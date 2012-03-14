package  
{
	import org.flixel.FlxBasic;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxU;
	import pieces.NullPiece;
	
	public class PlayingField extends FlxGroup
	{
		[Embed(source = "assets/bg.png")] private var _bg:Class;
		
		private var _pieces:Array;
		private var _dragAction:FlxGroup;
		private var _netplay:Netplay;
		
		public function PlayingField(netplay:Netplay) 
		{
			super();
			
			_netplay = netplay;
			_netplay.startTracking(processChanges);
			
			var bg:ZFlxSprite = new ZFlxSprite();
			bg.loadGraphic(_bg, false, false, 800, 600);
			add(bg);
			
			_pieces = new Array();
			for (var n:int = 0; n < 12 * 6; n++) 
			{
				_pieces[n] = new NullPiece();
			}
		}
		
		protected function processChanges(data:Object, raw:String):void
		{
			if (data.Changes)
			{
				trace(raw);
				for (var i:int = 0; i < data.Changes.length; i++)
				{
					var n:Number = data.Changes[i].n;
					var pieceName:String = data.Changes[i].PieceName;
					var teamColor:String = data.Changes[i].TeamColor;
					if (pieceName && teamColor)
					{
						var piece:ChessPiece = Utility.createPiece(pieceName, teamColor);
						addPieceLocalOnly(piece, n);
					}
					else
					{
						removePieceLocalOnly(n);
					}
				}
			}
		}
		
		public function removePieceNetworkOnly(n:Number):void
		{
			if (n >= 0 && n < _pieces.length)
			{
				_netplay.removePiece(n);
			}
		}
		
		public function removePieceLocalOnly(n:Number):void
		{
			if (n >= 0 && n < _pieces.length)
			{
				_pieces[n].kill();
				_pieces[n] = new NullPiece();
			}
		}
		
		public function addPiece(piece:ChessPiece, n:Number):void
		{
			if (n >= 0 && n < _pieces.length)
			{
				addPieceLocalOnly(piece, n);
				_netplay.addPiece(piece.name, piece.teamColor, n);
			}
		}
		
		public function addPieceLocalOnly(piece:ChessPiece, n:Number):void
		{
			if (n >= 0 && n < _pieces.length)
			{
				_pieces[n].kill();
				remove(_pieces[n]);
				_pieces[n] = piece;
				var gridPoint:FlxPoint = Utility.fieldNToXY(n);
				piece.x = gridPoint.x;
				piece.y = gridPoint.y;
				piece.n = n;
				add(piece);
			}
		}
		
		override public function update():void 
		{
			debugActions();
			var player:Player = Global.instance().player;
			if (FlxG.mouse.justPressed() && player.dragAction == null)
			{
				var startN:Number = Utility.mouseToFieldN(FlxG.mouse.getScreenPosition());
				if (!isNaN(startN) && _pieces[startN].canBePickedUp(player))
				{
					var pieceName:String = _pieces[startN].name;
					var pieceColor:String = _pieces[startN].teamColor;
					
					var gridPos:FlxPoint = Utility.fieldNToXY(startN);
					var ghost:ZFlxSprite = new ChessPiece(pieceName, pieceColor);
					ghost.x = gridPos.x;
					ghost.y = gridPos.y;
					ghost.alpha = 0.4;
					add(ghost);
					
					player.dragAction = new ChessPieceDragAction(player, pieceName, pieceColor);
					player.dragAction.successCallback = function(endN:Number):void {
						remove(ghost);
						var piece:ChessPiece = Utility.createPiece(pieceName, pieceColor);
						if (piece.canCapture(_pieces[endN]))
						{
							removePieceNetworkOnly(startN);
							addPiece(piece, endN);
						}
						else
						{
							addPieceLocalOnly(piece, startN);
						}
					};
					player.dragAction.errorCallback = function():void {
						remove(ghost);
						var piece:ChessPiece = Utility.createPiece(pieceName, pieceColor);
						addPiece(piece, startN);
					};
					removePieceLocalOnly(startN);
				}
			}
			updateDragAction();
		}
		
		protected function updateDragAction():void
		{
			var player:Player = Global.instance().player;
			if (player.dragAction != null)
			{
				if (_dragAction != null && _dragAction == player.dragAction)
				{
					_dragAction.update();
				}
				else
				{
					remove(_dragAction);
					_dragAction = player.dragAction;
					add(_dragAction);
				}
			}
			else
			{
				if (_dragAction != null)
				{
					remove(_dragAction);
					_dragAction = null;
				}
			}
		}
		
		// I tried to get members.sort working with a custom sortHandler but couldn't get it to work.
		// This sorting algorithm isn't efficient but didn't want to waste more time on this.
		protected function resort():void
		{
			// distinct list of z indecies
			var zlist:Array = new Array();
			var z:int;
			for (var i:int = 0; i < members.length; i++)
			{
				if (members[i] == undefined || members[i] == null)
				{
					continue;
				}
				z = (members[i] as IZIndex).zIndex;
				if (zlist.indexOf(z) == -1)
				{
					zlist.push(z);
				}
			}
			zlist.sort();
			// get index of where each member *should be*
			var newpos:Array = new Array();
			for (var n:int = 0; n < zlist.length; n++)
			{
				for (var k:int = 0; k < members.length; k++)
				{
					if (members[k] == undefined || members[k] == null)
					{
						continue;
					}
					z = (members[k] as IZIndex).zIndex;
					if (z == zlist[n])
					{
						newpos.push(k);
					}
				}
			}
			// swap old pos with new pos if needed
			for (var a:int = 0; a < newpos.length; a++)
			{
				var b:int = newpos[a];
				if (b > a)
				{
					var tmp:Object = members[a];
					members[a] = members[b];
					members[b] = tmp;
				}
			}
		}
		
		override public function add(Object:FlxBasic):FlxBasic 
		{
			resort();
			return super.add(Object);
		}
		
		protected function debugActions():void
		{
			if (FlxG.keys.justPressed("A"))
			{
				for (var i:int = 0; i < this.members.length; i++)
				{
					trace(i, members[i], members[i]==null?"":members[i].zIndex);
				}
				trace("---------------------------------");
			}
			if (FlxG.keys.justPressed("Z"))
			{
				resort();
			}
		}
	}
}
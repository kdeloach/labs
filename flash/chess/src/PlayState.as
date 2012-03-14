package  
{
	import flash.display.Graphics;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	
	public class PlayState extends FlxState
	{
		private var _field:PlayingField;
		
		public function PlayState() 
		{
			super();
		}
		
		override public function create():void 
		{
			FlxG.mouse.show();

			drawBg();
			
			var netplay:Netplay = new Netplay();
			var player:Player = Global.instance().player;
			
			_field = new PlayingField(netplay);
			add(_field);
			
			var loading:FlxText = new FlxText(0, 0, 200, "LOADING...");
			add(loading);

			netplay.getPlayingField(function(data:Object, raw:String):void {
				populateField(data.Field);
				remove(loading);
				var store:StoreToolbar = new StoreToolbar(_field);
				add(store);
				if (player.teamColor == "Spectator")
				{
					add(new FlxText(0, 0, 200, "SPECTATOR MODE"));
				}
			});
		}
		
		protected function populateField(field:Array):void
		{
			for (var n:int = 0; n < field.length; n++)
			{
				if (field[n].PieceName)
				{
					var piece:ChessPiece = Utility.createPiece(field[n].PieceName, field[n].TeamColor);
					_field.addPieceLocalOnly(piece, n);
				}
			}
		}
		
		private function drawBg():void 
		{
			var bg:Sprite = new Sprite();
			var g:Graphics = bg.graphics;
			g.beginFill(0xFFFFFF);
			g.drawRect(0, 0, 800, 600);
			g.endFill();
			var flxBg:FlxSprite = new FlxSprite();
			flxBg.makeGraphic(800, 600);
			flxBg.pixels.draw(bg);
			flxBg.dirty = true;
			add(flxBg);
		}
	}
}
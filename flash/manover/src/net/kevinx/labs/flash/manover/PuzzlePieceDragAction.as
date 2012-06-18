package net.kevinx.labs.flash.manover
{
	import org.flixel.FlxBasic;
	import org.flixel.FlxCamera;
	import org.flixel.FlxG;
	import org.flixel.FlxGame;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxRect;
	import org.flixel.FlxU;
	
	public class PuzzlePieceDragAction extends FlxGroup
	{
		private var _owner:PuzzleBox;
		private var _piece:PuzzlePiece;
		private var _mouseStart:FlxPoint = new FlxPoint();
		private var _mouseEnd:FlxPoint = new FlxPoint();
		private var _offset:FlxPoint;
		private var _shadow:PuzzlePiece;
		
		public function PuzzlePieceDragAction(owner:PuzzleBox, piece:PuzzlePiece)
		{
			super();
			_owner = owner;
			_piece = piece;
			
			_piece.layoutDirty = true;
			_shadow = _piece.clone();
			_shadow.pieceShadow = true;
		}
		
		override public function update():void 
		{
			if (FlxG.mouse.justPressed())
			{
				_mouseStart = mouse;
				_offset = new FlxPoint(mouse.x - _piece.x, mouse.y - _piece.y);
				_owner.add(_shadow);
				_owner.bringToFront(_piece);
			}
			else if(FlxG.mouse.pressed())
			{
				var targetPos:FlxPoint = new FlxPoint(mouse.x - _offset.x, mouse.y - _offset.y);
				if (!Util.pieceOverlaps(_owner.pieces, _piece, targetPos)
					&& Util.withinBounds(new FlxRect(targetPos.x, targetPos.y, _piece.width, _piece.height), _owner.rect))
				{
					_piece.x = targetPos.x;
					_piece.y = targetPos.y;
				}
			}
			else if (FlxG.mouse.justReleased())
			{
				kill();
			}
			super.update();
		}
		
		override public function kill():void 
		{
			_mouseEnd = FlxG.mouse.getScreenPosition();
			_shadow.kill();
			_owner.remove(_shadow);
			_owner.remove(this);
			_owner.updateNeighbors();
			super.kill();
		}
		
		private function get mouse():FlxPoint
		{
			var snap:FlxPoint = new FlxPoint(10, 18 / 2);
			var result:FlxPoint = new FlxPoint(int(FlxG.mouse.x / snap.x) * snap.x, int(FlxG.mouse.y / snap.y) * snap.y);
			return result;
		}
	}
}
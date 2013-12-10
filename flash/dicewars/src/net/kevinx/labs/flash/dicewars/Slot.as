package net.kevinx.labs.flash.dicewars 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import org.flixel.FlxPoint;
	
	public class Slot extends Sprite
	{
		public static const WIDTH:Number = 24;
		public static const HEIGHT:Number = 24;
		
		private var _territoryID:int = -1;
		private var _waterImmune:Boolean = false;
		private var _highlighted:Boolean = false;
		private var _row:int = 0;
		private var _col:int = 0;
		private var _owner:Territory;
		private var _txt:TextField;
		
        public function get territoryID():int { return _territoryID; }
        public function set territoryID(n:int):void { _territoryID = n; redraw(); }
        public function get waterImmune():Boolean { return _waterImmune; }
        public function set waterImmune(v:Boolean):void { _waterImmune = v; }
        public function get highlighted():Boolean { return _highlighted; }
        public function set highlighted(v:Boolean):void { _highlighted = v; redraw(); }
        public function get row():int { return _row; }
        public function get col():int { return _col; }
		
		// XXX: territoryID is used mainly for TerritoryGen but the owner is used for quick lookup of slot parent sprite.
		// These could be consolidated better.
		public function get owner():Territory { return _owner; }
		public function set owner(v:Territory):void { _owner = v; redraw(); }
		
		public function Slot(row:int, col:int, x:Number, y:Number) 
		{
			super();
	
			_row = row;
			_col = col;
			
			this.x = x;
			this.y = y;
			
			addEventListener(Event.ADDED_TO_STAGE, redraw);
			addEventListener(Event.RENDER, redraw);
		}
		
		public function redraw(e:Event = null):void 
		{
			draw(this.graphics);
		}
		
		protected function draw(g:Graphics):void
		{
			g.clear();
	
			var commands:Vector.<int> = new Vector.<int>();
			commands.push(1, 2, 2, 2, 2, 2, 2);
			
			var w:Number = WIDTH + 1;
			var h:Number = HEIGHT + 1;
			var x:Number = 0;
			var y:Number = 0;
			
			var coords:Vector.<Number> = new Vector.<Number>();
			coords.push(
				x + w / 2, y,
				x + w,     y + h * 1 / 4,
				x + w,     y + h * 3 / 4,
				x + w / 2, y + h,
				x,         y + h * 3 / 4,
				x,         y + h * 1 / 4,
			 	x + w / 2, y		
			);
			
			g.beginFill(_highlighted ? getHighlightedColor() : getColor(), 1);
			g.drawPath(commands, coords);
			g.endFill();
			
			if (0) {
				g.lineStyle(1, 0x00FF00);
				g.drawPath(commands, coords);
			}
		}
		
		public function getColor():uint
		{
			if (_owner) return _owner.getColor();
			return 0xFFFFFF;
		}
		
		public function getHighlightedColor():uint
		{
			return 0xDDDDDD;
		}
		
		override public function toString():String 
		{
			return "[Slot@(" + _col + "," + _row + ")]";
		}
		
		public function isWater():Boolean
		{
			return _owner && _owner.isWater;
		}
		
		public function getFlxPoint():FlxPoint 
		{
			return new FlxPoint(x, y);
		}
	}
}
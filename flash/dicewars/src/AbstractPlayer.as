package  
{
	import com.codecatalyst.promise.Deferred;
	import com.codecatalyst.promise.Promise;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	public class AbstractPlayer extends EventDispatcher
	{
		private var _id:int;
		private var _name:String;
		private var _color:uint;
		private var _pool:int = 0;
		
		private var _arrow:Sprite;
		private var _enableAnimation:Boolean = true;
		
		public function get id():int { return _id; }
		public function get name():String { return _name; }
		public function get color():uint { return _color; }
		public function get pool():int { return _pool; }
		public function set pool(n:int):void { _pool = n; }
		
		public function get enableAnimation():Boolean { return _enableAnimation; }
		public function set enableAnimation(v:Boolean):void { _enableAnimation = v; }
		
		public function AbstractPlayer(id:int, name:String, color:uint) 
		{
			_id = id;
			_name = name;
			_color = color;
		}
		
		public function move():Promise
		{
			throw new Error("Abstract method");
		}
		
		// t1 - Attacking
		// t2 - Defending
		protected function performMove(t1:Territory, t2:Territory):Promise 
		{			
			if (t1 == t2 || t1.playerID == t2.playerID) {
				trace("Do nothing");
				return Promise.when(null);
			}
			
			var game:Gameplay = Globals.game;
			var deferred:Deferred = new Deferred();

			addArrow(t1, t2);
			
			performAnimation(function():void {
				t1.active = true;
			}, 0);
			
			performAnimation(function():void {
				t2.active = true;
			}, game.BOT_DELAY_MS * 1);
			
			performAnimation(function():void {
				var d1:Number = Util.rollDice(t1.armySize);
				var d2:Number = Util.rollDice(t2.armySize);
				trace(d1, "attacks", d2);
				if (d1 > d2) {
					t2.armySize = t1.armySize - 1;	
					t1.armySize = 1;
					t2.playerID = t1.playerID;
				} else {
					t1.armySize = 1;
				}
			}, game.BOT_DELAY_MS * 2);
			
			performAnimation(function():void {
				t1.active = false;
				t2.active = false;
				removeArrow();
				deferred.resolve(null);
			}, game.BOT_DELAY_MS * 3);
			
			return deferred.promise;
		}
		
		private function performAnimation(fn:Function, delay:Number):void
		{
			if (_enableAnimation) {
				setTimeout(fn, delay);
			} else {
				fn();
			}
		}
		
		private function addArrow(t1:Territory, t2:Territory):void
		{
			// Author: Jason Sturges
			// Source: http://stackoverflow.com/questions/7908545/need-to-be-able-to-draw-arrows-with-the-mouse-and-be-able-to-select-it
			_arrow = new Sprite();
			_arrow.alpha = 0.25;
			var toRadian:Number = Math.PI / 180;
			var t1Pos:Point = new Point(t1.midCenterSlot().x + Slot.WIDTH / 2, t1.midCenterSlot().y + Slot.HEIGHT / 2);
			var t2Pos:Point = new Point(t2.midCenterSlot().x + Slot.WIDTH / 2, t2.midCenterSlot().y + Slot.HEIGHT / 2);
			var angle:Number = Math.atan2(t2Pos.y - t1Pos.y, t2Pos.x - t1Pos.x);
			var angle45:Number = Math.PI / 4;
			_arrow.graphics.lineStyle(5, 0xFF0000, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
			_arrow.graphics.moveTo(t1Pos.x, t1Pos.y);
			_arrow.graphics.lineTo(t2Pos.x, t2Pos.y);
			_arrow.graphics.moveTo(
				t2Pos.x - 20 * Math.cos(angle - angle45),
				t2Pos.y - 20 * Math.sin(angle - angle45)
			);
			_arrow.graphics.lineTo(t2Pos.x, t2Pos.y);
			_arrow.graphics.lineTo(
				t2Pos.x - 20 * Math.cos(angle + angle45),
				t2Pos.y - 20 * Math.sin(angle + angle45)
			);
			Globals.map.addChild(_arrow);
		}
		
		private function removeArrow():void
		{
			Globals.map.removeChild(_arrow);
		}
		
		override public function toString():String 
		{
			return "[Player#" + id + "]";
		}
	}
}
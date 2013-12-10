package net.kevinx.labs.flash.dicewars 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import org.flixel.FlxU;
	
	public class Territory extends Sprite
	{
		private var _territoryID:int = -1;
		private var _playerID:int = -1;
		private var _armySize:int = 1;
		private var _armyLimit:int = 1;
		private var _txt:TextField;
		private var _isWater:Boolean = false;
		private var _active:Boolean = false;
		
		private var _slots:Vector.<Slot>;
		private var _neighborSlots:Vector.<Slot>;
		
		private var _hover:Boolean = false;

        public function get territoryID():int { return _territoryID; }
        public function set territoryID(n:int):void { _territoryID = n; redraw(); }
        public function get playerID():int { return _playerID; }
        public function set playerID(n:int):void { _playerID = n; redraw(); }
		public function get armySize():int { return _armySize; }
		public function set armySize(n:int):void { _armySize = n; redraw(); }
		public function get armyLimit():int { return _armyLimit; }
		public function set armyLimit(n:int):void { _armyLimit = n; }
		public function get neighborSlots():Vector.<Slot> { return _neighborSlots; }
		public function set neighborSlots(v:Vector.<Slot>):void { _neighborSlots = v; }
        public function get hover():Boolean { return _hover; }
        public function set hover(v:Boolean):void { _hover = v; redraw(); }
        public function get isWater():Boolean { return _isWater; }
        public function set isWater(v:Boolean):void { _isWater = v; }
        public function get active():Boolean { return _active; }
        public function set active(v:Boolean):void { _active = v; redraw(); }
		
		public function Territory(id:int) 
		{
			super();
			
			buttonMode = true;
			
			_territoryID = id;
			_slots = new Vector.<Slot>();
			_neighborSlots = new Vector.<Slot>();
			
			_txt = new TextField();
			_txt.autoSize = TextFieldAutoSize.CENTER;
			_txt.mouseEnabled = false;
			_txt.embedFonts = true;
			_txt.defaultTextFormat = new TextFormat("nokia", 18, 0xFFFFFF);
			
			this.filters = [new GlowFilter(0xFFFFFF, 0.75, 3, 3, 2, BitmapFilterQuality.LOW, true)];
			
			addEventListener(Event.ADDED_TO_STAGE, redraw);
			addEventListener(Event.RENDER, redraw);
		}
		
		public function ready():void
		{
			if (isWater) return;
			var midSlot:Slot = midCenterSlot();
			_txt.x = midSlot.x + Slot.WIDTH / 3;
			_txt.y = midSlot.y;
			_txt.text = "" + _armySize;
			addChild(_txt);	
		}
		
		public function addSlot(slot:Slot):void
		{
			slot.owner = this;
			slot.territoryID = _territoryID;
			_slots.push(slot);
			addChild(slot);
			redraw();
		}
		
		public function slotAt(i:int):Slot
		{
			return _slots[i];
		}
		
		public function redraw(e:Event = null):void 
		{
			draw(this.graphics);
		}
		
		protected function draw(g:Graphics):void
		{
			_txt.text = "" + _armySize;
			_slots.forEach(function(item:Slot, index:int, arr:Vector.<Slot>):void {
				item.highlighted = _hover;
			});
		}
		
		override public function toString():String 
		{
			return "[Territory#" + _territoryID + "]";
		}
		
		public function size():int
		{
			return _slots.length;
		}
		
		public function midCenterSlot():Slot
		{
			var arrSlots:Array = Util.vectorToArray(_slots as Vector.<*>);
			var cols:Array = arrSlots.map(function(item:Slot, index:int, arr:Array):int { return item.col; } );
			var rows:Array = arrSlots.map(function(item:Slot, index:int, arr:Array):int { return item.row; });
			var minCol:int = Math.min.apply(null, cols);
			var maxCol:int = Math.max.apply(null, cols);
			var minRow:int = Math.min.apply(null, rows);
			var maxRow:int = Math.max.apply(null, rows);
			var targetCol:int = Math.floor((minCol + maxCol) / 2);
			var targetRow:int = Math.floor((minRow + maxRow) / 2);
			var dist:Function = function(x:Number, y:Number):Number { return Math.sqrt(x * x + y * y); };
			var result:Slot = _slots[0];
			for (var i:int = 1; i < _slots.length; i++) {
				var slot:Slot = _slots[i];
				var d1:Number = dist(result.col - targetCol, result.row - targetRow);
				var d2:Number = dist(slot.col - targetCol, slot.row - targetRow);
				if (d2 < d1 && siblings(slot).length == 6) {
					result = slot;
				}
			}
			return result;
		}
		
		private function siblings(slot:Slot):Vector.<Slot>
		{
			var self:Territory = this;
			var neighbors:Vector.<Slot> =  Globals.map.getNeighborSlots(slot);
			var result:Vector.<Slot> = neighbors.filter(function(item:Slot, i:int, lst:Vector.<Slot>):Boolean {
				return item.owner == self;
			});
			return result;
		}
		
		public function getColor():uint
		{
			if (_isWater) return 0xFFFFFF;
			if (_playerID > -1) {
				if (_active) {
					var c:Array = FlxU.getHSB(Globals.game.getPlayer(_playerID).color);
					return FlxU.makeColorFromHSB(c[0], c[1], _active ? 0.75 : c[2]);
				}
				return Globals.game.getPlayer(_playerID).color;
			}
			// Neutral territory color
			return 0xDDC9AB;
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			_hover = true;
			useHandCursor = true;
			redraw();
		}
		
		private function onMouseOut(e:MouseEvent):void
		{
			_hover = false;
			useHandCursor = true;
			redraw();
		}
	}
}
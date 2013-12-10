package 
{
	import com.codecatalyst.promise.Deferred;
	import com.codecatalyst.promise.Promise;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import org.as3commons.collections.Set;
	
	public class Map extends Sprite
	{
		private var _cols:int;
		private var _rows:int;
		private var _slots:Array;
		
		private var _width:Number;
		private var _height:Number;
		
		// Populated by TerritoryGen
		private var _territories:Vector.<Territory>;
		public function get territories():Vector.<Territory> { return _territories; }
		public function set territories(v:Vector.<Territory>):void { _territories = v; }
		
		public function get cols():int { return _cols; }
		public function get rows():int { return _rows; }
		
		public function Map(width:Number, height:Number)
		{
			_width = width;
			_height = height;
			
			var outline:GlowFilter = new GlowFilter(0, 1, 6, 6, 20, 1);
			var border:GlowFilter = new GlowFilter(0, 0.5, 2, 2, 4, BitmapFilterQuality.LOW);
			//this.filters = _hover ? [outline] : [border];
			this.filters = [border];
		}
		
		public function build():Promise
		{
			_cols = _width / Slot.WIDTH;
			_rows = _height / (Slot.HEIGHT * 3 / 4);
			_slots = new Array(_cols * _rows);
			
			for (var i:int = 0; i < _slots.length; i++) {
				var col:int = i % _cols;
				var row:int = Math.floor(i / _cols);
				
				var x:Number = col * Slot.WIDTH;
				var y:Number = row * (Slot.HEIGHT * 3 / 4);
				
				if (row % 2 == 0) {
					x += Slot.WIDTH / 2;
				}
				
				var slot:Slot = new Slot(row, col, x, y);
				slot.visible = false;
				_slots[i] = slot;
				addChild(_slots[i]);
			}
			
			var deferred:Deferred = new Deferred();
			deferred.resolve(null);
			return deferred.promise;
		}
		
		public function slotAt(row:int, col:int):Slot
		{
			return _slots[row * _cols + col];
		}
		
		private function slotAtPoint(p:Point):Slot
		{
			var things:Array = stage.getObjectsUnderPoint(p);
			for (var i:int = 0; i < things.length; i++) {
				if (things[i] is Slot) {
					return things[i];
				}
			}
			return null;
		}
		
		public function territoryAtPoint(p:Point):Territory
		{
			var slot:Slot = slotAtPoint(p);
			if (slot && slot.owner) {
				return slot.owner;
			}
			return null;
		}
		
		public function inBounds(n:Number, lo:Number, hi:Number):Boolean
		{
			return n >= lo && n < hi;
		}
		
		public function getNeighborSlots(slot:Slot):Vector.<Slot>
		{
			var col:int = slot.col;
			var row:int = slot.row;
			
			var altRowOffset:int = row % 2 == 0 ? 1 : 0;
			
			return getNeighborsHelper(
				[col - 1 + altRowOffset, row - 1],
				[col + altRowOffset, row - 1],
				
				[col - 1, row],
				[col + 1, row],
				
				[col - 1 + altRowOffset, row + 1],
				[col + altRowOffset, row + 1]
			);	
		}
		
		public function getNeighbors2(slot:Slot):Vector.<Slot>
		{
			var col:int = slot.col;
			var row:int = slot.row;
			
			var altRowOffset:int = row % 2 == 0 ? 1 : 0;
			
			return getNeighborsHelper(
				[col - 1, row - 2],
				[col, row - 2],
				[col + 1, row - 2],
				
				[col - 2 + altRowOffset, row - 1],
				[col + 1 + altRowOffset, row - 1],
				
				[col - 2, row],
				[col + 2, row],
				
				[col - 2 + altRowOffset, row + 1],
				[col + 1 + altRowOffset, row + 1],
				
				[col - 1, row + 2],
				[col, row + 2],
				[col + 1, row + 2]
			);	
		}
		
		private function getNeighborsHelper(...rowColPairs:Array):Vector.<Slot>
		{
			var result:Vector.<Slot> = new Vector.<Slot>();
			for (var i:int = 0; i < rowColPairs.length; i++) {
				var pair:Array = rowColPairs[i];
				var col:int = pair[0];
				var row:int = pair[1];
				if (inBounds(col, 0, _cols) && inBounds(row, 0, _rows)) {
					var slot:Slot = slotAt(row, col);
					if (slot) {
						result.push(slot);
					}
				}
			}
			return result;
		}
		
		public function getNeighborTerritories(t:Territory):Vector.<Territory>
		{
			var allNeighbors:Set = new Set();
			for (var i:int = 0; i < t.size(); i++) {
				var slot:Slot = t.slotAt(i);
				var neighbors:Vector.<Slot> = getNeighborSlots(slot);
				neighbors.forEach(function(item:Slot, index:int, lst:Vector.<Slot>):void {
					if (!item.owner.isWater && item.territoryID != t.territoryID) {
						allNeighbors.add(item.owner);
					}
				});
			}
			var result:Vector.<Territory> = new Vector.<Territory>();
			result.push.apply(null, allNeighbors.toArray());
			return result;
		}
		
		public function getPlayerTerritories(playerID:int):Vector.<Territory>
		{
			return _territories.filter(function(item:Territory, index:int, arr:Vector.<Territory>):Boolean {
				return item.playerID == playerID;
			});
		}
		
		public function sharesBorder(t1:Territory, t2:Territory):Boolean
		{
			if (t1 == t2) {
				return true;
			}
			var neighbors:Vector.<Territory> = getNeighborTerritories(t1);
			for (var i:int = 0; i < neighbors.length; i++) {
				if (neighbors[i] == t2) {
					return true;
				}
			}
			return false;
		}
		
		// True if player owns at least one territory
		public function playerCanMove(playerID:int):Boolean
		{
			for (var i:int = 0; i < Globals.game.NUM_TERRITORIES; i++) {
				if (territories[i].playerID == playerID) {
					return true;
				}
			}
			return false;
		}
		
		override public function toString():String 
		{
			return "[Map]";
		}
	}
}
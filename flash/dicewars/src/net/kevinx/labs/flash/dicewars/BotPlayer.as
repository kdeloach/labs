package net.kevinx.labs.flash.dicewars 
{
	import com.codecatalyst.promise.Promise;
	
	public class BotPlayer extends AbstractPlayer 
	{
		public function BotPlayer(id:int, name:String, color:uint) 
		{
			super(id, name, color);
			enableAnimation = true;
		}
		
		override public function move():Promise
		{
			dispatchEvent(new PlayerEvent("move", this));
			return moveOnce();
		}
		
		private function moveOnce(territoryID:int=0, armiesMoved:int=0, victory:Boolean=false):Promise
		{
			var map:Map = Globals.map;
			var lands:Vector.<Territory> = map.getPlayerTerritories(id);
			
			if (territoryID == lands.length) {
				if (armiesMoved > 0) {
					// At least one move was made so start over.
					return moveOnce(0, 0);
				} else {
					// Finished; Iterated through all lands and none of them were able to make a move.
					return Promise.when(null);
				}
			}
			
			var t1:Territory = lands[territoryID];
			
			if (t1.armySize <= 1) {
				return moveOnce(territoryID + 1, armiesMoved);
			}
			
			var neighbors:Vector.<Territory> = map.getNeighborTerritories(t1);
			neighbors = neighbors.filter(isOwnedByOtherPlayers);
			neighbors.sort(sortByArmySizeAsc);
			
			if (neighbors.length == 0) {
				return moveOnce(territoryID + 1, armiesMoved);
			}
			
			// TODO: 
			// Attack weakest neighbor
			var t2:Territory = neighbors[0];
			
			return performMove(t1, t2).then(function():Promise {
				return moveOnce(territoryID + 1, armiesMoved + 1);
			});
		}
		
		private function isOwnedByOtherPlayers(item:Territory, index:int, arr:Vector.<Territory>):Boolean
		{
			return item.playerID != id;
		}
		
		private function armySizeLessThan(n:int):Function
		{
			return function (item:Territory, index:int, arr:Vector.<Territory>):Boolean {
				return item.armySize < n;
			}
		}
		
		private function sortByArmySizeAsc(a:Territory, b:Territory):Number
		{
			if (a.armySize < b.armySize) return -1;
			if (a.armySize > b.armySize) return 1;
			return 0;
		}
	}
}
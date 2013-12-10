package
{
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    import flash.utils.setTimeout;
    import org.as3commons.collections.Set;
    import org.flixel.FlxU;

    public class TerritoryGen extends EventDispatcher
    {
        private var ENABLE_ANIMATION:Boolean = false;
        private var DELAY_MS:int = 100;

        private var _map:Map;
        private var _territories:Vector.<Territory>;

        public function TerritoryGen(map:Map)
        {
            _map = map;
        }

        public function gen():Promise
        {
            _territories = new Vector.<Territory>();
            _map.territories = _territories;

            var deferred:Deferred = new Deferred();

            createLand()
                .then(connect)
                .then(createWater)
                .then(expand)
                .then(finish)
                .then(createPlayers)
                .then(deferred.resolve);

            return deferred.promise;
        }

        private function createLand(territoryID:int = 0):Promise
        {
            if (territoryID == Globals.game.NUM_TERRITORIES) {
                return Promise.when(null);
            }

            var territory:Territory = new Territory(territoryID);
            _map.addChild(territory);

            var slot:Slot = randomSlot();

            claimSlot(territory, slot);
            claimNeighbors(territory, slot);

            _territories.push(territory);

            var deferred:Deferred = new Deferred();

            performAnimation(function():void {
                createLand(territoryID + 1).then(deferred.resolve);
            });

            return deferred.promise;
        }

        private function createWater():Promise
        {
            for (var i:int = 0; i < Globals.game.NUM_WATERS; i++) {
                var territory:Territory = new Territory(Globals.game.NUM_TERRITORIES + i);
                territory.isWater = true;
                territory.visible = false;
                _map.addChild(territory);

                var slot:Slot = randomSlot();

                claimSlot(territory, slot);
                claimNeighbors(territory, slot);

                _territories.push(territory);
            }

            var deferred:Deferred = new Deferred();
            deferred.resolve(null);
            return deferred.promise;
        }

        public function claimSlot(territory:Territory, slot:Slot):void
        {
            slot.territoryID = territory.territoryID;
            slot.visible = true;
            territory.addSlot(slot);
        }

        public function claimNeighbors(territory:Territory, slot:Slot):void
        {
            var neighbors:Vector.<Slot> = _map.getNeighborSlots(slot);
            for (var i:int = 0; i < neighbors.length; i++) {
                claimSlot(territory, neighbors[i]);
            }
        }

        // Each territory expands once from each slot possible.
        public function expand():Promise
        {
            var keepGoing:Boolean = false;

            for (var i:int = 0; i < _territories.length; i++) {
                var territory:Territory = _territories[i];
                var territoryFilter:Function = canBeOccupiedByTerritory(territory);

                var tsize:int = territory.size();

                for (var j:int = 0; j < tsize; j++) {
                    var currSlot:Slot = territory.slotAt(j);
                    var neighbors:Vector.<Slot> = _map.getNeighborSlots(currSlot);
                    neighbors = neighbors.filter(territoryFilter);

                    // If slot has no more neighbors to expand to, try again with the next slot
                    if (neighbors.length == 0) {
                        continue;
                    }

                    // Claim new territory!

                    var neighborIndex:int = Math.floor(Math.random() * neighbors.length);
                    var neighbor:Slot = neighbors[neighborIndex];
                    claimSlot(territory, neighbor);

                    // Keep going as long as one territory expands per iteration
                    keepGoing = true;
                }
            }

            var deferred:Deferred = new Deferred();

            if (!keepGoing) {
                deferred.resolve(null);
            } else {
                performAnimation(function():void {
                    expand().then(deferred.resolve);
                });
            }

            return deferred.promise;
        }

        // This draws a line from the first to last territories and marks all slots under
        // the line as "water immune" which will prevent water territories from claiming
        // these slots during the expand phase. Without this step, islands can form.
        private function connect(territoryID:int = 0):Promise
        {
            // XXX: Promise chain passes the last resolved value (probably null) into the
            // first argument which gets cast as 0 but we always want to start from 1.
            if (territoryID <= 0) {
                return connect(1);
            }

            if (territoryID == Globals.game.NUM_TERRITORIES) {
                return Promise.when(null);
            }

            var t1:Territory = _territories[territoryID - 1];
            var t2:Territory = _territories[territoryID];

            var first:Slot = t1.slotAt(0);
            var last:Slot = t2.slotAt(0);

            var slot:Slot = first;
            var distance:Number = FlxU.getDistance(slot.getFlxPoint(), last.getFlxPoint());

            while (distance > 0) {
                var neighbors:Vector.<Slot> = _map.getNeighborSlots(slot);
                for (var k:int = 0; k < neighbors.length; k++) {
                    var target:Slot = neighbors[k];
                    var targetDistance:Number = FlxU.getDistance(target.getFlxPoint(), last.getFlxPoint());
                    var whoopsWrongTurn:Boolean = Math.random() < 0.1;
                    if (whoopsWrongTurn || targetDistance < distance) {
                        slot = target;
                        distance = targetDistance;
                    }
                }
                slot.visible = true;
                slot.highlighted = true;
                slot.waterImmune = true;
            }

            var deferred:Deferred = new Deferred();

            performAnimation(function():void {
                connect(territoryID + 1).then(deferred.resolve);
            });

            return deferred.promise;
        }

        private function finish():Promise
        {
            for (var i:int = 0; i < _territories.length; i++) {
                var territory:Territory = _territories[i];
                territory.neighborSlots = getNeighborSlots(territory);
                territory.armyLimit = 12;
                territory.armySize = 1;
                territory.ready();
            }
            return Promise.when(null);
        }

        private function createPlayers(playerID:int = 0):Promise
        {
            if (playerID == Globals.game.numberOfPlayers()) {
                return Promise.when(null);
            }

            var territory:Territory = randomTerritory();
            territory.playerID = playerID;
            territory.armySize = Globals.game.INITIAL_ARMYSIZE;

            var deferred:Deferred = new Deferred();

            performAnimation(function():void {
                createPlayers(playerID + 1).then(deferred.resolve);
            });

            return deferred.promise;
        }

        // Return random unclaimed slot.
        public function randomSlot():Slot
        {
            // We make the assumption that this function is never called when there
            // are no remaining slots left. Otherwise, this loop will not terminate.
            while (true) {
                var row:int = Math.floor(Math.random() * _map.rows - 2) + 1;
                var col:int = Math.floor(Math.random() * _map.cols - 2) + 1;
                var slot:Slot = _map.slotAt(row, col);

                if (!canBeOccupied(slot)) {
                    continue;
                }

                var neighbors:Vector.<Slot> = _map.getNeighborSlots(slot);
                var freeNeighbors:Vector.<Slot> = neighbors.filter(function(item:Slot, index:int, arr:Vector.<Slot>):Boolean {
                    if (item.waterImmune) {
                        return false;
                    }
                    return canBeOccupied(item);
                });

                if (freeNeighbors.length < 6) {
                    continue;
                }
                return slot;
            }
            return null;
        }

        // Return random unclaimed territory
        public function randomTerritory():Territory
        {
            while (true) {
                var i:int = Math.floor(Math.random() * Globals.game.NUM_TERRITORIES);
                var territory:Territory = _territories[i];
                if (territory.playerID == -1) {
                    return territory;
                }
            }
            return null;
        }

        private function getNeighborSlots(t:Territory):Vector.<Slot>
        {
            var allNeighbors:Set = new Set();
            for (var i:int = 0; i < t.size(); i++) {
                var slot:Slot = t.slotAt(i);
                var neighbors:Vector.<Slot> = _map.getNeighborSlots(slot);
                neighbors.forEach(function(item:Slot, index:int, lst:Vector.<Slot>):void {
                    if (item.territoryID != t.territoryID) {
                        allNeighbors.add(item);
                    }
                });
            }
            var result:Vector.<Slot> = new Vector.<Slot>();
            result.push.apply(null, allNeighbors.toArray());
            return result;
        }

        public function canBeOccupied(slot:Slot, index:int = -1, arr:Vector.<Slot> = null):Boolean
        {
            return slot && slot.territoryID == -1;
        }

        public function canBeOccupiedByTerritory(territory:Territory):Function
        {
            return function(item:Slot, index:int, arr:Vector.<Slot>):Boolean {
                if (territory.isWater && item.waterImmune) {
                    return false;
                }
                return canBeOccupied(item);
            };
        }

        // Perform func within a setTimout closure if animation is enabled.
        private function performAnimation(func:Function):void
        {
            if (ENABLE_ANIMATION) {
                setTimeout(func, DELAY_MS);
            } else {
                func();
            }
        }
    }
}

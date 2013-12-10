package
{
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    public class HumanPlayer extends AbstractPlayer
    {
        private var _btnEndTurn:Button;

        public function HumanPlayer(id:int, name:String, color:uint)
        {
            super(id, name, color);
            enableAnimation = false;
            _btnEndTurn = new Button("End Turn", 125);
        }

        override public function move():Promise
        {
            dispatchEvent(new PlayerEvent("move", this));

            var map:Map = Globals.map;
            var deferred:Deferred = new Deferred();

            var t1:Territory;
            var t2:Territory;

            Globals.game.addChild(_btnEndTurn);
            _btnEndTurn.x = 10;
            _btnEndTurn.y = 10;

            var mapOnClick:Function = function(e:MouseEvent):void {
                var territory:Territory = map.territoryAtPoint(new Point(e.stageX, e.stageY));

                if (!territory) return;

                if (!t1 && territory.playerID == id && territory.armySize > 1) {
                    t1 = territory;
                    t1.active = true;
                } else if (t1 && !t2) {
                    t2 = territory;
                }

                if (t1 && t2) {
                    if (map.sharesBorder(t1, t2)) {
                        t2.active = true;
                        performMove(t1, t2);
                    }

                    t1.active = false;
                    t2.active = false;
                    t1 = null;
                    t2 = null;
                }
            };

            var btnEndTurnOnClick:Function = function(e:MouseEvent):void {
                Globals.game.removeChild(_btnEndTurn);
                _btnEndTurn.removeEventListener(MouseEvent.CLICK, btnEndTurnOnClick);
                map.removeEventListener(MouseEvent.CLICK, mapOnClick);
                deferred.resolve(null);
            };

            _btnEndTurn.addEventListener(MouseEvent.CLICK, btnEndTurnOnClick);
            map.addEventListener(MouseEvent.CLICK, mapOnClick);

            return deferred.promise;
        }
    }
}

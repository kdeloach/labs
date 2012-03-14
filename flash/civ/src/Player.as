package  
{
    import events.GameEvent;
    import flash.events.EventDispatcher;
    import org.flixel.FlxG;
    import org.flixel.FlxPoint;
    import org.flixel.FlxU;
    
    public class Player extends EventDispatcher
    {
        private var _placingStartCity:Boolean = false;
        private var _map:Map;
        private var _cities:Array;
        
        private var _cityUnderMouse:City;
        
        public function Player(map:Map) 
        {
            _map = map;
            _cities = new Array();
        }
        
        public function placeStartingCity():void
        {
            _placingStartCity = true;
            _cityUnderMouse = new City(this, _map);
            _cities.push(_cityUnderMouse);
            _map.addCity(_cityUnderMouse);
        }
        
        public function update():void
        {
            if (_placingStartCity)
            {
                updatePlacingStartCity();
                return;
            }
        }
        
        public function updatePlacingStartCity():void
        {
            _cityUnderMouse.x = Utility.mouse.x - _cityUnderMouse.width / 2;
            _cityUnderMouse.y = Utility.mouse.y - _cityUnderMouse.height / 2;
            _cityUnderMouse.redrawBoundaries();
            
            if (FlxG.mouse.justPressed())
            {
                var pos:FlxPoint = Utility.mousePositionRelativeToMap();
                if (_map.canPlaceCityHere(_cityUnderMouse.size, pos.x, pos.y))
                {
                    _map.addCity(_cityUnderMouse);
                    _placingStartCity = false;
                    _cityUnderMouse = null;
                    dispatchEvent(new GameEvent(GameEvent.READY_TO_PLAY));
                }
            }
        }
    }
}
package  
{
    import flash.display.Sprite;
    import org.flixel.FlxBasic;
    import org.flixel.FlxGroup;
    import org.flixel.FlxSprite;
    
    public class Map extends FlxGroup
    {
        public static const GROUND:uint = 0;
        public static const WATER:uint = 1;
        
        // 2D array of HeightColor objects
        private var _heightMap:Array;
        private var _cities:Array;
        
        public function Map(heightMap:Array) 
        {
            _heightMap = heightMap;
            _cities = new Array();
            redrawBG();
        }
        
        public function redrawBG():void
        {
            var mapBG:Sprite = new Sprite();
            for (var y:int = 0; y < GameSettings.MAP_SIZE.height; y++)
            {
                for (var x:int = 0; x < GameSettings.MAP_SIZE.width; x++)
                {
                    mapBG.graphics.beginFill(_heightMap[y][x].color);
                    mapBG.graphics.drawRect(GameSettings.BLOCK_SIZE * x, 
                                            GameSettings.BLOCK_SIZE * y, 
                                            GameSettings.BLOCK_SIZE, 
                                            GameSettings.BLOCK_SIZE);
                    mapBG.graphics.endFill();
                }
            }
            var flxMapBG:FlxSprite = new FlxSprite();
            flxMapBG.makeGraphic(800, 600);
            flxMapBG.pixels.draw(mapBG);
            flxMapBG.dirty = true;
            add(flxMapBG);
        }
        
        public function addCity(city:FlxSprite):void
        {
            _cities.push(city);
            add(city);
        }
        
        // TODO: factor in city size
        public function canPlaceCityHere(citySize:uint, x:int, y:int):Boolean
        {
            if (y >= 0 && y < _heightMap.length && x >= 0 && x < _heightMap[y].length)
            {
                return (_heightMap[y][x] as HeightColor).type == GROUND;
            }
            return false;
        }
        
        public function isGround(x:int, y:int):Boolean
        {
            if (y >= 0 && y < _heightMap.length && x >= 0 && x < _heightMap[y].length)
            {
                return (_heightMap[y][x] as HeightColor).type == GROUND;
            }
            return false;
        }
    }
}
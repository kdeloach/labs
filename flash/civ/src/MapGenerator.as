package  
{
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import org.flixel.FlxSprite;
    public class MapGenerator
    {
        // how many pixels of noise to generate per block
        public var pxPerBlockSize:uint = 1;
        public var percWater:Number = 0.40;
        // these must be sorted by height
        public var shades:Array;
        
        public function MapGenerator() 
        {
            shades = new Array();
            shades.push(new HeightColor(1, 0x669966, Map.GROUND));
            shades.push(new HeightColor(percWater, 0x336699, Map.WATER));
        }
        
        public function createRandomMap():Map
        {
            var w:uint = pxPerBlockSize * GameSettings.MAP_SIZE.width;
            var h:uint = pxPerBlockSize * GameSettings.MAP_SIZE.height;
            var noise:BitmapData = new BitmapData(w, h, false);
            var seed:uint = Math.random() * 10000;
            noise.perlinNoise(w, h, 12, seed, false, true, 1, true);
        
            var heightMap:Array = new Array();
            var darkest:Number = 0xFFFFFF;
            var brightest:Number = 0x000000;
            
            for (var y:uint = 0; y < GameSettings.MAP_SIZE.height; y++)
            {
                heightMap[y] = new Array();
                for (var x:uint = 0; x < GameSettings.MAP_SIZE.width; x++)
                {
                    heightMap[y][x] = noise.getPixel(pxPerBlockSize * x, pxPerBlockSize * y);
                    heightMap[y][x] /= 0xFFFFFF;
                    if (heightMap[y][x] < darkest) {
                        darkest = heightMap[y][x];
                    }
                }
            }
            for (y = 0; y < GameSettings.MAP_SIZE.height; y++)
            {
                for (x = 0; x < GameSettings.MAP_SIZE.width; x++) {
                    heightMap[y][x] -= darkest;
                    if (heightMap[y][x] > brightest)
                    {
                        brightest = heightMap[y][x];
                    }
                }
            }
            for (y = 0; y < GameSettings.MAP_SIZE.height; y++)
            {
                for (x = 0; x < GameSettings.MAP_SIZE.width; x++)
                {
                    heightMap[y][x] /= brightest;
                    // Up until this point heightMap was a 2D array of uint
                    // but NOW it is a 2D array of HeightMap objects...
                    heightMap[y][x] = getHeightColor(heightMap[y][x]);
                }
            }
            
            var map:Map = new Map(heightMap);
            return map;
        }
        
        // assumes list of shades are sorted by height from high to low
        public function getHeightColor(height:Number):HeightColor
        {
            var hc:HeightColor;
            for (var i:uint = 0; i < shades.length; i++)
            {
                if (height <= (shades[i] as HeightColor).height)
                {
                    hc = (shades[i] as HeightColor);    
                }
            }
            return hc;
        }
    }
}
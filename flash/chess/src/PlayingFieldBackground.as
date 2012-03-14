package  
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import org.flixel.FlxSprite;
	
	public class PlayingFieldBackground extends FlxSprite
	{
		public var _heightMap:Array;
		public var _pixelation:int = 10;
		
		public function PlayingFieldBackground() 
		{
			super();
		}
		
		public function createRandomBg():void
		{
			_heightMap = createRandomHeightMap();
			redrawBG();
		}
		
		private function createRandomHeightMap():Array
		{
			var w:uint = 850;
			var h:uint = 650;
			var mapSize:Dimension = new Dimension(w / _pixelation, h / _pixelation);
			var noise:BitmapData = new BitmapData(w, h, false);
			var seed:uint = Math.random() * 10000;
			noise.perlinNoise(w, h, 12, seed, false, true, 1, true);
		
			var heightMap:Array = new Array();
			var darkest:Number = 0xFFFFFF;
			var brightest:Number = 0x000000;
			
			for (var y:uint = 0; y < mapSize.height; y++)
			{
				heightMap[y] = new Array();
				for (var x:uint = 0; x < mapSize.width; x++)
				{
					heightMap[y][x] = noise.getPixel(_pixelation * x, _pixelation * y);
					heightMap[y][x] /= 0xFFFFFF;
					if (heightMap[y][x] < darkest) {
						darkest = heightMap[y][x];
					}
				}
			}
			for (y = 0; y < mapSize.height; y++)
			{
				for (x = 0; x < mapSize.width; x++)
				{
					heightMap[y][x] -= darkest;
					if (heightMap[y][x] > brightest) {
						brightest = heightMap[y][x];
					}
				}
			}
			for (y = 0; y < mapSize.height; y++)
			{
				for (x = 0; x < mapSize.width; x++)
				{
					heightMap[y][x] /= brightest;
					heightMap[y][x] *= 0xFF;
					heightMap[y][x] = heightMap[y][x] << 16 | heightMap[y][x] << 8 | heightMap[y][x];
				}
			}
			return heightMap;
		}
		
		public function redrawBG():void
		{
			var w:uint = 850;
			var h:uint = 650;
			var mapSize:Dimension = new Dimension(w / _pixelation, h / _pixelation);
			var mapBG:Sprite = new Sprite();
			for (var y:int = 0; y < mapSize.height; y++)
			{
				for (var x:int = 0; x < mapSize.width; x++)
				{
					/*
					var r:uint = _heightMap[y][x] >> 16 & 0xFF;
					var g:uint = _heightMap[y][x] >> 8 & 0xFF;
					var b:uint = _heightMap[y][x] & 0xFF;
					var hsb:Object = RGBtoHSB(r, g, b);
					hsb.s = 30;
					hsb.b = -10;
					var rgb:Object = HSBtoRGB(hsb.h, hsb.s, hsb.b);
					var color:uint = rgb.r << 16 | rgb.g << 8 | rgb.b;
					mapBG.graphics.beginFill(color);
					*/
					mapBG.graphics.beginFill(_heightMap[y][x]);
					mapBG.graphics.drawRect(_pixelation * x, _pixelation * y, _pixelation, _pixelation);
					mapBG.graphics.endFill();
				}
			}
			
            var applyGreen:Array = new Array();
            applyGreen = applyGreen.concat([0, 0, 0, 0, 0]);
            applyGreen = applyGreen.concat([0, 1, 0, 0, 0]); 
            applyGreen = applyGreen.concat([0, 0, 0, 0, 0]); 
            applyGreen = applyGreen.concat([0, 0, 0, 1, 0]); 
			
			var brightness:Array = new Array();
            brightness = brightness.concat([1, 0, 0, 0, 0]);
            brightness = brightness.concat([0, 1, 0, 0, 0]); 
            brightness = brightness.concat([0, 0, 1, 0, 0]); 
            brightness = brightness.concat([0, 0, 0, 1, 0]); 
			
			mapBG.filters = [
				new ColorMatrixFilter(applyGreen),
				new ColorMatrixFilter(brightness),
				new BlurFilter(25, 25)
			];
			
			this.makeGraphic(850, 650);
			this.pixels.draw(mapBG);
			this.dirty = true;
		}

		private function RGBtoHSB(r:int, g:int, b:int):Object
		{
			var hsb:Object = new Object;
			var _max:Number = Math.max(r,g,b);
			var _min:Number = Math.min(r,g,b);
			
			hsb.s = (_max != 0) ? (_max - _min) / _max * 100: 0;
			hsb.b = _max / 255 * 100;

			if(hsb.s == 0){
				hsb.h = 0;
			}else{
				switch(_max)
				{
					case r:
						hsb.h = (g - b)/(_max - _min)*60 + 0;
						break;
					case g:
						hsb.h = (b - r)/(_max - _min)*60 + 120;
						break;
					case b:
						hsb.h = (r - g)/(_max - _min)*60 + 240;
						break;
				}
			}
			
			hsb.h = Math.min(360, Math.max(0, Math.round(hsb.h)))
			hsb.s = Math.min(100, Math.max(0, Math.round(hsb.s)))
			hsb.b = Math.min(100, Math.max(0, Math.round(hsb.b)))
			
			return hsb;
		}
		
		private function HSBtoRGB(h:int, s:int, b:int):Object
		{
			var rgb:Object = new Object();
			var max:Number = (b * 0.01) * 255;
			var min:Number = max * (1 - (s * 0.01));
			
			if (h == 360) {
				h = 0;
			}
			
			if (s == 0) {
				rgb.r = rgb.g = rgb.b = b*(255*0.01) ;
			} else {
				var _h:Number = Math.floor(h / 60);
				
				switch(_h){
					case 0:
						rgb.r = max	;
						rgb.g = min+h * (max-min)/ 60;
						rgb.b = min;
						break;
					case 1:
						rgb.r = max-(h-60) * (max-min)/60;
						rgb.g = max;
						rgb.b = min;
						break;
					case 2:
						rgb.r = min ;
						rgb.g = max;
						rgb.b = min+(h-120) * (max-min)/60;
						break;
					case 3:
						rgb.r = min;
						rgb.g = max-(h-180) * (max-min)/60;
						rgb.b =max;
						break;
					case 4:
						rgb.r = min+(h-240) * (max-min)/60;
						rgb.g = min;
						rgb.b = max;
						break;
					case 5:
						rgb.r = max;
						rgb.g = min;
						rgb.b = max-(h-300) * (max-min)/60;
						break;
					case 6:
						rgb.r = max;
						rgb.g = min+h  * (max-min)/ 60;
						rgb.b = min;
						break;
				}

				rgb.r = Math.min(255, Math.max(0, Math.round(rgb.r)))
				rgb.g = Math.min(255, Math.max(0, Math.round(rgb.g)))
				rgb.b = Math.min(255, Math.max(0, Math.round(rgb.b)))
			}
			return rgb;
		}


	}

}
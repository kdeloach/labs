package net.kevinx.labs.flash.dicewars 
{
	public class Util 
	{
		public function Util() 
		{
		}
		
		public static function rollDice(numDice:int):int
		{
			var result:int = 0;
			for (var i:int = 0; i < numDice; i++) {
				result += Math.floor(Math.random() * 6) + 1;
			}
			return result;
		}
		
		public static function partial(fn:Function, ...a:Array):Function
		{
			return function (...b):* {
				return fn.apply(null, a.concat(b));
			}
		}
		
		// Author: Arie de Bonth
		// Source: http://www.bonth.nl/2010/07/25/as3-vector-shuffle-or-randomize/
		public static function shuffleVector(vec:Vector.<*>):void
		{
			if (vec.length > 1) {
				var i:int = vec.length - 1;
				while (i > 0) {
					var s:Number = Math.floor(Math.random() * vec.length);
					var temp:* = vec[s];
					vec[s] = vec[i];
					vec[i] = temp;
					i--;
				}
			}
		}
		
		// Vector.map is broken in Flash Player 11...
		// http://stackoverflow.com/q/4875830/40
		public static function vectorToArray(vec:Vector.<*>):Array
		{
			var result:Array = [];
			for (var i:int = 0; i < vec.length; i++) {
				result.push(vec[i]);
			}
			return result;
		}
	}
}
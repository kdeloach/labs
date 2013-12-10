package net.kevinx.labs.flash.dicewars 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	
	public class Globals 
	{
		public static var stage:Stage;
		public static var map:Map;
		public static var game:Gameplay;
		
		public static var debugSprite:Sprite;
		
		[Embed(source = "./content/nokiafc22.ttf", fontName="nokia", embedAsCFF=false)]
		private var nokiaFont:String;
		
		public function Globals() 
		{
		}
	}
}
package 
{
	import org.flixel.FlxGame;

	[SWF(width="800", height="600", backgroundColor="#FFFFFF")]
	public class Main extends FlxGame 
	{		
		public function Main():void 
		{
			var zoom:int = 1;
			super(800/zoom, 600/zoom, PlayState, zoom, 30, 30);
		}
	}
}
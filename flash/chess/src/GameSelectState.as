package  
{
	import com.adobe.serialization.json.JSONEncoder;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	
	public class GameSelectState extends FlxState
	{
		[Embed(source = "assets/bg.png")] private var _bg:Class;
		
		public function GameSelectState() 
		{
			super();
		}
		
		override public function create():void 
		{
			FlxG.mouse.show();
			drawBg();
			var global:Global = Global.instance();
			var netplay:Netplay = new Netplay();
			var btnNewGame:FlxButton = new FlxButton(70, 125, "New Game", function():void {
				netplay.newGame(function():void {
					FlxG.switchState(new PlayerSelectState());	
				});
			});
			var btnContinueGame:FlxButton = new FlxButton(250, 125, "Resume Game", function():void {
				FlxG.switchState(new PlayerSelectState());
			});
			btnNewGame.scale = new FlxPoint(2, 4);
			btnContinueGame.scale = new FlxPoint(2, 4);
			add(btnNewGame);
			add(btnContinueGame);
		}
		
		private function drawBg():void 
		{
			var bg:ZFlxSprite = new ZFlxSprite();
			bg.loadGraphic(_bg, false, false, 800, 600);
			add(bg);
		}
	}
}
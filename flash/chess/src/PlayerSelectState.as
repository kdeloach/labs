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
	
	public class PlayerSelectState extends FlxState
	{
		[Embed(source = "assets/bg.png")] private var _bg:Class;
		
		public function PlayerSelectState() 
		{
			super();
		}
		
		override public function create():void 
		{
			FlxG.mouse.show();
			drawBg();
			var global:Global = Global.instance();
			var netplay:Netplay = new Netplay();
			var btnPlayer1:FlxButton = new FlxButton(70, 125, "White", function():void {
				netplay.setPlayers( { White: true }, function(data:Object, raw:String):void {
					global.player = new Player("White");
					FlxG.switchState(new PlayState());	
				});
			});
			var btnPlayer2:FlxButton = new FlxButton(250, 125, "Black", function():void {
				netplay.setPlayers( { Black: true }, function(data:Object, raw:String):void {
					global.player = new Player("Black");
					FlxG.switchState(new PlayState());	
				});
			});
			btnPlayer1.scale = new FlxPoint(2, 4);
			btnPlayer2.scale = new FlxPoint(2, 4);
			
			netplay.getPlayers(function(data:Object, raw:String):void {
				if (data.White && data.Black)
				{
					global.player = new Player("Spectator");
					FlxG.switchState(new PlayState());
				}
				else if (data.White)
				{
					netplay.setPlayers( { Black:true } );
					global.player = new Player("Black");
					FlxG.switchState(new PlayState());
				}
				else if (data.Black)
				{
					netplay.setPlayers( { White:true } );
					global.player = new Player("White");
					FlxG.switchState(new PlayState());
				}
				else
				{
					add(btnPlayer1);
					add(btnPlayer2);
				}
			});
		}
		
		private function drawBg():void 
		{
			var bg:ZFlxSprite = new ZFlxSprite();
			bg.loadGraphic(_bg, false, false, 800, 600);
			add(bg);
		}
	}
}
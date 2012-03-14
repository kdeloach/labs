package  
{
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	
	public class PlayState extends FlxState
	{
		public var player:Player;
		public var ground:FlxSprite;
		public var wall1:FlxSprite;
		public var wall2:FlxSprite;
		public var platform:FlxSprite;
		
		public function PlayState() 
		{					
			super();
		}
		
		override public function create():void 
		{
			super.create();
			
			FlxG.mouse.show();
			FlxG.bgColor = 0xFFDDDDDD;
			
			player = new Player(this);
			player.body.x = FlxG.width / 2 - player.body.width;
			player.body.y = FlxG.height / 2 - player.body.height;	
			
			ground = new FlxSprite(player.body.x - 600, player.body.y + 125);
			ground.makeGraphic(1200, 25, 0xFF555555);
			ground.immovable = true;
			add(ground);
			
			wall1 = new FlxSprite(0, 0);
			wall1.makeGraphic(5, 1000, 0xFF555555);
			wall1.immovable = true;
			add(wall1);
			
			wall2 = new FlxSprite(315, 0);
			wall2.makeGraphic(5, 1000, 0xFF555555);
			wall2.immovable = true;
			add(wall2);
			
			platform = new FlxSprite(player.body.x - 50, player.body.y + 85);
			platform.makeGraphic(100, 5, 0xFF555555);
			platform.immovable = true;
			add(platform);
			
			add(player);
			
			add(new DebugHUD(this, player));
		}
				
		override public function update():void 
		{
			super.update();
			FlxG.collide(player, ground);
			FlxG.collide(player, wall1);
			FlxG.collide(player, wall2);
			FlxG.collide(player, platform);
		}
	}
}
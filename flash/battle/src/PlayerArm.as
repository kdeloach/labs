package  
{
	import flash.geom.Point;
	import flash.text.engine.FontDescription;
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxU;
	
	public class PlayerArm extends FlxSprite
	{
		[Embed(source = "assets/arm.png")] private var arm:Class;
		
		protected  var player:Player;
		private var offsets:Array;
		
		public function PlayerArm(player:Player) {
			super();
			
			this.player = player;
			loadGraphic(arm, true, false, 13, 6);
			addAnimation("aim_right", [0], 1);
			addAnimation("aim_left", [1], 1);
			play("aim_right");
			allowCollisions = 0;
			offsets = [
				// right
				new Point(17, 18),
				new Point(17, 16),
				new Point(17, 18),
				new Point(21, 16),
				new Point(16, 10),
				// left (subtract arm length and body width)
				new Point(32 - 16 - 13, 10),
				new Point(32 - 21 - 13, 16),
				new Point(32 - 17 - 13, 18),
				new Point(32 - 17 - 13, 16),
				new Point(32 - 17 - 13, 18)
			];
			origin.y = 2;
		}
		
		public function move():void
		{
			angle = FlxU.getAngle(new FlxPoint(x, y), FlxG.mouse.getScreenPosition()) - 90;
			
			if (player.body.dirfacing() == "left") {
				play("aim_left");
				origin.x = 13;
				angle -= 180;
			} else {
				play("aim_right");
				origin.x = 0;
			}
			
			if (player.body.curindex() < offsets.length) {
				x = player.body.x + offsets[player.body.curindex()].x  - player.body.offset.x;
				y = player.body.y + offsets[player.body.curindex()].y  - player.body.offset.y;

			}			
		}
	}
}
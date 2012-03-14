package  
{
	import flash.text.engine.BreakOpportunity;
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	
	
	public class DebugHUD extends FlxSprite
	{
		private var player:Player;
		private var state:FlxState;
		
		private var btnYspeed:FlxButton;
		private var txtYspeed:FlxText;
		private var btnMaxYVel:FlxButton;
		private var txtMaxYVel:FlxText;
		private var btnAccelY:FlxButton;
		private var txtAccelY:FlxText;
		private var btnJumpTicks:FlxButton;
		private var txtJumpTicks:FlxText;
		
		public function DebugHUD(state:FlxState, player:Player) 
		{
			super();
			
			this.player = player;
			this.state = state;
			this.makeGraphic(1, 1, 0x00000000);
			
			x = FlxG.camera.x;
			y = FlxG.camera.y;
			
			btnYspeed = new FlxButton(0, 0, "yspeed", function():void {
				player.body.yspeed += 25 * shiftPressed();
				txtYspeed.text = player.body.yspeed + "";
			});
			txtYspeed = new FlxText(90, 0, 100, player.body.yspeed + "");
			txtYspeed.color = 0xFF000000;
			
			btnMaxYVel = new FlxButton(0, 21, "max vel Y", function():void {
				player.body.maxVelocity.y += 25 * shiftPressed();
				txtMaxYVel.text = player.body.maxVelocity.y + "";
			});
			txtMaxYVel = new FlxText(90, 21, 100, player.body.maxVelocity.y + "");
			txtMaxYVel.color = 0xFF000000;
			
			btnAccelY = new FlxButton(0, 42, "accel Y", function():void {
				player.body.acceleration.y += 50 * shiftPressed();
				txtAccelY.text = player.body.acceleration.y + "";
			});
			txtAccelY = new FlxText(90, 42, 100, player.body.acceleration.y + "");
			txtAccelY.color = 0xFF000000;
			
			btnJumpTicks = new FlxButton(0, 63, "jump ticks", function():void {
				player.body.jumpTicksLimit += 1 * shiftPressed();
				txtJumpTicks.text = player.body.jumpTicksLimit + "";
			});
			txtJumpTicks = new FlxText(90, 63, 100, player.body.jumpTicksLimit + "");
			txtJumpTicks.color = 0xFF000000;
			
			state.add(btnYspeed);
			state.add(txtYspeed);
			state.add(btnMaxYVel);
			state.add(txtMaxYVel);
			state.add(btnAccelY);
			state.add(txtAccelY);
			state.add(btnJumpTicks);
			state.add(txtJumpTicks);
		}
		
		private function shiftPressed():int
		{
			return FlxG.keys.SHIFT ? -1 : 1;
		}
	}
}
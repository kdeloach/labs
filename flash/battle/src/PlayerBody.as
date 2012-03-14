package
{
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;

    public class PlayerBody extends FlxSprite
    {
        [Embed(source = "assets/mm.png")] private var img:Class;

        public var xspeed:int;
        public var yspeed:int;
        public var jumpTicksLimit:int;

        protected var player:Player;

        private var movingLeft:Boolean = false;
        private var justJumped:Boolean = false;
        private var jumping:Boolean = false;
        private var holdingJump:Boolean = false;
        // number of ticks to occur before the jump reaches its peak
        private var jumpTicks:int = 0;
        // number of animation frames which need to pass before jump is allowed
        private var jumpNumFramesDisabled:int = 0;

        public function PlayerBody(player:Player) {
            super();

            this.player = player;

            loadGraphic(img, true, false, 32, 30);
            addAnimation("run_right", [1, 2, 1, 0], 8);
            addAnimation("run_left", [8, 7, 8, 9], 8);
            addAnimation("idle_right", [3], 1);
            addAnimation("idle_left", [6], 1);
            addAnimation("jump_right", [4], 1);
            addAnimation("jump_left", [5], 1);

            // hit box adjustments
            offset.x = 10;
            width = 14;

            idle();

            xspeed = 100;
            yspeed = 200;
            jumpTicksLimit = 10;

            maxVelocity.x = 100;
            maxVelocity.y = 300;
            acceleration.y = maxVelocity.y * 4;
        }

        private function move():void
        {
            if (movingLeft) {
                velocity.x = -xspeed;
            } else {
                velocity.x = xspeed;
            }
            if (!jumping) {
                play("run_" + dirfacing());
            }
        }

        private function idle():void
        {
            acceleration.x = 0;
            if (!jumping) {
                play("idle_" + dirfacing());
            }
        }

        private function jump():void
        {
            if (justJumped) {
                jumpNumFramesDisabled = 10;
            }
            if (holdingJump && jumpTicks < jumpTicksLimit) {
                velocity.y = -yspeed;
                jumpTicks++;
            }
            play("jump_" + dirfacing());
        }

        public function dirfacing():String {
            if (FlxG.mouse.x < x) {
                return "left";
            }
            return "right";
        }

        public function curindex():uint {
            return _curIndex;
        }

        override public function update():void
        {
            var moving:Boolean = false;

            jumping = !isTouching(FlxObject.FLOOR);
            justJumped = justTouched(FlxObject.FLOOR);

            // pressing JUMP as soon as you land can bypass the short delay that
            // occurs if you just hold W to repeatedly JUMP
            if (!jumping && FlxG.keys.justPressed("SPACE")) {
                jumpNumFramesDisabled = 0;
            }
            if (FlxG.keys.justReleased("SPACE")) {
                holdingJump = false;
            }
            if (!jumping && FlxG.keys.SPACE && jumpNumFramesDisabled == 0) {
                jumping = true;
                holdingJump = true;
                justJumped = true;
                jumpTicks = 0;
            } else {
                justJumped = false;
            }

            if (!jumping && jumpNumFramesDisabled > 0) {
                jumpNumFramesDisabled -= 1;
            }

            if (FlxG.keys.justPressed("A")) {
                movingLeft = true;
            }
            if (FlxG.keys.justPressed("D")) {
                movingLeft = false;
            }
            if (FlxG.keys.justReleased("D") && FlxG.keys.A) {
                movingLeft = true;
            }
            if (FlxG.keys.justReleased("A") && FlxG.keys.D) {
                movingLeft = false;
            }

            if (FlxG.keys.A) {
                moving = true;
            }
            if (FlxG.keys.D) {
                moving = true;
            }

            if (moving) {
                move();
            }  else {
                velocity.x = 0;
            }
            if (jumping) {
                jump();
            }
            if(!moving && !jumping) {
                idle();
            }

            super.update();
        }

        override public function postUpdate():void
        {
            super.postUpdate();
            player.arm.move();
        }

        override public function draw():void
        {
            super.draw();
            return;
            for (var y:int = 0; y < 2; y++) {
                for (var x:int = 0; x < 5; x++) {
                    var myx:int = x * 32;
                    var myy:int = y * 30;
                    drawRect(myx + offset.x, myy + 1, width,  30 - 2);
                    //drawLine(myx, myy, myx + 32, myy + 30, 0xFFFF0000);
                    //drawLine(myx, myy + 30, myx + 32, myy, 0xFFFF0000);
                }
            }
        }

        private function drawRect(x:int, y:int, w:int, h:int):void
        {
            drawLine(x, y, x + w, y, 0xFFFF0000);
            drawLine(x + w, y, x + w, y + h, 0xFFFF0000);
            drawLine(x + w, y + h, x, y + h, 0xFFFF0000);
            drawLine(x, y + h, x, y, 0xFFFF0000);
        }
    }
}

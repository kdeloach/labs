package  
{
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxState;

    public class Player extends FlxSprite
    {
        [Embed(source = "assets/sprite.png")]
        private var img:Class;

        public var xspeed:int;
        public var yspeed:int;
        public var jumpTicksLimit:int;
        
        private var jumping:Boolean = false;
        private var attacking:Boolean = false;
        
        private var movingLeft:Boolean = false;
        private var justJumped:Boolean = false;
        private var holdingJump:Boolean = false;
        // number of ticks to occur before the jump reaches its peak
        private var jumpTicks:int = 0;
        // number of animation frames which need to pass before jump is allowed
        private var jumpNumFramesDisabled:int = 0;
        
        public var controller:PlayerController;
        
        public var stage:FlxState;
        private var particles:Array;
        private var missleDelay:int = 0;

        public function Player(stage:FlxState, controller:PlayerController)
        {
            super();

            this.stage = stage;
            this.controller = controller;
            
            loadGraphic(img, true, false, 31, 30);            
            addAnimation("run_left", [1, 0, 1, 2], 8);
            addAnimation("run_right", [6, 7, 6, 5], 8);
            addAnimation("idle_left", [3], 1);
            addAnimation("idle_right", [4], 1);
            addAnimation("jump_left", [11], 1);
            addAnimation("jump_right", [12], 1);
            addAnimation("attack_run_left", [19, 18, 19, 20], 8);
            addAnimation("attack_run_right", [24, 25, 24, 23], 8);
            addAnimation("attack_idle_left", [21], 1);
            addAnimation("attack_idle_right", [22], 1);
            addAnimation("attack_jump_left", [9], 1);
            addAnimation("attack_jump_right", [14], 1);
            
            // hit box adjustments
            offset.x = 5;
            width = 15;

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
                play(animationName("run"));
            }
        }

        private function idle():void
        {
            acceleration.x = 0;
            play(animationName("idle"));
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
            play(animationName("jump"));
        }

        public function dirfacing():String
        {
            return movingLeft ? "left" : "right";
        }

        private function animationName(name:String):String
        {
            return (attacking ? "attack_" : "") + name + "_" + dirfacing();
        }
        
        override public function update():void
        {
            var moving:Boolean = false;
        
            jumping = !isTouching(FlxObject.FLOOR);
            justJumped = justTouched(FlxObject.FLOOR);

            // pressing JUMP as soon as you land can bypass the short delay that occurs if you just hold SPACE to repeatedly JUMP
            if (!jumping && controller.justPressedJump) {
                jumpNumFramesDisabled = 0;
            }
            if (controller.justReleasedJump) {
                holdingJump = false;
            }
            if (!jumping && controller.jump && jumpNumFramesDisabled == 0) {
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

            if (controller.justPressedMoveLeft) {
                movingLeft = true;
            }
            if (controller.justPressedMoveRight) {
                movingLeft = false;
            }
            if (controller.justReleasedMoveRight && controller.moveLeft) {
                movingLeft = true;
            }
            if (controller.justReleasedMoveLeft && controller.moveRight) {
                movingLeft = false;
            }

            if (controller.moveLeft) {
                moving = true;
            }
            if (controller.moveRight) {
                moving = true;
            }
            
            attacking = controller.attack;

            if (moving) {
                move();
            }  else {
                velocity.x = 0;
            }
            if (jumping) {
                jump();
            }
            if (!moving && !jumping) {
                idle();
            }
            
            if (attacking) {
                if (missleDelay % 3 == 0) {
                    fireMissle();
                    missleDelay = 0;
                }
                missleDelay++;
            }
            
            super.update();
        }
        
        private function fireMissle():void
        {
            var offset:FlxPoint = new FlxPoint(movingLeft ? -20 : 20, jumping ? 6 : 12);
            var src:FlxPoint = new FlxPoint(x + offset.x, y + offset.y);
            var dest:FlxPoint = new FlxPoint(movingLeft ? -1000 : 1000, y);
            stage.add(new Bullet(stage, src.x, src.y, dest.x, dest.y));
        }
    }
}

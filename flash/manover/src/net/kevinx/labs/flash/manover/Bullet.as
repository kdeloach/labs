package net.kevinx.labs.flash.manover 
{
    import org.flixel.FlxG;
    import org.flixel.FlxGroup;
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    import org.flixel.FlxState;
    import org.flixel.FlxU;

    public class Bullet extends FlxSprite
    {
        [Embed(source = "assets/bullet.png")]
        private var bullet:Class;

        private var stage:FlxState;
        private var speed:int = 300;

        public function Bullet(stage:FlxState, x:int, y:int, targetX:int, targetY:int)
        {
            this.stage = stage;
            
            loadGraphic(bullet, false, false, 22, 10);
            addAnimation("left", [0], 1);
            addAnimation("right", [1], 1);
            
            this.health = 100;
            this.x = x;
            this.y = y;
            
            velocity.x = (x < targetX ? 1 : -1) * speed;
            
            play(x < targetX ? "right" : "left");
        }

        override public function update():void
        {
            hurt(1);
            super.update();
        }

        override public function kill():void
        {
            stage.remove(this);
            super.kill();
        }
    }
}

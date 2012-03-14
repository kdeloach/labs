package
{
    import org.flixel.FlxG;
    import org.flixel.FlxGroup;
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    import org.flixel.FlxState;
    import org.flixel.FlxU;

    public class Bullet extends FlxSprite
    {
        [Embed(source = "assets/particle.png")] private var bullet:Class;

        private var stage:FlxState;
        private var speed:int = 300;

        public function Bullet(stage:FlxState, x:int, y:int, targetX:int, targetY:int)
        {
            this.stage = stage;
            loadGraphic(bullet);
            this.health = 100;
            this.x = x;
            this.y = y;

            var toRadian:Number = Math.PI /  180;
            var theta:Number = FlxU.getAngle(new FlxPoint(x, y), new FlxPoint(targetX, targetY));
            theta -= 90;
            theta *= toRadian;
            this.velocity.x = Math.cos(theta) * speed;
            this.velocity.y = Math.sin(theta) * speed;
        }

        override public function update():void
        {
            hurt(1);
            super.update();
        }

        override public function kill():void
        {
            super.kill();
        }
    }
}

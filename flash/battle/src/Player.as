package
{
    import flash.text.engine.FontDescription;
    import org.flixel.FlxEmitter;
    import org.flixel.FlxG;
    import org.flixel.FlxGroup;
    import org.flixel.FlxSprite;
    import org.flixel.FlxObject;
    import org.flixel.FlxState;

    public class Player extends FlxGroup
    {
        public var body:PlayerBody;
        public var arm:PlayerArm;
        public var stage:FlxState;

        private var particles:Array;
        private var missleDelay:int = 0;

        public function Player(stage:FlxState)
        {
            super();
            this.stage = stage;
            body = new PlayerBody(this);
            arm = new PlayerArm(this);
            add(arm);
            add(body);
        }

        override public function update():void
        {
            if (FlxG.mouse.pressed()) {
                if (missleDelay % 3 == 0) {
                    fireMissle();
                    missleDelay = 0;
                }
                missleDelay++;
            }
            super.update();
        }

        private function fireMissle():void {
            var bullet:Bullet = new Bullet(stage, arm.x, arm.y, FlxG.mouse.x, FlxG.mouse.y);
            stage.add(bullet);
            trace("boom");
        }
    }
}

package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import org.flixel.*;

    [SWF(width="640", height="480", backgroundColor="#000000")]
    public class Main extends FlxGame
    {
        public function Main():void
        {
            super(320, 240, PlayState, 2, 60, 60);
        }
    }
}

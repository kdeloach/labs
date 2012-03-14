package 
{
    import flash.events.Event;
    import org.flixel.FlxGame;

    [SWF(width="800", height="600", backgroundColor="#FFFFFF")]
    public class Main extends FlxGame 
    {        
        public function Main():void 
        {
            var zoom:int = 2;
            super(800 / zoom, 600 / zoom, GameSelectState, zoom, 30, 30);
        }
        
        override protected function create(FlashEvent:Event):void
        {
            super.create(FlashEvent);
            stage.removeEventListener(Event.DEACTIVATE, onFocusLost);
            stage.removeEventListener(Event.ACTIVATE, onFocus);
        }
    }
}
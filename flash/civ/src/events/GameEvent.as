package events 
{
    import flash.events.Event;
    
    public class GameEvent extends Event
    {
        public static const READY_TO_PLAY:String = "readyToPlay";
        
        public function GameEvent(command:String) 
        {
            super(command);
        }
    }
}
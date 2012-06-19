package pieces 
{
    import org.flixel.FlxG;
    
    public class Attack extends PuzzlePiece 
    {
        public function Attack() 
        {
            super("Attack", 4);
        }
        
        override public function updateController(controller:PlayerController):void 
        {
            controller.attack = emitting;
        }
    }
}

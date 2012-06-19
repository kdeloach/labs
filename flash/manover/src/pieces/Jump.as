package pieces 
{
    import org.flixel.FlxG;
    
    public class Jump extends PuzzlePiece 
    {
        public function Jump() 
        {
            super("Jump", 4);
        }
        
        override public function updateController(controller:PlayerController):void 
        {
            controller.justPressedJump = !controller.jump && emitting;
            controller.justReleasedJump = controller.jump && !emitting;
            controller.jump = emitting;
        }
    }
}

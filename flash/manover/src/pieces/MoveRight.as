package pieces 
{
    import org.flixel.FlxG;
    
    public class MoveRight extends PuzzlePiece 
    {
        public function MoveRight() 
        {
            super("Move Right", 6);
        }
        
        override public function updateController(controller:PlayerController):void 
        {
            controller.justPressedMoveRight = !controller.moveRight && emitting;
            controller.justReleasedMoveRight = controller.moveRight && !emitting;
            controller.moveRight = emitting;
        }
    }
}

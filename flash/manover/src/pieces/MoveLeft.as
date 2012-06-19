package pieces 
{
    import org.flixel.FlxG;
    
    public class MoveLeft extends PuzzlePiece
    {
        public function MoveLeft() 
        {
            super("Move Left", 6);
        }
        
        override public function updateController(controller:PlayerController):void 
        {
            controller.justPressedMoveLeft = !controller.moveLeft && emitting;
            controller.justReleasedMoveLeft = controller.moveLeft && !emitting;
            controller.moveLeft = emitting;
        }
    }
}

package net.kevinx.labs.flash.manover.pieces 
{
    import net.kevinx.labs.flash.manover.PlayerController;
    import net.kevinx.labs.flash.manover.PuzzlePiece;
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

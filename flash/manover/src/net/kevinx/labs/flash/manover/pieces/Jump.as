package net.kevinx.labs.flash.manover.pieces 
{
    import net.kevinx.labs.flash.manover.PlayerController;
    import net.kevinx.labs.flash.manover.PuzzlePiece;
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

package net.kevinx.labs.flash.manover.pieces 
{
    import net.kevinx.labs.flash.manover.PlayerController;
    import net.kevinx.labs.flash.manover.PuzzlePiece;
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

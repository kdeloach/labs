package net.kevinx.labs.flash.manover.pieces 
{
    import net.kevinx.labs.flash.manover.PuzzlePiece;
    import org.flixel.FlxG;
    
    public class Shift extends PuzzlePiece 
    {
        public function Shift() 
        {
            super("SHIFT", 4);
        }
        
        override public function get emitting():Boolean 
        {
            return FlxG.keys.SHIFT;
        }
        
        override public function set emitting(val:Boolean):void 
        {
        }
    }
}

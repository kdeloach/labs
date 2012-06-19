package pieces 
{
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

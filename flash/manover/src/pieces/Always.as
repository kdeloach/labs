package pieces 
{
    import org.flixel.FlxG;
    
    public class Always extends PuzzlePiece 
    {
        public function Always() 
        {
            super("Always", 4);
        }
        
        override public function get emitting():Boolean 
        {
            return true;
        }
    }
}

package pieces 
{
    import org.flixel.FlxG;
    
    public class Space extends PuzzlePiece 
    {
        public function Space() 
        {
            super("SPACE", 4);
        }
        
        override public function get emitting():Boolean 
        {
            return FlxG.keys.SPACE;
        }
        
        override public function set emitting(val:Boolean):void 
        {
        }
    }
}

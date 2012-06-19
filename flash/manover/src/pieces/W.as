package pieces 
{
    import org.flixel.FlxG;
    
    public class W extends PuzzlePiece 
    {
        public function W() 
        {
            super("W", 2);
        }
        
        override public function get emitting():Boolean 
        {
            return FlxG.keys.W;
        }
        
        override public function set emitting(val:Boolean):void 
        {
        }
    }
}

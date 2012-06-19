package pieces 
{
    import org.flixel.FlxG;
    
    public class D extends PuzzlePiece 
    {
        public function D() 
        {
            super("D", 2);
        }
        
        override public function get emitting():Boolean 
        {
            return FlxG.keys.D;
        }
        
        override public function set emitting(val:Boolean):void 
        {
        }
    }
}

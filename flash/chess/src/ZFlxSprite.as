package  
{
    import org.flixel.FlxSprite;

    public class ZFlxSprite extends FlxSprite implements IZIndex
    {
        private var _zIndex:int = 0;
        public function get zIndex():int { return _zIndex; }
        public function set zIndex(idx:int):void { _zIndex = idx; }
    }
}
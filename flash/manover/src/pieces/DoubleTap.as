package pieces 
{
    import org.flixel.FlxG;
    import org.flixel.FlxU;
    
    public class DoubleTap extends PuzzlePiece 
    {
        private var _lastCalled:uint = 0;
        private var _lastEmits:Array = [0, 0];
        
        private var _speed:uint = 400;
        private var _duration:uint = 500;
        
        public function DoubleTap() 
        {
            super("Doubletap", 6);
        }
                
        override public function get emitting():Boolean
        {
            var delta:int = _lastEmits[1] - _lastEmits[0];
            return delta <= _speed && FlxU.getTicks() - _lastEmits[1] < _duration;
        }
        
        override public function set emitting(val:Boolean):void 
        {
            if (emitting || !val)
            {
                return;
            }
            var delta:int = FlxU.getTicks() - _lastCalled;
            if (delta > 70)
            {
                _lastEmits[0] = _lastEmits[1];
                _lastEmits[1] = FlxU.getTicks();
            }
            _lastCalled = FlxU.getTicks();
        }
    }
}

package
{
    import flash.utils.getTimer;

    // Author: Joshua Honig
    // Source: http://stackoverflow.com/a/12495538
    public class StopWatch
    {
        private var _mark:int;
        private var _started:Boolean = false;

        public function start():void
        {
            _mark = getTimer();
            _started = true;
        }

        // Milliseconds elapsed since start
        public function get elapsed():int
        {
            return _started ? getTimer() - _mark : 0;
        }
    }
}

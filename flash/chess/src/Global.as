package  
{
    public class Global 
    {
        protected static var _instance:Global = null;
        
        public var _player:Player;
        public function get player():Player { return _player; }
        public function set player(p:Player):void { _player = p; }
        
        public function Global() 
        {
        }
        
        public static function instance():Global
        {
            if (_instance == null)
            {
                _instance = new Global();
            }
            return _instance;
        }
    }
}
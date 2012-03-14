package  
{
    public class GameSettings
    {
        public static var BLOCK_SIZE:uint = 10;
        
        // map size in terms of blocks
        public static var MAP_SIZE:Dimension =
            new Dimension(800 / GameSettings.BLOCK_SIZE, 
            600 / GameSettings.BLOCK_SIZE);
        
        public function GameSettings() 
        {
        }
    }
}
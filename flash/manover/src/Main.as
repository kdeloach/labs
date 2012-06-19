package 
{
    import org.flixel.FlxGame;
    
    [SWF(width = "640", height = "480", backgroundColor = "#FFFFFF")]
    public class Main extends FlxGame
    {
        public function Main()
        {
            super(640, 480, PlayState, 2, 60, 60);
        }
    }
}
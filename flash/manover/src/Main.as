package 
{
    import net.kevinx.labs.flash.manover.PlayState;
    import org.flixel.*;
    
    [SWF(width = "640", height = "480", backgroundColor = "#FFFFFF")]
    public class Main extends FlxGame
    {
        public function Main()
        {
            super(640, 480, PlayState, 2, 60, 60);
        }
    }
}
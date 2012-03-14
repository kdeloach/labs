package  
{
    import org.flixel.FlxGroup;
    import org.flixel.FlxSprite;
    import org.flixel.FlxText;
    
    public class Bubble extends FlxGroup
    {
        [Embed(source = "assets/bubble.png")] private var _bubbleBg:Class;
        
        public function Bubble(x:int, y:int, message:String) 
        {
            super();
            
            var bg:FlxSprite = new FlxSprite(x, y);
            bg.loadGraphic(_bubbleBg, false, false, 77, 74);
            add(bg);
            
            var txt:FlxText = new FlxText(x, y+20, 77, message);
            txt.alignment = "center";
            txt.color = 0;
            add(txt);
        }
    }
}
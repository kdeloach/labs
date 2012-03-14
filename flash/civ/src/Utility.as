package  
{
    import flash.text.engine.BreakOpportunity;
    import org.flixel.FlxG;
    import org.flixel.FlxPoint;
    
    public class Utility
    {
        public function Utility() 
        {
        }
        
        // snap mouse coords to nearest block
        public static function get mouse():FlxPoint
        {
            return snapPoint(FlxG.mouse.getScreenPosition());
        }
        
        // snap point to nearest block
        public static function snapPoint(pos:FlxPoint):FlxPoint
        {
            var relPos:FlxPoint = pointRelativeToMap(pos);
            return new FlxPoint(
                relPos.x * GameSettings.BLOCK_SIZE,
                relPos.y * GameSettings.BLOCK_SIZE);
        }
        
        public static function mousePositionRelativeToMap():FlxPoint
        {
            return pointRelativeToMap(FlxG.mouse.getScreenPosition());
        }
        
        public static function xyRelativeToMap(x:Number, y:Number):FlxPoint
        {
            return new FlxPoint(
                int(x / GameSettings.BLOCK_SIZE),
                int(y / GameSettings.BLOCK_SIZE));
        }
        
        public static function pointRelativeToMap(pos:FlxPoint):FlxPoint
        {
            return xyRelativeToMap(pos.x, pos.y);
        }
        
    }
}
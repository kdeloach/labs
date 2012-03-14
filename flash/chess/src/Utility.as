package  
{
    import flash.geom.Point;
    import flash.text.engine.BreakOpportunity;
    import org.flixel.FlxBasic;
    import org.flixel.FlxG;
    import org.flixel.FlxGroup;
    import org.flixel.FlxObject;
    import org.flixel.FlxParticle;
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    import pieces.*;
    
    public class Utility
    {
        public static var windowOff:Dimension = new Dimension(9, 16);
        
        public function Utility() 
        {
        }
        
        public static function mouseIntersects(x:int, y:int, width:int, height:int):Boolean
        {
            return FlxG.mouse.x >= x && FlxG.mouse.x < x + width && FlxG.mouse.y >= y && FlxG.mouse.y < y + height;
        }
        
        public static function mouseToFieldN(mouse:FlxPoint):Number
        {
            var result:Number = NaN;
            var shortestDistance:Number;
            for (var n:int = 0; n < 12 * 6; n++)
            {
                var y:int = n / 6;
                var x:int = n % 6;
                var xOff:int = y % 2 == 0 ? 0 : 70;
                // because of the irregular shape of the board, odd number rows have one less column
                if (y % 2 != 0 && x == 5) {
                    continue;
                }
                var px:int = x * 137.5 + 45 + xOff + windowOff.width;
                var py:int = y * 39.5 + 40 + windowOff.height;
                px /= 2;
                py /= 2;
                var dist:Number = Math.sqrt(Math.pow(px - mouse.x, 2) + Math.pow(py - mouse.y, 2));
                if (dist < 45 && (isNaN(shortestDistance) || dist < shortestDistance)) {
                    shortestDistance = dist;
                    result = y * 6 + x;
                }
            }
            return result;
        }

        public static function fieldNToXY(n:Number):FlxPoint
        {
            if (isNaN(n))
            {
                return null;
            }
            var y:int = n / 6;
            var x:int = n % 6;
            var xOff:int = y % 2 == 0 ? 0 : 70;
            var px:int = x * 137.5 + 45 + xOff + windowOff.width;
            var py:int = y * 39.5 + 40 + windowOff.height;
            px /= 2;
            py /= 2;
            return new FlxPoint(px, py);
        }
        
        public static function createPiece(name:String, teamColor:String):ChessPiece
        {
            switch(name)
            {
                case "Pawn":
                    return new Pawn(teamColor);
                    break;
                case "Knight":
                    return new Knight(teamColor);
                    break;
                case "Bishop":
                    return new Bishop(teamColor);
                    break;
                case "Rook":
                    return new Rook(teamColor);
                    break;
                case "Queen":
                    return new Queen(teamColor);
                    break;
            }
            return new NullPiece();
        }
    }

}
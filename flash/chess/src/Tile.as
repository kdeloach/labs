package  
{
    import flash.display.Graphics;
    import flash.display.Sprite;
    import org.flixel.FlxG;
    import org.flixel.FlxSprite;
    import org.flixel.FlxU;

    public class Tile extends FlxSprite
    {
        public function Tile() 
        {
            super();
        }
        
        public function createGraphic():void
        {
            var sides:int = 6;
            var rad:int = 50;
            var ang:Number = 360 / sides;
            var points:Array = new Array();
            var i:int = 0;
            var halfWidth:int;
            var halfHeight:int;
            var highestY:int = 0;
            var lowestY:int = 0;
            
            for (i = 0; i < sides; i++)
            {
                var theta:Number = (ang * i) * (Math.PI / 180);
                var dx:int = rad * Math.cos(theta);
                var dy:int = rad * Math.sin(theta);
                highestY = Math.max(highestY, dy);
                lowestY = Math.min(lowestY, dy);
                points.push({x: dx, y: dy});
            }
            
            this.width = rad * 2;
            this.height = Math.abs(lowestY) + Math.abs(highestY);
            
            halfWidth = rad;
            halfHeight = this.height / 2;
            
            var tile:Sprite = new Sprite();
            var g:Graphics = tile.graphics;

            g.lineStyle(2, 0x000000, 1, true);
            g.moveTo(points[0].x + halfWidth, points[0].y + halfHeight);
            for (i = 1; i < points.length; i++)
            {
                g.lineTo(points[i].x + halfWidth, points[i].y + halfHeight);
            }
            g.lineTo(points[0].x + halfWidth, points[0].y + halfHeight);
            
            this.makeGraphic(rad*2, rad*2, 0x00FFFFFF);
            this.pixels.draw(tile);
            this.dirty = true;
            this.alpha = 0.15;
        }
    }
}
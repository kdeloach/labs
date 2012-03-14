package  
{
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.text.engine.BreakOpportunity;
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    
    public class City extends FlxSprite
    {
        public var size:int = 4;
        
        private var _player:Player;
        private var _map:Map;
        // position of city last time boundaries were redrawn
        // used so we only redraw boundaries if city has moved
        private var _lastboundaryPos:FlxPoint;
        private var _randCol:uint;
        
        public function City(player:Player, map:Map) 
        {
            _player = player;
            _map = map;
            _lastboundaryPos = new FlxPoint();
            _randCol = Math.random() * 0xFF | Math.random() * 0xFF << 8 | Math.random() * 0xFF << 16;
        }
        
        public function get radius():int
        {
            return size * GameSettings.BLOCK_SIZE;
        }
        
        public function redrawBoundaries():void
        {
            // has the city moved?
            if (_lastboundaryPos.x == x && _lastboundaryPos.y == y) {
                return;
            }
            _lastboundaryPos = new FlxPoint(x, y);
            
            var pos:FlxPoint = Utility.snapPoint(new FlxPoint(x + radius, y + radius));
            var lowerBound:Point = new Point(pos.x - radius, pos.y - radius);
            var upperBound:Point = new Point(pos.x + radius, pos.y + radius);
            
            var bg:Sprite = new Sprite();
            
            for (var by:int = lowerBound.y; by < upperBound.y; by += GameSettings.BLOCK_SIZE)
            {
                for (var bx:int = lowerBound.x; bx < upperBound.x; bx += GameSettings.BLOCK_SIZE)    
                {
                    var col:uint = 0;
                    if (withinCircle(pos.x, pos.y, bx, by))
                    {
                        col = _randCol;
                    }
                    else
                    {
                        var mapPos:FlxPoint = Utility.xyRelativeToMap(bx, by);
                        if (_map.isGround(mapPos.x, mapPos.y))
                        {
                            col = 0x669966;
                        }
                        else
                        {
                            col = 0x336699;
                        }
                    }
                    bg.graphics.beginFill(col);
                    bg.graphics.drawRect(bx - x,
                                         by - y,
                                         GameSettings.BLOCK_SIZE,
                                         GameSettings.BLOCK_SIZE);
                    bg.graphics.endFill();
                }
            }

            this.makeGraphic(radius * 2, radius * 2, 0x00FFFFFF);
            this.pixels.draw(bg);
            this.dirty = true;
        }
        
        private function withinCircle(midX:int, midY:int, x:int, y:int):Boolean
        {
            var mapPos:FlxPoint = Utility.xyRelativeToMap(x, y);
            var c:int = Math.sqrt(Math.pow(midX - x, 2) + Math.pow(midY - y, 2));
            if (_map.isGround(mapPos.x, mapPos.y) && c <= radius)
            {
                return true;
            }
            return false;
        }
    }
}
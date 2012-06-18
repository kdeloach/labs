package net.kevinx.labs.flash.manover  
{
    import org.flixel.FlxPoint;
    import org.flixel.FlxRect;
    
    public class Util 
    {
        public function Util() 
        {
        }
        
        // Returns NULL if piece will not overlap with another
        // Otherwise, returns piece that already exists in target range
        public static function pieceOverlaps(pieces:Array, piece:PuzzlePiece, targetPos:FlxPoint):PuzzlePiece
        {
            var rect:FlxRect = new FlxRect(targetPos.x, targetPos.y, piece.width, piece.height);
            for each (var item:PuzzlePiece in pieces)
            {
                if (item == piece || item.shadowOf == piece)
                {
                    continue;
                }
                if (rect.overlaps(item.rect))
                {
                    return item;
                }
            }
            return null;
        }
        
        public static function piecesOverlapping(pieces:Array, rect:FlxRect):Array
        {
            var result:Array = new Array();
            for each (var item:PuzzlePiece in pieces)
            {
                if (item.pieceShadow)
                {
                    continue;
                }
                if (rect.overlaps(item.rect))
                {
                    result.push(item);
                }
            }
            return result;
        }
        
        public static function pieceAt(pieces:Array, pos:FlxPoint):PuzzlePiece
        {
            for each (var piece:PuzzlePiece in pieces)
            {
                if (piece.containsPoint(pos))
                {
                    return piece;
                }
            }
            return null;
        }
        
        public static function anyEmitting(pieces:Array):Boolean
        {
            for each(var piece:PuzzlePiece in pieces)
            {
                if (piece.emitting)
                {
                    return true;
                }
            }
            return false;
        }
        
        public static function arrayRemove(targetArr:Array, target:Object):Array
        {
            return targetArr.filter(function(item:Object, i:int, arr:Array):Boolean {
                return item != target;
            });
        }
        
        public static function arrayAddMany(targetArr:Array, items:Array, allowDuplicates:Boolean = true):void
        {
            if (!allowDuplicates)
            {
                items = items.filter(function(item:*, i:int, arr:Array):Boolean {
                    return targetArr.indexOf(item) == -1;
                });
            }
            for each (var item:* in items)
            {
                targetArr.push(item);
            }
        }
        
        public static function withinBounds(target:FlxRect, bounds:FlxRect):Boolean
        {
            return target.left >= bounds.left && target.right <= bounds.right
                && target.top >= bounds.top && target.bottom <= bounds.bottom;
        }
    }
}
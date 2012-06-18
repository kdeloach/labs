package net.kevinx.labs.flash.manover 
{
    import flash.utils.Dictionary;
    import org.flixel.FlxBasic;
    import org.flixel.FlxG;
    import org.flixel.FlxPoint;
    import org.flixel.FlxRect;
    import org.flixel.FlxU;
    
    public class PuzzleBoxFlowLayout
    {
        private var _container:PuzzleBox;
        
        public function PuzzleBoxFlowLayout(container:PuzzleBox)
        {
            _container = container;
        }
        
        public function organize():void
        {
            var field:Array = new Array();
            for (var i:int = 0; i < _container.pieces.length; i++)
            {
                var piece:PuzzlePiece = _container.pieces[i];
                if (piece.layoutDirty)
                {
                    field[ptHash(piece.point)] = piece;
                    continue;
                }
                var pos:FlxPoint = firstUnoccupiedSpace(piece, field);
                if (!pos)
                {
                    throw new Error("Unable to fit any more pieces on the playing field");
                }
                piece.x = pos.x;
                piece.y = pos.y;
                field[ptHash(pos)] = piece;
            }
        }
        
        public function firstUnoccupiedSpace(piece:PuzzlePiece, field:Array):FlxPoint
        {
            var gy:int = 0;
            var gx:int = 0;
            while (gy < _container.height)
            {
                while (gx < _container.width)
                {
                    var targetPos:FlxPoint = new FlxPoint(gx + _container.x, gy + _container.y);
                    var occupiedPiece:PuzzlePiece = Util.pieceOverlaps(field, piece, targetPos);
                    if (occupiedPiece)
                    {
                        gx += (occupiedPiece.x - gx) + occupiedPiece.width;
                        continue;
                    }
                    else if (Util.withinBounds(new FlxRect(targetPos.x, targetPos.y, piece.width, piece.height), _container.rect))
                    {
                        return targetPos;
                    }
                    break;
                }
                gy += 18;
                gx = 0;
            }
            return null;
        }
        
        public function ptHash(pt:FlxPoint):String
        {
            return pt.x + "," + pt.y;
        }
    }
}
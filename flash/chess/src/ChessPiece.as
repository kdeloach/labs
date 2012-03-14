package  
{
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    import pieces.Bishop;
    import pieces.NullPiece;
    
    public class ChessPiece extends ZFlxSprite
    {
        [Embed(source = "assets/symbols.png")] private var _pieces:Class;
        
        private var _name:String;
        private var _teamColor:String;
        private var _n:Number;
        
        public function get name():String { return _name; }
        public function get teamColor():String { return _teamColor; }
        public function get n():Number { return _n; }
        public function set n(pos:Number):void { _n = pos; }
        
        public function ChessPiece(name:String, teamColor:String) 
        {
            super();
            
            _name = name;
            _teamColor = teamColor;
            zIndex = 10;
            
            loadGraphic(_pieces, true, false, 30, 30);
            addAnimation("BlackKing", [0]);
            addAnimation("BlackQueen", [1]);
            addAnimation("BlackRook", [2]);
            addAnimation("BlackBishop", [3]);
            addAnimation("BlackKnight", [4]);
            addAnimation("BlackPawn", [5]);
            addAnimation("WhiteKing", [6]);
            addAnimation("WhiteQueen", [7]);
            addAnimation("WhiteRook", [8]);
            addAnimation("WhiteBishop", [9]);
            addAnimation("WhiteKnight", [10]);
            addAnimation("WhitePawn", [11]);
            offset = new FlxPoint(15, 15);
            play(teamColor + name);
        }
        
        public function canCapture(piece:ChessPiece):Boolean
        {
            if (piece is NullPiece)
            {
                return true;
            }
            if (piece.teamColor == teamColor)
            {
                return false;
            }
            return true;
        }
        
        public function capture(field:PlayingField, target:ChessPiece):void
        {
            
        }
        
        public function canBePickedUp(player:Player):Boolean
        {
            return teamColor == player.teamColor;
        }
    }
}
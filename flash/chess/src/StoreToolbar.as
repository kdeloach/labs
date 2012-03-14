package  
{
    import org.flixel.FlxButton;
    import org.flixel.FlxG;
    import org.flixel.FlxGroup;
    import org.flixel.FlxSprite;
    
    public class StoreToolbar extends FlxGroup
    {
        [Embed(source = "assets/store.png")] private var _storeBg:Class;
        
        private var _field:PlayingField;
        private var _bg:FlxSprite;
        
        private var _pawnBubble:FlxGroup;
        private var _knightBubble:FlxGroup;
        private var _bishopBubble:FlxGroup;
        private var _rookBubble:FlxGroup;
        private var _queenBubble:FlxGroup;
        
        public function StoreToolbar(field:PlayingField) 
        {
            super();
            
            _field = field;
            
            _bg = new FlxSprite(95, 278);
            _bg.loadGraphic(_storeBg, true, false, 98, 20);
            _bg.addAnimation("PawnHover", [0]);
            _bg.addAnimation("KnightHover", [1]);
            _bg.addAnimation("BishopHover", [2]);
            _bg.addAnimation("RookHover", [3]);
            _bg.addAnimation("QueenHover", [4]);
            _bg.addAnimation("Default", [5]);
            _bg.play("Default");
            add(_bg);
            
            _pawnBubble = new Bubble(164, 240, "COST 1");
            _pawnBubble.visible = false;
            add(_pawnBubble);
            
            _knightBubble = new Bubble(144, 240, "COST 2");
            _knightBubble.visible = false;
            add(_knightBubble);
            
            _bishopBubble = new Bubble(124, 240, "COST 4");
            _bishopBubble.visible = false;
            add(_bishopBubble);
            
            _rookBubble = new Bubble(104, 240, "COST 8");
            _rookBubble.visible = false;
            add(_rookBubble);
            
            _queenBubble = new Bubble(84, 240, "COST 16");
            _queenBubble.visible = false;
            add(_queenBubble);
        }
        
        override public function update():void 
        {
            _bg.play("Default");
            _pawnBubble.visible = false;
            _knightBubble.visible = false;
            _bishopBubble.visible = false;
            _rookBubble.visible = false;
            _queenBubble.visible = false;
            
            var player:Player = Global.instance().player;
            var teamColor:String = player.teamColor;
            
            if (teamColor != "White" && teamColor != "Black")
            {
                return;
            }
            
            var fnAddToField:Function = function(pieceName:String):Function {
                return function(n:Number):void {
                    var piece:ChessPiece = Utility.createPiece(pieceName, teamColor);
                    _field.addPiece(piece, n);
                }
            };
            
            if (FlxG.keys.justPressed("ONE"))
            {
                player.cancelDragAction();
                player.dragAction = new ChessPieceDragAction(player, "Pawn", teamColor);
                player.dragAction.successCallback = fnAddToField("Pawn");
            }    
            else if (FlxG.keys.justPressed("TWO"))
            {
                player.cancelDragAction();
                player.dragAction = new ChessPieceDragAction(player, "Knight", teamColor);
                player.dragAction.successCallback = fnAddToField("Knight");
            }    
            else if (FlxG.keys.justPressed("THREE"))
            {
                player.cancelDragAction();
                player.dragAction = new ChessPieceDragAction(player, "Bishop", teamColor);
                player.dragAction.successCallback = fnAddToField("Bishop");
            }
            else if (FlxG.keys.justPressed("FOUR"))
            {
                player.cancelDragAction();
                player.dragAction = new ChessPieceDragAction(player, "Rook", teamColor);
                player.dragAction.successCallback = fnAddToField("Rook");
            }    
            else if (FlxG.keys.justPressed("FIVE"))
            {
                player.cancelDragAction();
                player.dragAction = new ChessPieceDragAction(player, "Queen", teamColor);
                player.dragAction.successCallback = fnAddToField("Queen");
            }    
            
            if (Utility.mouseIntersects(_bg.x, _bg.y, _bg.width, _bg.height))
            {
                if (FlxG.mouse.justPressed())
                {
                    player.cancelDragAction();
                    player.dragAction = new ChessPieceDragAction(player, selectedPiece(), teamColor);
                    player.dragAction.successCallback = fnAddToField(selectedPiece());
                }
                if (FlxG.mouse.pressed())
                {
                    return;
                }
                switch(selectedPiece())
                {
                    case "Pawn":
                        _bg.play("PawnHover");
                        break;
                    case "Knight":
                        _bg.play("KnightHover");
                        break;
                    case "Bishop":
                        _bg.play("BishopHover");
                        break;
                    case "Rook":
                        _bg.play("RookHover");
                        break;
                    case "Queen":
                        _bg.play("QueenHover");
                        break;
                }
            }
        }
        
        private function selectedPiece():String
        {
            if (Utility.mouseIntersects(82 + _bg.x, _bg.y, 16, 20))
            {
                return "Pawn";
            }
            else if (Utility.mouseIntersects(61 + _bg.x, _bg.y, 21, 20))
            {
                return "Knight";
            }
            else if (Utility.mouseIntersects(40 + _bg.x, _bg.y, 21, 20))
            {
                return "Bishop";
            }
            else if (Utility.mouseIntersects(22 + _bg.x, _bg.y, 18, 20))
            {
                return "Rook";
            }
            else if (Utility.mouseIntersects(_bg.x, _bg.y, 22, 20))
            {
                return "Queen";
            }    
            return "";
        }
        
    }
}
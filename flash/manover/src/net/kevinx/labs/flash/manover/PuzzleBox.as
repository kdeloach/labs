package net.kevinx.labs.flash.manover
{
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import org.flixel.*;

    public class PuzzleBox extends FlxGroup
    {
        public var x:Number;
        public var y:Number;
        
        private var _width:Number;
        private var _height:Number;
        private var _bg:FlxSprite;
        
        public var pieces:Array = new Array();
        public var layout:PuzzleBoxFlowLayout;
        public var playerController:PlayerController;
        
        public function PuzzleBox(x:Number, y:Number, width:Number, height:Number)
        {
            super();
            this.x = x;
            this.y = y;
            _width = width;
            _height = height;
            
            playerController = new PlayerController();
            layout = new PuzzleBoxFlowLayout(this);
            
            _bg = createGridLines();
            _bg.x = x;
            _bg.y = y;
            add(_bg);
        }
        
        protected function createGridLines():FlxSprite
        {
            var bg:Sprite = new Sprite();
            bg.graphics.lineStyle(1, 0xEEEEEE);
            for (var cy:int = 0; cy < this.height; cy += Settings.GRID_HEIGHT / 2)
            {
                for (var cx:int = 0; cx < this.width; cx += Settings.GRID_WIDTH)    
                {
                    bg.graphics.drawRect(cx, cy, Settings.GRID_WIDTH, Settings.GRID_HEIGHT / 2);
                }
            }
            var result:FlxSprite = new FlxSprite();
            result.makeGraphic(width, height);
            var data:BitmapData = new BitmapData(width, height);
            data.draw(bg);
            result.pixels = data;
            return result;
        }
        
        public function bringToFront(piece:PuzzlePiece):void
        {
            members.sort(function(a:FlxBasic, b:FlxBasic):int {
                if (a === piece) {
                    return 1;
                } else if (b === piece) {
                    return -1;
                }
                return a === _bg ? -1 : b === _bg ? 1 : 0;
            });
        }
        
        override public function add(obj:FlxBasic):FlxBasic 
        {
            if (obj is PuzzlePiece)
            {
                pieces.push(obj);
                layout.organize();
                (obj as PuzzlePiece).layoutDirty = true;
                updateNeighbors();
            }
            return super.add(obj);
        }
        
        override public function remove(obj:FlxBasic, splice:Boolean = false):FlxBasic 
        {
            if (obj is PuzzlePiece)
            {
                pieces = Util.arrayRemove(pieces, obj);
                layout.organize();
                updateNeighbors();
            }
            return super.remove(obj, splice);
        }
        
        override public function preUpdate():void 
        {
            // The only emitters that should be active are "natural emitters"
            // Ex. user input and blocks with custom logic (PULSE, NOT, ALWAYS, etc.)
            // Other emitters should have been disabled during PuzzlePiece.postUpdate()
            var emitters:Array = pieces.filter(function(item:PuzzlePiece, i:int, arr:Array):Boolean {
                return item.emitting;
            });
            // Cascade the emitting action to other blocks using breadth-first traversal
            var queue:Array = new Array();
            Util.arrayAddMany(queue, emitters, false);
            var i:int = 0;
            while (i < queue.length)
            {
                var piece:PuzzlePiece = queue[i];
                piece.emitting = true;
                // Some blocks can not be triggered manually
                if (piece.emitting)
                {
                    Util.arrayAddMany(queue, piece.neighbors, false);
                }
                i++;
            }
            super.preUpdate();
        }
        
        override public function update():void 
        {
            if (FlxG.mouse.justPressed())
            {
                var piece:PuzzlePiece = Util.pieceAt(pieces, FlxG.mouse.getScreenPosition());
                if (piece)
                {
                    add(new PuzzlePieceDragAction(this, piece));
                }
            }
            
            for each(var item:PuzzlePiece in pieces)
            {
                item.updateController(playerController);
            }
            
            super.update();
        }
        
        public function get width():Number
        {
            return _width;
        }
        
        public function get height():Number
        {
            return _height;
        }
        
        public function get rect():FlxRect
        {
            return new FlxRect(x, y, width, height);
        }
        
        public function updateNeighbors():void
        {
            for each(var piece:PuzzlePiece in pieces)
            {
                var border1:FlxRect = new FlxRect(piece.x - 1, piece.y, piece.width + 2, piece.height);
                var border2:FlxRect = new FlxRect(piece.x, piece.y - 1, piece.width, piece.height + 2);
                var neighbors:Array = new Array();
                Util.arrayAddMany(neighbors, Util.piecesOverlapping(pieces, border1));
                Util.arrayAddMany(neighbors, Util.piecesOverlapping(pieces, border2));
                neighbors = Util.arrayRemove(neighbors, piece);
                piece.neighbors = neighbors;
            }
        }
    }
}
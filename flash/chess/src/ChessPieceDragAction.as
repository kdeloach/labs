package  
{
    import flash.events.SecurityErrorEvent;
    import org.flixel.FlxG;
    import org.flixel.FlxGroup;
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    
    public class ChessPieceDragAction extends FlxGroup implements IZIndex
    {
        private var _player:Player;
        private var _sprite:ChessPiece;
        private var _mouseActive:Boolean;
        
        private var _errorCallback:Function;
        public function get errorCallback():Function { return _errorCallback; }
        public function set errorCallback(fn:Function):void { _errorCallback = fn; }
        
        private var _successCallback:Function;
        public function get successCallback():Function { return _successCallback; }
        public function set successCallback(fn:Function):void { _successCallback = fn; }
        
        public function get zIndex():int { return 20; }
        
        public function ChessPieceDragAction(player:Player, pieceName:String, pieceColor:String) 
        {
            super();
            
            _player = player;
            _mouseActive = true;
            
            _sprite = new ChessPiece(pieceName, pieceColor);
            _sprite.x = FlxG.mouse.x;
            _sprite.y = FlxG.mouse.y;
            add(_sprite);
        }
        
        override public function update():void 
        {
            if (!alive)
            {
                return;
            }
            var n:Number = Utility.mouseToFieldN(FlxG.mouse.getScreenPosition());
            if (FlxG.mouse.justReleased() || FlxG.mouse.justPressed())
            {
                _mouseActive = false;
            }
            if (!_mouseActive)
            {
                if (!isNaN(n))
                {
                    if (successCallback != null)
                    {
                        successCallback(n);
                    }
                }
                else
                {
                    if (errorCallback != null)
                    {
                        errorCallback();
                    }
                }
                kill();
                return;
            }
            _sprite.x = FlxG.mouse.x;
            _sprite.y = FlxG.mouse.y;
        }
        
        override public function kill():void 
        {
            _player.dragAction = null;
            super.kill();
        }
        
        public function cancel():void
        {
            if (errorCallback != null)
            {
                errorCallback();
            }
            kill();
        }
    }
}
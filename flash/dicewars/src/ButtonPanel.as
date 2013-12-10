package
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;

    public class ButtonPanel extends Sprite
    {
        private var _targetWidth:Number;
        private var _targetHeight:Number;

        public function ButtonPanel(width:Number, height:Number)
        {
            _targetWidth = width;
            _targetHeight = height;
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        private function onAddedToStage(e:Event):void
        {
        }

        override public function addChild(child:DisplayObject):DisplayObject
        {
            var buttonPaddingLeft:Number = 5;
            child.y = 0;
            child.x = _targetWidth - child.width;
            for (var i:int = 0; i < numChildren; i++) {
                child.x -= buttonPaddingLeft + getChildAt(i).width;
            }
            return super.addChild(child);
        }
    }
}

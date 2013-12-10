package net.kevinx.labs.flash.dicewars 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class Button extends Sprite
	{
		private var _txtField:TextField;
		private var _pill:Sprite;
		
		private var _pillWidth:int;
		
		public function Button(text:String, width:int)
		{
			_pillWidth = width;
			
			buttonMode = true;
			useHandCursor = true;

			_pill = new Sprite();
			onMouseOut(null);
			addChild(_pill);
			
			_txtField = new TextField();
			_txtField.embedFonts = true;
			_txtField.defaultTextFormat = new TextFormat("nokia", 18, 0);
			_txtField.autoSize = TextFieldAutoSize.LEFT;
			_txtField.mouseEnabled = false;
			_txtField.text = text;
			addChild(_txtField);
			
			_txtField.x = (_pillWidth - _txtField.textWidth) / 2;
			_txtField.y = 5;
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			_pill.graphics.lineStyle(2, 0x555555);
			_pill.graphics.beginFill(0xCCCCCC);
			_pill.graphics.drawRoundRect(0, 0, _pillWidth, 36, 10);
			_pill.graphics.endFill();
		}
		
		private function onMouseOut(e:MouseEvent):void
		{
			_pill.graphics.lineStyle(2, 0x555555);
			_pill.graphics.beginFill(0xEEEEEE);
			_pill.graphics.drawRoundRect(0, 0, _pillWidth, 36, 10);
			_pill.graphics.endFill();
		}
	}
}


package net.kevinx.labs.flash.manover
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontMetrics;
	import flash.text.TextField;
	import flash.text.TextLineMetrics;
	import org.flixel.*;

	public class PuzzlePiece extends FlxGroup
	{
		private var _fontsize:int = 8;
		private var _textwidth:Number;
		
		private var _text:FlxText;
		private var _bg:FlxSprite;
		
		private var _lastState:int = 0;
		public var pieceActive:Boolean = false;
		public var pieceHover:Boolean = false;
		public var pieceOverlap:Boolean = false;
		public var pieceShadow:Boolean = false;
		
		public var shadowOf:PuzzlePiece = null;
		
		// Marked TRUE when piece has been moved by user
		public var layoutDirty:Boolean = false;
		
		// Surrounding pieces
		public var neighbors:Array = new Array();
		
		private var _emitting:Boolean = false;
		
		public function PuzzlePiece(text:String = "", textwidth:int = 1)
		{
			super();
			
			_textwidth = textwidth;
			
			_text = new FlxText(0, 0, width, text);
			_text.color = 0xFFFFFF;
			_text.size = _fontsize;
			_text.alignment = "center";
			
			_bg = new FlxSprite();
			_bg.pixels = renderBackground();
			
			add(_bg);
			
			this.x = 0;
			this.y = 0;
		}
		
		protected function renderBackground():BitmapData
		{
			var bg:Sprite = new Sprite();
			var g:Graphics = bg.graphics;
			g.beginFill(pieceShadow ? 0xEEEEEE : pieceHover || pieceActive ? 0xF7803C : 0xF54828);
			g.drawRoundRect(0, 0, width, height, 5);
			g.endFill();
			
			g.beginBitmapFill(_text.pixels, null, false);
			g.drawRect(0, 0, width, height);
			g.endFill();
			
			if (pieceOverlap)
			{
				g.lineStyle(1, 0xFF0000);
				g.moveTo(0, 0);
				g.lineTo(width, height);
				g.moveTo(0, height);
				g.lineTo(width, 0);
			}
			var result:FlxSprite = new FlxSprite();
			var bmp:BitmapData = new BitmapData(width, height);
			bmp.draw(bg);
			return bmp;
		}
		
		override public function update():void 
		{
			pieceActive = !pieceShadow && emitting;
			pieceHover = containsPoint(FlxG.mouse.getScreenPosition()); 
			if (state != _lastState)
			{
				_bg.pixels = renderBackground();
				_lastState = state;
			}
			super.update();
		}
		
		public function updateController(controller:PlayerController):void
		{
		}
		
		override public function postUpdate():void 
		{
			super.postUpdate();
			emitting = false;
		}
		
		public function get emitting():Boolean
		{
			return _emitting;
		}
		
		public function set emitting(val:Boolean):void 
		{
			_emitting = val;
		}
		
		public function get x():Number
		{
			return _bg.x;
		}
		
		public function set x(n:Number):void
		{
			_bg.x = n;
		}
		
		public function get y():Number
		{
			return _bg.y;
		}
		
		public function set y(n:Number):void
		{
			_bg.y = n;
		}
		
		public function get width():Number
		{
			return _textwidth * Settings.GRID_WIDTH;
		}
		
		public function get height():Number
		{
			return Settings.GRID_HEIGHT;
		}
		
		public function get rect():FlxRect
		{
			return new FlxRect(x, y, width, height);
		}
		
		public function get point():FlxPoint
		{
			return new FlxPoint(x, y);
		}
		
		public function get state():int
		{
			return int(pieceActive) 
				| int(pieceHover) << 1 
				| int(pieceOverlap) << 2
				| int(pieceShadow) << 3;
		}
		
		public function containsPoint(pos:FlxPoint):Boolean
		{
			return Util.withinBounds(new FlxRect(pos.x, pos.y), rect);
		}
		
		public function clone():PuzzlePiece
		{
			var result:PuzzlePiece = new PuzzlePiece(_text.text, _textwidth);
			result.x = x;
			result.y = y;
			result.shadowOf = this;
			result.layoutDirty = layoutDirty;
			result.pieceHover = pieceHover;
			result.pieceOverlap = pieceOverlap;
			result.pieceShadow = pieceShadow;
			return result;
		}
		
		override public function toString():String 
		{
			return "<PuzzlePiece '" + _text.text + "'>"
		}
	}
}

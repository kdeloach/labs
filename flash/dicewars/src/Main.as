package 
{
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	
	[SWF(width="800", height="600")]
	public class Main extends Sprite
	{		
		private var _game:Gameplay;
		
		public function Main():void
		{
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.quality = StageQuality.BEST;
			Globals.stage = stage;
			newGame();
		}
		
		private function newGame():void 
		{
			trace("New Game");
			
			_game = new Gameplay();
			Globals.game = _game;
			addChild(_game);
			
			_game.start(onGameReady);
		}
		
		private function onGameReady():void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			// TODO: Cancel currently executing promises & animations.
			removeChild(_game);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			newGame();
		}
	}
}
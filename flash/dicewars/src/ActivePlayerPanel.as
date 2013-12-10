package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class ActivePlayerPanel extends Sprite
	{
		private var _targetWidth:Number;
		private var _targetHeight:Number;
		private var _players:Vector.<AbstractPlayer>;
		
		private var _rects:Vector.<Sprite>;
		private var _activeRect:Sprite;
		
		public function ActivePlayerPanel(width:Number, height:Number, players:Vector.<AbstractPlayer>) 
		{
			_targetWidth = width;
			_targetHeight = height;
			_players = players;
			_rects = new Vector.<Sprite>();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void
		{
			_activeRect = new Sprite();
			addChild(_activeRect);
			
			for (var i:int = 0; i < _players.length; i++) {
				var player:AbstractPlayer = _players[i];
				player.addEventListener("move", fillActiveRect);
			}
			
			buildPlayerRects();
		}
		
		private function buildPlayerRects(e:PlayerEvent=null):void
		{			
			var rectWidth:Number = _targetWidth / _players.length;
			var rectHeight:Number = _targetHeight / 2;
			
			for (var j:int = 0; j < _rects.length; j++) {
				removeChild(_rects[j]);
			}
			_rects = new Vector.<Sprite>;
			
			for (var i:int = 0; i < _players.length; i++) {
				var player:AbstractPlayer = _players[i];
				var rect:Sprite = new Sprite();
				rect.graphics.beginFill(player.color);
				rect.graphics.drawRect(0, 0, rectWidth, rectHeight);
				rect.graphics.endFill();
				rect.x = rectWidth * i;
				rect.y = _targetHeight - rectHeight;
				_rects.push(rect);
				addChild(rect);
			}
		}
		
		private function fillActiveRect(e:PlayerEvent):void
		{
			// Check if any players were eliminated during the previous turn.
			var alivePlayers:Vector.<AbstractPlayer> = _players.filter(function(player:AbstractPlayer, index:int, lst:Vector.<AbstractPlayer>):Boolean {
				return Globals.map.getPlayerTerritories(player.id).length > 0;
			});
			if (alivePlayers.length != _players.length) {
				_players = alivePlayers;
				buildPlayerRects();
			}

			_activeRect.graphics.beginFill(e.player.color);
			_activeRect.graphics.drawRect(0, 0, _targetWidth, _targetHeight);
			_activeRect.graphics.endFill();
		}
	}
}
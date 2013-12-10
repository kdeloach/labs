package net.kevinx.labs.flash.dicewars 
{
	import com.codecatalyst.promise.Deferred;
	import com.codecatalyst.promise.Promise;
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	
	public class Gameplay extends Sprite
	{
		private var _map:Map;
		private var _mapGen:TerritoryGen;
		private var _players:Vector.<AbstractPlayer>;
		private var _playerPanel:ActivePlayerPanel;
		private var _buttonsPanel:ButtonPanel;
		
		public const BOT_DELAY_MS:Number = 150;
		public const INITIAL_ARMYSIZE:Number = 2;
		public const NUM_TERRITORIES:int = 24;
		public const NUM_WATERS:int = 12;
		
		public function Gameplay() 
		{
		}
		
		public function start(onGameReady:Function):void 
		{
			if (_map) removeChild(_map);
		
			var buttonsMargin:Margin = new Margin(10, 10, 10, 10);
			var mapMargin:Margin = new Margin(0, 10, 0, 10);
			var panelMargin:Margin = new Margin(10, 10, 10, 10);
						
			var buttonsWidth:Number = stage.stageWidth - buttonsMargin.left - buttonsMargin.right;
			var buttonsHeight:Number = 36;
			var panelWidth:Number = stage.stageWidth - panelMargin.left - panelMargin.right;
			var panelHeight:Number = 18;
			var mapWidth:Number = stage.stageWidth - mapMargin.left - mapMargin.right;
			var mapHeight:Number = stage.stageHeight - mapMargin.top - mapMargin.bottom 
				- panelMargin.top - panelMargin.bottom - panelHeight
				- buttonsMargin.top - buttonsMargin.bottom - buttonsHeight;
			
			_map = new Map(mapWidth, mapHeight);
			_map.x = mapMargin.left;
			_map.y = buttonsHeight + buttonsMargin.top + mapMargin.top;
			Globals.map = _map;
			
			_mapGen = new TerritoryGen(_map);
			
			var playerID:int = 0;
			_players = new Vector.<AbstractPlayer>();
			_players.push(new BotPlayer(playerID++, "Light Blue", getPlayerColor(1)));
			_players.push(new BotPlayer(playerID++, "Dark Blue", getPlayerColor(2)));
			_players.push(new BotPlayer(playerID++, "Purple", getPlayerColor(3)));
			_players.push(new HumanPlayer(playerID++, "Teal (Human)", getPlayerColor(0)));
			_players.push(new BotPlayer(playerID++, "Magenta", getPlayerColor(4)));
			_players.push(new BotPlayer(playerID++, "Pink", getPlayerColor(5)));
			
			_map.build()
				.then(_mapGen.gen)
				.then(function():void {
					_playerPanel = new ActivePlayerPanel(panelWidth, panelHeight, _players);
					_playerPanel.x = panelMargin.left;
					_playerPanel.y = buttonsMargin.top + buttonsMargin.bottom + buttonsHeight 
						+ mapMargin.top + mapMargin.bottom + mapHeight 
						+ panelMargin.top;
					addChild(_playerPanel);
					
					_buttonsPanel = new ButtonPanel(buttonsWidth, buttonsHeight);
					_buttonsPanel.x = buttonsMargin.left;
					_buttonsPanel.y = buttonsMargin.top;
					addChild(_buttonsPanel);
				})
				.then(onGameReady)
				.then(turn)
				.then(gameOver);
			
			addChild(_map);
		}
		
		private function getPlayerColor(playerID:int):uint
		{
			switch (playerID) {
				case 0: return 0x6DC8BF;
				case 1: return 0xAED137;
				case 2: return 0xFDB813;
				case 3: return 0xF15A23;
				case 4: return 0xB72468;
				case 5: return 0x534FA3;
				case 6: return 0x0076B3;
			}
			throw new Error("Undefined player color");
		}
		
		private function highlightNeighbors(map:Map, slot:Slot, highlighted:Boolean):void
		{
			var neighbors:Vector.<Slot> = slot.owner.neighborSlots;
			//var neighbors:Vector.<Slot> = map.getNeighbors(slot).concat(map.getNeighbors2(slot));
			for (var i:int = 0; i < neighbors.length; i++) {
				neighbors[i].highlighted = highlighted;
			}
		}
		
		private function turn(playerID:int = 0):Promise
		{
			if (isGameOver()) {
				return Promise.when(null);
			}
			
			var startOver:Function = Util.partial(turn, 0);
			var nextTurn:Function = Util.partial(turn, playerID + 1);
			
			if (playerID == numberOfPlayers()) {
				return buffArmies().then(startOver);
			}
			
			var player:AbstractPlayer = getPlayer(playerID);
			if (!_map.playerCanMove(playerID)) {
				trace("Skipping player", playerID, "(no moves left)");
				return nextTurn();
			}
			
			var deferred:Deferred = new Deferred();
			setTimeout(function():void {
				player.move()
					.then(nextTurn)
					.then(deferred.resolve);
			}, 0);
			return deferred.promise;
		}
		
		private function buffArmies():Promise
		{
			trace("Buffing armies...");
			
			for (var i:int = 0; i < numberOfPlayers(); i++) {
				var player:AbstractPlayer = getPlayer(i);
				var lands:Vector.<Territory> = _map.getPlayerTerritories(player.id);
				
				trace("Player", player.name, "has", lands.length, "lands");
				player.pool += lands.length;
				
				while (player.pool > 0) {
					if (lands.length == 0) break;
					Util.shuffleVector(lands as Vector.<*>);
					for (var j:int = 0; j < lands.length; j++) {
						if (player.pool == 0) break;
						var land:Territory = lands[j];
						if (land.armySize == land.armyLimit) {
							lands.splice(j, 1);
							continue;
						}
						var n:int = Math.min(land.armyLimit - land.armySize, Math.floor(Math.random() * player.pool) + 1);
						land.armySize += n;
						player.pool -= n;
					}
				}
			}
			
			return Promise.when(null);
		}
		
		// True if all territories are owned by the same player.
		public function isGameOver():Boolean
		{
			var lands:Vector.<Territory> = _map.territories.filter(isPlayerOwned);
			var playerID:int = lands[0].playerID;
			for (var i:int = 1; i < lands.length; i++) {
				if (lands[i].playerID != playerID) {
					return false;
				}
			}
			return true;
		}
		
		public function isPlayerOwned(item:Territory, index:int, arr:Vector.<Territory>):Boolean
		{
			return item.playerID > -1;
		}
		
		private function gameOver():Promise
		{
			trace("GAME OVER");
			return Promise.when(null);
		}
		
		public function getPlayer(playerID:int):AbstractPlayer
		{
			return _players[playerID];
		}
		
		public function numberOfPlayers():int
		{
			return _players.length;
		}
	}
}
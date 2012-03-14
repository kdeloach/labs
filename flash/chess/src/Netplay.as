package  
{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Timer;
	import org.flixel.FlxG;
	import org.flixel.FlxU;
	import com.adobe.serialization.json.*;
	
	public class Netplay 
	{
		private var _changes:Array;
		private var _processChangesCallback:Function;
		private var _lastUpdate:String;
		
		public function Netplay() 
		{
			_changes = new Array();
		}
		
		public function startTracking(processChangesCallback:Function):void
		{
			_processChangesCallback = processChangesCallback;
			var timer:Timer = new Timer(300);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			timer.start();
		}
		
		public function getPlayers(callback:Function):void
		{
			var message:Object = { type:"GetPlayers" };
			var request:URLRequest = createRequest(message);
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				var obj:Object;
				try
				{
					var decoder:JSONDecoder = new JSONDecoder(e.target.data, false);	
					obj = decoder.getValue();
				}
				catch(ex:Error) {}
				callback(obj, e.target.data);
			});
			loader.load(request);
		}
		
		public function setPlayers(data:Object, callback:Function = null):void
		{
			var message:Object = { type:"SetPlayers", data: data };
			var request:URLRequest = createRequest(message);
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			if (callback != null)
			{
				loader.addEventListener(Event.COMPLETE, function(e:Event):void {
					var obj:Object;
					try
					{
						var decoder:JSONDecoder = new JSONDecoder(e.target.data, false);	
						obj = decoder.getValue();
					}
					catch(ex:Error) {}
					callback(obj, e.target.data);
				});
			}
			loader.load(request);
		}
		
		public function newGame(callback:Function):void
		{
			var message:Object = { type:"NewGame" };
			var request:URLRequest = createRequest(message);
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				callback();
			});
			loader.load(request);
		}
		
		public function getPlayingField(callback:Function):void 
		{
			var message:Object = { type:"GetPlayingField" };
			var request:URLRequest = createRequest(message);
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				var obj:Object;
				try
				{
					var decoder:JSONDecoder = new JSONDecoder(e.target.data, false);	
					obj = decoder.getValue();
				}
				catch(ex:Error) {}
				callback(obj, e.target.data);
			});
			loader.load(request);
		}
		
		protected function update():void
		{
			var ts:String = new Date().toUTCString();
			var player:Player = Global.instance().player;
			var message:Object = { type: "Update", changes: _changes, ts: ts, prevts: _lastUpdate, TeamColor: player.teamColor };
			var request:URLRequest = createRequest(message);
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				var obj:Object;
				try
				{
					var decoder:JSONDecoder = new JSONDecoder(e.target.data, false);	
					obj = decoder.getValue();
				}
				catch(ex:Error) {}
				_processChangesCallback(obj, e.target.data);
				_lastUpdate = ts;
			});
			loader.load(request);
			_changes = new Array();
		}
		
		protected function createRequest(data:Object):URLRequest
		{
			var requestVars:URLVariables = new URLVariables();
			var json:JSONEncoder = new JSONEncoder(data)
			requestVars.req = json.getString();

			var request:URLRequest = new URLRequest();
			request.url = "http://kevinx.net/labs/flash/chess/server/api.php";
			request.method = URLRequestMethod.GET;
			request.data = requestVars;
			
			return request;
		}
		
		public function timerHandler(evt:TimerEvent):void
		{
			update();
		}
		
		public function removePiece(n:Number):void
		{
			_changes.push( { n: n } );
		}
		
		public function addPiece(pieceName:String, teamColor:String, n:Number):void
		{
			_changes.push( { PieceName: pieceName, TeamColor: teamColor, n: n } );
		}
	}
}
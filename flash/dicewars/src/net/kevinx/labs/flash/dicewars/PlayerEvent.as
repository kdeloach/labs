package net.kevinx.labs.flash.dicewars 
{
	import flash.events.Event;
	
	public class PlayerEvent extends Event
	{
		public var player:AbstractPlayer;
		
		public function PlayerEvent(type:String, player:AbstractPlayer) 
		{
			super(type);
			this.player = player;
		}
	}
}
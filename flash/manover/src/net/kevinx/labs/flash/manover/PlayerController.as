package net.kevinx.labs.flash.manover 
{
	public class PlayerController 
	{
		public var jump:Boolean = false;
		public var justPressedJump:Boolean = false;
		public var justReleasedJump:Boolean = false;
		
		public var moveLeft:Boolean = false;
		public var justPressedMoveLeft:Boolean = false;
		public var justReleasedMoveLeft:Boolean = false;
		
		public var moveRight:Boolean = false;
		public var justPressedMoveRight:Boolean = false;
		public var justReleasedMoveRight:Boolean = false;
		
		public var attack:Boolean = false;
		
		public function PlayerController() 
		{
		}
	}
}
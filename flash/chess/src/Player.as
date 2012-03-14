package  
{
	public class Player
	{
		public var teamColor:String;
		
		private var _dragAction:ChessPieceDragAction = null;
		public function get dragAction():ChessPieceDragAction { return _dragAction; };
		public function set dragAction(action:ChessPieceDragAction):void { _dragAction = action; };
		
		public function Player(teamColor:String) 
		{
			this.teamColor = teamColor;
		}
		
		public function cancelDragAction():void
		{
			if (_dragAction != null)
			{
				_dragAction.cancel();
			}
		}
	}
}
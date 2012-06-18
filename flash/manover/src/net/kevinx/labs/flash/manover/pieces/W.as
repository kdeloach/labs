package net.kevinx.labs.flash.manover.pieces 
{
	import net.kevinx.labs.flash.manover.PuzzlePiece;
	import org.flixel.FlxG;
	
	public class W extends PuzzlePiece 
	{
		public function W() 
		{
			super("W", 2);
		}
		
		override public function get emitting():Boolean 
		{
			return FlxG.keys.W;
		}
		
		override public function set emitting(val:Boolean):void 
		{
		}
	}
}

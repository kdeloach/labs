package  
{
	// Describes which color to use for each part of the map based on height
	// Heights are a percentage from 0 - 1
	// Map tiles will use this color if tile height is less than or equal to this height
	// Examples:
	//   height=0.5, color=0xFF0000 would make half of the map red
	//   height=0.1, color=0x0000FF would make 10% of the map green
	public class HeightColor
	{
		// height value as percentage
		// value ranges 0 to 1
		public var height:Number;
		public var color:uint;
		public var type:uint;
		
		public function HeightColor(height:Number, color:uint, type:uint) 
		{
			this.height = height;
			this.color = color;
			this.type = type;
		}
	}
}
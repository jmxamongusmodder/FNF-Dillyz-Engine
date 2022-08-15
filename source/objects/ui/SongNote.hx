package objects.ui;

import gamestates.PlayState;

using DillyzUtil;

class SongNote extends FunkySprite
{
	public static var noteWidth:Float = 160;
	public static var noteScaling:Float = 0.7;
	public static var noteDirections:Array<String> = ['Left', 'Down', 'Up', 'Right'];

	public static function resetVariables()
	{
		switch (PlayState.keyCount)
		{
			case 4:
				noteWidth = 160;
				noteScaling = 0.7;
				noteDirections.wipeArray();
				noteDirections.push('Left');
				noteDirections.push('Down');
				noteDirections.push('Up');
				noteDirections.push('Right');
		}
	}
}

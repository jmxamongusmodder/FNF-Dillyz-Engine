package managers;

import DillyzLogger.LogType;
import flixel.FlxG;

class PreferenceManager
{
	// keybinds
	public static var keybinds_4k:Array<String> = ['Left', 'Down', 'Up', 'Right'];

	// visuals
	public static var antialiasing:Bool = true;

	public static var middleScroll:Bool = false;

	public static function save()
	{
		FlxG.save.data.keybinds_4k = keybinds_4k;
		FlxG.save.data.antialiasing = antialiasing;
		FlxG.save.data.middleScroll = middleScroll;
		DillyzLogger.log('Saved preferences to disk!', LogType.Normal);
		FlxG.save.data.hasSaved = true;
	}

	public static function load()
	{
		if (FlxG.save.data == null || FlxG.save.data.hasSaved == null || FlxG.save.data.hasSaved == false)
		{
			DillyzLogger.log('Failed to load preferences from disk!', LogType.Warning);
			return;
		}
		keybinds_4k = FlxG.save.data.keybinds_4k;
		antialiasing = FlxG.save.data.antialiasing;
		middleScroll = FlxG.save.data.middleScroll;
		DillyzLogger.log('Loading preferences from disk!', LogType.Normal);
	}
}

package gamestates;

import flixel.FlxG;
import managers.BGMusicManager;

class TitleScreenState extends MusicBeatState
{
	override public function create()
	{
		super.create();
		if (FlxG.save.data.lastMod != null)
			Paths.curMod = FlxG.save.data.lastMod;
		BGMusicManager.play('freakyMenu', 102);
	}
}

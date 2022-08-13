package managers;

import flixel.FlxG;
import rhythm.Conductor;

class BGMusicManager
{
	public static var bgMusicName:String = 'nothing';
	public static var bpm:Int = 100;
	public static var soundMemCleared:Bool = false;

	public static function play(musicName:String, bpm:Int, ?force:Bool = false)
	{
		if (bgMusicName != musicName || force || soundMemCleared)
		{
			bgMusicName = musicName;
			BGMusicManager.bpm = bpm;
			restart();
			soundMemCleared = false;
		}
	}

	public static function pause()
	{
		FlxG.sound.music.pause();
	}

	public static function stop()
	{
		FlxG.sound.music.stop();
	}

	public static function restart()
	{
		FlxG.sound.playMusic(Paths.music(bgMusicName), 1.05, true);
		Conductor.changeBPM(bpm);
	}
}

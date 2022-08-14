package managers;

import flixel.FlxG;
import rhythm.Conductor;

class BGMusicManager
{
	public static var bgMusicName:String = 'nothing';
	public static var bpm:Int = 100;
	public static var soundMemCleared:Bool = false;

	public static var thingStillPlaying:Bool = false;

	public static function play(musicName:String, bpm:Int, ?force:Bool = false)
	{
		if (bgMusicName != musicName || force || soundMemCleared || !thingStillPlaying)
		{
			bgMusicName = musicName;
			BGMusicManager.bpm = bpm;
			restart();
			soundMemCleared = false;
		}
	}

	public static function resume()
	{
		FlxG.sound.music.resume();
		thingStillPlaying = true;
	}

	public static function pause()
	{
		FlxG.sound.music.pause();
		thingStillPlaying = false;
	}

	public static function stop()
	{
		FlxG.sound.music.stop();
		thingStillPlaying = false;
	}

	public static function restart()
	{
		FlxG.sound.playMusic(Paths.music(bgMusicName), 1.05, true);
		Conductor.changeBPM(bpm);
	}
}

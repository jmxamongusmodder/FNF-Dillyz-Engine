package managers;

import flixel.FlxG;
import rhythm.Conductor;

class BGMusicManager
{
	public static var bgMusicName:String = 'freakyMenu';
	public static var bpm:Int = 102;

	public static function play(musicName:String, bpm:Int)
	{
		bgMusicName = musicName;
		BGMusicManager.bpm = bpm;
		restart();
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
		FlxG.sound.playMusic(Paths.music(bgMusicName), true);
		Conductor.changeBPM(bpm);
	}
}

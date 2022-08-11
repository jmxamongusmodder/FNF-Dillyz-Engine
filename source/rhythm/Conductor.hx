package rhythm;

import rhythm.Song.SongData;

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Int;
}

// mostly pasted from https://github.com/ninjamuffin99/Funkin/blob/master/source/Conductor.hx
class Conductor
{
	public static var bpm:Int = 100;
	public static var crochet:Float = ((60 / bpm) * 1000);
	public static var stepCrochet:Float = crochet / 4;
	public static var songPosition:Float;
	// public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000;

	public static var bpmChanges:Array<BPMChangeEvent> = [];

	public static function mapBPMChanges(song:SongData)
	{
		clearBPMChanges();

		var curBPM:Int = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChanges.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
	}

	public static function clearBPMChanges()
	{
		var dirtBPMChanges:Array<BPMChangeEvent> = [];
		for (i in bpmChanges)
			dirtBPMChanges.push(i);
		for (i in dirtBPMChanges)
			bpmChanges.remove(i);
		// untyped bpmChanges.length = 0;
	}

	public static function changeBPM(bpm:Int)
	{
		Conductor.bpm = bpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}

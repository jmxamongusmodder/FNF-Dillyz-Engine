package rhythm;

import rhythm.Section.SectionData;
import rhythm.Section;

using DillyzUtil;
using StringTools;

typedef SongData =
{
	// FNF BASE GAME STUFF
	var song:String;
	var notes:Array<SectionData>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;
	var player1:String;
	var player2:String;

	// var validScore:Bool;
	// DILLYZ ENGINE STUFF
	var girlfriend:Null<String>;
	var stage:Null<String>;
	// IF YOU ARE MAKING AN ENGINE, THEN I ENCOURAGE MAKING THIS VARIABLE AND SETTING IT TO YOUR ENGINE NAME!
	// WE COULD ALLOW FOR CROSS ENGINE COMPATIBILITY!!!!!
	// (if you make an engine & you'd want your charts to be compatible here, just contact me. server: https://discord.gg/49NFTwcYgZ)
	var engineType:Null<String>;
	var countdownSuffix:Null<String>;
}

class Song
{
	public var songName:String;
	public var notes:Array<SectionData>;
	public var bpm:Int;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var boyfriend:String = 'bf';
	public var dad:String = 'dad';
	public var girlfriendYouDontHave:String = 'gf';

	public var stage:String = 'stage';

	public var countdownSuffix:String;

	public function new(songName:String, notes:Array<SectionData>, bpm:Int, needsVoices:Bool, speed:Float, boyfriend:String, dad:String,
			girlfriendYouDontHave:String, stage:String, countdownSuffix:String)
	{
		this.songName = songName;
		this.notes = notes;
		this.bpm = bpm;
		this.needsVoices = needsVoices;
		this.speed = speed;
		this.boyfriend = boyfriend;
		this.dad = dad;
		this.girlfriendYouDontHave = (girlfriendYouDontHave == null || girlfriendYouDontHave == '') ? 'girlfriend' : girlfriendYouDontHave;
		this.stage = (stage == null || stage == '') ? 'stage' : stage;
		this.countdownSuffix = countdownSuffix;
	}

	public static var defSong:SongData = {
		song: 'Tutorial',
		notes: [],
		bpm: 100,
		needsVoices: false,
		speed: 1,
		player1: 'boyfriend',
		player2: 'daddy dearest',
		// validScore: true,
		// DILLYZ ENGINE STUFF
		girlfriend: 'girlfriend',
		stage: 'stage',
		countdownSuffix: '',
		// feel free to use this variable in your engine
		engineType: 'Dillyz Engine'
	};

	public static function songFromName(songName:String, difficulty:String):Song
	{
		var songData:SongData = songDataFromName(songName, difficulty);
		return new Song(songData.song, songData.notes, songData.bpm, songData.needsVoices, songData.speed, songData.player1, songData.player2,
			songData.girlfriend, songData.stage, songData.countdownSuffix);
	}

	public static function oldCharToDillyz(oldChar:String)
	{
		switch (oldChar)
		{
			case 'bf':
				oldChar = 'boyfriend';
			case 'dad':
				oldChar = 'daddy dearest';
			case 'spooky':
				oldChar = 'spooky kids';
			default:
				if (oldChar.startsWith('bf-'))
					oldChar = oldChar.replace('bf-', 'boyfriend-');
		}

		return oldChar;
	}

	public static function songDataFromName(songName:String, difficulty:String):SongData
	{
		var newData:SongData;
		var dataUntouched:Dynamic = Paths.json('songs/${songName.toLowerCase().replace(' ', '-')}/${songName.toLowerCase().replace(' ', '-')}-${difficulty.toLowerCase().replace(' ', '-')}',
			null, defSong);

		if (dataUntouched.song != null && !Std.isOfType(dataUntouched.song, String))
		{
			trace('base game song');
			newData = dataUntouched.song;
		}
		else
		{
			trace('possibly dillyz engine song');
			newData = dataUntouched;
		}

		// just assume it's base game
		// maybe i'll add engine checks in the future
		if (newData.engineType == null || newData.engineType == '')
		{
			// just write the engine name
			newData.engineType = 'Dillyz Engine';
			newData.girlfriend == 'girlfriend';
			newData.stage == 'stage';
			newData.countdownSuffix = '';

			newData.player1 = oldCharToDillyz(newData.player1);
			newData.player2 = oldCharToDillyz(newData.player2);

			for (i in newData.notes)
			{
				i.theNotes = new Array<NoteData>();
				for (o in i.sectionNotes)
					i.theNotes.push({
						strumTime: o[0],
						noteData: o[1],
						sustainLength: o[2],
						noteType: ''
					});

				i.sectionNotes.wipeArray();
			}
		}

		return newData;
	}
}

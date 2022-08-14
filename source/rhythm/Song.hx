package rhythm;

import rhythm.Section.SectionData;

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
	var validScore:Bool;

	// DILLYZ ENGINE STUFF
	var girlfriend:Null<String>;
	var stage:Null<String>;
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

	public function new(songName:String, notes:Array<SectionData>, bpm:Int, needsVoices:Bool, speed:Float, boyfriend:String, dad:String,
			girlfriendYouDontHave:String, stage:String)
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
	}

	public static var defSong:SongData = {
		song: 'Tutorial',
		notes: [],
		bpm: 100,
		needsVoices: false,
		speed: 1,
		player1: 'bf',
		player2: '',
		validScore: true,
		// DILLYZ ENGINE STUFF
		girlfriend: 'gf',
		stage: 'stage'
	};

	public static function fromSongName(songName:String, difficulty:String):SongData
	{
		return
			Paths.json('${songName.toLowerCase().replace(' ', '-')}/${songName.toLowerCase().replace(' ', '-')}-${difficulty.toLowerCase().replace(' ', '-')}',
				null,
			defSong);
	}
}

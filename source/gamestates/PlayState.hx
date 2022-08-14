package gamestates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.system.debug.console.Console;
import flixel.util.FlxTimer;
import gamestates.MusicBeatState.FunkinTransitionType;
import gamestates.editors.CharacterEditorState;
import gamestates.menus.MainMenuState;
import haxe.Json;
import managers.BGMusicManager;
import objects.FunkySprite;
import objects.FunkyStage;
import objects.characters.Character;
import openfl.media.Sound;
import rhythm.Conductor;
import rhythm.Song;
import sys.io.File;

typedef CountdownJson =
{
	var threeOffset:Array<Int>;
	var twoOffset:Array<Int>;
	var oneOffset:Array<Int>;
	var goOffset:Array<Int>;
}

// import managers.StateManager;
class PlayState extends MusicBeatState
{
	// stage
	private var theStage:FunkyStage;

	// characters
	private var charLeft:Character;
	private var charMid:Character;
	private var charRight:Character;

	// the song
	public static var curSong:Song;

	// song control
	private var genMusic:Bool = false;
	private var canCountdown:Bool = false;
	private var countdownStarted:Bool = false;
	private var songStarted:Bool = false;
	private var songLength:Float = 0;

	// cutscene stuff
	private var preSongCutscene:Bool = false;
	private var postSongCutscene:Bool = false;
	private var inCutscene:Bool = false;

	private var countdownSprite:FlxSprite;
	private var countdownJson:CountdownJson;

	// song stuff
	private var instData:Sound;
	private var voices:FlxSound;

	override public function create()
	{
		super.create();
		BGMusicManager.stop();

		curSong = Song.songFromName('Bopeebo', 'Hard');
		Conductor.mapBPMChanges(curSong);
		Conductor.changeBPM(curSong.bpm);

		theStage = new FunkyStage(curSong.stage);
		add(theStage);

		FlxG.camera.zoom = theStage.camZoom;

		charMid = new Character(theStage.posGF.x, theStage.posGF.y, curSong.girlfriendYouDontHave, false, false, false);
		add(charMid);

		charLeft = new Character(theStage.posDad.x, theStage.posDad.y, curSong.dad, false, false, false);
		add(charLeft);

		charRight = new Character(theStage.posBF.x, theStage.posBF.y, curSong.boyfriend, true, true, false);
		add(charRight);

		// this is used for cloning
		countdownSprite = new FlxSprite();
		countdownSprite.frames = Paths.sparrowV2('ui/countdown' + curSong.countdownSuffix, 'shared');
		countdownSprite.animation.addByPrefix('Three', 'Three', 24, false, false, false);
		countdownSprite.animation.addByPrefix('Two', 'Two', 24, false, false, false);
		countdownSprite.animation.addByPrefix('One', 'One', 24, false, false, false);
		countdownSprite.animation.addByPrefix('Go', 'Go', 24, false, false, false);
		countdownSprite.animation.play('Three', true);

		if (Paths.assetExists('images/ui/countdown' + curSong.countdownSuffix, 'shared', 'json'))
			countdownJson = Json.parse(File.getContent(Paths.asset('images/ui/countdown' + curSong.countdownSuffix, 'shared', 'json')));
		else
			countdownJson = {
				threeOffset: [0, 0],
				twoOffset: [0, 0],
				oneOffset: [0, 0],
				goOffset: [0, 0]
			};

		trace(countdownJson);

		Conductor.songPosition = -5000;
		canCountdown = true;

		regenerateSong();
		startCountdown();

		postCreate();
	}

	private function regenerateSong()
	{
		instData = Paths.songInst(curSong.songName);
		voices = new FlxSound();
		if (curSong.needsVoices)
			voices.loadEmbedded(Paths.songVoices(curSong.songName), false, false);

		FlxG.sound.list.add(voices);
	}

	private function startCountdown()
	{
		if (!canCountdown)
			return;

		inCutscene = countdownStarted = false;
		Conductor.songPosition = -(Conductor.crochet * 5);

		var makeCountdownSpr:(String, Bool, Array<Int>) -> Void = function(countdownAnim:String, cleanOG:Bool, offsetttt:Array<Int>)
		{
			var newCountdownSpr:FlxSprite = countdownSprite.clone();
			add(newCountdownSpr);
			newCountdownSpr.cameras = [camHUD];
			newCountdownSpr.animation.play(countdownAnim, true);
			newCountdownSpr.animation.finishCallback = function(anim:String)
			{
				remove(newCountdownSpr);
				newCountdownSpr.destroy();

				if (cleanOG)
				{
					countdownSprite.destroy();
					countdownSprite = null;
				}
			};
			newCountdownSpr.screenCenter();
			newCountdownSpr.x += offsetttt[0];
			newCountdownSpr.y += offsetttt[1];
		};

		new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			switch (tmr.elapsedLoops)
			{
				case 1:
					FlxG.sound.play(Paths.sound('countdown/intro3', 'shared'), 0.75);
					makeCountdownSpr('Three', false, countdownJson.threeOffset);
				case 2:
					FlxG.sound.play(Paths.sound('countdown/intro2', 'shared'), 0.75);
					makeCountdownSpr('Two', false, countdownJson.twoOffset);
				case 3:
					FlxG.sound.play(Paths.sound('countdown/intro1', 'shared'), 0.75);
					makeCountdownSpr('One', false, countdownJson.oneOffset);
				case 4:
					FlxG.sound.play(Paths.sound('countdown/introGo', 'shared'), 0.75);
					makeCountdownSpr('Go', true, countdownJson.goOffset);
				case 5:
					startSong();
			}
		}, 5);
	}

	private function startSong()
	{
		songStarted = true;

		FlxG.sound.playMusic(instData, 1, false);
		voices.play();
		FlxG.sound.music.onComplete = function()
		{
			switchState(MainMenuState, [], false, FunkinTransitionType.Black);
		};
		songLength = FlxG.sound.music.length;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
			Sys.exit(0);
		else if (FlxG.keys.justPressed.S)
		{
			charLeft.playAnim('singLEFT', true);
			charMid.playAnim('singLEFT', true);
			charRight.playAnim('singLEFT', true);
		}
		else if (FlxG.keys.justPressed.D)
		{
			charLeft.playAnim('singDOWN', true);
			charMid.playAnim('singDOWN', true);
			charRight.playAnim('singDOWN', true);
		}
		else if (FlxG.keys.justPressed.K)
		{
			charLeft.playAnim('singUP', true);
			charMid.playAnim('singUP', true);
			charRight.playAnim('singUP', true);
		}
		else if (FlxG.keys.justPressed.L)
		{
			charLeft.playAnim('singRIGHT', true);
			charMid.playAnim('singRIGHT', true);
			charRight.playAnim('singRIGHT', true);
		}
		else if (FlxG.keys.justPressed.ONE)
		{
			// StateManager.load(CharacterEditorState);
			switchState(CharacterEditorState, [], false);
		}
		else if (FlxG.keys.justPressed.TWO)
		{
			// StateManager.loadAndClearMemory(CharacterEditorState);
			switchState(CharacterEditorState, [], true);
		}
		else if (FlxG.keys.justPressed.THREE)
		{
			// StateManager.loadAndClearMemory(CharacterEditorState);
			switchState(MainMenuState, [], false, FunkinTransitionType.Black);
		}

		charRight.holdingControls = (FlxG.keys.pressed.S || FlxG.keys.pressed.D || FlxG.keys.pressed.K || FlxG.keys.pressed.L);
	}

	override public function beatHit()
	{
		if (curBeat % 2 == 0)
		{
			charLeft.dance();
			charMid.dance();
			charRight.dance();
		}
	}
}

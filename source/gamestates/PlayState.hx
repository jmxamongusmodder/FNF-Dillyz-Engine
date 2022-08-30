package gamestates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.system.debug.console.Console;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import gamestates.MusicBeatState.FunkinTransitionType;
import gamestates.editors.CharacterEditorState;
import gamestates.editors.ChartEditorState;
import gamestates.menus.FreeplayState;
import gamestates.menus.MainMenuState;
import gamesubstates.PauseSubState;
import haxe.Json;
import lime.app.Application;
import managers.BGMusicManager;
import managers.FunkyLuaManager;
import managers.PreferenceManager;
import objects.FunkySprite;
import objects.FunkyStage;
import objects.FunkyText;
import objects.characters.Character;
import objects.ui.Alphabet;
import objects.ui.SongNote;
import objects.ui.StrumLineNote;
import objects.ui.health.HealthBar;
import openfl.media.Sound;
import rhythm.Conductor;
import rhythm.Song;
import sys.io.File;

using DillyzUtil;

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
	public static var instance:PlayState;

	// lua stuff
	public var songLua:FunkyLuaManager;
	public var spriteMap:Map<String, FunkySprite>;

	// stage
	private var theStage:FunkyStage;

	// characters
	private var charLeft:Character;
	private var charMid:Character;
	private var charRight:Character;

	// the song
	public static var loadFromChartEditorInstead:Bool = false;
	public static var cameFromFreeplay:Bool = false;
	public static var songToLoad:String = 'Bopeebo';
	public static var diffToLoad:String = 'Hard';
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

	// strum note stuff
	private var strumLine:Float = 35;
	private var opponentStrums:FlxTypedSpriteGroup<StrumLineNote>;
	private var playerStrums:FlxTypedSpriteGroup<StrumLineNote>;

	public static var keyCount:Int = 4; // future support
	private static var middleScroll:Bool = true;
	private static var curSpeed:Float = 1;

	// notes
	private var displayedNotes:FlxTypedSpriteGroup<SongNote>;
	private var hiddenNotes:Array<SongNote>;

	// ui elements
	private var curHealth:Float = 1;
	private var healthBar:HealthBar;
	private var curScore:Int = 0;
	private var missCount:Int = 0;
	private var accuracyCount:Float = 0;
	private var accuracyPrecalc:Float = 0;
	private var accuracyPrecalcAmount:Float = 0;
	private var scoreInfo:FunkyText;

	override public function create()
	{
		super.create();
		BGMusicManager.stop();

		instance = this;

		PauseSubState.initOptions();

		if (!loadFromChartEditorInstead)
			curSong = Song.songFromName(songToLoad, diffToLoad);
		Conductor.mapBPMChanges(curSong);
		Conductor.changeBPM(curSong.bpm);

		spriteMap = new Map<String, FunkySprite>();
		theStage = new FunkyStage(curSong.stage);
		add(theStage);

		FlxG.camera.zoom = theStage.camZoom;

		charMid = new Character(theStage.posGF.x, theStage.posGF.y, curSong.girlfriendYouDontHave, false, false, false);
		add(charMid);

		charLeft = new Character(theStage.posDad.x, theStage.posDad.y, curSong.dad, false, false, false);
		add(charLeft);

		charRight = new Character(theStage.posBF.x, theStage.posBF.y, curSong.boyfriend, true, true, false);
		add(charRight);

		// set lua access with multiple references
		spriteMap.set('charMid', charMid);
		spriteMap.set('gf', charMid);
		spriteMap.set('girlfriend', charMid);

		spriteMap.set('charLeft', charLeft);
		spriteMap.set('dad', charLeft);
		spriteMap.set('daddy', charLeft);
		spriteMap.set('dearest', charLeft);

		spriteMap.set('charRight', charRight);
		spriteMap.set('bf', charRight);
		spriteMap.set('boyfriend', charRight);

		theStage.setupLua();

		if (Paths.songLuaExists(curSong.songName))
			songLua = new FunkyLuaManager('${curSong.songName}.lua', Paths.songLua(curSong.songName));

		middleScroll = PreferenceManager.middleScroll;
		prepareStrumLineNotes();

		healthBar = new HealthBar(0, 600);
		healthBar.screenCenter(X);
		healthBar.updateHealthIconsAndColors(charLeft, charRight);
		add(healthBar);
		healthBar.cameras = [camHUD];

		scoreInfo = new FunkyText(0, 650, 0, 'I', 24);
		scoreInfo.setFormat(Paths.font('vcr'), 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreInfo.borderSize = 1;
		add(scoreInfo);
		scoreInfo.cameras = [camHUD];
		scoreInfo.antialiasing = managers.PreferenceManager.antialiasing;
		scoreInfo.screenCenter(X);

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

		curSpeed = curSong.speed;

		// arrow debugging
		/*var bbruhhhhh = new FlxSprite((FlxG.width / 4) - 4, 0).makeGraphic(8, FlxG.height, FlxColor.RED);
			var bbruhhhhh2 = new FlxSprite(((FlxG.width / 4) * 3) - 4, 0).makeGraphic(8, FlxG.height, FlxColor.RED);
			add(bbruhhhhh);
			add(bbruhhhhh2);
			bbruhhhhh.cameras = bbruhhhhh2.cameras = [camHUD]; */

		displayedNotes = new FlxTypedSpriteGroup<SongNote>();
		hiddenNotes = new Array<SongNote>();

		add(displayedNotes);
		displayedNotes.cameras = [camHUD];

		regenerateSong();
		startCountdown();

		postCreate();
		callLua('onCreatePost', []);
		updateScore();
	}

	public function updateScore(?funnyBounce:Bool = true)
	{
		accuracyCount = (accuracyPrecalc / accuracyPrecalcAmount);
		scoreInfo.text = '$curScore Score \\\\ ${missCount > 0 ? '$missCount ${missCount == 1 ? 'Miss' : 'Misses'}' : 'No Misses'} \\\\ Composed by ${curSong.songComposer} // ${accuracyPrecalc > 0 ? '${Std.int(accuracyCount * 10) / 10.0}%' : 'Invalid'} Accuracy // $diffToLoad Mode';
		if (funnyBounce)
			scoreInfo.scale.x = scoreInfo.scale.y = 1.1;
	}

	public function addHealth(newHealth:Float)
	{
		curHealth += newHealth;
		if (curHealth >= 2)
			curHealth = 2;
		else if (curHealth <= 0)
			curHealth = 0;
		healthBar.updateHealth(curHealth);
	}

	public function setHealth(newHealth:Float)
	{
		curHealth = newHealth;
		if (curHealth >= 2)
			curHealth = 2;
		else if (curHealth <= 0)
			curHealth = 0;
		healthBar.updateHealth(curHealth);
	}

	public function callLua(functionName:String, arguments:Array<Dynamic>)
	{
		if (theStage.stageLua != null)
			return theStage.stageLua.callFunction(functionName, arguments);
		return null;
	}

	public function setLua(varName:String, value:Dynamic)
	{
		if (theStage.stageLua != null)
			theStage.stageLua.setVar(varName, value);
		if (songLua != null)
			songLua.setVar(varName, value);
	}

	// this function is for future usage with songs
	public function getStrumNoteName(player:Int, index:Int)
	{
		var funnyReturn:Dynamic = callLua('getStrumNoteName', [player, index]);
		if (Std.isOfType(funnyReturn, String))
			return funnyReturn;
		return 'Strum Line Notes';
	}

	public function getNoteName(noteData:Int, noteType:String, mustHit:Bool):String
	{
		var funnyReturn:Dynamic = callLua('getNoteName', [noteData, noteType, mustHit]);
		if (Std.isOfType(funnyReturn, String))
			return funnyReturn;
		return 'Scrolling Notes';
	}

	private function prepareStrumLineNotes()
	{
		opponentStrums = new FlxTypedSpriteGroup<StrumLineNote>();
		playerStrums = new FlxTypedSpriteGroup<StrumLineNote>();

		add(opponentStrums);
		add(playerStrums);
		opponentStrums.cameras = playerStrums.cameras = [camHUD];

		SongNote.resetVariables();

		var noteAnimMap:Map<String, StrumLineNoteData> = new Map<String, StrumLineNoteData>();

		for (p in 0...2)
		{
			var strumMid:Float;
			if (!middleScroll)
				strumMid = (p == 0) ? FlxG.width / 4 : FlxG.width - (FlxG.width / 4);
			else
				strumMid = (p == 0) ? FlxG.width / 4 : FlxG.width / 2;

			for (i in 0...keyCount)
			{
				var strumNoteList:FlxTypedSpriteGroup<StrumLineNote> = (p == 0) ? opponentStrums : playerStrums;

				var noteDataJson:StrumLineNoteData;

				var noteName:String = getStrumNoteName(p, i);

				if (noteAnimMap.exists(noteName))
					noteDataJson = noteAnimMap.get(noteName);
				else
				{
					noteDataJson = Paths.imageJson('ui/notes/strumline/$noteName', 'shared', {
						scale: 1,
						staticOffset: [0, 0],
						hitOffset: [-3, -3],
						pressedOffset: [13, 13]
					});
					noteAnimMap.set(noteName, noteDataJson);
				}

				// var widthBetween = SongNote.noteWidth;
				var newStrumNote:StrumLineNote = new StrumLineNote(((middleScroll && p == 0 && i >= keyCount / 2.0) ? (FlxG.width / 4) * 3 : strumMid)
					+ ((SongNote.noteWidth * SongNote.noteScaling) * (i - (keyCount / 2.0) + 0.5)),
					strumLine
					- 35, i, noteName, noteDataJson);
				strumNoteList.add(newStrumNote);
				newStrumNote.alpha = 0;

				newStrumNote.x -= ((SongNote.noteWidth * SongNote.noteScaling) / 2) + 35;

				newStrumNote.autoSnapAnim = p == 0;

				FlxTween.tween(newStrumNote, {alpha: (middleScroll && p == 0) ? 0.5 : 1, y: strumLine}, 1.75, {ease: FlxEase.circOut, startDelay: i * 0.15});
			}
		}
	}

	private function regenerateSong()
	{
		instData = Paths.songInst(curSong.songName);
		if (voices != null)
		{
			FlxG.sound.list.remove(voices);
			voices.destroy();
		}
		voices = new FlxSound();
		if (curSong.needsVoices)
			voices.loadEmbedded(Paths.songVoices(curSong.songName), false, false);

		FlxG.sound.list.add(voices);

		var lastNote:SongNote = null;
		var songNoteDataMap:Map<String, SongNoteData> = new Map<String, SongNoteData>();
		for (section in curSong.notes)
			for (note in section.theNotes)
			{
				var isBFNote:Bool = note.noteData >= keyCount;
				if (section.mustHitSection)
					isBFNote = !isBFNote;
				var curData:SongNoteData;
				var noteName:String = getNoteName(note.noteData, note.noteType, isBFNote);
				if (songNoteDataMap.exists(noteName))
					curData = songNoteDataMap.get(noteName);
				else
				{
					curData = Paths.imageJson('ui/notes/scrolling/$noteName', 'shared', {
						scale: 1,
						scrollOffsetCyan: [0, 0],
						sustainEndCyan: [40, 0],
						sustainHoldCyan: [40, 0],
						scrollOffsetLime: [0, 0],
						sustainEndLime: [40, 0],
						sustainHoldLime: [40, 0],
						scrollOffsetPink: [0, 0],
						sustainEndPink: [40, 0],
						sustainHoldPink: [40, 0],
						scrollOffsetRed: [0, 0],
						sustainEndRed: [40, 0],
						sustainHoldRed: [40, 0]
					});
					songNoteDataMap.set(noteName, curData);
				}
				var theNote:SongNote = new SongNote(0, 0, lastNote, note.strumTime, note.noteData % keyCount, isBFNote, false, note.noteType, noteName,
					curData);

				lastNote = theNote;

				var susDiv:Float = 64;
				var susCut:Float = note.sustainLength / susDiv;
				for (i in 0...Std.int(susCut))
				{
					var sustainNote:SongNote = new SongNote(0, 0, lastNote, note.strumTime + (i * susDiv), note.noteData % keyCount, isBFNote, true,
						note.noteType, noteName, curData);
					hiddenNotes.push(sustainNote);
					lastNote = sustainNote;
					sustainNote.alpha = 0.5;
					sustainNote.visible = sustainNote.active = false;
				}

				hiddenNotes.push(theNote);
				theNote.visible = theNote.active = false;
			}

		genMusic = true;
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
			callLua('onCountdown', [tmr.elapsedLoops]);
			switch (tmr.elapsedLoops)
			{
				case 1:
					FlxG.sound.play(Paths.sound('countdown/intro3', 'shared'), 0.75);
					makeCountdownSpr('Three', false, countdownJson.threeOffset);
					setCamTarget('dad');
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
					setCamTarget('bf');
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
			endSong();
		};
		songLength = FlxG.sound.music.length;
		callLua('onStartSong', []);
	}

	public function setCamTarget(char:String)
	{
		var offsetX:Float = 25;
		var offsetY:Float = -100;
		var curCharLol:Character;
		curCamZoom = theStage.camZoom;

		switch (char)
		{
			case 'bf':
				offsetX = -100;
				offsetY = -100;
				curCharLol = charRight;
				curCamZoom *= theStage.zoomMultiBF;
				offsetX += theStage.camOffBF.x;
				offsetY += theStage.camOffBF.y;
			case 'dad':
				offsetX = 150;
				offsetY = -100;
				curCharLol = charLeft;
				curCamZoom *= theStage.zoomMultiDad;
				offsetX += theStage.camOffDad.x;
				offsetY += theStage.camOffDad.y;
			default:
				curCharLol = charMid;
				curCamZoom *= theStage.zoomMultiGF;
				offsetX += theStage.camOffGF.x;
				offsetY += theStage.camOffGF.y;
		}

		offsetX += curCharLol.camOffset.x;
		offsetY += curCharLol.camOffset.y;
		curCamZoom *= curCharLol.camZoomMultiplier;

		@:privateAccess {
			for (i in curCharLol.charData.animData)
				if (i.name == curCharLol.getAnim())
				{
					offsetX += i.cameraOffset[0];
					offsetY += i.cameraOffset[1];
					curCamZoom *= i.camZoomMulti;
				}
		}

		camFollow.setPosition(curCharLol.getMidpoint().x + offsetX, curCharLol.getMidpoint().y + offsetY);
		callLua('onCamTarget', [char]);
	}

	var dirtyNotes:Array<SongNote> = [];
	var alreadyHitNote:Array<Bool> = [false, false, false, false];

	function displaySort(bruhL:Int, Obj1:SongNote, Obj2:SongNote)
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1 != null ? Obj1.strumTime : 0, Obj2 != null ? Obj2.strumTime : 0);
	}

	/*function hiddenSort(Obj1:SongNote, Obj2:SongNote)
		{
			return FlxSort.byValues(FlxSort.ASCENDING, Obj1 != null ? Obj1.strumTime : 0, Obj2 != null ? Obj2.strumTime : 0);
	}*/
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		callLua('onUpdate', [elapsed]);

		scoreInfo.scale.x = scoreInfo.scale.y = FlxMath.lerp(1, scoreInfo.scale.x, elapsed * 114);
		scoreInfo.screenCenter(X);

		// yes ik this gets set off even when hitting a note but shut up it's just ghost tapping rn
		for (i in 0...SongNote.keyArray.length)
		{
			if (FlxG.keys.anyJustPressed([SongNote.keyArray[i]]))
			{
				var strumNote:StrumLineNote = playerStrums.members[i % playerStrums.members.length];
				strumNote.press();
				// charRight.playAnim('sing${SongNote.noteDirections[i % SongNote.noteDirections.length].toUpperCase()}miss', true);
				// FlxG.sound.play(Paths.sound('notes/missnote${FlxG.random.int(1, 3)}', 'shared'), 0.85);
			}
			else if (FlxG.keys.anyJustReleased([SongNote.keyArray[i]]))
			{
				var strumNote:StrumLineNote = playerStrums.members[i % playerStrums.members.length];
				strumNote.letGo();
			}
		}

		for (i in 0...alreadyHitNote.length)
			alreadyHitNote[i] = false;

		if (genMusic)
		{
			dirtyNotes.wipeArray();

			for (i in hiddenNotes)
			{
				var strumNoteList:FlxTypedSpriteGroup<StrumLineNote> = !i.boyfriendNote ? opponentStrums : playerStrums;
				var strumNote:StrumLineNote = strumNoteList.members[i.noteData % strumNoteList.members.length];
				if ((strumNote.y - (Conductor.songPosition - i.strumTime) * (0.45 * FlxMath.roundDecimal(curSpeed, 2))) <= FlxG.height)
					dirtyNotes.push(i);
			}

			for (i in dirtyNotes)
			{
				hiddenNotes.remove(i);
				displayedNotes.add(i);
				i.visible = i.active = true;
			}

			dirtyNotes.wipeArray();

			for (i in displayedNotes)
			{
				var strumNoteList:FlxTypedSpriteGroup<StrumLineNote> = !i.boyfriendNote ? opponentStrums : playerStrums;
				var strumNote:StrumLineNote = strumNoteList.members[i.noteData % strumNoteList.members.length];
				i.x = strumNote.x;
				i.y = (strumNote.y - (Conductor.songPosition - i.strumTime) * (0.45 * FlxMath.roundDecimal(curSpeed, 2)));

				// i.visible = i.y >= FlxG.height;

				if (i.sustainNote)
				{
					i.scale.y = 2.15 * (0.45 * FlxMath.roundDecimal(curSpeed, 2)) * SongNote.noteScaling;
					i.offset.set(i.lastOffset.x, i.lastOffset.y * FlxMath.roundDecimal(curSpeed, 2));
				}

				var curChar:Character = i.boyfriendNote ? charRight : charLeft;

				if (songStarted)
				{
					if (!i.deletedOnScroll)
					{
						if (!i.boyfriendNote)
						{
							if (i.strumTime <= Conductor.songPosition)
							{
								dirtyNotes.push(i);

								curChar.playAnim('sing${SongNote.noteDirections[i.noteData % SongNote.noteDirections.length].toUpperCase()}', true,
									!i.sustainNote);
								strumNote.hit();
								i.deletedOnScroll = true;
								voices.volume = 1;
							}
						}
						else
						{
							var noteHasBeenHit:Bool = alreadyHitNote[i.noteData % alreadyHitNote.length];
							if (i.strumTime <= Conductor.songPosition - Conductor.safeZoneOffset)
							{
								// dirtyNotes.push(i);
								FlxG.sound.play(Paths.sound('notes/missnote${FlxG.random.int(1, 3)}', 'shared'), 0.85);

								curChar.playAnim('sing${SongNote.noteDirections[i.noteData % SongNote.noteDirections.length].toUpperCase()}miss', true,
									!i.sustainNote);
								// strumNote.fail();
								i.deletedOnScroll = true;
								i.alpha /= 2;

								addHealth(i.sustainNote ? -0.0125 : -0.0475);
								voices.volume = 0;
								accuracyPrecalcAmount += (i.sustainNote ? 0.15 : 1);
								missCount++;
								updateScore();
							}
							else if (i.sustainNote
								&& i.strumTime <= Conductor.songPosition
								&& FlxG.keys.anyPressed([SongNote.keyArray[i.noteData % SongNote.keyArray.length]]))
							{
								dirtyNotes.push(i);

								curChar.playAnim('sing${SongNote.noteDirections[i.noteData % SongNote.noteDirections.length].toUpperCase()}', true, false);
								strumNote.hit();
								i.deletedOnScroll = true;
								addHealth(0.00625);
								voices.volume = 1;

								curScore += 50;
								updateScore(false);
							}
							else if (!i.sustainNote
								&& i.strumTime <= Conductor.songPosition + Conductor.safeZoneOffset
								&& FlxG.keys.anyJustPressed([SongNote.keyArray[i.noteData % SongNote.keyArray.length]])
								&& !noteHasBeenHit)
							{
								dirtyNotes.push(i);

								curChar.playAnim('sing${SongNote.noteDirections[i.noteData % SongNote.noteDirections.length].toUpperCase()}', true);
								strumNote.hit();
								i.deletedOnScroll = alreadyHitNote[i.noteData % alreadyHitNote.length] = true;
								addHealth(0.025);
								voices.volume = 1;

								var curAcc:Float = Math.abs(((Conductor.songPosition - i.strumTime) / (Conductor.safeFrames / 10)) / 1.15).snapFloat(0, 100);
								Application.current.window.title = '$curAcc';
								curScore += Std.int(450 + (450 * (curAcc / 100))).snapInt(-250, 450);
								accuracyPrecalc += 100 - curAcc;
								accuracyPrecalcAmount++;
								updateScore();
							}
						}
					}
					else if (SongNote.noteWidth >= i.y)
						dirtyNotes.push(i);
				}
			}

			for (i in dirtyNotes)
			{
				displayedNotes.remove(i);
				i.destroy();
			}

			if (curSong.notes != null
				&& curSong.notes[Std.int(curStep / 16)] != null
				&& curSong.notes[Std.int(curStep / 16)].mustHitSection)
				setCamTarget('bf');
			else
				setCamTarget('dad');

			if (displayedNotes != null && displayedNotes.length >= 2)
				displayedNotes.sort(displaySort);
			// if (hiddenNotes != null && hiddenNotes.length >= 2)
			//	hiddenNotes.sort(hiddenSort);
		}

		if (songStarted)
		{
			if (FlxG.keys.justPressed.ENTER)
				openSubState(new PauseSubState());
			else if (FlxG.keys.justPressed.SEVEN)
				endSong(ChartEditorState, FunkinTransitionType.Normal);
			// switchState(PlayState, [], false, FunkinTransitionType.Normal);
		}

		charRight.holdingControls = FlxG.keys.anyPressed(SongNote.keyArray);
		callLua('onUpdatePost', [elapsed]);
	}

	function wipeAllNotes()
	{
		dirtyNotes.wipeArray();

		for (i in hiddenNotes)
			dirtyNotes.push(i);

		for (i in dirtyNotes)
		{
			hiddenNotes.remove(i);
			i.destroy();
		}

		for (i in displayedNotes)
			dirtyNotes.push(i);

		for (i in dirtyNotes)
		{
			displayedNotes.remove(i);
			i.destroy();
		}
		dirtyNotes.wipeArray();
	}

	function endSong(?overrideState:Class<MusicBeatState> = null, ?overrideTrans:FunkinTransitionType = FunkinTransitionType.Black)
	{
		callLua('onEndSong', []);
		wipeAllNotes();

		if (PauseSubState.optionInstances != null)
		{
			var dirtyOptions:Array<Alphabet> = [];
			for (i in PauseSubState.optionInstances)
				dirtyOptions.push(i);
			for (i in dirtyOptions)
			{
				i.destroy();
				PauseSubState.optionInstances.remove(i);
			}
			PauseSubState.optionInstances = dirtyOptions = null;
		}

		// prevent the unfunny character editor from trolling
		spriteMap.clear();
		spriteMap = null;

		BGMusicManager.play('freakyMenu', 102);
		switchState(overrideState == null ? (cameFromFreeplay ? MainMenuState : FreeplayState) : overrideState, [], false, overrideTrans);
	}

	override public function beatHit()
	{
		setLua('curBeat', curBeat);
		callLua('onBeatHit', []);
		if (curBeat % 2 == 0)
		{
			charLeft.dance();
			charMid.dance();
			charRight.dance();
			camGame.zoom *= 1.025;
			healthBar.iconBop();
		}
		callLua('onBeatHitPost', []);
	}

	override public function stepHit()
	{
		setLua('curStep', curStep);
		callLua('onStepHit', []);
	}
}

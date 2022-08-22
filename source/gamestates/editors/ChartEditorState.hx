package gamestates.editors;

import DillyzLogger.LogType;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import gamestates.MusicBeatState.FunkinTransitionType;
import haxe.Exception;
import objects.ui.SongNote;
import rhythm.Conductor;
import rhythm.Section;

using DillyzUtil;

@:privateAccess
class ChartEditorState extends MusicBeatState
{
	var strumLine:Int = 10;
	var GRID_SIZE:Int = 40;

	var gridBG:FlxSprite;
	var gridSplit:FlxSprite;

	var newRenderedNotes:FlxTypedGroup<SongNote>;

	var theVoices:FlxSound;

	var gridLayer:FlxTypedGroup<FlxSprite>;

	override public function create()
	{
		super.create();

		gridLayer = new FlxTypedGroup<FlxSprite>();

		theVoices = new FlxSound();
		if (PlayState.curSong.needsVoices)
			theVoices.loadEmbedded(Paths.songVoices(PlayState.curSong.songName), false, false);

		newRenderedNotes = new FlxTypedGroup<SongNote>();

		// gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * (PlayState.keyCount * 2), GRID_SIZE * (PlayState.keyCount * 4));
		// gridLayer.add(gridBG);

		add(gridLayer);
		add(newRenderedNotes);

		refreshGrid();
		reloadNotes();

		postCreate();
	}

	function refreshGrid()
	{
		SongNote.resetVariables();
		if (gridBG != null)
		{
			gridLayer.remove(gridBG);
			gridBG.destroy();
		}
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * (PlayState.keyCount * 2), GRID_SIZE * 16);
		gridLayer.add(gridBG);
		if (gridSplit != null)
		{
			gridLayer.remove(gridSplit);
		}
		else
			gridSplit = new FlxSprite().makeGraphic(4, GRID_SIZE * 16, FlxColor.BLACK);
		gridSplit.setPosition(gridBG.x + gridBG.width / 2 - 2, 0);
		gridLayer.add(gridSplit);
	}

	function getCurSection()
	{
		if (curSection < 0)
			curSection = 0;
		else if (curSection >= PlayState.curSong.notes.length)
			curSection = PlayState.curSong.notes.length - 1;
		if (curSection >= PlayState.curSong.notes.length)
		{
			var newSection:SectionData = {
				sectionNotes: [],
				theNotes: new Array<NoteData>(),
				lengthInSteps: 16,
				typeOfSection: 0,
				mustHitSection: false,
				bpm: 100,
				changeBPM: false,
				altAnim: false,
				gfSings: false
			};
			PlayState.curSong.notes.push(newSection);
			return newSection;
		}
		return PlayState.curSong.notes[curSection];
	}

	function strumToY(strumTime:Float)
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + (GRID_SIZE * 16));
	}

	function sectionTime()
	{
		var curBPM:Int = PlayState.curSong.bpm;
		var newPos:Float = 0;

		if (curSection < 0)
			curSection = 0;
		else if (curSection >= PlayState.curSong.notes.length)
			curSection = PlayState.curSong.notes.length - 1;
		for (i in 0...curSection)
		{
			if (PlayState.curSong.notes[i].changeBPM)
				curBPM = PlayState.curSong.notes[i].bpm;

			newPos += 4 * (1000 * 60 / curBPM);
		}
		return newPos;
	}

	var canReload:Bool = true;

	function reloadNotes()
	{
		trace('swapping section');
		canReload = false;
		var dirtyNotes:Array<SongNote> = [];
		for (i in 0...newRenderedNotes.members.length)
			dirtyNotes.push(newRenderedNotes.members[i]);
		for (i in dirtyNotes)
		{
			newRenderedNotes.remove(i);
			if (i != null && i.alive)
				i.destroy();
		}
		dirtyNotes.wipeArray();

		for (i in getCurSection().theNotes)
		{
			var newNote:SongNote = new SongNote(0, 0, null, i.strumTime, i.noteData, false, false, i.noteType, "Scrolling Notes", null);
			newNote.setGraphicSize(GRID_SIZE, GRID_SIZE);
			newNote.updateHitbox();
			newNote.x = Math.floor(i.noteData * GRID_SIZE);
			newNote.y = Math.floor(strumToY((i.strumTime - sectionTime()) % (Conductor.stepCrochet * getCurSection().lengthInSteps)));

			newRenderedNotes.add(newNote);
		}
		canReload = true;
	}

	override public function update(e:Float)
	{
		super.update(e);

		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.ENTER)
			switchState(PlayState, [], false, FunkinTransitionType.Normal);

		if (canReload)
		{
			if (FlxG.keys.justPressed.UP)
			{
				curSection--;
				reloadNotes();
			}
			else if (FlxG.keys.justPressed.DOWN)
			{
				curSection++;
				reloadNotes();
			}
		}
	}
}

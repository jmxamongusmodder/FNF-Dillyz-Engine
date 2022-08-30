package objects.ui;

import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import gamestates.PlayState;

using DillyzUtil;
using StringTools;

typedef SongNoteData =
{
	var scale:Int;
	var scrollOffsetCyan:Array<Int>;
	var sustainEndCyan:Array<Int>;
	var sustainHoldCyan:Array<Int>;
	var scrollOffsetLime:Array<Int>;
	var sustainEndLime:Array<Int>;
	var sustainHoldLime:Array<Int>;
	var scrollOffsetPink:Array<Int>;
	var sustainEndPink:Array<Int>;
	var sustainHoldPink:Array<Int>;
	var scrollOffsetRed:Array<Int>;
	var sustainEndRed:Array<Int>;
	var sustainHoldRed:Array<Int>;
}

class SongNote extends FunkySprite
{
	public static var noteWidth:Float = 160;
	public static var noteScaling:Float = 0.7;
	public static var noteColors:Array<String> = ['Pink', 'Cyan', 'Lime', 'Red'];
	public static var noteDirections:Array<String> = ['Left', 'Down', 'Up', 'Right'];
	public static var keyArray:Array<FlxKey> = [
		FlxKey.fromString('S'),
		FlxKey.fromString('D'),
		FlxKey.fromString('K'),
		FlxKey.fromString('L')
	];

	public var ogX:Float;
	public var ogY:Float;
	public var strumTime:Float;
	public var noteType:String;
	public var noteData:Int;
	public var songNoteData:SongNoteData;

	public var boyfriendNote:Bool;

	public var lastNote:SongNote;
	public var sustainNote:Bool;

	public var deletedOnScroll:Bool = false;

	public function new(x:Float, y:Float, lastNote:SongNote, strumTime:Float, noteData:Int, boyfriendNote:Bool, sustainNote:Bool, ?noteType:String = '',
			?textureName:String = 'Scrolling Notes', ?textureJson:Null<SongNoteData>)
	{
		super(x, y);
		this.debugEnabled = false;
		this.ogX = x;
		this.ogY = y;
		this.lastNote = lastNote;
		this.strumTime = strumTime;
		this.noteData = noteData;
		this.boyfriendNote = boyfriendNote;
		this.noteType = noteType;
		this.sustainNote = sustainNote;
		reloadNote(textureName, textureJson);
		this.antialiasing = managers.PreferenceManager.antialiasing;
	}

	public function reloadNote(?textureName:String = 'Scrolling Notes', ?textureJson:Null<SongNoteData>)
	{
		if (textureJson == null)
			textureJson = {
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
			};
		scale.x = scale.y = SongNote.noteScaling * textureJson.scale;

		frames = Paths.sparrowV2('ui/notes/scrolling/$textureName', 'shared');
		animation.addByPrefix('Scrolling', 'Scrolling Note ${SongNote.noteColors[noteData % SongNote.noteColors.length]}', 24, true, false, false);
		animation.addByPrefix('Sustain End', 'Sustain End ${SongNote.noteColors[noteData % SongNote.noteColors.length]}', 24, false, false, false);
		animation.addByPrefix('Sustain Hold', 'Sustain Hold ${SongNote.noteColors[noteData % SongNote.noteColors.length]}', 24, false, false, false);
		switch (SongNote.noteColors[noteData % SongNote.noteColors.length])
		{
			case 'Lime':
				animOffsets.set('Scrolling', new FlxPoint(textureJson.scrollOffsetLime[0], textureJson.scrollOffsetLime[1]));
				animOffsets.set('Sustain End', new FlxPoint(textureJson.sustainEndLime[0], textureJson.sustainEndLime[1]));
				animOffsets.set('Sustain Hold', new FlxPoint(textureJson.sustainHoldLime[0], textureJson.sustainHoldLime[1]));
			case 'Pink':
				animOffsets.set('Scrolling', new FlxPoint(textureJson.scrollOffsetPink[0], textureJson.scrollOffsetPink[1]));
				animOffsets.set('Sustain End', new FlxPoint(textureJson.sustainEndPink[0], textureJson.sustainEndPink[1]));
				animOffsets.set('Sustain Hold', new FlxPoint(textureJson.sustainHoldPink[0], textureJson.sustainHoldPink[1]));
			case 'Red':
				animOffsets.set('Scrolling', new FlxPoint(textureJson.scrollOffsetRed[0], textureJson.scrollOffsetRed[1]));
				animOffsets.set('Sustain End', new FlxPoint(textureJson.sustainEndRed[0], textureJson.sustainEndRed[1]));
				animOffsets.set('Sustain Hold', new FlxPoint(textureJson.sustainHoldRed[0], textureJson.sustainHoldRed[1]));
			default:
				animOffsets.set('Scrolling', new FlxPoint(textureJson.scrollOffsetCyan[0], textureJson.scrollOffsetCyan[1]));
				animOffsets.set('Sustain End', new FlxPoint(textureJson.sustainEndCyan[0], textureJson.sustainEndCyan[1]));
				animOffsets.set('Sustain Hold', new FlxPoint(textureJson.sustainHoldCyan[0], textureJson.sustainHoldCyan[1]));
		}

		if (sustainNote)
		{
			if (lastNote != null && lastNote.getAnim().startsWith('Sustain'))
				lastNote.playAnim('Sustain Hold', true);
			playAnim('Sustain End', true);
		}
		else
			playAnim('Scrolling', true);
	}

	public static function resetVariables()
	{
		switch (PlayState.keyCount)
		{
			case 4:
				noteWidth = 160;
				noteScaling = 0.7;
				// get colors
				noteColors.wipeArray();
				noteColors.push('Pink');
				noteColors.push('Cyan');
				noteColors.push('Lime');
				noteColors.push('Red');
				// get directions
				noteDirections.wipeArray();
				noteDirections.push('Left');
				noteDirections.push('Down');
				noteDirections.push('Up');
				noteDirections.push('Right');
				// get controls
				keyArray.wipeArray();
				#if debug
				keyArray.push(FlxKey.fromString('S'));
				keyArray.push(FlxKey.fromString('D'));
				keyArray.push(FlxKey.fromString('K'));
				keyArray.push(FlxKey.fromString('L'));
				#else
				keyArray.push(FlxKey.fromString('LEFT'));
				keyArray.push(FlxKey.fromString('DOWN'));
				keyArray.push(FlxKey.fromString('UP'));
				keyArray.push(FlxKey.fromString('RIGHT'));
				#end
		}
	}
}

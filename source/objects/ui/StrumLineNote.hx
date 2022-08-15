package objects.ui;

import flixel.math.FlxPoint;

typedef StrumLineNoteData =
{
	var scale:Int;
	var staticOffset:Array<Int>;
	var hitOffsetCyan:Array<Int>;
	var hitOffsetLime:Array<Int>;
	var hitOffsetPink:Array<Int>;
	var hitOffsetRed:Array<Int>;
	var pressedOffset:Array<Int>;
}

class StrumLineNote extends FunkySprite
{
	public var ogX:Float;
	public var ogY:Float;
	public var noteData:Int;

	public function new(x:Float, y:Float, noteData:Int, ?textureName:String = 'Strum Line Notes', ?textureJson:Null<StrumLineNoteData>)
	{
		super(x, y);
		this.ogX = x;
		this.ogY = y;
		this.noteData = noteData;
		reloadNote(textureName, textureJson);
		this.antialiasing = true;
	}

	public function reloadNote(?textureName:String = 'Strum Line Notes', ?textureJson:Null<StrumLineNoteData>)
	{
		if (textureJson == null)
			textureJson = {
				scale: 1,
				staticOffset: [0, 0],
				hitOffsetCyan: [27, 23],
				hitOffsetLime: [28, 26],
				hitOffsetPink: [28, 25],
				hitOffsetRed: [28, 25],
				pressedOffset: [13, 13]
			};
		scale.x = scale.y = SongNote.noteScaling * textureJson.scale;

		frames = Paths.sparrowV2('ui/notes/strumline/$textureName', 'shared');
		animation.addByPrefix('Static', 'Strum Note Static ${SongNote.noteColors[noteData % SongNote.noteColors.length]}', 24, true, false, false);
		animation.addByPrefix('Hit', 'Strum Note Hit ${SongNote.noteColors[noteData % SongNote.noteColors.length]}', 24, false, false, false);
		animation.addByPrefix('Pressed', 'Strum Note Pressed ${SongNote.noteColors[noteData % SongNote.noteColors.length]}', 24, false, false, false);
		animOffsets.set('Static', new FlxPoint(textureJson.staticOffset[0], textureJson.staticOffset[1]));
		switch (SongNote.noteColors[noteData % SongNote.noteColors.length])
		{
			case 'Lime':
				animOffsets.set('Hit', new FlxPoint(textureJson.hitOffsetLime[0], textureJson.hitOffsetLime[1]));
			case 'Pink':
				animOffsets.set('Hit', new FlxPoint(textureJson.hitOffsetPink[0], textureJson.hitOffsetPink[1]));
			case 'Red':
				animOffsets.set('Hit', new FlxPoint(textureJson.hitOffsetRed[0], textureJson.hitOffsetRed[1]));
			default:
				animOffsets.set('Hit', new FlxPoint(textureJson.hitOffsetCyan[0], textureJson.hitOffsetCyan[1]));
		}
		animOffsets.set('Pressed', new FlxPoint(textureJson.pressedOffset[0], textureJson.pressedOffset[1]));
		letGo();

		animation.finishCallback = function(anim:String)
		{
			if (anim != 'Static')
				letGo();
		};
	}

	public function hit()
	{
		playAnim('Hit', true);
	}

	public function press()
	{
		playAnim('Pressed', true);
	}

	public function letGo()
	{
		playAnim('Static', true);
	}
}

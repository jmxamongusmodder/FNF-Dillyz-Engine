package objects.characters;

import DillyzLogger.LogType;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import gamestates.editors.CharacterEditorState;
import rhythm.Conductor;

using StringTools;

typedef CharAnimData =
{
	var offset:Array<Int>;
	var indices:Array<Int>;
	var name:String;
	var prefix:String;
	var flipX:Bool;
	var flipY:Bool;
	var looped:Bool;
	var fps:Int;
}

typedef CharacterData =
{
	var animData:Array<CharAnimData>;
	var groundOffset:Array<Int>;
	var scale:Array<Float>;
	var sprPath:String;
	var sprType:String;
	var deadVariant:String;
	var flipX:Bool;
	var flipY:Bool;
	var antialiasing:Bool;
	var idleLoop:Array<String>;
	var holdTimer:Float;
}

class Character extends FunkySprite
{
	@:allow(CharacterEditorState)
	private var charData:CharacterData;

	private static var charAnimDefault:CharAnimData = {
		offset: [0, 0],
		indices: [0, 0],
		name: 'idle',
		prefix: 'BF idle dance',
		flipX: false,
		flipY: false,
		fps: 24,
		looped: false
	};
	private static var charDefault:CharacterData = {
		animData: [charAnimDefault],
		groundOffset: [0, 350],
		scale: [1.0, 1.0],
		sprPath: "characters/Boyfriend",
		sprType: "sparrow-v2",
		deadVariant: "deadVariant",
		flipX: false,
		flipY: false,
		antialiasing: true,
		idleLoop: ["idle"],
		holdTimer: 6.1
	};

	private var defPoint:FlxPoint;

	public var rightSide:Bool;
	public var isPlaying:Bool;
	public var gameOver:Bool;

	public var holdingControls:Bool = false;

	public var charName:String;

	public function new(x:Float, y:Float, charName:String, ?rightSide:Bool = false, ?isPlaying:Bool = false, ?gameOver:Bool = false)
	{
		super(x, y);
		defPoint = new FlxPoint(x, y);
		this.charName = charName;
		this.rightSide = rightSide;
		this.isPlaying = isPlaying;
		this.gameOver = gameOver;
		loadCharacter(charName);
	}

	override public function animationError(name:String, forced:Bool)
	{
		DillyzLogger.log('Animation for $charName called "$name" ${forced ? 'with' : 'without'} force not found!\n$charName\'s current sheet: ${charData.sprPath} as type ${charData.sprType}.',
			LogType.Warning);
	}

	override public function playAnim(name:String, ?forced:Bool = false)
	{
		holdTimer = Conductor.stepCrochet * charData.holdTimer * 0.001;
		super.playAnim(name, forced);
	}

	public var danceIndex:Int = 0;

	public var holdTimer:Float = 0;

	override public function update(e:Float)
	{
		super.update(e);

		holdTimer -= e;

		if ((!isPlaying || (isPlaying && !holdingControls)) && holdTimer <= 0 && holdTimer > -100000000)
		{
			dance(true);
			holdTimer = -100000000;

			// DillyzLogger.log('Doing forceful gay dance for $charName.', LogType.Normal);
		}
	}

	public function dance(?forced:Bool = false)
	{
		if (!charData.idleLoop.contains(getAnim()) && !forced)
			return;
		if (charData.idleLoop.length == 0)
		{
			DillyzLogger.log('Idle loop for $charName ${forced ? 'with' : 'without'} force not found!\n$charName\'s current sheet: ${charData.sprPath} as type ${charData.sprType}.',
				LogType.Warning);
			return;
		}
		if (danceIndex >= charData.idleLoop.length)
			danceIndex = 0;
		playAnim(charData.idleLoop[danceIndex], forced);
		holdTimer = -100000000;
		danceIndex++;
	}

	public function loadCharacter(charName:String, ?reloadSprite:Bool = true)
	{
		this.charName = charName;
		charData = Paths.json('${gameOver ? 'characters dead' : 'characters'}/$charName', null, charDefault);
		reloadChar(reloadSprite);
	}

	public function loadCharacterByData(charData:CharacterData, ?reloadSprite:Bool = true)
	{
		this.charData = charData;
		reloadChar(reloadSprite);
	}

	@:allow(CharacterEditorState)
	private function reloadChar(?reloadSprite:Bool = true)
	{
		this.flipX = false;
		this.flipY = false;
		// DillyzLogger.log(cast(charData), LogType.Normal);

		var animData:Array<CharAnimData> = charData.animData;

		DillyzLogger.log('Loading $charName from ${charData.sprPath} as type ${charData.sprType}.', LogType.Normal);
		// DillyzLogger.log('$charData.', LogType.Normal);

		// haxeflixel fix ur clear() function >:(((((((((
		var dirtBlockValues:Array<String> = [];
		for (i in animOffsets.keys())
			dirtBlockValues.push(i);
		for (i in dirtBlockValues)
			animOffsets.remove(i);

		switch (charData.sprType)
		{
			// sparrow v2
			default:
				if (reloadSprite || frames == null)
					frames = Paths.sparrowV2(charData.sprPath, 'shared');

				DillyzLogger.log('Loading $charName from ${charData.sprPath} as type ${charData.sprType}.', LogType.Normal);

				for (i in animData)
				{
					if (i.indices.length == 0)
						this.animation.addByPrefix(i.name, i.prefix + '0', i.fps, i.looped, i.flipX, i.flipY);
					else
						this.animation.addByIndices(i.name, i.prefix + '0', i.indices, "", i.fps, i.looped, i.flipX, i.flipY);

					animOffsets.set(i.name, new FlxPoint(i.offset[0], i.offset[1]));
				}
		}

		this.x += charData.groundOffset[0];
		this.y += charData.groundOffset[1];
		this.scale.x = charData.scale[0];
		this.scale.y = charData.scale[1];
		this.flipX = charData.flipX;
		this.flipY = charData.flipY;
		this.antialiasing = charData.antialiasing;

		if (rightSide)
			this.flipX = !this.flipX;

		if (charData.idleLoop.length >= 1)
			playAnim(charData.idleLoop[0], true);
	}
}

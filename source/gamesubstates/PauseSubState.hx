package gamesubstates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import gamestates.MusicBeatState;
import gamestates.PlayState;
import gamestates.editors.CharacterEditorState;
import gamestates.menus.MainMenuState;
import objects.ui.Alphabet;
import rhythm.Conductor;

using DillyzUtil;

class PauseSubState extends MusicBeatSubState
{
	private var bg:FlxSprite;

	private static var options:Array<String> = ['Resume Song', 'Restart Song', 'Character Editor', 'Exit To Menu'];

	public static var optionInstances:Array<Alphabet>;

	public static function initOptions()
	{
		if (optionInstances == null)
		{
			trace('optionInstances was null lmao');
			optionInstances = new Array<Alphabet>();

			for (i in options)
			{
				var newOptions:Alphabet = new Alphabet(0, 0, i);
				optionInstances.push(newOptions);
				// add(newOptions);
			}
		}
		else
			trace('optionInstances wasn\'t null lmao');
	}

	override public function create()
	{
		super.create();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		bg.cameras = [newHUD];
		bg.alpha = 0.5;

		initOptions();

		for (i in optionInstances)
		{
			add(i);
			i.cameras = [newHUD];

			i.x = i.y = 0;
			i.visible = i.active = true;
		}

		changeSelection();

		FlxG.sound.music.pause();
		@:privateAccess {
			cast(MusicBeatState.instance, PlayState).voices.pause();
		}
	}

	public var overrideState:Class<MusicBeatState> = MusicBeatState;
	public var overrideTranstion:FunkinTransitionType = Black;

	private function selectOption()
	{
		switch (optionInstances[curIndex].text)
		{
			case 'Restart Song':
				overrideState = PlayState;
				overrideTranstion = Normal;
			case 'Character Editor':
				overrideState = CharacterEditorState;
				overrideTranstion = Normal;
			case 'Exit To Menu':
				overrideState = MainMenuState;
				overrideTranstion = Black;
		}
		killSelf();

		FlxG.sound.play(Paths.sound('menus/confirmMenu', null));

		var selectOverlay = new FlxSprite().loadGraphic(Paths.png('menus/selectOverlay', null));
		selectOverlay.antialiasing = true;
		add(selectOverlay);
		selectOverlay.cameras = [newHUD];
	}

	override public function update(e:Float)
	{
		super.update(e);

		for (i in 0...optionInstances.length)
		{
			var curOption:Alphabet = optionInstances[i];
			var intendedMulti:Int = i - curIndex;
			var intY:Float = FlxG.height / 2 - 30 + (165 * intendedMulti);
			var intX:Float = 240 + (-165 * Math.abs(intendedMulti));
			var intAlpha:Float = (1 - (Math.abs(intendedMulti) / 3.25)).snapFloat(0, 1);

			curOption.y = FlxMath.lerp(intY, curOption.y, e * 114);
			curOption.x = FlxMath.lerp(intX + 175, curOption.x, e * 114);
			curOption.alpha = FlxMath.lerp(intAlpha, curOption.alpha, e * (114 * 0.65));

			#if debug
			if (FlxG.keys.justPressed.ONE)
				trace('$i ${curOption.text} $intX $intY $intAlpha');
			#end
		}

		if (!controlsReady)
			return;

		if (FlxG.keys.justPressed.ESCAPE)
			killSelf();
		else if (FlxG.keys.justPressed.ENTER)
			selectOption();
		else if (FlxG.keys.justPressed.UP)
			changeSelection(-1);
		else if (FlxG.keys.justPressed.DOWN)
			changeSelection(1);
	}

	public var curIndex:Int = 0;

	public function changeSelection(?amount:Int = 0)
	{
		if (amount != 0)
		{
			curIndex += amount;
			// curIndex = curIndex.snapInt(0, options.length - 1);
			if (curIndex < 0)
				curIndex = optionInstances.length - 1;
			else if (curIndex >= optionInstances.length)
				curIndex = 0;

			FlxG.sound.play(Paths.sound('menus/scrollMenu', null));
		}
	}

	override public function trulyEndState()
	{
		@:privateAccess {
			var playState = cast(MusicBeatState.instance, PlayState);
			if (optionInstances[curIndex].text == 'Resume Song')
			{
				FlxG.sound.music.resume();
				playState.voices.resume();
				Conductor.songPosition = playState.voices.time = FlxG.sound.music.time;
			}
			else
				playState.endSong(overrideState, overrideTranstion);
		}
		if (optionInstances != null)
			for (i in optionInstances)
				remove(i);
		super.trulyEndState();
	}
}

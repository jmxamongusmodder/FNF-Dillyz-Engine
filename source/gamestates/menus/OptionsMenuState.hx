package gamestates.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxMath;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gamestates.MusicBeatState.FunkinTransitionType;
import managers.PreferenceManager;
import objects.FunkyText;
import objects.ui.Alphabet;
import objects.ui.Options;

using DillyzUtil;

enum OptionType
{
	Bool;
	Int;
	Float;
	String;
	Keybind;
	Category;
}

typedef OptionData =
{
	var name:String;
	var type:OptionType;
	var saveValue:String;
}

class OptionsMenuState extends MusicBeatState
{
	// private var bgFlash:FlxSprite;
	private var funnyBG:FlxSprite;
	private var funnyBGAlt:FlxSprite;
	private var funnyGayText:FunkyText;

	private var curIndex:Int;

	private var optionArray:Array<OptionBase>;

	private static var optionArrayData:Array<OptionData> = [
		{
			name: 'Keybinds (4K)',
			type: OptionType.Category,
			saveValue: null
		},
		{
			name: 'Left Bind',
			type: OptionType.Keybind,
			saveValue: '4k_bindLeft'
		},
		{
			name: 'Down Bind',
			type: OptionType.Keybind,
			saveValue: '4k_bindDown'
		},
		{
			name: 'Up Bind',
			type: OptionType.Keybind,
			saveValue: '4k_bindUp'
		},
		{
			name: 'Right Bind',
			type: OptionType.Keybind,
			saveValue: '4k_bindRight'
		},
		{
			name: 'Visuals',
			type: OptionType.Category,
			saveValue: null
		},
		{
			name: 'Antialising',
			type: OptionType.Bool,
			saveValue: 'antialiasing'
		}
	];

	override public function create()
	{
		super.create();

		funnyBG = new FlxSprite().loadGraphic(Paths.png('menus/menuBG_orange'));
		funnyBG.antialiasing = managers.PreferenceManager.antialiasing;
		// funnyBG.color = FlxColor.fromRGB(253, 232, 113, 255);
		add(funnyBG);

		funnyBGAlt = new FlxSprite().loadGraphic(Paths.png('menus/menuBG_blue'));
		funnyBGAlt.antialiasing = managers.PreferenceManager.antialiasing;
		funnyBGAlt.visible = false;
		// funnyBG.color = FlxColor.fromRGB(253, 232, 113, 255);
		add(funnyBGAlt);

		/*bgFlash = new FlxSprite(-1280, -720).makeGraphic(1280 * 3, 720 * 3, FlxColor.WHITE);
			bgFlash.PreferenceManager.antialiasing;
			bgFlash.alpha = 0; */
		// funnyBG.color = FlxColor.fromRGB(253, 232, 113, 255);

		funnyGayText = new FunkyText(FlxG.width / 2 - 60, FlxG.height - 2 - 40, 0, MainMenuState.gayWatermark, 16);
		funnyGayText.setFormat(Paths.font('vcr'), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		funnyGayText.borderSize = 1;
		add(funnyGayText);
		funnyGayText.cameras = [camHUD];
		funnyGayText.screenCenter(X);
		// funnyGayText.x += 35;
		funnyGayText.antialiasing = managers.PreferenceManager.antialiasing;

		// add(bgFlash);
		// bgFlash.cameras = [camHUD];

		optionArray = new Array<OptionBase>();
		for (i in 0...optionArrayData.length)
		{
			var newOptions:OptionData = optionArrayData[i];
			var newOption:OptionBase;
			switch (newOptions.type)
			{
				case OptionType.Category:
					newOption = new CategoryOption(0, i * 75, newOptions.name, newOptions.saveValue);
				case OptionType.Keybind:
					var defBindOpt:String = '';
					switch (newOptions.saveValue)
					{
						case '4k_bindLeft':
							defBindOpt = PreferenceManager.keybinds_4k[0];
						case '4k_bindDown':
							defBindOpt = PreferenceManager.keybinds_4k[1];
						case '4k_bindUp':
							defBindOpt = PreferenceManager.keybinds_4k[2];
						case '4k_bindRight':
							defBindOpt = PreferenceManager.keybinds_4k[3];
					}
					newOption = new KeybindOption(0, i * 75, newOptions.name, newOptions.saveValue, defBindOpt);
				case OptionType.Bool:
					var defBoolOpt:Bool = false;
					if (newOptions.saveValue == 'antialiasing')
						defBoolOpt = PreferenceManager.antialiasing;
					newOption = new BooleanOption(0, i * 75, newOptions.name, newOptions.saveValue, defBoolOpt);
				default:
					newOption = new OptionBase(0, i * 75, newOptions.name, newOptions.saveValue);
			}
			newOption.updateValue();
			add(newOption);
			optionArray.push(newOption);
		}

		curIndex = 0;
		changeSelection();

		/*selectOverlay = new FlxSprite().loadGraphic(Paths.png('menus/selectOverlay'));
			selectOverlay.PreferenceManager.antialiasing;
			selectOverlay.alpha = 0;
			add(selectOverlay);
			selectOverlay.cameras = [camHUD]; */

		postCreate();
	}

	public function changeSelection(?amount:Int = 0, ?wasForced:Bool = false)
	{
		if (amount != 0)
		{
			curIndex += amount;
			// curIndex = curIndex.snapInt(0, options.length - 1);
			if (curIndex < 0)
				curIndex = optionArray.length - 1;
			else if (curIndex >= optionArray.length)
				curIndex = 0;

			if (!wasForced)
				FlxG.sound.play(Paths.sound('menus/scrollMenu', null));
		}

		if (!wasForced)
			trace(optionArray[curIndex].text);

		if (optionArray[curIndex].realType == 'Category')
			changeSelection(amount == 0 ? 1 : amount, true);
	}

	private var stopSpamming:Bool = false;

	private var enterTypes:Array<String> = ['Keybind', 'String', 'Bool'];

	override public function update(e:Float)
	{
		super.update(e);

		for (i in 0...optionArray.length)
		{
			var curOption:Alphabet = optionArray[i];
			var intendedMulti:Int = i - curIndex;
			var intY:Float = FlxG.height / 2 - 30 + (165 * intendedMulti);
			var intX:Float = 240 + (-165 * Math.abs(intendedMulti));
			var intAlpha:Float = (1 - (Math.abs(intendedMulti) / 3.25)).snapFloat(0, 1);
			curOption.y = FlxMath.lerp(intY, curOption.y, e * 114);
			curOption.x = FlxMath.lerp(intX, curOption.x, e * 114);
			curOption.alpha = FlxMath.lerp(intAlpha, curOption.alpha, e * (114 * 0.65));

			// curOption.x = FlxMath.lerp(intX, curOption.x, e * 144);
			#if debug
			if (FlxG.keys.justPressed.ONE)
				trace('$i ${curOption.text} $intX $intY $intAlpha');
			#end
			// curOption.alpha = FlxMath.lerp(intendedMulti / 4, curOption.alpha, e * 28.5);

			/* var curOption:Alphabet = optionArray[i];
				var intendedMulti:Int = i - curIndex;
				var intX:Float = FlxG.height / 2 - 30 + (125 * intendedMulti);
				var intY:Float = 240 + (-50 * Math.abs(intendedMulti));
				curOption.y = FlxMath.lerp(intX, curOption.y, e * 114);
				// four hundreed and eight peas reference!!!!!
				curOption.x = FlxMath.lerp(intY, curOption.x, e * 144);9
				// curOption.alpha = FlxMath.lerp(1 - (intendedMulti / 4), curOption.alpha, e * 576);

				if (FlxG.keys.justPressed.ONE)
				{
					trace('$i $intX $intY ${1 - (intendedMulti / 4)}');
			}*/
		}

		if (stopSpamming)
			return;

		if (FlxG.keys.justPressed.ESCAPE)
		{
			stopSpamming = true;
			FlxG.sound.play(Paths.sound('menus/cancelMenu', null), 1.25);
			switchState(MainMenuState, [], false, FunkinTransitionType.Black);
		}
		else if (FlxG.keys.justPressed.ENTER && enterTypes.contains(optionArray[curIndex].realType))
		{
			// if (optionArray[curIndex].realType != 'Category')
			// {
			// FlxG.sound.play(Paths.sound('menus/confirmMenu', null));
			// stopSpamming = true;
			// FlxFlicker.flicker(funnyBGAlt, 1.1, 0.15, false);
			// bgFlash.alpha = 0.8;
			// FlxTween.tween(bgFlash, {alpha: 0}, 0.5, {ease: FlxEase.cubeInOut});
			// camHUD.flash(FlxColor.WHITE, 0.5);

			// trace(optionArray[curIndex].baseName);
			// trace(optionArray[curIndex].saveValue);

			switch (optionArray[curIndex].realType)
			{
				case 'Bool':
					var boolOpt:BooleanOption = cast(optionArray[curIndex], BooleanOption);
					boolOpt.boolValue = !boolOpt.boolValue;

					if (optionArray[curIndex].saveValue == 'antialiasing')
						PreferenceManager.antialiasing = boolOpt.boolValue;
			}

			optionArray[curIndex].updateValue();
			camGame.zoom += 0.01;
			FlxG.sound.play(Paths.sound('menus/scrollMenu', null));
			PreferenceManager.save();
			// }
		}
		else if (FlxG.keys.justPressed.UP)
			changeSelection(-1);
		else if (FlxG.keys.justPressed.DOWN)
			changeSelection(1);
	}
}

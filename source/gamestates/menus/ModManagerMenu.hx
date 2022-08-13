package gamestates.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxMath;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gamestates.MusicBeatState.FunkinTransitionType;
import objects.FunkyText;
import objects.ui.Alphabet;
import sys.FileSystem;

using DillyzUtil;

class ModManagerMenu extends MusicBeatState
{
	private var bgFlash:FlxSprite;
	private var funnyBG:FlxSprite;
	private var funnyBGAlt:FlxSprite;
	private var funnyGayText:FunkyText;
	var optionArray:Array<Alphabet>;

	private var curIndex:Int;

	override public function create()
	{
		super.create();

		funnyBG = new FlxSprite().loadGraphic(Paths.png('menus/menuBG_blue'));
		funnyBG.antialiasing = true;
		// funnyBG.color = FlxColor.fromRGB(253, 232, 113, 255);
		add(funnyBG);

		funnyBGAlt = new FlxSprite().loadGraphic(Paths.png('menus/menuBG_lime'));
		funnyBGAlt.antialiasing = true;
		funnyBGAlt.visible = false;
		// funnyBG.color = FlxColor.fromRGB(253, 232, 113, 255);
		add(funnyBGAlt);

		bgFlash = new FlxSprite(-1280, -720).makeGraphic(1280 * 3, 720 * 3, FlxColor.WHITE);
		bgFlash.antialiasing = true;
		bgFlash.alpha = 0;
		// funnyBG.color = FlxColor.fromRGB(253, 232, 113, 255);

		funnyGayText = new FunkyText(FlxG.width / 2 - 60, FlxG.height - 2 - 40, 0, MainMenuState.gayWatermark, 16);
		funnyGayText.setFormat(Paths.font('vcr'), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		funnyGayText.borderSize = 1;
		add(funnyGayText);
		funnyGayText.cameras = [camHUD];
		funnyGayText.screenCenter(X);
		// funnyGayText.x += 35;
		funnyGayText.antialiasing = true;

		add(bgFlash);
		bgFlash.cameras = [camHUD];

		var fileList:Array<String> = FileSystem.readDirectory('./mods/');
		optionArray = new Array<Alphabet>();
		for (i in 0...fileList.length)
		{
			trace(fileList[i]);
			var newAlphabet:Alphabet = new Alphabet(0, i * 75, fileList[i]);
			add(newAlphabet);
			optionArray.push(newAlphabet);
		}

		curIndex = 0;
		changeSelection();

		postCreate();
	}

	public function changeSelection(?amount:Int = 0)
	{
		if (amount != 0)
		{
			curIndex += amount;
			// curIndex = curIndex.snapInt(0, options.length - 1);
			if (curIndex < 0)
				curIndex = optionArray.length - 1;
			else if (curIndex >= optionArray.length)
				curIndex = 0;

			FlxG.sound.play(Paths.sound('menus/scrollMenu', null));
		}

		trace(optionArray[curIndex].text);
	}

	private var stopSpamming:Bool = false;

	override public function update(e:Float)
	{
		for (i in 0...optionArray.length)
		{
			var curOption:Alphabet = optionArray[i];
			var intendedMulti:Int = i - curIndex;
			var intX:Float = 240 + (-125 * Math.abs(intendedMulti));
			var intY:Float = FlxG.height / 2 - 30 + (125 * intendedMulti);
			var intAlpha:Float = (1 - (Math.abs(intendedMulti) / 3.2)).snapFloat(0, 1);
			curOption.y = FlxMath.lerp(intY, curOption.y, e * 114);
			curOption.alpha = FlxMath.lerp(intAlpha, curOption.alpha, e * (114 * 0.8));

			// curOption.x = FlxMath.lerp(intX, curOption.x, e * 144);
			if (FlxG.keys.justPressed.ONE)
				trace('$i ${curOption.text} $intX $intY $intAlpha');
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

		super.update(e);
		if (stopSpamming)
			return;

		if (FlxG.keys.justPressed.ESCAPE)
		{
			stopSpamming = true;
			FlxG.sound.play(Paths.sound('menus/cancelMenu', null), 1.25);
			switchState(MainMenuState, [], false, FunkinTransitionType.Black);
		}
		else if (FlxG.keys.justPressed.ENTER)
		{
			stopSpamming = true;
			FlxG.sound.play(Paths.sound('menus/confirmMenu', null));
			FlxFlicker.flicker(funnyBGAlt, 1.1, 0.15, false);
			bgFlash.alpha = 0.5;
			FlxTween.tween(bgFlash, {alpha: 0}, 0.5, {ease: FlxEase.cubeInOut});

			new FlxTimer().start(1.5, function(t:FlxTimer)
			{
				FlxG.sound.music.fadeOut(0.5);
				switchState(MainMenuState, [], true, FunkinTransitionType.Normal);
			});
		}
		else if (FlxG.keys.justPressed.UP)
			changeSelection(-1);
		else if (FlxG.keys.justPressed.DOWN)
			changeSelection(1);
	}
}

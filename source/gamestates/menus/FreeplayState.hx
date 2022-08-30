package gamestates.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.FlxGraphic;
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
import objects.ui.health.HealthIcon;
import openfl.display.BitmapData;
import openfl.media.Sound;
import sys.FileSystem;
import sys.io.File;

using DillyzUtil;
using StringTools;

typedef WeekSongData =
{
	var name:String;
	var icon:String;
	var bgColor:Array<Int>;
	var hiddenFromFreeplay:Bool;
	var hiddenFromStory:Bool;
}

typedef WeekData =
{
	var songs:Array<WeekSongData>;
}

class FreeplayState extends MusicBeatState
{
	// private var bgFlash:FlxSprite;
	private var funnyBG:FlxSprite;
	private var funnyBGAlt:FlxSprite;
	private var funnyGayText:FunkyText;
	var optionArray:Array<Alphabet>;
	var iconArray:Array<HealthIcon>;

	private var curIndex:Int;

	override public function create()
	{
		super.create();

		funnyBG = new FlxSprite().loadGraphic(Paths.png('menus/menuBG_blue'));
		funnyBG.antialiasing = managers.PreferenceManager.antialiasing;
		// funnyBG.color = FlxColor.fromRGB(253, 232, 113, 255);
		add(funnyBG);

		funnyBGAlt = new FlxSprite().loadGraphic(Paths.png('menus/menuBG_lime'));
		funnyBGAlt.antialiasing = managers.PreferenceManager.antialiasing;
		funnyBGAlt.visible = false;
		// funnyBG.color = FlxColor.fromRGB(253, 232, 113, 255);
		add(funnyBGAlt);

		/*bgFlash = new FlxSprite(-1280, -720).makeGraphic(1280 * 3, 720 * 3, FlxColor.WHITE);
			bgFlash.antialiasing = managers.PreferenceManager.antialiasing ;
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

		trace('holy crap lois, i\'m in a debug build!');
		optionArray = new Array<Alphabet>();
		iconArray = new Array<HealthIcon>();

		// add(bgFlash);
		// bgFlash.cameras = [camHUD];
		var newAlphabet:Alphabet = new Alphabet(0, 0, 'Tutorial');
		add(newAlphabet);
		optionArray.push(newAlphabet);

		var newIcon:HealthIcon = new HealthIcon(0, 0, 'girlfriend', false);
		add(newIcon);
		iconArray.push(newIcon);

		var fileList:Array<String> = FileSystem.readDirectory('./assets/weeks/');
		for (u in 0...fileList.length)
		{
			var dynamWeek = Paths.weekJson(fileList[u].replace('.json', ''), null, {
				songs: [
					{
						name: "tutorial 2",
						icon: "divorce",
						bgColors: [0, 0, 0],
						hiddenFromFreeplay: false,
						hiddenFromStory: false
					}
				]
			});
			trace(dynamWeek);
			var curWeekData:WeekData = cast dynamWeek;
			trace(curWeekData);
			trace(fileList[u]);
			for (i in curWeekData.songs)
			{
				// if (!i.hiddenFromFreeplay)
				// {
				var newAlphabet:Alphabet = new Alphabet(0, 0, i.name);
				add(newAlphabet);
				optionArray.push(newAlphabet);

				var newIcon:HealthIcon = new HealthIcon(0, 0, i.icon, false);
				add(newIcon);
				iconArray.push(newIcon);
				// }
			}
		}
		if (Paths.curMod != '' && FileSystem.exists('./mods/${Paths.curMod}/weeks/'))
		{
			var fileListMods:Array<String> = FileSystem.readDirectory('./mods/${Paths.curMod}/weeks/');
			for (u in 0...fileListMods.length)
			{
				var curWeekData:WeekData = Paths.weekJson(fileListMods[u].replace('.json', ''), null, {songs: []});
				trace(curWeekData);
				trace(fileListMods[u]);
				for (i in curWeekData.songs)
				{
					// if (!i.hiddenFromFreeplay)
					// {
					var newAlphabet:Alphabet = new Alphabet(0, 0, i.name);
					add(newAlphabet);
					optionArray.push(newAlphabet);

					var newIcon:HealthIcon = new HealthIcon(0, 0, i.icon, false);
					add(newIcon);
					iconArray.push(newIcon);
					// }
				}
			}
		}

		curIndex = 0;
		changeSelection();

		/*selectOverlay = new FlxSprite().loadGraphic(Paths.png('menus/selectOverlay'));
			selectOverlay.antialiasing = managers.PreferenceManager.antialiasing ;
			selectOverlay.alpha = 0;
			add(selectOverlay);
			selectOverlay.cameras = [camHUD]; */

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
		super.update(e);

		for (i in 0...optionArray.length)
		{
			var curOption:Alphabet = optionArray[i];
			var curIcon:HealthIcon = iconArray[i];
			var intendedMulti:Int = i - curIndex;
			var intY:Float = FlxG.height / 2 - 30 + (165 * intendedMulti);
			var intX:Float = 240 + (-165 * Math.abs(intendedMulti));
			var intAlpha:Float = (1 - (Math.abs(intendedMulti) / 3.25)).snapFloat(0, 1);

			curOption.y = FlxMath.lerp(intY, curOption.y, e * 114);
			curOption.x = FlxMath.lerp(intX + 175, curOption.x, e * 114);
			curOption.alpha = FlxMath.lerp(intAlpha, curOption.alpha, e * (114 * 0.65));

			curIcon.y = FlxMath.lerp(intY - 35, curIcon.y, e * 114);
			curIcon.x = FlxMath.lerp(intX, curIcon.x, e * 114);
			curIcon.alpha = FlxMath.lerp(intAlpha, curIcon.alpha, e * (114 * 0.65));

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
		else if (FlxG.keys.justPressed.ENTER)
		{
			// FlxG.sound.play(Paths.sound('menus/confirmMenu', null));
			stopSpamming = true;
			FlxFlicker.flicker(funnyBGAlt, 1.1, 0.15, false);
			// bgFlash.alpha = 0.8;
			// FlxTween.tween(bgFlash, {alpha: 0}, 0.5, {ease: FlxEase.cubeInOut});
			camHUD.flash(FlxColor.WHITE, 0.5);

			PlayState.loadFromChartEditorInstead = false;
			PlayState.cameFromFreeplay = true;
			PlayState.songToLoad = optionArray[curIndex].text;
			PlayState.diffToLoad = 'Hard';

			// thisis cooler bc it plays the custom sound and shows your custom sprite
			FlxG.sound.play(Paths.sound('menus/confirmMenu', null));

			var selectOverlay = new FlxSprite().loadGraphic(Paths.png('menus/selectOverlay', null));
			selectOverlay.antialiasing = managers.PreferenceManager.antialiasing;
			add(selectOverlay);
			selectOverlay.cameras = [camHUD];

			new FlxTimer().start(1.5, function(t:FlxTimer)
			{
				FlxG.sound.music.fadeOut(0.5);
				switchState(PlayState, [], true, FunkinTransitionType.Normal);
			});
		}
		else if (FlxG.keys.justPressed.UP)
			changeSelection(-1);
		else if (FlxG.keys.justPressed.DOWN)
			changeSelection(1);
	}
}

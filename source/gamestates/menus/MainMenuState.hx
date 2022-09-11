package gamestates.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gamestates.MusicBeatState.FunkinTransitionType;
import managers.BGMusicManager;
import objects.FunkySprite;
import objects.FunkyText;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;

using DillyzUtil;

typedef MenuButtonOffset =
{
	var parentAnim:String;
	var x:Int;
	var y:Int;
}

typedef MenuButtonJson =
{
	var posOffset:Array<Int>;
	var animOffsets:Array<MenuButtonOffset>;
}

class MenuButtonThing extends FunkySprite
{
	public var menuButtonName:String;
	public var posOffset:FlxPoint;

	public function new(menuButtonName:String, posOffset:FlxPoint)
	{
		super(0, 400);
		this.menuButtonName = menuButtonName;
		this.posOffset = posOffset;
	}
}

class MainMenuState extends MusicBeatState
{
	private var funnyBG:FlxSprite;
	private var funnyBGAlt:FlxSprite;

	private var funnyGayText:FunkyText;

	// HEY!!!!
	// If you're modding the engine, do NOT change this!
	// Modding someone else's engine does not mean you made one!
	// I mean, imagine that from my perspective. I spend weeks writing this engine and you just discredit it for 5 edits you did?
	// Instead, just add another line like this: 'Bruh Additions 1.0.0\nDillyz Engine 0.0.7\nFriday Night Funkin\' (Assets Only) 0.2.8\n'
	// If you do discredit my work for your minimal programming, I WILL request that you add it back or take your """"engine"""" down for lack of co-operation.
	public static var gayWatermark(default, never):String = 'Dillyz Engine 0.0.7\nFriday Night Funkin\' (Assets Only) 0.2.8\n';

	private var options:Array<String> = ['Story Mode', 'Freeplay', 'Options', 'Donate', 'Mods', #if debug 'Debug' #end];
	private var optionDisplay:Array<MenuButtonThing>;
	private var curIndex:Int;

	#if KONAMI_CODE_SECRET
	private var konamiCodeControls:Array<FlxKey> = [
		FlxKey.UP, FlxKey.UP, FlxKey.DOWN, FlxKey.DOWN, FlxKey.LEFT, FlxKey.RIGHT, FlxKey.LEFT, FlxKey.RIGHT, FlxKey.B, FlxKey.A
	];
	private var konamiCodeIndex:Int = 0;

	private static var konamiCodeComplete:Bool = false;
	#end

	public function menuButtonJsonDefault():MenuButtonJson
	{
		return {
			posOffset: [0, 0],
			animOffsets: [{parentAnim: "static", x: 0, y: 0}, {parentAnim: "hover", x: 0, y: 0}]
		};
	}

	var bgFlash:FlxSprite;

	public static var reloadingMod:Bool = false;

	override public function create()
	{
		super.create();

		if (FlxG.sound == null || FlxG.sound.music == null || !FlxG.sound.music.playing || reloadingMod)
		{
			BGMusicManager.play('freakyMenu', 102);
			reloadingMod = true;
		}

		funnyBG = new FlxSprite().loadGraphic(Paths.png('menus/menuBG_yellow'));
		funnyBG.antialiasing = managers.PreferenceManager.antialiasing;
		// funnyBG.color = FlxColor.fromRGB(253, 232, 113, 255);
		add(funnyBG);

		funnyBGAlt = new FlxSprite().loadGraphic(Paths.png('menus/menuBG_magenta'));
		funnyBGAlt.antialiasing = managers.PreferenceManager.antialiasing;
		funnyBGAlt.visible = false;
		// funnyBG.color = FlxColor.fromRGB(253, 232, 113, 255);
		add(funnyBGAlt);

		bgFlash = new FlxSprite(-1280, -720).makeGraphic(1280 * 3, 720 * 3, FlxColor.WHITE);
		bgFlash.antialiasing = managers.PreferenceManager.antialiasing;
		bgFlash.alpha = 0;
		// funnyBG.color = FlxColor.fromRGB(253, 232, 113, 255);

		curCamZoom = 1.0075;

		optionDisplay = new Array<MenuButtonThing>();
		// add(optionDisplay);

		for (i in 0...options.length)
		{
			var optionJson:MenuButtonJson = menuButtonJsonDefault();
			optionJson = Paths.menuButtonJson(options[i], optionJson);
			// trace(optionJson);
			var newMenuOption:MenuButtonThing = new MenuButtonThing(options[i], new FlxPoint(optionJson.posOffset[0], optionJson.posOffset[1]));
			newMenuOption.frames = Paths.sparrowV2('menus/main menu buttons/${options[i]}', null);
			newMenuOption.animation.addByPrefix('static', '${options[i]} Static0', 24, true, false, false);
			newMenuOption.animation.addByPrefix('hover', '${options[i]} Hover0', 24, true, false, false);
			for (i in optionJson.animOffsets)
				newMenuOption.animOffsets.set(i.parentAnim, new FlxPoint(i.x, i.y));
			// trace(optionJson.animOffsets);
			// trace(newMenuOption.animOffsets);
			newMenuOption.playAnim(i == 0 ? 'hover' : 'static', true);
			add(newMenuOption);
			optionDisplay.push(newMenuOption);
			newMenuOption.antialiasing = managers.PreferenceManager.antialiasing;

			newMenuOption.x = ((FlxG.width / 2) - (newMenuOption.width / 2)) + newMenuOption.posOffset.x + 60;
		}

		curIndex = 0;
		changeSelection();

		funnyGayText = new FunkyText(FlxG.width / 2 - 60, FlxG.height - 2 - 40, 0, gayWatermark, 16);
		funnyGayText.setFormat(Paths.font('vcr'), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		funnyGayText.borderSize = 1;
		add(funnyGayText);
		funnyGayText.cameras = [camHUD];
		funnyGayText.screenCenter(X);
		// funnyGayText.x += 20;
		funnyGayText.antialiasing = managers.PreferenceManager.antialiasing;

		add(bgFlash);
		bgFlash.cameras = [camHUD];

		postCreate();
	}

	public function changeSelection(?amount:Int = 0)
	{
		if (amount != 0)
		{
			curIndex += amount;
			// curIndex = curIndex.snapInt(0, options.length - 1);
			if (curIndex < 0)
				curIndex = options.length - 1;
			else if (curIndex >= options.length)
				curIndex = 0;

			FlxG.sound.play(Paths.sound('menus/scrollMenu', null));
		}

		for (i in 0...options.length)
		{
			var curOption:MenuButtonThing = optionDisplay[i];
			var intendedAnim:String = (curIndex == i) ? 'hover' : 'static';
			if (amount != 0 && intendedAnim != curOption.getAnim())
				curOption.playAnim(intendedAnim, true);
		}

		trace(options[curIndex]);
	}

	public var stopSpamming:Bool = false;

	override public function update(e:Float)
	{
		super.update(e);

		for (i in 0...options.length)
		{
			var curOption:MenuButtonThing = optionDisplay[i];
			var intendedMulti:Int = i;
			if (curIndex >= 2)
				intendedMulti = (i - curIndex) + 2;
			curOption.y = FlxMath.lerp(85 + (135 * intendedMulti), curOption.y - curOption.posOffset.y, e * 114) + curOption.posOffset.y;
		}

		if (stopSpamming)
			return;

		#if KONAMI_CODE_SECRET
		if (!konamiCodeComplete)
		{
			if (FlxG.keys.anyJustPressed([konamiCodeControls[konamiCodeIndex]]))
			{
				konamiCodeIndex++;

				if (konamiCodeControls.length == konamiCodeIndex)
				{
					// konamiCodeComplete = stopSpamming = true;
					konamiCodeIndex = 0;
					FlxG.openURL('https://www.youtube.com/watch?v=dQw4w9WgXcQ');
				}
			}
			else if (FlxG.keys.justPressed.ANY)
				konamiCodeIndex = 0;
		}
		#end

		if (FlxG.keys.justPressed.ENTER)
		{
			stopSpamming = true;
			FlxG.sound.play(Paths.sound('menus/confirmMenu', null));

			FlxFlicker.flicker(funnyBGAlt, 1.1, 0.15, false);
			bgFlash.alpha = 0.5;
			FlxTween.tween(bgFlash, {alpha: 0}, 0.5, {ease: FlxEase.cubeInOut});

			for (i in 0...options.length)
			{
				var curOption:MenuButtonThing = optionDisplay[i];
				if (curIndex != i)
					FlxTween.tween(curOption, {alpha: 0, "scale.x": 0.85, "scale.y": 0.85}, 0.5, {ease: FlxEase.cubeInOut});
				// curOption.alpha = 0;
			}

			new FlxTimer().start(1.5, function(t:FlxTimer)
			{
				switch (optionDisplay[curIndex].menuButtonName)
				{
					case 'Story Mode':
						switchState(StoryMenuState, [], false, FunkinTransitionType.Normal);
					case 'Freeplay':
						switchState(FreeplayState, [], false, FunkinTransitionType.Black);
					case 'Options':
						switchState(OptionsMenuState, [], false, FunkinTransitionType.Black);
					case 'Donate':
						FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
						switchState(MainMenuState, [], false, FunkinTransitionType.Black);
					case 'Mods':
						switchState(ModManagerMenu, [], false, FunkinTransitionType.Black);
					#if debug
					case 'Debug':
						// var nullSpr:FlxSprite = null;
						// nullSpr.clone();
						switchState(DebugMenu, [], false, FunkinTransitionType.Black);
					#end
					// switchState(MainMenuState, [], false, FunkinTransitionType.Black);
					default:
						Sys.exit(0);
				}
			}, 0);
		}
		else if (FlxG.keys.justPressed.UP)
			changeSelection(-1);
		else if (FlxG.keys.justPressed.DOWN)
			changeSelection(1);
		else if (FlxG.keys.justPressed.ESCAPE)
			switchState(TitleScreenState, [], false, FunkinTransitionType.Black);
	}

	override public function beatHit()
	{
		if (curBeat % 2 == 0)
			FlxG.camera.zoom = 1.015;
		else
			FlxG.camera.zoom = 1;
	}
}

package gamestates.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gamestates.MusicBeatState.FunkinTransitionType;
import objects.FunkyText;

class ModManagerMenu extends MusicBeatState
{
	private var bgFlash:FlxSprite;
	private var funnyBG:FlxSprite;
	private var funnyBGAlt:FlxSprite;
	private var funnyGayText:FunkyText;

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
		funnyGayText.x += 35;
		funnyGayText.antialiasing = true;

		add(bgFlash);
		bgFlash.cameras = [camHUD];

		postCreate();
	}

	private var stopSpamming:Bool = false;

	override public function update(e:Float)
	{
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
	}
}

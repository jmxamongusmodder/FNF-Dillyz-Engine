package gamestates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gamestates.MusicBeatState.FunkinTransitionType;
import gamestates.menus.MainMenuState;
import managers.BGMusicManager;
import objects.FunkySprite;
import objects.characters.Character;
import objects.ui.Alphabet;

typedef TitleScreenCharData =
{
	var charName:String;
	var position:Array<Int>;
	var shouldFlip:Bool;
}

typedef TitleScreenJSON =
{
	var characters:Array<TitleScreenCharData>;
	var logoImage:String;
	var bopAnimName:String;
	var bopFPS:Int;
	var bopFlip:Array<Bool>;
	var beatsToBop:Int;
	var logoInFrontOfChar:Int;
	var logoPos:Array<Int>;
	var heyBeats:Array<Int>;
	var enterImage:String;
	var enterStaticName:String;
	var enterSelectName:String;
	var enterFPS:Int;
	var enterPos:Array<Int>;
}

class TitleScreenState extends MusicBeatState
{
	var titleJson:TitleScreenJSON;

	var grossHeterosexuals:Array<Character>;
	var logoImage:FunkySprite;
	var enterImage:FunkySprite;

	// flx and not funky bc custom functions are unwanted
	var ogLogo:FlxSprite;

	public static var hasSkippedBefore:Bool = false;

	override public function create()
	{
		super.create();
		if (FlxG.save.data.lastMod != null)
			Paths.curMod = FlxG.save.data.lastMod;
		BGMusicManager.play('freakyMenu', 102);
		titleJson = Paths.json('menus/titleScreen', null, {
			characters: [
				{
					charName: "boyfriend-title",
					position: [-35, 40],
					shouldFlip: false
				},
				{
					charName: "girlfriend-title",
					position: [775, 220],
					shouldFlip: false
				}
			],
			logoImage: "title/Game Logo",
			bopAnimName: "Logo Beat Hit",
			bopFPS: 24,
			bopFlip: [false, false],
			beatsToBop: 2,
			logoInFrontOfChar: 1,
			logoPos: [160, -110],
			heyBeats: [7, 23, 39, 55, 71, 87, 103, 135, 151, 167, 183],
			enterImage: "title/Enter Text",
			enterStaticName: "ET Static",
			enterSelectName: "ET Select",
			enterFPS: 24,
			enterPos: [135, 610]
		});

		var addedLogo:Bool = false;

		logoImage = new FunkySprite(titleJson.logoPos[0], titleJson.logoPos[1]);
		logoImage.frames = Paths.sparrowV2(titleJson.logoImage, null);
		logoImage.animation.addByPrefix('Bop', '${titleJson.bopAnimName}0', titleJson.bopFPS, false, titleJson.bopFlip[0], titleJson.bopFlip[1]);
		logoImage.playAnim('Bop', true);

		enterImage = new FunkySprite(titleJson.enterPos[0], titleJson.enterPos[1]);
		enterImage.frames = Paths.sparrowV2(titleJson.enterImage, null);
		enterImage.animation.addByPrefix('Static', '${titleJson.enterStaticName}0', titleJson.enterFPS, true, false, false);
		enterImage.animation.addByPrefix('Select', '${titleJson.enterSelectName}0', Std.int(titleJson.enterFPS / 2), false, false, false);
		enterImage.playAnim('Static', true);

		grossHeterosexuals = new Array<Character>();
		for (i in 0...titleJson.characters.length)
		{
			var curCharData:TitleScreenCharData = titleJson.characters[i];

			var newChar:Character = new Character(curCharData.position[0], curCharData.position[1], curCharData.charName, curCharData.shouldFlip);
			add(newChar);

			grossHeterosexuals.push(newChar);

			if (i == titleJson.logoInFrontOfChar)
			{
				add(logoImage);
				addedLogo = true;
			}
		}

		if (!addedLogo)
		{
			add(logoImage);
			addedLogo = true;
		}
		add(enterImage);
		postCreate();

		if (!hasSkippedBefore)
		{
			camHUD.bgColor = FlxColor.BLACK;
			preloaderArt.visible = false;

			ogLogo = new FlxSprite(0, 250, Paths.png('title/Original FNF Logo', null));
			ogLogo.screenCenter(X);
			add(ogLogo);
			ogLogo.cameras = [camHUD];
			ogLogo.visible = false;
		}
		preloaderArt.color = FlxColor.BLACK;
	}

	public var stopSpammingMadEmoji:Bool = false;

	override public function update(e:Float)
	{
		super.update(e);

		if (!stopSpammingMadEmoji && FlxG.keys.justPressed.ENTER)
		{
			if (!hasSkippedBefore)
				skipIntro();
			else
			{
				stopSpammingMadEmoji = true;
				FlxG.sound.play(Paths.sound('menus/confirmMenu', null));
				camGame.flash(FlxColor.WHITE, 0.85);

				enterImage.playAnim('Select', true);
				for (i in grossHeterosexuals)
					i.playAnim('hey', true);

				new FlxTimer().start(1.5, function(t:FlxTimer)
				{
					switchState(MainMenuState, [], false, FunkinTransitionType.Black);
				});
			}
		}
	}

	public static var textStart:Int = 125;
	public static var textSpacing:Int = 75;

	override public function beatHit()
	{
		if (curBeat % 2 == 0)
		{
			for (i in grossHeterosexuals)
				i.dance();
			FlxG.camera.zoom = 1.015;
		}
		else
			FlxG.camera.zoom = 1;
		if (curBeat % titleJson.beatsToBop == 0)
			logoImage.playAnim('Bop', true);

		if (titleJson.heyBeats.contains(curBeat))
			for (i in grossHeterosexuals)
				i.playAnim('hey', true);

		// maybe i'll make this moddable later
		if (!hasSkippedBefore)
		{
			switch (curBeat)
			{
				case 1:
					// trace('DillyzThe1');
					addText(textStart, 'DillyzThe1');
				case 3:
					addText(textStart + textSpacing, 'presents');
				case 4:
					delText();
				case 5:
					addText(textStart, 'A recreation');
					addText(textStart + textSpacing, 'of');
				case 7:
					// addText(textStart + (textSpacing * 3), 'FNF');
					trace('fnf logo vis');
					ogLogo.visible = true;
				case 8:
					delText();
					trace('fnf logo invis');
					ogLogo.visible = false;
				case 9:
					addText(textStart, 'ayo');
				case 11:
					addText(textStart + textSpacing, 'da pizza here');
				case 12:
					delText();
				case 13:
					addText(textStart, 'FNF');
				case 14:
					addText(textStart + textSpacing, 'Dillyz');
				case 15:
					addText(textStart + (textSpacing * 2), 'Engine');
				case 16:
					skipIntro();
			}
		}
	}

	public function skipIntro()
	{
		hasSkippedBefore = true;
		camHUD.bgColor = FlxColor.TRANSPARENT;
		camGame.flash(FlxColor.WHITE, 2.5);
		delText();
	}

	public var youKnowWhoElseHasDementia:Array<Alphabet>;

	public function addText(y:Float, text:String)
	{
		if (youKnowWhoElseHasDementia == null)
			youKnowWhoElseHasDementia = new Array<Alphabet>();
		var newAlphabet:Alphabet = new Alphabet(0, y, text);
		newAlphabet.screenCenter(X);
		add(newAlphabet);
		newAlphabet.cameras = [camHUD];
		youKnowWhoElseHasDementia.push(newAlphabet);
		newAlphabet.x -= 15;
	}

	public function delText()
	{
		if (youKnowWhoElseHasDementia == null)
			return;

		var dirtyVars:Array<Alphabet> = new Array<Alphabet>();

		for (i in youKnowWhoElseHasDementia)
			dirtyVars.push(i);
		for (i in dirtyVars)
		{
			youKnowWhoElseHasDementia.remove(i);
			i.destroy();
		}
	}
}

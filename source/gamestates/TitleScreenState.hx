package gamestates;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gamestates.MusicBeatState.FunkinTransitionType;
import gamestates.menus.MainMenuState;
import managers.BGMusicManager;
import objects.FunkySprite;
import objects.characters.Character;

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
	}

	public var stopSpammingMadEmoji:Bool = false;

	override public function update(e:Float)
	{
		super.update(e);

		if (!stopSpammingMadEmoji && FlxG.keys.justPressed.ENTER)
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
	}
}

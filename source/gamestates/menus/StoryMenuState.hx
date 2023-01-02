package gamestates.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import gamestates.MusicBeatState.FunkinTransitionType;
import objects.characters.StoryModeCharacter;

class StoryMenuState extends MusicBeatState
{
	var yellowSprite:FlxSprite;
	//var dudethatexsists:StoryModeCharacter;

	override public function create()
	{
		super.create();
		yellowSprite = new FlxSprite(-30, FlxG.height / 10).makeGraphic(FlxG.width + 60, Std.int(FlxG.height / 1.85), FlxColor.fromString('#F9CF51'));
		add(yellowSprite);
		//dudethatexsists.texture = "test";
		postCreate();
	}

	var canInput:Bool = true;

	override public function update(e:Float)
	{
		super.update(e);

		if (!canInput)
			return;

		var kjp = FlxG.keys.justPressed;
		var ctrls:Array<Bool> = [kjp.ESCAPE, kjp.ENTER];

		for (i in 0...ctrls.length)
			if (ctrls[i])
				switch (i)
				{
					case 0:
						switchState(MainMenuState, [], false, FunkinTransitionType.Black);
						canInput = false;
					case 1:
						switchState(PlayState, [], false, FunkinTransitionType.Normal);
						canInput = false;
				}
	}
}

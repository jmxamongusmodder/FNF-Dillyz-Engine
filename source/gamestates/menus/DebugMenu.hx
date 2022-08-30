package gamestates.menus;

import objects.ui.Alphabet;
#if debug
import flixel.FlxG;
import gamestates.MusicBeatState.FunkinTransitionType;

class DebugMenu extends MusicBeatState
{
	public var bruhMan:Alphabet;

	override public function create()
	{
		super.create();
		bruhMan = new Alphabet(100, 100, 'bruh');
		add(bruhMan);
		postCreate();
	}

	override public function update(e:Float)
	{
		super.update(e);

		if (FlxG.keys.justPressed.ESCAPE)
			switchState(MainMenuState, [], false, FunkinTransitionType.Black);
		else if (FlxG.keys.justPressed.ONE)
			bruhMan.text = 'h';
		else if (FlxG.keys.justPressed.TWO)
			bruhMan.text = 'ad';
		else if (FlxG.keys.justPressed.THREE)
			bruhMan.text = 'ate';
		else if (FlxG.keys.justPressed.FOUR)
			bruhMan.text = 'bruh';
		else if (FlxG.keys.justPressed.FIVE)
			bruhMan.text = 'abuse';
		else if (FlxG.keys.justPressed.SIX)
			bruhMan.text = 'lmaooo';
		else if (FlxG.keys.justPressed.SEVEN)
			bruhMan.text = 'twitter';
		else if (FlxG.keys.justPressed.EIGHT)
			bruhMan.text = 'eightlol';
		else if (FlxG.keys.justPressed.NINE)
			bruhMan.text = 'ihaveurip';
	}
}
#end

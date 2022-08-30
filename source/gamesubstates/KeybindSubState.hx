package gamesubstates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import objects.FunkyText;
import objects.ui.Options;

class KeybindSubState extends MusicBeatSubState
{
	public var popupTextLol:FunkyText;

	public static var lastOpt:KeybindOption;

	public static var keyIntToStr:Map<Int, FlxKey> = [
		65 => 'A',
		// 18 => 'Alt',
		//- 2 => 'Any',
		66 => 'B',
		// 220 => 'BackSlash',
		// 8 => 'BackSpace',
		67 => 'C',
		// 20 => 'CapsLock',
		188 => 'Comma',
		// 17 => 'Control',
		68 => 'D',
		// 46 => 'Delete',
		40 => 'Down',
		69 => 'E',
		56 => 'Eight',
		// 35 => 'End',
		// 13 => 'Enter',
		// 27 => 'Escape',
		70 => 'F',
		112 => 'F1',
		121 => 'F10',
		122 => 'F11',
		123 => 'F12',
		113 => 'F2',
		114 => 'F3',
		115 => 'F4',
		116 => 'F5',
		117 => 'F6',
		118 => 'F7',
		119 => 'F8',
		120 => 'F9',
		// 53 => 'Five',
		// 52 => 'Four',
		71 => 'G',
		192 => 'GraveAccent',
		72 => 'H',
		// 36 => 'Home',
		73 => 'I',
		// 45 => 'Insert',
		74 => 'J',
		75 => 'K',
		76 => 'L',
		// 219 => 'LBracket',
		37 => 'Left',
		77 => 'M',
		// 189 => 'Minus',
		78 => 'N',
		57 => 'Nine',
		// -1 => 'None',
		104 => 'NumpadEight',
		101 => 'NumpadFive',
		100 => 'NumpadFour',
		// 109 => 'NumpadMinus',
		106 => 'NumpadMultiply',
		105 => 'NumpadNine',
		97 => 'NumpadOne',
		110 => 'NumpadPeriod',
		// 107 => 'NumpadPlus',
		103 => 'NumpadSeven',
		102 => 'NumpadSix',
		99 => 'NumpadThree',
		98 => 'NumpadTwo',
		96 => 'NumpadZero',
		79 => 'O',
		// 49 => 'One',
		80 => 'P',
		34 => 'PageDown',
		33 => 'PageUp',
		190 => 'Period',
		// 187 => 'Plus',
		// 307 => 'PrintScreen',
		81 => 'Q',
		222 => 'Qoute',
		82 => 'R',
		// 221 => 'RBracket'm
		39 => 'Right',
		83 => 'S',
		186 => 'SemiColon',
		// 55 => 'Seven',
		// 16 => 'Shift',
		// 54 => 'Six',
		// 191 => 'Slash'
		32 => 'Space',
		84 => 'T'
	];

	override public function create()
	{
		super.create();

		add(new FlxSprite(0, 0).makeGraphic(1280, 720, FlxColor.BLACK));

		popupTextLol = new FunkyText(0, 0, 0, 'Hit any key to bind.', 64);
		popupTextLol.setFormat(Paths.font('vcr'), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		popupTextLol.borderSize = 1;
		add(popupTextLol);
		popupTextLol.cameras = [newHUD];
		popupTextLol.screenCenter();
		// funnyGayText.x += 35;
		popupTextLol.antialiasing = managers.PreferenceManager.antialiasing;
	}

	override public function update(e:Float)
	{
		super.update(e);

		if (FlxG.keys.justPressed.ANY)
		{
			trace(FlxKey.fromString('${FlxG.keys.firstJustPressed()}').toString() + ' ${FlxG.keys.firstJustPressed()}');
		}
	}
}

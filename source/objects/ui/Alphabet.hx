package objects.ui;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;

using DillyzUtil;

class AlphabetCharacter extends FunkySprite
{
	private var _curChar:String = 'a';

	private static var letters:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	private static var validExtras:String = "_#$%&()*+-0123456789:;<=>@[]^|~";
	private static var renameMap:Map<String, String> = [
		// https://en.wikipedia.org/wiki/Arrows_(Unicode_block)
		'←' => 'Arrow Left',
		'↓	' => 'Arrow Down',
		'↑' => 'Arrow Up',
		'→' => 'Arrow Right',
		// emojis
		'⬅️' => 'Arrow Left',
		'⬇️' => 'Arrow Down',
		'⬆️' => 'Arrow Up',
		'➡️' => 'Arrow Right',
		'❤️' => 'Heart',
		'😠' => 'Angry Face',
		'😡' => 'Angry Face',
		'🤬' => 'Angry Face',
		// things you can type
		'*' => 'Asterisk',
		'\'' => 'Apostraphie',
		',' => 'Comma',
		'!' => 'Exclamation Mark',
		'♡' => 'Heart',
		'♥' => 'Heart',
		// cant put paranthesis here but they're called "Parenthesis Open" & "Parenthesis Close"
		'.' => 'Period',
		'?' => 'Question Mark',
		'\\' => 'Slash Back',
		'/' => 'Slash Foward',
		' ' => 'Space'
	];

	public function new(newChar:String, bold:Bool)
	{
		super();
		frames = Paths.sparrowV2('Alphabet', null);

		for (i in 0...letters.length)
		{
			animation.addByPrefix('${letters.charAt(i).toUpperCase()} Bold', '${letters.charAt(i).toUpperCase()} Bold0', 24, true, false, false);
			animation.addByPrefix('${letters.charAt(i).toUpperCase()} Lowercase', '${letters.charAt(i).toUpperCase()} Lowercase0', 24, true, false, false);
			animation.addByPrefix('${letters.charAt(i).toUpperCase()} Uppercase', '${letters.charAt(i).toUpperCase()} Uppercase0', 24, true, false, false);
		}
		for (i in 0...validExtras.length)
			animation.addByPrefix('${validExtras.charAt(i)}', '${validExtras.charAt(i)}0', 24, true, false, false);

		var keys:Array<String> = cast renameMap.keys().toArray();
		for (i in 0...keys.length)
			animation.addByPrefix('${renameMap.get(keys[i])}', '${renameMap.get(keys[i])}0', 24, true, false, false);

		animation.addByPrefix('Parenthesis Open', 'Parenthesis Open0', 24, true, false, false);
		animation.addByPrefix('Parenthesis Close', 'Parenthesis Close0', 24, true, false, false);
		// animation.addByPrefix('Period', 'Period0', 24, true, false, false);
		animation.addByPrefix('Default', 'Sad Spongebob0', 24, true, false, false);

		animOffsets.set('_', new FlxPoint(0, -50));
		animOffsets.set('+', new FlxPoint(0, -10));
		animOffsets.set(';', new FlxPoint(0, -4));
		animOffsets.set(':', new FlxPoint(0, -4));
		animOffsets.set('=', new FlxPoint(0, -12));
		animOffsets.set('~', new FlxPoint(0, -24));
		animOffsets.set('-', new FlxPoint(0, -16));
		var bOffset = -5;
		animOffsets.set('B Bold', new FlxPoint(bOffset, 0));
		animOffsets.set('E Bold', new FlxPoint(bOffset, 0));
		animOffsets.set('F Bold', new FlxPoint(bOffset, 0));
		animOffsets.set('G Bold', new FlxPoint(1, 0));
		animOffsets.set('I Bold', new FlxPoint(bOffset, 0));
		animOffsets.set('L Bold', new FlxPoint(bOffset, 0));
		animOffsets.set('N Bold', new FlxPoint(bOffset, 0));
		animOffsets.set('P Bold', new FlxPoint(bOffset, 0));
		animOffsets.set('R Bold', new FlxPoint(bOffset, 0));
		animOffsets.set('S Bold', new FlxPoint(-2, 0));
		animOffsets.set('U Bold', new FlxPoint(-2, 0));
		animOffsets.set('W Bold', new FlxPoint(1, 0));

		setCurChar(newChar, bold);
	}

	public function getCurChar():String
	{
		return _curChar;
	}

	var openingQoute:Bool = false;

	function convertToAnim(value:String, bold:Bool)
	{
		if (bold)
		{
			for (i in 0...letters.length)
				if (letters.charAt(i).toUpperCase() == value.toUpperCase())
					return '${letters.charAt(i).toUpperCase()} Bold';
		}
		else
		{
			for (i in 0...letters.length)
				if (letters.charAt(i).toUpperCase() == value)
					return '${letters.charAt(i).toUpperCase()} Uppercase';
				else if (letters.charAt(i).toLowerCase() == value)
					return '${letters.charAt(i).toUpperCase()} Lowercase';
		}

		for (i in 0...validExtras.length)
			if (validExtras.charAt(i).toUpperCase() == value.toUpperCase())
				return validExtras.charAt(i).toUpperCase();

		if (renameMap.exists(value))
			return renameMap.get(value);

		if (value == "\"")
		{
			openingQoute = !openingQoute;
			return openingQoute ? 'Parenthesis Open' : 'Parenthesis Close';
		}

		return 'Default';
	}

	public function setCurChar(value:String, bold:Bool)
	{
		openingQoute = false;
		if (value.length != 1)
			return;
		_curChar = value;
		playAnim(convertToAnim(value, bold), true);
	}
}

class Alphabet extends FlxTypedSpriteGroup<AlphabetCharacter>
{
	private var letterList:Array<AlphabetCharacter>;
	private var text(get, set):String;

	private var _text:String = '';

	public function new(x:Float, y:Float, newText:String)
	{
		super(x, y); // idol
		letterList = new Array<AlphabetCharacter>();
		set_text(newText);
	}

	private function destroyCharacters()
	{
		for (i in letterList)
		{
			remove(i);
			i.destroy();
		}
		letterList.wipeArray();
	}

	public function getWidth()
	{
		return 65 * letterList.length;
	}

	public function getHeight()
	{
		return 65;
	}

	function get_text():String
	{
		return this._text;
	}

	function set_text(newText:String):String
	{
		this._text = newText;
		destroyCharacters();

		for (i in 0..._text.length)
		{
			var newAlphabetChar:AlphabetCharacter = new AlphabetCharacter(_text.charAt(i), true);
			letterList.push(newAlphabetChar);
			add(newAlphabetChar);
			newAlphabetChar.antialiasing = true;

			newAlphabetChar.x = i * 50;
		}

		return this._text;
	}
}

package objects.ui;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

using DillyzUtil;

class AlphabetCharacters extends FunkySprite
{
	public var curChar(get, set):String;

	private var _curChar:String = 'a';

	function get_curChar():String
	{
		return _curChar;
	}

	function set_curChar(value:String):String
	{
		if (value.length != 1)
			return _curChar;
		_curChar = value;
		playAnim(value, true);
		return _curChar;
	}
}

class Alphabet extends FlxTypedSpriteGroup<AlphabetCharacters>
{
	private var letterList:Array<AlphabetCharacters>;

	public function new(newText:String)
	{
		super(); // idol
		letterList = [];
		resetText(newText);
	}

	private function destroyCharacters()
	{
		for (i in letterList)
			i.destroy();
		letterList.wipeArray();
	}

	public function resetText(newText:String)
	{
		destroyCharacters();

		for (i in 0...newText.length)
		{
			var newChar:String = newText.charAt(i);
		}
	}
}

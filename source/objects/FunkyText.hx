package objects;

import flixel.system.FlxAssets;
import flixel.text.FlxText;
import openfl.text.Font;

class FunkyText extends FlxText
{
	public function setFontFromFile(newFont:Font):String
	{
		textField.embedFonts = true;

		if (Font != null)
			_defaultFormat.font = newFont.fontName;
		else
			_defaultFormat.font = FlxAssets.FONT_DEFAULT;

		updateDefaultFormat();
		return _font = _defaultFormat.font;
	}
}

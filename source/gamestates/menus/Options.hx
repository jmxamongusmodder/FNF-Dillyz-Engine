package gamestates.menus;

import objects.ui.Alphabet;

class OptionBase extends Alphabet
{
	public var baseName:String;
	public var saveValue:String;

	public var realType:String;

	public function new(x:Float, y:Float, baseName:String, saveValue:String)
	{
		super(x, y, '???');
		this.baseName = baseName;
		this.saveValue = saveValue;
		this.realType = 'None';
		updateValue();
	}

	public function updateValue()
	{
		var bruhInt:Int = flixel.FlxG.random.int(0, 3);
		switch (bruhInt)
		{
			case 1:
				bruhInt = 10;
			case 2:
				bruhInt = 100;
			case 3:
				bruhInt = 1000;
		}
		this.text = '$baseName: N/A ' + bruhInt;
	}
}

class CategoryOption extends OptionBase
{
	public function new(x:Float, y:Float, baseName:String, saveValue:String)
	{
		super(x, y, baseName, saveValue);
		this.realType = 'Category';
	}

	override public function updateValue()
	{
		this.text = '< $baseName >'.toLowerCase();
	}
}

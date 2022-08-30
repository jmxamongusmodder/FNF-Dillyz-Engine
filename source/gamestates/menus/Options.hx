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
		this.text = '$baseName: N/A';
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

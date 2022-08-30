package objects.ui;

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

class KeybindOption extends OptionBase
{
	public var curBind:String;

	public function new(x:Float, y:Float, baseName:String, saveValue:String, curBind:String)
	{
		super(x, y, baseName, saveValue);
		this.realType = 'Keybind';
		this.curBind = curBind;
	}

	override public function updateValue()
	{
		this.text = '$baseName: $curBind'.toLowerCase();
	}
}

class BooleanOption extends OptionBase
{
	public var boolValue:Bool;

	public function new(x:Float, y:Float, baseName:String, saveValue:String, boolValue:Bool)
	{
		super(x, y, baseName, saveValue);
		this.realType = 'Bool';
		this.boolValue = boolValue;
	}

	override public function updateValue()
	{
		this.text = '$baseName: $boolValue'.toLowerCase();
	}
}

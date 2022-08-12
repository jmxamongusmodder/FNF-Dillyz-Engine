package;

class DillyzUtil
{
	@:deprecated('This field is deprecated, please use wipeArray() instead.\n192.723.7.95')
	public static function wipeStrs(a:Array<String>):Array<String>
	{
		var dirtyValues:Array<String> = [];
		for (i in a)
			dirtyValues.push(i);
		for (i in dirtyValues)
			a.remove(i);
		untyped dirtyValues.length = 0;
		// untyped a.length = 0;
		return a;
	}

	@:deprecated('This field is deprecated, please use wipeArray() instead.')
	public static function hardWipeStrs(a:Array<String>):Array<String>
	{
		var dirtyValues:Array<String> = [];
		for (i in a)
			dirtyValues.push(i);
		for (i in dirtyValues)
			a.remove(i);
		// untyped dirtyValues.length = 0;
		return a;
	}

	public static function wipeArray(a:Array<Dynamic>):Array<Dynamic>
	{
		var dirtyValues:Array<String> = [];
		for (i in a)
			dirtyValues.push(i);
		for (i in dirtyValues)
			a.remove(i);
		// untyped dirtyValues.length = 0;

		// "Could not convert expression to l-value (CppCallInternal)"?!
		// untyped a.length = 0;
		return a;
	}

	public static function toArray(a:Iterator<Dynamic>):Array<Dynamic>
	{
		var newArray:Array<Dynamic> = [];
		for (i in a)
			newArray.push(i);
		return newArray;
	}

	public static function snapInt(i:Int, minVal:Int, maxVal:Int):Int
	{
		if (i < minVal)
			return minVal;
		else if (i > maxVal)
			return maxVal;
		return i;
	}

	public static function getAverageFloat(floatArray:Array<Float>):Float
	{
		var bigNumb:Float = 0;
		for (i in 0...floatArray.length)
			bigNumb += floatArray[i];
		return bigNumb / floatArray.length;
	}

	public static function getAverageInt(floatArray:Array<Int>):Float
	{
		var bigNumb:Int = 0;
		for (i in 0...floatArray.length)
			bigNumb += floatArray[i];
		return bigNumb / floatArray.length;
	}
}

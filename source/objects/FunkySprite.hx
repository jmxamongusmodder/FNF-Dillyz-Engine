package objects;

import DillyzLogger.LogType;
import Paths.PathDefaults;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;

class FunkySprite extends FlxSprite
{
	public var animOffsets:Map<String, FlxPoint> = [];

	public function setOffset(name:String, x:Int, y:Int)
	{
		animOffsets.set(name, new FlxPoint(x, y));
	}

	public function getOffset(name:String)
	{
		if (animOffsets.exists(name))
			animOffsets.get(name);
		return PathDefaults.getPoint();
	}

	public function animationError(name:String, forced:Bool)
	{
		DillyzLogger.log('Animation "$name" ${forced ? 'with' : 'without'} force not found!', LogType.Warning);
	}

	public function updateOffset()
	{
		if (animOffsets.exists(getAnim()))
		{
			var offsetReal:FlxPoint = animOffsets.get(getAnim());
			offset.set(offsetReal.x, offsetReal.y);
			return;
		}
	}

	public function playAnim(name:String, ?forced:Bool = false)
	{
		if (animOffsets.exists(name))
		{
			this.animation.play(name, forced);
			var offsetReal:FlxPoint = animOffsets.get(name);
			offset.set(offsetReal.x, offsetReal.y);
			return;
		}

		animationError(name, forced);
	}

	public function getAnim()
	{
		if (this.animation != null && this.animation.curAnim != null)
			return this.animation.curAnim.name;
		return 'static';
	}

	// i'm doing this to return the right type aniasnfuninuhoajiog screw you haxeflixel you should just return class<flxsprite> or like dynamic or something
	override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String)
	{
		super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
		return this;
	}
}

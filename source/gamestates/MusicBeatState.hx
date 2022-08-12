package gamestates;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import rhythm.Conductor;

class MusicBeatState extends FlxState
{
	public var curSection:Int = 0;
	public var curBeat:Int = 0;
	public var curStep:Int = 0;

	private var camGame:FlxCamera;

	public var camHUD:FlxCamera;

	private var preloaderArt:FlxSprite;
	private var preloaderTween:FlxTween;
	private var preloaderCamera:FlxCamera;

	public var camFollow:FlxObject;

	var curCamZoom:Float = 1;

	/*public function new(?clearGraphics:Bool = true, ?clearSound:Bool = true, ?clearFrames:Bool = true)
		{
			Paths.clearMemory(clearGraphics, clearSound, clearFrames);
			super();
	}*/
	public var followingPosition:FlxPoint;

	override public function create()
	{
		if (intendedToClearMemory)
			Paths.clearMemory();
		intendedToClearMemory = false;
		super.create();
		// get the first camera in action
		camGame = new FlxCamera();
		// camGame.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		// gonna need this a lot anyway
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);
		// FlxG.camera.fade(FlxColor.BLACK, 0.5, true);

		camFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2, 1, 1);
		FlxG.camera.follow(camFollow, LOCKON, 0.02 / (60 / FlxG.updateFramerate));
		followingPosition = camFollow.getPosition();
		FlxG.camera.focusOn(followingPosition);
	}

	public function postCreate()
	{
		preloaderCamera = new FlxCamera();
		preloaderCamera.bgColor.alpha = 0;
		FlxG.cameras.add(preloaderCamera, false);
		preloaderArt = new FlxSprite().loadGraphic(Paths.png('preloader'));
		preloaderArt.antialiasing = true;
		add(preloaderArt);
		preloaderArt.cameras = [preloaderCamera];

		preloaderTween = FlxTween.tween(preloaderArt, {alpha: 0}, 0.5, {
			ease: FlxEase.cubeInOut
		});
	};

	public override function update(e:Float)
	{
		super.update(e);

		if (FlxG.sound != null && FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var lastSection:Int = curSection;
		var lastBeat:Int = curBeat;
		var lastStep:Int = curStep;

		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		};

		for (i in Conductor.bpmChanges)
			if (Conductor.songPosition >= i.songTime)
				lastChange = i;

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
		curBeat = Math.floor(curStep / 4);
		curSection = Math.floor(curBeat / 4);

		if (lastSection != curSection)
			sectionHit();
		if (lastBeat != curBeat)
			beatHit();
		if (lastStep != curStep)
			stepHit();

		var ripPigMan:Float = e * 114;
		// debugArrayLol.push(ripPigMan);
		// debugText.text = Std.string(debugArrayLol.getAverageFloat());
		FlxG.camera.zoom = FlxMath.lerp(curCamZoom, FlxG.camera.zoom, ripPigMan);
	}

	public function sectionHit() {};

	public function beatHit() {};

	public function stepHit() {};

	private static var intendedToClearMemory:Bool = false;

	public function switchState(newState:Class<MusicBeatState>, args:Array<Dynamic>, clearMemory:Bool)
	{
		if (preloaderTween != null)
			preloaderTween.cancel();

		intendedToClearMemory = clearMemory;

		preloaderTween = FlxTween.tween(preloaderArt, {alpha: 1}, 0.5, {
			ease: FlxEase.cubeInOut,
			onComplete: function(t:FlxTween)
			{
				FlxG.switchState(Type.createInstance(newState, args));
			}
		});
		/*FlxG.camera.fade(FlxColor.BLACK, 0.15, false, function()
			{
				new FlxTimer().start(0.1, function(t:FlxTimer)
				{
					FlxG.switchState(Type.createInstance(newState, args));
				});
		});*/
	}
	/*@:deprecated('You are an IDIOT for using this function.')
		public static function switchStateInstance(newState:MusicBeatState)
		{
			FlxG.camera.fade(FlxColor.BLACK, 0.15, false, function()
			{
				new FlxTimer().start(0.1, function(t:FlxTimer)
				{
					FlxG.switchState(newState);
				});
			});
	}*/
}

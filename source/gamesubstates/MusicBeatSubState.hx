package gamesubstates;

import DillyzLogger.LogType;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gamestates.MusicBeatState;
import rhythm.Conductor;

class MusicBeatSubState extends flixel.FlxSubState
{
	public var curSection:Int = 0;
	public var curBeat:Int = 0;
	public var curStep:Int = 0;

	public var newHUD:FlxCamera;

	public var camFollow:FlxObject;

	var curCamZoom:Float = 1;

	public var followingPosition:FlxPoint;

	public var controlsReady:Bool = false;

	override public function create()
	{
		super.create();
		// new substate camera
		newHUD = new FlxCamera();
		newHUD.bgColor.alpha = 0;
		FlxG.cameras.add(newHUD, false);

		camFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2, 1, 1);
		newHUD.follow(camFollow, LOCKON, 0.01 / (60 / FlxG.updateFramerate));
		followingPosition = camFollow.getPosition();
		newHUD.focusOn(followingPosition);

		newHUD.alpha = 0.05;

		FlxTween.tween(newHUD, {alpha: 1}, 0.15, {
			ease: FlxEase.cubeInOut,
			onComplete: function(t:FlxTween)
			{
				controlsReady = true;
			}
		});
	}

	public override function update(e:Float)
	{
		super.update(e);

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

		FlxG.camera.zoom = FlxMath.lerp(curCamZoom, FlxG.camera.zoom, e * 114);
	}

	public function sectionHit() {};

	public function beatHit() {};

	public function stepHit() {};

	// https://tenor.com/view/blm-gif-25815938
	public function killSelf()
	{
		controlsReady = false;

		FlxTween.tween(newHUD, {alpha: 0}, 0.5, {
			ease: FlxEase.cubeInOut,
			onComplete: function(t:FlxTween)
			{
				trulyEndState();
			}
		});
	}

	// doing this to find out what the problem is and for overriding
	public function trulyEndState()
	{
		try
		{
			MusicBeatState.instance.closeSubState();
		}
		catch (e:haxe.Exception)
		{
			DillyzLogger.log('Could not close current MusicBeatSubState! ${e.toString()}\n${e.details()}', LogType.Error);
		}
	}
}

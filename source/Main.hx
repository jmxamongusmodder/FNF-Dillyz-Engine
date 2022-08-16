package;

import DillyzLogger.LogType;
import flixel.FlxGame;
import gamestates.PlayState;
import gamestates.menus.MainMenuState;
import haxe.CallStack;
import haxe.CallStack;
import lime.app.Application;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;
import openfl.events.UncaughtErrorEvents;

class Main extends Sprite
{
	public static var fpsCounter:FPS;

	public function new()
	{
		super();
		DillyzLogger.setLogDate();
		fpsCounter = new FPS(10, 10, 0xFFFFFFFF);
		var curGame:FlxGame = new FlxGame(0, 0, MainMenuState, 1, 120, 120, true, false);
		addChild(curGame);
		addChild(fpsCounter);
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, Main.onUncaughtError);
		/*DillyzLogger.log('Lib.current.loaderInfo.loader == null is ${Lib.current.loaderInfo.loader == null}', LogType.Warning);
			DillyzLogger.log('Lib.current.loaderInfo.loader.uncaughtErrorEvents == null is ${Lib.current.loaderInfo.loader.uncaughtErrorEvents}', LogType.Warning);
			// trace(Lib.current.loaderInfo.loader.uncaughtErrorEvents == null);
			Lib.current.loaderInfo.loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, Main.onUncaughtError); */
		/*Application.current.onExit.add(function(exNumb:Int)
			{
				DillyzLogger.log('-==> Game Closed, Goodbye! <==-', LogType.Normal);
				DillyzLogger.log('-==> Exit number: $exNumb <==-', LogType.Normal);
		}, false, 100);*/
		// Application.current.window.alert('Started Game!', 'bruh');
	}

	@:keep
	// based on https://github.com/gedehari/IzzyEngine/blob/master/source/Main.hx#L94
	public static function onUncaughtError(e:UncaughtErrorEvent)
	{
		DillyzLogger.log('-==> GAME CRASHED! Please review the crash_logs folder. <==-\n-==> Problem: ${e.error} <==-', LogType.Error);
		DillyzLogger.writeCrash(e);
		Application.current.window.alert('-==> GAME CRASHED! Please review the crash_logs folder. <==-\n-==> Problem: ${e.error} <==-\n\nPlease check the latest TXT in the new crash_logs folder if it hasn\'t automatically opened.',
			'Dillyz Engine crash generated!');
		@:privateAccess {
			Sys.command('start notepad "./crash_logs/${DillyzLogger.logFileName}.txt"');
		}
		Sys.exit(1);
	}
}

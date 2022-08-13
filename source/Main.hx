package;

import flixel.FlxGame;
import gamestates.PlayState;
import gamestates.menus.MainMenuState;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var fpsCounter:FPS;

	public function new()
	{
		super();
		DillyzLogger.setLogDate();
		fpsCounter = new FPS(10, 10, 0xFFFFFFFF);
		addChild(new FlxGame(0, 0, MainMenuState, 1, 120, 120, true, false));
		addChild(fpsCounter);
	}
}

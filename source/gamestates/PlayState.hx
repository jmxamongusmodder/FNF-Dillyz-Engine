package gamestates;

import flixel.FlxG;
import gamestates.MusicBeatState.FunkinTransitionType;
import gamestates.editors.CharacterEditorState;
import gamestates.menus.MainMenuState;
import managers.BGMusicManager;
import objects.FunkyStage;
import objects.characters.Character;

// import managers.StateManager;
class PlayState extends MusicBeatState
{
	var theStage:FunkyStage;

	var charLeft:Character;
	var charMid:Character;
	var charRight:Character;

	override public function create()
	{
		super.create();

		theStage = new FunkyStage('stage');
		add(theStage);

		FlxG.camera.zoom = theStage.camZoom;

		charMid = new Character(theStage.posGF.x, theStage.posGF.y, 'girlfriend', false, false, false);
		add(charMid);

		charLeft = new Character(theStage.posDad.x, theStage.posDad.y, 'daddy dearest', false, false, false);
		add(charLeft);

		charRight = new Character(theStage.posBF.x, theStage.posBF.y, 'boyfriend', true, true, false);
		add(charRight);

		postCreate();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
			Sys.exit(0);
		else if (FlxG.keys.justPressed.S)
		{
			charLeft.playAnim('singLEFT', true);
			charMid.playAnim('singLEFT', true);
			charRight.playAnim('singLEFT', true);
		}
		else if (FlxG.keys.justPressed.D)
		{
			charLeft.playAnim('singDOWN', true);
			charMid.playAnim('singDOWN', true);
			charRight.playAnim('singDOWN', true);
		}
		else if (FlxG.keys.justPressed.K)
		{
			charLeft.playAnim('singUP', true);
			charMid.playAnim('singUP', true);
			charRight.playAnim('singUP', true);
		}
		else if (FlxG.keys.justPressed.L)
		{
			charLeft.playAnim('singRIGHT', true);
			charMid.playAnim('singRIGHT', true);
			charRight.playAnim('singRIGHT', true);
		}
		else if (FlxG.keys.justPressed.ONE)
		{
			// StateManager.load(CharacterEditorState);
			switchState(CharacterEditorState, [], false);
		}
		else if (FlxG.keys.justPressed.TWO)
		{
			// StateManager.loadAndClearMemory(CharacterEditorState);
			switchState(CharacterEditorState, [], true);
		}
		else if (FlxG.keys.justPressed.THREE)
		{
			// StateManager.loadAndClearMemory(CharacterEditorState);
			switchState(MainMenuState, [], false, FunkinTransitionType.Black);
		}

		charRight.holdingControls = (FlxG.keys.pressed.S || FlxG.keys.pressed.D || FlxG.keys.pressed.K || FlxG.keys.pressed.L);
	}

	override public function beatHit()
	{
		if (curBeat % 2 == 0)
		{
			charLeft.dance();
			charMid.dance();
			charRight.dance();
		}
	}
}

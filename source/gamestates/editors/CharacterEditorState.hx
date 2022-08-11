package gamestates.editors;

import flixel.FlxG;
import objects.FunkyStage;
import objects.characters.Character;

using DillyzUtil;
using StringTools;

enum CharSideEdit
{
	Left;
	Middle;
	Right;
}

// import managers.StateManager;
class CharacterEditorState extends MusicBeatState
{
	public var curCharName:String = 'boyfriend';
	public var charSide:CharSideEdit = CharSideEdit.Right;

	public var bgChar:Character;
	public var curChar:Character;

	public var animList:Array<String> = [];

	public var normalStage:FunkyStage;

	public function getDefaultX()
	{
		switch (charSide)
		{
			case CharSideEdit.Left:
				return normalStage.posDad.x;
			case CharSideEdit.Middle:
				return normalStage.posGF.x;
			case CharSideEdit.Right:
				return normalStage.posBF.x;
		}
	}

	public function getDefaultY()
	{
		switch (charSide)
		{
			case CharSideEdit.Left:
				return normalStage.posDad.y;
			case CharSideEdit.Middle:
				return normalStage.posGF.y;
			case CharSideEdit.Right:
				return normalStage.posBF.y;
		}
	}

	override public function create()
	{
		super.create();

		normalStage = new FunkyStage('stage');
		add(normalStage);

		bgChar = new Character(getDefaultX(), getDefaultY(), 'boyfriend', charSide == CharSideEdit.Right, false, false);
		bgChar.alpha = 0.15;
		add(bgChar);
		curChar = new Character(getDefaultX(), getDefaultY(), curCharName, charSide == CharSideEdit.Right, false, false);
		add(curChar);

		postCreate();
	}

	override public function beatHit()
	{
		if (curBeat % 2 == 0)
			bgChar.dance();
	}

	public function reloadAnims()
	{
		animList = cast(animList.wipeArray());
	}

	override public function update(e:Float)
	{
		super.update(e);

		if (FlxG.keys.justPressed.ONE)
			switchState(PlayState, [], false);
		// StateManager.load(PlayState);
		else if (FlxG.keys.justPressed.TWO)
			switchState(PlayState, [], true);
		// StateManager.loadAndClearMemory(PlayState);
	}
}

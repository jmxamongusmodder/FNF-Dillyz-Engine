package gamestates.editors;

import DillyzLogger.LogType;
import flixel.FlxG;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.StrNameLabel;
import haxe.Json;
import objects.FunkyStage;
import objects.characters.Character;
import objects.ui.FlxUIDropDownMenuScrollable;
import openfl.errors.IOError;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;

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

	var optionsBox:FlxUITabMenu;

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

		/*var charBox:FlxUITabMenu = new FlxUITabMenu(null, [], true);
			charBox.resize(400, 75);
			charBox.x = FlxG.width - 60 - charBox.width;
			charBox.y = 20;
			add(charBox);
			charBox.cameras = [camHUD];

			var charDrop:FlxUIDropDownMenuScrollable = new FlxUIDropDownMenuScrollable(10, 10, [
				new StrNameLabel("daddy dearest", "daddy dearest"),
				new StrNameLabel("girlfriend", "girlfriend"),
				new StrNameLabel("boyfriend", "boyfriend")
			], function(opt:String)
			{
				DillyzLogger.log('Dropdown Option $opt selected. No functionality implemented.', LogType.Normal);
			});
			charBox.add(charDrop); */

		optionsBox = new FlxUITabMenu(null, [
			{name: "Animations", label: "Animations"},
			{name: "Character", label: "Character"}
		], true);
		optionsBox.resize(400, 500);
		optionsBox.x = FlxG.width - 60 - optionsBox.width;
		optionsBox.y = 40; // 120;
		add(optionsBox);
		optionsBox.cameras = [camHUD];
		optionsBox.selected_tab = 2;

		addCharacterUI();

		postCreate();
	}

	public function addCharacterUI()
	{
		var spriteSheetInput:FlxInputText;
		var spriteSheetSubmit:FlxUIButton;
		// create variables here
		@:privateAccess {
			spriteSheetInput = new FlxInputText(25, 22.5, 250, curChar.charData.sprPath);
			spriteSheetSubmit = new FlxUIButton(300, 20, 'Reload', function()
			{
				// DillyzLogger.log('Spritesheet "${spriteSheetInput.text}" submitted, but no functionality found.', LogType.Warning);
				curChar.charData.sprPath = spriteSheetInput.text;
				// remove(curChar);
				curChar.loadCharacterByData(curChar.charData);
				// add(curChar);
			});
		}

		var choseJSONButton:FlxUIButton = new FlxUIButton(200, 50, 'Choose JSON Instead', function()
		{
			DillyzLogger.log('Attempting to ask for JSON file for a character.', LogType.Normal);

			var funnyFile:FileReference = new FileReference();

			var onLoadOpen:(Event) -> Void;
			var onLoadCancel:(Event) -> Void;
			var onLoadError:(IOErrorEvent) -> Void;

			var likeIfYouAgree:() -> Void = function()
			{
				funnyFile.removeEventListener(Event.SELECT, onLoadOpen);
				funnyFile.removeEventListener(Event.CANCEL, onLoadCancel);
				funnyFile.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				funnyFile = null;
			};

			onLoadOpen = function(_:Event)
			{
				DillyzLogger.log('Got the json.', LogType.Normal);
				funnyFile.load();
				@:privateAccess {
					curChar.charData = Json.parse(funnyFile.data.toString());
					curChar.loadCharacterByData(curChar.charData);
					spriteSheetInput.text = curChar.charData.sprPath;
				}
				likeIfYouAgree();
			};
			onLoadCancel = function(_:Event)
			{
				DillyzLogger.log('Lost the json.', LogType.Warning);
				likeIfYouAgree();
			};
			onLoadError = function(_:IOErrorEvent)
			{
				DillyzLogger.log('Uhhhh whoops! Something went wrong loading the json!', LogType.Warning);
				likeIfYouAgree();
			};

			funnyFile.addEventListener(Event.SELECT, onLoadOpen);
			funnyFile.addEventListener(Event.CANCEL, onLoadCancel);
			funnyFile.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			funnyFile.browse([new FileFilter('Character JSON File', 'json')]);
		});
		choseJSONButton.resize(choseJSONButton.width * 2.5, choseJSONButton.height);
		choseJSONButton.x -= choseJSONButton.width / 2;

		// make new char ui var
		var tabGroup_characters = new FlxUI(null, optionsBox);
		tabGroup_characters.name = "Character";

		// add ur stuff here
		tabGroup_characters.add(spriteSheetInput);
		tabGroup_characters.add(spriteSheetSubmit);
		tabGroup_characters.add(choseJSONButton);

		// assign it to the box
		optionsBox.addGroup(tabGroup_characters);
		optionsBox.scrollFactor.set();
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

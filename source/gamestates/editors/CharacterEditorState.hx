package gamestates.editors;

import DillyzLogger.LogType;
import flixel.FlxG;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.StrNameLabel;
import flixel.animation.FlxAnimation;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
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

	var curCamZoom:Float;

	var animDataText:FlxText;

	public function getDefaultPos()
	{
		switch (charSide)
		{
			case CharSideEdit.Left:
				return normalStage.posDad;
			case CharSideEdit.Middle:
				return normalStage.posGF;
			case CharSideEdit.Right:
				return normalStage.posBF;
		}
	}

	public function getDefaultChar()
	{
		switch (charSide)
		{
			case CharSideEdit.Left:
				return 'daddy dearest';
			case CharSideEdit.Middle:
				return 'girlfriend';
			case CharSideEdit.Right:
				return 'boyfriend';
		}
	}

	public function refreshCharacter(?reloadSprite:Bool = true)
	{
		@:privateAccess {
			if (reloadSprite)
				curChar.loadCharacterByData(curChar.charData);
		}

		camFollow.setPosition(curChar.getMidpoint().x + 150 + curChar.camOffset.x, curChar.getMidpoint().y - 100 + curChar.camOffset.y);

		curCamZoom = normalStage.camZoom * normalStage.zoomMultiBF;
		switch (charSide)
		{
			case CharSideEdit.Left:
				curCamZoom *= normalStage.zoomMultiDad;
				camFollow.x += normalStage.camOffDad.x;
				camFollow.y += normalStage.camOffDad.y;
			case CharSideEdit.Middle:
				curCamZoom *= normalStage.zoomMultiGF;
				camFollow.x += normalStage.camOffGF.x;
				camFollow.y += normalStage.camOffGF.y;
			case CharSideEdit.Right:
				curCamZoom *= normalStage.zoomMultiBF;
				camFollow.x += normalStage.camOffBF.x;
				camFollow.y += normalStage.camOffBF.y;
		}
		curCamZoom *= curChar.camZoomMultiplier;

		updateAnims();
	}

	override public function create()
	{
		super.create();

		normalStage = new FunkyStage('stage');
		add(normalStage);

		bgChar = new Character(getDefaultPos().x, getDefaultPos().y, getDefaultChar(), charSide == CharSideEdit.Right, false, false);
		bgChar.alpha = 0.15;
		add(bgChar);
		curChar = new Character(getDefaultPos().x, getDefaultPos().y, curCharName, charSide == CharSideEdit.Right, false, false);
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
		optionsBox.selected_tab = 1;

		addCharacterUI();

		animDataText = new FlxText(20, 20, 0, '', 16);
		animDataText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 4);
		add(animDataText);
		animDataText.cameras = [camHUD];

		refreshCharacter(false);

		postCreate();
	}

	var allAnimNames:Array<String> = [];
	var curAnim:String = '';

	public function updateAnims()
	{
		var allAnims:Array<FlxAnimation>;
		if (curChar.animation != null)
			allAnims = curChar.animation.getAnimationList();
		else
			allAnims = [];

		for (i in allAnims)
			allAnimNames.push(i.name);
		if (curAnim == '')
			curAnim = allAnimNames[0];

		@:privateAccess {
			var curAnimData:CharAnimData = Character.charAnimDefault;
			for (i in curChar.charData.animData)
				if (i.name == curAnim)
					curAnimData = i;
			animDataText.text = 'Name: ${curAnimData.name}\nPrefix: ${curAnimData.prefix}\nOffset: [${curAnimData.offset[0]}, ${curAnimData.offset[1]}]\nIndices: [';
			for (i in 0...curAnimData.indices.length)
			{
				if (i == curAnimData.indices.length - 1)
					animDataText.text += Std.string(curAnimData.indices[i]);
				else
					animDataText.text += '${curAnimData.indices[i]}, ';
			}
			animDataText.text += ']\nFlipX: ${curAnimData.flipX}\nFlipY: ${curAnimData.flipY}\nLooped: ${curAnimData.looped}\nFPS: ${curAnimData.fps}\n';
		}
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
				refreshCharacter();
				// curChar.loadCharacterByData(curChar.charData);
				// add(curChar);
			});
		}

		var choseJSONButton:FlxUIButton = new FlxUIButton(200, 50, 'Choose JSON Instead', function()
		{
			DillyzLogger.log('Attempting to ask for JSON file for a character.', LogType.Normal);

			@:suppressWarnings {
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
						refreshCharacter();
						// curChar.loadCharacterByData(curChar.charData);
						spriteSheetInput.text = curChar.charData.sprPath;
						// camFollow.setPosition(curChar.getMidpoint().x + 150, curChar.getMidpoint().y - 100);
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
			}
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

	/*public function getCameraXOffset()
		{
			switch (charSide)
			{
				case CharSideEdit.Left:
					return 150;
				case CharSideEdit.Middle:
					return 25;
				case CharSideEdit.Right:
					return -100;
			}
	}*/
	// public var debugArrayLol:Array<Float> = [];

	override public function update(e:Float)
	{
		super.update(e);

		/*if (FlxG.keys.justPressed.ONE)
				switchState(PlayState, [], false);
			// StateManager.load(PlayState);
			else if (FlxG.keys.justPressed.TWO)
				switchState(PlayState, [], true);
			else if (FlxG.keys.justPressed.THREE)
				refreshCharacter(false);
			// StateManager.loadAndClearMemory(PlayState); */

		var kp = FlxG.keys.pressed;
		var kjp = FlxG.keys.justPressed;
		var controls:Array<Bool> = [kp.W, kp.A, kp.S, kp.D, kp.Q, kp.E, kjp.ONE, kjp.TWO, kjp.THREE, kjp.SPACE];

		for (i in 0...controls.length)
			if (controls[i])
				switch (i)
				{
					// camera position stuff
					case 0:
						camFollow.y -= e * 750;
					case 1:
						camFollow.x -= e * 750;
					case 2:
						camFollow.y += e * 750;
					case 3:
						camFollow.x += e * 750;
					// camera zooming
					case 4:
						curCamZoom -= e * 2.5;

						if (curCamZoom < 0.15)
							curCamZoom = 0.15;
						else if (curCamZoom > 3.25)
							curCamZoom = 3.25;
					case 5:
						curCamZoom += e * 2.5;

						if (curCamZoom < 0.15)
							curCamZoom = 0.15;
						else if (curCamZoom > 3.25)
							curCamZoom = 3.25;
					// number inputs
					case 6 | 7:
						switchState(PlayState, [], i == 7);
					case 8:
						refreshCharacter(false);
					case 9:
						curChar.playAnim(curAnim, true);
				}
		var ripPigMan:Float = e * 114;
		// debugArrayLol.push(ripPigMan);
		// debugText.text = Std.string(debugArrayLol.getAverageFloat());
		FlxG.camera.zoom = FlxMath.lerp(curCamZoom, FlxG.camera.zoom, ripPigMan);
	}
}

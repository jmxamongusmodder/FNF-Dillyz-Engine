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
import flixel.math.FlxPoint;
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
import sys.io.File;

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

	public var bgChars:Array<Character>;
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

		var bgCharBF = new Character(normalStage.posBF.x, normalStage.posBF.y, 'boyfriend', true, true, false);
		bgCharBF.alpha = 0.15;
		add(bgCharBF);

		var bgCharGF = new Character(normalStage.posGF.x, normalStage.posGF.y, 'girlfriend', false, true, false);
		bgCharGF.alpha = 0.15;
		add(bgCharGF);

		var bgCharDad = new Character(normalStage.posDad.x, normalStage.posDad.y, 'daddy dearest', false, true, false);
		bgCharDad.alpha = 0.15;
		add(bgCharDad);

		bgChars = [bgCharBF, bgCharGF, bgCharDad];

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

		var saveJSONButton:FlxUIButton = new FlxUIButton(200, choseJSONButton.y + choseJSONButton.height + 10, 'Save Current JSON', function()
		{
			DillyzLogger.log('Attempting to save the JSON file for a character.', LogType.Normal);

			@:suppressWarnings {
				var funnyFile:FileReference = new FileReference();

				var onSaveComplete:(Event) -> Void;
				var onSaveCancel:(Event) -> Void;
				var onSaveError:(IOErrorEvent) -> Void;

				var likeIfYouAgree:() -> Void = function()
				{
					funnyFile.removeEventListener(Event.COMPLETE, onSaveComplete);
					funnyFile.removeEventListener(Event.CANCEL, onSaveCancel);
					funnyFile.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
					funnyFile = null;
				};

				onSaveComplete = function(_:Event)
				{
					DillyzLogger.log('Sent the json.', LogType.Normal);
					curCharName = funnyFile.name.substring(0, funnyFile.name.lastIndexOf('.') - 1);
					likeIfYouAgree();
				};
				onSaveCancel = function(_:Event)
				{
					DillyzLogger.log('Kept the json.', LogType.Warning);
					likeIfYouAgree();
				};
				onSaveError = function(_:IOErrorEvent)
				{
					DillyzLogger.log('Uhhhh whoops! Something went wrong saving the json!', LogType.Warning);
					likeIfYouAgree();
				};

				funnyFile.addEventListener(Event.COMPLETE, onSaveComplete);
				funnyFile.addEventListener(Event.CANCEL, onSaveCancel);
				funnyFile.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
				var newJsonText:String = '{\n	"__comment": "lmao i failed to get the data xdwbuwafni",\n	"__comment_2": "nah but if you see this report it as a bug"\n}';
				@:privateAccess {
					newJsonText = Json.stringify(curChar.charData);
				}
				// [new FileFilter('Character JSON File', 'json')]
				funnyFile.save(newJsonText, '$curCharName.json');
			}
		});

		var sideDropdown:FlxUIDropDownMenuScrollable = new FlxUIDropDownMenuScrollable(100, saveJSONButton.y + saveJSONButton.height + 10, [
			new StrNameLabel("Left", "Left"),
			new StrNameLabel("Middle", "Middle"),
			new StrNameLabel("Right", "Right")
		], function(opt:String)
		{
			@:privateAccess {
				// DillyzLogger.log('Dropdown Option $opt selected. No functionality implemented.', LogType.Normal);
				switch (opt.toLowerCase())
				{
					case 'left':
						charSide = CharSideEdit.Left;
						curChar.rightSide = false;
					case 'middle':
						charSide = CharSideEdit.Middle;
						curChar.rightSide = false;
					case 'right':
						charSide = CharSideEdit.Right;
						curChar.rightSide = true;
				}

				curChar.defPoint.set(getDefaultPos().x, getDefaultPos().y);

				curChar.resetPosition();
				curChar.resetFlip();
				refreshCharacter(false);
			}
		});
		sideDropdown.x -= sideDropdown.width / 2;
		sideDropdown.selectedLabel = sideDropdown.selectedId = 'Right';

		choseJSONButton.resize(choseJSONButton.width * 2.5, choseJSONButton.height);
		choseJSONButton.x -= choseJSONButton.width / 2;

		saveJSONButton.resize(saveJSONButton.width * 2.5, saveJSONButton.height);
		saveJSONButton.x -= saveJSONButton.width / 2;

		// make new char ui var
		var tabGroup_characters = new FlxUI(null, optionsBox);
		tabGroup_characters.name = "Character";

		// add ur stuff here
		tabGroup_characters.add(spriteSheetInput);
		tabGroup_characters.add(spriteSheetSubmit);
		tabGroup_characters.add(choseJSONButton);
		tabGroup_characters.add(saveJSONButton);
		tabGroup_characters.add(sideDropdown);

		// assign it to the box
		optionsBox.addGroup(tabGroup_characters);
		optionsBox.scrollFactor.set();
	}

	override public function beatHit()
	{
		if (curBeat % 2 == 0)
			for (i in bgChars)
				i.dance();
		// bgChar.dance();
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

		curChar.holdTimer = 1000000;

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
		var controls:Array<Bool> = [
			kp.W, kp.A, kp.S, kp.D, kp.Q, kp.E, kjp.ONE, kjp.TWO, kjp.THREE, kjp.SPACE, kp.UP, kp.LEFT, kp.DOWN, kp.RIGHT, kjp.COMMA, kjp.PERIOD
		];

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
					// animation force play
					case 9:
						curChar.playAnim(curAnim, true);
					// animation offset
					case 10:
						@:privateAccess
						{
							var newPoint:FlxPoint;
							if (curChar.animOffsets.exists(curAnim))
							{
								newPoint = curChar.animOffsets.get(curAnim);
								newPoint.y++;
							}
							else
								newPoint = new FlxPoint(0, 1);

							curChar.animOffsets.set(curAnim, newPoint);

							curChar.updateOffset();
							for (i in curChar.charData.animData)
								if (i.name == curAnim)
								{
									i.offset[0] = Std.int(newPoint.x);
									i.offset[1] = Std.int(newPoint.y);
								}
							updateAnims();
						}
					case 11:
						@:privateAccess
						{
							var newPoint:FlxPoint;
							if (curChar.animOffsets.exists(curAnim))
							{
								newPoint = curChar.animOffsets.get(curAnim);
								newPoint.x++;
							}
							else
								newPoint = new FlxPoint(1, 0);

							curChar.animOffsets.set(curAnim, newPoint);

							curChar.updateOffset();
							for (i in curChar.charData.animData)
								if (i.name == curAnim)
								{
									i.offset[0] = Std.int(newPoint.x);
									i.offset[1] = Std.int(newPoint.y);
								}
							updateAnims();
						}
					case 12:
						@:privateAccess
						{
							var newPoint:FlxPoint;
							if (curChar.animOffsets.exists(curAnim))
							{
								newPoint = curChar.animOffsets.get(curAnim);
								newPoint.y--;
							}
							else
								newPoint = new FlxPoint(0, -1);

							curChar.animOffsets.set(curAnim, newPoint);

							curChar.updateOffset();
							for (i in curChar.charData.animData)
								if (i.name == curAnim)
								{
									i.offset[0] = Std.int(newPoint.x);
									i.offset[1] = Std.int(newPoint.y);
								}
							updateAnims();
						}
					case 13:
						@:privateAccess
						{
							var newPoint:FlxPoint;
							if (curChar.animOffsets.exists(curAnim))
							{
								newPoint = curChar.animOffsets.get(curAnim);
								newPoint.x--;
							}
							else
								newPoint = new FlxPoint(-1, 0);

							curChar.animOffsets.set(curAnim, newPoint);

							curChar.updateOffset();
							for (i in curChar.charData.animData)
								if (i.name == curAnim)
								{
									i.offset[0] = Std.int(newPoint.x);
									i.offset[1] = Std.int(newPoint.y);
								}
							updateAnims();
						}
					// current animation
					case 14:
						var curIndex:Int = allAnimNames.indexOf(curAnim);
						curIndex++;
						if (curIndex < 0)
							curIndex = allAnimNames.length - 1;
						else if (curIndex > allAnimNames.length)
							curIndex = 0;
						curAnim = allAnimNames[curIndex];
						updateAnims();
						curChar.playAnim(curAnim, true);
					case 15:
						var curIndex:Int = allAnimNames.indexOf(curAnim);
						curIndex--;
						if (curIndex < 0)
							curIndex = allAnimNames.length - 1;
						else if (curIndex > allAnimNames.length)
							curIndex = 0;
						curAnim = allAnimNames[curIndex];
						updateAnims();
						curChar.playAnim(curAnim, true);
				}
		var ripPigMan:Float = e * 114;
		// debugArrayLol.push(ripPigMan);
		// debugText.text = Std.string(debugArrayLol.getAverageFloat());
		FlxG.camera.zoom = FlxMath.lerp(curCamZoom, FlxG.camera.zoom, ripPigMan);
	}
}

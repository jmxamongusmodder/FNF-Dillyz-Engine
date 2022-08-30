package gamestates.editors;

import DillyzLogger.LogType;
import flixel.FlxG;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.StrNameLabel;
import flixel.animation.FlxAnimation;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gamestates.menus.MainMenuState;
import haxe.Exception;
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

	private function setCamZoomReal()
	{
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
		@:privateAccess {
			var bruh:CharAnimData = Character.charAnimDefault();
			for (i in curChar.charData.animData)
				if (i.name == curAnim)
					bruh = i;
			curCamZoom *= curChar.camZoomMultiplier;
			curCamZoom *= bruh.camZoomMulti;
		}
	}

	public function refreshCharacter(?reloadSprite:Bool = true, ?setCamPos:Bool = true)
	{
		@:privateAccess {
			if (reloadSprite)
				curChar.loadCharacterByData(curChar.charData);
		}

		// camFollow.setPosition(curChar.getMidpoint().x + 150 + curChar.camOffset.x, curChar.getMidpoint().y - 100 + curChar.camOffset.y);
		if (setCamPos)
			camFollow.setPosition(curChar.getMidpoint().x + 150, curChar.getMidpoint().y - 250);

		setCamZoomReal();

		updateAnims();

		@:privateAccess {
			spriteSheetInput.text = curChar.charData.sprPath;
			gOffX.value = curChar.charData.groundOffset[0];
			gOffY.value = curChar.charData.groundOffset[1];
			cOffX.value = curChar.charData.cameraOffset[0];
			cOffY.value = curChar.charData.cameraOffset[1];
			cZoom.value = curChar.charData.camZoomMulti;
			idleLoopLol.text = '';

			for (i in 0...curChar.charData.idleLoop.length)
			{
				if (i == curChar.charData.idleLoop.length - 1)
					idleLoopLol.text += Std.string(curChar.charData.idleLoop[i]);
				else
					idleLoopLol.text += '${curChar.charData.idleLoop[i]}, ';
			}

			deadVarLol.text = curChar.charData.deadVariant;
			theSprTypeLmao.text = curChar.charData.sprType;

			theRealFlipX.checked = curChar.charData.flipX;
			theRealFlipY.checked = curChar.charData.flipY;
			theRealHoldTimer.value = curChar.charData.holdTimer;
			scaleChar.value = curChar.charData.scale[0];
			antialiasingGay.checked = curChar.charData.antialiasing;
		}

		curChar.resetFlip();
		curChar.resetPosition();
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
			// {name: "Animation Manager", label: "Animation Manager"},
			{name: "Animation", label: "Animation"},
			{name: "Character", label: "Character"}
		], true);
		optionsBox.resize(400, 500);
		optionsBox.x = FlxG.width - 60 - optionsBox.width;
		optionsBox.y = 40; // 120;
		add(optionsBox);
		optionsBox.cameras = [camHUD];
		optionsBox.selected_tab = 1;
		optionsBox.selected_tab_id = 'Character';

		// addAnimationMasterUI();
		addAnimationUI();
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

	public function getAnimData()
	{
		@:privateAccess {
			for (i in curChar.charData.animData)
				if (i.name == curAnim)
					return i;
			return Character.charAnimDefault();
		}
	}

	public function updateAnims()
	{
		/*var allAnims:Array<FlxAnimation>;
			if (curChar.animation != null)
				allAnims = curChar.animation.getAnimationList();
			else
				allAnims = []; */

		// var allAnims:Array<String> = [];

		allAnimNames.wipeArray();

		@:privateAccess {
			for (i in curChar.charData.animData)
				allAnimNames.push(i.name);
		}

		// for (i in allAnims)
		//	allAnimNames.push(i);
		if (curAnim == '')
			curAnim = allAnimNames[0];

		// trace(allAnimNames);

		@:privateAccess {
			var curAnimData:CharAnimData = Character.charAnimDefault();
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

			// animationListDropdown.list = cast animationListDropdwn.list.wipeArray);
			/*for (i in 0...allAnimNames.length)
				{
					if (animationListDropdown.list.length >= i)
						animationListDropdown.list.push(animationListDropdown.makeListButton(i, allAnimNames[i], allAnimNames[i]));
					else
					{
						animationListDropdown.changeLabelByIndex(0, allAnimNames[i]);
						animationListDropdown.changeNameByIndex(0, allAnimNames[i]);
					}
				}
				animationListDropdown.selectSomething(curAnim, curAnim); */

			animationListDropdown.selectSomething(curAnim, curAnim);

			animationName.text = curAnimData.name;
			animationPrefix.text = curAnimData.prefix;
			animationIndices.text = '';
			for (i in 0...curAnimData.indices.length)
				if (i == curAnimData.indices.length - 1)
					animationIndices.text += Std.string(curAnimData.indices[i]);
				else
					animationIndices.text += '${curAnimData.indices[i]}, ';
			animationFlipX.checked = curAnimData.flipX;
			animationFlipY.checked = curAnimData.flipY;
			animationLooped.checked = curAnimData.looped;
			animationFPS.value = curAnimData.fps;
			if (curAnimData.cameraOffset == null || curAnimData.cameraOffset.length != 2)
				curAnimData.cameraOffset = [0, 0];
			animationCamOffX.value = curAnimData.cameraOffset[0];
			animationCamOffY.value = curAnimData.cameraOffset[1];
			animationCamZoom.value = curAnimData.camZoomMulti;

			var camOffReal:Int = 0;
			switch (charSide)
			{
				case Left:
					camOffReal = 150;
				case Middle:
					camOffReal = 25;
				case Right:
					camOffReal = -100;
			}
			camFollow.setPosition(curChar.getMidpoint().x + camOffReal + curChar.camOffset.x, curChar.getMidpoint().y - 100 + curChar.camOffset.y);
			setCamZoomReal();
		}
	}

	/*public function addAnimationMasterUI()
		{
			// make new char ui var
			var tabGroup_animationManager = new FlxUI(null, optionsBox);
			tabGroup_animationManager.name = "Animation Manager";

			// add ur stuff here
			tabGroup_animationManager.add(null);

			// assign it to the box
			optionsBox.addGroup(tabGroup_animationManager);
			optionsBox.scrollFactor.set();
	}*/
	var animationListDropdown:FlxUIDropDownMenuScrollable;
	var animationName:FlxInputText;
	var animationPrefix:FlxInputText;
	var animationIndices:FlxInputText;
	var animationFlipX:FlxUICheckBox;
	var animationFlipY:FlxUICheckBox;
	var animationLooped:FlxUICheckBox;
	var animationFPS:FlxUINumericStepper;

	public function reloadAnimationList()
	{
		@:privateAccess {
			if (tabGroup_animation != null && tabGroup_animation.hasThis(animationListDropdown))
				tabGroup_animation.remove(animationListDropdown);
			var allAnims:Array<FlxAnimation>;
			if (curChar.animation != null)
				allAnims = curChar.animation.getAnimationList();
			else
				allAnims = [];

			var strLabelList:Array<StrNameLabel> = [];

			for (i in 0...allAnims.length)
				strLabelList.push(new StrNameLabel(allAnims[i].name, allAnims[i].name));

			if (animationListDropdown != null)
				animationListDropdown.destroy();
			animationListDropdown = new FlxUIDropDownMenuScrollable(100, 20, strLabelList, function(opt:String)
			{
				@:privateAccess {
					trace(opt);
					curAnim = opt;
					updateAnims();
					curChar.playAnim(curAnim, true);

					// curChar.reloadAnims();
					// refreshCharacter(false);
				}
			});
			animationListDropdown.x -= animationListDropdown.width / 2;

			animationListDropdown.selectSomething(curAnim, curAnim);
			if (tabGroup_animation != null)
				tabGroup_animation.add(animationListDropdown);
		}
	}

	var tabGroup_animation:FlxUI;

	private function labelText(x:Float, y:Float, text:String, ?center:Bool = false)
	{
		var newText:FlxText = new FlxText(x, y, 0, text, 8);
		newText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 4);
		if (center)
			newText.x -= newText.width / 2;
		newText.antialiasing = PreferenceManager.antialiasing;
		return newText;
	}

	var gOffX:FlxUINumericStepper;
	var gOffY:FlxUINumericStepper;
	var cOffX:FlxUINumericStepper;
	var cOffY:FlxUINumericStepper;
	var cZoom:FlxUINumericStepper;
	var animationCamOffX:FlxUINumericStepper;
	var animationCamOffY:FlxUINumericStepper;
	var animationCamZoom:FlxUINumericStepper;

	private function addAnimationUI()
	{
		reloadAnimationList();

		// make new char ui var
		tabGroup_animation = new FlxUI(null, optionsBox);
		tabGroup_animation.name = "Animation";

		// make stuff
		tabGroup_animation.add(labelText(25, animationListDropdown.y + 60, 'Anim Name'));
		animationName = new FlxInputText(100, animationListDropdown.y + 60, 250, 'idle');
		tabGroup_animation.add(labelText(25, animationName.y + animationName.height + 10, 'Anim Prefix'));
		animationPrefix = new FlxInputText(100, animationName.y + animationName.height + 10, 250, 'idle');
		tabGroup_animation.add(labelText(25, animationPrefix.y + animationName.height + 10, 'Anim Indices'));
		animationIndices = new FlxInputText(100, animationPrefix.y + animationName.height + 10, 250, '');
		tabGroup_animation.add(labelText(25, animationIndices.y + animationName.height + 10, 'Anim Flip X'));
		animationFlipX = new FlxUICheckBox(100, animationIndices.y + animationName.height + 10, null, null, '');
		tabGroup_animation.add(labelText(25, animationFlipX.y + animationName.height + 10, 'Anim Flip Y'));
		animationFlipY = new FlxUICheckBox(100, animationFlipX.y + animationName.height + 10, null, null, '');
		tabGroup_animation.add(labelText(25, animationFlipY.y + animationName.height + 10, 'Anim Looped'));
		animationLooped = new FlxUICheckBox(100, animationFlipY.y + animationName.height + 10, null, null, '');
		tabGroup_animation.add(labelText(25, animationLooped.y + animationName.height + 10, 'Anim FPS'));
		animationFPS = new FlxUINumericStepper(100, animationLooped.y + animationName.height + 10, 1, 24, 0, 120);
		tabGroup_animation.add(labelText(25, animationFPS.y + animationName.height + 10, 'Anim Cam'));
		animationCamOffX = new FlxUINumericStepper(100, animationFPS.y + animationName.height + 10, 5, 0, -2500, 2500);
		animationCamOffY = new FlxUINumericStepper(175, animationFPS.y + animationName.height + 10, 5, 0, -2500, 2500);
		tabGroup_animation.add(labelText(25, animationCamOffY.y + animationName.height + 10, 'Anim Zoom'));
		animationCamZoom = new FlxUINumericStepper(100, animationCamOffY.y + animationName.height + 10, 0.1, 1, 0.5, 1.5);
		animationCamZoom.isPercent = true;

		var updateAnimation:FlxUIButton = new FlxUIButton(100, 440, 'Update/Add', function()
		{
			@:privateAccess {
				var bruhData:CharAnimData = Character.charAnimDefault();
				var bruhDirty:Bool = false;
				for (i in curChar.charData.animData)
					if (i.name == animationName.text)
					{
						bruhData = i;
						bruhDirty = true;
					}
				if (bruhDirty)
					curChar.charData.animData.remove(bruhData);
				bruhData.name = animationName.text;
				bruhData.prefix = animationPrefix.text;
				bruhData.indices.wipeArray();
				if (animationIndices.text.length == 1)
					bruhData.indices.push(Std.parseInt(animationIndices.text));
				else if (animationIndices.text.length >= 1 && animationIndices.text.contains(','))
				{
					var splitIndices:Array<String> = animationIndices.text.replace(', ', ',').split(',');
					for (i in splitIndices)
						bruhData.indices.push(Std.parseInt(i));
				}
				bruhData.flipX = animationFlipX.checked;
				bruhData.flipY = animationFlipY.checked;
				bruhData.looped = animationLooped.checked;
				bruhData.fps = Std.int(animationFPS.value);
				bruhData.cameraOffset = [Std.int(animationCamOffX.value), Std.int(animationCamOffY.value)];
				bruhData.camZoomMulti = animationCamZoom.value;
				curAnim = bruhData.name;
				trace(bruhData);

				curChar.charData.animData.push(bruhData);

				curChar.reloadAnims();
				curChar.playAnim(bruhData.name, true);
				updateAnims();
				reloadAnimationList();

				var camOffReal:Int = 0;
				switch (charSide)
				{
					case Left:
						camOffReal = 150;
					case Middle:
						camOffReal = 25;
					case Right:
						camOffReal = -100;
				}
				camFollow.setPosition(curChar.getMidpoint().x + camOffReal + curChar.camOffset.x + curChar.charData.cameraOffset[0]
					+ getAnimData().cameraOffset[0],
					curChar.getMidpoint().y - 100 + curChar.camOffset.y + curChar.charData.cameraOffset[1]
					+ getAnimData().cameraOffset[1]);
				setCamZoomReal();
			}
		});
		updateAnimation.x -= updateAnimation.width / 2;

		var removeAnimation:FlxUIButton = new FlxUIButton(300, 440, 'Remove', function()
		{
			@:privateAccess {
				if (allAnimNames.length <= 1)
					return;
				for (i in curChar.charData.animData)
					if (i.name == animationName.text)
						curChar.charData.animData.remove(i);
				curAnim = curChar.charData.animData[0].name;
				curChar.reloadAnims();
				curChar.playAnim(curChar.charData.animData[0].name, true);
				updateAnims();
				reloadAnimationList();
			}
		});
		removeAnimation.x -= removeAnimation.width / 2;

		// do this after bc it references the tab

		// add ur stuff here
		tabGroup_animation.add(animationName);
		tabGroup_animation.add(animationPrefix);
		tabGroup_animation.add(animationIndices);
		tabGroup_animation.add(animationFlipX);
		tabGroup_animation.add(animationFlipY);
		tabGroup_animation.add(animationLooped);
		tabGroup_animation.add(animationFPS);
		tabGroup_animation.add(animationCamOffX);
		tabGroup_animation.add(animationCamOffY);
		tabGroup_animation.add(animationCamZoom);
		tabGroup_animation.add(updateAnimation);
		tabGroup_animation.add(removeAnimation);

		tabGroup_animation.add(animationListDropdown);

		// assign it to the box
		optionsBox.addGroup(tabGroup_animation);
		optionsBox.scrollFactor.set();
	}

	var spriteSheetInput:FlxInputText;
	var idleLoopLol:FlxInputText;
	var deadVarLol:FlxInputText;
	var theSprTypeLmao:FlxInputText;
	var theRealFlipX:FlxUICheckBox;
	var theRealFlipY:FlxUICheckBox;
	var theRealHoldTimer:FlxUINumericStepper;
	var scaleChar:FlxUINumericStepper;
	var antialiasingGay:FlxUICheckBox;

	private function addCharacterUI()
	{
		// make new char ui var
		var tabGroup_characters = new FlxUI(null, optionsBox);
		tabGroup_characters.name = "Character";

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
						// camFollow.setPosition(curChar.getMidpoint().x + 150, curChar.getMidpoint().y - 100);

						curAnim = curChar.charData.animData[0].name;
						curChar.reloadAnims();
						curChar.playAnim(curChar.charData.animData[0].name, true);
						updateAnims();
						reloadAnimationList();
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

		var sideDropdown:FlxUIDropDownMenuScrollable = new FlxUIDropDownMenuScrollable(200, saveJSONButton.y + saveJSONButton.height + 10, [
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

		tabGroup_characters.add(labelText(200, sideDropdown.y + 25, 'Ground Offset', true));
		gOffX = new FlxUINumericStepper(150, sideDropdown.y + 25 + 20, 1, 0, -100000, 100000);
		gOffX.x -= gOffX.width / 2;
		gOffY = new FlxUINumericStepper(250, sideDropdown.y + 25 + 20, 1, 0, -100000, 100000);
		gOffY.x -= gOffY.width / 2;
		tabGroup_characters.add(labelText(200, gOffX.y + gOffX.height + 10, 'Camera Offset & Zoom Multiplier', true));
		cOffX = new FlxUINumericStepper(100, gOffX.y + gOffX.height + 10 + 20, 5, 0, -100000, 100000);
		cOffX.x -= cOffX.width / 2;
		cOffY = new FlxUINumericStepper(300, gOffX.y + gOffX.height + 10 + 20, 5, 0, -100000, 100000);
		cOffY.x -= cOffY.width / 2;
		cZoom = new FlxUINumericStepper(200, gOffX.y + gOffX.height + 10 + 20, 0.1, 0, 0.5, 150);
		cZoom.x -= cZoom.width / 2;
		cZoom.isPercent = true;
		tabGroup_characters.add(labelText(200, cOffY.y + cOffY.height + 10, 'Idle Loop', true));
		idleLoopLol = new FlxInputText(200, cOffY.y + cOffY.height + 10 + 20, 250, '');
		idleLoopLol.x -= idleLoopLol.width / 2;
		tabGroup_characters.add(labelText(200, idleLoopLol.y + cOffY.height + 10, 'Dead Variant', true));
		deadVarLol = new FlxInputText(200, idleLoopLol.y + cOffY.height + 10 + 20, 250, 'boyfriend');
		deadVarLol.x -= deadVarLol.width / 2;
		tabGroup_characters.add(labelText(200, deadVarLol.y + cOffY.height + 10, 'Sprite Type', true));
		theSprTypeLmao = new FlxInputText(200, deadVarLol.y + cOffY.height + 10 + 20, 250, 'sparrow-v2');
		theSprTypeLmao.x -= theSprTypeLmao.width / 2;
		tabGroup_characters.add(labelText(200, theSprTypeLmao.y + cOffY.height + 10, 'FlipX, FlipY, & Hold Timer', true));
		theRealFlipX = new FlxUICheckBox(200, theSprTypeLmao.y + cOffY.height + 10 + 20, null, null, '', 0);
		// theRealFlipX.x -= theRealFlipX.width / 2;
		theRealFlipY = new FlxUICheckBox(200, theSprTypeLmao.y + cOffY.height + 10 + 20, null, null, '', 0);
		// theRealFlipY.x -= theRealFlipY.width / 2;
		theRealFlipX.x -= theRealFlipY.width * 2;
		theRealFlipY.x -= theRealFlipY.width;
		theRealHoldTimer = new FlxUINumericStepper(200, theSprTypeLmao.y + gOffX.height + 10 + 20, 0.1, 4, 0, 10);
		// theRealHoldTimer.x -= theRealHoldTimer.width / 2;
		theRealHoldTimer.isPercent = true;
		tabGroup_characters.add(labelText(200, theRealHoldTimer.y + cOffY.height + 10, 'Scale & Antialiasing', true));
		scaleChar = new FlxUINumericStepper(180, theRealHoldTimer.y + gOffX.height + 10 + 20, 0.1, 1, 0.1, 2.5);
		scaleChar.isPercent = true;
		scaleChar.x -= scaleChar.width;
		antialiasingGay = new FlxUICheckBox(220, theRealHoldTimer.y + cOffY.height + 10 + 20, null, null, '', 0);
		antialiasingGay.checked = true;

		idleLoopLol.callback = function(text:String, b:String)
		{
			try
			{
				text = text.replace(', ', ',');
				if (text.contains(','))
				{
					@:privateAccess {
						curChar.charData.idleLoop = text.split(',');
						trace(curChar.charData.idleLoop);
					}
				}
			}
			catch (e:Exception)
			{
				DillyzLogger.log('Couldn\'t parse idle loop; ${e.toString()}\n${e.details}', LogType.Warning);
			}
		};

		deadVarLol.callback = function(text:String, b:String)
		{
			@:privateAccess {
				curChar.charData.deadVariant = text;
			}
		};
		theSprTypeLmao.callback = function(text:String, b:String)
		{
			@:privateAccess {
				curChar.charData.sprType = text;
			}
		};
		theRealFlipX.callback = function()
		{
			@:privateAccess {
				curChar.charData.flipX = theRealFlipX.checked;
				refreshCharacter(false);
			}
		};
		theRealFlipY.callback = function()
		{
			@:privateAccess {
				curChar.charData.flipY = theRealFlipY.checked;
				refreshCharacter(false);
			}
		};
		antialiasingGay.callback = function()
		{
			@:privateAccess {
				curChar.charData.antialiasing = antialiasingGay.checked;
				curChar.antialiasing = antialiasingGay.checked;
				refreshCharacter(false);
			}
		};

		// add ur stuff here
		tabGroup_characters.add(sideDropdown);
		tabGroup_characters.add(spriteSheetInput);
		tabGroup_characters.add(spriteSheetSubmit);
		tabGroup_characters.add(choseJSONButton);
		tabGroup_characters.add(saveJSONButton);

		tabGroup_characters.add(gOffX);
		tabGroup_characters.add(gOffY);
		tabGroup_characters.add(cOffX);
		tabGroup_characters.add(cOffY);
		tabGroup_characters.add(cZoom);
		tabGroup_characters.add(idleLoopLol);
		tabGroup_characters.add(deadVarLol);
		tabGroup_characters.add(theSprTypeLmao);
		tabGroup_characters.add(theRealFlipX);
		tabGroup_characters.add(theRealFlipY);
		tabGroup_characters.add(theRealHoldTimer);
		tabGroup_characters.add(scaleChar);
		tabGroup_characters.add(antialiasingGay);

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

	/*public function reloadAnims()
		{
			animList = cast(animList.wipeArray());
	}*/
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

	/*public function updateFocusManagement()
		{
			// make sure it doesn't select a text box
			if (animationListDropdown.dropPanel.visible)
				{
					animationName.hasFocus = false;
					animationPrefix.hasFocus = false;
			}
	}*/
	public function attemptAnimMovement(inputThing:Int)
	{
		switch (inputThing)
		{
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
		}
	}

	public function attemptCharMovement(inputThing:Int)
	{
		@:privateAccess
		{
			switch (inputThing)
			{
				case 10:
					curChar.charData.groundOffset[1]--;
				case 11:
					curChar.charData.groundOffset[0]--;
				case 12:
					curChar.charData.groundOffset[1]++;
				case 13:
					curChar.charData.groundOffset[0]++;
			}
			gOffX.value = curChar.charData.groundOffset[0];
			gOffY.value = curChar.charData.groundOffset[1];

			curChar.defPoint.set(getDefaultPos().x, getDefaultPos().y);
			curChar.resetPosition();
			curChar.resetFlip();
			refreshCharacter(false, false);
		}
	}

	var oldCharValues:Array<Int> = [-1, 0, 0, 0, 0];
	var oldCharValues2:Array<Int> = [-1, 0];
	var oldCharValue3:Array<Float> = [0, 0, 0];

	override public function update(e:Float)
	{
		super.update(e);

		curChar.holdTimer = 1000000;

		if (Std.int(gOffX.value) != oldCharValues[0]
			|| Std.int(gOffY.value) != oldCharValues[1]
			|| Std.int(cOffX.value) != oldCharValues[2]
			|| Std.int(cOffY.value) != oldCharValues[3]
			|| Std.int(cZoom.value * 100) != oldCharValues[4])
		{
			@:privateAccess {
				oldCharValues = [
					Std.int(gOffX.value),
					Std.int(gOffY.value),
					Std.int(cOffX.value),
					Std.int(cOffY.value),
					Std.int(cZoom.value * 100)
				];
				curChar.charData.groundOffset[0] = oldCharValues[0];
				curChar.charData.groundOffset[1] = oldCharValues[1];
				curChar.camOffset.set(oldCharValues[2], oldCharValues[3]);

				curChar.charData.groundOffset = [oldCharValues[0], oldCharValues[1]];
				curChar.charData.cameraOffset = [oldCharValues[2], oldCharValues[3]];
				curChar.charData.camZoomMulti = cZoom.value;
				curChar.resetPosition();
				curChar.resetFlip();
				var camOffReal:Int = 0;
				switch (charSide)
				{
					case Left:
						camOffReal = 150;
					case Middle:
						camOffReal = 25;
					case Right:
						camOffReal = -100;
				}
				// camFollow.setPosition(curChar.getMidpoint().x + camOffReal + curChar.camOffset.x, curChar.getMidpoint().y - 100 + curChar.camOffset.y);
				camFollow.setPosition(curChar.getMidpoint().x + camOffReal + curChar.camOffset.x + curChar.charData.cameraOffset[0]
					+ getAnimData().cameraOffset[0],
					curChar.getMidpoint().y - 100 + curChar.camOffset.y + curChar.charData.cameraOffset[1]
					+ getAnimData().cameraOffset[1]);
				setCamZoomReal();
			}
		}

		if (Std.int(animationCamOffX.value) != oldCharValues2[0]
			|| Std.int(animationCamOffY.value) != oldCharValues2[1]
			|| animationCamZoom.value != oldCharValue3[0])
		{
			@:privateAccess {
				oldCharValues2 = [Std.int(animationCamOffX.value), Std.int(animationCamOffY.value)];
				oldCharValue3[0] = animationCamZoom.value;

				getAnimData().cameraOffset = oldCharValues2;
				getAnimData().camZoomMulti = oldCharValue3[0];

				var camOffReal:Int = 0;
				switch (charSide)
				{
					case Left:
						camOffReal = 150;
					case Middle:
						camOffReal = 25;
					case Right:
						camOffReal = -100;
				}
				// camFollow.setPosition(curChar.getMidpoint().x + camOffReal + curChar.camOffset.x, curChar.getMidpoint().y - 100 + curChar.camOffset.y);
				camFollow.setPosition(curChar.getMidpoint().x + camOffReal + curChar.camOffset.x + curChar.charData.cameraOffset[0]
					+ getAnimData().cameraOffset[0],
					curChar.getMidpoint().y - 100 + curChar.camOffset.y + curChar.charData.cameraOffset[1]
					+ getAnimData().cameraOffset[1]);
				setCamZoomReal();
			}
		}

		if (theRealHoldTimer.value != oldCharValue3[1])
		{
			oldCharValue3[1] = theRealHoldTimer.value;

			@:privateAccess {
				curChar.charData.holdTimer = theRealHoldTimer.value;
			}
		}

		if (scaleChar.value != oldCharValue3[2])
		{
			oldCharValue3[2] = scaleChar.value;

			@:privateAccess {
				curChar.charData.scale = [scaleChar.value, scaleChar.value];
				curChar.scale.set(scaleChar.value, scaleChar.value);
			}
		}

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
			kp.W, kp.A, kp.S, kp.D, kp.Q, kp.E, kjp.ONE, kjp.TWO, kjp.THREE, kjp.SPACE, kp.UP, kp.LEFT, kp.DOWN, kp.RIGHT, kjp.COMMA, kjp.PERIOD, kp.FOUR
		];

		if (!animationName.hasFocus && !animationPrefix.hasFocus && !animationIndices.hasFocus)
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
							switchState(i == 6 ? PlayState : MainMenuState, [], false);
						case 8:
							refreshCharacter(false);
						// animation force play
						case 9:
							curChar.playAnim(curAnim, true);
						// animation offset
						case 10 | 11 | 12 | 13:
							if (optionsBox.selected_tab_id.toLowerCase().trim() == 'animation')
								attemptAnimMovement(i);
							else
								attemptCharMovement(i);
						// current animation
						case 14:
							var curIndex:Int = allAnimNames.indexOf(curAnim);
							curIndex++;
							if (curIndex >= allAnimNames.length)
								curIndex = 0;
							curAnim = allAnimNames[curIndex];
							updateAnims();
							curChar.playAnim(curAnim, true);
							setCamZoomReal();
						// animationListDropdown.selectSomething(curAnim, curAnim);
						case 15:
							var curIndex:Int = allAnimNames.indexOf(curAnim);
							curIndex--;
							if (curIndex < 0)
								curIndex = allAnimNames.length - 1;
							curAnim = allAnimNames[curIndex];
							updateAnims();
							curChar.playAnim(curAnim, true);
						// animationListDropdown.selectSomething(curAnim, curAnim);
						// debug
						case 16:
							reloadAnimationList();
					}
	}
}

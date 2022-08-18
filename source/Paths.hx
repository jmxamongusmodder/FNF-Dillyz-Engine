package;

import DillyzLogger.LogType;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import haxe.Exception;
import haxe.Json;
import objects.FunkyStage;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.system.System;
import openfl.text.Font;
import sys.FileSystem;
import sys.io.File;

using DillyzUtil;
using StringTools;

class Paths
{
	// public static var curLib:String = 'shared';
	#if MODS_ACTIVE
	public static var curMod:String = '_TEMPLATE';
	#end

	public static var loadedGraphics:Map<String, FlxGraphic> = [];
	public static var loadedSounds:Map<String, Sound> = [];
	public static var loadedFrames:Map<String, FlxAtlasFrames> = [];

	// public static var loadedFonts:Map<String, Font> = [];
	public static function clearSpecificMemory(thingstoClear:Array<String>) // , ?clearFonts:Bool = false)
	{
		DillyzLogger.log('Clearing out specific assets. Graphics? Elements: $thingstoClear', LogType.Normal);
		var keys:Array<String> = cast(loadedGraphics.keys().toArray());
		for (i in 0...keys.length)
		{
			try
			{
				// don't break the loading state
				if (keys[i] != 'null:preloader' && thingstoClear.contains(keys[i]))
				{
					var graphic:FlxGraphic = loadedGraphics.get(keys[i]);
					loadedGraphics.remove(keys[i]);
					graphic.persist = false;
					graphic.destroy();
				}
			}
			catch (e:Exception)
			{
				DillyzLogger.log('Could not clear graphic asset \'${keys[i]}\'; ${e.toString()}\n${e.message}', LogType.Error);
			}
		}
		var keys:Array<String> = cast(loadedSounds.keys().toArray());
		for (i in 0...keys.length)
		{
			try
			{
				if (thingstoClear.contains(keys[i]))
				{
					var sound:Sound = loadedSounds.get(keys[i]);
					loadedSounds.remove(keys[i]);
					sound.close();
				}
			}
			catch (e:Exception)
			{
				DillyzLogger.log('Could not clear sound asset \'${keys[i]}\'; ${e.toString()}\n${e.message}', LogType.Error);
			}
		}
		var keys:Array<String> = cast(loadedFrames.keys().toArray());
		for (i in 0...keys.length)
		{
			try
			{
				if (thingstoClear.contains(keys[i]))
				{
					var frames:FlxAtlasFrames = loadedFrames.get(keys[i]);
					loadedFrames.remove(keys[i]);
					frames.destroy();
				}
			}
			catch (e:Exception)
			{
				DillyzLogger.log('Could not clear atlas frames \'${keys[i]}\'; ${e.toString()}\n${e.message}', LogType.Error);
			}
		}
	}

	public static function clearMemory(?clearGraphics:Bool = true, ?clearSound:Bool = true, ?clearFrames:Bool = true) // , ?clearFonts:Bool = false)
	{
		DillyzLogger.log('Clearing out assets. Graphics? ${clearGraphics ? 'Yes' : 'No'}. Sounds? ${clearSound ? 'Yes' : 'No'}. Atlas Frames? ${clearFrames ? 'Yes' : 'No'}.',
			LogType.Normal);
		if (clearGraphics)
		{
			var keys:Array<String> = cast(loadedGraphics.keys().toArray());
			for (i in 0...keys.length)
			{
				try
				{
					// don't break the loading state
					if (keys[i] != 'null:preloader')
					{
						var graphic:FlxGraphic = loadedGraphics.get(keys[i]);
						loadedGraphics.remove(keys[i]);
						graphic.persist = false;
						graphic.destroy();
					}
				}
				catch (e:Exception)
				{
					DillyzLogger.log('Could not clear graphic asset \'${keys[i]}\'; ${e.toString()}\n${e.message}', LogType.Error);
				}
			}
		}

		if (clearSound)
		{
			var keys:Array<String> = cast(loadedSounds.keys().toArray());
			for (i in 0...keys.length)
			{
				try
				{
					var sound:Sound = loadedSounds.get(keys[i]);
					loadedSounds.remove(keys[i]);
					sound.close();
				}
				catch (e:Exception)
				{
					DillyzLogger.log('Could not clear sound asset \'${keys[i]}\'; ${e.toString()}\n${e.message}', LogType.Error);
				}
			}
		}

		if (clearFrames)
		{
			var keys:Array<String> = cast(loadedFrames.keys().toArray());
			for (i in 0...keys.length)
			{
				try
				{
					var frames:FlxAtlasFrames = loadedFrames.get(keys[i]);
					loadedFrames.remove(keys[i]);
					frames.destroy();
				}
				catch (e:Exception)
				{
					DillyzLogger.log('Could not clear atlas frames \'${keys[i]}\'; ${e.toString()}\n${e.message}', LogType.Error);
				}
			}
		}
		System.gc();

		/*if (clearFonts)
			{
				var keys:Array<String> = cast(loadedFonts.keys().toArray());
				for (i in 0...keys.length)
				{
					try
					{
						var font:Font = loadedFonts.get(keys[i]);
						loadedFonts.remove(keys[i]);
						font.decompose();
					}
					catch (e:Exception)
					{
						DillyzLogger.log('Could not clear font \'${keys[i]}\'; ${e.toString()}\n${e.message}', LogType.Error);
					}
				}
		}*/
	}

	inline public static function asset(path:String, ?lib:Null<String>, ?fileExt:String = 'txt')
	{
		DillyzLogger.log('${fileExt.toUpperCase()} from library $lib at path $path ' #if MODS_ACTIVE + 'with mod $curMod ' #end + 'loading...',
			LogType.Normal);
		#if MODS_ACTIVE
		var modPath:String = 'mods/$curMod/$path.${fileExt.toLowerCase()}';
		if (FileSystem.exists(modPath))
			return modPath;
		#end

		// check preload
		var pathThing:String = 'assets/$path.${fileExt.toLowerCase()}';
		if (FileSystem.exists(pathThing))
			return pathThing;

		if (lib != null)
			pathThing = 'assets/$lib/$path.${fileExt.toLowerCase()}';

		if (FileSystem.exists(pathThing))
			return pathThing;
		DillyzLogger.log('Asset Missing at "${pathThing}"'
			#if MODS_ACTIVE + ' OR "${modPath}"' #end + '; Cannot find $fileExt asset at detected paths, as it does not exist or is the wrong format.',
			LogType.Error);
		return 'assets/catch/${fileExt.toLowerCase()}.${fileExt.toLowerCase()}';
	}

	inline public static function assetExists(path:String, ?lib:Null<String>, ?fileExt:String = 'txt')
	{
		#if MODS_ACTIVE
		var modPath:String = 'mods/$curMod/$path.${fileExt.toLowerCase()}';
		if (FileSystem.exists(modPath))
			return true;
		#end

		// check preload
		var pathThing:String = 'assets/$path.${fileExt.toLowerCase()}';
		if (FileSystem.exists(pathThing))
			return true;

		if (lib != null)
			pathThing = 'assets/$lib/$path.${fileExt.toLowerCase()}';

		if (FileSystem.exists(pathThing))
			return true;
		return false;
	}

	inline public static function png(path:String, ?lib:Null<String>):FlxGraphic
	{
		try
		{
			var assetID:String = '$lib:$path';

			if (loadedGraphics.exists(assetID))
			{
				var graphic = loadedGraphics.get(assetID);
				graphic.undump();
				return graphic;
			}

			var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromBytes(File.getBytes(asset('images/$path', lib, 'png'))));
			loadedGraphics.set(assetID, newGraphic);
			newGraphic.destroyOnNoUse = false;
			newGraphic.persist = true;
			return newGraphic;
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Image Asset Missing; ${e.toString()}\n${e.message}', LogType.Error);
			return PathDefaults.getGraphic();
		}
	}

	inline public static function stageSprite(path:String):FlxGraphic
	{
		try
		{
			var assetID:String = '$path';

			if (loadedGraphics.exists(assetID))
			{
				var graphic = loadedGraphics.get(assetID);
				graphic.undump();
				return graphic;
			}

			var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromBytes(File.getBytes(asset('$path', null, 'png'))));
			loadedGraphics.set(assetID, newGraphic);
			newGraphic.destroyOnNoUse = false;
			newGraphic.persist = true;
			// newGraphic.canBeDumped = false;
			return newGraphic;
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Stage Image Asset Missing; ${e.toString()}\n${e.message}', LogType.Error);
			return PathDefaults.getGraphic();
		}
	}

	inline public static function xml(path:String, ?lib:Null<String>):String
	{
		try
		{
			return File.getContent(asset('images/$path', lib, 'xml'));
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Xml-Based Text Asset Missing; ${e.toString()}\n${e.message}', LogType.Error);
			return
				'<?xml version="1.0" encoding="utf-8"?>\n<TextureAtlas imagePath="png.png">\n	<SubTexture name="caught0000" x="0" y="0" width="1" height="1"/>\n</TextureAtlas>';
		}
	}

	inline public static function txt(path:String, ?lib:Null<String>):String
	{
		try
		{
			return File.getContent(asset('data/$path', lib, 'txt'));
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Text Asset Missing; ${e.toString()}\n${e.message}', LogType.Error);
			return 'null lmfao';
		}
	}

	inline private static function baseJson(folder:String, path:String, ?lib:Null<String>, ?defaultThing:Null<Dynamic> = null):Dynamic
	{
		try
		{
			if (assetExists('$folder/$path', lib, 'json'))
				return Json.parse(File.getContent(asset('$folder/$path', lib, 'json')));
			else
			{
				DillyzLogger.log('Json Missing: $folder/$path.json not found or missing.', LogType.Error);
				return Json.parse(Json.stringify(defaultThing));
			}
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Json Missing; ${e.toString()}\n${e.message}', LogType.Error);
			if (defaultThing == null)
				defaultThing = {name: 'Default', value: 0};
			return Json.parse(Json.stringify(defaultThing));
		}
	}

	inline public static function weekJson(path:String, ?lib:Null<String>, ?defaultThing:Null<Dynamic> = null):Dynamic
	{
		return baseJson('weeks', path, lib, defaultThing);
	}

	inline public static function json(path:String, ?lib:Null<String>, ?defaultThing:Null<Dynamic> = null):Dynamic
	{
		return baseJson('data', path, lib, defaultThing);
	}

	inline public static function imageJson(path:String, ?lib:Null<String>, ?defaultThing:Null<Dynamic> = null):Dynamic
	{
		return baseJson('images', path, lib, defaultThing);
	}

	inline public static function menuButtonJson(path:String, ?defaultThing:Null<Dynamic> = null):Dynamic
	{
		return baseJson('images/menus/main menu buttons', path, null, defaultThing);
	}

	inline public static function stageSettingsJson(stage:String):Dynamic
	{
		try
		{
			if (assetExists('stages/$stage/settings', null, 'json'))
				return Json.parse(File.getContent(asset('stages/$stage/settings', null, 'json')));
			else
				return Json.parse(Json.stringify(FunkyStage.defaultData));
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Stage Json Missing; ${e.toString()}\n${e.message}', LogType.Error);
			return Json.parse(Json.stringify(FunkyStage.defaultData));
		}
	}

	inline public static function stageLuaExists(stage:String):Bool
	{
		return assetExists('stages/$stage/stage', null, 'lua');
	}

	public static function stageLua(stage:String):String
	{
		try
		{
			if (assetExists('stages/$stage/stage', null, 'lua'))
				return File.getContent(asset('stages/$stage/stage', null, 'lua'));
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Stage Lua Missing; ${e.toString()}\n${e.message}', LogType.Error);
		}
		return 'function onCreatePost() log("what am i doing", LogType.Normal) end';
	}

	inline public static function music(path:String):Sound
	{
		try
		{
			var assetID:String = '$path';

			if (loadedSounds.exists(assetID))
				return loadedSounds.get(assetID);

			var newSound:Sound = Sound.fromFile(asset('music/$path', null, 'ogg'));
			loadedSounds.set(assetID, newSound);
			return newSound;
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Music Missing; ${e.toString()}\n${e.message}', LogType.Error);
			return PathDefaults.getSound();
		}
	}

	inline public static function songInst(songName:String):Sound
	{
		try
		{
			var assetID:String = '$songName-SongINST';

			if (loadedSounds.exists(assetID))
				return loadedSounds.get(assetID);

			var newSound:Sound = Sound.fromFile(asset('songs/${songName.toLowerCase().replace(' ', '-')}/Inst', null, 'ogg'));
			loadedSounds.set(assetID, newSound);
			return newSound;
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Song Inst for $songName Missing; ${e.toString()}\n${e.message}', LogType.Error);
			return PathDefaults.getSound();
		}
	}

	inline public static function songVoices(songName:String):Sound
	{
		try
		{
			var assetID:String = '$songName-SongVOICES';

			if (loadedSounds.exists(assetID))
				return loadedSounds.get(assetID);

			var newSound:Sound = Sound.fromFile(asset('songs/${songName.toLowerCase().replace(' ', '-')}/Voices', null, 'ogg'));
			loadedSounds.set(assetID, newSound);
			return newSound;
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Song Voices for $songName Missing; ${e.toString()}\n${e.message}', LogType.Error);
			return PathDefaults.getSound();
		}
	}

	inline public static function sound(path:String, ?lib:Null<String>):Sound
	{
		try
		{
			var assetID:String = '$lib:$path';

			if (loadedSounds.exists(assetID))
				return loadedSounds.get(assetID);

			var newSound:Sound = Sound.fromFile(asset('sounds/$path', lib, 'ogg'));
			loadedSounds.set(assetID, newSound);
			return newSound;
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Sound Missing; ${e.toString()}\n${e.message}', LogType.Error);
			return PathDefaults.getSound();
		}
	}

	inline public static function songFile(path:String):Sound
	{
		try
		{
			var assetID:String = 'songs:$path';

			if (loadedSounds.exists(assetID))
				return loadedSounds.get(assetID);

			var newSound:Sound = Sound.fromFile(asset('$path', 'songs', 'ogg'));
			loadedSounds.set(assetID, newSound);
			return newSound;
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Song Folder/Files Missing; ${e.toString()}\n${e.message}', LogType.Error);
			return PathDefaults.getSound();
		}
	}

	inline public static function sparrowV2(path:String, ?lib:Null<String>):FlxAtlasFrames
	{
		try
		{
			var assetID:String = '$lib:$path';

			if (loadedFrames.exists(assetID))
				return loadedFrames.get(assetID);

			var newFrames:FlxAtlasFrames = FlxAtlasFrames.fromSparrow(png(path, lib), xml(path, lib));
			loadedFrames.set(assetID, newFrames);
			return newFrames;
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Sparrow V2 SpriteSheet Missing OR Invalid; ${e.toString()}\n${e.message}', LogType.Error);
			return PathDefaults.getFrames();
		}
	}

	inline public static function font(path:String, ?ext:String = 'ttf')
	{
		try
		{
			/*var assetID:String = 'font:$path';

				if (loadedFonts.exists(assetID))
					return loadedFonts.get(assetID);

				var newFont:Font = Font.fromBytes(File.getBytes(asset(path, 'fonts', ext)));
				loadedFonts.set(assetID, newFont);
				return newFont; */

			return asset('fonts/$path', null, ext); // 'assets/fonts/$path.${ext.toLowerCase()}';
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Font OR Invalid; ${e.toString()}\n${e.message}', LogType.Error);
			return 'assets/fonts/vcr.ttf'; // null;
		}
	}
}

class PathDefaults
{
	public static var defaultBitmap:BitmapData;

	public static function getBitmap():BitmapData
	{
		if (defaultBitmap == null)
			defaultBitmap = new BitmapData(1, 1, true, 0xFFFFFFFF);
		return defaultBitmap;
	}

	public static var defaultGraphic:FlxGraphic;

	public static function getGraphic():FlxGraphic
	{
		if (defaultGraphic == null)
			defaultGraphic = FlxGraphic.fromBitmapData(getBitmap());
		defaultGraphic.destroyOnNoUse = false;
		return defaultGraphic;
	}

	public static var defaultFrames:FlxAtlasFrames;

	public static function getFrames():FlxAtlasFrames
	{
		if (defaultFrames == null)
			defaultFrames = new FlxAtlasFrames(getGraphic(), getPoint());
		return defaultFrames;
	}

	public static var defaultPoint:FlxPoint;

	public static function getPoint():FlxPoint
	{
		if (defaultPoint == null)
			defaultPoint = new FlxPoint();
		return defaultPoint;
	}

	public static var defaultSound:Sound;

	public static function getSound():Sound
	{
		if (defaultSound == null)
			defaultSound = new Sound();
		return defaultSound;
	}
}

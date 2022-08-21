package managers;

import DillyzLogger.LogType;
import flixel.FlxG;
import gamestates.PlayState;
import haxe.Exception;
import lime.app.Application;
import llua.Convert;
import llua.Lua;
import llua.LuaL;
import llua.State;
import objects.FunkySprite;
import objects.characters.Character;

using StringTools;

class FunkyLuaManager
{
	var lua:State;

	public static var funcRet_Proceed:Int = 0;
	public static var funcRet_Block:Int = 1;
	public static var funcRet_Terminate:Int = 2;

	public function new(luaFileNameForDebugging:String, luaContents:String)
	{
		try
		{
			lua = LuaL.newstate();
			LuaL.openlibs(lua);
			Lua.init_callbacks(lua);
			trace("Lua version: " + Lua.version());
			trace("LuaJIT version: " + Lua.versionJIT());

			var ohGodDidItWork:Dynamic = LuaL.dostring(lua, luaContents);
			var endOwnEntityStr:String = Lua.tostring(lua, ohGodDidItWork);

			if (endOwnEntityStr != null && ohGodDidItWork != 0)
			{
				trace('AHHHHHHH IT DIDN\'T WORKKKKK AOHFAWJOW');
				DillyzLogger.log('Problem loading lua file "${luaFileNameForDebugging}"!\n${endOwnEntityStr}', LogType.Error);
				#if windows
				Application.current.window.alert(endOwnEntityStr, FlxG.random.bool(5) ? 'Warning: Lua Skill Issue Detected' : 'Warning: Improper Lua File');
				#end
				lua = null;
				return;
			}
			trace('WOOOOOOOOOOOOOOH YEAHHHHH BABY THAT\'S WHAT I\'VE BEEN WAITING FOR! THAT\'S WHAT IT\'S ALL ABOUT!!!');
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Invalid lua file! ${e.toString()}\n${e.message}', LogType.Error);
			return;
		}

		@:privateAccess {
			setVar('songName', PlayState.curSong.songName);
			setVar('dadName', PlayState.instance.charLeft.charName);
			setVar('gfName', PlayState.instance.charMid.charName);
			setVar('bfName', PlayState.instance.charRight.charName);

			Lua_helper.add_callback(lua, 'playAnim', function(sprite:String, animation:String, forced:Bool)
			{
				trace(sprite + ' ' + animation + ' ' + forced);

				getSpr(sprite).playAnim(animation, forced);
			});

			Lua_helper.add_callback(lua, 'funkyLog', function(message:String, logType:String)
			{
				var curLogType:LogType;

				switch (message)
				{
					case 'warning' | 'logWarning':
						curLogType = LogType.Warning;
					case 'error' | 'logError':
						curLogType = LogType.Error;
					default:
						curLogType = LogType.Normal;
				}

				DillyzLogger.log('From "${luaFileNameForDebugging}": $message', curLogType);
			});
		}
	}

	public function callFunction(functionName:String, arguments:Array<Dynamic>):Dynamic
	{
		if (lua == null)
			return funcRet_Proceed;

		try
		{
			Lua.getglobal(lua, functionName);
			if (Lua.type(lua, -1) != Lua.LUA_TFUNCTION)
				return funcRet_Proceed;

			for (argument in arguments)
				Convert.toLua(lua, argument);

			var possibleRet:Null<Int> = Lua.pcall(lua, arguments.length, 1, 0);
			if (!canGetResult(possibleRet))
				Lua.pop(lua, -1);
			else
			{
				var newRet:Dynamic = cast getLuaFuncRet(possibleRet);
				Lua.pop(lua, -1);
				if (newRet == null)
					return funcRet_Proceed;
				return newRet;
			}
		}
		catch (e:Exception)
		{
			DillyzLogger.log('Failed to find lua function $functionName! arguments: $arguments', LogType.Warning);
		}
		return funcRet_Proceed;
	}

	function canGetResult(res:Int)
	{
		var luaType:Int = Lua.type(lua, res);
		return luaType >= Lua.LUA_TNIL && luaType < Lua.LUA_TTABLE && luaType != Lua.LUA_TLIGHTUSERDATA;
	}

	function getLuaFuncRet(res:Int):Any
	{
		var newRet:Any = null;

		switch (Lua.type(lua, res))
		{
			case Lua.LUA_TBOOLEAN:
				newRet = Lua.toboolean(lua, -1);
			case Lua.LUA_TNUMBER:
				newRet = Lua.tonumber(lua, -1);
			case Lua.LUA_TSTRING:
				newRet = Lua.tostring(lua, -1);
		}

		return newRet;
	}

	public function getSpr(spr:String):FunkySprite
	{
		@:privateAccess {
			var curChar:Character;

			switch (spr.toLowerCase())
			{
				case 'dad' | 'charleft' | 'daddy' | 'dearest' | 'd':
					curChar = PlayState.instance.charLeft;
				case 'gf' | 'charmid' | 'girlfriend' | 'girl' | 'g':
					curChar = PlayState.instance.charMid;
				default:
					curChar = PlayState.instance.charRight;
			}
			return curChar;
		}
	}

	// https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/FunkinLua.hx#L3185
	public function setVar(varName:String, value:Dynamic)
	{
		if (lua == null)
			return;
		Convert.toLua(lua, value);
		Lua.setglobal(lua, varName);
	}

	// https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/FunkinLua.hx#L3196
	public function getBool(varName:String, ?defaultValue:Bool = false):Bool
	{
		if (lua == null)
			return defaultValue;
		Lua.getglobal(lua, varName);
		var res:String = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		return (res == null) ? defaultValue : (res == 'true');
	}

	public function getInt(varName:String, ?defaultValue:Int = 0):Int
	{
		if (lua == null)
			return defaultValue;
		Lua.getglobal(lua, varName);
		var res:String = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		return (res == null) ? defaultValue : Std.parseInt(res);
	}

	public function getFloat(varName:String, ?defaultValue:Float = 0.0):Float
	{
		if (lua == null)
			return defaultValue;
		Lua.getglobal(lua, varName);
		var res:String = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		return (res == null) ? defaultValue : Std.parseFloat(res);
	}

	public function getString(varName:String, ?defaultValue:String = ''):String
	{
		if (lua == null)
			return defaultValue;
		Lua.getglobal(lua, varName);
		var res:String = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		return (res == null) ? defaultValue : res;
	}

	public function stopLua()
	{
		if (lua == null)
			return;
		Lua.close(lua);
		lua = null;
	}
}

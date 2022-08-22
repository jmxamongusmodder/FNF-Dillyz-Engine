package;

import crashdumper.SystemData;
import flixel.FlxG;
import haxe.CallStack;
import haxe.CallStack;
import openfl.events.UncaughtErrorEvent;

using StringTools;

#if LOGS_ENABLED
import sys.FileSystem;
import sys.io.File;
#end

enum LogType
{
	Normal;
	Warning;
	Error;
	Unknown;
}

class DillyzLogger
{
	#if LOGS_ENABLED
	static var startUpDayDate:String = '0-0-0000';
	static var startUpDayTime:String = '00:00:00AM';

	static var logFileName:String = 'FNF Dillyz Engine (Null)';

	static var allLogs:Array<String> = [];

	static var newSystemData:SystemData;

	@:allow(Main)
	inline private static function setLogDate()
	{
		newSystemData = new SystemData();
		startUpDayDate = '${(Date.now().getUTCMonth() + 1)}-${Date.now().getUTCDate()}-${Date.now().getUTCFullYear()}';
		startUpDayTime = '${(Date.now().getUTCHours() % 12) + 1}-${Date.now().getUTCMinutes()}-${Date.now().getUTCSeconds()}${Date.now().getUTCHours() >= 12 ? 'PM' : 'AM'}';
		logFileName = 'FNF Dillyz Engine (Instance $startUpDayDate at $startUpDayTime)';
	}
	#end

	inline private static function logTypeToString(logType:LogType = LogType.Normal, oldExtraInfo:String = '')
	{
		var dayDate:String = '${(Date.now().getUTCMonth() + 1)}-${Date.now().getUTCDate()}-${Date.now().getUTCFullYear()}';
		var dayTime:String = '${(Date.now().getUTCHours() % 12) + 1}:${Date.now().getUTCMinutes()}:${Date.now().getUTCSeconds()}${Date.now().getUTCHours() >= 12 ? 'PM' : 'AM'}';
		var extraInfo = '$dayDate @$dayTime ${Date.now().getSeconds()}s';
		if (oldExtraInfo != '')
			extraInfo += ' $oldExtraInfo';
		switch (logType)
		{
			case Normal:
				return '[${extraInfo}]';
			case Warning:
				return '[WARNING - ${extraInfo}]';
			case Error:
				return '[ERROR - ${extraInfo}]';
			default:
				return '[UNKNOWN-  ${extraInfo}]';
		}
	}

	/*inline private static function getLogType(strType:String)
		{
			switch (strType.toLowerCase().trim())
			{
				case 'normal':
					return LogType.Normal;
				case 'warning':
					return LogType.Warning;
				case 'error':
					return LogType.Error;
				default:
					return LogType.Unknown;
			}
	}*/
	static var lastLogTime:Float = -2;

	inline public static function log(newLine:String, ?logType:LogType = LogType.Normal)
	{
		if (newLine.contains('\n'))
		{
			var newStuffs:Array<String> = newLine.split('\n');

			for (i in newStuffs)
				log(i, logType);

			return;
		}
		var loggedLine = '${logTypeToString(logType)} $newLine';
		#if debug
		trace(loggedLine);
		#end
		#if LOGS_ENABLED
		allLogs.push(loggedLine);

		if (Sys.time() >= lastLogTime + 2)
			writeLog();
		#end
	}

	#if LOGS_ENABLED
	inline public static function writeLog()
	{
		lastLogTime = Sys.time();
		if (!FileSystem.exists('logs/'))
			FileSystem.createDirectory('logs/');
		var logText:String = '--==<( Friday Night Funkin\': Dillyz Engine 2022 Log )>==--\n'
			+ '> Operating System: ${newSystemData.osName} (Version ${newSystemData.osVersion})\n'
			+ '> CPU: ${newSystemData.cpuName}\n'
			+ '> GPU: ${newSystemData.gpuName} (Driver Version ${newSystemData.gpuDriverVersion})\n'
			+ '> Initial Day: $startUpDayDate\n'
			+ '> Initial Time: $startUpDayTime\n'
			+ '> Last Log Day: ${(Date.now().getUTCMonth() + 1)}-${Date.now().getUTCDate()}-${Date.now().getUTCFullYear()}\n'
			+
			'> Last Log Time: ${(Date.now().getUTCHours() % 12) + 1}-${Date.now().getUTCMinutes()}-${Date.now().getUTCSeconds()}${Date.now().getUTCHours() >= 12 ? 'PM' : 'AM'}\n' /*+ '> Current Library: ${Paths.curLib}\n'*/ #if MODS_ACTIVE +
		'> Current Mod: ${Paths.curMod}\n' #end
		+ '\nIf the game has crashed, send this report to https://github.com/DillyzThe1/Dillyz-Engine/issues\n\n\n-----== LOGS START HERE ==-----\n';

		for (i in allLogs)
			logText += '$i\n';

		logText += '-----== LOGS END HERE ==-----';

		File.saveContent('logs/$logFileName.txt', logText);
	}
	#end

	#if LOGS_ENABLED
	inline public static function writeCrash(e:UncaughtErrorEvent)
	{
		var randomFunnies:Array<String> = [
			'SMH SMH SMH can\'t believe uncle fred would do this.',
			'Guess we can\'t find who asked.',
			'This is going in my cringe compilation.',
			'Maybe get funnier jokes?',
			'So, what now?',
			'No, really. Just submit this already. What are you waiting for?!',
			'Null object reference; Cannot find father figure.',
			'Time to cry on github.',
			'This is my fault, not NinjaMuffin99\'s. (somehow)',
			'Guess I got chat reported again... :/',
			'YOU KNOW WHAT ELSE JUST CRASHED?!',
			'Do you know what you\'re doing?',
			'Oh, but if you loaded a bambi song, don\'t even bother sending this.',
			'I totally didn\'t steal the random crash note thing from something. Not at all.',
			'Time to go outside and get some girls?',
			'However, the horse is here.',
			'Too bad you don\'t know what this means! Lmao!'
		];
		if (!FileSystem.exists('crash_logs/'))
			FileSystem.createDirectory('crash_logs/');
		var logText:String = '--==<( Friday Night Funkin\': Dillyz Engine 2022 Crash Log )>==--\n'
			+ '> Operating System: ${newSystemData.osName} (${newSystemData.osVersion})\n'
			+ '> CPU: ${newSystemData.cpuName}\n'
			+ '> GPU: ${newSystemData.gpuName} (Driver Version ${newSystemData.gpuDriverVersion})\n'
			+ '> Initial Day: $startUpDayDate\n'
			+ '> Initial Time: $startUpDayTime\n'
			+ '> Crash Day: ${(Date.now().getUTCMonth() + 1)}-${Date.now().getUTCDate()}-${Date.now().getUTCFullYear()}\n'
			+
			'> Crash Time: ${(Date.now().getUTCHours() % 12) + 1}-${Date.now().getUTCMinutes()}-${Date.now().getUTCSeconds()}${Date.now().getUTCHours() >= 12 ? 'PM' : 'AM'}\n' /*+ '> Current Library: ${Paths.curLib}\n'*/ #if MODS_ACTIVE +
		'> Current Mod: ${Paths.curMod}\n' #end
		+ '\nWhoops, the game has Crashed! ${randomFunnies[FlxG.random.int(0, randomFunnies.length - 1)]}'
		+ '\nPlease send this report to https://github.com/DillyzThe1/Dillyz-Engine/issues\n\n\n-----== LOGS START HERE ==-----\n';

		for (i in allLogs)
			logText += '$i\n';

		logText += '-----== LOGS END HERE ==-----\n';

		logText += '\n\n-----== CRASH INFO STARTS HERE ==-----\n';
		logText += 'Exception "${e.error}" thrown.\n';
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					logText += 'at $file (line $line, column $column) $s\n';
				default:
					logText += stackItem;
			}
		}
		logText += '-----== CRASH INFO ENDS HERE ==-----';

		File.saveContent('crash_logs/$logFileName.txt', logText);
	}
	#end
}

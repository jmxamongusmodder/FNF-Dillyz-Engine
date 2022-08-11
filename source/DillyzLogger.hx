package;

#if LOGS_ENABLED
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

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

	@:allow(Main)
	inline private static function setLogDate()
	{
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

		writeLog();
		#end
	}

	#if LOGS_ENABLED
	inline public static function writeLog()
	{
		if (!FileSystem.exists('logs/'))
			FileSystem.createDirectory('logs/');
		var logText:String = '--==<( Friday Night Funkin\': Dillyz Engine 2022 Log )>==--\n'
			+ '> Day: $startUpDayDate\n'
			+ '> Time: $startUpDayTime\n'
			+ '> Current Library: ${Paths.curLib}\n' #if MODS_ACTIVE + '> Current Mod: ${Paths.curMod}\n' #end
		+ '\nIf the game has crashed, send this report to https://github.com/DillyzThe1/Dillyz-Engine/issues\n\n\n-----== LOGS START HERE ==-----\n';

		for (i in allLogs)
			logText += '$i\n';

		logText += '-----== LOGS END HERE ==-----';

		File.saveContent('logs/$logFileName.txt', logText);
	}
	#end
}

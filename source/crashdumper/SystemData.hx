package crashdumper;

import sys.FileSystem;
import sys.io.File;
#if sys
import sys.io.Process;
#end
#if flash
import flash.system.Capabilities;
#end

/**
 *	https://github.com/larsiusprime/crashdumper/blob/master/crashdumper/SystemData.hx
 * A simple data structure that records data about the user's system.
 * 
 * usage: var s = new SystemData();
 * 
 * @author larsiusprime
 */
class SystemData
{
	public var os:String; // simple constant matching the haxedef -- "windows", "mac", "linux", etc
	public var osRaw:String; // raw output from command-line OS identifier -- "Microsoft Windows [Version 6.1.7601]"
	public var osName:String; // common product name of OS -- "Windows 7", "Ubuntu 14.10", "OSX Snow Leopard", "Android KitKat"
	public var osVersion:String; // version number of OS -- "6.1.7601, 14.10, 10.6, 4.4" (for the above 4 examples)
	public var totalMemory:Int; // total visible memory, in kilobytes, except for mac where it's in gigabytes
	public var cpuName:String; // the name of your cpu, -- "Intel(R) Core(TM)2 Duo CPU     E7400  @ 2.80GHz"
	public var gpuName:String; // the name of your gpu, -- "ATI Radeon HD 4800 Series"
	public var gpuDriverVersion:String; // version number of gpu driver, -- "8.970.100.1100"

	#if flash
	public var playerVersion:String; // version number of the flash player, ie "WIN 12,0,0,77"
	public var playerType:String;
	#end

	public function new()
	{
		#if windows
		os = "windows";
		#elseif mac
		os = "mac";
		#elseif linux
		os = "linux";
		#elseif android
		os = "android";
		#elseif ios
		os = "ios";
		#elseif flash
		osName = flash.system.Capabilities.os + " (flash)";
		playerType = flash.system.Capabilities.playerType;
		playerVersion = flash.system.Capabilities.version;
		cpuName = flash.system.Capabilities.cpuArchitecture;
		totalMemory = 0;
		gpuName = "unknown";
		gpuDriverVersion = "unknown";
		#end

		try
		{
			if (!FileSystem.exists('./logs/'))
				FileSystem.createDirectory('./logs/');
			if (!FileSystem.exists('./logs/sys_info/'))
				FileSystem.createDirectory('./logs/sys_info/');
			#if windows
			runProcess("@echo off\ncall ver", "logs/sys_info/os.bat", [], processOS);
			runProcess("@echo off\nwmic OS get TotalVisibleMemorySize /Value <nul", "logs/sys_info/memory.bat", [], processMemory);
			runProcess("@echo off\nwmic cpu get name /Value <nul", "logs/sys_info/cpu.bat", [], processCPU);
			runProcess("@echo off\nwmic PATH Win32_VideoController get name /Value <nul\necho ,\nwmic PATH Win32_VideoController get driverversion /Value <nul",
				"logs/sys_info/gpu.bat", [], processGPU);
			#elseif linux
			// must set file to executable first
			runProcess(null, "chmod", ["a+x", "logs/sys_info/os.sh"], dummy);
			runProcess(null, "chmod", ["a+x", "logs/sys_info/memory.sh"], dummy);
			runProcess(null, "chmod", ["a+x", "logs/sys_info/cpu.sh"], dummy);
			runProcess(null, "chmod", ["a+x", "crashdusys_infomper/gpu.sh"], dummy);

			runProcess("#!/bin/bash\nlsb_release -a | grep \"Description\" | awk -F':' '{print $2}' ; uname -m", "logs/sys_info/os.sh", [], processOS);
			runProcess("#!/bin/bash\ncat /proc/meminfo | grep MemTotal | awk -F ':' '{print $2}'", "logs/sys_info/memory.sh", [], processMemory);
			runProcess("#!/bin/bash\ncat /proc/cpuinfo | grep -m 1 \"model name\" | awk -F': ' '{print $2}'", "logs/sys_info/cpu.sh", [], processCPU);
			runProcess("#!/bin/bash\nlspci | grep VGA | awk -F ':' '{print $3}'", "logs/sys_info/gpu.sh", [], processGPU);
			#elseif mac
			// must set file to executable first
			runProcess(null, "chmod", ["a+x", "logs/sys_info/os.sh"], dummy);
			runProcess(null, "chmod", ["a+x", "logs/sys_info/memory.sh"], dummy);
			runProcess(null, "chmod", ["a+x", "logs/sys_info/cpu.sh"], dummy);
			runProcess(null, "chmod", ["a+x", "logs/sys_info/gpu.sh"], dummy);

			runProcess("#!/bin/bash\ndetail=`system_profiler SPHardwareDataType -detailLevel mini`\nmodelName=`echo \"$detail\" | grep -m 1 \"Model Name\" | awk -F': ' '{print $2}'`\nmodelIdentifier=`echo \"$detail\" | grep -m 1 \"Model Identifier\" | awk -F': ' '{print $2}'`\ndetail=`system_profiler SPSoftwareDataType -detailLevel mini`\nosVersion=`echo \"$detail\" | grep -m 1 \"System Version\" | awk -F': ' '{print $2}'`\necho $osVersion $modelName $modelIdentifier",
				"logs/sys_info/os.sh", [], processOS);
			runProcess("#!/bin/bash\ndetail=`system_profiler SPHardwareDataType -detailLevel mini`\nmemory=`echo \"$detail\" | grep -m 1 \"Memory\" | awk -F': ' '{print $2}'`\necho $memory",
				"logs/sys_info/memory.sh", [], processMemory);
			runProcess("#!/bin/bash\ndetail=`system_profiler SPHardwareDataType -detailLevel mini`\ncpuType=`echo \"$detail\" | grep -m 1 \"Processor Name\" | awk -F': ' '{print $2}'`\ncpuSpeed=`echo \"$detail\" | grep -m 1 \"Processor Speed\" | awk -F': ' '{print $2}'`\necho $cpuType $cpuSpeed",
				"logs/sys_info/cpu.sh", [], processCPU);
			runProcess("#!/bin/bash\ndetail=`system_profiler SPDisplaysDataType`\nchipset=`echo \"$detail\" | grep -m 1 \"Chipset Model\" | awk -F': ' '{print $2}'`\nmemory=`echo \"$detail\" | grep -m 1 \"VRAM\" | awk -F': ' '{print $2}'`\nresolution=`echo \"$detail\" | grep -m 1 \"Resolution\" | awk -F': ' '{print $2}'`\necho $chipset $memory $resolution",
				"logs/sys_info/gpu.sh", [], processGPU);
			#end
		}
		catch (msg:Dynamic)
		{
			trace("error creating SystemData : " + msg);
		}
	}

	private function dummy(line:String):Void
	{
		// this is because runprocess() must accept function
	}

	public function summary():String
	{
		#if flash
		return "SystemData" + endl() + "{" + endl() + "   OS: " + osName + endl() + "FLASH: " + playerType + " v. " + playerVersion + endl() + "  CPU: "
			+ cpuName + endl() + "}";
		#else
		return "SystemData" + endl() + "{" + endl() + "  OS : " + osName + endl() + "  RAM: " + totalMemory + " KB (" + toGBStr(totalMemory) + " GB)"
			+ endl() + "  CPU: " + cpuName + endl() + "  GPU: " + gpuName + ", driver v. " + gpuDriverVersion + endl() + "}";
		#end
	}

	public function toString():String
	{return "SystemData" + "\n" + "{" + endl() + "  os: " + os + "\n" + "  osRaw: " + osRaw + "\n" + "  osName: " + osName + "\n" + "  osVersion: "
		+ osVersion + "\n" + #if flash "  playerType: " + playerType + "\n" + "  playerVersion: " + playerVersion + "\n" + #end
		"  totalMemory: "
		+ toGBStr(totalMemory)
		+ "\n"
		+ "  cpuName: "
		+ cpuName
		+ "\n"
		+ "  gpuName: "
		+ gpuName
		+ "\n"
		+ "  gpuDriverVersion: "
		+ gpuDriverVersion
		+ "\n"
		+ "}";
	}

	private function toMB(kilobytes:Int):Float
	{
		return kilobytes / (1024);
	}

	private function toGB(kilobytes:Int):Float
	{
		return kilobytes / (1024 * 1024);
	}

	private function toGBStr(kilobytes:Int):String
	{
		var gb:Float = toGB(kilobytes);
		gb = Math.round(gb * 100) / 100;
		return Std.string(gb);
	}

	private function runProcess(commandText:String, commandStr:String, commandArgs:Array<String>, processFunc:String->Void):Void
	{
		#if sys
		if (commandText != null && !FileSystem.exists(commandStr))
		{
			File.saveContent(commandStr, commandText);
		}

		var p:Process = null;
		try
		{
			p = new Process(commandStr, commandArgs);
		}
		catch (msg:String)
		{
			p = null;
		}
		if (p != null)
		{
			p.exitCode();
			var str:String = p.stdout.readAll().toString();
			p.close();
			processFunc(str);
		}
		#end
	}

	private function isOneOfThese(char:String, arr:Array<String>):Bool
	{
		for (str in arr)
		{
			if (char == str)
			{
				return true;
			}
		}
		return false;
	}

	private function processOS(line:String):Void
	{
		if (line == null)
		{
			line = "unknown"; // avoid null error when parsing
		}
		#if windows
		// ver returns something like this: "Microsoft Windows [Version 6.1.7601]", localized
		// we wanna strip away everything but the number

		line = stripEndLines(line);
		osRaw = line;
		line = line.toLowerCase();
		line = stripWhiteSpace(line);

		// chomp away everything before the "[" and after the "]"
		if (line.indexOf("[") != -1)
		{
			while (line.charAt(0) != "[")
			{
				line = line.substr(1, line.length - 1);
			}
		}
		if (line.indexOf("]") != -1)
		{
			while (line.charAt(line.length - 1) != "]")
			{
				line = line.substr(0, line.length - 1);
			}
		}

		// now we have something like this: "[versionX.Y.Z]"
		// where X.Y.Z are numbers and "version" is locale-specific

		// strip the "[]" chars
		line = stripWord(line, "[");
		line = stripWord(line, "]");

		var numAndDot:Array<String> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."];

		// strip away all non-number and non-dot characters

		if (line.length > 0 && !isOneOfThese(line.charAt(0), numAndDot))
		{
			while (line.length > 0 && !isOneOfThese(line.charAt(0), numAndDot))
			{
				line = line.substr(1, line.length - 1);
			}
		}

		// now we have a string we can safely compare against known values
		osVersion = line;

		// check for windows 10
		if (osVersion.substr(0, 2) == "10")
		{
			osName = checkWindows10Version(osVersion);
		}
		else
		{
			switch (line)
			{
				case "3.10.103":
					osName = "Windows 3.1";
				case "4.00.950":
					osName = "Windows 95";
				case "4.00.1111":
					osName = "Windows 95 OSR2";
				case "4.00.1381":
					osName = "Windows NT 4.0";
				case "4.10.1998":
					osName = "Windows 98";
				case "4.10.2222":
					osName = "Windows 98 SE";
				case "4.90.3000":
					osName = "Windows ME";
				case "5.00.2195":
					osName = "Windows 2000";
				case "5.1.2600":
					osName = "Windows XP";
				case "6.0.6000":
					osName = "Windows Vista";
				case "6.0.6002":
					osName = "Windows Vista SP2";
				case "6.1.7600":
					osName = "Windows 7";
				case "6.1.7601":
					osName = "Windows 7 SP1";
				case "6.2.9200":
					osName = "Windows 8";
				case "6.3.9600":
					osName = "Windows 8.1";
				default:
					osName = "Windows (unknown version)";
			}
		}
		#elseif linux
		var temp = line.split("\n");
		if (temp != null && temp.length >= 2)
		{
			osName = temp[0] + " (" + temp[1] + ")";
		}
		#elseif mac
		line = stripEndLines(line);
		osName = line;
		#end
	}

	private function checkWindows10Version(line:String):String
	{
		// the specific windows 10 version is determined by the last number in the string
		var versionNumber:Int = Std.parseInt(line.substr(line.lastIndexOf(".") + 1));

		// all versions under 10240 are preview releases
		if (versionNumber < 10240)
		{
			return "Windows 10 (Pre-release)";
		}
		// 10240 is the original release version
		else if (versionNumber == 10240)
		{
			return "Windows 10 (TH1)";
		}
		// versions up until 10586 are part of the second wave of updates
		else if (versionNumber > 10240 && versionNumber <= 10586)
		{
			return "Windows 10 (TH2)";
		}
		else
		{
			return "Windows 10 (Unknown Specific Version)";
		}
	}

	private function processMemory(line:String):Void
	{
		#if windows
		line = stripWhiteSpace(line);
		if (line.indexOf("TotalVisibleMemorySize=") != -1)
		{
			line = stripWord(line, "TotalVisibleMemorySize=");
			totalMemory = Std.parseInt(line);
		}
		#elseif linux
		totalMemory = Std.parseInt(line);
		#elseif mac
		totalMemory = Std.parseInt(line) * 1024 * 1024;
		#end
	}

	private function processCPU(line:String):Void
	{
		#if windows
		line = stripEndLines(line);
		if (line != null && line.indexOf("Name=") != -1)
		{
			cpuName = stripWord(line, "Name=");
		}
		else
		{
			cpuName = "unknown";
		}
		#elseif linux
		cpuName = stripWord(line, "\n");
		#elseif mac
		cpuName = stripEndLines(line);
		#end
	}

	private function processGPU(line:String):Void
	{
		#if windows
		gpuName = "unknown";
		gpuDriverVersion = "unknown";
		var arr:Array<String> = line.split(",");
		if (arr != null && arr.length == 2)
		{
			for (str in arr)
			{
				str = stripEndLines(str);
				if (str.indexOf("Name=") != -1)
				{
					gpuName = stripWord(str, "Name=");
				}
				else if (str.indexOf("DriverVersion=") != -1)
				{
					gpuDriverVersion = stripWord(str, "DriverVersion=");
				}
			}
		}
		#elseif linux
		gpuName = line;
		gpuDriverVersion = "unknown";
		#elseif mac
		gpuName = line;
		gpuDriverVersion = "unknown";
		#end
	}

	public static function endl():String
	{
		#if windows
		return "\r\n";
		#end
		return "\n";
	}

	public static function slash():String
	{
		#if windows
		return "\\";
		#end
		return "/";
	}

	public static function replaceWord(line:String, word:String, replace:String):String
	{
		if (word == replace)
		{
			return line;
		}
		while (line.indexOf(word) != -1)
		{
			line = StringTools.replace(line, word, replace);
		}
		return line;
	}

	public static function stripWord(line:String, word:String):String
	{
		while (line.indexOf(word) != -1)
		{
			line = StringTools.replace(line, word, "");
		}
		return line;
	}

	public static function stripEndLines(str:String):String
	{
		str = stripWord(str, "\n");
		str = stripWord(str, "\r");
		return str;
	}

	public static function stripWhiteSpace(str:String):String
	{
		str = stripWord(str, " ");
		str = stripWord(str, "\t");
		return str;
	}
}

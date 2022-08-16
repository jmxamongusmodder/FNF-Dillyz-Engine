cls
@echo off
title FNF Dillyz Engine - Library Installer and Setup
echo.
echo This batch file will automatically setup all the libraries and whatnot for you.
echo If it can't automatically do something, it'll point you in the direction.
echo.
set /p menu="Install libraries? [Y/N/C]"
       if %menu%==Y goto CheckLibraries
       if %menu%==y goto CheckLibraries
       if %menu%==N goto CancelLibraries
       if %menu%==n goto CancelLibraries
       if %menu%==C goto Credits
       if %menu%==c goto Credits
       cls
	   
:CancelLibraries
cls
echo.
echo Library installation cancelled.
echo.
echo Press any key to continue.
pause>nul
exit

:CheckLibraries
title FNF Dillyz Engine - Library Installer and Setup (Active)
cls
echo.
haxe -version >nul 2>&1 && (
	echo "haxe has been installed"
	haxe -version
) || (
	echo "haxe is not installed"
	set /p menu="Do you want to install 64bit? [Y/N]"
       if %menu%==Y start https://haxe.org/download/file/4.2.4/haxe-4.2.4-win64.exe/
       if %menu%==y start https://haxe.org/download/file/4.2.4/haxe-4.2.4-win64.exe/
       if %menu%==N start https://haxe.org/download/file/4.2.4/haxe-4.2.4-win.exe/
       if %menu%==n start https://haxe.org/download/file/4.2.4/haxe-4.2.4-win.exe/
       cls

	echo.
	echo Please run this file.
	echo One it is done installing, press any key to continue.
	pause>nul
)

::lime -version >nul 2>&1 && (
::	echo "lime has been installed"
::	lime -version
::) || (
::	echo "lime is not installed"
::)

::lime 
haxelib install lime
haxelib run lime setup

:: openfl
haxelib install openfl

:: flixel
haxelib install flixel
haxelib run lime setup flixel

:: flixel-tools
haxelib install flixel-tools
haxelib run flixel-tools setup

:: flixel-addons
haxelib install flixel-addons
haxelib run flixel-addons setup

:: flixel-ui
haxelib install flixel-ui
haxelib run flixel-ui setup

:: update it
haxelib update lime
haxelib update openfl
haxelib update flixel
haxelib update flixel-tools
haxelib update flixel-addons
haxelib update flixel-ui

echo Press any key to continue.
pause>nul
goto FinishLibraries

:FinishLibraries
cls
title FNF Dillyz Engine - Library Installer and Setup (Done)
echo.
echo All libraries have been installed; you can now use "build.bat".
echo.
echo Press any key to continue.
pause>nul
exit


:Credits
cls
title FNF Dillyz Engine - Credits
echo FNF Dillyz Engine
echo.
echo Programming & custom animator link:
echo https://www.github.com/DillyzThe1
echo Original FNF dev links:
echo https://github.com/ninjamuffin99
echo https://twitter.com/phantomarcade3k
echo https://twitter.com/evilsk8r
echo https://twitter.com/kawaisprite
echo.
echo.
echo Press any key to continue.
pause>nul
exit
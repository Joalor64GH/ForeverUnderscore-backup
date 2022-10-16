@echo off
color 0a
title FNF: Forever Engine - Building Game (DEBUG MODE)
cd ..
echo BUILDING...
echo IF IT CRASHES AFTER THE TITLESCREEN OR WHEN GOING TO PLAYSTATE
echo TRY BINDING THE RESET KEYS TO ANYTHING ON A RELEASE BUILD
haxelib run lime build windows -debug -D enableUpdater
echo.
echo DONE.
pause
pwd
explorer.exe export\debug\windows\bin
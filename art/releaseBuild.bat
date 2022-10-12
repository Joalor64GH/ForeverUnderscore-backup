@echo off
color 0a
title FNF: Forever Engine - Building Game (RELEASE MODE)
cd ..
echo BUILDING...
haxelib run lime build windows -release -D enableUpdater
echo.
echo DONE.
pause
pwd
explorer.exe export\release\windows\bin
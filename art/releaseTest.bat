@echo off
color 0a
title FNF: Forever Engine - Running Game (RELEASE MODE)
cd ..
echo BUILDING...
haxelib update
haxelib run lime test windows -release -D enableUpdater
echo.
echo DONE.
pause
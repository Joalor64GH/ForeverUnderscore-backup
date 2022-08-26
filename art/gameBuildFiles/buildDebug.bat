@echo off
color 0a
title FNF: Forever Engine - Building Game (DEBUG MODE)
cd ..
cd ..
echo BUILDING...
echo DEBUG IS CURRENTLY BROKEN!!!
echo IF YOU GET ANY FARTHER THAN THE TITLESCREEN
echo PLEASE REPORT TO THE DEVELOPERS
lime build windows -debug
echo.
echo DONE.
pause
pwd
explorer.exe export\debug\windows\bin
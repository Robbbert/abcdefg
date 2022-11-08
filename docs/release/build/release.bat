@echo off
echo HAVE YOU UPDATED the version number in WINUI.H and MAKEFILE ???
pause


call newsrc.bat
call clean.bat
call clean.bat
call clean.bat
call clean.bat
goto 64bit

rem --- 32bit ---
del arcade32.exe
del arcade32.sym
call make32 -j4 %1 %2 %3
if not exist arcade32.exe goto end

:64bit
rem --- 64bit ---
call make.bat
if not exist arcade64.exe goto end

cls
echo Compile was successful.
echo.
echo 7Z up each exe;
echo and RAR the source.

:end

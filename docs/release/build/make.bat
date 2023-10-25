@echo off
del arcade64.sym
del build\generated\resource\mamevers.rc
:start
del arcade64.exe
if exist arcade64.exe goto start
copy /Y src\mame\arcade.txt src\mame\arcade.flt
touch src\mame\arcade.flt
rem call mk.bat
call make64 -j4 "OSD=winui" %1 %2 %3
if not exist arcade64.exe goto end
del a.exe
copy /Y arcade64.exe a.exe
:end

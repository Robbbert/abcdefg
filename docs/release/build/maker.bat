@echo off
del mamearcade.sym
del build\generated\resource\mamevers.rc
:start
del mamearcade.exe
if exist mamearcade.exe goto start
copy /Y src\mame\arcade.flt src\mame\arcade.bak
copy /Y src\mame\arcade.txt src\mame\arcade.flt
touch src\mame\arcade.flt
del C:\ARCADE\build\projects\windows\mamearcade\gmake-mingw64-gcc\Makefile
call make64 -j6 "ARCHOPTS='-fuse-ld=lld'" %1 %2 %3
copy /Y src\mame\arcade.bak src\mame\arcade.flt
copy /Y mamearcade.* a.*

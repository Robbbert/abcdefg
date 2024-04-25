set from=C:\ARCADE
set to=c:\ARCADE\docs\release

rd %to%\src /q /s
rd %to%\scripts /q /s
rd %to%\build /q /s

copy    %from%\makefile                             %to%

md %to%\src\devices\machine
copy /Y %from%\src\devices\machine\atastorage.cpp   %to%\src\devices\machine

md %to%\src\devices\sound
copy /Y %from%\src\devices\sound\qs1000.cpp         %to%\src\devices\sound

md %to%\src\devices\cpu\psx
copy /Y %from%\src\devices\cpu\psx\irq.cpp          %to%\src\devices\cpu\psx

md %to%\src\devices\video
copy /Y %from%\src\devices\video\psx.cpp            %to%\src\devices\video

md %to%\src\emu
copy /Y %from%\src\emu\emuopts.*                    %to%\src\emu
copy /Y %from%\src\emu\ioport.*                     %to%\src\emu
copy /Y %from%\src\emu\romload.h                    %to%\src\emu
copy /Y %from%\src\emu\video.*                      %to%\src\emu
copy /Y %from%\src\emu\machine.*                    %to%\src\emu
copy /Y %from%\src\emu\main.*                       %to%\src\emu
copy /Y %from%\src\emu\emufwd.h                     %to%\src\emu

md %to%\src\frontend\mame\ui
xcopy /S %from%\src\frontend\mame\ui\*.*            %to%\src\frontend\mame\ui
copy /Y %from%\src\frontend\mame\audit.*            %to%\src\frontend\mame
copy /Y %from%\src\frontend\mame\clifront.cpp       %to%\src\frontend\mame

md %to%\src\mame
xcopy /T %from%\src\mame                            %to%\src\mame
copy /Y %from%\src\mame\mame.cpp                    %to%\src\mame
copy /Y %from%\src\mame\arcade.txt                  %to%\src\mame\arcade.flt
copy %from%\src\mame\capcom\cps1_v.cpp              %to%\src\mame\capcom
copy %from%\src\mame\capcom\fcrash.cpp              %to%\src\mame\capcom
copy %from%\src\mame\dataeast\scregg.cpp            %to%\src\mame\dataeast
copy %from%\src\mame\efo\cidelsa_v.cpp              %to%\src\mame\efo
copy %from%\src\mame\galaxian\galaxian.cpp          %to%\src\mame\galaxian
copy %from%\src\mame\igs\pgm2.cpp                   %to%\src\mame\igs
copy %from%\src\mame\igs\pgm2.h                     %to%\src\mame\igs
copy %from%\src\mame\irem\m72.*                     %to%\src\mame\irem
copy %from%\src\mame\konami\xmen.cpp                %to%\src\mame\konami
copy %from%\src\mame\midway\midzeus.cpp             %to%\src\mame\midway
copy %from%\src\mame\misc\cv1k.cpp                  %to%\src\mame\misc
copy %from%\src\mame\namco\namconb1_v.cpp           %to%\src\mame\namco
copy %from%\src\mame\neogeo\neogeo.*                %to%\src\mame\neogeo
copy %from%\src\mame\sega\deniam.cpp                %to%\src\mame\sega
copy %from%\src\mame\seta\ssv.cpp                   %to%\src\mame\seta
copy %from%\src\mame\sony\zn.cpp                    %to%\src\mame\sony
copy %from%\src\mame\taito\taito_f3_v.cpp           %to%\src\mame\taito
copy %from%\src\mame\toaplan\toaplan2.cpp           %to%\src\mame\toaplan

md %to%\src\osd\modules\lib
md %to%\src\osd\modules\render
copy /Y %from%\src\osd\modules\osdwindow.h          %to%\src\osd\modules
copy /Y %from%\src\osd\modules\lib\osdobj_common.*  %to%\src\osd\modules\lib
copy /Y %from%\src\osd\modules\render\drawogl.cpp   %to%\src\osd\modules\render
copy /Y %from%\src\osd\modules\render\drawd3d.cpp   %to%\src\osd\modules\render

md %to%\src\osd\windows
copy /Y %from%\src\osd\windows\video.cpp            %to%\src\osd\windows
copy /Y %from%\src\osd\windows\winmain.*            %to%\src\osd\windows
copy /Y %from%\src\osd\windows\window.*             %to%\src\osd\windows

md %to%\src\osd\winui
xcopy /E /Y %from%\src\osd\winui                    %to%\src\osd\winui

rem now save all our stuff to github
md %to%\build
copy %from%\*.bat                                   %to%\build

md %to%\scripts
xcopy /T %from%\scripts                             %to%\scripts
copy %from%\scripts\build\verinfo.py                %to%\scripts\build
copy %from%\scripts\src\mame\frontend.lua           %to%\scripts\src\mame
copy %from%\scripts\src\osd\modules.lua             %to%\scripts\src\osd
copy %from%\scripts\src\3rdparty.lua                %to%\scripts\src
copy %from%\scripts\src\main.lua                    %to%\scripts\src
copy %from%\scripts\src\video.lua                   %to%\scripts\src
copy %from%\scripts\src\osd\winui.lua               %to%\scripts\src\osd
copy %from%\scripts\genie.lua                       %to%\scripts



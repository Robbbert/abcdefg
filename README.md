What is ARCADE64?
=================
ARCADE64 has an inbuilt front-end allowing you to run selected arcade games from a list.
Only working games are included. Pinball games and mechanical games are excluded.
It runs on Windows 7 SP1 or later.


How to compile?
===============

You can only build ARCADE64 on a Windows computer. It won't compile on Unix.

```
make OSD=winui PTR64=1 SUBTARGET=arcade SYMBOLS=0 NO_SYMBOLS=1 DEPRECATED=0
```



Where can I find out more?
==========================

* [ARCADE64 site] https://arcade.mameworld.info/
* [ARCADE64 forum] https://www.1emulation.com/forums/forum/127-arcade/


Licensing Information
=====================

Information about the MAME content can be found at https://github.com/mamedev/mame/blob/master/README.md

Information about the license can be found in COPYING

Information about the WINUI portion can be found at https://github.com/Robbbert/mameui/blob/master/docs/winui_license.txt


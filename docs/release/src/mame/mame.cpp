// license:BSD-3-Clause
// copyright-holders:Aaron Giles (original), Robbbert (modifications)
/***************************************************************************

    mame.cpp

    Specific (per target) constants

****************************************************************************/

#include "emu.h"
#include "main.h"

// MAMEFX - ARCADE modifications by Robbbert, 2022-11-04
#define APPNAME                 "ARCADE"
#define APPNAME_LOWER           "arcade"
#define CONFIGNAME              "mame"
#define COPYRIGHT           "Copyright Robbbert\nand the MAME team\nhttps://mamedev.org"
#define COPYRIGHT_INFO      "\nMAME portions are copyright the MAME team and contributors\n" \
                            "ARCADE-specific portions are copyright Robbbert, Mamesick and contributors."

const char * emulator_info::get_appname() { return APPNAME;}
const char * emulator_info::get_appname_lower() { return APPNAME_LOWER;}
const char * emulator_info::get_configname() { return CONFIGNAME;}
const char * emulator_info::get_copyright() { return COPYRIGHT;}
const char * emulator_info::get_copyright_info() { return COPYRIGHT_INFO;}

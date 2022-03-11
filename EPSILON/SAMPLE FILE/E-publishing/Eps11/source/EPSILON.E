/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1985, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

// This file loads all the other files and sets up Epsilon.

#include "eel.h"

// For setting up OEM characters.
#define UCLC(up, low)	_def_char_class[low] = C_LOWER, \
			_def_char_class[up] = C_UPPER, \
			_def_case_map[low] = _def_srch_case_map[low] = up, \
			_def_case_map[up] = low

when_loading()
{
	int i, j;
	char *upper, *lower;

	for (i = 0; i < 256; i++)
		_def_case_map[i] = _def_srch_case_map[i] = i;
	for (i = 'A', j = 'a'; i <= 'Z'; i++, j++)
		UCLC(i, j);
	for (i = 131; i < 154; i++)
		_def_char_class[i] = C_LOWER;
	for (i = 160; i < 164; i++)
		_def_char_class[i] = C_LOWER;
	UCLC('€', '‡');
	UCLC('Ž', '„');
	UCLC('', '†');
	UCLC('', '‚');
	UCLC('’', '‘');
	UCLC('™', '”');
	UCLC('š', '');
	UCLC('¥', '¤');

	// Now do the same for ANSI characters.
	for (i = 0; i < 256; i++)
		_def_ansi_case_map[i] = _def_ansi_srch_case_map[i] = i;
	upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ";
	lower = "abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ";
	for (; *upper && *lower; upper++, lower++) {
		_def_ansi_char_class[*lower] = C_LOWER;
		_def_ansi_char_class[*upper] = C_UPPER;
		_def_ansi_case_map[*lower] = _def_ansi_srch_case_map[*lower] = *upper;
		_def_ansi_case_map[*upper] = *lower;
	}		
#include "keydef.h"
		/* set up keytran */
	reg_tab[CTRL('X')] = find_index("cx-tab");
	reg_tab[CTRL('C')] = find_index("cc-tab");
	load_commands("basic");
	load_commands("control");
	for (i = 'A'; i <= 'Z'; i++)
		cx_tab[i] = cx_tab[ALT(i)] = reg_tab[ALT(i)] =
						(short) case_indirect;
	load_commands("set");
	load_commands("kill");
	load_commands("window");
	load_commands("complete");
	load_commands("indent");
	load_commands("format");
	load_commands("help");
	load_commands("search");
	load_commands("prog");
	load_commands("proc");
	load_commands("lowlevel");
	load_commands("files");
	load_commands("filedate");
	load_commands("buffer");
	load_commands("load");
	load_commands("debug");
	load_commands("sort");
	load_commands("disp");
	load_commands("video");
	load_commands("dired");
	load_commands("bufed");	/* bufed uses cmds from dired */
	load_commands("c");
	load_commands("undo");
	load_commands("tags");
	load_commands("compare");
	load_commands("cmdline");
	load_commands("grep");
	load_commands("bookmark");
	load_commands("zoom");
	load_commands("session");
	load_commands("mouse");
	load_commands("menu");
	load_commands("store");
	load_commands("colcode");
	load_commands("clipboar");
	load_commands("uniq");
	load_commands("html");
	load_commands("tex");
	load_commands("epsnet");
	load_commands("browse");
	load_commands("stdcolor");
	load_commands("makemode");
	load_commands("inimode");
	load_commands("gams");
	load_commands("fillcomm");
	load_commands("misclang");
	load_commands("pull");
	load_commands("unicode");


	/* the following functions autoload just once per session */
	autoload_commands("diff");
	autoload_commands("vidextra");
	autoload_commands("brief");
	autoload_commands("displook");
	autoload_commands("asm");
	autoload_commands("info");
	autoload_commands("perl");
	autoload_commands("vbasic");
	autoload_commands("hex");
	autoload_commands("python");

	/* the remaining functions autoload on every invocation */
	autoload("set-color", "color", 0);
	autoload("set-display-characters", "dispchar", 0);
	autoload("program-keys", "keyprogs", 0);
	autoload("edit-variables", "editvars", 0);
	reg_tab[FALT(8)] = (short) edit_variables;

	when_restoring();
}

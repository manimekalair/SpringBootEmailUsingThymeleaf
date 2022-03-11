/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1989, 1997 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

#include "eel.h"

// Prior to version 5.0, Epsilon used a different syntax for some
// key names.  These commands convert from the old syntax (in command
// files, and in EEL code files).

command change_key_names()
{
	note("Replacing old-style key names with new...");
	point = 0;
	string_replace("A-\\", "A-\\\\", 0);	/* A-\ => A-\\ */
	string_replace("<", "\\<", 0);
	string_replace("N-0", "<Insert>", 0);
	string_replace("N-1", "<End>", 0);
	string_replace("N-2", "<Down>", 0);
	string_replace("N-3", "<PageDown>", 0);
	string_replace("N-4", "<Left>", 0);
	string_replace("N-6", "<Right>", 0);
	string_replace("N-7", "<Home>", 0);
	string_replace("N-8", "<Up>", 0);
	string_replace("N-9", "<PageUp>", 0);
	string_replace("N-.", "<Delete>", 0);
	say("Done.");
}

command eel_change_key_names()
{
	note("Replacing old-style key names with new...");
	point = 0;
	string_replace("NUMDIGIT(0)", "KEYINSERT", 0);
	string_replace("NUMDIGIT(1)", "KEYEND", 0);
	string_replace("NUMDIGIT(2)", "KEYDOWN", 0);
	string_replace("NUMDIGIT(3)", "KEYPGDN", 0);
	string_replace("NUMDIGIT(4)", "KEYLEFT", 0);
	string_replace("NUMDIGIT(6)", "KEYRIGHT", 0);
	string_replace("NUMDIGIT(7)", "KEYHOME", 0);
	string_replace("NUMDIGIT(8)", "KEYUP", 0);
	string_replace("NUMDIGIT(9)", "KEYPGUP", 0);
	string_replace("NUMDOT", "KEYDELETE", 0);
	say("Done.");
}

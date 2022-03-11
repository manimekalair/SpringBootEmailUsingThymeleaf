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

// This file has the command to load .b files into Epsilon.

#include "eel.h"

char _prev_byte_name[80];

command load_bytes()
{
	char fname[FNAMELEN], ext[20];

	sprintf(ext, "|%s|", byte_extension);
	save_var only_file_extensions = ext;
	save_var show_mouse_choices = 1;
	get_file(fname, "Load bytecodes from file", _prev_byte_name);
	if (!*fname)
		return;
	restore_vars();
	do_load_bytes(fname);
	iter = 0;
}

int do_load_bytes(fname)
char *fname;
{
	char rel[FNAMELEN], *s;

	strcpy(get_extension(fname), byte_extension);
	strcpy(_prev_byte_name, fname);
	if (s = lookpath(fname, 1)) {
		relative(s, rel);
		load_commands(s);
		say("%s loaded.", rel);
	} else
		error("Can't find %s", fname);
	iter = 0;
}

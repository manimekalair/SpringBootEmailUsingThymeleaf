/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1996, 2001 Lugaru Software Ltd.  All rights reserved.  *
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

#include "eel.h"
#include "proc.h"
#include "colcode.h"
#include "inimode.h"

char _ini_mode_name[] = "Ini";

color_ini_range(from, to) // recolor just this section
{			// last colored region may go past to
	int t = -1;

	if (from >= to)
		return to;
	save_var point, matchstart, matchend;
	point = to;				// Color entire lines.
	nl_forward();
	to = point;
	set_character_color(from, to, -1);
	point = from;
	to_begin_line();
	for (; point < to; nl_forward()) {
		t = point;
		switch (curchar()) {
			case '[':
				set_character_color(t, give_end_line() + 1,
									color_class inifile_section);
				break;
			case '#':
			case ';':
				set_character_color(t, give_end_line() + 1,
									color_class inifile_comment);
				break;
			default:	// Some textual .sys files use REM for comments.
				if (parse_string(1, "[ \t]*REM[ \t\n]")) {
					set_character_color(t, give_end_line(),
										color_class inifile_comment);
				} else if (parse_string(1, "[^\n=]*="))
					set_character_color(t, matchend,
										color_class inifile_definition);
		}
	}
	return point;
}

command ini_mode()
{
	mode_default_settings();
	major_mode = _ini_mode_name;
	strcpy(comment_start, ";[ \t]*");
	strcpy(comment_pattern, ";.*$");
	strcpy(comment_begin, "; ");
	strcpy(comment_end, "");
	comment_column = 0;
	recolor_range = color_ini_range;	// set up coloring rules
	recolor_from_here = recolor_by_lines;
	if (want_code_coloring)		// maybe turn on coloring
		when_setting_want_code_coloring();
	try_calling("ini-mode-hook");
	make_mode();
}

suffix_ini()
{
	ini_mode();
}

// Is it an MS-Windows file, not Info doc file or other types using
// this extension?
suffix_inf()
{
	if (matches_at(0, 1, "([ \t]*\n)*[[;]"))
		ini_mode();
}

suffix_sys()
{
	if (translation_type != FILETYPE_BINARY)
		ini_mode();
}

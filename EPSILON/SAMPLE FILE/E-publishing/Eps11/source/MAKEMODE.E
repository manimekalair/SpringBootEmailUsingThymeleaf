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

// A mode for editing makefiles.

#include "eel.h"
#include "proc.h"
#include "colcode.h"
#include "makemode.h"

// Color this range of the buffer.

color_makefile_range(from, to)
{			// last colored region may go past to
	int t = -1, s;

	if (from >= to)
		return to;
	save_var point, matchstart, matchend;
	point = to;		// Never stop coloring on a continued line.
	re_search(1, "[^\\]\n");
	to = point;
	set_character_color(from, to, -1);
	point = from;
	to_begin_line();
	for (; point < to; ) {
		t = point;
		if (!re_search(1, ":([ \t]|$)|[#=]|^[ \t]*<!>"))
			break;
		switch (character(point - 1)) {
			case '#':		// Found a comment.
				if (parse_string(-1, "^\t.*"))
					break;	// Not in a command.
				set_character_color(point - 1, give_end_line() + 1,
									color_class makefile_comment);
				nl_forward();
				break;
			case '!':		// A preprocessor directive starting with !.
				s = point - 1;
				while (nl_forward() && character(point - 2) == '\\')
					;			// include contin lines
				set_character_color(s, point, color_class makefile_preproc);
				break;
			case '=':		// A macro definition.
				if (parse_string(-1, "^[^\t\n ]([^\n=:]|\\\n)*="))
					set_character_color(matchstart - 1, matchend,
										color_class makefile_macro);
				break;
			default:		// Perhaps a target specification.
// A target specification ends with : followed by eol or whitespace,
// and includes previous lines that end with a \.
				if (parse_string(-1, "^[^\t\n ](.|\\\n)*(:)[ \t]*")) {
					s = matchend;	// Don't color : or :: after it.
					set_character_color(s, point - parse_string(-1,
						"[ :]*"), color_class makefile_target);
				}
				break;
		}
	}
	if (to < t)
		set_character_color(to, t, -1);
	return point;
}

command list_make_preprocessor_conditionals() on makefile_tab[ALT('i')]
{
	if (opsys == OS_UNIX)		// Gnu Make format
		do_list_preprocessor_conditionals("^ *(ifn?(eq|def)|else|endif)",
										  "^ *(ifn?(eq|def))",
										  "^ *(endif)", "if");
	else						// Microsoft Nmake format
		do_list_preprocessor_conditionals("^[ \t]*%![ \t]*(if|else|endif|elif)",
										  "^[ \t]*%![ \t]*(if)",
										  "^[ \t]*%![ \t]*(endif)", "!if");
}

command makefile_mode()
{
	mode_default_settings();
	mode_keys = makefile_tab;		/* Use these keys. */
	major_mode = _makefile_mode_name;
	compile_buffer_cmd = compile_makefile_cmd;	// Can "compile" this.
	strcpy(comment_start, "#[ \t]*");
	strcpy(comment_pattern, "#.*$");
	strcpy(comment_begin, "# ");
	strcpy(comment_end, "");
	recolor_range = color_makefile_range;	// set up coloring rules
	recolor_from_here = recolor_from_top;
	if (want_code_coloring)		// maybe turn on coloring
		when_setting_want_code_coloring();
	try_calling("makefile-mode-hook");
	drop_all_colored_regions();
	make_mode();
}

suffix_mak()
{
	makefile_mode();
}

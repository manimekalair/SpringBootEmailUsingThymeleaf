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
#include "misclang.h"
#include "html.h"

// Move past a string in PostScript.

fwd_postscript_string()
{
	int level = 0;

	while (re_search(1, "[\\()]")) {
		switch (character(point - 1)) {
			case '\\':		// Quote next char.
				point++;
				break;
			case '(':		// Ignore balanced parens within.
				level++;
				break;
			case ')':
				if (--level <= 0)
					return 1;
				break;
		}
	}
	return 0;
}

color_postscript_range(from, to)
{
	int t = -1;

	if (from >= to)
		return to;
	save_var point, matchstart, matchend;
	set_character_color(from, to, -1);
	point = from;
	to_begin_line();	// Move back over continued lines.
	point -= parse_string(-1, "(.*\\\n)+");
	while (point < to) {
		if (!re_search(1, "[%(]|/[-_a-z0-9]+|</word>(doclutimage|doNimage)</word>")) {
			t = size();
			break;
		}
		t = matchstart;
		switch (character(t)) {		// check first char
			case '%':
				nl_forward();
				set_character_color(t, point, color_class postscript_comment);
				break;
			case '(':		// A text string.
				point--;
				fwd_postscript_string();
				set_character_color(t, point, color_class postscript_text);
				break;
			case '/':		// Found /literalname.
				set_character_color(t, point, color_class postscript_literal);
				break;
			default:		// Found start of Windows PS driver binary code.
				re_search(1, "~>[ \n]*(Z|endimage)");	// Find end.
				set_character_color(t, point, color_class postscript_text);
				break;
		}
	}
	if (to < t)
		set_character_color(to, t, -1);
	return point;
}

command postscript_mode()
{
	mode_default_settings();
	major_mode = _postscript_mode_name;
	mode_keys = pscript_tab;		/* Use these keys. */
	if (auto_show_postscript_delimiters)
		auto_show_matching_characters = postscript_auto_show_delim_chars;
	strcpy(comment_start, "%%[ \t]*");
	strcpy(comment_pattern, "%%.*$");
	strcpy(comment_begin, "% ");
	strcpy(comment_end, "");
	comment_column = 0;
	recolor_range = color_postscript_range;	// set up coloring rules
	recolor_from_here = recolor_by_lines;
	coloring_flags |= COLOR_INVALIDATE_FORWARD | COLOR_INVALIDATE_RESETS;
	idle_coloring_size = 10000;
	if (want_code_coloring)		// maybe turn on coloring
		when_setting_want_code_coloring();
	pscript_tab[ALT('q')] = (short) fill_comment;
	try_calling("postscript-mode-hook");
	make_mode();
}

suffix_ps()
{
	postscript_mode();
}

suffix_eps()
{
	postscript_mode();
}

color_conf_range(from, to)
{
	int t = -1;

	if (from >= to)
		return to;
	save_var point, matchstart, matchend;
	point = to;				// Color entire lines.
	nl_forward();
	to = point;
	save_var narrow_end = size() - to;
	set_character_color(from, to, -1);
	point = from;

	while (point < to) {
		if (!re_search(1, "([^ \t\n#:;,]+[ \t]*)="
					   "([ \t]*([^ \t\n#:;,]+|'[^\n']*'|\"[^\n']*\"))|^;|[#]")) {
			t = size();
			break;
		}
		t = matchstart;
		switch (character(point - 1)) {		// check last char
			case '#':
			case ';':
				nl_forward();
				set_character_color(t, point, color_class conf_comment);
				break;
			default:
				set_character_color(t, find_group(1, 0),
									color_class conf_attribute);
				set_character_color(find_group(2, 1), point,
									color_class conf_value);
				break;
		}
	}
	if (to < t)
		set_character_color(to, t, -1);
	return point;
}

command conf_mode()
{
	mode_default_settings();
	major_mode = _conf_mode_name;
	strcpy(comment_start, "#[ \t]*");
	strcpy(comment_pattern, "#.*$");
	strcpy(comment_begin, "# ");
	strcpy(comment_end, "");
	comment_column = 0;
	recolor_range = color_conf_range;	// set up coloring rules
	recolor_from_here = recolor_by_lines;
	idle_coloring_size = 10000;
	if (want_code_coloring)		// maybe turn on coloring
		when_setting_want_code_coloring();
	try_calling("conf-mode-hook");
	make_mode();
}

suffix_conf()
{
	conf_mode();
}

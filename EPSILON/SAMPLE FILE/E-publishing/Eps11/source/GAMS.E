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
#include "gams.h"
#include "colcode.h"

// GAMS is a language for mathematical programming.  See www.gams.com.

color_gams_range(from, to) // recolor just this section
{			// last colored region may go past to
	int t = -1, talk;

	if (from >= to)
		return to;
	save_var point, matchstart, matchend, case_fold = 1;
	set_character_color(from, to, -1);
	point = from;
	talk = (to - from > 2000);	// show status during long delays
	while (point < to) {
		if (!re_search(1, "[0-9A-Za-z_.]+|^[*$]|[!\"']")) {
			t = size();
			break;
		}
		t = matchstart;
		switch (character(point - 1)) {		// check last char
			case '"':		// found a string
				point = t;
				re_search(1, "\"([^\"\n])*[\"\n]");
				set_character_color(t, point, color_class gams_string);
				break;
			case '\'':		// found a string
				point = t;
				re_search(1, "\'([^\'\n])*[\'\n]");
				set_character_color(t, point, color_class gams_string);
				break;

			case '!':	// Really this is only a comment if $eolcom says so.
			case '*':			// found comment
				nl_forward();
				set_character_color(t, point, color_class gams_comment);
				break;
			case '$':			// found control statement
				if (parse_string(1, "ontext")) {
					search(1, "\n$offtext");
					set_character_color(t, point, color_class gams_comment);
					break;
				}
				nl_forward();
				set_character_color(t, point, color_class gams_control);
				break;
			default:		// found identifier, kywd, or number
				gams_keyword_color(t, point);
				break;
		}
		if (talk)
			note("Coloring GAMS file: %d%% complete...",
				 muldiv(point - from, 100, to - from));
	}
	if (to < t)
		set_character_color(to, t, -1);
	if (talk)
		note("");
	return point;
}

// Set color of "identifier" in this buffer range (actually anything
// with alpha or digits).
gams_keyword_color(from, to)
{
	char buf[500];

	if (point - from > sizeof(buf) - 10)
		save_var point = from + sizeof(buf) - 10;
	buf[0] = '|';		// get identifier, between | chars
	grab(from, point, buf + 1);
	if (index("0123456789-", buf[1]) || buf[1] == '.' && isdigit(buf[2])) {
		set_character_color(from, to, -1);
		return;
	}
	strcpy(buf + point - from + 1, "|");
	if (is_gams_data(buf)) {
		set_character_color(from, to, color_class gams_keyword);
		search(1, ";");
	} else if (is_gams_keyword(buf))
		set_character_color(from, to, color_class gams_keyword);
	else
		set_character_color(from, to, color_class gams_variable);
}

// Is text in p (must be surrounded by |'s) a keyword that starts some data?
// If so, we're going to interpret the rest of this section (until a ;)
// specially.

is_gams_data(p)
char *p;
{
	if (strstr("|set|sets|scalar|scalars|parameter|parameters|table|tables"
			   "|variable|variables|equation|equations|model|models|", p))
		return 1;
	return 0;
}

is_gams_keyword(p)	// is text in p (must be surrounded by |'s) a keyword?
char *p;
{
	if (strstr("|file|files|option|loop|while|alias|include|abort|card|ord"
			   "|yes|no|smax|smin|not|and|or|solve"
			   "|put|putclose|sum|max|min|prod|display|exp|log|log10|normal"
			   "|uniform|abs|ceil|floor|mapval|mod|power|round|sign|sqr"
			   "|sqrt|trunc|arctan|cos|sin|inf|na|undf|eps|errorf|", p))
		return 1;
	return 0;
}

command gams_mode()
{
	mode_default_settings();
	major_mode = _gams_mode_name;
	compile_buffer_cmd = compile_gams_cmd;	// can compile this
	if (auto_show_gams_delimiters)
		auto_show_matching_characters = gams_auto_show_delim_chars;
	strcpy(comment_start, "^*[ \t]*");
	strcpy(comment_pattern, "^*.*$");
	strcpy(comment_begin, "* ");
	strcpy(comment_end, "");
	recolor_range = color_gams_range;	// set up coloring rules
	recolor_from_here = recolor_from_top;
	if (want_code_coloring)		// maybe turn on coloring
		when_setting_want_code_coloring();
	try_calling("gams-mode-hook");
	make_mode();
}

suffix_gms()		// .gms file invokes GAMS mode
{
	gams_mode();
}

suffix_set()		// .set file invokes GAMS mode
{
	gams_mode();
}

// These extensions aren't enabled by default, as they're commonly in
// use for non-GAMS purposes.

suffix_inc()
{
	if (gams_files)
		gams_mode();
	else
		asm_mode();
}

suffix_map()
{
	if (gams_files)
		gams_mode();
	else
		fundamental_mode();
}

suffix_dat()
{
	if (gams_files)
		gams_mode();
	else
		fundamental_mode();
}

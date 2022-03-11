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
#include "python.h"

// We just found a " or a ' character.  Find the other end and color.

python_string_color(int c)
{
	char pat[100], start = point - 1;

	if (character(point) == c && character(point + 1) == c) {
		// a triple-quoted string
		point += 2;
		sprintf(pat, "\\.|%c%c%c", c, c, c);
	} else
		sprintf(pat, "\\.|%c|\n", c);
	while (re_search(1, pat))
		if (character(matchstart) != '\\')
			break;
	set_character_color(start, point, color_class python_string);
}

color_python_range(from, to) // recolor just this section
{			// last colored region may go past to
	int t = -1, talk, s, talk_at = 0;

	if (from >= to)
		return to;
	save_var point, matchstart, matchend;
	if (from < to)
		set_character_color(from, to, -1);
	point = from;
	talk = (to - from > 20000);	// show status during long delays
	while (point < to) {
		if (!re_search(1, "[A-Za-z_][A-Za-z0-9_]*"
					   "|-?%.?[0-9]([A-Za-z0-9._]|[Ee]-)*j?|[\"'#]")) {
			t = size();
			break;
		}
		t = matchstart;
		switch (character(point - 1)) {		// check last char
			case '#':			// found comment
				nl_forward();
				set_character_color(t, point, color_class python_comment);
				break;
			case '"':		// found a string literal
				python_string_color('"');
				if (get_character_color(point, (int *) 0, &s) == 
					  color_class python_string && s > to)  // fix up after
					if (point < (to = s))	 // quoted "'s
						set_character_color(point, to, -1);
				break;
			case '\'':
				python_string_color('\'');
				if (get_character_color(point, (int *) 0, &s) == 
					  color_class python_string && s > to)  // fix up after
					if (point < (to = s))	 // quoted "'s
						set_character_color(point, to, -1);
				break;
			default:		// found identifier, kywd, or number
				set_character_color(t, point, python_keyword_color(t));
				break;
		}
		if (talk && point > talk_at + 2000) {
			note("Coloring Python program: %d%% complete...",
				 muldiv(point - from, 100, to - from));
			talk_at = point;
		}
	}
	if (to < t)
		set_character_color(to, t, -1);
	if (talk)
		note("");
	return point;
}

python_keyword_color(from)	// return color for "identifier" from here to point
{			// (something with alpha or digits)
	char buf[500];

	if (point - from > sizeof(buf) - 10)
		save_var point = from + sizeof(buf) - 10;
	buf[0] = '|';		// get identifier, between | chars
	grab(from, point, buf + 1);
	if (index("0123456789-", buf[1]) || buf[1] == '.' && isdigit(buf[2]))
		return c_number_color(buf + 1);
	strcpy(buf + point - from + 1, "|");
	if (is_python_keyword(buf))
		return color_class python_keyword;
	return color_class python_identifier;
}

is_python_keyword(p)	// is text in p (must be surrounded by |'s) a keyword?
char *p;
{
	if (strstr("|and|del|for|is|raise|assert|elif|from|lambda|return|"
			   "break|else|global|not|try|class|except|if|or|while|"
			   "continue|exec|import|pass|def|finally|in|print|yield|", p))
		return 1;
	return 0;
}

// If the previous non-comment line ends with :, indent one more,
// otherwise indent the same.

do_python_indent()
{
	int ind;

	save_var point;
	do {		// Find prev non-comment line.
		if (!nl_reverse())		// First line in the file, no indent.
			return 0;
		to_begin_line();
	} while (parse_string(1, "[ \t]*[#\n]"));
	to_indentation();
	ind = current_column();
	// Does this (previous) line end with a : character (plus maybe a
	// comment)?  If so, indent one level more.
	if (parse_string(1, ".*:[\t\n]*(#.*)?$"))
		ind += python_indent;
	restore_vars();
	to_column(ind);
}

python_indenter() on python_tab['\t']
{
	int orig = point;
	int orig_column = current_column();

	if (maybe_indent_rigidly(0))
		return;
	to_indentation();
	if (orig_column > current_column()) {
					/* if not in indentation */
		point = orig;
		to_column(orig_column + python_indent
				  - orig_column % python_indent);
	} else if (prev_cmd == C_INDENT)	/* repeated, make bigger */
		to_column(orig_column + python_indent);
	else {
		do_python_indent();
		if (!get_indentation(point) && !orig_column
			  && this_cmd != CMD_INDENT_REG)	// 0 indent=>0 indent,
			to_column(python_indent);		// but indent anyway
	}
	if (this_cmd != CMD_INDENT_REG)
		this_cmd = C_INDENT;
}


command python_mode()
{
	mode_default_settings();
	mode_keys = python_tab;		/* Use these keys. */
	major_mode = _python_mode_name;
	compile_buffer_cmd = compile_python_cmd;	// can compile this
	auto_indent = 1;
	tab_size = 8;		// Python language requires this.
	indent_with_tabs = 0;
	indenter = do_python_indent;
	strcpy(comment_start, "#[ \t]*");
	strcpy(comment_pattern, "#.*$");
	strcpy(comment_begin, "# ");
	strcpy(comment_end, "");
	recolor_range = color_python_range;	// set up coloring rules
	recolor_from_here = recolor_from_top;
	if (want_code_coloring)		// maybe turn on coloring
		when_setting_want_code_coloring();
	if (auto_show_python_delimiters)
		auto_show_matching_characters = python_auto_show_delim_chars;
	python_tab[ALT('q')] = (short) fill_comment;
	try_calling("python-mode-hook");
	drop_all_colored_regions();
	make_mode();
}

suffix_python()
{
	python_mode();
}

suffix_py()
{
	python_mode();
}

// Set display_func_name to the name of the function we're editing, and
// return 1.  If not in a function, set display_func_name to "" and
// return 1.  If user pressed a key and we gave up for now, return 0.

python_func_name_finder()
{
	int from, to, color;

	save_var point, case_fold = 0;
	to_end_line();
	recolor_buffer_range(0, point);
	while (re_search(-1, "^[ \t]*(def|class)[ \t]+([a-zA-Z_]<word>*)[(:]")) {
		color = get_character_color(matchend);
		if (color == color_class python_comment
			  || color == color_class python_string)
			continue;
		from = find_group(2, 1);
		to = find_group(2, 0);
		to = MIN(to, from + ptrlen(display_func_name) - 1);
		grab(from, to, display_func_name);
		return 1;
	}
	*display_func_name = 0;
	return 1;
}

tag_suffix_python()
{
	char func[TAGLEN];
	int start, color;

	python_mode();
	recolor_buffer_range(0, size());	// Just to skip over comments
	save_var point = 0, case_fold = 0;				// & strings.
	while (re_search(1, "^[ \t]*(def|class)[ \t]+([a-zA-Z_]<word>*)[(:]")) {
		color = get_character_color(matchstart);
		if (color == color_class python_comment
			  || color == color_class python_string)
			continue;
		grab(start = find_group(2, 1), find_group(2, 0), func);
		add_tag(func, start);
	}
}

tag_suffix_py()
{
	tag_suffix_python();
}

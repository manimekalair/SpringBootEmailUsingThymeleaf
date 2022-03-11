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
#include "c.h"
#include "tex.h"

// Functions for coloring TeX.

// Return the start of the biggest specially-colored construct (like
// math mode) that includes point.

int tex_start_construct()
{
	int s;

	save_var point, narrow_end = size() - point;
	re_search(-1, "\n([ \t]*\n|\\def[^a-z0-9])");
	for (; re_search(1, "[%$\\]"); ) {	// Look for %, $, or \\ characters
		s = matchstart;
		switch (character(point - 1)) {
			case '\\':
				if (curchar() == '[') {
					if (!search(1, "\\]"))
						return s;
				} else
					point++;
				break;
			case '$':
				if (curchar() == '$') {
					if (!search(1, "$$"))
						return s;
				} else
					if (!search(1, "$"))
						return s;
				break;
			case '%':
				to_end_line();
				break;
		}
	}
	return point;
}

recolor_tex_from_here(int safe)
{
	safe = safe;			// Suppress compiler warning.
	to_begin_line();		// Get outside math mode.
	return tex_start_construct();
}

color_tex_cmd(int s)
{
	char cmd[200];
	int color = color_class tex_literal;

	cmd[0] = '|';
	if (parse_string(1, "[a-z@]*", cmd + 1)) {
		strcat(cmd, "|");
		if (strstr("|begin|end|", cmd))
			color = color_class tex_begin_end;
		else if (strstr("|chapter|section|subsection|subsubsection"
						"|appendix|bibliography|title|tableofcontents"
						"|input|include|listoffigures|listoftables|part"
						"|usepackage|paragraph|subparagraph|",
						cmd))
			color = color_class tex_section;
		else
			color = color_class tex_command;
	} else if (curchar() == '[') {
		int orig = point;
		if (re_search(1, "\n[ \t]*\n|\\par![^a-z]|\\]")
			&& character(point - 1) == ']') {
			color_tex_math(orig - 1, point, color_class tex_display_math);
			return;
		}
		point = orig + 1;
	} else if (curchar() == '(') {
		int orig = point;
		if (re_search(1, "\n[ \t]*\n|\\par![^a-z]|\\%)")
			  && character(point - 1) == ')') {
			color_tex_math(orig - 1, point, color_class tex_math);
			return;
		}
		point = orig + 1;
	} else
		point++;
	set_character_color(s, point, color);
}

color_tex_math(int from, int to, int color)
{
	int s;

	set_character_color(from, to, color);
	save_var narrow_start = from, narrow_end = size() - to, point = from;
	while (re_search(1, "[\\%&]")) {
		s = point - 1;		// Color % and & specially in math mode unless
		switch (character(s)) {	// protected by \ character.
			case '\\':
				point++;
				break;
			case '%':
				to_end_line();
				set_character_color(s, point, color_class tex_comment);
				break;
			case '&':
				set_character_color(s, point, color_class tex_section);
				break;
		}
	}
}

color_tex_dollar(int s)
{
	char pat[30];
	int orig, color = color_class tex_math;

	strcpy(pat, "\n[ \t]*\n|\\par![^a-z]|%$");
	if (curchar() == '$') {	// A $$ that signals displayed math?
		point++;			// Get to after $$.
		strcat(pat, "%$");
		color = color_class tex_display_math;
	}
	orig = point;
	if (re_search(1, pat) && character(point - 1) == '$')
		color_tex_math(s, point, color);
	else
		point = orig;
}

// Adding/deleting $'s can get math mode coloring out of synch.
// If we just colored a math block and the next character is in
// math color, that's probably happened, so recolor the rest of this
// paragraph.

int fix_tex_math_coloring(int to)
{
	int c = get_character_color(point);

	if (c == color_class tex_math || c == color_class tex_display_math) {
		int s = point;			// Color rest of parag.
		if (!narrowed_search(REGEX, "\n[ \t]*\n", tex_look_back / 2))
			to_end_line();
		set_character_color(s, point, color_class tex_text);
		to = point;
		point = s;
	}
	return to;
}

int color_tex_range(int from, int to) // Recolor just this section.
{						// Last colored region may go past to.
	int s, talk, cnt = 0;

	if (from >= to)
		return to;
	save_var point, matchstart, matchend;
	point = from;
	from = point = tex_start_construct();

	talk = (to - from > tex_look_back + 1000); // Show status during long delays.
	if (point < to)
		set_character_color(point, to, color_class tex_text);
	save_var case_fold = 1;
	for (s = point; point < to && re_search(1, "[][{}%\\$&]"); s = point) {
		if (point > to)
			set_character_color(s, point - 1, color_class tex_text);
		s = point - 1;
		switch (character(s)) {
			case '\\':
				color_tex_cmd(s);
				if (talk)
					if (!(cnt++ % 500))
						note("Coloring TeX: %d%% complete...",
							 muldiv(point - from, 100, to - from));
				break;
			case '$':
				color_tex_dollar(s);
				to = fix_tex_math_coloring(to);
				break;
			case '%':
				to_end_line();
				set_character_color(s, point, color_class tex_comment);
				to = fix_tex_math_coloring(to);
				break;
			case '{': case '}':
				set_character_color(s, point, color_class tex_curly_brace);
				break;
			case '&':
				set_character_color(s, point, color_class tex_section);
				break;
			case '[': case ']':
				set_character_color(s, point,
									color_class tex_square_bracket);
				break;
		}
	}
	if (talk)
		note("");
	return point;
}

// Insert a command, position inside its braces, and optionally
// add an italic correction after.  If a region's highlighted,
// put it inside the command and move after it.

tex_insert_cmd(char *before, char *after, int italic_correction)
{
	iter = 0;
	if (is_highlight_on()) {
		fix_region();
		stuff(before);
		exchange_point_and_mark();
	} else {
		stuff(before);
		save_var point;		// Stay here after.
	}
	if (italic_correction && !index(",.", curchar()))	// Add italic
		stuff("\\/");		// correction except before punctuation.
	stuff(after);
}

command tex_italic() on tex_tab[ALT('i')]
{
	tex_insert_cmd(latex_2e_or_3 ? "\\textit{" : "{\\it ", "}",
				   !latex_2e_or_3);
}

command tex_slant() on tex_tab[ALT('I')]
{
	tex_insert_cmd(latex_2e_or_3 ? "\\textsl{" : "{\\sl ", "}",
				   !latex_2e_or_3);
}

command tex_typewriter() on tex_tab[ALT('T')]
{
	tex_insert_cmd(latex_2e_or_3 ? "\\texttt{" : "{\\tt ", "}", 0);
}

command tex_boldface() on tex_tab[ALT('B')]
{
	tex_insert_cmd(latex_2e_or_3 ? "\\textbf{" : "{\\bf ", "}", 0);
}

command tex_small_caps() on tex_tab[ALT('C')]
{
	tex_insert_cmd(latex_2e_or_3 ? "\\textsc{" : "{\\sc ", "}", 0);
}


// Insert a pair of characters, position between them.
// But if quoted or repeated, just insert normally.
tex_insert_pair(char *pair)
{
	if (character(point - 1) == '\\' || has_arg)
		normal_character();
	else {
		stuff(pair);
		point--;
	}
}

command tex_left_brace() on tex_tab['{']
{
	iter = 0;
	if (point < size() - narrow_end && !strchr(" \t\n$}", curchar()))
		insert('{');
	else if (character(point - 1) == '\\' && !has_arg) {
		stuff("{\\}");
		point -= 2;
	} else
		tex_insert_pair("{}");
}

command tex_math_escape() on tex_tab['$']
{
	iter = 0;
	tex_insert_pair("$$");
}

// Maybe delete an italic correction \/.

command tex_rm_correction() on tex_tab[','], tex_tab['.']
{
	if (parse_string(-1, "\\/}"))
		delete(matchend, matchstart - 1);
	normal_character();
}

// Convert " to TeX's quote sequences of `` or '' as appropriate.

command tex_quote() on tex_tab['"']
{
	if (character(point - 1) == '\\' || has_arg)
		normal_character();		// quoted (\" is an umlaut)
	else if (point <= narrow_start || index(" \t\n([{",
											character(point - 1)))
		stuff("``");	// use opening quote
	else
		stuff("''");	// closing quote
}

// An alternative to typing Ctrl-Q ".
command tex_force_quote() on tex_tab[ALT('"')], tex_tab[ALT('\'')]
{
	insert('"');
}

// Insert appropriate footnote cmd (TeX's takes two parameters).

command tex_footnote() on tex_tab[ALT('F')]
{
	tex_insert_cmd("\\footnote{",
				   tex_force_latex ? "}" : "}{}", 0);
}

// Make sure there's a \n before and after point.
tex_open_new_line()
{
	if (point > 0 && character(point - 1) != '\n')
		insert('\n');			// Make new lines before or after?
	if (curchar() != '\n')
		insert('\n'), point--;
}

command tex_center_line() on tex_tab[ALT('s')]
{
	iter = 0;
	tex_open_new_line();
	if (tex_force_latex && latex_2e_or_3)
		tex_insert_cmd("\\begin{center}", "\\end{center}", 0);
	else
		tex_insert_cmd("\\centerline{", "}", 0);
}

tex_insert_open(int close)
{
	normal_character();
	if (tex_force_latex && character(point - 2) == '\\') {
		save_var point;
		bprintf("\\%c", close);
	}
}

command tex_inline_math() on tex_tab['(']
{
	tex_insert_open(')');
}

command tex_display_math() on tex_tab['[']
{
	tex_insert_open(']');
}

tex_init_env()		// Load the list of environments.
{					// Return 0 if we couldn't.
	char *s;

	if (exist(TEX_ENV_BUF))
		return 1;
	save_var bufnum = create(TEX_ENV_BUF);
	s = lookpath("latex.env");
	if (!s)
		return 0;
	err_file_read(s, FILETYPE_AUTO);
	save_var sort_status = 0;
	do_sort_region(0, size(), 0, 0);
	delete_final_newlines();
	return 1;
}

// Add this environment to the list.
tex_add_to_env_list(char *env)
{
	char *s = lookpath("latex.env");

	if (!tex_init_env())
		return;
	save_var bufname = TEX_ENV_BUF;
	point = 0;
	bprintf("%s\n", env);
	save_var sort_status = 0;
	do_sort_region(0, size(), 0, 0);
	point = 0;
	do_uniq(1, 1, 0);
	delete_final_newlines();
	if (s && tex_save_new_environments)
		file_write(s, translation_type);
}

char *tex_env_match(char *partial, int start)
{
	if (!tex_init_env())
		error("Can't find latex.env");
	save_var bufname = TEX_ENV_BUF;
	case_fold = 0;
	if (start & STARTMATCH)
		point = 0;
	if (*partial ? !col_search(partial, 0) : (point >= size()))
		return NULL;
	to_begin_line();
	if (!grab_line(bufnum, _this_match))
		return NULL;
	return _this_match;
}

command tex_environment() on tex_tab[ALT('E')]
{
	char res[FNAMELEN];

	iter = 0;				// Ask which environment to use.
	comp_read(res, "Environment name: ", tex_env_match, 0,
			  tex_environment_name);
	strcpy(tex_environment_name, res);
	if (*res && tex_init_env())
		tex_add_to_env_list(res);
	if (is_highlight_on()) {	// Surround highlighted region.
		fix_region();
		if (point > 0 && character(point - 1) != '\n')
			insert('\n');			// Make new line before?
		bprintf("\\begin{%s}\n", tex_environment_name);
		exchange_point_and_mark();
		if (point > 0 && character(point - 1) != '\n')
			insert('\n');			// Make new line before?
		bprintf("\\end{%s}\n", tex_environment_name);
	} else {
		tex_open_new_line();
		bprintf("\\begin{%s}\n", tex_environment_name);
		save_var point;		// Stay here afterwards.
		bprintf("\n\\end{%s}", tex_environment_name);
	}
}

command tex_close_environment() on tex_tab[ALT('Z')]
{
	char env[FNAMELEN];
	int cnt = 0 , level = 0, pos = point;

	while (re_search(-1, "\\(begin|end){")) {
		cnt++;
		if (character(point + 1) == 'e')
			level++;
		else if (--level < 0) {
			if (!parse_string(1, "\\begin{([^\n}]+)}"))
				error("Can't interpret \\begin statement");
			grab(find_group(1, 1), find_group(1, 0), env);
			point = pos;
			tex_open_new_line();
			bprintf("\\end{%s}", env);
			return;
		}
	}
	if (cnt)
		error("Mismatched \\begin & \\end pairs detected.");
	point = pos;
	error("No \\begin block before point");
}

// Search on line for link, set file to its name.
// Abort if none.
tex_find_linked_file(char *file)
{
	char rel[FNAMELEN], curdir[FNAMELEN], *p, *include;

	to_begin_line();
	if (parse_string(1, ".*\\(include|input|usepackage)[ \t{]*([^{} \t\n]+)"))
		grab(find_group(2, 1), find_group(2, 0), rel);
	else
		error("Can't find any link here.");
	if (!*get_extension(rel))
		strcpy(get_extension(rel),
			   character(find_group(1, 1)) == 'u' ? ".sty" : ".tex");
	strcpy(file, rel);
	get_buffer_directory(curdir);
	absolute(file, curdir);
	if (check_file(file))
		return;
	include = getenv("TEXINPUTS");
	p = 0;
	if (!p && include)
		p = look_on_path(rel, 0, include);
	if (!p && *include_directories)
		p = look_on_path(rel, 0, include_directories);
	if (!p)
		error("%s not found in include-directories path", rel);
	strcpy(file, p);
}

// We're inserting the character in key; maybe break this line first
// (or instead).  Return 1 if we still want to insert the character, or
// 0 to ignore it.  But if mode is 0,1,2, then we're only setting (0,1) or
// retrieving (2) the value of tex-auto-fill-mode.

int tex_maybe_break_line(int mode)
{
	switch (mode) {
		case 0:
		case 1:
			tex_auto_fill_mode = (mode != 0);
			return 0;
		case 2:
			return tex_auto_fill_mode;
	}
	if (!tex_auto_fill_mode)		// We're not in auto-fill mode.
		return 1;
	if (parse_string(-1, "([^\\]|<bob>)%%.*"))
		return 1;	// In comments, don't break lines.
	return maybe_break_this_line();
}

command tex_mode()
{
	mode_default_settings();
	mode_keys = tex_tab;		/* Use these keys. */
	compile_buffer_cmd = compile_tex_cmd;
	tex_tab['}'] = Matchdelim ? (short) show_matching_delimiter : 0;
	tex_tab[']'] = Matchdelim ? (short) show_matching_delimiter : 0;
	tex_tab[')'] = Matchdelim ? (short) show_matching_delimiter : 0;
	tex_paragraphs = 1;
	buffer_maybe_break_line = tex_maybe_break_line;
	if (tex_force_latex == 2){		// Determine if it's LaTeX.
		save_var point = 0;
		tex_force_latex = search(1, "\\begin{document}");
	}
	major_mode = tex_force_latex ? _latex_mode_name : _tex_mode_name;
	strcpy(comment_start, "[^\\]%%[ \t\f]*");
	strcpy(comment_pattern, "[^\\]%%.*$");
	strcpy(comment_begin, "% ");
	strcpy(comment_end, "");
	recolor_range = color_tex_range;	// set up coloring rules
	recolor_from_here = recolor_tex_from_here;
	if (want_code_coloring)		// maybe turn on coloring
		when_setting_want_code_coloring();
	idle_coloring_size = 3000;	// Do bigger bunches.
	if (auto_show_tex_delimiters)
		auto_show_matching_characters = tex_auto_show_delim_chars;
	try_calling("tex-mode-hook");
	drop_all_colored_regions();
	make_mode();
}

command latex_mode()
{
	if (!tex_force_latex)
		save_var tex_force_latex = 1;
	tex_mode();
}

// Automatically go into TeX mode on .tex, .ltx, .sty files.

suffix_tex()
{
	tex_mode();
}

suffix_ltx()
{
	tex_force_latex = 1;
	tex_mode();
}

suffix_sty()
{
	tex_mode();
}

// Go to the place where this text appears in the DVI previewer.
// Works with Y&Y's DVIWindo previewer, version 2.1.4 and later.
// Requires the TeX file to use srctex.sty or srcltx.sty.

command jump_to_dvi() on tex_tab[ALT('J')]
{
	int conv;
	char msg[500], dvifile[FNAMELEN];

	strcpy(dvifile, filename);
	strcpy(get_extension(dvifile), ".dvi");
	conv = dde_open("DVIWindo", "SRCSpecial");
	if (!conv)
		error("Couldn't open DDE channel to DVI viewer.");
	if (check_file(dvifile)) {		// The file exists, so open it.
		sprintf(msg, "[Open(\"%s\")]", dvifile);
		if (!dde_execute(conv, msg, 10000))
			say("Error sending open message to DVI viewer.");
	}	// Otherwise assume the user's already opened the file.
	sprintf(msg, "[Source(\"%s\");Line(%d)]",
			get_tail(filename, 1), lines_between(0, point, 0));
	if (!dde_execute(conv, msg, 10000))
		say("Error sending message to DVI viewer.");
	if (!dde_close(conv))
		say("Error closing channel to DVI viewer.");
}

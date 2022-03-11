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
#include "c.h"
#include "proc.h"
#include "colcode.h"
#include "perl.h"

// Look for matching c skipping over \'d chars.
perl_fwd_quote(int c)
{
	char pat[10];

	sprintf(pat, "%%%c|\\", c);
	while (re_search(1, pat))
		if (character(point - 1) == '\\')
			point++;
		else
			return 1;
	return 0;
}

// Return nonzero if p seems to follow an expression (if there's an
// expression-like thing before, or if there's a closing curly bracket
// on the same line).  An expression-like thing means a variable or
// function name marked as such, a number, or a parenthesized thing.

perl_after_expression(int p)
{
	int ch;
	if (!matches_at(p, -1, "([$%&#@]((<word>+(->|'))?<word>+)"
// A variable or function with $ or similar before it.
					"(%+%+|--)?"
// Possibly followed by ++ or --.
					  "|%$%^?[^ \t\n]"
// Or $, then perhaps a ^ and a nonspace.
					  "|<^word>[0-9]+([-0-9e.]+)?|[])`])"
// Or a number.  Or one of the characters ] or ) or `.
					  "(#.*|[ \t\n])*|}[ \t]*"))
// All followed by whitespace or a comment.
		return 0;
	ch = get_character_color(matchend);
	if (ch == color_class perl_comment || ch == color_class perl_string)
		return 0;
	return 1;
}

// Color simple variable references within this string-like thing (already
// colored itself).
color_perl_interpolated(int from, int to, int comments)
{
	int p;

	save_var point = from;
	save_var narrow_end = size() - to;
	while (re_search(1, in_shell_buffer ? "[\\$]" : "[\\$@#]")) {
		p = point;
		if (character(point - 1) == '\\')
			point++;
		else if (character(point - 1) == '#') {
			if (!comments)
				continue;
			from = point - 1;
			to_end_line();
			if (point > to)
				point = to;
			set_character_color(from, point, color_class perl_comment);
		} else if (in_shell_buffer) {
			if (parse_string(1, "[0-9A-Za-z_]+"))
				set_character_color(matchstart - 1, point = matchend,
									color_class perl_variable);
		} else if (curchar() == '{') {
			to_default_move_level(1, "{", "}", 1);
			set_character_color(p - 1, point, color_class perl_variable);
		} else if (parse_string(1, "#?[0-9A-Za-z_]+|%^[A-Z]"
								"|[]-[&`'+*|%=~^_./,\\\";:#?!@$<>()]")) {
			point = matchend;
			switch (curchar()) {
				case '[': case '{':
					to_default_move_level(1, "[{", "]}", 1);
					break;
			}
			set_character_color(p - 1, point, color_class perl_variable);
		}
	}
}

// Look for an unbackslashed c character, then color as a string.
// If interpolated, go back and color interpolated variables within.

color_perl_fwd_quote(int c, int start, int interpolated)
{
	perl_fwd_quote(c);
	set_character_color(start, point, color_class perl_string);
	if (interpolated)
		color_perl_interpolated(start, point, 0);
}

// Just found a format keyword, so color to its end.

color_perl_format()
{
	int start = point, i, j, have_vars = 0;

	point += parse_string(1, "[ \t]*[0-9A-Za-z_]+");	// Format's name.
	if (!parse_string(1, "[ \t]*="))	// Something funny's going on, give up.
		return;
	to_end_line();
	set_character_color(start, give_end_line() + 1, color_class perl_constant);
	save_var narrow_start = point, narrow_end = 0;
	re_search(1, "^[ \t]*%.$");	// Find end of format (or color rest of buffer).
	narrow_end = size() - (point - 1);
	point = 0;
	while (nl_forward()) {
		if (curchar() == '#') {		// A comment.
			set_character_color(point, give_end_line() + 1,
								color_class perl_comment);
		} else if (!have_vars) {	// A literal format line.
			set_character_color(point, give_end_line() + 1,
								color_class perl_string);
			have_vars = parse_string(1, ".*[@^]");
		} else {	// Variables for the previous line.
			i = point;
			set_character_color(point, give_end_line() + 1,
								color_class perl_constant);
			if (parse_string(1, "[ \t]*{")) {
				point = matchend - 1;
				j = default_move_level(1, "{", "}");
				point = (j < 0) ? size() : j;
				color_perl_interpolated(i, point, 0);
			} else {	// If not in {}'s, just one line of vars.
				color_perl_interpolated(point, give_end_line(), 0);
			}
			have_vars = 0;
		}
	}
}

// Match #1 has a terminating string.  See if it's a likely here document
// and color if so.
color_perl_here_doc(int start, int interpolated)
{
	char line[FNAMELEN], pat[FNAMELEN], *s;
	int p1, p2, end = matchend;

	grab(find_group(1, 1), find_group(1, 0), line);
	p1 = give_end_line() + 1;
	if (get_tagged_region("color-as-unit", p1) == 1) {
		get_tagged_region("color-as-unit", p1, NULL, &p1);
		start = p1;
	}
	sprintf(pat, "^%q$", line);
	if (re_search(1, pat))		// Find end of document (or eof).
		p2 = matchstart;
	else
		p2 = size();
	set_character_color(start, point, color_class perl_constant);
	set_tagged_region("color-as-unit", start, point, 1);
	save_var point;
	save_var narrow_start = p1;
	save_var narrow_end = size() - p2;
	s = get_extension(line);
	if (s)
		if (!strcmp(s, ".tex"))
			color_tex_range(p1, p2);
		else if (!strcmp(s, ".html"))
			color_html_range(p1, p2);
	restore_vars();
	if (interpolated)
		color_perl_interpolated(start, point, 0);
	point = end;
}

// Just before a delimiter character.  Find its match, then color.
// If two, we're parsing something like s/// so repeat.
// If interpolated, color any variable references like $var within it.
// If modifiers, also parse the modifiers after it (2 means they're
// regex modifiers).

color_perl_delimiters(int two, int interpolated, int modifiers)
{
	int start = point, c, end, level = 0, rstart, rend;
	char *openers = "([{<", *closers = ")]}>", *p;
	char pat[10];

	point += parse_string(1, "[ \t\n]+");
	set_character_color(start, point, color_class perl_comment);
	rstart = start = point;
	p = strchr(openers, c = end = curchar());
	if (isalnum(c) || isspace(c))
		return;			// No valid delimiter, so stop now.
	if (p) {			// A paired delimiter.
		end = closers[p - openers];
		sprintf(pat, "[%c%c]", end, c);
		while (re_search(1, pat))
			if (character(point - 1) == c)
				level++;
			else if (--level <= 0)
				break;
		set_character_color(start, point, color_class perl_string);
		if (interpolated)
			color_perl_interpolated(start, point, 0);
	} else {
		point++;
		color_perl_fwd_quote(c, start, interpolated);
	}
	rend = point;
	if (two)		// A command like s///, so look for 2nd set.
		if (p) {	// After a paired delimiter, whitespace and pick new char.
			start = point;
			point += parse_string(1, "([ \t\n]|#.*)+");
			set_character_color(start, point, color_class perl_comment);
			color_perl_delimiters(0, interpolated, 0);	// One more pair.
		} else		// Find 3rd instance of char.
			color_perl_fwd_quote(c, point, interpolated);
	if (modifiers) {
		start = point;
		if (modifiers == 2 && parse_string(1, "[a-z]*x"))
			color_perl_interpolated(rstart + 1, rend - 1, 1);
		point += parse_string(1, "[a-z]+");
		set_character_color(start, point, color_class perl_keyword);
	}
}

// If this is a label, color it and move past it.  But if it's a
// conditional keyword, don't do either.

color_perl_label(int start, int end)
{
	point = start;
	if (parse_string(1, "(if|unless)<^word>"))
		return;
	set_character_color(start, end, color_class perl_constant);
	point = end;
}

// Found an undecorated word; maybe it's a keyword.  Do the appropriate thing
// for various keywords we know about.  Otherwise it's probably a function
// call.

color_perl_keyword(int start)
{
	char buf[100];

	if (point - start < sizeof(buf) - 10
		  && (point - start > 1 || character(start - 1) != '-')) {
		buf[0] = '|';		// get identifier, between | chars
		grab(start, point, buf + 1);
		strcat(buf, "|");
	} else	// Too long to be a keyword, or else it's -s or similar.
		strcpy(buf, "not a keyword");
	if (strstr("|package|sub|", buf)) {
		point += parse_string(1, "[ \t]+");
		set_character_color(start, point, color_class perl_keyword);
		if (parse_string(1, "(<word>+('|::))*<word>+"))
			set_character_color(matchstart, point = matchend,
								color_class perl_function);
	} else if (strstr("|import|no|require|use|", buf)) {
		point += parse_string(1, "[ \t]+");
		set_character_color(start, point, color_class perl_keyword);
		if (parse_string(1, "(<word>+('|::))*<word>+"))
			set_character_color(matchstart, point = matchend,
								color_class perl_constant);
	} else if (strstr("|die|do|dump|else|elsif|eval|exec|exit|for|foreach|if|"
			   "return|unless|until|while|BEGIN|END|", buf)) {
		set_character_color(start, point, color_class perl_keyword);
	} else if (strstr("|local|my|", buf)) {		// special color
		set_character_color(start, point, color_class perl_constant);
	} else if (strstr("|continue|goto|last|next|redo|", buf)) {
		point += parse_string(1, "[ \t]+");
		set_character_color(start, point, color_class perl_keyword);
		if (parse_string(1, "[0-9A-Za-z_]+"))	// A label.
			color_perl_label(matchstart, matchend);
	} else if (strstr("|qq|qx|", buf) && !isspace(curchar())) {
		set_character_color(start, point, color_class perl_keyword);
		color_perl_delimiters(0, 1, 0);	// One pattern, interpolated.
	} else if (strstr("|m|", buf) && !isspace(curchar())) {
		set_character_color(start, point, color_class perl_keyword);
		color_perl_delimiters(0, 1, 2);	// One pattern, interp, w/modifiers.
	} else if (strstr("|q|qw|", buf) && !isspace(curchar())) {
		set_character_color(start, point, color_class perl_keyword);
		color_perl_delimiters(0, 0, 0);	// One pattern, uninterpolated.
	} else if (strstr("|s|", buf) && !isspace(curchar())) {
		set_character_color(start, point, color_class perl_keyword);
		color_perl_delimiters(1, 1, 2);	// Two patterns, interpolated.
	} else if (strstr("|tr|y|", buf) && !isspace(curchar())) {
		set_character_color(start, point, color_class perl_keyword);
		color_perl_delimiters(1, 0, 1);	// Two patterns, uninterpolated.
	} else if (strstr("|format|", buf)) {
		set_character_color(start, point, color_class perl_keyword);
		color_perl_format();
	} else if (strstr("|__END__|__DATA__|", buf)) {	// Skip to the end.
		set_character_color(start, point, color_class perl_keyword);
		set_character_color(point, size(), color_class perl_constant);
		point = size();
	} else if (character(point) == ':' && matches_at(point, 1, ":[^:]")
			   && matches_at(start, -1, "^[ \t]*")) {		// a label
		set_character_color(start, point, color_class perl_constant);
	} else
		set_character_color(start, point, color_class perl_function);
}

// Found a word; see if it's decorated like a variable or subr.
color_perl_word(int start)
{
	if (!in_shell_buffer)
		point += parse_string(1, "('|::)<word>+");	// pkg::var
	if (strchr(in_shell_buffer ? "$" : "$*@%",
			   character(start - 1))) {	// $var, @var etc.
		set_character_color(start - 1, point, color_class perl_variable);
	} else if (!in_shell_buffer && character(start - 1) == '&') {	// &funcname
		set_character_color(start - 1, point, color_class perl_function);
	} else if (!in_shell_buffer && character(start - 1) == '<'
			   && character(point) == '>') {
		set_character_color(start - 1, point, color_class perl_constant);
	} else if (isdigit(character(start))) {		// a number
		if (matches_at(start, -1, "-?%.?"))	// number like -.25
			start = matchend;
		point += parse_string(1, "([A-Za-z0-9._]|[Ee]-)*");		// -3.0e-7
		set_character_color(start, point, color_class perl_constant);
	} else if (!in_shell_buffer)
		if (parse_string(1, "[ \t\n]*=>"))
			set_character_color(start, point, color_class perl_constant);
		else if (character(start - 1) == '{' && curchar() == '}')
			set_character_color(start, point, color_class perl_constant);
		else
			color_perl_keyword(start);
}

// Recolor just this section.  The last colored region may go
// past to.

// In parsing Perl, we can't just start anywhere.  We know that
// anything earlier in the buffer is already colored correctly
// (because we specify through coloring_flags that a buffer
// change invalidates all coloring after it).  So we look back
// for a safe place.  Here we assume that an uncolored section
// (-1) is never between "interesting" tokens, and we can pick up
// coloring from any such place.  That means, for correct
// coloring of a sequence like "sub funcname", the space between
// these cannot be in color -1.

color_perl_range(from, to)
{
	int t = -1, talk, c, talk_at = 0, after_here_doc = 0;

	if (from >= to)
		return to;
	save_var point, matchstart, matchend, case_fold = 0;
	save_var narrow_start = 0, narrow_end = 0;
	do {
		from--;		// Get to uncolored section.
	} while (from > 0 && (get_character_color(from, &from) != -1
			|| get_tagged_region("color-as-unit", from) != -1));
	set_tagged_region("color-as-unit", from, size(), -1);
	point = from;
	talk = (to - from > 10000);	// Show status during long delays.
	while (point < to) {
		if (!re_search(1, "[0-9A-Za-z_]+|[\"'`/#$&<=\n]")) {
			t = size();
			break;
		}
		t = matchstart;
		switch (c = character(point - 1)) {		// check last char
			case '#':			// found comment
				to_end_line();
				set_character_color(t, point, color_class perl_comment);
				break;
			case '&':
				if (in_shell_buffer)
					break;
				if (parse_string(1, "((<word>+('|::))*|'|::)<word>+"))
					set_character_color(t, point = matchend,
										color_class perl_function);
				break;
			case '$':
				if (in_shell_buffer) {
					if (parse_string(1, "<word>+|{[^}\n]+}|."))
						set_character_color(t, point = matchend,
											color_class perl_variable);
					break;
				}
				if (!isident(curchar()) && !strchr("#{}", curchar())) {
					if (character(point++) == '^')
						point++;	// $', $?, $^Z or similar special var
					set_character_color(t, point, color_class perl_variable);
				} else if (parse_string(1, "#?((<word>+('|::))*|'|::)<word>+"))
					set_character_color(t, point = matchend,
										color_class perl_variable);
				break;
			case '\'':
				if (in_shell_buffer ? character(t - 1) != '\\'
									: (!isident(character(t - 1))
									   && !strchr("&$@%*", character(t - 1))))
					color_perl_fwd_quote(c, t, 0);	// old syntax pkg'func
				break;
			case '"':		// found a string literal
			case '`':
				color_perl_fwd_quote(c, t, 1);
				break;
			case '/':	// if previous thing looks like an expression, skip it
				if (!in_shell_buffer && !perl_after_expression(t)) {
					point--;
					color_perl_delimiters(0, 1, 2);
				}
				break;
			case '<':
				if (perl_after_expression(t) || character(t - 1) == '<')
					break; // It's a shift or lessthan op, not "here" doc or input op.
				if (curchar() == '<') {		// found <<, possible "here" document.
					point++;	// Next must be an identifier or text in quotes.
					if (parse_string(1, in_shell_buffer ? "[ \t]*-?(<alpha|_>+)"
									 : "(<alpha|_>+)"))
						color_perl_here_doc(t, 1);
					else if (parse_string(1, "[ \t]*\"([^\"\n]+)\""))
						color_perl_here_doc(t, 1);
					else if (parse_string(1, "[ \t]*'([^'\n]+)'"))
						color_perl_here_doc(t, 0);
					else if (parse_string(1, "[ \t]*`([^`\n]+)`"))
						color_perl_here_doc(t, 1);
					else
						break;
					after_here_doc = 1;
					break;
				}
				if (in_shell_buffer)
					break;
				point--;	// File glob operator.
				color_perl_delimiters(0, 1, 0);
				break;
			case '\n':
				if (after_here_doc)
					if (get_tagged_region("color-as-unit", point) == 1)
						to_end_line();	// Already colored this line.
					else
						after_here_doc = 0;
				break;
			case '=':			// Found POD (documentation).
				if (in_shell_buffer)
					break;
				if (parse_string(-1, "^=")) {
					search(1, "\n=cut");
					set_character_color(t, point, color_class perl_comment);
				}
				break;
			default:		// found identifier, kywd, or number
				color_perl_word(t);
				break;
		}
		if (talk && point > talk_at + 2000) {
			note("Coloring Perl program: %d%% complete...",
				 muldiv(point - from, 100, to - from));
			talk_at = point;
		}
	}
	if (talk)
		note("");
	return point;
}

int in_perl_comment(int pos)
{
	int ch = get_character_syntax_color(pos);

	if (ch == color_class perl_comment)
		return IN_NEW_COMMENT;
	else if (ch == color_class perl_string)
		return IN_STR_CONST;
	return 0;
}

/* Look backward for a matching pair of delimiters, ignoring
 * delimiters inside strings, character constants, or comments.
 */

int perl_skip_level(int dir, char left_d, char right_d)
{
	char pattern[40], ch;
	int level = 0, pos;

	sprintf(pattern, "[%c%c]", right_d, left_d);
	do {
		if (!re_search(dir, pattern))
			return 0;
		pos = point - (dir > 0);
		if (in_perl_comment(pos))
			continue;
		if (character(pos - 1) == '$' && get_character_syntax_color(pos - 1)
			  == color_class perl_variable)
			continue;		// Actually a $[ or similar.
		ch = character(pos);
		if (ch == right_d)
			level++;
		else if (ch == left_d)
			level--;
	} while ((dir > 0) ? (level < 0) : (level > 0));
	return 1;
}


/*  Look at the last two lines (or more sometimes) and return the
    correct indentation for the current line, assuming Perl source.  At
    start, we must be at the end of a line's indentation.  We borrow
    heavily from C mode.
*/

perl_compute_indent()
{
	int ind = 0;		/* indentation to use */
	int orig = point, i;
	int first_char = curchar(); /* cur line's first char */
	int pstart;		/* start position of prev line */
	int pafter;		/* after label on prev line */
	int pend;		/* end position of prev line */
	int prev_end = ';';	/* last char on previous line */
	int norm_narrow;	/* narrowing setting for most parsing */

	save_var point;
	save_var Closeback = perl_closeback;
	save_var Topindent = perl_topindent;
	save_var c_indent = perl_indent;
	save_var c_label_indent = perl_label_indent;
	save_var c_contin_offset = perl_contin_offset;
	save_var c_align_contin_lines = perl_align_contin_lines;
	save_var c_brace_offset = perl_brace_offset;
	save_var c_top_braces = perl_top_braces;
	save_var c_top_contin = perl_top_contin;
	save_var c_top_struct = perl_top_struct;

	save_var narrow_start = 0;
	recolor_buffer_range(orig, orig + 1);
	if (get_character_color(orig, &i) == color_class perl_constant
		  && matches_at(i, 1, "%<%<"))		// Keep original's indentation
		return get_indentation(orig);		// if in here doc
	if (get_character_color(orig - 1, &i) == color_class perl_string)
		return get_indentation(orig);		// or in string.

	norm_narrow = fix_narrowing(point - c_look_back);
	narrow_start = norm_narrow;
	if (first_char == '\f')
		return 0;
	else if (first_char == '}')
		return cind_close();

	to_begin_line();
	if (parse_string(1, "[ \t]*\n") && after_many_comments()) {
		re_search(-1, "[^ \t\n]");	/* find previous non-blank line */
		return get_indentation(point);
	}
	cind_space();			/* skip whitespace and comments */
	if (character(point - 1) == ':')
		move_before_labels();
	prev_end = character(point - 1); /* get last relevant char */
	pend = point;

	to_statement_start();		/* if contin line, back up */
	pstart = point;			/* now at start of biggest statement */
	past_labels();			/* containing original point */
	pafter = point;			/* just after label */
	ind = current_column();
	narrow_start = norm_narrow;	/* ok to look far back again */

	if (have_label(orig)) {
		ind = c_label_indent;
	} else if (prev_end == ':' && is_label(pstart)) {
		ind = get_column(pstart);
		if (!(Closeback && just_open(orig)))
			ind += get_c_indent();
		if (just_open(orig))
			ind += c_brace_offset;
	} else if (is_else(orig)) {
		point = orig;
		ind = indent_else(ind);
	} else if (prev_end == ';') {
		if (just_open(orig) && func_start_block(pstart))
			ind = c_top_braces;
		else
			ind = indent_after_statement(orig);
	} else if (prev_end == '}') {
		point = pend;
		ind = indent_after_block(orig);
	} else if (prev_end == '{') {
		if (ind <= c_top_braces	// special case if no previous indent
			|| get_column(pend - 1) <= c_top_braces) {
			ind += top_indent(prev_end) ? get_c_indent() : c_top_braces;
			if (just_open(orig))
				ind += c_brace_offset;
			if (ind < c_top_braces)
				ind = c_top_braces;
		} else if (Closeback || curchar() != '{')
			ind += get_c_indent();
		if (just_open(pafter))
			ind -= c_brace_offset;
	} else if (just_open(orig))
		return indent_just_open(ind);
	else if (is_contin_statement(pend, 1, orig)) {
		return indent_c_contin(ind, orig, pend);
	} else if (!index(":);{}", c_line_before()) && !c_statement_start()
			   && !(Closeback && just_open(point)))
		return ind;
	else
		ind += get_c_indent();
	return ind;
}

// Return a value like in_perl_comment for the given character
// (IN_NEW_COMMENT for a comment, IN_STR_CONST for a string, 0
// otherwise).  But return IN_CHAR_CONST as a flag if the string
// character seems to be quoted.  We assume it is if it's preceded by an
// odd number of \ chars.  (Sometimes backslashes in Perl string context
// don't quote some characters, but we ignore that complication.)

perl_delim_type(int pos)
{
	int cnt, type = in_perl_comment(pos);

	if (type != IN_STR_CONST)
		return type;
	save_var point = pos;
	for (cnt = 0; point > narrow_start; cnt++)
		if (character(--point) != '\\')
			break;
	return (cnt & 1) ? IN_CHAR_CONST : IN_STR_CONST;
}

/*
 * Move in direction dir past a matched pair of delimiters {}, (), or []
 * in a Perl-mode or shell-mode buffer.  If the delimiters aren't
 * matched, or if we hit any unmatched delimiter first, return -1.  On
 * success, return the new buffer position.  Ignore delimiters inside of
 * comments or strings (or, if we started with one, bail out when we
 * find one that isn't in a comment or string).  (We ignore quoted
 * delims in strings when we start from an unquoted one, and vice
 * versa.)  If stop_on_key and a key is pressed, return -2 immediately.
 */

int perl_smart_move_level(int dir, int comm, int stop_on_key, int ignore_parens)
{
	char delims[100], *pat = (dir > 0) ? "])}[({" : "[({])}";
	int c, i, depth = 0, t, cnt = 0, this_comm;

	while (re_search(dir, "[])}[({]")) {
		t = point - (dir > 0);
		c = character(t);
		i = strchr(pat, c) - pat;
		if (ignore_parens && strchr("()", c))
			continue;
		if (character(t - 1) == '$' && !strchr("{}", c)
			  && get_character_syntax_color(t - 1) == color_class perl_variable)
			continue;		// Actually a $[ or similar.
		if (stop_on_key && (cnt++ % 20 == 0)
			  && (char_avail() || is_key_repeating()))
			return -2;		// Give up search now?
		this_comm = perl_delim_type(t);
		if (this_comm != comm)
			if (!comm)		// We didn't start in comment/string, so
				continue;	// skip over delims in comments/strings.
			else if ((this_comm & 0xf00) == (comm & 0xf00))
				continue;	// Ignore quoted delims.
			else			// If we started in comment/string,
				return -1;	// stop if we ever search outside it.
		if (i < 3) {		// Closing delim.
			if (depth < 1 || c != delims[--depth])
				return -1;	// This didn't match what we expected.
			if (!depth)		// We found a match, success.
				return point;
		} else if (depth < sizeof(delims) - 1)	// Opening delim, record it.
			delims[depth++] = pat[i - 3];
		else
			return -1;		// Too deep, give up.
	}
	return -1;
}

/*
Move in direction dir past a matched pair of characters in Perl-mode buffers.
On success, or if the end of the buffer is encountered before the
first character is found, return the new buffer position.
Otherwise return -1.  If stop_on_key and a key is pressed, return -2
immediately.
Ignore delimiters inside of comments or strings.  (However, if we began
inside a comment or string, then accept such delimiters.)
*/

perl_move_level(int dir, int stop_on_key)
{
	int cnow;

	save_var point;			// if aborted, don't move anywhere
	if (!re_search(dir, (dir > 0) ? "[[({]" : "[])}]"))
		return point;	/* at end of buffer */
	cnow = perl_delim_type(point - (dir > 0));
	point -= dir;			/* move back over first char */
	return perl_smart_move_level(dir, cnow, stop_on_key,
			in_shell_buffer && !strchr("()", character(point - (dir < 0))));
}

int perl_mute_unmatched_delimiter(int dir)
{
	return perl_delim_type(point - (dir > 0));
}

// Set display_func_name to the name of the function we're editing, and
// return 1.  If not in a function, set display_func_name to "" and
// return 1.  If user pressed a key and we gave up for now, return 0.

perl_func_name_finder()
{
	int orig = point, end, from, to;

	save_var point;
	to_end_line();
	recolor_buffer_range(0, point);
	while (search(-1, "sub")) {
		if (!parse_string(1,  "<[word>(sub)[ \t]+(([a-zA-Z_]<word>+"
						 "((::|')[a-zA-Z_]<word>+)?))"))
			continue;
		if (get_character_color(find_group(1, 1)) == color_class perl_keyword
			&& get_character_color(find_group(2, 1)) == color_class perl_function) {
			from = find_group(2, 1);
			to = find_group(2, 0);
			to = MIN(to, from + ptrlen(display_func_name) - 1);
			grab(from, to, display_func_name);
			if (re_search(1, "!{")) {
				end = perl_move_level(1, 1);
				if (end == -2)
					return 0;
				if (end != -1 && orig > end)
					break;
			}
			return 1;
		}
	}
	*display_func_name = 0;
	return 1;
}

perl_like_mode()
{
	mode_default_settings();
	mode_keys = c_tab;		/* Use these keys. */
	in_perl_buffer = 1;		/* But with modified definitions. */
	indenter = c_indenter;
	auto_indent = 1;
	mode_move_level = perl_move_level;
	mute_unmatched_delimiter = perl_mute_unmatched_delimiter;
	strcpy(comment_start, "#[ \t]*");
	strcpy(comment_pattern, "#.*$");
	strcpy(comment_begin, "# ");
	strcpy(comment_end, "");
	recolor_range = color_perl_range;	// set up coloring rules
	recolor_from_here = recolor_from_top;
	coloring_flags |= COLOR_INVALIDATE_FORWARD | COLOR_INVALIDATE_RESETS;
	if (want_code_coloring)		// maybe turn on coloring
		when_setting_want_code_coloring();
	buffer_maybe_break_line = c_maybe_break_line;
	if (c_fill_column > 0)
		margin_right = c_fill_column;
}

command perl_mode()
{
	perl_like_mode();
	major_mode = _perl_mode_name;
	compile_buffer_cmd = compile_perl_cmd;	// can compile this
	in_shell_buffer = 0;
	if (auto_show_perl_delimiters)
		auto_show_matching_characters = perl_auto_show_delim_chars;
	if (perl_tab_override > 0)
		tab_size = perl_tab_override;
	try_calling("perl-mode-hook");
	drop_all_colored_regions();
	make_mode();
}

suffix_perl()
{
	perl_mode();
}

suffix_pm()		// Perl v5 module extension
{
	perl_mode();
}

suffix_al()		// Perl autoloaded file
{
	perl_mode();
}

suffix_ph()			// old Perl module extension
{
	perl_mode();
}

suffix_pl()			// old Perl module extension
{
	perl_mode();
}

tag_suffix_perl()
{
	char func[TAGLEN];
	int start;

	perl_mode();
	recolor_buffer_range(0, size());	// Just to skip over comments
	save_var point = 0, case_fold = 0;				// & strings.
	while (re_search(1, "<^word>(sub)[ \t]+([a-zA-Z_]<word>*"
					 "((::|')[a-zA-Z_]<word>*)?)")) {
		if (get_character_color(find_group(1, 1)) == color_class perl_keyword
			&& get_character_color(find_group(2, 1)) == color_class perl_function) {
			grab(start = find_group(2, 1), find_group(2, 0), func);
			add_tag(func, start);
		}
	}
}

tag_suffix_pm()		// Perl v5 module extension
{
	tag_suffix_perl();
}

tag_suffix_al()		// Perl autoloaded file
{
	tag_suffix_perl();
}

tag_suffix_ph()			// old Perl module extension
{
	tag_suffix_perl();
}

tag_suffix_pl()			// old Perl module extension
{
	tag_suffix_perl();
}

command shell_mode()
{
	perl_like_mode();
	major_mode = _shell_mode_name;
	in_shell_buffer = 1;
	if (auto_show_shell_delimiters)
		auto_show_matching_characters = shell_auto_show_delim_chars;
	if (shell_tab_override > 0)
		tab_size = shell_tab_override;
	try_calling("shell-mode-hook");
	drop_all_colored_regions();
	make_mode();
}

suffix_sh()
{
	shell_mode();
}

suffix_csh()
{
	shell_mode();
}

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

// This file has C mode.

#include "eel.h"
#include "c.h"
#include "kill.h"
#include "colcode.h"
#include "proc.h"
#include "tags.h"

/*
Automatic indentation for C and EEL code.  Several indenting styles
are supported, selected by the following variables.

                        *       *       *       *

The position of the closing brace is controlled by the Closeback
variable, 1 by default:

Closeback = 0;                  Closeback = 1;
if (foo) {                      if (foo) {
        bar();                          bar();
        baz();                          baz();
        }                       }

By placing the opening brace on the following line, these styles
may be also used:

Closeback = 0;                  Closeback = 1;
if (foo)                        if (foo)
        {                       {
        bar();                          bar();
        baz();                          baz();
        }                       }


                        *       *       *       *

The Topindent variable controls whether top-level statements in a function
are indented.  It is 1 by default.

Topindent = 0;                  Topindent = 1;
foo()                           foo()
{                               {
if (bar)                                if (bar)
        baz();                                  baz();
}                               }

                        *       *       *       *

The Matchdelim variable controls whether typing ), ], or } displays the
corresponding (, [, or { when the former is typed.  It uses the
show-matching-delimiter command.
*/

c_indenter()		/* replace surrounding indentation with new */
{
	if (in_shell_buffer)
		prev_indenter();
	else if (!(in_c_comment(c_look_back) & IN_COMMENT))
		indent_to_column(c_compute_indent());
	else if (reindent_c_comments && !in_perl_buffer)
		indent_c_comment();
}

/*
 * Move in direction dir past a matched pair of delimiters {}, (), or
 * [] in a C-mode buffer.  If the delimiters aren't matched, or if we
 * hit any unmatched delimiter first, return -1.  On success, return
 * the new buffer position.  Ignore delimiters inside of comments or
 * strings.  If stop_on_key and a key is pressed, return -2 immediately.
 */

int c_smart_move_level(int dir, int comm, int stop_on_key)
{
	char delims[100], *pat = (dir > 0) ? "])}[({*/" : "[({])}*/";
	int c, i, depth = 0, cnt = 0;
	int in_block_comment = (comm == IN_OLD_COMMENT) ? comm : 0;

	while (re_search(dir, "[])}[({]|/%*|%*/")) {
		if (stop_on_key && (cnt++ % 20 == 0)
			  && (char_avail() || is_key_repeating()))
			return -2;		// Give up search now?
		c = character(point - (dir > 0));
		if (c == '/' && !in_c_comment(c_look_back))
			in_block_comment = 0;	// Leaving a block comment.
		else if (c == '*' && in_c_comment(c_look_back) == IN_OLD_COMMENT)
			in_block_comment = IN_OLD_COMMENT;	// Entering block comment.
		i = strchr(pat, c) - pat;
		if (i >= 6)	// Block comment chars, not delimiters.
			continue;
		if ((in_block_comment ? in_block_comment : in_c_comment(0)) != comm)
			if (comm)			// If we started in comment/string,
				return -1;		// stop if we ever search outside it.
			else				// We didn't start in comment/string, so
				continue;		// skip over delims in comments/strings.
		if (i < 3) {		// Closing delim.
			if (depth < 1 || c != delims[--depth])
				return -1;	// This didn't match what we expected.
			if (!depth)		// We found a match, success.
				return point;
		} else			// Opening delim, record it.
			delims[depth++] = pat[i - 3];
	}
	return -1;
}

/*
Move in direction dir past a matched pair of characters in C-mode buffers.
On success, or if the end of the buffer is encountered before the
first character is found, return the new buffer position.
Otherwise return -1.  If stop_on_key and a key is pressed, return -2
immediately.
Ignore delimiters inside of comments or strings.  (However, if we began
inside a comment or string, then accept such delimiters.)
*/

c_move_level(int dir, int stop_on_key)
{
	int cnow, cstart = in_c_comment(c_look_back);	// in comment/string at start?

	save_var point;			// if aborted, don't move anywhere
	do {				/* find the first char of pair */
		if (!re_search(dir, (dir > 0) ? "[[({]" : "[])}]"))
			return point;	/* at end of buffer */
		cnow = in_c_comment(c_look_back);	// ignore if it's in a comment/string
	} while (cnow && cnow != cstart);	// (unless we started in one)
	point -= dir;			/* move back over first char */
	return c_smart_move_level(dir, cnow, stop_on_key);
}

c_mute_unmatched_delimiter(int dir)
{
	UNREFERENCED_PARAMETER(dir);
	return in_c_comment(c_look_back) != 0;
}

// If we're before the brackets of a function definition, move before the
// function name (filling it in if != NULL) and return 1, else 0..
int move_before_func_name(char *func)
{
	int p, end;

	if (cind_try_space())
		return 0;
	point -= parse_string(-1, "</word>throws[ \t\n]+[a-z0-9_]+"
						  "([ \t\n]*,[ \t\n]*[a-z0-9_]+)*");
	if (cind_try_space())
		return 0;
	if (character(point - 1) != ')' || !c_rev_skip_level('(', ')'))
		return 0;
	if (cind_try_space())
		return 0;
	end = point;
	if (character(point - 1) == '>' && !parse_string(-1, "operator%>")
		  && (p = default_move_level(-1, ">", "<")) >= 0)
		point = p;			// Move past template stuff.
	if (!parse_string(-1, CPP_OPSPEC) && !parse_string(-1, "~?[a-zA-Z0-9_]+"))
		return 0;
	point = matchend;
	if (c_statement_start())
		return 0;
	if (func)
		if (end - point >= ptrlen(func) - 1)
			return 0;
		else
			grab(point, end, func);
	return 1;
}

// Our normal backward scanning looks for outermost braces
// at the left margin.  This function helps to correct matters when some
// functions don't follow that rule.  When positioned just before a
// left brace, it returns nonzero if the matching right brace is before
// the starting position, remaining after the right brace.  Otherwise
// it returns 0 and doesn't move.

find_c_func_oneliner(int start)
{
	if (curchar() != '{')
		return 0;
	save_var narrow_end = size() - start;
	return !skip_c_delims('{', '}', 1);
}

// Inside a class definition, try to determine the name of the current function.
int find_inner_func_name(int start, int class_start, char *func)
{
	int braces, cnt;

	save_var narrow_start = class_start;
	point = start + 1;
	while (c_rev_skip_level('{', '}')) {
		braces = point;
		cnt = 0;
		while (move_before_func_name(func)) {
			cnt++;
			if (cind_try_space() || !parse_string(-1, "[:,]"))
				break;
			point--;
			cind_try_space();
		}
		if (cnt > 0) {
			point = braces;
			skip_c_braces();
			return (start < point);
		}
	}
	return 0;
}

// Helper for find_c_func_info.  We've found a { character; see if it
// starts a class def or similar.  If so, see if our original
// position is within one of its functions.  Params and returns like
// find_c_func_info.

int find_c_class_info(int start, char *type, char *class, char *func)
{
	char this[FNAMELEN], last[FNAMELEN];
	int class_start = point, i;

	point--;	// See if "class foo" is before this.
	strcpy(last, "");
	for (i = 20; i-- > 0; ) {	// Look through some words before the {.
		if (cind_try_space() || give_begin_line() > start)
			return 0;
		if (strchr("<>:,", character(point - 1)))
			point--;
		else {
			if (!parse_string(-1, "[a-zA-Z0-9_]+", this))
				return 0;
			if (!strcmp(this, "class") || !strcmp(this, "struct")
				|| !strcmp(this, "union") || !strcmp(this, "namespace")) {
				if (type)
					strcpy(type, this);		// Word to the right of type is class.
				if (class)
					strcpy(class, last);	// Is place where we started within func?
				if (find_inner_func_name(start, class_start, func))
					return CF_INFO_TYPE | CF_INFO_CLASS | CF_INFO_FUNC;
				if (func)
					*func = 0;
				return CF_INFO_TYPE | CF_INFO_CLASS;
			}
			strcpy(last, this);		// Go on to the next word.
		}
	}
	return 0;		// Couldn't recognize anything here.
}

// Get info on the current C function or class we're within.  Set
// class to the class name if any and func to the function name if
// any.  Set type to "class", "struct", or "union" if we know which.
// Outside a function or class def, these will be set to "".  Any of
// the three may be NULL if this information isn't needed.

// If stop_on_key != 0, may return -1 if user's pressed a key during
// execution.  Otherwise returns bit pattern: CF_INFO_TYPE (1) if
// type != "", CF_INFO_CLASS (2) if class != "", CF_INFO_FUNC (4) if
// func != "".  Possible values 0, 3, 4, 6, 7.

int find_c_func_info(char *type, char *class, char *func, int stop_on_key)
{
	char funcname[FNAMELEN], classname[FNAMELEN];
	int start, funcstart, i, j;

	*classname = *funcname = 0;
	if (func)
		*func = 0;
	if (class)
		*class = 0;
	if (type)
		*type = 0;
	save_var point, matchstart, matchend, narrow_start = 0, narrow_end = 0;
	save_var tag_declarations = 0;	// We use tagging sometimes.
	to_begin_line();
	start = point;
	point--;		// Begin searching at the last } char on the left margin...
	while (search(-1, "\n}")) {
		point++;		// ...that's not in a comment.
		if (!in_c_comment(c_look_back))
			break;
		point--;
	}

	while (re_search(1, "{|/<*|/>|(~?[a-zA-Z0-9_]+|" CPP_OPSPEC ")[ \t\n]*%(")) {
		point = matchstart;
		if (stop_on_key && (char_avail() || is_key_repeating()))
			return -1;		// Give up search now?
		if (parse_string(-1, "^[ \t]*#[ \t]*(define|if).*(\\\n.*)*")) {
			nl_forward();	// Ignore everything in a macro definition.
			continue;
		}
		switch (curchar()) {
			case '{':		// Could be start of class def.
				j = point;
				i = find_c_class_info(start, type, class, func);
				if (i)
					return i;
				point = j;
				c_skip_level('{', '}');
				break;
			case '/':
				if (character(point + 1) == '*') {		// Skip over comment.
					point += 2;
					search(1, "*/");
				} else
					nl_forward();	/* c++ comment */
				break;
			default:		// Found an identifier; is it a function def?
				if (give_begin_line() > start)
					return 0;		// Gone too far, so give up.
				funcstart = point;
				if (!parse_string(1, "~?[a-zA-Z0-9_]+|" CPP_OPSPEC, funcname))
					return 0;
				if (parse_string(1, "[ \t\n]*%("))
					narrow_end = size() - (point + 1000);
				if (tag_c_func(0) == 2 && !find_c_func_oneliner(start)) {
					point = funcstart;	// Checks out as a function def.
					*classname = 0;
					if (parse_string(-1, "[ \t\n]*::[ \t\n]*")) {
						point = matchend;
						parse_string(-1, "[a-zA-Z0-9_]+", classname);
					}
					if (func)
						strcpy(func, funcname);
					if (class)
						strcpy(class, classname);
					return CF_INFO_FUNC | (*classname ? CF_INFO_CLASS : 0);
				}
				*funcname = 0;
				narrow_end = 0;
				break;
		}
	}
	return 0;
}

// Fill funcname with the name of the current function we're editing,
// "" if none.  If stop_on_key, return 0 immediately if the user's
// pressed a key (otherwise only respect aborting) and leave funcname
// alone.  Return 1 otherwise.

find_c_func_name(char *funcname, int stop_on_key)
{
	char type[FNAMELEN], func[FNAMELEN], class[FNAMELEN];
	int i = find_c_func_info(type, class, func, stop_on_key);

	if (i == -1)		// User pressed a key, give up.
		return 0;
	*funcname = 0;
	if (strlen(type) + strlen(class) + strlen(func) + 4 >= ptrlen(funcname)) {
		sprintf(funcname, "...%s%.*s",
				(*class && *func) ? "::" : "",
				ptrlen(funcname) - 10, *func ? func : class);
		return 1;
	}
	switch (i) {			// Format the information for display.
		case CF_INFO_TYPE | CF_INFO_CLASS | CF_INFO_FUNC:
			sprintf(funcname, "%s %s::%s", type, class, func);
			break;
		case CF_INFO_TYPE | CF_INFO_CLASS:
			sprintf(funcname, "%s %s", type, class);
			break;
		case				CF_INFO_CLASS | CF_INFO_FUNC:
			sprintf(funcname, "%s::%s", class, func);
			break;
		case								CF_INFO_FUNC:
			sprintf(funcname, "%s", func);
			break;
	}
	return 1;
}

// Set display_func_name to the name of the function we're editing, and
// return 1.  If not in a function, set display_func_name to "" and
// return 1.  If user pressed a key and we gave up for now, return 0.

c_func_name_finder()
{
	return find_c_func_name(display_func_name, 1);
}

command c_mode()
{
	mode_default_settings();
	mode_keys = c_tab;		/* use these keys */
	in_perl_buffer = 0;
	indenter = c_indenter;
	auto_indent = 1;
	major_mode = _c_mode_name;
	strcpy(comment_start, "(/</|*>)[ \t\f]*");
	strcpy(comment_pattern, "//.*$|/<*>(.|<newline>)*<*>/<FirstEnd>");
	when_setting_new_c_comments();
	mode_move_level = c_move_level;
	mute_unmatched_delimiter = c_mute_unmatched_delimiter;
	recolor_range = color_c_range;	// set up coloring rules
	recolor_from_here = color_c_from_here;
	if (want_code_coloring)		// maybe turn on coloring
		when_setting_want_code_coloring();
	if (auto_show_c_delimiters)
		auto_show_matching_characters = c_auto_show_delim_chars;
	if (c_mode_mouse_to_tag)
		mouse_goes_to_tag = 1;
	if (c_tab_override > 0)
		tab_size = c_tab_override;
	buffer_maybe_break_line = c_maybe_break_line;
	if (c_fill_column > 0)
		margin_right = c_fill_column;
	try_calling("c-mode-hook");
	drop_all_colored_regions();
	make_mode();
}

c_mode_hook()
{
}

/* make c mode the default mode for .c, .h, .e, etc. files,
 with slight modifications for each */

suffix_c()
{
	c_mode();
	compile_buffer_cmd = compile_c_cmd;	// can compile this
	if (is_unix)			// special definition
		compile_buffer_cmd = compile_c_cmd_unix;
	c_extra_keywords = 0;	// don't recognize C++ or EEL keywords in .c
}

suffix_h()
{
	c_mode();
	c_extra_keywords = CPP_KEYWORDS | EEL_KEYWORDS;
}	// recognize all keywords; can't tell if it's C/C++/EEL from extension

suffix_cpp()
{
	c_mode();
	compile_buffer_cmd = compile_cpp_cmd;	// can compile this
	if (is_unix)			// special definition
		compile_buffer_cmd = compile_c_cmd_unix;
	c_extra_keywords = CPP_KEYWORDS;	// recognize only C++, not EEL
}

suffix_inl()		// Dev Studio inline files.
{
	c_mode();
	c_extra_keywords = CPP_KEYWORDS;	// recognize only C++, not EEL
}

suffix_hpp()
{
	c_mode();
	c_extra_keywords = CPP_KEYWORDS;	// recognize only C++, not EEL
}

suffix_e()
{
	c_mode();
	concurrent_compile = 0;	// we want to load it after, so no concur
	compile_buffer_cmd = compile_eel_cmd;		// can compile this
	post_compile_hook = load_this_bytecode_file;	// and load it after
	pre_compile_hook = compile_via_dll;	 // maybe compile internally
	c_extra_keywords = EEL_KEYWORDS;	// recognize only EEL, not C++
	if (eel_tab_override > 0)
		tab_size = eel_tab_override;
}

suffix_java()
{
	c_mode();
	compile_buffer_cmd = compile_java_cmd;	// can compile this
	c_extra_keywords = JAVA_KEYWORDS;	// recognize Java keywords
}

suffix_js()
{
	suffix_java();
}

suffix_idl()
{
	c_mode();
	compile_buffer_cmd = compile_idl_cmd;	// can compile this
	c_extra_keywords = IDL_KEYWORDS;
}

suffix_cs()
{
	c_mode();
	compile_buffer_cmd = compile_csharp_cmd;	// can compile this
	c_extra_keywords = CSHARP_KEYWORDS;
}

suffix_xbm()
{
	c_mode();
	c_extra_keywords = 0;
}

// other file extensions are synonymous with the ones above
suffix_y()
{
	suffix_c();
}

suffix_cxx()
{
	suffix_cpp();
}

suffix_cc()
{
	suffix_cpp();
}

suffix_hxx()
{
	suffix_hpp();
}


/*  Look at the last two lines (or more sometimes) and return the
    correct indentation for the current line, assuming C source (or
    similar).  At start, we must be at the end of a line's indentation.
*/

c_compute_indent()
{
	int ind = 0;		/* indentation to use */
	int orig = point;
	int first_char = curchar(); /* cur line's first char */
	int pstart;		/* start position of prev line */
	int pafter;		/* after label on prev line */
	int pend;		/* end position of prev line */
	int prev_end = ';';	/* last char on previous line */
	int norm_narrow;	/* narrowing setting for most parsing */

	save_var point;
	if (setjmp(&c_indent_giveup))	/* if we hit end & gave up, */
		return ind;		/* use best guess so far */
	if (in_perl_buffer)
		return perl_compute_indent();
	norm_narrow = fix_narrowing(point - c_look_back);
	save_var narrow_start = norm_narrow;
	if (!reindent_c_comments && parse_string(1, "[ \t\f]*/<*>"))
		return get_indentation(point);
	if (!reindent_one_line_c_comments && parse_string(1, "[ \t\f]*//"))
		return get_indentation(point);
	if (first_char == '#' || first_char == '\f')
		return 0;
	else if (first_char == '}')
		return cind_close();

	to_begin_line();
	if (character(point - 2) == '\\')
		return indent_after_backslash();
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

	if (is_case(orig)) {
		ind = indent_case(orig);
	} else if (parse_string(1, "ON_")) {
		// Found MFC dispatch table, leave alone.
	} else if (have_label(orig)) {
		char type[FNAMELEN];		// Could it be a bitfield, not a label?
		find_c_func_info(type, NULL, NULL, 0);
		if (!strcmp(type, "struct") || !strcmp(type, "union"))	// Yes, a bitfield.
			ind += get_c_indent();
		else					// It's a label.
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
		if (!c_indent_after_extern_c
			  && parse_string(1, "[ \t]*extern[ \t]*\"C\"[ \t\n]*{"))
			return ind;
		if (!c_indent_after_namespace
			  && parse_string(1, "[ \t]*namespace</word>.*{"))
			return ind;
		if (ind <= c_top_braces	// special case if no previous indent
		    || get_column(pend - 1) <= c_top_braces) {
			ind += top_indent(prev_end) ? get_c_indent() : c_top_braces;
			if (just_open(orig))
				ind += c_brace_offset;
			if (ind < c_top_braces)
				ind = c_top_braces;
		} else if (have_struct_init(pend - 1)) {
			ind = indent_struct_init(pend - 1) + get_c_indent();
		} else if (Closeback || curchar() != '{')
			ind += get_c_indent();
		if (just_open(pafter))
			ind -= c_brace_offset;
	} else if (just_open(orig)) {
		if (have_struct_init(orig))
			return indent_struct_init(orig);
		else
			return indent_just_open(ind);
	} else if (in_c_initializer(orig)) {
		return ind;
	} else if (is_contin_statement(pend, 1, orig)) {
		return indent_c_contin(ind, orig, pend);
	} else if (!index(":);{}", c_line_before()) && !c_statement_start()
				&& !(Closeback && just_open(point)))
		return ind;
	else
		ind += get_c_indent();
	return ind;
}

cind_search(pat)	/* search back for pattern */
char *pat;		/* if we reach start of (examinable) buffer, give up */
{			/* call this only from c_compute_indent */
	int res = re_search(-1, pat);

	if (point == narrow_start)
		longjmp(&c_indent_giveup, 1);
	return res;
}

cind_space()		/* move back over any whitespace or comments */
{			/* give up if we hit start */
	if (cind_try_space())
		longjmp(&c_indent_giveup, 1);
}

cind_try_space()	/* move back over whitespace, comments, preproc */
{			/* lines, and return 0, or 1 if we hit start */
	if (in_perl_buffer) {
		for (;;) {
			if (index(" \t\n\f", character(point - 1)))
				point--;
			else if (parse_string(-1, "#.*")
					 && (in_perl_comment(matchend) & IN_COMMENT))
				point = matchend;
			else
				return point == narrow_start;
		}
	}
	for (;;) {
		if (index(" \t\n\f", character(point - 1)))
			point--;
		else if (cind_skip_new_comment() || cind_skip_preproc_line())
			;
		else if (character(point - 1) == '/'
					&& character(point - 2) == '*') {
			point -= 2;
			if (!search(-1, "/*") || point == narrow_start)
				return 1;
		} else
			return point == narrow_start;
	}
}

cind_skip_new_comment()	/* move before // comment on line */
{			/* return 1 if there was one */
	int old = point;

	save_var narrow_start = give_begin_line();
	while (search(-1, "//"))
		if (at_c_comment(point + 2, 0) == IN_NEW_COMMENT) {
			point -= parse_string(-1, "/+");
			return 1;
		}
	point = old;
	return 0;
}

cind_skip_preproc_line()	/* move back past any preproc line */
{				/* return 1 if there was one */
	int old = point;

	for (;;) {
		to_begin_line();
		if (character(point - 2) != '\\')
			break;
		point -= 2;	/* prev might be preproc contin line */
	}
	if (parse_string(1, "[ \t\f]*#"))
		return (point > narrow_start);
	point = old;
	return 0;
}

// Is orig inside an initializer?  It is if we're inside {}'s and just
// before is a comma or equal sign.
int in_c_initializer(int orig)
{
	save_var point = orig;
	c_rev_skip_level('{', '}');
	if (curchar() != '{')
		return 0;
	cind_try_space();
	if (!strchr("=,", character(point - 1)))
		return 0;
	return !c_skip_level('{', '}') || point >= orig;
}

c_line_before()		/* retrieve last character of prev line of c code */
{			/* (ignoring comments, blank lines, etc.) */
	save_var point;		/* assumes we're in this line's indentation */
	return cind_try_space() ? ';' : character(point - 1);
}

fix_narrowing(p)	// return p, limited by narrowing, and at line's start
{
	save_var point = p;
	to_begin_line();
	return point;
}

indent_after_backslash()	// assume we're at start of line
{				// after the one ending w/ backslash
	save_var narrow_end = size() - point;	// only look back
	do {				// find last line w/o backslash
		if (!nl_reverse())
			break;
	} while (character(point - 1) == '\\');
	if (!parse_string(1, "\n[ \t\f]*#define[ \t\f]+[a-z0-9_]+"))
		return 0;	// not a big #define, so use no indentation
	point = matchend;	// get past ident being defined
	if (curchar() == '(')	// maybe skip fwd past param list
		if (!c_skip_level('(', ')'))
			return 0;
	point += parse_string(1, "[ \t\f]+");	// indent with start of def
	return current_column();
}



/*  Look at the last two lines and guess at the correct indentation,
    assuming C source (or similar).  If we're not in this line's
    indentation, though, or our new indentation matches the old,
    just indent one more level.
*/

command do_c_indent() on c_tab['\t']
{
	int orig = point, ind = get_c_indent();
	int orig_column = current_column();

	if (maybe_indent_rigidly(0))
		return;
	to_indentation();
	if (!c_tab_always_indents && orig_column > current_column() || in_shell_buffer) {
					/* if not in indentation */
		point = orig;
		to_column(orig_column + tab_size - orig_column % tab_size);
	} else if (prev_cmd == C_INDENT)	/* repeated, make bigger */
		to_column(orig_column + ind);
	else {
		c_indenter();
		if (in_perl_buffer && !get_indentation(point) && !orig_column
			  && this_cmd != CMD_INDENT_REG)
			to_column(ind);	// 0 indent=>0 indent, but indent anyway
	}
	if (this_cmd != CMD_INDENT_REG)
		this_cmd = C_INDENT;
}

/*
Tell if more indent is required.
Assumes last line had no indent and point is at its start.
The hard case is distinguishing between these when Topindent is zero:

	foo();				foo();
}				}
func(bar)			if (bar)

When point is just after these examples, we must examine the word
at "func" to distinguish the left example (the end of a function and
beginning of the next, requiring no indentation) from the right (the
end of a block and start of a conditional, requiring indentation).
*/
top_indent(prev_end)
{
	if (Topindent)
		return (prev_end == '{');
	switch (prev_end) {
		case ';':
		case '}':	return 0;
		default:	return 1;
		case '{':	if (parse_string(1, "[ \t\f]*{")) {
					cind_try_space();
					to_indentation();
				}
		case ')':	break;
	}
	return c_statement_start();
}

/*
Tell if the last line begins a statement (rather than a function
declaration or the continuation of a previous statement).
Assumes point is at the start of the last line.
*/
c_statement_start()
{
	return parse_string(1, "[{} \t\f]*(if|else|while|do|for|switch|try|"
						"catch|finally)[^a-zA-Z0-9]");
}

just_open(p)
{
	save_var point = p;
	return parse_string(1, "[ \t\f]*{[ \t\f]*($|//|/<*>)");
}

move_before_labels()
{
	int p;

	while ((p = parse_string(-1, "^[ \t\f]*![a-zA-Z0-9_]+[ \t\f]*:"))
		   && !is_case(point - p)) {
		to_begin_line();
		cind_space();			/* skip whitespace and comments */
	}
}

is_label(p)	/* does line at p contain only case: or label? */
{
	save_var point = p;
	while (parse_label())	/* go past any labels */
		point = matchend;
	return parse_string(1, "[ \t\f]*\n|/<*>|//");
}

is_case(p)	/* is there a case-like statement at position p? */
{
	if (!index("cdp", character(p)))
		return 0;
	save_var point = p;
	return parse_string(1, "(case|default|public|private|protected)"
			    "[^a-zA-Z0-9_]");
}

indent_case(orig)	// indent case-like statement at orig
{
	point = orig;
	for (;;) {		// look for case-like statement, or {}'s
		cind_search("([^a-zA-Z0-9_]!(case|default|public|"
					"private|protected)[^a-zA-Z0-9_])|[{}]");
		if (in_c_comment(c_look_back))
			continue;
		else if (curchar() != '}')
			break;
		point++;
		if (!c_rev_skip_level('{', '}')) // move before matching {
			longjmp(&c_indent_giveup, 1);
	}
	if (curchar() != '{')	// copy indentation from prior case
		return get_indentation(point);

	cind_space();	// skip over switch-like construct before {
	if (character(point - 1) == ')') // back past () of switch
		if (!c_rev_skip_level('(', ')'))
			longjmp(&c_indent_giveup, 1);
	to_indentation();
	past_labels();	// might be "case 3: switch ()", get to switch
	point += parse_string(1, "[ \t\f]*");
	return current_column() + get_c_indent() + c_case_offset;
}

is_switch(p)	/* is there a switch-like statement at position p? */
{
	if (!index("scu", character(p)))
		return 0;
	save_var point = p;
	return parse_string(1, "(switch|struct|union|class|namespace)[^a-zA-Z0-9_]");
}

is_else(p)	/* is there an else keyword at position p? */
{
	if (character(p) != 'e')
		return 0;
	save_var point = p;
	return parse_string(1, "else[^a-zA-Z0-9_]");
}

// Are we after a bunch of single-line comments?  If so, decide that
// the most likely next line is another comment.

after_many_comments()
{
	char pat[FNAMELEN];
	int cnt = 0;

	if (comment_repeat_indentation_lines < 0)
		return 0;
	save_var point;
	sprintf(pat, "[ \t]*%s", comment_start);
	while (nl_reverse()) {
		to_begin_line();
		if (!parse_string(1, pat))
			break;
		if (++cnt >= comment_repeat_indentation_lines)
			return 1;
	}
	return 0;
}

// Go back to the last /* sequence and see if point lies between
// there and the closing */.

c_in_old_comment()
{
	int p = point, inside = 0;

	save_var point, narrow_end = size() - p;
	if (!search(-1, "/*"))
		return 0;
	while (point < p && re_search(RE_FORWARD | RE_FASTEST, "/<*>|<*>/"))
		inside = (character(point - 1) == '*');		 // Found /*.
	return inside;
}

// Is point in a comment (C++ style or block) or a string or character
// constant?  Return codes for each, or 0.
// To completely correctly determine if we're in a block comment, we
// need to go back in the file until we find a /* or a */.  Sometimes
// we find one that doesn't count because it's quoted.

in_c_comment(lookback)		// is point inside a c comment, string, etc?
{
	int i = -1, orig = point;

	if (in_perl_buffer)
		return in_perl_comment(point);
	if (lookback) {			// If !lookback, check only this line.
		save_var narrow_start = point - lookback;
		save_var point;
		for (; re_search(RE_REVERSE | RE_FASTEST, "/<*>|<*>/"); point++) {
			i = scan_for_string();	// Parse just this line.  A string?
			if (curchar() == '/' && character(point - 1) == '/')
				continue;		// Found //*, so no block comment.
			if (!i || i == IN_OLD_COMMENT)
				break;		// The delimiter wasn't quoted.
			if (curchar() == '*' && c_in_old_comment()) {
				save_var narrow_start = point;
				break;	// Found */ sequence, ends a comment?
			}	// If it looks like it was quoted, double-check.
		}
		if (i != -1 && curchar() == '/' && character(point + 1) == '*')
			return IN_OLD_COMMENT;	// Found /* sequence.
	}
	point = orig;	// Not in a block comment, so use a local check.
	return scan_for_string();
}

scan_for_string()	// check current line to see if we're in
{			// string or new-style comment
	int c;

	save_var point;
	save_var narrow_end = size() - point;
	to_begin_line();		// scan this line before point
	while (parse_string(-1, ".*\\\n"))
		point = matchend;	// Go back past this continuation line.
	while (re_search(1, "<squote|dquote>|//|/<*>")) {
		point = matchstart;
		c = curchar();
		if (c == '/' && character(point + 1) == '/')  // found "//"
			return IN_NEW_COMMENT;
		else if (!c_skip_item(c, RE_FORWARD))
			return c == '/' ? IN_OLD_COMMENT
							: c == '"' ? IN_STR_CONST : IN_CHAR_CONST;
	}
	return 0;
}

at_c_comment(pos, lookback)
{
	save_var point = pos;
	return in_c_comment(lookback);
}

indent_c_comment()		/* indenter when inside a comment */
{
	int prev_indent;
	int orig, has_star, no_star = 0;

	has_star = parse_string(1, "[ \t\f]*<*>");
	orig = point;
	re_search(-1, "[^ \t\f\n]");	/* find previous non-blank line */
	to_indentation();
	if (has_star && parse_string(1, "[/ \t\f]*<*>"))
		point = matchend - 1;	// line up star under prev star
	else
		no_star = 1;
	prev_indent = current_column();
	point = orig;
	if (no_star && parse_string(1, "<*>/"))
		prev_indent = 0;
	to_column(prev_indent);		/* indentation as previous */
}

int have_struct_init(int orig)
{
	save_var point = orig;
	cind_space();
	return parse_string(-1, "^[ \t\n]*}[ \t\n]*,");
}

indent_struct_init(int orig)
{
	save_var point = orig;
	cind_space();
	point -= parse_string(-1, "}[ \t\n]*,");
	return current_column();
}

int indent_just_open(ind)		// Indent a line with just { on it.
{
	int extra = 0;

	if (!Topindent && !ind && c_statement_start())
		extra = get_c_indent();
	if (ind && !Closeback)
		extra = get_c_indent();
	return ind + c_brace_offset + extra;
}

/* We are at the beginning of a statement, which may be part of a larger
 * statement because it has "if ()" or similar before it.  Find the
 * biggest statement that the current line could be the tail end of,
 * and return its indentation.  We assume the statement starts at the
 * beginning of a line. */

indent_after_statement(orig) // orig is place needing indentation, for toplevel
{
	int lastcont, i, c, atparen = -1;

	for (;;) { /* was only the end of a larger statement, find start */
		do {	/* look back for line that ends with ;{}: */
			lastcont = point;
			to_begin_line();
			if (cind_try_space())
				break;
			if ((c = character(point - 1)) == ')') {
				atparen = lastcont;
				if (!c_rev_skip_level('(', ')'))
					break;
				to_begin_line();
			}
		} while (!index(";{}:", c));
		point = lastcont;	/* use indentation of line */
		to_c_indentation();	/* just after it */
		if (parse_string(RE_FORWARD, "(}[ \t\f]*)?e!lse[^a-zA-Z0-9_]")) {
			point = matchend;
			if (!to_matching_if())
				break;
		} else if (parse_string(RE_FORWARD,
								"(}[ \t\f]*)?!(catch|finally)[^a-zA-Z0-9_]")) {
				point = matchend;
				if (!to_matching_try())
					break;
			} else
			break;
	}
	i = current_column();
	if (!i && atparen != -1 && (Topindent || !c_statement_start()))
		i = get_indentation(atparen);	// 2nd func param decl
	if ((atparen = parse_string(1, "for[ \t\f]*%([ \t\f]*"))
	    && for_unclosed(point, orig))
		i = get_column(point + atparen); // part of "for" statement
	if (i <= c_top_braces)
		return 0;	// 1st line of new func
	return i;
}

for_unclosed(start, end)	// does this region have unmatched )?
{
	save_var point = start;
	save_var narrow_end = size() - end;
	return !c_skip_level('(', ')');
}

/* Return new indentation, when the previous line ended with a } character.
 * We are now just after the } character. */

indent_after_block(orig)
{
	int ind;

	c_rev_skip_level('{', '}');	/* find matching { */
	to_begin_line();
	ind = get_indentation(point);
	if (Topindent && (ind == 0 || parse_string(1, "[ \t]*{")
					  && ind <= c_brace_offset))
		return 0;	// found a func def block
	return indent_after_statement(orig);
}

func_start_block(p)	// are these lines arg decls of func, not statements?
{
	int c;

	save_var point = p;
	for (;;) {
		if (cind_try_space())
			return 0;
		if ((c = character(point - 1)) != ';')
			break;
		to_begin_line();
	}
	if (c != ')' || !c_rev_skip_level('(', ')') || cind_try_space()
		|| !parse_string(-1, "[_A-Z0-9]"))
		return 0;
	to_begin_line();
	return !c_statement_start();
}

indent_c_contin(ind, orig, lastl)	/* indent continuation line */
{
	int c, plevel = 0, qlevel = 0, findc;

	if (!c_align_contin_lines)	// never line up
		return c_default_indent(ind, orig, 1);
	to_begin_line();
	save_var narrow_start = point;
	point = orig;
	findc = character(orig);
	while (re_search(-1, "[()?:\"'\n]|[=!<>]?=")) {
		switch (c = curchar()) {
			case '(':	/* indent after unmatched lparen */
				if (plevel-- > 0)
					break;
indhere:		if (findc != ')')
					point++;
				if (!parse_string(1, "[ \t\f]*/[*/]"))
					point += parse_string(1, "[ \t\f]*![^ \t\f\n]");
				return limit_c_contin_indent(ind);
			case ')':
				plevel++;
				break;
			case '?':	/* indent : to matching ? */
				if (qlevel-- > 0 || plevel > 0 || findc != ':')
					break;
				point--;
				goto indhere;
			case ':':
				qlevel++;
				break;
			case '=': case '!':
				if (character(point + 1) == '=' || plevel > 0
				    || character(lastl - 1) == ',')
					break;
				goto indhere;
			case '\n':		 // skip over comments
				cind_try_space(); // at ends of lines
				break;
			case '"': case '\'':
				point++;
				c_skip_item(c, RE_REVERSE);
				break;
		}
	}
	if (character(lastl - 1) == ',') {
		if (character(lastl - 2) != ')') {
			point = lastl;
			to_begin_line();
		}
		point += parse_string(1, "(.*[ \t\f]on)?[ \t\f]+");
		if (in_c_comment(c_look_back))
			to_indentation();
		return limit_c_contin_indent(ind);
	}
	return c_default_indent(ind, orig, 2);
}

c_default_indent(ind, orig, defmult)
{
	if (ind)
		return ind + defmult * get_c_indent() + c_contin_offset;
	if (parse_string(1, "[ \t\f]*(struct|union|class|namespace)[ \t\f\n]+"
			 "[a-zA-Z0-9_]*[ \t\f\n]*{[ \t\f\n]*[\n/]"))
		return ind + c_top_struct;
	if (just_open(orig))
		return c_top_braces;
	point = orig;
	cind_space();
	return is_contin_statement(point, 0, orig)
			? c_top_contin : c_param_decl;
}

limit_c_contin_indent(ind)	// if lining up under something would put us
{				// too far to right, just use std indent
	int std, i = current_column();	// get lining-up indent

	if (i > c_align_contin_lines) {
		std = ind + get_c_indent() + c_contin_offset;
		i = MIN(std, i);
	} else if (i == ind + get_c_indent())	// The same as a plain indent
		i += c_align_extra_space;			// so fiddle with it slightly.
	return i;
}

indent_else(def)	/* indent a line that starts with "else" */
{			/* by finding matching "if" */
	if (!to_matching_if())
		return def;
	to_c_indentation();
	return current_column();
}

to_matching_try()	/* go to matching try statement, assuming we're */
{			/* just before a catch or finally keyword */
	int extra_elses = 0;	/* ret 0 if couldn't find it, 1 if ok */

	while (cind_search("<min>(([^#a-zA-Z0-9]|^)(try|catch|finally)[^a-zA-Z0-9]|})")) {
		if (!in_c_comment(c_look_back) && !parse_string(-1, "[ \t]*#[ \t]*")) {
			if (curchar() == '}') {
				point++;	/* find matching { */
				c_rev_skip_level('{', '}');
			} else if (character(point + 1) == 'e')
				extra_elses++;
			else if (--extra_elses < 0)
				return 1;
		}
	}
	return 0;
}

to_matching_if()	/* go to matching if statement, assuming we're */
{			/* just before an else keyword */
	int extra_elses = 0;	/* ret 0 if couldn't find it, 1 if ok */

	while (cind_search("<min>(([^#a-zA-Z0-9]|^)(else|if)[^a-zA-Z0-9]|})")) {
		if (!in_c_comment(c_look_back) && !parse_string(-1, "[ \t]*#[ \t]*")) {
			if (curchar() == '}') {
				point++;	/* find matching { */
				c_rev_skip_level('{', '}');
			} else if (character(point + 1) == 'e')
				extra_elses++;
			else if (--extra_elses < 0)
				return 1;
		}
	}
	return 0;
}

parse_label()	/* parse for a case:, default: or label construct at point */
{		/* return nonzero if found, setting matchend to end */
	return have_colon() && parse_string(1,
		"(case[^a-zA-Z0-9_\n]([^:\n]*|.*(':'|::).*)"
		"|[a-zA-Z0-9_]+[ \t\f]*):[ \t\f]*![^:]");
}

have_colon()		/* is there a colon later on this line? */
{
	save_var narrow_end = size() - give_end_line();
	save_var point;
	return search(1, ":");
}

have_label(pt)	/* is there a label here? */
{
	save_var point = pt;
	return have_colon() && parse_string(1,"[a-zA-Z0-9_]+[ \t\f]*:[^:]");
}

to_c_indentation()	/* go to end of indentation, ignoring any */
{			/* case : or label-like constructs */
	to_indentation();
	past_labels();
}

past_labels()	/* move past labels or case statements at point */
{
	while (parse_label() && character(matchend) != '\n')
		point = matchend;
}

/* If this line appears to be a continuation line, back up until we find
 * one that doesn't.  (We assume it's a continuation line if the previous
 * line doesn't end with one of the five characters ; { } ) : or a
 * keyword like "else".)  Then go to end of indentation.
*/

to_statement_start()
{
	int lastcont, count = 100;	/* give up after this many lines */
	int orig = point;

	to_begin_line();
	if (parse_string(1, "[ \t\f]*}")) {
		search(1, "}");
		c_rev_skip_level('{', '}');
	}
	do {
		to_begin_line();
		lastcont = point;
		if (parse_string(1, "[ \t\f]*},")) {	// initializer
			search(1, "}");
			c_rev_skip_level('{', '}');
		}
	} while (!cind_try_space() && is_contin_statement(point, 0, orig)
			&& count-- > 0);
	point = lastcont;
	to_indentation();
}

unmatched_rparen(from, to)	// is there an unmatched ")" in range?
{
	save_var narrow_start = from;
	save_var point = to;
	do {
		if (!search(-1, ")"))
			return 0;	// find last ")" in range
	} while (in_c_comment(c_look_back));
	point++;		// return 1 if unmatched
	return !c_rev_skip_level('(', ')');
}

is_contin_statement(p, fd, orig) // would line after p be a continuation line?
{			// assumes p is just after last interesting char
	// if fd, pretend func param decls are a "continuation" of func decl
	// orig is later position in buffer, for unclosed "for" scan
	switch (character(p - 1)) {
		case ';':		// check for multi-line "for" statemnt
			if (unmatched_rparen(p, orig))
				return 1;
		case '{':
		case '}':
			return 0;
		case ')':
			save_var point = p;
			save_var narrow_start = p - 500;
			if (!c_rev_skip_level('(', ')'))
				return 1;
			return !parse_string(-1, "[^a-z0-9_](if|while|for"
					     "|switch)[ \t\f]*") && (fd
				|| !Topindent || get_indentation(point)) || in_perl_buffer;
		case 'e':
			return !is_else(p - 4);
		case 'o':
			save_var point = p;
			return !parse_string(-1, "[^a-z0-9_]do");
		case ':':
			save_var point = p;
			to_indentation();
			return !is_label(point);
		default:
			return 1;
	}
}

when_setting_new_c_comments()	// Auto-run when user sets this variable.
{								// Also runs when entering c-mode.
	if (new_c_comments) {
		strcpy(comment_begin, "// ");
		strcpy(comment_end, "");
	} else {
		strcpy(comment_begin, "/* ");
		strcpy(comment_end, " */");
	}
}

cind_close()	/* indent a line that starts with a } character */
{		/* find matching { and indent based on that one */
	int ind, solitary;

	point++;		/* go past } char */
	c_rev_skip_level('{', '}');	/* find matching { */
	solitary = parse_string(-1, "\n[ \t\f]*");	/* stuff before? */
	if (solitary)
		to_indentation();
	else
		to_statement_start();
	past_labels();
	ind = current_column();
	if (!Closeback && !solitary)
		ind += get_c_indent() + c_brace_offset;
	return ind;
}

	/* dquote "(" snormal OR bslash anything ")" STAR dquote */
#define C_STRING "\"([^\"\\\n]|\\(.|\n))*\""

	/* squote "(" cnormal OR bslash anything ")" STAR squote */
#define C_CCONST "'([^'\\\n]|\\(.|\n))*'"

/* Skip past a string, character-constant, or comment,
   depending on "item".
*/

c_skip_item(item, flags)
{
	char *s; int m;

	switch (item) {
		case '/':	m = (flags & RE_REVERSE) ? -1 : 1;
				return search(m, (m < 0) ? "*/" : "/*")
					&& search(m, (m < 0) ? "/*" : "*/");
		case '"':	s = C_STRING; break;
		case '\'':	s = C_CCONST; break;
	}
	return re_search(flags, s);
}

/* look backward for a matching pair of delimiters, ignoring
 * delimiters inside strings, character constants, or comments
 */

int c_rev_skip_level(left_d, right_d)
char left_d, right_d;
{
	char pattern[40], ch;
	int level = 0;

	if (in_perl_buffer)
		return perl_skip_level(-1, left_d, right_d);
	sprintf(pattern, "<*>/|[%c%c'\"]|//.*\n", right_d, left_d);

bgn:	do {
		if (!re_search(RE_REVERSE, pattern))
			return 0;
		switch (ch = curchar()) {
			case '/':
				if (at_c_comment(point + 2, 100) & IN_STRING)
					to_end_line();
				break;
			case '\'': case '"': case '*':
				point = matchstart;
				c_skip_item(character(point - 1), RE_REVERSE);
				goto bgn;
			default:
				if (ch == right_d)
					level++;
				else if (ch == left_d)
					level--;
		}
	} while (level > 0);
	return 1;
}

/* look forward for a matching pair of delimiters, ignoring
 * delimiters inside strings, character constants, or comments
 */

int c_skip_level(left_d, right_d)
char left_d, right_d;
{
	char pattern[40], ch;
	int level = 0;

	if (in_perl_buffer)
		return perl_skip_level(1, left_d, right_d);
	sprintf(pattern, "/[/*]|[%c%c'\"]", right_d, left_d);

bgn:	do {
		if (!re_search(RE_FORWARD, pattern))
			return 0;
		switch (ch = character(matchstart)) {
			case '/':
				search(1, character(matchstart + 1) == '/'
				       ? "\n" : "*/");
				break;
			case '\'': case '"':
				point = matchstart;
				c_skip_item(ch, RE_FORWARD);
				goto bgn;
			default:
				if (ch == right_d)
					level++;
				else if (ch == left_d)
					level--;
		}
	} while (level < 0);
	return 1;
}

// Try to scroll the window so the entire scope of this directive
// is visible.

position_on_ifdef()
{
	to_begin_line();
	if (point < window_start || point > window_end) {
		int line = text_height() - show_tag_line;
		if (parse_string(1, PREPROC_IF))
			line = show_tag_line;
		else if (parse_string(1, PREPROC_ELSE))
			line /= 2;
		window_start = prev_screen_line(line);
	}
}

// Move forward or backward stopping at #if, #else, or #endif (or similar)
// but skipping over inner nested preprocessor lines.

move_by_ifdef(dir)
{
	int level = 0;

	to_begin_line();
	if (!parse_string(1, PREPROC_LINE) ||
		parse_string(1, (dir > 0) ? PREPROC_ENDIF : PREPROC_IF)) {

// If we're not starting from a preprocessor line, or we're moving out of
// the scope of the current line's directive, just move to the next.

		if (dir > 0)
			to_end_line();
		re_search(dir, PREPROC_LINE);
		position_on_ifdef();
		return;
	}
	if (dir > 0)
		to_end_line();
	for (;;) {		// Look for a preprocessor line at the right level.
		if (!re_search(dir, PREPROC_LINE))
			error("Unmatched preprocessor line.");
		if (parse_string(-dir, PREPROC_IF)) {
			if ((dir > 0) ? (++level <= 0) : (++level > 0))
				break;
		} else if (parse_string(-dir, PREPROC_ENDIF)) {
			if ((dir > 0) ? (--level < 0) : (--level >= 0))
				break;
		} else if (parse_string(-dir, PREPROC_ELSE)) {
			if ((dir > 0) ? (level <= 0) : (level >= 0))
				break;
		}
	}
	position_on_ifdef();
}

command forward_ifdef() on c_tab[ALT(']')], c_tab[NUMALT(KEYDOWN)],
						   c_tab[NUMALT(NUMDIGIT(2))]
{
	to_begin_line();
	if (in_c_comment(c_look_back * 2))
		forward_paragraph();
	else
		move_by_ifdef(1);
}

command backward_ifdef() on c_tab[ALT('[')], c_tab[NUMALT(KEYUP)],
							c_tab[NUMALT(NUMDIGIT(8))]
{
	to_begin_line();
	if (in_c_comment(c_look_back * 2))
		backward_paragraph();
	else
		move_by_ifdef(-1);
}

// Lists preprocessor conditionals for this buffer.  It assumes they
// work basically the same as the C preprocessor, but may use different
// syntax.  It requires regex patterns that match:
// 1. Any preprocessor conditional line (if, end, else, else if).
// 2. An "if" line only.
// 3. An "end" line only.
// It assumes that any line that matches 1 but not 2 or 3 is an
// "else"/"else if" of some kind.

do_list_preprocessor_conditionals(char *line, char *if_line, char *end_line, char *msg)
{
	int b = zap("-list-preprocessor-conditionals"), level = 0;

	iter = 0;
	save_var point = give_begin_line();
	while (re_search(-1, line)) {
		if (parse_string(1, end_line))
			level--;
		else if (!level) {
			buf_xfer(b, give_begin_line(), give_end_line() + 1);
			set_buf_point(b, 0);
		} else if (parse_string(1, if_line))
			level++;
	}
	restore_vars();
	save_var _view_title = "Preprocessor conditionals";
	if (buffer_size("-list-preprocessor-conditionals"))
		view_buffer("-list-preprocessor-conditionals", 1);
	else
		say("Not in any %s conditional.", msg);
}


command list_preprocessor_conditionals() on c_tab[ALT('i')]
{
	do_list_preprocessor_conditionals(PREPROC_LINE, PREPROC_IF,
									  PREPROC_ENDIF, "#if");
}

// Search on line for link, set file to its name.
// Abort if none.
c_find_linked_file(char *file)
{
	char rel[FNAMELEN], curdir[FNAMELEN], tmp[FNAMELEN], *p, *classpath, *include;
	int flags = PATH_ADD_CUR_DIR, is_abs = 0;

	to_begin_line();
	if (parse_string(1, "[ \t]*#[ \t]*include[ \t]*[<\"](.*)([>\"])"
					 "[ \t]*(/[*/].*)?$")) {
		grab(find_group(1, 1), find_group(1, 0), rel);
		is_abs = character(find_group(2, 1)) == '>'
				 && !find_linked_file_ignores_angles;
		// Using #include "" or <> syntax?
	} else if (is_java_buffer() &&  parse_string(1, "[ \t]*(package|import)"
		"[ \t]*(<word>+(%.<word>+)*(%.%*)?)[ \t]*;")) {
		grab(find_group(2, 1), find_group(2, 0), rel);
		while (p = strchr(rel, '.'))	// Transform java.lang to 
			*p = path_sep;				// java/lang filename.
		p = rel + strlen(rel) - 1;
		if (*p == '*') {
			strcpy(p, ".");
			flags |= PATH_PERMIT_DIRS;
		} else
			strcat(p, ".java");
	} else
		error("Can't find any link here.");
	strcpy(file, rel);
	get_buffer_directory(curdir);
	if (is_abs)				// Don't look for relative names at all.
		flags = 0;
	else {
		absolute(file, curdir);
		if (check_file(file))
			return;
	}
	flags |= PATH_PERMIT_WILDCARDS;
	include = getenv("INCLUDE");
	classpath = getenv("CLASSPATH");
	p = 0;
	if (!p && !strcmp(get_extension(filename), ".e")) {
		sprintf(tmp, "include%c%s", path_sep, rel);
		p = lookpath(tmp, 0);
	}
	if (!p && is_java_buffer() && classpath)
		p = look_on_path(rel, flags, classpath);
	if (!p && include)
		p = look_on_path(rel, flags, include);
	if (!p && *include_directories)
		p = look_on_path(rel, flags, include_directories);
	if (!p)
		p = look_on_path(rel, flags, (opsys == OS_UNIX)
						 ? INCL_PATH_UNIX : INCL_PATH_WIN);
	if (!p)
		error("%s not found in include-directories path", rel);
	strcpy(file, p);
}

fix_c_indentation()		/* recompute this line's indentation */
{				/* without moving point */
	if (in_shell_buffer)
		return;
	save_spot point;
	to_indentation();
	c_indenter();
}


/*  fix indentation if necessary when { is typed */
command c_open() on c_tab['{']
{
	normal_character();
	if (current_column() - 1 <= get_indentation(point)
			&& !in_c_comment(c_look_back))
		fix_c_indentation();
}

/*  fix indentation if necessary when } or ) is typed */
command c_close() on c_tab['}'], c_tab[')'], c_tab[']']
{		/* only if typed inside indentation, & it might need fixup */
	normal_character();
	if (current_column() - 1 <= get_indentation(point)
			&& !in_c_comment(c_look_back))
		fix_c_indentation();
	save_var inside_show_matching_delimiter = 1;
	if (Matchdelim)
		find_delimiter();
}

/*  fix indentation if necessary when : is typed */
command c_colon() on c_tab[':']
{
	normal_character();
	if (parse_string(-1, "^[ \t\f]*(case[^a-zA-Z0-9_\n][^:\n]*"
				"|[a-zA-Z0-9_]+[ \t\f]*:?):")
			&& !in_c_comment(c_look_back))
		fix_c_indentation();
}

/*  fix indentation if necessary when # is typed */
command c_hash_mark() on c_tab['#']
{
	normal_character();
	if (parse_string(-1, "^[ \t\f]*#"))
		fix_c_indentation();
}

get_c_indent()	/* indent this many spaces for each level */
{			/* if c_indent is 0, use tab_size instead */
	return (c_indent > 0) ? c_indent : tab_size;
}

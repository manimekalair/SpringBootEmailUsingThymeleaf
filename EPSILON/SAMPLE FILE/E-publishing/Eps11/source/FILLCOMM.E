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

#include "eel.h"
#include "c.h"
#include "kill.h"
#include "colcode.h"

// Fill block comments in C-like languages and others.

/* We use the notion of a prefix to fill comments.  A prefix is
 * anything on a line before the first alphanumeric character.  First
 * we locate the paragraph to be filled.  Lines containing only a
 * prefix separate paragraphs.
 *
 * Then we go through the paragraph and adjust our notion of "prefix"
 * a bit.  We find the width of the prefix (as above) on each line of
 * the paragraph.  If one line has an extra-wide prefix, we want to
 * ignore the excess characters.  So we find the minimum prefix
 * width, then restrict our prefixes to that in the rest.
 *
 * Next we extract the prefix text of each line and save it in a temp
 * buffer.  Then we fill the original paragraph.  Then we move the
 * prefix text back to the original buffer, line by line.  If there
 * are more lines than before, we duplicate the prefix of the last
 * line.  If there was only one line to begin with, but more now, we
 * use a default prefix.
 *
 * We try to work with languages that use one-line comments but a
 * delimiter other than //, such as # in Perl, but we assume it doesn't
 * use any funny regex characters like * or -.
 * 
 */

#define C_COMMENT_FILLER		"[^0-9a-zA-Z\x80-\xFF_(\n]*"
#define C_COMMENT_PREFIX		"^" C_COMMENT_FILLER

// Replace all characters==old with character new in string p. 
replace_in_string(char *p, int old, int new)
{
	while (p = strchr(p, old))
		*p = new;
}

command fill_comment() on c_tab[ALT('q')]
{
	int pbuf, width = 1000, i, old_lines, new_lines, orig_lines;
	int col, col2, orig = bufnum, type, generic = strcmp(major_mode, "C");
	char last_prefix[FNAMELEN], orig_prefix[FNAMELEN], pat[FNAMELEN], comm[30];

	iter = 0;
	if (has_arg)
		save_var margin_right = current_column() + 1;
	save_spot point;
	type = locate_c_comment();	// 1 if block comment, 2 if one-line
	if (!type)					// comment, or 0 if not a comment.
		error("Can't fill comment here, not in a comment.");
	point += parse_string(1, C_COMMENT_FILLER);	// Past 1st line's prefix.
	sprintf(pat, "[ \t]*%s[^0-9a-z_\n]*", generic ? comment_start : "/[*/]");
	grab(point, point - parse_string(-1, pat), orig_prefix);
	save_var narrow_start = point;		// Narrow to the paragraph.
	point = mark;
	if (!generic)
		point -= parse_string(-1, "<*>/");
	save_var narrow_end = size() - point + 1;

	if (type == 1 && !generic)		// Combine adjacent block comments.
		simple_re_replace(1, "[ \t]*<*>/[ \t]*\n?[ \t]*/<*>[ \t]*", " ");
	point = 0;
	while (nl_forward()) {	// Find width of narrowest prefix.
		i = parse_string(1, C_COMMENT_PREFIX);
		col = get_column(point + i);
		width = MIN(width, col);
	}
	pbuf = tmp_buf();
	point = 0;
	strcpy(comm, generic ? comment_begin : "//");
	while (strlen(comm) > 0 && comm[strlen(comm) - 1] == ' ')
		comm[strlen(comm) - 1] = 0;	// Remove trailing spaces.
	sprintf(pat, "[ \t]*%s", comm);
	while (nl_forward()) {	// Move each prefix to our temp buffer.
		i = parse_string(1, C_COMMENT_PREFIX);
		col = get_column(point + i);
		if (col > width)	// Make sure it's not too wide.
			col = width;
		if (type == 2) {	// But if it's made of one-line comments,
			i = parse_string(1, pat);
			col2 = get_column(point + i);
			if (col < col2)		// each prefix must include a "//".
				col = col2;
		}
		i = column_to_pos(col);
		buf_xfer(pbuf, point - 1, i);
		delete(point, i);
	}
	if (width == 1000)	// No prefix, so use default.
		width = 3;
	orig_lines = old_lines = lines_between(0, size(), 0) + 1;
	region_fill_first_line(narrow_start, size() - narrow_end,
						   MAX(margin_right, 20),
						   MAX(margin_right - width, 20));
	new_lines = lines_between(0, size(), 0) + 1;
	point = 0;
	bufnum = pbuf;
	point = 0;
	*last_prefix = 0;	// Now copy the prefixes back.
	for (; new_lines > 0 && old_lines > 0; old_lines--, new_lines--) {
		grab(point, give_end_line(), last_prefix);
		buf_xfer(orig, point, give_end_line());
		nl_forward();
		bufnum = orig;
		nl_forward();
		bufnum = pbuf;
	}
	if (orig_lines < 2) {		// Default for new lines if 1 line originally.
		strcpy(last_prefix, orig_prefix);
		if (type == 2 && !strstr(last_prefix, comm))
			sprintf(last_prefix, "%s ", comm);
		else if (type == 1 && !generic)
			if (!strstr(last_prefix, "/*"))
				strcpy(last_prefix, " * ");
			else {
				replace_in_string(last_prefix, '/', ' ');
				if (fill_c_comment_plain)
					replace_in_string(last_prefix, '*', ' ');
			}
	}
	bufnum = orig;
	for (; new_lines > 0; new_lines--) {	// More lines than before.
		stuff(last_prefix);			// Add some prefixes.
		nl_forward();
	}
	buf_delete(pbuf);
	if (display_column > 0)
		display_column = 0;
	fix_window_start();	/* win shouldn't start in middle of line */
}

command mark_c_paragraph() on c_tab[ALT('h')]
{
	if (!locate_c_comment())		// Maybe mark current function.
		error("No paragraph comment here.");
	highlight_on();
	shift_selecting = 2;
}

// Set point & mark before & after the paragraph in this comment, return
// 1 if it's block comment or 2 if it's a one-line C++ style comment.
// Or return 0 if not in a comment.

int locate_c_comment()
{
	int com, type = 1, generic = strcmp(major_mode, "C");

	save_spot narrow_start, narrow_end;
	com = in_c_comment(c_look_back);	// Comment?  If so, what type?
	if (com == IN_OLD_COMMENT || !com && !generic && parse_string(1, "[ \t]*/<*>"))
		narrow_to_block_comment();
	else if (narrow_to_new_comment())
		type = 2;
	else
		return 0;
	to_begin_line();
	if (parse_string(1, C_COMMENT_PREFIX "$"))
		point--;		// If on line right after a parag, go back.
	to_begin_line();
	if (parse_string(1, C_COMMENT_PREFIX "$")) // If no text on line,
		if (!re_search(-1, "[^ \t\n]"))	// Find a line with text.
			re_search(1, "[^ \t\n]");

	re_search(1, C_COMMENT_PREFIX "$");	// Find "blank" line w/only filler.
	if (parse_string(-1, C_COMMENT_PREFIX "$"))
		to_begin_line();	// And move to its start.
	re_search(-1, "[^ \t\n]");	// Find text of some parag before it.
	nl_forward();
	mark = point;
	point--;
	re_search(-1, C_COMMENT_PREFIX "$");	// Find "blank" line before.
	if (parse_string(1, C_COMMENT_PREFIX "\n"))
		nl_forward();
	return type;
}

// Assuming we're in (or just before) a C block comment, narrow to it.
// Consider block comments with only a newline between them as one.

narrow_to_block_comment()
{
	save_var point;
	do {
		search(1, "*/");
	} while (parse_string(1, "[ \t]*\n?[ \t]*/<*>"));
	narrow_end = size() - point;
	do {
		search(-1, "/*");
	} while (parse_string(-1, "<*>/[ \t]*\n?[ \t]*"));
	narrow_start = point;
}

// Narrow to a block of adjacent lines that that start with one-line
// C++ comments like the one we assume we're starting in.  If this one
// doesn't start with such a comment, return 0, else 1.  We attempt to
// handle non-C++ one-line comments too.

int narrow_to_new_comment()
{
	char pat[50];

	if (strcmp(major_mode, "C"))
		sprintf(pat, "[ \t]*%s", comment_start);
	else
		strcpy(pat, "[ \t]*//");
	save_var point;
	to_begin_line();
	if (!parse_string(1, pat)) {
		narrow_start = point;	// This line doesn't start with one.
		restore_vars();
		to_end_line();
		if (!re_search(-1, pat))
			return 0;		// Can't find comment start.
		narrow_start = point;
	}
	while (nl_forward())		// Find the last such line.
		if (!parse_string(1, pat))
			break;
	narrow_end = size() - point;
	do {						// Find the first such line.
		point--;
		to_begin_line();
		if (!parse_string(1, pat)) {
			nl_forward();
			break;
		}
	} while (point > narrow_start);
	narrow_start = point;
	return 1;
}

// Break the line here, and arrange the result appropriately for various cases.

c_break_line_here(int comm, int starts_with_comm, int starts_in_comm,
				  int comm_start, spot next_ends, spot after, char *fill)
{
	int offset, generic = strcmp(major_mode, "C");
	char rest[FNAMELEN], *new_comm;

	delete_horizontal_space();
	insert('\n');
	if (display_column > 0)	// Horizontally scroll back to left margin.
		display_column = 0;
	if (key == '\n')	// User might be trying to break line elsewhere as
		key = ' ';		// we're breaking it here.  Prevent a mess.

	if (comm == IN_NEW_COMMENT) {		// A //-style C++ comment.
		new_comm = generic ? comment_begin : "// ";
		if (starts_with_comm)	// This line began with a comment, so just
			stuff(fill);		// repeat its prefix (indentation and such).
		else if (next_ends && get_column(comm_start) > get_column(*next_ends)) {
			grab(point, give_end_line(), rest);	// Continue it on the next line
			offset = give_end_line() - *after;	// since there's no comment
			delete(point - 1, give_end_line());	// there.
			point = *next_ends;
			to_column(get_column(comm_start) - 2);
			bprintf("%s%s%s", isspace(character(point - 1)) ? "" : " ",
					new_comm, rest);
			*after = point - offset;	// Point might be in the middle of moved text.
		} else {			// Make a new line after the commented code line we
			stuff(new_comm);	// broke.
			point -= 3;
			indent_to_column(c_compute_indent());
		}
	} else {			/* Old-style K&R comment. */
		if (strstr(fill, "*/"))
			*fill = 0;
		if (starts_in_comm)		// Just repeat the *'s or whatever at start of
			stuff(fill);		// old line.
		else if (starts_with_comm) {
			if (!strcmp(fill, "/**"))	// A Javadoc comment.
				fill = " * ";
			replace_in_string(fill, '/', ' ');
			if (fill_c_comment_plain)	// Like above, but convert that first /*.
				replace_in_string(fill, '*', ' ');
			stuff(fill);
		} else {
			delete(point - 1, point);	// Delete the \n we just inserted.
			stuff(" */\n/* ");			// And put this instead.
			to_begin_line();
			indent_to_column(c_compute_indent());
		}
	}
}

// We're inserting the character in key; maybe break this line first
// (or instead).  Return 1 if we still want to insert the character, or
// 0 to ignore it.  But if mode is 0,1,2, then we're only setting (0,1) or
// retrieving (2) the value of c-auto-fill-mode.

int c_maybe_break_line(int mode)
{
	switch (mode) {
		case 0:
		case 1:
			c_auto_fill_mode = (mode != 0);
			return 0;
		case 2:
			return c_auto_fill_mode;
	}
	if (!c_auto_fill_mode)		// We're not in auto-fill mode.
		return 1;
	return do_c_maybe_break_line();
}

// We're inserting the character in key; maybe break this line first
// (or instead).  Return 1 if we still want to insert the character, or
// 0 to ignore it.

int do_c_maybe_break_line()
{
	int comm, res = 1, starts_with_comm, starts_in_comm, after_prefix;
	int comm_start = -1, break_block_comment = 0;
	int generic = strcmp(major_mode, "C");
	char fill[FNAMELEN], pat[FNAMELEN], raw_comm[FNAMELEN];
	spot after, next_ends = 0;

	delete_if_highlighted();

	// Various reasons we might want not want to fill right now.
	if (give_end_line() - give_begin_line() > FNAMELEN - 10)
		return 1;			// The line's too long for us.
	if (current_column() + 1 <= margin_right) {
		if (IS_ENTER_KEY(key) && in_c_comment(c_look_back) == IN_OLD_COMMENT)
			break_block_comment = 1, res = 0;
		else
			return 1;		// We're not past the margin.
	}
	comm = in_c_comment(c_look_back);
	if (!(comm & IN_COMMENT))
		return 1;			// We're not in a comment.

	// Collect info on the situation.
	if (key == ' ') {		// Insert <Space> now, then remember not
		insert(key);		// to later, so we can break here.
		res = 0;
	}
	after = alloc_spot(1);	// Remember where we should end up.
	to_begin_line();	// See if a comment's the first thing on this line.
	strcpy(raw_comm, generic ? comment_begin : "//");
	while (strlen(raw_comm) > 0 && raw_comm[strlen(raw_comm) - 1] == ' ')
		raw_comm[strlen(raw_comm) - 1] = 0;	// Remove trailing spaces.
	sprintf(pat, "[ \t]*%s", generic ? raw_comm : "/[*/]");
	starts_with_comm = parse_string(1, pat);	// Yes.
	starts_in_comm = in_c_comment(c_look_back);	// Does this line start with one?
	sprintf(pat, "[ \t%s]*", generic ? raw_comm : "*/");
	parse_string(1, pat, fill);	// Repeat this prefix on new lines.
	after_prefix = point;
	if (!starts_in_comm) {		// Find where this line's comment starts.
		to_begin_line();
		sprintf(pat, "<min>.*%s",
				generic ? raw_comm : comm == IN_NEW_COMMENT ? "//" : "/%*");
		point += parse_string(1, pat);
		comm_start = point;
	}
	if (nl_forward()) {		// Remember the end of the next line, unless
		to_end_line();		// there's a comment there.
		if (!in_c_comment(c_look_back))
			next_ends = alloc_spot(0);
	}

	// Look for a breaking point.
	point = *after;
	if (break_block_comment ||
		  (c_auto_fill_mode != 1 || starts_with_comm || starts_in_comm)
		  && pick_break(margin_right) && point > after_prefix
		  && point > comm_start)
		c_break_line_here(comm, starts_with_comm, starts_in_comm,
						  comm_start, next_ends, after, fill);

	point = *after;
	free_spot(after);
	if (next_ends)
		free_spot(next_ends);
	return res;
}

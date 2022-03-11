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

// This file has some commands for indenting.

#include "eel.h"

get_soft_tab_size()
{
	return (soft_tab_size > 0) ? soft_tab_size : tab_size;
}

/*  Make this line's indentation the same as the previous nonempty line's,
    unless the indentation would be less, or we're not in this line's
    indentation.  In those cases, indent to the next tab stop. 
*/

command indent_previous() on reg_tab[CTRL('I')]
{
	int orig_column, prev_indent;
	int orig = point;

	if (maybe_indent_rigidly(0))
		return;
	orig_column = current_column();	/* point's column */
	to_begin_line();
	re_search(-1, "[^ \t\n]");	/* find previous non-blank line */
	to_indentation();
	prev_indent = current_column();
	point = orig;
	to_indentation();		/* go to current line's indent */

	if (orig_column < prev_indent && orig_column <= current_column())
		indent_to_column(prev_indent);	/* indentation as previous */
	else {
		point = orig;
		indent_like_tab();
	}
}

prev_indenter()		/* indent this line like previous one */
{
	int prev_indent;
	int orig;

	to_begin_line();
	orig = point;
	re_search(-1, "[^ \t\n]");	/* find previous non-blank line */
	to_indentation();
	prev_indent = current_column();
	point = orig;
	indent_to_column(prev_indent);	/* indentation as previous */
}


/*  Using the previous non-empty line, "tab" over to the beginning
    of the next column of darkspace.
*/

command indent_under() on reg_tab[ALT(CTRL('I'))]
{
	int prev_indent, indent, orig = point;

	if (maybe_indent_rigidly(0))
		return;
	indent = current_column();
	to_begin_line();
	re_search(-1, "[^ \t\n]");	/* find previous non-blank line */
	move_to_column(indent);		/* go to same column on prev line */
	if (current_column() > indent)
		point--;

	if (!re_search(1, "[ \t\n]") || character(point - 1) == '\n' ||
			!re_search(1, "[^ \t]")
			|| character(point - 1) == '\n') {
		point = orig;			 /* indent like one tab */
		indent_like_tab();
	} else {				/* get new place to tab to */
		prev_indent = current_column() - 1;
		point = orig;			/* back to original line */
		indent_to_column(prev_indent);	/* force to new indentation */
	}
}

indent_like_tab()	/* indent like tab char, but maybe use spaces */
{
	int cur = current_column(), tab = get_soft_tab_size();

	to_column(cur + tab - cur % tab);
}

// Commands bound to tab can call this.
// If a region's highlighted, indent all lines by one tab stop
// and return 1.  Otherwise return 0.

maybe_indent_rigidly(int rev)
{
	if (!is_highlight_on())
		return 0;
	if (rev) {
		if (!has_arg)
			iter = -get_soft_tab_size();
		else if (iter > 0)
			iter = -iter;
		has_arg = 1;
	}
	indent_rigidly();
	highlight_on();
	shift_selecting = 2;
	return 1;
}

command back_to_tab_stop() on reg_tab[NUMSHIFT(GREYTAB)]
{			/* move back to nearest tab stop */
	int tab = get_soft_tab_size(), old;

	if (maybe_indent_rigidly(1))
		return;
	old = current_column();
	move_to_column(((current_column() - 1) / tab) * tab);
	if (old && old == current_column())
		point--;
}

/* position point before the first darkspace character on the current line */
command to_indentation() on reg_tab[ALT('m')]
{				/* used by other commands */
	to_begin_line();
	re_search(1, "[ \t]*");
}

to_column(place) /* replace current indentation with indent to column place */
{
	delete(point - parse_string(-1, "[ \t]*"), point); /* del old ind */
	insert_to_column(current_column(), place);
}

indent_to_column(place)	 /* delete whitespace, then indent */
{
	delete_horizontal_space();
	insert_to_column(current_column(), place);
}

insert_to_column(start, end)	/* insert to get from start to end columns */
{
	int i;

	if (indent_with_tabs)
		while ((i = start + tab_size - start % tab_size) <= end) {
			insert('\t');
			start = i;
		}
	for (; start < end; start++)
		insert(' ');
}

force_to_column(want)	/* convert tabs to spaces or add indentation to */
{			/* get to this column on current line */
	int have;

	move_to_column(want);
	have = current_column();
	if (have == want)
		return;
	if (point >= size() - narrow_end || curchar() == '\n')
		insert_to_column(have, want);
	else {
		hack_tabs(want - have);
		move_to_column(want);
	}
}

get_column(pos)		/* give column of a buffer position */
{
	save_var point = pos;
	return current_column();
}

column_to_pos(col)	// give buffer position of char at column on this line
{
	save_var point;
	move_to_column(col);
	return point;
}

get_indentation(pos)	/* give indentation of line at buffer position */
{
	save_var point = pos;
	to_indentation();
	return current_column();
}

// Search for lines matching pattern.  If pattern ends earlier on some lines
// that others, insert spaces so they end at the same column throughout.

right_align_columns(char *pat)
{
	int max_col = 0, min_col = 1000;

	save_spot point = 0;
	while (re_search(1, pat)) {
		max_col = MAX(current_column(), max_col);
		min_col = MIN(current_column(), min_col);
	}
	point = size();
	if (max_col != min_col) {
		while (re_search(-1, pat))
			to_column(current_column() + max_col - get_column(matchstart));
	}
}

command indent_rigidly() on cx_tab['\t']
{
	int temp, indent;

	if (!has_arg) iter = get_soft_tab_size();
	fix_region();
	if (nl_reverse())	/* to start of line */
		point++;
	temp = point;
	while (point < mark) {
		re_search(1, "[ \t]*");
		indent = current_column() + iter;
		to_column(indent);
		if (curchar() == '\n')
			delete_horizontal_space();
		nl_forward();
	}
	mark = temp;
	iter = 0;
}

command indent_region() on reg_tab[ALT(CTRL('\\'))]
{
	int temp;
	int (*func)() = (int (*)()) (mode_keys['\t'] ? mode_keys['\t']
						: root_keys['\t']);
	int progress, cnt = 0;

	fix_region();
	highlight_off();
	if (nl_reverse())
		point++;
	temp = point;
	progress = (mark - point > 4000);
	this_cmd = CMD_INDENT_REG;
	while (point < mark) {
		(*func)();
		if (curchar() == '\n')
			delete_horizontal_space();
		nl_forward();
		if (!(cnt % 25) && progress && temp - mark != 0)
			note("Indenting region: %d%%...",
				 100 * (point - temp ) / (mark - temp));
		cnt++;
		check_abort();
	}
	if (progress)
		say("");
	mark = temp;
	this_cmd = iter = 0;
}

hack_tabs(offset)	/* change tabs to spaces between current column */
{			/* and current + offset column */
	int count = offset, dir = 1;
	spot orig;

	if (offset < 0)
		count = -offset, dir = -1;
	if (count > 1 || character(point - (offset < 0)) == '\t') {
		orig = alloc_spot();
		column_chars(count, dir);
		tab_convert(point, *orig, 0);
		point = *orig;
		free_spot(orig);
	}
}

column_chars(n, dir)		/* move by n chars, counting tabs as spaces */
{
	int i, j, sofar = 0, failed = 0;
	int offs;

	offs = (dir == -1) ? -1 : 0;
	while (sofar < n && point + offs >= narrow_start
				&& point + offs < size() - narrow_end) {
		if (character(point + offs) == '\n')
			point += dir, sofar++;
		else {
			i = current_column();
			if (failed)
				point += dir;
			else
				move_to_column(i + (n - sofar) * dir);
			j = current_column();
			failed = (i == j);
			sofar += (j - i) * dir;
		}
		check_abort();
	}
}

all_blanks(from, to)	/* are all chars in this region whitespace? */
{
	save_var point;
	for (point = from; point < to; point++)
		if (!isspace(curchar()))
			return 0;
	return 1;
}

command untabify_region() on cx_tab[ALT('i')]
{
	do_tabify_region(0);
}

command tabify_region() on cx_tab[ALT(CTRL('i'))]
{
	do_tabify_region(1);
}

command untabify_buffer()
{
	tab_convert(0, size(), 0);
	iter = 0;
	say("Done.");
}

command tabify_buffer()
{
	tab_convert(0, size(), 1);
	iter = 0;
	say("Done.");
}

/* Run tab_convert() on the current region, special-casing rectangular
 * regions. */
do_tabify_region(totabs)
{
	if (region_type() == REGRECT) {
		int width, orig = bufnum, b = tmp_buf();

		save_var indent_with_tabs = totabs;
		width = extract_rectangle(b, 0);
		save_var bufnum = b;
		tab_convert(0, size(), totabs);
		xfer_rectangle(orig, width, 1);
		restore_vars();
		buf_delete(b);
	} else {
		save_spot point, mark;
		fix_region();
		tab_convert(point, mark, totabs);
	}
	iter = 0;
	say("Done.");
}

tab_convert(from, to, totabs)
{			/* convert between tabs & spaces in this region */
	save_spot point = from;
	save_var indent_with_tabs = 1; // use tabs, even if we normally don't
	save_var narrow_end = size() - narrow_position(to);
	if (totabs)
		spaces_to_tabs();
	else
		tabs_to_spaces();
}

tabs_to_spaces() /* convert tabs to spaces in rest of buffer */
{
	int i, j;

	while (search(1, "\t")) {
		i = current_column();
		point--;
		j = current_column();
		replace(point, ' ');
		while (++j < i)
			insert(' ');
	}
}

spaces_to_tabs() /* convert spaces to tabs in rest of buffer */
{
	int i, j;

	while (re_search(1, "(\t| [ \t])[ \t]*")) {
		i = get_column(matchstart);
		j = current_column();
		if (i + 1 < j) {
			delete(matchstart, point);
			insert_to_column(i, j);
		}
	}
}

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

// This file has commands that deal with words, paragraphs, and so
// forth.

#include "eel.h"

/* position point after the next word */
command forward_word() on reg_tab[ALT('f')], reg_tab[NUMCTRL(KEYRIGHT)]
{
	do_shift_selects();
	if (iter < 0) {
		iter = -iter;
		backward_word();
	}
	while (iter-- > 0)
		re_search(1, forward_word_to_start ? "<any>!<[word>" : word_pattern);
}

/* position point before the previous word */
command backward_word() on reg_tab[ALT('b')], reg_tab[NUMCTRL(KEYLEFT)]
{
	do_shift_selects();
	if (iter < 0) {
		iter = -iter;
		forward_word();
	}
	while (iter-- > 0)
		re_search(-1, word_pattern);
}

/* make the current word all lower case */
command lowercase_word() on reg_tab[ALT('l')]
{
	word_or_region(do_lowercase_region);
}

/* make the current word all upper case */
command uppercase_word() on reg_tab[ALT('u')]
{
	word_or_region(do_uppercase_region);
}

/* capitalize the current word */
command capitalize_word() on reg_tab[ALT('c')]
{
	word_or_region(do_capitalize_region);
}

do_lowercase_region(from, to)
{
	int temp;

	if (from > to)
		temp = from, from = to, to = temp;
	for (; from < to; from++) {
		replace(from, tolower(character(from)));
		check_abort();
	}
}

do_uppercase_region(from, to)
{
	int temp;

	if (from > to)
		temp = from, from = to, to = temp;
	for (; from < to; from++) {
		replace(from, toupper(character(from)));
		check_abort();
	}
}

do_capitalize_region(from, to)
{
	int temp, first = 1, c;

	if (from > to)
		temp = from, from = to, to = temp;
	for (; from < to; from++) {
		c = character(from);
		replace(from, first ? toupper(c) : tolower(c));
		first = !isalpha(c);
		check_abort();
	}
}

word_or_region(func)	/* call func on appropriate regions */
int (*func)();
{
	int high, orig, scol, ecol;

	high = has_arg ? 0 : is_highlight_on();		// get highlight type
	check_modify(bufnum);		// don't move if we can't modify
	if (!high) {
		orig = point;
		forward_word();		// pass iter; can move bkwds
		(*func)(orig, point);
		return;
	}
	save_spot point, mark;
	fix_region();
	if (high == REGRECT) {	// do on right columns of each line
		scol = get_column(point);
		ecol = get_column(mark);
		for (; point < mark; nl_forward())
			(*func)(column_to_pos(scol), column_to_pos(ecol));
	} else
		(*func)(point, mark);
}

/* transpose characters before and after point */
command transpose_characters() on reg_tab[CTRL('T')]
{
	int p = point;
	char c, d;

	if (p == size() || curchar() == '\n')
		p--;		/* switch last two at end of line */
	else if (p == 0 || character(point - 1) == '\n')
		p++;
	c = character(p);	/* store away current */
	d = character(p - 1);
	if (p > 0 && p < size() && c != '\n' && d != '\n') {
		replace(p, d);
		replace(p - 1, c);
	}
	iter = 0;
}

transpose_areas(from1, to1, from2, to2)
{		/* requires from1 <= to1 <= from2 <= to2 */
	int t1, t2;

	if (from1 > to1 || to1 > from2 || from2 > to2)
		return;
	t1 = tmp_buf();
	t2 = tmp_buf();
	buf_xfer(t1, from1, to1);	/* copy areas */
	buf_xfer(t2, from2, to2);
	delete(from2, to2);
	delete(from1, to1);
	point = from1 + from2 - to1;	/* go to where second was */
	grab_buffer(t1);
	point = from1;			/* go where first was */
	grab_buffer(t2);		/* stay after first one */
	buf_delete(t1);
	buf_delete(t2);
}

command transpose_words() on reg_tab[ALT('t')]
{
	int from1, to1, to2;

	re_search(1, word_pattern);		/* these extra moves */
	if (!re_search(-1, word_pattern))	/* position us correctly */
		error("Nothing to transpose.");	/* when we're near one */
	if (!re_search(-1, word_pattern)) {	/* end of the buffer */
		re_search(1, word_pattern);
		if (!re_search(1, word_pattern))
			error("Nothing to transpose.");
		re_search(-1, word_pattern);
		re_search(-1, word_pattern);
	}
	from1 = point;		/* now we're at start of first word */
	re_search(1, word_pattern);
	to1 = point;
	re_search(1, word_pattern);
	to2 = point;
	re_search(-1, word_pattern);
	transpose_areas(from1, to1, point, to2);
	iter = 0;
}

command transpose_lines() on cx_tab[CTRL('T')]
{
	int from1;

	nl_reverse();
	to_begin_line();
	from1 = point;
	if (!nl_forward())
		error("Nothing to transpose.");
	transpose_areas(from1, point - 1, point, give_end_line());
	point++;	/* go to start of 2nd one */
	iter = 0;
}

command set_fill_column() on cx_tab['f']
{
	char pr[80];
	int def, i;

	if (has_arg)
		margin_right = iter;
	else {
		def = current_column() + 1;
		sprintf(pr, "Change fill column from %d to [%d]: ",
			margin_right, def);
		i = get_number(pr);
		margin_right = (i > 0) ? i : def;
	}
	iter = 1;
	say("Fill column is %d", margin_right);
}


command mark_paragraph() on reg_tab[ALT('h')]
{
	backward_paragraph();
	mark = point;
	forward_paragraph();
	set_region_type(REGNORM);
	highlight_on();
}

command forward_paragraph() on reg_tab[ALT(']')], reg_tab[NUMALT(KEYDOWN)],
							   reg_tab[NUMALT(NUMDIGIT(2))]
{
	char pat[100];

	do_shift_selects();
	re_search(1, ".");
	sprintf(pat, "\n%s|\f",
			indents_separate_paragraphs ? "[ \t\n]" : "[ \t]*\n");
	if (tex_paragraphs) {	/* skip formatter lines */
		to_begin_line();
		re_search(1, "(([@.]|^\\(begin|end)|^[ \t]*%%).*\n)*");
		re_search(1, "[^ \t\n@.\\]");
		strcat(pat, "|^\\(begin|end)|^[ \t]*%%");
	}
	if (re_search(1, pat)) {
		point--;
		if (curchar() != '\f') {
			if (!indents_separate_paragraphs)
				re_search(-1, "[ \t]*");
			if (tex_paragraphs)
				re_search(-1, "^(([@.]|^\\(begin|end)|^[ \t]*%%).*\n)*");
		}
	} else
		point = size();
}

command backward_paragraph() on reg_tab[ALT('[')], reg_tab[NUMALT(KEYUP)],
								reg_tab[NUMALT(NUMDIGIT(8))]
{
	do_shift_selects();
	if (tex_paragraphs) {
		if (character(point - 1) == '\n')
			re_search(-1, "^(([@.]|^\\(begin|end)|^[ \t]*%%).*\n)*");
		re_search(-1, "[^ \t\n]");
		if (matches_at(give_begin_line(), 1, "^\\(begin|end)|^[ \t]*%%"))
			to_begin_line();
		if (indents_separate_paragraphs) {
			if (re_search(-1, "\n[ \t\n]|\f|^\\(begin|end|^[ \t]*%%)"))
				re_search(1, "\n*");
		} else
			re_search(-1, "(\n[ \t]*\n|\f|^\\(begin|end)|^[ \t]*%%)!");
		if (curchar() != '\f')
			re_search(1, "^(([@.\f]|^\\(begin|end)|^[ \t]*%%).*\n)*");
	} else {
		re_search(-1, "[^ \t\n]");
		if (indents_separate_paragraphs) {
			if (re_search(-1, "\n[ \t\n]|\f|\n\\(begin|end|\n[ \t]*%%)"))
				re_search(1, "\n*");
		} else
			re_search(-1, "(\n[ \t]*\n|\f)!");
	}
}

command forward_sentence() on reg_tab[ALT('e')]
{
	do_shift_selects();
	for (; iter > 0; iter--)
		next_sentence();
	for (; iter < 0; iter++)
		previous_sentence();
}

command backward_sentence() on reg_tab[ALT('a')]
{
	iter = -iter;
	forward_sentence();
}

next_sentence()
{
	re_search(1, "[^ \t\n]");	/* don't find same sentence */
	save_var narrow_end = size() - give_position(forward_paragraph);
	if (re_search(1, sentence_end))	/* go to end of sentence */
		re_search(-1, "[ \n\t]*(.|\n)");
}

previous_sentence()
{
	int orig = point;

	for (;;) {
		save_var narrow_start = give_position(backward_paragraph);
		re_search(-1, "[^ \t\n]");
		re_search(-1, sentence_end);
		point = matchstart;	/* go to start of sent. */
		if (point < orig)
			return;
		point = 0;		/* go to start of parag */
		restore_vars();
		if (point <= narrow_start)
			break;
	}
}

when_setting_sentence_end_double_space()
{
	if (ask_yn("Set sentence-end too?",
			   "Set the sentence-end variable to match?", "Yes", "No", 1))
		sprintf(sentence_end, "([.?!]<rsquare|rparen|squote|dquote>*"
				"[ \t\n]*(%s[ \t]|\n))", sentence_end_double_space ? "[ \t]" : "");
}

give_position(cmd)	/* return buf pos that cmd goes to, but preserve pt */
int (*cmd)();
{
	save_var point;
	(*cmd)();
	return point;
}

command center_line() on reg_tab[ALT('s')]	/* center current line */
{
	int linelen;			/* length of line */

	to_begin_line();		/* first remove extra space */
	delete_horizontal_space();
	to_end_line();
	delete_horizontal_space();
	linelen = current_column();	/* column at end is length */
	to_begin_line();
	to_column((margin_right - linelen) / 2);	/* indent to here */
}

/* make space break line or not */
command auto_fill_mode()
{
	call_maybe_break_line(has_arg? (iter != 0) : !call_maybe_break_line(2));
	make_mode();
	iter = 1;
}

/* determine where to break current line given right margin */
pick_break(col)
int col;
{
	int orig = point, start, colpos;

	to_begin_line();
	re_search(1, "[ \t]*");	/* skip indentation */
	start = point;
	move_to_column(col);	/* find first space before col */
	colpos = point;
	if (re_search(-1, "[ \t]") && point > start) {
		point++;
		return 1;
	}
	point = colpos;		/* else find first space after col */
	if (re_search(1, "[ \t]") && point < orig) {
		point--;
		return 1;
	}
	point = orig;
	return 0;
}

command enter_key() on reg_tab['\r'], reg_tab[GREYENTER],
		       reg_tab[NUMSHIFT(GREYENTER)]
{
	key = '\n';
	normal_character();
}

// Formerly, auto fill mode broke lines only in response to spaces.
// This routine handled that.  Now normal-character checks on every
// character, and this routine simply calls that one.  It's here only
// so that extensions can call it.

maybe_break_line()
{
	normal_character();
}

// When mode is 0 or 1, we set auto-fill off or on in this buffer.
// When mode is 2, we return nonzero if auto-fill is on.
// When mode is 3, we perform auto-filling, breaking the line and
// returning nonzero if we should still
// insert the character that triggered this.

call_maybe_break_line(int mode)
{
	if (buffer_maybe_break_line)
		return (*buffer_maybe_break_line)(mode);
	switch (mode) {
		case 0:
		case 1:		fill_mode = (mode != 0);
					return 0;
		case 2:		return fill_mode != 0;
	}
	return fill_mode ? maybe_break_this_line() : 1;
}

// We're inserting the character in key; maybe break this line first
// (or instead).  Return 1 if we still want to insert the character,
// or 0 to ignore it.

int maybe_break_this_line()
{
	int h, found = 1;
	spot old;

	h = current_column();
	if (h >= margin_right) {
		old = alloc_spot(1);
		if (h == margin_right && (key == ' ' || key == '\n')) {
			break_line_here();	/* just change the ' ' to a '\n' */
			return 0;
		}
		found = pick_break(margin_right);
		if (found) {
			break_line_here();
			if (key == '\n')
				key = ' ';
			point = *old;
		} else if (key == ' ')
			break_line_here();
		free_spot(old);
		if (!found && key == ' ')
			return 0;
	}
	return 1;
}

break_line_here()	/* replace whitespace with \n and indent */
{
	delete_horizontal_space();
	insert('\n');
	if (auto_fill_indents && indenter)
		(*indenter)();
	if (display_column > 0)
		display_column = 0;
}

command fill_region()
{
	save_var point;
	if (has_arg)
		save_var margin_right = (iter > 5) ? iter : 32000;
	if (region_type() == REGRECT)
		fill_rectangle(0);
	else {
		fix_region();
		do_fill_region();
	}
}

fill_rectangle(marg)	// fill parags in rectangle betw point and mark
{		// to marg columns (relative to rectangle's width if <=0)
	int width, orig = bufnum, b = tmp_buf();

	width = extract_rectangle(b, 0);
	save_var bufnum = b;
	mark = 0;
	margin_right = marg + (marg <= 0 ? width : 0);
	do_fill_region();
	xfer_rectangle(orig, width, 1);
	buf_delete(b);
}

do_fill_region()
{
	int orig = point, start, atend = 0;
	spot end = alloc_spot();

	if (point > (*end = mark))
		*end = point, orig = point = mark;
	while (point < *end && !atend) {
		start = point;
		if (search(1, "\n\n"))
			point--;
		else
			atend = 1;
		if (point > *end + 1)
			point = *end + 1;
		region_fill(start, point - 1);
		re_search(1, "[ \t\n]*");	/* skip paragraph indent */
	}
	mark = orig;
	point = *end;
	free_spot(end);
	if (display_column > 0)
		display_column = 0;
	fix_window_start();
}

command fill_paragraph() on reg_tab[ALT('q')]
{
	int end;

	if (has_arg)
		save_var margin_right = (iter > 5) ? iter : 32000;
	if (is_highlight_on()) {
		fill_region();
		return;
	}
	save_var point;
	iter = 0;
	point--;
	forward_paragraph();
	end = point - 1;
	backward_paragraph(); 
	re_search(1, "[ \t\n]*");	/* leave leading whitespace intact */
	if (point < end)
		region_fill(point, end);
	if (display_column > 0)
		display_column = 0;
	fix_window_start();	/* win shouldn't start in middle of line */
}

// Fill a paragraph preserving its leading whitespace.  With prefix
// arg, use current column as right margin.

command fill_indented_paragraph() on reg_tab[ALT('Q')]	// Alt-Shift-Q
{
	int pbuf, width, i, old_lines, new_lines, orig = bufnum;
	char prefix[FNAMELEN];

	iter = 0;
	if (has_arg)
		save_var margin_right = current_column() + 1;
	save_spot point;
	point--;
	forward_paragraph();
	mark = point - 1;
	backward_paragraph(); 
	point += parse_string(1, "([ \t]*\n)+");
	parse_string(1, "[ \t]*", prefix);
	width = current_column();
	save_var narrow_start = point;		// Narrow to the paragraph.
	point = mark;
	save_var narrow_end = size() - point + 1;

	point = 0;
	while (nl_forward())	// Find width of narrowest indentation.
		width = MIN(width, get_indentation(point));
	pbuf = tmp_buf();
	point = 0;
	while (nl_forward()) {	// Move each prefix to our temp buffer.
		i = column_to_pos(width);
		buf_xfer(pbuf, point - 1, i);
		delete(point, i);
	}
	old_lines = lines_between(0, size(), 0) + 1;
	region_fill_first_line(narrow_start, size() - narrow_end,
						   MAX(margin_right, 2),
						   MAX(margin_right - width, 2));
	new_lines = lines_between(0, size(), 0) + 1;
	point = 0;
	bufnum = pbuf;
	point = 0;	// Now copy the prefixes back.
	for (; new_lines > 0 && old_lines > 0; old_lines--, new_lines--) {
		if (point < give_end_line())
			grab(point, give_end_line(), prefix);
		buf_xfer(orig, point, give_end_line());
		nl_forward();
		bufnum = orig;
		nl_forward();
		bufnum = pbuf;
	}
	bufnum = orig;
	for (; new_lines > 0; new_lines--) {	// More lines than before.
		stuff(prefix);			// Add some prefixes.
		nl_forward();
	}
	buf_delete(pbuf);
	if (display_column > 0)
		display_column = 0;
	fix_window_start();	/* win shouldn't start in middle of line */
}

widened_move_to_column(int col)
{
	save_var narrow_start = 0;
	move_to_column(col);
}

region_fill(a, b)
	int a, b;
{
	region_fill_first_line(a, b, margin_right, margin_right);
}

// Fill paragraph between a and b.  Make the first line up to
// first_width long.  Make remaining lines up to rest_width.
region_fill_first_line(int a, int b, int first_width, int rest_width)
{
	int start, atend, len;

	if (a > b)			/* switch so a < b */
		start = a, a = b, b = start;
	save_spot point = a;
	save_var narrow_start = a, narrow_end = size() - b;
	save_var abort_searching = 0;
	point = 0;		/* remove previous line breaks */
	while (re_search(1, "( [ \t\n]+)|([\t\n][ \t\n]*)")) {
		len = point - matchstart;
		atend = character(matchstart) == '\n';
		delete(matchstart, point);
		if (sentence_end_double_space && (len >= 2 || atend)
			  && parse_string(-1, "[.?!][])'\"]*", NULL))
			stuff("  ");
		else
			insert(' ');
	}
	point = 0;
	widened_move_to_column(first_width);
	for (;;) {		/* put in new line breaks */
		if (point >= size() - narrow_end)
			break;
		while (curchar() == ' ')
			point++;
		re_search(-1, " +");
		if (!re_search(1, " +"))
			break;
		delete(matchstart, point);
		insert('\n');
		narrow_start = point;	/* never look before here */
		widened_move_to_column(rest_width);
	}
	build_first = 1;		/* redisplay hint */
}

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

// This file has commands for killing or deleting text.

#include "eel.h"
#include "kill.h"
#include "c.h"
#include "colcode.h"

check_num_kill_buffers()
{
	int i;

	if (kill_buffers == _prev_kill_buffers && _kill_width)
		return;
	if (kill_buffers < 1)
		kill_buffers = 1;
	if (_kill_width)
		free(_kill_width);
	_kill_width = (short *) malloc(kill_buffers * sizeof(short));
	for (i = 0; i < _prev_kill_buffers; i++) {
		sprintf(_cur_kill_buf, "-kill-buffer-%d", i);
		delete_buffer(_cur_kill_buf);
	}
	for (i = 0; i < kill_buffers; i++)
		_kill_width[i] = UNUSED;
	_prev_kill_buffers = kill_buffers;
	_num_kill = 0;
}

/* Prepare to use another kill buffer.  Find the proper one and empty it. */
push_kill()
{
	_num_kill = (++_num_kill) % kill_buffers;
	sprintf(_cur_kill_buf, "-kill-buffer-%d", _num_kill);
	zap(_cur_kill_buf);	/* zap will create if necessary */
}

/* make the previous kill buffer current, create if necessary */
pop_kill()
{
	check_num_kill_buffers();
	if (--_num_kill < 0)
		_num_kill += kill_buffers;
	sprintf(_cur_kill_buf, "-kill-buffer-%d", _num_kill);
	create(_cur_kill_buf);	/* no effect if already exists */
}

/* transfer region to kill buffer appropriately, then delete it */
do_save_kill(near, far)		/* near is end adjacent to old text */
{
	do_save_only(near, far);
	delete(near, far);
}

/* transfer region to kill buffer appropriately */
do_save_only(near, far)		/* near is end adjacent to old text */
{
	char *thisbuf = bufname;

	check_num_kill_buffers();
	if (prev_cmd != APPENDKILL || !NORM_REGION(_kill_width[_num_kill])) {
		push_kill();		/* start on a new killbuffer */
		_kill_width[_num_kill] = (region_type() == REGLINE)
								 ? REGION_LINE : REGION;
	} else { /* get to proper end of same kill buffer as last time */
		bufname = _cur_kill_buf;
		point = (near < far) ? size() : 0;
		bufname = thisbuf;
	}
	xfer(_cur_kill_buf, near, far);
	this_cmd = APPENDKILL;
	save_to_clipboard();
}

/* exchange point and mark */
command exchange_point_and_mark() on cx_tab[CTRL('X')]
{
	int temp = point, tcol;

	point = mark;
	tcol = mark_to_column;
	do_set_mark(temp);
	cursor_to_column = tcol;
}

/* set mark to be point */
command set_mark() on reg_tab[CTRL('@')], reg_tab[ALT('@')]
{			/* begin marking a normal region */
	do_set_mark(point);
	say("Mark set.");
	set_region_type(REGNORM);
	highlight_on();
}

do_set_mark(val)
{
	mark = val;
	save_var point = val;
	mark_to_column = cursor_to_column;
	shift_selecting = 0;
}

/* The following four commands begin defining a particular type of
region, or switch the current region to a different type, or remove
the highlighting for the current region, depending upon the setting
of mark_unhighlights. */

command mark_normal_region()
{
	set_mark_cmd(REGNORM);
}

command mark_rectangle() on cx_tab['#']
{
	set_mark_cmd(REGRECT);
}

command mark_line_region()
{
	set_mark_cmd(REGLINE);
}

command mark_inclusive_region()
{
	set_mark_cmd(REGINCL);
}

set_mark_cmd(type)	// set mark equal to point, and begin defining
{			// the specified type of region
	int now = is_highlight_on();	// get type of current region

	if (!now || type == now && !mark_unhighlights) {
		do_set_mark(point); // start new region here
		say("Mark set.");
	} else if (type == now && mark_unhighlights) {
		highlight_off();	// region is same type, remove it
		return;
	}
	set_region_type(type);	// define region of this type & show it
	highlight_on();
}

/*
Commands that need to operate on more than just normal regions generally
save point and mark in spots, then call fix_region(), which will move
point and mark so that point <= mark, and convert inclusive and
line regions to look like normal regions.  The caller must still
deal with rectangular regions appropriately, though.
*/

fix_region() /* ensure point <= mark, fix line & inclusive regions */
{
	int t;

	if (point > mark)
		exchange_point_and_mark();
	if (region_type() == REGLINE) {
		to_begin_line();
		t = point;
		point = mark;
		nl_forward();
		mark = point;
		point = t;
	} else if (region_type() == REGINCL)
		mark++;
}

kill_after_cmd(cmd)	/* kill from here to position after cmd */
int (*cmd)();
{
	int start;

	check_modify(bufnum);
	start = point;
	(*cmd)();
	do_save_kill(start, point);
}

/* delete from point to the end of the next word */
command kill_word() on reg_tab[ALT('d')]
{
	kill_after_cmd(forward_word);
}

command mark_whole_buffer() on cx_tab['h']
{
	point = 0;
	mark = size();
	set_region_type(REGNORM);
	highlight_on();
}

/* delete from point to the beginning of the previous word */
command backward_kill_word() on reg_tab[ALT(CTRL('H'))],
			reg_tab[NUMALT(GREYBACK)], reg_tab[ALT(DEL)]
{
	kill_after_cmd(backward_word);
}

command backward_delete_word()
{
	int start = point;
	check_modify(bufnum);
	backward_word();
	delete(start, point);
}

command kill_sentence() on reg_tab[ALT('k')]
{
	kill_after_cmd(forward_sentence);
}

command kill_level() on reg_tab[ALT(CTRL('K'))]
{
	kill_after_cmd(forward_level);
}

command backward_kill_level() on reg_tab[NUMALT(KEYDELETE)],
								 reg_tab[NUMALT(NUMDOT)]
{
	kill_after_cmd(backward_level);
}


do_kill_line(int save_it)
{
	int start = point;

	check_modify(bufnum);
	if (has_arg) {
		if (iter > 0)
			while (iter-- > 0)
				nl_forward();
		else {
			while (iter++ <= 0)
				nl_reverse();
			if (point > 0)
				point++;
		}
	} else if (curchar() == '\n')
		point++;
	else
		to_end_line();

	iter = 0;
	if (save_it)
		do_save_kill(start, point);
	else
		delete(start, point);
}


/* delete the current line, and put it in the kill buffer */
command kill_line() on reg_tab[CTRL('K')]
{
	do_kill_line(1);
}

command kill_current_line()	/* kill entire line */
{
	to_begin_line();
	has_arg = 1;
	do_kill_line(1);
}

command delete_current_line()	/* delete entire line */
{
	to_begin_line();
	has_arg = 1;
	do_kill_line(0);
}

command kill_to_end_of_line()
{
	if (curchar() != '\n')	// cmd does nothing at end of line
		do_kill_line(1);
}

command delete_to_end_of_line()
{
	if (curchar() != '\n')	// cmd does nothing at end of line
		do_kill_line(0);
}

command kill_region() on reg_tab[CTRL('W')], reg_tab[NUMSHIFT(KEYDELETE)]
{
	if (region_type() == REGRECT)
		kill_rectangle();
	else {
		save_spot point, mark;	// handle other types of regions
		fix_region();
		do_save_kill(point, mark);
	}
}

command copy_region() on reg_tab[ALT('w')], reg_tab[NUMCTRL(KEYINSERT)]
{
   do_copy_region();
   highlight_off();
   say("Region copied.");
}

do_copy_region()
{
	save_spot point, mark;	// handle other types of regions
	fix_region();
	if (region_type() == REGRECT)
		copy_rectangle();
	else {
		prev_cmd = 0;
		do_save_only(point, mark);
		this_cmd = 0;
	}
}

/* Delete the current character */
command delete_character() on reg_tab[CTRL('D')], reg_tab[KEYDELETE]
{
	if (!delete_if_highlighted())
		do_delete_characters(1);
}

/* Delete the previous character */
command backward_delete_character() on reg_tab[CTRL('H')], reg_tab[DEL],
				       reg_tab[NUMSHIFT(GREYBACK)], reg_tab[GREYBACK]
{
	if (delete_if_highlighted())
		return;
	if (virtual_space && cursor_to_column > 0)
		virtual_move_back();
	else {
		if (delete_hacking_tabs)
			hack_tabs(-iter);
		do_delete_characters(-1);
	}
}

virtual_move_back()	/* move left in virtual space */
{
	int newcol = cursor_to_column, orig = point;

	if ((curchar() == '\n' || character(point - 1) == '\t') &&
						!(newcol % tab_size))
		newcol -= tab_size;
	else
		newcol--;
	to_virtual_column(newcol);
	if (point < orig)
		point = orig - (curchar() == '\t');
}

do_delete_characters(dir)
{
	int start;

	check_modify(bufnum);
	start = point;
	if (has_arg || prev_cmd == APPENDKILL) {
		point += iter * dir;
		do_save_kill(start, point);
	} else if (!over_mode || dir == 1 || point <= 0)
		delete(start, start + dir);
	else if (character(--point) != '\t' && curchar() != '\n')
		replace(point, ' ');
	iter = 0;
}

command append_next_kill() on reg_tab[ALT(CTRL('W'))]
{
	if (region_type() == REGRECT)
		delete_rectangle();
	else
		this_cmd = APPENDKILL;
}

command kill_rectangle()
{				/* save and replace w/ spaces */
	pick_rectangle(1, 2);
}

command copy_rectangle()
{
	pick_rectangle(1, 0);
}

command delete_rectangle()
{				/* remove columns */
	pick_rectangle(0, 1);
}

pick_rectangle(copy, remove)	/* copy => push copy of rectangle */
{				/* remove => take out rectangle */
	iter = 0;		/* remove>1 => and put spaces instead */
	if (remove)
		check_modify(bufnum);
	if (copy) {
		check_num_kill_buffers();
		push_kill();
		_kill_width[_num_kill] = extract_rectangle(
			name_to_bufnum(_cur_kill_buf), remove);
		save_to_clipboard();
	} else
		extract_rectangle(0, remove);
	set_region_type(REGRECT);
}

/*
 Operate on rectangular region between point & mark in current buffer.
 If copybuf is nonzero, insert a copy of the rectangle in buffer with
 that number.  If remove is 1, delete the characters in the
 region.  If remove is 2, replace the characters with spaces.
 Leave point at the upper left corner of the rectangle, mark at the
 lower right, and return the width of the rectangle.
*/

extract_rectangle(copybuf, remove)
{
	int oldpoint, t, tmp = 0;
	short start_col, stop_col;	/* columns to operate on */

	if (remove)
		check_modify(bufnum);
	start_col = virtual_column();
	t = point;
	point = mark;
	if (mark_to_column >= 0)
		stop_col = mark_to_column;
	else
		stop_col = current_column();
	point = t;
	if (point > mark)
		t = point, point = mark, mark = t;
	if (start_col == stop_col)
		return 0;
	else if (start_col > stop_col)
		t = start_col, start_col = stop_col, stop_col = t;
	oldpoint = point;
	if (!remove && _buf_readonly) {
		tmp = tmp_buf();
		t = give_begin_line();
		point = mark;
		buf_xfer(tmp, t, give_end_line());
		save_var bufnum = tmp;
		exchange_point_and_mark();
	}
	for (;;) {			/* for each line */
		force_to_column(start_col);
		t = point;
		force_to_column(stop_col);
		if (copybuf)
			buf_xfer(copybuf, t, point);
		if (remove)
			delete(t, point);
		if (remove > 1)
			insert_to_column(start_col, stop_col);
		if (point >= mark || !nl_forward())
			break;
		if (copybuf)
			buf_xfer(copybuf, point - 1, point);
	}
	mark = point;		/* lower right of rectangle */
	point = oldpoint;	/* upper left */
	force_to_column(start_col);
	if (tmp) {
		restore_vars();
		buf_delete(tmp);
	}
	return stop_col - start_col;
}

/* yank the current kill buffer into the current buffer */
command yank() on reg_tab[CTRL('Y')], reg_tab[NUMSHIFT(KEYINSERT)]
{
	int pos = point, oldsize = size();

	delete_if_highlighted();
	get_clipboard();
	retrieve(0);
	if (_doing_input == DI_LINEINPUT && insert_default_response == 3
	   && pos == oldsize && size() < FNAMELEN) {
		undo_mainloop();		// Let undo add stuff back.
		restart_file_paths();
	}
}

/* pop to the previous kill buffer, and replace region with the new buffer */
command yank_pop() on reg_tab[ALT('y')]
{
	retrieve(1);
}

rectangle_position_after_yank(int topleft, int bottomright)
{
	int col;

	switch (yank_rectangle_to_corner) {
		case 2:		// Old-style, to top left.
			point = _oldfrom = topleft;
			mark = _oldto = bottomright;
			break;
		case 3:		// Brief-style, on line following yanked region.
			col = get_column(topleft);
			mark = topleft;
			point = bottomright;
			if (nl_forward())
				move_to_column(col);
			_oldfrom = _oldto = -1; // Must disallow yank-pop with this style.
			break;
		default:	// Standard method: to lower right.
			point = _oldto = bottomright;
			mark = _oldfrom = topleft;
			break;
	}
}

retrieve(withpop)	/* insert text from kill buffer */
{
	char *thisbuf = bufname;
	int overwrite = over_mode;

	check_modify(bufnum);
	check_num_kill_buffers();
	if (_kill_width[_num_kill] == UNUSED)	/* no kills yet */
		return;
	if (withpop && !pop_retrieve())
		error("Must follow yank or yank-pop");
	if (_kill_width[_num_kill] == REGION_LINE)
		to_begin_line();
	_oldfrom = point;		/* record start of yank */
	undo_flag = UNDO_FLAG_KILL;	/* mark in undo list */
	bufname = _cur_kill_buf;
	if (bufname == thisbuf)		/* ignore yanking to kill buffer */
		return;
	switch (_kill_width[_num_kill]) {
		case REGION_LINE:
			set_region_type(REGLINE);
			break;
		case REGION:
			set_region_type(REGNORM);
			break;
		default:
			set_region_type(REGRECT);
			break;
	}

	if (region_type() != REGRECT) {
		xfer(thisbuf, 0, size());
		bufname = thisbuf;
		_oldto = point;		/* end of yank */
		if (iter >= 0)
			do_reindent_after_yank();
	} else {			/* yank rectangle */
		xfer_rectangle(name_to_bufnum(thisbuf),
			       _kill_width[_num_kill], overwrite);
		bufname = thisbuf;
		rectangle_position_after_yank(_oldfrom, mark);
	}
	build_first = 1;		/* redisplay hint */
}

pop_retrieve()		/* get previous kill buffer */
{
	int from, to, t, ok = 0, i = 0;
	spot before, after;

	from = point, to = mark;
	if (to < from)		/* ensure from <= to */
		from = mark, to = point;
	undo_flag = UNDO_FLAG_RETR;
	if (from != _oldfrom || to != _oldto)
		return 0;
	do {		/* undo previous yank */
		t = undo_op(1);
		if ((t & UNDO_FLAG) && undo_flag == UNDO_FLAG_KILL) {
			ok = 1 + (NORM_REGION(_kill_width[_num_kill]));
			break;		/* found prev yank */
		}
	} while (t && !(t & UNDO_END) && i++ < 10);
	if (ok == 2) {		/* if region */
		before = alloc_spot(0);	/* remember where it was */
		after = alloc_spot(1);
	}
	if (ok != 1) {		/* unless rectangle, redo it now */
		while (!(undo_op(0) & UNDO_FLAG)
					|| undo_flag != UNDO_FLAG_RETR)
			;		/* redo it */
	}
	if (ok == 2) {
		delete(*before, *after);
		free_spot(before);
		free_spot(after);
	} else if (!ok)
		return 0;
	t = _num_kill;
	do {			/* get the previous kill buffer */
		pop_kill();	/* skipping unused kbufs */
	} while (_kill_width[_num_kill] == UNUSED && t != _num_kill);
	return 1;
}

/*
 Insert current buffer as a rectangle of given width into dest buffer,
 starting at dest's current point.  If overwrite is nonzero, copy on
 top of existing columns, else insert new columns.  Leave point at
 top left corner of new rectangle in dest, mark at bottom right.
 Remain in original at same position.
*/

xfer_rectangle(dest, width, overwrite)
{
	int startcol, stopcol, from, to, t;
	int src = bufnum;

	save_var point;
	bufnum = dest;
	save_var point;
	startcol = current_column();
	stopcol = startcol + width;
	bufnum = src;
	point = 0;
	while (point < size()) {	/* for each line in src buf */
		from = point;
		to = nl_forward();
		to = point - to;
		bufnum = dest;
		force_to_column(startcol);
		if (overwrite) {	/* delete old stuff */
			t = point;
			force_to_column(stopcol);
			delete(t, point);
		}
		insert_to_column(current_column(), startcol);
		bufnum = src;
		raw_xfer(dest, from, to);
		bufnum = dest;
		if (curchar() != '\n')
			insert_to_column(current_column(), stopcol);
		mark = point;		/* leave mark at end of rect */
		if (!nl_forward())
			insert('\n');
		bufnum = src;
	}
}

// Don't reindent when yanking in the middle of a line, or when
// text is very large.

do_reindent_after_yank()
{
	int tmp, orig = bufnum, from, to, stuff_before, max;
	jmp_buf this_level;

	max = get_mode_variable("reindent_after_%s_yank");
	if (got_bad_number)
		max = reindent_after_yank;
	if (!max || max > 0 && point - mark > max)
		return;	// Text is too large.
	stuff_before = matches_at(mark, -1, "^.*[^ \n\t].*") > 0;
	if (lines_between(mark, point, 0) < 1) {
		if (parse_string(1, "[ \t]*[^ \t\n]"))
			return;
		if (stuff_before)	// Other stuff on the line, don't reindent.
			return;
	}
	save_var narrow_start = 0, narrow_end = 0;
	if (reindent_c_comments == 1)
		save_var reindent_c_comments = 0;
	if (reindent_one_line_c_comments == 1)
		save_var reindent_one_line_c_comments = 0;
	prev_cmd = 0;
	from = mark;	// Make a copy of the buffer and do indenting
	to = point;		// there, so undo records just one operation.
	tmp = tmp_buf();	// (Yank-pop requires undo.)
	buf_xfer(tmp, 0, size());
	bufnum = tmp;
	mark = from;
	point = to;
	safe_copy_buffer_variables(tmp, orig);	// Duplicate bufvars into tmp.
	save_var top_level = &this_level;
	if (!setjmp(top_level)) {
		spot end = alloc_spot(1);
		save_var iter = 1, has_arg = 0;
		if (stuff_before) {		// Don't indent the first line; 
			exchange_point_and_mark();	// there was already an indent.
			nl_forward();
			exchange_point_and_mark();
		}
		indent_region();
		if (!buffers_identical(orig, tmp)) {
			fix_region();
			if (stuff_before)	// Indent-region can expand the region.
				point = from;
			else
				from = point;
			to = size() - *end;
			delete(0, point);	// Discard all but the region.
			delete(*end, size());
			bufnum = orig;
			delete(from, size() - to);
			grab_buffer(tmp);
			_oldfrom = mark;
			_oldto = point;		/* end of yank */
		}
	}					// User aborted, just clean up.
	bufnum = orig;
	buf_delete(tmp);
}

command delete_blank_lines() on cx_tab[CTRL('O')]
{
	int num = 0, c;
	int start;

	check_modify(bufnum);
	re_search(-1, "[ \t\n]*");	/* go to start of this whitespace */
	if (point)			/* skip prev line */
		point += parse_string(1, "[ \t]*\n", NULL);
	start = point;
	while (point < size()) {	/* count lines in whitespace */
		if ((c = curchar()) == '\n')
			num++;
		else if (c != ' ' && c != '\t')
			break;
		point++;
	}
	re_search(-1, "[ \t]*");	/* skip indentation of last line */
	if (num)
		delete(start, point);
	if (!has_arg)			/* with no argument, */
		iter = (num > 1);   /* 1 or 0 blank lines => 0, more => 1 */
	while (iter-- > 0)		/* insert (iter) newlines */
		insert('\n');
	point = start;
}

/* delete spaces and tabs adjacent to point on current line */
command delete_horizontal_space() on reg_tab[ALT('\\')]
{
	check_modify(bufnum);
	re_search(-1, "[ \t]*");		/* to beginning of area */
	delete(point, point + parse_string(1, "[ \t]*", (char *) 0));
}

get_alnum()	/* wait until user presses a letter or digit */
{
	do {
		getkey();
		check_abort();
	} while (!isalnum(key));
	key = toupper(key);
}

command copy_to_scratch() on cx_tab['x']
{
	char buf[80];

	mention("Save region in scratch buffer [A-Z, 0-9]: ");
	get_alnum();
	fix_region();
	sprintf(buf, "-temp-buf-%c", key);
	zap(buf);
	if (region_type() == REGRECT)
		extract_rectangle(name_to_bufnum(buf), 0);
	else
		xfer(buf, point, mark);
	say("");
	highlight_off();
}

command insert_scratch() on cx_tab['y']
{
	char buf[80];
	int orig = bufnum;

	mention("Restore from scratch buffer [A-Z, 0-9]: ");
	get_alnum();
	sprintf(buf, "-temp-buf-%c", key);
	if (!exist(buf))
		error("Scratch buffer %c is not in use", key);
	delete_if_highlighted();
	mark = point;
	bufname = buf;
	set_region_type(REGNORM);
	buf_xfer(orig, 0, size());
	bufnum = orig;
	say("");
}

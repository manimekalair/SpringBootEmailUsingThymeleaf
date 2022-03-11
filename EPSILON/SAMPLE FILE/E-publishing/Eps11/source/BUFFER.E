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

// This file has miscellaneous commands that deal with buffers.

#include "eel.h"
#include "proc.h"
#include "epsnet.h"
#include "bufed.h"

command change_modified() on reg_tab[ALT('~')]
{
	modified = has_arg? (iter != 0) : !modified;
	if (!modified)
		undo_set_flag(UNDO_UNMODIFIED);
	iter = 0;
}

command change_read_only() on cx_tab[CTRL('Q')]
{
	set_read_only(has_arg? (iter != 0) : !_buf_readonly);
	iter = 0;
}

set_read_only(val)
{
	_buf_readonly = val;
	if (_buf_readonly)
		call_on_modify = 1;
	make_mode();
}

on_modify()	/* called when you try to modify a buffer with */
{ /* call-on-modify set.  if it returns, buffer will be modified anyway */
	if (buffer_on_modify)
		(*buffer_on_modify)();
	else
		normal_on_modify();
}

// The usual action for call_on_modify buffers.  Replacements
// via buffer_on_modify may wish to call this.
normal_on_modify()
{
	int paging = (_buf_readonly == 3 || _buf_readonly && readonly_pages);

	if (_doing_input != DI_SEARCH)
		highlight_off();
	if (paging && key == ' ' && last_index == normal_character) {
		next_page();
		quick_abort();
	} else if (paging && (key == '\b' || key == GREYBACK)
			   && last_index == backward_delete_character) {
		previous_page();
		quick_abort();
	} else if (_buf_readonly)
		error("Buffer is read-only.");
	call_on_modify = 0;	/* don't call us next time */
	if (virtual_space && bufnum == window_bufnum)
		virtual_to_real_column();
}

virtual_to_real_column()	/* if we're in a virtual column, try to */
{				/* convert characters so we're really there */
	int col;

	if ((col = cursor_to_column) >= 0) {
		cursor_to_column = -1;
		force_to_column(col);
	}
}

// Build unique buffer name from file name for find-file.

make_bname(fname, bname)
char *fname, *bname;
{
	do_make_bname(fname, bname, NULL);
}

// Build buffer name from file name.
// Must not match any existing buffer (except dup_ok, if non-null).

do_make_bname(char *fname, char *bname, char *dup_ok)
{
	int uniq = 1, ok;
	char *to, *oldbuf;

	strcpy(bname, get_tail(fname, 0));
	if ((filename_rules(fname) & FSYS_CASE_MASK) != FSYS_CASE_SENSITIVE)
		for (to = bname; *to; to++)
			*to = tolower(*to);
	to = bname + strlen(bname);
	while (exist(bname) && (!dup_ok || strcmp(bname, dup_ok))) {
		oldbuf = bufname;
		bufname = bname;
		ok = (size() == 0);
		bufname = oldbuf;
		if (ok) return;
		sprintf(to, "<%d>", uniq++);
	}
}

unique_file_ids_match(int a[3], int b[3])
{
	return a[0] && b[0] && a[1] == b[1] && a[2] == b[2];
}

look_file(fname)	/* is there a buffer with this file? */
char *fname;		/* if so, switch to it */
{
	int i, orig = bufnum;
	int new_file_id[3];

	unique_filename_identifier(fname, new_file_id);
	if (!fnamecmp(filename, fname) && force_save_as != FSA_NEWFILE)
		return 1;	/* already in it */
	if (unique_file_ids_match(new_file_id, unique_file_identifier))
		return 1;
	i = buf_list(0, 2);	/* start with most recently created buf */
	do {
		bufnum = i;
		if (!fnamecmp(filename, fname) && force_save_as != FSA_NEWFILE)
			return 1;
		if (unique_file_ids_match(new_file_id, unique_file_identifier))
			return 1;
	} while (i = buf_list(-1, 1));
	bufnum = orig;
	return 0;
}

fnamecmp(f1, f2) /* compare two file names like strcmp, maybe folding */
char *f1, *f2;
{
	save_var case_fold = 1;
	if ((filename_rules(f1) & FSYS_CASE_MASK) == FSYS_CASE_SENSITIVE)
		return strcmp(f1, f2);
	else
		return strfcmp(f1, f2);
}

command count_lines() on cx_tab['l']
{
	int count, here, disksize, reg_lines;

	noteput("Counting...");
	here = lines_between(0, point, 1);
	check_abort();
	noteput("Counting... point on line %d...", here + 1);
	count = here + lines_between(point, size(), 1);
	check_abort();
	disksize = size();
	if (translation_type == FILETYPE_MSDOS)
		disksize += count;
	if (file_io_converter == unicode_file_converter)
		disksize *= 2;
	if (size() && character(size() - 1) != '\n')
		count++;
	save_var point, mark;
	fix_region();
	if (is_highlight_on()) {
		reg_lines = lines_between(point, mark, 1);
		if (mark > point && character(mark - 1) != '\n')
			reg_lines++;
		say("%d line%s, %d in region, point on line %d.  %d bytes on disk.",
			  count, count == 1 ? "" : "s", reg_lines, here + 1, disksize);
	} else
		say("%d line%s, point on line %d.  %d bytes on disk.",
			  count, count == 1 ? "" : "s", here + 1, disksize);
	expire_message = 1;
	iter = 0;
}

#define UTF8_CONTIN(b)	(((b) & 0xc0) == 0x80)	/* additional UTF-8 byte? */

add_utf8_char_info(char *msg)
{
	int from, to, val, tmp, ok;

	if (!matches_at(0, 1, "\xef\xbb\xbf")
		  && (file_io_converter != unicode_file_converter
			  || (unicode_format & CONV_LATIN1)))
		return;
	from = point;
	to = point + 1;
	while (UTF8_CONTIN(character(from)) && from > narrow_start)
		from--;
	while (UTF8_CONTIN(character(to)) && to < size() - narrow_end)
		to++;
	tmp = tmp_buf();
	buf_printf(tmp, "\xef\xbb\xbf");
	buf_xfer(tmp, from, to);
	ok = perform_conversion(tmp, CONV_TO_16 | CONV_OMIT_BOM) == -1;
	if (buf_size(tmp) != 2)
		ok = 0;
	buf_grab_bytes(tmp, 0, 2, &val);
	buf_delete(tmp);
	if (ok) {
		sprintf(msg, ", U+%04x", val);
		if (point != from)
			sprintf(msg + strlen(msg), " at %d", from);
	}
}

command show_point() on cx_tab['=']
{
	char msg[130], c;

	if (point < size()) {
		sprintf(msg, "Column %d, char %d of %d is ", virtual_column(),
				point, size());
		if (c = curchar())
			sprintf(msg + strlen(msg),
				"'%c'=%d decimal=%02x hex", c, c, c);
		else
			sprintf(msg + strlen(msg), "'\\0'");
		add_utf8_char_info(msg + strlen(msg));
	} else
		sprintf(msg, "Column %d, at end of %d chars",
				virtual_column(), size());
	say("%s", msg);
	expire_message = 1;
	iter = 0;
}

grab_buffer(buf)	/* insert buffer buf into this buffer */
{
	int cur = bufnum;

	bufnum = buf;
	buf_xfer(cur, 0, size());
	bufnum = cur;
}

grab_full_line(b, str)	/* put current line (not incl newline) in string */
char *str;		/* don't change point */
{
	int begin;

	save_var bufnum = b;
	save_var point;
	to_begin_line();
	begin = point;
	to_end_line();
	grab(begin, point, str);
	return point - begin;
}

grab_line(b, s)	/* read next line of input from buffer b into string s */
char *s;	/* & move past it */
{		/* remove any \n from end of line, & return length */
	int opt, found;
	save_var bufnum = b;

	opt = point;
	found = nl_forward();
	grab(opt, point - found, s);
	return point - found - opt;
}

grab_numbers(b, nums)		/* read next line of input & break up into */
int *nums;			/* numbers, returning # found */
{
	char line[150], *p = line;
	int count = 0;

	grab_line(b, line);
	for (;;) {
		while (isspace(*p))
			p++;
		if (!*p)
			break;
		nums[count++] = numtoi(p);
		while (*p && !isspace(*p))
			p++;
	}
	return count;
}

grab_string(b, s, endmark)	/* read from b until endmark, put in s */
char *s, *endmark;		/* return 1 if found, else 0 & clear s */
{
	int opt, res;
	save_var bufnum = b;
	
	opt = point;
	if (res = search(1, endmark))
		grab(opt, matchstart, s);
	else
		*s = 0;
	return res;
}

/* Read from buffer b until endmark, and put in the variable *s. */
/* Return 1 if found, else 0 & set *s to "".  If s is null, or not big
 * enough to hold the string, resize it. */
int grab_string_expanding(int b, char **s, char *endmark, int minlen)
{
	int opt, res, len;
	save_var bufnum = b;

	opt = point;
	res = search(1, endmark);
	len = MAX(point - opt + 1, minlen);
	*s = realloc(*s, len);
	if (res)
		grab(opt, matchstart, *s);
	else
		**s = 0;
	return res;
}

// Grab buffer text in this range and copy into *str.  Expand *str as
// needed, giving it a minimum length of minlen.
grab_expanding(int from, int to, char **str, int minlen)
{
	int len = MAX(ABS(to - from) + 1, minlen);

	*str = realloc(*str, len);
	grab(from, to, *str);
}

buf_grab_bytes(int buf, int from, int to, char *dest)
{
	save_var bufnum = buf;
	grab(from, to, dest);
}

// Find the longest prefix common to all lines in this buffer after point.
find_buffer_prefix(int buf, char *prefix)
{
	char next[FNAMELEN];
	int i;

	save_var bufnum = buf;
	grab_line(buf, prefix);
	while (grab_line(buf, next)) {
		for (i = 0; prefix[i]; i++)
			if (prefix[i] != next[i])
				break;
		prefix[i] = 0;
	}
}

// Find the longest prefix common to all lines in this buffer after point.
// Maybe fold case.
find_buffer_prefix_folding(int buf, char *prefix, int fold)
{
	char next[FNAMELEN];
	int i;

	save_var bufnum = buf;
	grab_line(buf, prefix);
	while (grab_line(buf, next)) {
		for (i = 0; prefix[i]; i++)
			if (fold ? charfcmp(prefix[i], next[i]) : (prefix[i] != next[i]))
				break;
		prefix[i] = 0;
	}
}

// Take the lines in the specified buffer and arrange them into columns
// so they fit in the specified width.  Leave a margin between the
// columns.  Position to start of buffer.

columnize_buffer_text(int buf, int width, int margin)
{
	int i, w = 0, cols;

	save_var bufnum = buf;
	point = size();
	do {				// Find widest entry.
		i = current_column();
		if (i > w)
			w = i;
	} while (nl_reverse());
	w += margin;			// Make extra room.
	cols = width / w;		// Make this many columns of width w.
	point = 0;
	do {
		for (i = 1; i < cols; i++) {
			if (!nl_forward())
				break;
			delete(point - 1, point);	// Discard the newline.
			to_column(i * w);
		}
	} while (nl_forward());
	if (character(point - 1) != '\n')
		insert('\n');
	point = 0;
}

// See if text at pos matches pattern.
matches_at(int pos, int dir, char *pat)
{
	save_var point = pos;
	return parse_string(dir, pat);
}

buffers_identical(a, b)		// do buffers a and b have the same text?
{
	int i;
	if (!a || !b)			// one or both buffers don't exist
		return !a == !b;	// if both don't, they're "same"
	save_var bufnum = a;
	i = size();
	bufnum = b;
	if (i != size())		// different sizes => mismatch
		return 0;
	return compare_buffer_text(a, 0, b, 0, 0) == size();
}				// were all the characters the same?

buffer_size(char *buf)
{
	save_var bufname = buf;
	return size();
}

buf_size(int buf)
{
	save_var bufnum = buf;
	return size();
}

count_lines_in_buf(int buf, int abortok)
{
	save_var bufnum = buf;
	return lines_between(0, size(), abortok);
}

get_buf_point(int buf)
{
	save_var bufnum = buf;
	return point;
}

set_buf_point(int buf, int val)
{
	save_var bufnum = buf;
	point = val;
}

command widen_buffer()
{
	narrow_start = narrow_end = 0;
	make_mode();
}

command narrow_to_region()
{
	fix_region();
	narrow_start = point;
	narrow_end = size() - mark;
	highlight_off();
	make_mode();
}

narrow_position(p)		/* return p, adjusting to be inside */
{				/* any narrowed region */
	save_var point = p;
	return point;
}

command rename_buffer()
{
	char bfname[FNAMELEN];

	get_buf(bfname, "Rename buffer to", "");
	if (*bfname)
		change_buffer_name(bfname);
	make_mode();
}

/* Act like C-x b using supplied prompt */
ask_which_buffer(pr)
char *pr;
{
	char bfname[FNAMELEN];
	int prev = give_prev_buf();

	get_buf(bfname, pr, prev ? bufnum_to_name(prev) : "");
	if (!*bfname)
		return;
	to_buffer(bfname);
}

command select_buffer() on cx_tab['b']
{
	tiled_only();
	ask_which_buffer("Buffer name");
	iter = 1;
}

command kill_buffer() on cx_tab['k']
{
	char bname[FNAMELEN];

	tiled_only();
	save_var show_mouse_choices = 1;
	get_buf(bname, "Buffer to delete", bufname);
	drop_buffer(bname);
}

command kill_current_buffer() on cx_tab[CTRL('K')]
{
	tiled_only();
	drop_buffer(bufname);
}

command kill_all_buffers()	// kill all user-visible buffers
{
	int count = 0;
	char *oldbuf;

	tiled_only();
	buffer_list(1);         // Count the buffers.
	do {
		count++;
	} while (buffer_list(0));

	while (count-- >= 0) {
		if (is_process_buffer(bufnum)) {
			next_buffer();
			continue;
		}
		oldbuf = bufname;
		if (modified && *filename && size() && !is_dired_buf()
			&& !discardable_buffer) {
			if (!check_drop_buffer(bufname))	// Ask user if ok to drop.
				return;
		} else
			to_another_buffer(bufname);
		delete_user_buffer(oldbuf);
	}
}

drop_buffer(bname)	/* delete a buffer, asking user if questionable */
char *bname;		/* return 1 if done, 0 if user said don't */
{
	if (!check_drop_buffer(bname))
		return 0;
	delete_user_buffer(bname);
	return 1;
}

delete_user_buffer(bname)	/* delete a buffer that might have coloring */
char *bname;
{
	if (!exist(bname))
		return;
	drop_coloring(name_to_bufnum(bname));
	highlight_off();
	delete_buffer(bname);
}

// Make sure the specified buffer is not the current one (we want to delete it).
to_another_buffer(char *buf)
{
	int newbuf;

	if (!strcmp(buf, bufname)) {
		if (newbuf = give_prev_buf())
			to_buffer_num(newbuf);
		else
			make_newfile_buf();
	}
}

check_drop_buffer(bname) /* check if buffer can be deleted safely */
char *bname;		/* ask user if questionable */
{			/* return 1 if done, 0 if user said don't */
	char msg[80], *origbuf = bufname;
	int mod;

	if (!exist(bname))
		error("No buffer %s.", bname);
	if (another_process() && is_process_buffer(name_to_bufnum(bname))) {
		exit_this_process(bname);
		if (is_process_buffer(name_to_bufnum(bname)))
			error("A process is running in buffer %s.", bname);
	}
	bufname = bname;
	mod = modified && size() > 0 && !discardable_buffer;
	if (ftp_job && ftp_job->buf == bufnum
		&& ftp_job->operation == FTP_SEND)
		mod = 1;
	if (!strcmp(bname, MSG_BUFFER))
		mod = 0;
	bufname = origbuf;
	if (!another_process() && !strcmp(bname, PROCBUF))
		mod = 0;
	if (mod) {
		sprintf(msg, "Buffer %.40s not saved.  Delete it? ", bname);
 		if (!ask_yn("Delete buffer", msg, "&Delete", "&Cancel", 2))
			return 0;
	}
	to_another_buffer(bname);
	return 1;
}


to_buffer(buf)		/* switch window to buffer, check file date */
char *buf;		/* create buffer if necessary */
{
	switch_to_buffer(create(buf));
	highlight_off();
	switching_to_buffer();
	check_dates(0);
}

to_buffer_num(num)	/* switch window to buffer by number */
{
	switch_to_buffer(num);
	switching_to_buffer();
	check_dates(0);
}

switch_to_buffer(num)	/* switch without checking date */
{
	int i;

	if (num != window_bufnum) {
		for (i = 0; i < _prev_num; i++)
			if (_prev_old_buffers[i] == window_bufnum)
				prev_forget(i);
		if (_prev_num >= MAXOLDBUFS)
			prev_forget(0);		/* no room, forget oldest */
		_prev_old_buffers[_prev_num++] = _prev_buffer = window_bufnum;
	}
	window_bufnum = num;
}

// Return the most recently accessed user buffer, ignoring buffers
// accessed at or after "time" t.  T is a buf_accessed_clock value,
// incremented each time a window switches to a buffer.

newest_before(t)
{
	int i, newest_time = 0, newest = 0;

	save_var bufnum;
	i = buf_list(0, 2);	/* start with most recently created buf */
	do {
		bufnum = i;
		if (buf_accessed >= t || *bufname == '-')
			continue;
		if (!newest || buf_accessed > newest_time) {
			newest_time = buf_accessed;
			newest = i;
		}
	} while (i = buf_list(-1, 1));
	return newest;
}

prev_forget(i)	/* forget old buffer # at index i */
{
	int j;

	for (j = i; j < _prev_num - 1; j++)
		_prev_old_buffers[j] = _prev_old_buffers[j + 1];
	_prev_num--;
}

get_buf_accessed(i)
{
	save_var bufnum = i;
	return buf_accessed;
}

give_prev_buf()		/* return buf # of previous buffer, or 0 if none */
{
	int i, j;

	if (_prev_buffer != bufnum && buf_exist(_prev_buffer))
		return _prev_buffer;
	for (i = _prev_num; --i >= 0; ) {	/* start with oldest at end */
		j = _prev_old_buffers[i];
		if (buf_exist(j) && j != bufnum && buf_in_window(j) < 0)
			return j;
	}
	for (i = buf_accessed_clock; j = newest_before(i);
		 i = get_buf_accessed(j))
		if (j != bufnum)
			return j;
	return 0;
}

// The buf_accessed variable lets us determine the most recently used buffer.
// Reassign values sequentially to all buffers.
// Just after this function, the N most recent buffers will be determinable
// by comparing their buf_accessed values to buf_accessed_clock.

minimize_buf_accessed()
{
	int i, tmp = tmp_buf();
	int nums[2];

	save_var bufnum, abort_searching = 0;
	i = buf_list(0, 2);
	do {
		bufnum = i;
		if (buf_accessed)
			buf_printf(tmp, "%07d %d\n", buf_accessed, i);
	} while (i = buf_list(-1, 1));
	if (buf_accessed_clock <= buf_accessed)
		buf_accessed_clock = buf_accessed + 1;
	bufnum = tmp;
	do_sort_region(0, size(), 0, 0);
	point = 0;
	buf_accessed_clock = 1;
	while (grab_numbers(tmp, nums) == 2) {
		bufnum = nums[1];
		buf_accessed = buf_accessed_clock++;
	}
	restore_vars();
	buf_delete(tmp);
}

// Copy this buffer's characters in the specified range to buffer num.
// Also copy character coloring.

buf_xfer_colors(num, from, to)
{
	int orig = bufnum, pos, color, colstart, colend;

	if (to < from)
		{ pos = from; from = to; to = pos; }
	buf_xfer(num, from, to);
	for (pos = from; pos < to;) {
		color = get_character_color(pos, &colstart, &colend);
		bufnum = num;
		if (colstart < from)	// Only change the part we just copied.
			colstart = from;
		if (colend > to)
			colend = to;
		set_character_color(mark + colstart - from,
							mark + colend - from, color);
		bufnum = orig;
		pos = colend;
	}
}

xfer(buf, from, to)
char *buf;
{
	buf_xfer(name_to_bufnum(buf), from, to);
}

buf_xfer(num, from, to)		/* copy from..to in current buffer to */
{				/* buffer num, setting mark before it */
	int orig = bufnum;

	bufnum = num;
	do_set_mark(point);
	set_region_type(REGNORM);
	bufnum = orig;
	raw_xfer(num, from, to);	/* insert at point */
}

command next_buffer() on reg_tab[FKEY(12)], cx_tab['>']
{
	n_or_p_buf(1);
}

command previous_buffer() on reg_tab[FKEY(11)], cx_tab['<']
{
	n_or_p_buf(0);
}

char *get_int_buf(start)	/* return name of "interesting" buffer */
{
	char *p;

	do {
		p = buffer_list(start);
		start = 0;
	} while (p && (*p == '-' || *p == '#'));
	return p;
}

n_or_p_buf(next)
{
	char *prev = 0, *s;

	tiled_only();
	s = get_int_buf(1);
	do {
		if (bufname == s)
			break;
		prev = s;
	} while (s = get_int_buf(0));
	if (next)
		s = get_int_buf(0);
	else if (prev)
		s = prev;
	else
		do {
			s = prev;
		} while (prev = get_int_buf(0));
	if (!s)
		s = get_int_buf(1);
	if (!s)
		s = buffer_list(1);
	to_buffer(s);
}

// Display a window with a list of buffers.  Keep it there as long as
// Ctrl is down, and move around in it in response to Ctrl-Tab and
// Shift-Ctrl-Tab.  When the user releases Ctrl, go to the selected
// buffer.  This command needs to be bound to a Ctrl key to work well.

command switch_buffers() on reg_tab[NUMCTRL(GREYTAB)]
{
	if (shift_pressed() & KB_CTRL_DN)
		do_switch_buffers(key);
	// If we can't detect Ctrl in this environment, do some simpler
	// thing: just switch to the most recent buffer.  This can also
	// happen if the user releases Ctrl very quickly.
	else if (shift_pressed() & KB_SHIFT_DN)
		previous_buffer();
	else
		next_buffer();
}

do_switch_buffers(int orig_key)
{
	char bname[FNAMELEN];
	int other_key = -1;

	// If the key that invoked us is a function key, numpad or cursor
	// pad, or "gray key", find its shifted equivalent and look for that
	// also.  Usually Shift+orig key will give us the original key code,
	// if the original included Ctrl, but sometimes it might give us a
	// different one.
	if (!IS_EXT_ASCII_KEY(orig_key) && IS_TRUE_KEY(orig_key))
		other_key = NUMSHIFT(NUMPLAIN(orig_key));
	error_if_input(1);
	tiled_only();
	do_bufed(BUFED_SWITCH | (has_arg ? BUFED_ALL : 0));
	move_in_switch_buffers(shift_pressed() & KB_SHIFT_DN);
	while ((shift_pressed() & KB_CTRL_DN)) {
		maybe_refresh();
		if (char_avail()) {
			getkey();
			if (key == GETFOCUS || key == LOSEFOCUS) {
				do_topkey();
				continue;
			} else if (key == orig_key || key == other_key)
				move_in_switch_buffers(shift_pressed() & KB_SHIFT_DN);
			else if (binding_of(key, root_keys) == (short) down_line)
				move_in_switch_buffers(0);
			else if (binding_of(key, root_keys) == (short) up_line)
				move_in_switch_buffers(1);
		} else
			delay(10, COND_KEY | COND_RETURN_ABORT);
		if (user_abort || key == abort_key || key == ESC
			  || key == NUMCTRL(GREYESC)) {
			while (char_avail())	// Discard keys so we don't get a delayed
				getkey();			// Canceled msg.
			user_abort = 0;
			remove_bufed();
			return;
		}
	}
	if (!bufed_getname(bname))
		*bname = 0;
	remove_bufed();
	if (*bname && exist(bname))
		to_buffer(bname);
}

// Move up or down in the list of buffers, wrapping at the ends.
move_in_switch_buffers(int up)
{
	if (up) {
		if (!nl_reverse())
			point = size();
	} else {
		if (!nl_forward() || point == size())
			point = 0;
	}
	move_to_column(BNAME_COL);
}

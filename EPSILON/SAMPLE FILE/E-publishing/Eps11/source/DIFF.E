/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1988, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

// This file compares windows line-by-line.

#include "eel.h"
#include "diff.h"
#include "colcode.h"

command diff()
{
	diff_style(0);
}

command merge_diff()
{
	char var[FNAMELEN];
	int obuf = bufnum;

	tiled_only();
	if (number_of_user_windows() < 2)
		error("Only one window");
	get_strdef(var, "Merge using an #ifdef variable named", merge_diff_var);
	if (!*var)
		return;
	strcpy(merge_diff_var, var);
	diff_style(MERGE_DIFF_STYLE);
	safe_copy_buffer_variables(bufnum, obuf);
}

visual_diff_mode()
{
	mode_keys = visual_diff_tab;
	major_mode = _visual_diff_mode_name;
	make_mode();
}

command visual_diff()
{
	diff_style(VISUAL_DIFF_STYLE);
	visual_diff_mode();
}

move_to_difference(int rev)
{
	int new, old;

	if (rev)
		nl_reverse();
	to_begin_line();
	old = get_character_color(point, NULL, NULL);
	if (old != color_class diff_removed && old != color_class diff_added)
		old = color_class text;
	new = old;
	while (new == old && (rev ? nl_reverse() : nl_forward())) {
		check_abort();
		to_begin_line();
		get_character_color(point, NULL, NULL);
		new = get_character_color(point, NULL, NULL);
		if (new != color_class diff_removed && new != color_class diff_added)
			new = color_class text;
	}
	if (rev && point > 0)
		nl_forward();
}

command next_difference() on visual_diff_tab[ALT(']')],
							 visual_diff_tab[NUMALT(KEYDOWN)],
							 visual_diff_tab[NUMALT(NUMDIGIT(2))]
{
	move_to_difference(0);
}

command previous_difference() on visual_diff_tab[ALT('[')],
								 visual_diff_tab[NUMALT(KEYUP)],
								 visual_diff_tab[NUMALT(NUMDIGIT(8))]
{
	move_to_difference(1);
}

diff_style(int style)
{
	char newbuf[FNAMELEN];

	tiled_only();
	if (number_of_user_windows() < 2)
		error("Only one window");
	get_buf(newbuf, "List differences to buffer", "diff");
	do_diff(newbuf, style);
	locate_window(newbuf, "");
	discardable_buffer = 1;
	point = 0;
}

do_diff(char *buf, int style)
{
	int start, other, osize;

	strcpy(_diff_buffer, buf);
	zap(_diff_buffer);
	drop_coloring(name_to_bufnum(_diff_buffer));
	highlight_off();
	save_var point;
	next_user_window(1);
	other = bufnum;
	osize = size();
	save_var point;
	next_user_window(-1);
	if ((has_feature & FEAT_LCS_PRIMITIVES)
		  && size() <= diff_precise_limit && osize <= diff_precise_limit) {
		diff_via_lcs(bufnum, other, style);
		return;
	}

	diff_check_malloc();	/* see if we need to make room for data */
	_diff_line1 = _diff_line2 = 1;
	set_points(0, 0);
	do {
		start = point;
		diff_same();	// Found identical lines.
		note_same(bufnum, start, point, style);
	} while (resync_lines(style));
	say("Done.");
}

diff_same()		/* advance both windows while lines match */
{
	int i1, i2, i, j;
	char buf1[MAXONE], buf2[MAXONE];

	for (;;) {
		i1 = point;
		nl_forward();
		if (i = (point > i1 + MAXONE - 1)) /* if too big, */
			point = i1 + MAXONE - 1;   /* break into pieces */
		grab(i1, point, buf1);
		next_user_window(1);
		i2 = point;
		nl_forward();
		if (j = (point > i2 + MAXONE - 1))
			point = i2 + MAXONE - 1;
		grab(i2, point, buf2);
		next_user_window(-1);	/* buf1 has i1..point chars */
		if (i != j || point == i1)
			break;	/* either mismatch, or hit end of both */ 
		else if (strlen(buf1) == point - i1)
			j = strfcmp(buf1, buf2); /* no nulls, do fast */
		else			/* must compare char-by-char */
			for (j = point - i1; j > 0; j--)
				if (charfcmp(buf1[j - 1], buf2[j - 1]))
					break;
		if (j)			/* mismatch */
			break;
		else if (!i) {
			++_diff_line1, ++_diff_line2;
			if (_diff_line1 % 100 == 0)
				noteput("Lines %d and %d match...",
						_diff_line1, _diff_line2);
		}
		check_abort();
	}
	set_points(i1, i2);	/* go to start of mismatched lines */
}

diff_check_malloc()	/* see if we need to make room in arrays */
{
	int newsize = (diff_mismatch_lines + diff_match_lines) * sizeof(int);
	int local;

	_diff_data.local = local = (newsize <= (MAXLINES * sizeof(int)));
	if (_diff_data.start1 && (newsize > _diff_data.size || local)) {
		free(_diff_data.start1);	/* if already exists, and */
		free(_diff_data.end1);		/* it's either too small, */
		free(_diff_data.start2);	/* or not needed, free it */
		free(_diff_data.end2);
	}	
	if (!local && (newsize > _diff_data.size || !_diff_data.start1)) {
		_diff_data.start1 = (int *) malloc(newsize);
		_diff_data.end1 = (int *) malloc(newsize);
		_diff_data.start2 = (int *) malloc(newsize);
		_diff_data.end2 = (int *) malloc(newsize);
	}
	_diff_data.size = newsize;
}

/* Attempt to resynchronize, give error if we couldn't. */
/* Return 0 when both have reached end. */

resync_lines(style)
{
	int i, reach, t, orig, other;
	int *start1, *end1, *start2, *end2;	/* ranges of lines */
	int loc_start1[MAXLINES], loc_end1[MAXLINES];	/* local versions */
	int loc_start2[MAXLINES], loc_end2[MAXLINES];

	orig = bufnum;
	next_user_window(1);
	other = bufnum;
	next_user_window(-1);
	if (_diff_data.local) {
		start1 = loc_start1, end1 = loc_end1;
		start2 = loc_start2, end2 = loc_end2;
	} else {	/* must use already-allocated globals from struct */
		start1 = _diff_data.start1, end1 = _diff_data.end1;
		start2 = _diff_data.start2, end2 = _diff_data.end2;
	}
	for (reach = 0; reach < diff_mismatch_lines; reach++) {
		start1[reach] = point;		/* get info on next range */
		end1[reach] = extent_end();	/* of lines */
		next_user_window(1);
		start2[reach] = point;
		end2[reach] = extent_end();
		next_user_window(-1);
		for (i = 0; i <= reach; i++) {
			if (line_matches(start1[reach], end1[reach],
						start2[i], end2[i]))
				t = reach, reach = i, i = t;	/* swap */
			else if (!line_matches(start1[i], end1[i],
						start2[reach], end2[reach]))
				continue;
			set_points(start1[i], start2[reach]);
			if (!i && !reach)	/* found a match */
				return 0;
			note_change(orig, start1[0], start1[i], _diff_line1, i,
						other, start2[0], start2[reach], _diff_line2, reach,
						style);
			_diff_line1 += i;
			_diff_line2 += reach;
			return 1;
		}
		if (reach > 10) {
			noteput("Searching...%d", reach);
			check_abort();
		}
	}
	set_points(start1[0], start2[0]);
	note_error(_diff_line1, _diff_line2);
}

extent_end()	/* return start of the line diff_match_lines lines after */
{		/* point, and go to start of next line after point */
	int second, i, final;

	nl_forward();
	second = point;
	for (i = diff_match_lines - 1; i > 0; i--)
		if (!nl_forward())
			break;
	final = point;
	point = second;
	return final;
}

line_matches(pos1, end1, pos2, end2)
{
	int orig1, orig2, i, len1 = end1 - pos1, len2 = end2 - pos2;
	char buf1[MAXMANY], buf2[MAXMANY];

	if (len1 != len2)
		return 0;
	if (i = (len1 < MAXMANY - 1)) {		/* fits in buf1? */
		grab(pos1, end1, buf1);
		next_user_window(1);
		if (i = (len2 < MAXMANY - 1))	/* and buf2? */
			grab(pos2, end2, buf2);
		next_user_window(-1);
	}
	if (i)				/* yes, they fit */
		return memfcmp(buf1, buf2, len1) == 0;
	orig1 = point, point = pos1;
	next_user_window(1);
	orig2 = point, point = pos2;
	next_user_window(-1);
	do_compare_windows();		/* if compare-windows stops */
	i = (point >= end1);		/* after end1, */
	point = orig1;
	next_user_window(1);
	i = (i && point >= end2);	/* and end2, */
	point = orig2;
	next_user_window(-1);		/* the regions match */
	return i;
}

// Record a difference.
// Chars s1..e1 in buffer b1 (lcount1 lines at lstart1) become chars
// s2..e2 in buffer b2 (lcount2 lines at lstart2).

note_change(b1, s1, e1, lstart1, lcount1,
			b2, s2, e2, lstart2, lcount2, style)
{
	char msg[80], *s;
	int cbuf = 0;

	if (style == VISUAL_DIFF_STYLE) {
		// Maybe compute character-based differences too.
		if (lcount1 && lcount2 && (has_feature & FEAT_LCS_PRIMITIVES)
			  && e1 - s1 < diff_match_characters_limit
				  && e2 - s2 < diff_match_characters_limit)
			lcs_char(b1, s1, e1, b2, s2, e2,
					 bufnum_to_name(cbuf = tmp_buf()));
		if (lcount1)
			visual_diff_copy(color_class diff_removed, "< ", b1, s1, e1, cbuf);
		if (lcount2)
			visual_diff_copy(color_class diff_added, "> ", b2, s2, e2, cbuf);
		if (cbuf)
			buf_delete(cbuf);
		return;
	}
	if (style == MERGE_DIFF_STYLE) {
		merge_note_msg(lcount1 ? "#ifndef %s" : "#ifdef %s");
		if (lcount1)
			visual_diff_copy(-1, "", b1, s1, e1, 0);
		if (lcount1 && lcount2)
			merge_note_msg("#else // %s");
		if (lcount2)
			visual_diff_copy(-1, "", b2, s2, e2, 0);
		merge_note_msg(lcount2 ? "#endif // %s" : "#endif // not %s");
		return;
	}
	s = msg + diff_range(msg, lstart1, lcount1);
	*s++ = !lcount1 ? 'a' : !lcount2 ? 'd' : 'c';
	s += diff_range(s, lstart2, lcount2);
	note_msg(msg);
	if (lcount1)
		visual_diff_copy(0, "< ", b1, s1, e1, 0);
	if (lcount1 && lcount2)
		note_msg("---");
	if (lcount2)
		visual_diff_copy(0, "> ", b2, s2, e2, 0);
}

// This region in the specified buffer is identical to the
// corresponding region in the other buffer, so say so in the diff
// output.

note_same(int buf, int start, int end, int style)
{
	if (start >= end)
		return;
	if (style == VISUAL_DIFF_STYLE)	// Found identical lines.
		visual_diff_copy(0, "  ", buf, start, end, 0);
	else if (style == MERGE_DIFF_STYLE)
		visual_diff_copy(-1, "", buf, start, end, 0);
}

note_msg(s)
char *s;
{
	char *orig = bufname;

	bufname = _diff_buffer;
	stuff(s);
	insert('\n');
	set_character_color(point - (strlen(s) + 1), point, -1);
	bufname = orig;
}

set_points(p1, p2)	/* set points for both windows */
{
	point = p1;
	next_user_window(1);
	point = p2;
	next_user_window(-1);
}

diff_range(s, lstart, count)
char *s;
{
	if (count > 1)
		return sprintf(s, "%d,%d", lstart, lstart + count - 1);
	else
		return sprintf(s, "%d", lstart + count - 1);
}

// Copy text from buffer buf to diff buffer, format & maybe color it.
// Color may be 0 to copy colors, -1 for no coloring, or a color class.
// If cbuf is nonzero, it's a buffer that specifies partial coloring (in
// which case we assume color is a color class, and prefix hints at
// which buffer we're doing now).

visual_diff_copy(color, prefix, buf, start, end, cbuf)
char *prefix;
{
	int tab, pos;

	save_var bufnum = buf;
	if ((!color || cbuf) && want_code_coloring && recolor_range)
		recolor_buffer_range(start, end);		// Color in place, then copy.
	buf_xfer_colors(name_to_bufnum(_diff_buffer), start, end);
	tab = tab_size;
	bufname = _diff_buffer;
	point = pos = size() - (end - start);
	if (color > 0)
		if (cbuf)	// Color based on matching characters.
			selectively_set_color(cbuf, color, *prefix == '>');
		else		// Make it all one color.
			set_character_color(point, size(), color);
	if (*prefix) {		// Untabify copied text.
		tab_size = tab;
		tab_convert(point, size(), 0);
		point = pos;
	}
	if (*prefix) {		// Put this before each line.
		while (re_search(1, "^!(.|\n)")) {
			stuff(prefix);
			set_character_color(point - strlen(prefix), point,
								(color > 0) ? color : -1);
		}
	}
	point = size();
	if (character(point - 1) != '\n')
		insert('\n');	// Buffer didn't end with \n, pretend it did.
}

// Paint sections of the current buffer, from point to the end, with the
// specified color.  The cbuf buffer describes a list of matching
// regions we shouldn't paint, one region per line.  Offset says whether
// to use the first or second value on each line, along with the third
// value (the region size).

selectively_set_color(cbuf, color, offset)
{
	int nums[10], pos = 0, matchcnt = count_lines_in_buf(cbuf, 0);

	set_buf_point(cbuf, 0);
	for (; grab_numbers(cbuf, nums); matchcnt--) {
		if (nums[2] < diff_match_characters && matchcnt > 1)
			continue;	// Ignore small matches, except for the last one.
		if (nums[offset] > pos)
			set_character_color(point + pos, point + nums[offset], color);
		pos = nums[offset] + nums[2];
	}
	set_character_color(point + pos, size(), color);
}

note_error(l1, l2)
{
	char msg[60];

	sprintf(msg, "Couldn't resynchronize at %d and %d...", l1, l2);
	note_msg(msg);
	error("%s", msg);
}

// Put a msg in the diff buffer, replacing %s with merge var name.
merge_note_msg(char *s)
{
	char buf[200];
	sprintf(buf, s, merge_diff_var);
	note_msg(buf);
}

command list_changes()
{
	char before[FNAMELEN], after[FNAMELEN];
	int t1, t2, t3, t4;

	get_file(before, "List changes from", "before");
	bufnum = t1 = tmp_buf();
	if (read_file(before, FILETYPE_MSDOS))
		quick_abort();
	save_var case_fold = 1;
	get_file(after, "To", "after");
	bufnum = t2 = tmp_buf();
	if (read_file(after, FILETYPE_MSDOS))
		quick_abort();
	save_var case_fold = 1;
	noteput("Sorting...");
	do_buffer_sort(bufnum_to_name(t3 = tmp_buf()), 0, 0);
	bufnum = t1;
	do_buffer_sort(bufnum_to_name(t4 = tmp_buf()), 0, 0);
	buf_zap(t2);
	do_compare_sorted(t4, t3, (char *)0, bufnum_to_name(t2), (char *)0);
	to_buffer_num(t2);
	one_window();
	buf_delete(t1);
	buf_delete(t3);
	buf_delete(t4);
	set_buffer_filename("changed");
	file_info.check_type = 0;
	say("These changes were made.");
}

command compare_sorted_windows()
{
	int b2;

	tiled_only();
	if (number_of_user_windows() < 2)
		error("Only one window");
	next_user_window(1), b2 = bufnum, next_user_window(-1);
	do_compare_sorted(bufnum, b2, "only1", "only2", "inboth");
	locate_window("only1", "");
}

/* compare two sorted buffers, copying lines that appear in only
   the first, only the second, or in both to other buffers */

#define MAXONE		200	/* maximum line length to read at once */
#define MSGCOUNT	100	/* say where we are every MSGCOUNT compares */

do_compare_sorted(b1, b2, only1, only2, both)
char *only1, *only2, *both;
{
	char buf[2][MAXONE + 1], *tobuf;
	int need[2], len[2], i[2], j[2], big[2], pt[2], line[2], w;
	int complen, diff, count = 0;

	save_var bufnum;
	if (only1) zap(only1);
	if (only2) zap(only2);
	if (both) zap(both);
	for (w = 0; w < 2; w++) {	/* do init */
		need[w] = 1;
		line[w] = 0;
		bufnum = w ? b2 : b1;
		save_var point = 0;
	}
	do {
		for (w = 0; w < 2; w++) {	/* get next lines */
			if (need[w]) {
				bufnum = w ? b2 : b1;
				i[w] = point;
				nl_forward();
				line[w]++;
				len[w] = (pt[w] = point) - i[w];
				big[w] = (len[w] > MAXONE);
				if (big[w])	/* too big, take 1st part */
					pt[w] = i[w] + MAXONE;
				grab(i[w], pt[w], buf[w]);
				need[w] = 0;
			}
		}
		complen = MIN(len[0], len[1]);
again:		if (complen)
			diff = memfcmp(buf[0], buf[1], MIN(complen, MAXONE));
		else
			diff = len[0] ? -1 : len[1] ? 1 : 0;
		if (diff == 0 && (big[0] || big[1]))	/* equal so far */
			if (big[0] && big[1]) {		/* both too big */
				for (w = 0; w < 2; w++) {	/* get more */
					bufnum = w ? b2 : b1;
					j[w] = point;
					big[w] = (j[w] - pt[w] > MAXONE);
					if (big[w])
						j[w] = pt[w] + MAXONE;
					grab(pt[w], j[w], buf[w]);
					pt[w] = j[w];
					need[w] = 1;
				}
				goto again;	/* till we find diff */
			} else		/* only one was too big */
				diff = big[0];
		if (diff >= 0) {	/* now transfer results */
			tobuf = diff ? only2 : both;
			if (tobuf) {
				bufnum = b2;
				xfer(tobuf, i[1], i[1] + len[1]);
			}
			need[1] = 1;
			if (!diff)
				need[0] = 1;
		} else {
			if (only1) {
				bufnum = b1;
				xfer(only1, i[0], i[0] + len[0]);
			}
			need[0] = 1;
		}
		check_abort();
		if (++count % MSGCOUNT == 0)
			noteput("Comparing lines %d and %d...", line[0], line[1]);
	} while (len[0] > 0 || len[1] > 0);
	say("Done.");
}

// Data on one of the two buffers we're diffing.
struct diff_info {
	int buf;		// The buffer number.
	int line;		// The line number we're working on, counting from 0.
	int pos;		// The buffer position for the start of that line number.
};

// Return the character position for the start of the specified line,
// counting lines from 0.  We maintain info on the last line/pos
// correspondence in the diff_info structure, so we can quickly get to
// a nearby line.  (Right now, we only call this passing increasing
// line numbers.)

lcs_line_to_pos(struct diff_info *b, int line)
{
	int offset = line - b->line;		// How far away is this new line?

	b->line = line;				// Remember the line we'll get to.
	save_var bufnum = b->buf, point = b->pos;
	if (offset >= 0) {
		while (offset-- > 0 && nl_forward())
			;
	} else {
		while (offset++ < 0 && nl_reverse())
			;
		to_begin_line();
	}
	return b->pos = point;	// Remember buffer pos for this line and return it.
}

// Record a difference: The len1 lines in buffer 1 starting at line
// number start1 differed from the len2 lines in buffer 2 starting at
// line number start2.  Put some stuff in the diff buffer saying so.
// Line numbers we receive are 0-based.

lcs_one_difference(struct diff_info *b1, int start1, int len1,
				   struct diff_info *b2, int start2, int len2, int style)
{
	int s1, e1, s2, e2;

	if (!len1 && !len2)
		return;
	s1 = lcs_line_to_pos(b1, start1);	// Get buffer ranges for the two
	e1 = lcs_line_to_pos(b1, start1 + len1);	//  text blocks involved.
	s2 = lcs_line_to_pos(b2, start2);
	e2 = lcs_line_to_pos(b2, start2 + len2);
	note_change(b1->buf, s1, e1, start1 + 1, len1,
				b2->buf, s2, e2, start2 + 1, len2, style);
}

// Record a similarity: a range of lines indentical in the two buffers.
// Since they're identical, we're only told about one of them: a block
// of len lines beginning at the specified line number (0-based).

lcs_one_similarity(struct diff_info *b, int line, int len, int style)
{
	int start = lcs_line_to_pos(b, line);
	int end = lcs_line_to_pos(b, line + len);
	note_same(b->buf, start, end, style);
}

// The buffer lcs lists the matching line ranges, in the format
// buf1line, buf2line, count.  Create diff output from this in the
// specified style.  The buffer line numbers are 0-based.  We also get
// the total number of lines in each buffer.

lcs_produce_diff(int buf1, int len1, int buf2, int len2,
				 int style, char *lcs, int talk)
{
	int start1 = 0, start2 = 0, nums[10];
	struct diff_info b1, b2;

	b1.buf = buf1;
	b2.buf = buf2;
	b1.line = b1.pos = b2.line = b2.pos = 0;

	save_var bufname = lcs;
	point = 0;
	while (grab_numbers(bufnum, nums)) {
		if (nums[2] < diff_match_lines)
			continue;
		lcs_one_difference(&b1, start1, nums[0] - start1,
						   &b2, start2, nums[1] - start2, style);
		start1 = nums[0] + nums[2];
		start2 = nums[1] + nums[2];
		lcs_one_similarity(&b1, nums[0], nums[2], style);
		if (talk)
			noteput("Generating output: %2d%%...", muldiv(point, 100, size()));
	}			// Finally, do the very last difference.
	lcs_one_difference(&b1, start1, len1 - start1,
					   &b2, start2, len2 - start2, style);
}

// Produce diff output in the specified style, comparing these two
// buffers (putting output in the buffer named by _diff_buffer).

diff_via_lcs(int one, int two, int style)
{
	int *one_lines = 0, *two_lines = 0, one_len, two_len, talk;
	char *tmp = temp_buf();

	talk = buf_size(one) + buf_size(two) > 50000;
	if (talk)
		noteput("Comparing...");
	// Compute the lcs info, putting it in into the temp buffer.
	tokenize_lines(one, &one_lines, &one_len,
				   two, &two_lines, &two_len);
	lcs(one_lines, one_len, two_lines, two_len, tmp);
	free(one_lines);
	free(two_lines);

	if (talk)
		noteput("Generating output...");
	lcs_produce_diff(one, one_len, two, two_len, style, tmp, talk);
	delete_buffer(tmp);
	if (talk)
		say("");
}

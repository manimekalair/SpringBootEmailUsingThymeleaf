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

// This file has a command for sorting the lines of a buffer.

#include "eel.h"

command sort_buffer()
{
	do_sort_buffer(0);
}

command reverse_sort_buffer()
{
	do_sort_buffer(1);
}

do_sort_buffer(rev)	/* ask user where to sort, then do it */
{
	char buf[FNAMELEN];

	save_var sort_status = 1;
	get_buf(buf, "Sort current buffer into buffer", "sorted");
	zap(buf);
	do_buffer_sort(buf, has_arg ? iter : 0, rev);
	to_buffer(buf);
	iter = 0;
}

/* Sort a buffer in place, w/o changing current buffer. */
/* If user aborts & abort_searching is ABORT_ERROR, return ABORT_ERROR */
/* & leave buffer unsorted, else return 0. */

sort_another(buf, col, rev)
char *buf;
{
	int old = bufnum, res;
	char *tmp = temp_buf();

	bufname = buf;
	res = do_buffer_sort(tmp, col, rev);	/* sort into tmp */
	if (!res) {
		zap(buf);	/* replace with (sorted) tmp */
		grab_buffer(name_to_bufnum(tmp));
	}
	bufnum = old;
	delete_buffer(tmp);
	return res;
}

command sort_region()
{
	sort_region_cmd(0);
}

command reverse_sort_region()
{
	sort_region_cmd(1);
}

sort_region_cmd(rev)	// sort region of any type in place,
{			// use num arg as column
	if (region_type() == REGRECT) {
		int width, orig = bufnum, b = tmp_buf();
		width = extract_rectangle(b, 0);
		save_var bufnum = b;
		mark = 0;
		sort_region_with_settings(0, size(), has_arg ? iter : 0,
					  rev, orig);
		xfer_rectangle(orig, width, 1);
		buf_delete(b);
	} else {
		save_spot point, mark;
		fix_region();		// handle other types of regions
		do_sort_region(point, mark, has_arg ? iter : 0, rev);
	}
	iter = 0;
}

do_sort_region(from, to, col, rev)	/* sort a region in place */
{
	return sort_region_with_settings(from, to, col, rev, bufnum);
}

sort_region_with_settings(from, to, col, rev, buf)
{	/* sort a region in place, using case-folding from buf */
	char *temp1 = temp_buf(), *temp2 = temp_buf();
	char *this_srch_case_map;
	int this_tab_size, this_case_fold, this_sort_case_fold;
	int res = ABORT_JUMP, orig = bufnum;
	jmp_buf this_level;

	bufnum = buf;
	this_srch_case_map = _srch_case_map;
	this_case_fold = case_fold;
	this_sort_case_fold = sort_case_fold;
	this_tab_size = tab_size;

	bufnum = orig;
	save_var top_level = &this_level;
	if (!setjmp(top_level)) {
		xfer(temp1, from, to);
		bufname = temp1;
		case_fold = this_case_fold;
		sort_case_fold = this_sort_case_fold;
		_srch_case_map = this_srch_case_map;
		tab_size = this_tab_size;
		res = do_buffer_sort(temp2, col, rev);
		if (!res) {
			bufnum = orig;
			delete(from, to);
			bufname = temp2;
			buf_xfer(orig, 0, size());
		}
	}
	bufnum = orig;
	delete_buffer(temp1);
	delete_buffer(temp2);
	return res;
}

/* Sort the buffer into buf on column col. */
/* If rev is nonzero, do a reverse sort. */
/* If abort_searching is ABORT_ERROR and user aborts, returns ABORT_ERROR. */
/* Otherwise returns 0. */

do_buffer_sort(buf, col, rev)
char *buf;
{
	char rev_map[256];
	int i;

	if (sort_case_fold == 0 || sort_case_fold == 1)
		save_var case_fold = sort_case_fold;
	if (rev) {
		for (i = 0; i < 256; i++)	/* set up for reverse sort */
			rev_map[i] = 255 - _srch_case_map[i];
		save_var _srch_case_map = rev_map;
		save_var case_fold = 1;
	}
	return buffer_sort(buf, col);
}

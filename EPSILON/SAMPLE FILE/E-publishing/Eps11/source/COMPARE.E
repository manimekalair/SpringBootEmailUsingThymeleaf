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

// This file compares windows interactively, character-by-character.

#include "eel.h"
#include "diff.h"

#define BUFSIZE 100

command compare_windows() on cx_tab['c'], reg_tab[FCTRL(2)]
{
	iter = 0;
	tiled_only();
	if (number_of_user_windows() < 2)
		error("Only one window");
	if (prev_cmd == CMP_WINDOWS)
		resynch_by_chars();
	else {
		noteput("Comparing windows...");
		switch (compare_windows_ignores_space
				? do_compare_windows_ignore_spaces(compare_windows_ignores_space)
				: do_compare_windows()) {
			case 0:	say("Difference found.");
				this_cmd = CMP_WINDOWS;
				break;
			case 3: say("No difference."); break;
			case 1: next_user_window(1);	/* go to extra chrs */
			default: say("Extra characters."); break;
		}
	}
}

/* Act like do_compare_windows(), but pretend one run of whitespace characters
 * matches another.
 *
 * Modes:
 * 0: don't ignore anything 1: merge runs of spaces, tabs, and newlines
 * 2: merge runs of spaces and tabs only.
 *
 * Return values:
 * 3: The windows match, 2: hit end of other window, 1: hit end of this
 * window, 0: different.
 */

do_compare_windows_ignore_spaces(int mode)
{
	int res, at_space, move1, move2;
	char *charlist = " \t\n", *pat = "[ \t\n]*";

	if (mode == 2)
		charlist = " \t", pat = "[ \t]*";
	while (!(res = do_compare_windows()) && mode) {
		at_space = move1 = move2 = 0;
		if (strchr(charlist, character(point))
			  || strchr(charlist, character(point - 1)))
			at_space++;			// Are we at whitespace in both buffers?
		next_user_window(1);
		if (strchr(charlist, character(point))
			  || strchr(charlist, character(point - 1)))
			at_space++;
		next_user_window(-1);
		if (at_space == 2) {	// Move in each, and note how far.
			point += (move1 = parse_string(1, pat));
			next_user_window(1);
			point += (move2 = parse_string(1, pat));
			next_user_window(-1);
		}
		if (!move1 && !move2)
			break;				// Didn't move in either, so stop.
	}
	return res;
}

do_compare_windows()	/* returns 3: windows match, 2: hit end of other */
{			/* window, 1: hit end of this window, 0: different */
	char buf1[BUFSIZE], buf2[BUFSIZE];
	int max, i;

	for (;;) {
		check_abort();
		max = BUFSIZE - 1;
		if (point + max > size() - narrow_end)
			max = size() - narrow_end - point;
		grab(point, point + max, buf1);
		next_user_window(1);
		if (point + max > size() - narrow_end)
			max = size() - narrow_end - point;
		grab(point, point + max, buf2);
		if (strncmp(buf1, buf2, max) || strlen(buf1) < max) {
			for (i = 0; i < max; i++)	/* find difference */
				if (buf1[i] != buf2[i]) {
					point += i;
					next_user_window(-1);
					point += i;
					return 0;
				}
		}
		point += max;
		i = (point >= size() - narrow_end) * 2;
		next_user_window(-1);
		point += max;
		if (i += (point >= size() - narrow_end))
			return i;
	}
}

#define MAXREACH		2000
#define MATCHES(off1, off2)	(off1 < max1 - resynch_match_chars && \
				off2 < max2 - resynch_match_chars && \
				!memcmp(buf1 + off1, buf2 + off2, \
					resynch_match_chars))

resynch_by_chars()	/* move fwd to next match of resynch_match_chars */
{	/* in this & next window, assuming it's within MAXREACH chars */
	int max1, max2, max, i, reach, t;
	char buf1[MAXREACH], buf2[MAXREACH];

	grab(point, point + MAXREACH - 1, buf1);
	max1 = size() - narrow_end - point;
	next_user_window(1);
	grab(point, point + MAXREACH - 1, buf2);
	max2 = size() - narrow_end - point;
	next_user_window(-1);
	max = max1;
	if (max2 > max)
		max = max2;
	if (max > MAXREACH)		/* highest limit less than MAXREACH */
		max = MAXREACH;
	for (reach = 0; reach < max - resynch_match_chars; reach++) {
		for (i = 0; i <= reach; i++) {
			if (MATCHES(reach, i))
				t = reach, reach = i, i = t;	/* swap */
			else if (!MATCHES(i, reach))
				continue;
			point += i;
			next_user_window(1);
			point += reach;
			next_user_window(-1);
			say("Found a match, skipping %d and %d", i, reach);
			return;
		}
		if (reach > 10) {
			note("Trying to resynchronize...%d", reach);
			check_abort();
		}
	}
	say("Couldn't resynchronize.");
}

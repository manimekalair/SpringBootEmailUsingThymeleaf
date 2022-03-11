/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1995, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

// This file has commands like uniq and keep-duplicate-lines.

#include "eel.h"

// Discard lines that occur more than once.
command keep_unique_lines()
{
	do_uniq(1, 0, 1);
}

// Discard lines that only occur once, leave one copy of each dupl line.
command keep_duplicate_lines()
{
	do_uniq(0, 1, 1);
}

// Leave one copy of each duplicated line.
command uniq()
{
	do_uniq(1, 1, 1);
}

// Do the lines starting at these two positions match?
uniq_lines_match(a, b)
{
	int i, ca, cb;

	if (!case_fold) {
		for (i = 0; character(a + i) == character(b + i); i++)
			if (character(a + i) == '\n')
				return 1;
		return 0;
	}
	for (i = 0; (ca = character(a + i)) >= 0 && (cb = character(b + i)) >= 0
			 && _srch_case_map[ca] == _srch_case_map[cb]; i++)
		if (ca == '\n')
			return 1;
	return 0;
}

// While the line at b matches the line at a, delete the line at b.
// Return the number of such lines we deleted.
uniq_count_dups(a, b)
{
	int cnt = 0;

	while (uniq_lines_match(a, b)) {
		point = b;
		nl_forward();
		delete(b, point);
		cnt++;
	}	
	return cnt;
}

// Go through the buffer deleting lines.
// If incl_uniq, keep lines without duplicates.
// If incl_dups, keep lines with duplicates (one copy only).

do_uniq(incl_uniq, incl_dups, talk)
{
	int old = 0;

	save_spot point;
	for (;;) {
		point = old;
		if (!nl_forward())
			break;
		if (uniq_count_dups(old, point) ? incl_dups : incl_uniq)
			old = point;
		else
			delete(old, point);
		if (talk && size())
			noteput("%d%% complete...", muldiv(point, 100, size()));
	}
	if (!incl_uniq)
		delete(old, point);
	if (talk)
		say("Done.");
}

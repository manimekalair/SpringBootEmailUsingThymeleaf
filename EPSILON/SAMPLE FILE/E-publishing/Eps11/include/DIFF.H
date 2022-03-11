/************************************************** -*- tab-width:4 -*- *
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

user short diff_mismatch_lines = 500;	// give up after looking # lines ahead
user short diff_match_lines = 1;  // # of identical lines to consider a match
user short resynch_match_chars = 15;	// same, but chars: for compare-windows
user int diff_precise_limit = 500000;	// Bigger than this, do sloppy.
user char compare_windows_ignores_space = 2;
user int diff_match_characters = 5;		// Visual diff ignores small char runs.
user int diff_match_characters_limit = 5000;	// Limit char-based visual-diff?

#define MAXONE		200		/* length of a single line before we compare piecemeal */
#define MAXMANY		1000	/* maximum length of diff_match_lines lines */
							/* before going to slow mode */

#define MAXLINES	60	/* if over this many lines, malloc */

struct _diff_data {	/* keep malloc'd arrays here */
	int *start1, *end1, *start2, *end2;
	int size;		/* allocated size of above in bytes */
	int local;		/* can use local vars for this */
} _diff_data;

char _diff_buffer[80] = "diff";	/* put diff listing here */
int _diff_line1, _diff_line2;	/* current line numbers */

// Diff styles
#define LISTING_DIFF_STYLE	0	/* Original style. */
#define VISUAL_DIFF_STYLE	1
#define MERGE_DIFF_STYLE	2

// #ifdef variable name for merge-diff.
user char merge_diff_var[30] = "DIFFVAR";

keytable visual_diff_tab;
char _visual_diff_mode_name[] = "Visual-Diff";
color_class diff_added;
color_class diff_removed;

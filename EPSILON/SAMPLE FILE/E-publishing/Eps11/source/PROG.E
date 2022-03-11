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

// This file has commands that deal with paired delimiters
// like [ and ].

#include "eel.h"
#include "colcode.h"
#include "c.h"

	/* the delimiters in use */
#define LEFTD	"[({"
#define RIGHTD	"])}"

/* user command to move past the next s-expression like object */
command forward_level() on reg_tab[ALT(CTRL('F'))]
{
	if (iter < 0) {
		iter = -iter;
		backward_level();
	}
	while (iter-- > 0)
		move_level(1, LEFTD, RIGHTD, 1, 0);
}

command backward_level() on reg_tab[ALT(CTRL('B'))]
{
	if (iter < 0) {
		iter = -iter;
		forward_level();
	}
	while (iter-- > 0)
		move_level(-1, RIGHTD, LEFTD, 1, 0);
}

command find_delimiter() on reg_tab[ALT(')')]
{
	int orig=point;

	say("");
	iter=0;
	if (in_macro() || key_from_macro)
		return;
	if (move_level(-1, RIGHTD, LEFTD, 1, 0)) {
		show_line();
		point = orig;
	}
}

command show_matching_delimiter()
{
	if (key > 32 && key < 255 && !isalnum(key))
		normal_character();
	save_var inside_show_matching_delimiter = 1;
	find_delimiter();
}

show_line()		/* display point for a moment, then restore */
{
	int oldstart = window_start;
	int time;

	if (in_macro())
		return;
	maybe_refresh();
	time = (window_start == oldstart) ? near_pause : far_pause;
	delay(time, COND_KEY);
	window_start = oldstart;
	build_first = 1;
}

/*
Move in direction dir past a matched pair of characters.
The first is from findch, the second one is at the same
position in otherch.
On success, or if the end of the buffer is encountered before the
first character is found, return the new buffer position.
Otherwise return -1.
*/

default_move_level(dir, findch, otherch)
char *findch, *otherch;
{
	int first, second;
	int level = 0;
	char *p, pat[FNAMELEN];			/* temporary pattern */

	save_var point;			// if aborted, don't move anywhere
	sprintf(pat, "[%s", findch);
	if (p = strchr(pat, ']'))	// Ensure ] is first char in list.
		first = pat[1], pat[1] = *p, *p = first;
	strcat(pat, "]");
	if (!re_search(dir, pat))	/* find the first char of pair */
		return point;	/* at end of buffer */

	point -= dir;			/* move back over first char */
	first = character(point - (dir < 0)); /* get the character we found */
	second = otherch[index(findch, first) - findch];
					/* find the matching char */

	if (second == ']')		/* ] is special in patterns, so */
		strcpy(pat, "[][]");	/* use this: matches [ or ] */
	else
		sprintf(pat, "[%c%c]", first, second);

	while (re_search(dir, pat)) {	/* look for either first or second */
		if (character(point - (dir > 0)) == first)
			level++;
		else
			level--;
		if (level == 0)  /* when we return to same level, done */
			return point;
	}
	return -1;
}

// Act like default_move_level, but also move to destination.  If
// to_end, move to far end of buffer if there's no match.

to_default_move_level(int dir, char *findch, char *otherch, int to_end)
{
	int r = default_move_level(dir, findch, otherch);
	if (r >= 0)
		point = r;
	else if (to_end)
		if (dir > 0)
			point = size();
		else
			point = 0;
	return r;
}

/*
Move in direction dir past a matched pair of characters.  The first is
from findch, the second one is at the same position in otherch.  Return
1 on success, or if the end of the buffer is encountered before the
first character is found.  Return -2 if stop_on_key was nonzero and the
user pressed a key, returning to starting point.  Otherwise maybe show
message, go to starting point, and return 0.
*/

move_level(int dir, char *findch, char *otherch, int show, int stop_on_key)
{
	int res;

	if (mode_move_level)
		res = (*mode_move_level)(dir, stop_on_key);
	else
		res = default_move_level(dir, findch, otherch);
	if (res == -1) {
		if (show)
			if (!inside_show_matching_delimiter || !mute_unmatched_delimiter
				  || !(*mute_unmatched_delimiter)(dir))
				say("Unmatched delimiter");
		return 0;
	}
	point = res;
	if (res == -2)
		return -2;
	return 1;
}

init_highlight_area(int cur_only, int color1, int color2, int type)
{
	if (!highlight_area_end[0]) {	// Initialize.
		highlight_area_start[0] = alloc_spot(1);
		highlight_area_start[1] = alloc_spot(1);
		highlight_area_end[0] = alloc_spot(1);
		highlight_area_end[1] = alloc_spot(1);
		if (modify_region(SHOW_MATCHING_REGION, MRTYPE, -1) != -1)
			remove_region(SHOW_MATCHING_REGION);
		if (color1 != -1)
			add_region(highlight_area_start[0], highlight_area_end[0],
					   color1, type, SHOW_MATCHING_REGION);
		if (color2 != -1)
			add_region(highlight_area_start[1], highlight_area_end[1],
					   color2, type, SHOW_MATCHING_REGION);
		if (cur_only)
			modify_region(SHOW_MATCHING_REGION, MRCONTROL,
						  find_index("is_current_window"));
		else
			retain_highlight_area = 1;
	}
}

init_auto_show_delimiter()
{
	init_highlight_area(1, color_class show_matching_start,
						color_class show_matching_end, 0);
}

// Try moving in the indicated direction over a set of delimiters.
// Then see if we can return to our starting point.  Return 1 if so.

try_auto_show_delimiter(int dir, char *near, char *far)
{
	int orig, there, res;

	save_var point;
	if (dir > 0) {	// Only go one line forward, and not too far back.
		save_var narrow_start = give_begin_line();
		save_var narrow_end = size() - (point + c_look_back);
	} else {		// Only go one line back, and not too far forward.
		save_var narrow_start = ++point - c_look_back;
		save_var narrow_end = size() - give_end_line();
	}
	orig = point;
	res = move_level(dir, near, far, 0, 1);
	if (res != 1)
		return 0;
	there = point;
	res = move_level(-dir, far, near, 0, 1);
	if (res != 1 || point != orig)
		return 0;
	*highlight_area_start[1] = there - (there > point);
	*highlight_area_end[1] = *highlight_area_start[1];
	*highlight_area_start[0] = point - (there < point);
	*highlight_area_end[0] = *highlight_area_start[0];
	return 1;
}

// Remove existing highlight.
hide_auto_show_delimiter()
{
	if (!retain_highlight_area && highlight_area_end[0])
		modify_region(SHOW_MATCHING_REGION, MRTYPE, 0);
}

// Highlight matching delimiter if we're on one.
// Returns 0 if we're not supposed to highlight, 1 if we're not
// on a delimiter character, 2 if we couldn't find its match,
// or 3 if we successfully highlighted delimiters.

// We assume that delimiters in the left half of the string are
// left-delimiters and those in the right half are right-delimiters,
// as in ([]).  Delimiters that are valid on right or left should
// be doubled, as in ('[]').

int maybe_auto_show_delimiter()
{
	int i;

	if (retain_highlight_area)
		return 0;
	if (highlight_area_end[0]) {	// Remove existing highlight.
		if (spot_to_buffer(highlight_area_start[0]) != bufnum) {
			highlight_area_start[0] = 0;	// A spot in some other buffer.
			highlight_area_end[0] = 0; // (we must have copied it).
			highlight_area_start[1] = 0;
			highlight_area_end[1] = 0;
		}
		modify_region(SHOW_MATCHING_REGION, MRTYPE, 0);
	}
	if (num_of_popups() > 0 || is_key_repeating())
		return 0;
	if (mode_auto_show_delimiter) {
		i = (*mode_auto_show_delimiter)();
		if (i != 1)
			return i;
	}
	return default_auto_show_delimiter();
}

default_auto_show_delimiter()
{
	char *p, left[FNAMELEN], right[FNAMELEN];
	int i, rightside, adjacent = 0, len;

	if (!auto_show_matching_characters || !*auto_show_matching_characters
		  || !curchar())
		return 0;
	p = index(auto_show_matching_characters, curchar());
	if (!p && auto_show_adjacent_delimiter) {
		adjacent = 1;	// Check prev character, maybe it's a delim.
		save_var point--;
		p = index(auto_show_matching_characters, curchar());
	}
	if (!p)
		return 1;				// Not a delimiter we can match.
	i = p - auto_show_matching_characters;		// Index of char.
	len = strlen(auto_show_matching_characters);
	rightside = i * 2 >= len;
	if (adjacent && !(auto_show_adjacent_delimiter & (rightside ? 1 : 2)))
		return 1;	// Maybe reject some adjacent delimiters.
	save_var point, matchstart, matchend, abort_searching = 0;
	save_var mouse_mask &= ~MASK_MOVE;	// Don't give up due to mouse motion.
	init_auto_show_delimiter();
	for (i = 0; i * 2 < len; i++) {
		left[i] = auto_show_matching_characters[i];
		right[i] = auto_show_matching_characters[len - i - 1];
	}
	left[i] = right[i] = 0;
	if (rightside ? try_auto_show_delimiter(-1, right, left)
				  : try_auto_show_delimiter(1, left, right)) {
		modify_region(SHOW_MATCHING_REGION, MRTYPE, REGINCL);
		return 3;			// Show the two regions.
	}
	return 2;
}

// Copy buffer-specific variables from one buffer to another,
// then clear those that should be unique to each buffer.

safe_copy_buffer_variables(to, from)
{
	copy_buffer_variables(to, from);
//	save_var bufnum = to;
}

to_line_comment()	/* go to start of comment on this line, or eol */
{			/* return 1 if there was comment, else 0 */
	int end;

	save_var narrow_start = give_begin_line();
	to_end_line();
	end = point;
	if (re_search(RE_REVERSE, comment_start))
		return 1;
	point = end;
	return 0;
}

to_comment_column()	/* replace whitespace here with comment indentation */
{
	int this;

	delete_horizontal_space();
	this = current_column();
	if (!this && !comment_column)
		return;
	else if (this >= comment_column)
		stuff(" ");	/* code extends past comment col */
	else if (!this && indenter && indent_comment_as_code)
		(*indenter)();
	else
		insert_to_column(this, comment_column);
}

command indent_for_comment() on reg_tab[ALT(';')]
{
	int pt = point, scom;

	if (has_arg) {
		if (iter < 0) {
			to_begin_line();
			if (!re_search(RE_REVERSE, comment_start)) {
				point = pt;
				error("No previous comment found.");
			}
		}
		if (!re_search(RE_FORWARD, comment_start)) {
			point = pt;
			error("No comment found.");
		}
		iter = 0;
		return;
	}
	if (to_line_comment()) {	/* line has comment */
		if (pt > point) {	/* if we were in the comment */
			scom = point;	/* remember where comment was */
			point = pt;	/* stay there after */
			save_spot point = scom;
			to_comment_column();	/* now reindent it */
		} else {
			to_comment_column();	/* reindent it */
			re_search(RE_FORWARD, comment_start);
		}			/* go to start of comment */
	} else {
		to_comment_column();	/* make a new comment on this line */
		stuff(comment_begin);
		pt = point;
		stuff(comment_end);
		point = pt;		/* insert comment text here */
	}
}

command set_comment_column() on cx_tab[';']
{				/* put future comments in this column */
	int newcol, orig = point;

	if (iter < 0) {
		kill_comment();
		return;
	}
	if (has_arg) {	/* copy comment column from last comment */
		to_begin_line();
		re_search(RE_REVERSE, comment_start);
		newcol = current_column();
		point = orig;
		iter = 0;
	} else
		newcol = current_column(); /* start comments here */
	comment_column = newcol;
	if (!to_line_comment()) {
		point = orig;
		return;
	}
	to_comment_column();
}

command kill_comment()		/* kill any comment on this line */
{
	int start;

	iter = 0;
	if (!to_line_comment())
		error("This line has no comment.");
	re_search(RE_REVERSE, "[ \t]*");
	start = point;
	re_search(RE_FORWARD, comment_pattern);
	do_save_kill(start, point);
}

/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 2000, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

#include "eel.h"

struct {
	spot start;
	spot end;

	char prefix[100];

	char found[200];
	int savepos;
	int len; 
	int pullsrc;
} pull;



int in_middle_of_word()
{
	save_var point;

	point = *pull.start;

	if (parse_string(-1, word_pattern) != 0)
		return 1;
	else
		return 0;
}


int find_word_with_prefix(int dir)
{
	char filter_pattern[200];

	sprintf(filter_pattern, "(%s)(%s)", pull.prefix, word_pattern);

	if (dir == -1)
		point = *pull.start;
	else
		point = *pull.end;
	while (re_search(dir, filter_pattern) != 0){
		*pull.start = find_group(1, 1);
		*pull.end = find_group(2, 0);

		if (in_middle_of_word()){
			continue;
		} else {
			return 1;
		}
	}
	return 0;
}




restore_prefix()
{
	save_var point = pull.savepos;
	delete(point, point + pull.len);
	stuff(pull.prefix);
	pull.len = strlen(pull.prefix);
}

int pl_search(int dir)
{
	restore_prefix();

	if (find_word_with_prefix(dir) != 0){
		grab(*pull.start, *pull.end, pull.found);

			// Get rid of the last guess.
		point = pull.savepos;
		delete(point, point + pull.len);

			// Stuff in the new guess.
		pull.len = strlen(pull.found);
		stuff(pull.found);

		maybe_refresh();

		if (is_region_visible(*pull.start, *pull.end) == 0){
			echo_context(*pull.start);
		} else {
			dismiss_echo_context();
			say("");
		}

		return 1;
	} else {
		say("Search failed for word beginning with: %s", pull.prefix);
		return 0;
	}
}



void free_pl()
{
	remove_region(pull.pullsrc);
	free_spot(pull.start);
	free_spot(pull.end);
	dismiss_echo_context();
}

void alloc_pl()
{
	/* Get the word prefix, if any, that occurs
	 * immediately before point.
	 */
	pull.len = 0;
	pull.prefix[0] = 0;
	parse_string(-1, word_pattern, pull.prefix);

	pull.savepos = point;
	pull.len = strlen(pull.prefix);

	pull.start = alloc_spot();
	pull.end = alloc_spot();
	*pull.start = *pull.end = point;
	pull.pullsrc = add_region(pull.start, pull.end, color_class pull_highlight, REGNORM);
}



 
void pl_restore()
{
	point = pull.savepos;
	delete(point, point + pull.len);
	stuff(pull.prefix);
}


int at_word_interior()
{
	save_var point;
	return parse_string(1, word_pattern);
}







command pull_word() on reg_tab[NUMCTRL(KEYUP)], reg_tab[FKEY(3)]
{
	int pl_key;

	check_modify(bufnum);
	iter = 1;
	if (at_word_interior()){
		note("Can't pull word here.");
		return;
	}


	alloc_pl();

	for (pl_key = pl_trans(key); 1; pl_key = pl_getkey()){

		switch(pl_key){
			case 1:
			case -1:
				if (pl_search(pl_key) == 0){
					pl_restore();
					free_pl();
					expire_message = 1;
					return;
				}
				break;
			case 7:
				pl_restore();
				free_pl();
				user_abort = 0;
				return;
			case '?':
				help_on_command("pull-word");
				break;
			default:
				free_pl();
				/* Run the key that caused us
				 * to exit.
				 */
				run_topkey();
				return;
		}
	}
}



command pull_word_fwd() on reg_tab[NUMCTRL(KEYDOWN)]
{
	pull_word();
}



int pl_trans(int k)
{
	int r = reg_tab[k];
	if (r == (short) pull_word)
		return -1;
	else if (r == (short) pull_word_fwd)
		return 1;
	else if (r == (short) help)
		return '?';
	else if (r == (short) abort)
		return 7;
	else
		return 0;
}




int pl_getkey()
{
	int ch;
	for (;;) {
		switch (ch = getkey()) {
		case MOUSE_MOVE:
		case GETFOCUS:
		case LOSEFOCUS:
		case LOST_SELECTION:
		case WIN_MOUSE_LEAVES:
		case WIN_MOUSE_ENTERS:
			break;
		default:
			return pl_trans(ch);
		}
	}
}

// Are all the characters in this buffer region visible in the current
// window?

is_region_visible(int start, int end)
{
	int t, row, col;

	if (start > end){
		t = start;
		start = end;
		end = t;
	}

	if (get_window_pos(start, &row, &col) || get_window_pos(end - 1, &row, &col))
		return 0;	// If either end isn't visible, say no.

	save_var point = start;	// Only check line endings/beginnings.
	save_var narrow_start = start, narrow_end = size() - (end - 1);
	while (nl_forward())
		if (get_window_pos(point - 1, &row, &col)
			  || get_window_pos(point, &row, &col))
			return 0;
	return 1;
}


zeroed int echo_window_handle;

echo_context(int pos)
{
	save_var point = pos;

	if (echo_window_handle && is_window(echo_window_handle)) {
		remove_window(echo_window_handle);
	}
	save_var window_handle;
	echo_window_handle = add_popup(0, screen_lines - 1, screen_cols, 1,
								   0, bufnum);
	system_window = 1;
}



dismiss_echo_context()
{
	if (echo_window_handle && is_window(echo_window_handle)) {
		remove_window(echo_window_handle);
		return;
	}
}

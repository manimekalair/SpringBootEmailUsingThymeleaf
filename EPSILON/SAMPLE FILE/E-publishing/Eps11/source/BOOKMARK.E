/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1992, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

// This file has the bookmark commands.

#include "eel.h"

char _blist_mode_name[] = "Bookmark-List";
#define BMARK_LIST	"-bookmark-list"
int _blist_window, _blist_orig_window;

bookmark_to_key(b)
{
	return (b < 10) ? ((b - _bookmark_slot + 10) % 10 + '0')
			: (b - 10 + 'A');
}

key_to_bookmark(k)
{
	return isdigit(k) ? ((k - '0' + _bookmark_slot) % 10) :
		isalpha(k) ? (toupper(k) - 'A' + 10) : -1;
}

command set_bookmark() on reg_tab[ALT('/')]
{
	quiet_set_bookmark();
	say("Bookmark set.");
}

quiet_set_bookmark()
{
	_bookmark_slot = (_bookmark_slot - 1 + 10) % 10;
	do_set_bookmark(key_to_bookmark('0'));
}

command set_named_bookmark() on cx_tab['/']
{
	int b;

	iter = 0;
	mention("Set bookmark [A-Z, 0-9, ? to list]: ");
	do {
		getkey();
		check_abort();
		if (key == '?') {
			_blist_cmd = say_set_bookmark;
			make_bookmark_list("set");
			return;
		} else if (IS_ENTER_KEY(key)) {
			set_bookmark();
			return;
		}
	} while ((b = key_to_bookmark(key)) < 0);
	say_set_bookmark(b);
}

say_set_bookmark(b)
{
	do_set_bookmark(b);
	say("Bookmark %c set.", bookmark_to_key(b));
}

do_set_bookmark(b)
{
	if (spot_to_buffer(_bookmark_spots[b]) > 0)
		free_spot(_bookmark_spots[b]);
	_bookmark_spots[b] = alloc_spot(0);
	_last_bookmark = b;
}

command jump_to_last_bookmark() on reg_tab[ALT('j')],
								   reg_tab[NUMCTRL(GREYSTAR)]
{
	int b, count;

	tiled_only();
	if (has_arg) {
		_bookmark_next = iter % 10;
		b = (_bookmark_next + _bookmark_slot) % 10;
		iter = 0;
	} else if (prev_cmd != LAST_BOOKMARK) {
		b = _last_bookmark;		/* go to last one */
		_bookmark_next = -1;		/* next time, go to #0 */
	} else				/* go to next one */
		b = (_bookmark_next + _bookmark_slot) % 10;

	for (count = 0; !is_good_bookmark(b); ) {
		if (count++ > 10)
			error("No valid bookmarks are defined.");
		b = (++_bookmark_next + _bookmark_slot) % 10;
	}	/* cycle through bookmarks till we find good one */

	if ((++_bookmark_next + _bookmark_slot) % 10 == b)
		_bookmark_next++;	/* but don't repeat */
	do_jump_to_bookmark(b);
	this_cmd = LAST_BOOKMARK;
}

command jump_to_named_bookmark() on cx_tab['j']
{
	int b;

	iter = 0;
	tiled_only();
	if (run_by_mouse)
		ungot_key = '?';
	mention("Jump to bookmark [A-Z, 0-9, ? to list]: ");
	do {
		getkey();
		check_abort();
		if (key == '?') {
			list_bookmarks();
			return;
		} else if (IS_ENTER_KEY(key)) {
			jump_to_last_bookmark();
			return;
		}
	} while ((b = key_to_bookmark(key)) < 0);
	key = toupper(key);
	do_jump_to_bookmark(b);
}

is_good_bookmark(b)
{
	spot m = _bookmark_spots[b];

	return m && spot_to_buffer(m) > 0;
}

do_jump_to_bookmark(b)
{
	int i;
	spot m = _bookmark_spots[b];

	if (!m)
		error("Bookmark %c is not in use", key);
	i = spot_to_buffer(m);
	if (i == -1)
		error("Bookmark %c's buffer has been deleted", key);
	else if (i == -2)
		error("Can't find bookmark %c", key);
	_last_bookmark = b;
	to_buffer_num(i);
	point = *m;
	say("Jumped to bookmark %c.", bookmark_to_key(b));
}

when_loading()	/* disable normal keys */
{
	fix_key_table(reg_tab, (short) normal_character, blist_tab, -1);
}

blist_help() on blist_tab['?'], blist_tab['h']
{
	help_on_command("list-bookmarks");
}

blist_tab_key() on blist_tab['\t']
{
	if ((has_feature & FEAT_GUI_DIALOGS) && window_to_screen(window_handle))
		next_dialog_item();
}

blist_backtab_key() on blist_tab[NUMSHIFT(GREYTAB)]
{
	prev_dialog_item();
}

blist_pick() on blist_tab[' '], blist_tab['\n'],
		blist_tab['e'], blist_tab['\r'], blist_tab[GREYENTER]
{				/* go to bookmark on this line */
	int b;

	iter = 0;
	b = get_bmark_code();
	if (b < 0)
		error("Bad bookmark code");
	say("");
	remove_blist();
	(*_blist_cmd)(b);
}

blist_delete() on blist_tab['d'], blist_tab['k']
{
	drop_bookmark(get_bmark_code());
	dired_del_line();
}

drop_bookmark(b)
{
	if (is_good_bookmark(b)) {
		free_spot(_bookmark_spots[b]);
		_bookmark_spots[b] = 0;
	}
}

in_blist()
{
	save_var bufnum = window_bufnum;
	return (window_handle == _blist_window && mode_keys == blist_tab);
}

quit_blist()	/* if in a bookmark list window, go back to orig */
{
	if (in_blist()) {
		remove_blist();
		maybe_refresh();
	}
}

remove_blist()		/* remove blist window from screen */
{
	if (_blist_orig_window && is_window(_blist_orig_window))
		window_handle = _blist_orig_window;
	if (_blist_window)
		remove_window(_blist_window);
}

blist_abort()		/* remove blist window if ^G'd */
{
	remove_blist();
}

get_bmark_code()
{
	int b;

	to_begin_line();
	if (!parse_string(1, "[0-9A-Z] ")
			|| (b = key_to_bookmark(curchar())) < 0)
		error("Can't read bookmark code");
	return b;
}

when_loading()
{
	set_list_keys(blist_tab);
	fix_key_table(reg_tab, (short) abort, blist_tab, (short) blist_abort);
	fix_key_table(reg_tab, (short) help, blist_tab, (short) blist_help);
}

command list_bookmarks()
{
	tiled_only();
	_blist_cmd = do_jump_to_bookmark;
	make_bookmark_list("jump to");
}

make_bookmark_list(op)
char *op;
{
	int i, orig = bufnum, list, count = 0, new;

	iter = 0;
	list = zap(BMARK_LIST);
	for (i = 10; i < NUM_BOOKMARKS; i++)
		count += list_a_bookmark(list, i);
	for (i = '0'; i <= '9'; i++)
		count += list_a_bookmark(list, key_to_bookmark(i));
	bufnum = orig;
	if (!count) {
		remove_blist();
		error("No bookmarks defined");
	}
	new = (window_handle != _blist_window);
	if (new) {
		_blist_orig_window = window_handle;
		remove_blist();
		_blist_window = add_popup(2, 2, screen_cols - 4,
			screen_lines - 6, ALL_BORD(BSINGLE), list);
		mouse_cursor = &left_pointer;
	} else
		window_bufnum = list;
	build_first = 1;
	point = 0;
	buf_delete_final_newlines(list);
	text_color = (is_gui && want_gui_prompts) ? color_class text : color_class viewed_text;
	display_column = 0;	/* horizontally scroll this window */
	window_title(_blist_window, BTOP, TITLECENTER, " Bookmarks ");
	display_more_msg(_blist_window);
	make_line_highlight();	/* have current line always be highlighted */
	goal_column = 0;	/* next-, prev-line stay in col 0 */
	popup_near_window(_blist_window, _blist_orig_window);
	if (is_gui && want_gui_prompts && new)
		one_window_to_dialog("Select a Bookmark", _blist_window,
							 "Go", "Cancel", "Help");
	mode_keys = blist_tab;
	major_mode = _blist_mode_name;
	mouse_dbl_selects = 1;
	make_mode();
	say("Select a bookmark to %s.", op);
	modified = 0;
}

list_a_bookmark(list, i)	/* maybe add a line to list for mark i */
{				/* return 1 if we did, else 0 */
	int b, opt;
	spot m = _bookmark_spots[i];

	if (!m || (b = spot_to_buffer(m)) <= 0)
		return 0;
	bufnum = b;
	buf_printf(list, "%c %s: ", bookmark_to_key(i), bufname);
	opt = point;
	point = *m;
	buf_xfer(list, give_begin_line(), give_end_line());
	point = opt;
	buf_printf(list, "\n");
	return 1;
}

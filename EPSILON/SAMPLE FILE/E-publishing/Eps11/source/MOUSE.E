/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*       "EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.      *
*                                                                       *
*  Copyright (C) 1992, 2001 Lugaru Software Ltd.  All rights reserved.  *
*                                                                       *
* Limited permission is hereby granted to reproduce and modify this     *
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in  *
* any such reproduction or modification.                                *
************************************************************************/

// This file has functions for handling mouse clicks.

#include "eel.h"

clip_mouse()	// make mouse globals in range
{
	if (mouse_x < 0)
		mouse_x = 0;
	else if (mouse_x >= screen_cols)
		mouse_pixel_x = screen_cols * x_pixels_per_char() - 1;
	if (mouse_y < 0)
		mouse_y = 0;
	else if (mouse_y >= screen_lines)
		mouse_pixel_y = screen_lines * y_pixels_per_char() - 1;
}

point_to_pos(x, y, screen)	// Go to window & position.  Return 0 normally,
{			// 1 if no window there, 2 if no text (in border).
	if (!to_mouse_window(x, y, screen))
		return 1;
	else if (!to_mouse_position(x, y))
		return 2;
	else
		return 0;
}

to_mouse_window(x, y, screen)	// Switch to window at coords, return nonzero if ok.
{
	int win;

	win = window_at_coords(y, x, screen);
	if (win == -1)
		return 0;
	if (win != window_handle) {
		tiled_only();	/* kill pop-up when we switch away */
		if (!is_window(win))
			return 0;
		window_handle = win;
		switching_to_buffer();
		check_dates(0);
	}
	return 1;
}

to_mouse_position(x, y)	// Move to position for these screen coords,
{			// assuming we're in right window, & return nonzero
	int pt;		// if we could.

	x -= window_text_left(window_handle);
	y -= window_text_top(window_handle);
	pt = window_line_to_position(y);
	if (pt == -1) {			// try again, in case window's
		build_window();		// never been seen
		pt = window_line_to_position(y);
		if (pt == -1)
			return 0;		// must be on the border
	}

	point = pt;
	if (display_column < 0) {
		save_var narrow_start = point;
		if (virtual_space)
			to_virtual_column(x);
		else
			move_to_column(x);
	} else if (virtual_space)
		to_virtual_column(x + display_column);
	else
		move_to_column(x + display_column);
	return 1;
}

window_text_left(win)	// 1st screen column with this win's text
{
	int v = get_wattrib(win, BLEFT);

	if (GET_BORD(BLEFT, get_wattrib(win, PBORDERS)) != BNONE)
		v++;
	return v;
}

window_text_top(win)	// 1st screen line with this win's text
{
	int v = get_wattrib(win, BTOP);

	if (GET_BORD(BTOP, get_wattrib(win, PBORDERS)) != BNONE)
		v++;
	return v;
}

window_right(win)		// screen column with right window edge
{
	save_var window_handle = win;
	return window_left + window_width - 1;
}

window_bottom(win)
{
	save_var window_handle = win;
	return window_top + window_height - 1;
}

get_text_area(w_handle)
{
	save_var window_handle = w_handle;

	w_left = window_text_left(window_handle);
	w_top = window_text_top(window_handle);
	w_right = w_left + text_width() - 1;
	w_bottom = w_top + text_height() - 1;
}

handle_scroll(x, y)
{
	save_var iter = 1;

	if (x < w_left && display_column > 0) {
		scroll_right();
		move_to_column(display_column);
	} else if (x > w_right && display_column >= 0) {
		scroll_left();
		move_to_column(display_column + text_width() - 1);
	} else if (y > w_bottom) {
		scroll_up();
		point = window_end;
	} else if (y < w_top) {
		scroll_down();
		point = window_start;
	}
	refresh();
}

int in_text_area(x, y)
{
	return x <= w_right && x >= w_left &&
	       y >= w_top && y <= w_bottom;
}

get_window_area()	// get text area of this window & return handle
{			// return -1 if no window here
	int win;

	clip_mouse();
	win = window_at_coords(mouse_y, mouse_x, mouse_screen);
	if (win != -1)
		get_text_area(win);
	return win;
}

int has_elapsed(t)
TIMER *t;
{
	int scroll_delay;

	if (!time_done(t))
		return 0;
	scroll_delay = 100 / MAX(scroll_rate, 1);
	time_begin(t, scroll_delay);
	return 1;
}

command mouse_select() on reg_tab[MOUSE_LEFT_DN], reg_tab[MOUSE_DBL_LEFT]
{
	int k = key;

	if (mouse_other_handler())
		return;
	else if (!in_text_area(mouse_x, mouse_y)) // clicked in border
		mouse_move_border(0);
	else if (IS_MOUSE_DOUBLE(key) && mouse_dbl_selects)
		run_enter_key();
	else {
		mouse_selecting();
		mouse_call_hook(k);	// call correct hook for this key
	}
}

command mouse_to_tag() on reg_tab[MOUSE_RIGHT_DN], reg_tab[MOUSE_DBL_RIGHT]
{
	int k = key;

	if (has_feature & FEAT_OS_MENUS) {
		context_menu();
	} else if (mouse_other_handler())
		return;
	else if (!in_text_area(mouse_x, mouse_y)) // clicked in border
		mouse_move_border(1);
	else if (IS_MOUSE_DOUBLE(key) && mouse_dbl_selects)
		run_enter_key();
	else {
		if (mouse_goes_to_tag && IS_MOUSE_DOUBLE(key) &&
			!(mouse_shift & (KB_SHIFT_DN | KB_CTRL_DN | KB_ALT_DN))) {
			mouse_display = 0;
			point_to_pos(mouse_x, mouse_y, mouse_screen);
			pluck_tag();
		} else
			mouse_selecting();
		mouse_call_hook(k);	// call correct hook for this key
	}
}

command context_menu() on reg_tab[FSHIFT(10)]
{
	win_menu_popup("_popup");
	invisible_cmd();
}

mouse_other_handler()	// will a menu or some other window handle this key?
{
	int win;

	if (is_menu_here())
		click_menu();
	else if ((win = get_window_area()) == -1)
		click_in_echo();
	else if (!window_mouse_handler(win)) // window did its own handling
		return 0;
	return 1;
}

run_enter_key()
{
	do_command(mode_keys['\n'] ? mode_keys['\n'] : root_keys['\n']);
}

// For a variable where 0 means no, 1 means yes, 2 means only under
// Unix, return nonzero or zero as appropriate.
interpret_mouse_variable(int val)
{
	return (val == 2) ? (opsys == OS_UNIX) : val;
}

mouse_selecting()	// using left button to select text
{
	int orig, by_words = IS_MOUSE_DOUBLE(key), extend;

	save_var mouse_auto_on = 0;	/* movements won't show mouse */
	to_mouse_window(mouse_x, mouse_y, mouse_screen);
	orig = point;
	refresh();
	to_mouse_position(mouse_x, mouse_y);
	mouse_display = (by_words && mouse_graphic_cursor);
	extend = (mouse_shift & KB_SHIFT_DN);
	if (!extend) {	/* not extending */
		if (is_highlight_on() && point_in_region(orig)) {
			drag_and_drop(orig);
			shift_selecting = 2;
			return;
		}
		mark = point;		/* put one end here */
		if (virtual_space >= 2)
			mark_to_column = cursor_to_column;
		highlight_off();
	}
	refresh();
	select_loop(by_words, 1);
	if (interpret_mouse_variable(mouse_selection_copies) && point != mark) {
		if (extend)
			pop_kill();
		do_copy_region();
		highlight_on();
	}
	if (!extend)
		shift_selecting = 2;
}

select_loop(by_words, display_region)
{	/* select a buffer pos while pressing mouse button */
	int bgn, pt, mk, curcol, otype = -1;
	TIMER ts;

	bgn = mark;
	time_begin(&ts, 0);
	pt = point; mk = mark; curcol = cursor_to_column;
	save_var mouse_mask |= MASK_MOVE | MASK_UP;
	do {
		if (char_avail()) {
			getkey();
			if (key == GETFOCUS || key == LOSEFOCUS) {
				do_topkey();
				continue;
			}
		}

		if (mouse_x < 0 && display_column <= 0)
			mouse_x = 0;
		if (in_text_area(mouse_x, mouse_y))
			point_to_pos(mouse_x, mouse_y, mouse_screen);
		else {
			if (!has_elapsed(&ts))
				continue;
			handle_scroll(mouse_x, mouse_y);
		}
		if (by_words)
			region_by_words(bgn);
		set_region_type((shift_pressed() & KB_ALT_DN)
				? REGRECT : REGNORM);
		if (point != pt || mark != mk || curcol != cursor_to_column
		    || region_type() != otype) {
			if (point != mark || curcol != cursor_to_column)
				if (display_region)
					highlight_on();
			refresh();
			mouse_display = 1;
			pt = point;
			mk = mark;
		}
		otype = region_type();
	} while (!IS_MOUSE_UP(key) && mouse_pressed());
	mouse_display = 0;
}

point_in_region(p)	// is point in region between p and mark?
{
	int pos, col1, col2, col;

	pos = point;		// remember place we're interested in
	col = virtual_column();
	save_var point = p, mark;
	fix_region();		// handle other region types
	if (region_type() != REGRECT)
		return point <= pos && pos < mark;
	col2 = (mark_to_column >= 0) ? mark_to_column : get_column(mark);
	col1 = current_column();
	if (col1 > col || col >= col2)	// pos must be between columns
		return 0;
	to_begin_line();		// and between lines (inclusive)
	if (pos < point)
		return 0;
	point = mark;
	nl_forward();
	return pos < point;
}

drag_and_drop(orig)	/* let user pick a spot to drag text to */
{			// called whenever user clicks on highlighted text
	spot temp_point;
	int region, type = region_type();

	save_var mouse_cursor = &drag_and_drop_pointer;
	save_var mouse_cursor_attr = 0x33;
	highlight_off();	// turn off for this window
	temp_point = alloc_spot(); // and display a region that's independent
	*temp_point = orig;	// of point
	region = add_region(temp_point, mark_spot, color_class highlight,
			    type);
	modify_region(region, MRCONTROL, find_index("_dragging_control"));
	save_var _dragging_control = 1;
	select_loop(0, 0);			// wait until user releases key
	set_region_type(type);	// select_loop() changes type
	remove_region(region);	// now free temporary region
	free_spot(temp_point);
	if (point_in_region(orig)) {	// unselect region
		highlight_off();
		mark = point;
	} else {
		drag_drop_xfer(orig);		// moved it somewhere
		highlight_on();
	}
}

drag_drop_xfer(orig)	/* move text from orig..mark to point */
{
	int copy = shift_pressed() & KB_CTRL_DN;

	save_spot point = orig;
	prev_cmd = 0;
	if (copy)
		copy_region();
	else if (region_type() == REGRECT)
		pick_rectangle(1, over_mode ? 2 : 1);
	else
		kill_region();
	restore_vars();
	yank();
}

region_by_words(bgn)
{
	int dir = (bgn <= point ) ? 1 : -1;
	int pt;

	if (point == bgn || parse_string(-dir, word_pattern))
		point += (dir * parse_string(dir, word_pattern));
	pt = point; point = bgn;
	if (point == bgn || parse_string(dir, word_pattern))
		point -= (dir * parse_string(-dir, word_pattern));
	mark = point; point = pt;
	if (point == mark)
		point++;
}

window_mouse_handler(win)	// try running window-specific handler
{				// return 1 if handler says to stop now
	int owin = window_handle;
	int (*f)();

	if (!is_window(win))
		return 0;
	window_handle = win;
	f = mouse_handler;
	window_handle = owin;
	return f ? (*f)(win) : 0;
}

allow_mouse_switching(nwin)	// mouse_handler() func that allows
{				// switching to this popup
	if (IS_MOUSE_KEY(key))
		window_handle = nwin;
	return 0;
}

mouse_call_hook(k)	// call correct hook for this key
{
	if (IS_MOUSE_LEFT(k))
		mouse_left_hook();
	else if (IS_MOUSE_RIGHT(k))
		mouse_right_hook();
	else if (IS_MOUSE_CENTER(k))
		mouse_center_hook();
}

mouse_left_hook()
{
}

mouse_right_hook()
{
}

mouse_center_hook()
{
}

mouse_move_border(resize)	/* let user move border around */
{
	int win = window_at_coords(mouse_y, mouse_x, mouse_screen);
	int bord;

	if (win == -1) {		/* probably clicked in echo area */
		click_in_echo();
		return;
	}
	save_var mouse_mask |= MASK_MOVE | MASK_UP;
	save_var window_handle = win;
	bord = get_wattrib(win, PBORDERS);
	if (!try_move_border(bord, resize))	// first try actual borders
		try_move_border(ALL_BORD(BBLANK), resize);
}


try_move_border(bord, resize)	// move if on edge & bord says ok
{				// return 1 if we found an edge to move
	int h = -1, v = -1;

	if (mouse_y == window_bottom(window_handle) && GET_BORD(BBOTTOM, bord))
		v = BBOTTOM;
	else if (mouse_y == window_top && GET_BORD(BTOP, bord))
		if (resize || is_window(window_handle) != ISPOPUP)
			v = BTOP;
		else {
			mouse_move_popup();	// move whole win
			return 1;
		}
	if (mouse_x == window_left && GET_BORD(BLEFT, bord))
		h = BLEFT;
	else if (mouse_x == window_right(window_handle)
					 && GET_BORD(BRIGHT, bord)) {
		if (!resize && v == -1 && display_scroll_bar) {
			mouse_scroll_bar();
			return 1;
		}
		h = BRIGHT;
	}
	if (h == -1 && v == -1)
		return 0;
	mouse_move_edge(h, v);
	return 1;
}

mouse_move_edge(h, v)		// let user move edges h or v with mouse
{				// -1 means don't move it
	int old_h, old_v;

	save_var mouse_cursor;
	if (h != -1)
		old_h = get_wattrib(window_handle, h);
	if (v != -1)
		old_v = get_wattrib(window_handle, v);
	if (h == -1)
		mouse_cursor = &vert_arrows;
	else if (v == -1)
		mouse_cursor = &horiz_arrows;
	else
		mouse_cursor = &move_arrows;
	while (mouse_pressed()){
		getkey();
		if (key == ESC || user_abort) {
			if (h != -1)
				set_wattrib(window_handle, h, old_h);
			if (v != -1)
				set_wattrib(window_handle, v, old_v);
			user_abort = 0;
			return;
		}
		if (h != -1)
			set_wattrib(window_handle, h, mouse_x);
		if (v != -1)
			set_wattrib(window_handle, v, mouse_y);
		refresh();
	}
}

mouse_move_popup()	// let user move popup window with mouse
{
	int orig_x = mouse_x - window_left;
	int orig_y = mouse_y - window_top;

	save_var mouse_cursor = &move_arrows;
	while (mouse_pressed()){
		getkey();
		window_left = mouse_x - orig_x;
		window_top = mouse_y - orig_y;
		refresh();
	}
}

permit_scroll_bar_border()
{
	return !is_gui;
}

command toggle_scroll_bar()	// want constant scroll bar on tiled wins?
{
	if (is_gui)
		error("Can't toggle scroll bar in this version.");
	tiled_scroll_bar = has_arg ? (iter != 0) : !tiled_scroll_bar;
	border_right = (permit_scroll_bar_border() && tiled_scroll_bar);
	full_redraw = 1;
}

scroll_bar_code() // give code showing where on scroll bar this is
{
	int l, y = mouse_y_in_range() - window_text_top(window_handle);

	if (y < 0)
		return -3;
	else if (y > text_height() - 1)
		return 3;
	else if (y == 0)
		return -2;
	else if (y == text_height() - 1)
		return 2;
	else if (y == (l = scroll_bar_line()))
		 return 0;
	else if (y < l)
		return -1;
	else
		return 1;
}

mouse_scroll_bar()	// clicked on scroll bar
{
	int atcode = scroll_bar_code();
	TIMER ts;

	save_var mouse_mask |= MASK_MOVE | MASK_UP;
	if (!atcode) {
		mouse_move_scroll_box();
		return;
	}
	save_var mouse_cursor = &right_pointer;
	time_begin(&ts, scroll_init_delay);
	handle_scroll_bar(atcode);
	while (mouse_pressed()) {
		if (char_avail())
			getkey();
		else if (has_elapsed(&ts))
			atcode = handle_scroll_bar(atcode);
	}
}

handle_scroll_bar(atcode)	// interpret scroll bar code
{
	int pos, pix = y_pixels_per_char();

	if (atcode != scroll_bar_code())
		return atcode;
	save_var iter = 1;
	switch (atcode) {
		case -2:	window_scroll(-1);	break;
		case -1:	previous_page();	break;
		case 1:		next_page();		break;
		case 2:		window_scroll(1);	break;
	}
	if (ABS(atcode) == 1 && atcode != scroll_bar_code()) {
		pos = scroll_bar_line() + window_text_top(window_handle);
		if (point && point < size())
			pos += atcode;
		mouse_pixel_y = pos * pix + pix / 2;
		atcode = scroll_bar_code();
	}
	refresh();
	return atcode;
}

mouse_move_scroll_box()		// grabbed box in center of scroll bar
{
	int i, pix, max, offset, last = -1;
	char *p = display_characters + SCROLLCHARSTART + 2, old = *p;

	save_var mouse_display = 0, mouse_auto_on = 0;
	*p = p[1];
	pix = y_pixels_per_char();
	max = (MAX(text_height(), 5) - 4) * pix;
	i = mouse_pixel_y - (w_top + 2) * pix;
	offset = point - size() * i / max;
	while (mouse_pressed() && !user_abort) {
		if (char_avail())
			getkey();
		i = mouse_pixel_y - (w_top + 2) * pix;
		point = size() * i / max + offset;
		if (point > 0 && goal_column >= 0)
			move_to_column(goal_column);
		window_start = prev_screen_line(text_height() / 2);
		if (point != last)
			refresh();
		last = point;
	}
	*p = old;
}

show_scroll_bar()	// display scroll bar while mouse is over it
{
	int obord, origx = mouse_x;

	save_var mouse_cursor = &right_pointer;
	save_var window_handle = window_to_scroll();
	obord = get_wattrib(window_handle, PBORDERS);
	if (!bar_on_edge() && !delay_scroll_bar())
		return;
	save_var _window_flags |= FIXED_BORDERS;  // no auto setting
	save_var display_scroll_bar = 1;
	if (!GET_BORD(BRIGHT, obord))	// make right border if not one now
		set_wattrib(window_handle, PBORDERS, obord
			    | (BORD(BRIGHT, -1) & tiled_border));
	for (;;) {
		refresh();
		getkey();
		if (key == MOUSE_MOVE && over_scroll_bar() != window_handle) {
			mouse_cursor = &std_pointer;
			while (over_scroll_bar() == -1)
				if (char_avail() && getkey() != MOUSE_MOVE
				    || ABS(mouse_x - origx) > 4)
					break;
			mouse_cursor = &right_pointer;
		}
		if (over_scroll_bar() != window_handle)
			break;		// still not on this scroll bar
		if (IS_MOUSE_LEFT(key) || IS_MOUSE_CENTER(key) ||
		    IS_MOUSE_RIGHT(key) && mouse_x >= screen_cols - 1) {
			mouse_scroll_bar();
			ungot_key = MOUSE_MOVE;
		} else if (key != MOUSE_MOVE)
			break;
	}
	set_wattrib(window_handle, PBORDERS, obord);
	restore_vars();
	refresh();
	ungot_key = key;
}

delay_scroll_bar()	// did mouse stay over scroll bar for a while?
{
	TIMER ts;

	time_begin(&ts, 10);
	while (!time_done(&ts))
		if (char_avail() && (getkey() != MOUSE_MOVE
				     || over_scroll_bar() != window_handle)) {
			ungot_key = key;
			return 0;
		}
	return 1;
}

on_scroll_bar()		// do we want to use scroll bar cursor here?
{
	if (is_window(window_handle) == ISPOPUP)
		return window_handle == window_to_scroll() && bar_on_border();
	else if (!permit_scroll_bar_border())
		return 0;
	else
		return bar_on_edge() || bar_on_border();
}

over_scroll_bar()	// are we over any sort of scroll bar?
{			// if so, give win handle, else -1
	return (mouse_x >= screen_cols - 1 || bar_on_border())
			? window_to_scroll() : -1;
}

mouse_y_in_range()	// mouse_y adjusted to valid screen pos
{
	return (mouse_y >= screen_lines) ? screen_lines - 1 :
			(mouse_y < 0) ? 0 : mouse_y;
}

window_to_scroll()	// which window will we scroll?
{
	return window_at_coords(mouse_y_in_range(), bar_on_edge()
				? (screen_cols - 1) : mouse_x, mouse_screen);
}

bar_on_edge()		// at an edge where we could put up scroll bar?
{
	int win = window_at_coords(mouse_y_in_range(), screen_cols - 1, mouse_screen);

	return (win != -1) && (mouse_x >= screen_cols)
			&& !line_on_border_text(win, mouse_y_in_range());
}

bar_on_border()		// mouse on a scroll bar now?
{
	int win = window_at_coords(mouse_y_in_range(), mouse_x, mouse_screen);
	int bord;

	if (win == -1)
		return 0;
	save_var window_handle = win;
	bord = get_wattrib(window_handle, PBORDERS);
	if (mouse_x != window_right(win) || !GET_BORD(BRIGHT, bord))
		return 0;
	return !line_on_border_text(win, mouse_y_in_range());
}

line_on_border_text(win, sl)	// is a border of window on screen line sl?
{
	int bord = get_wattrib(win, PBORDERS);

	return (sl == get_wattrib(win, BTOP) && GET_BORD(BTOP, bord)
		|| sl == window_bottom(win) && GET_BORD(BBOTTOM, bord));
}

click_in_echo()	/* clicking in echo area does nothing now */
{
}

mouse_over_border(int win, int pos, int side)
{
	return pos == get_wattrib(win, side)
			&& GET_BORD(side, get_wattrib(win, PBORDERS));
}

command mouse_move() on reg_tab[MOUSE_MOVE]
{			/* maybe pop up a menu or something */
	if (!permanent_menu && is_menu_here())
		show_menu_while_over();
	else {
		if (is_gui && !mouse_screen) {
			int win = get_window_area();
			if (mouse_over_border(win, mouse_y, BBOTTOM) &&
				mouse_y + 1 != echo_line
				|| mouse_over_border(win, mouse_y, BTOP))
				mouse_cursor = &vert_arrows;
			else if (mouse_over_border(win, mouse_x, BLEFT)
					 || mouse_over_border(win, mouse_x, BRIGHT))
				mouse_cursor = &horiz_arrows;
			else
				mouse_cursor = &std_pointer;
		} else if (!is_gui && tiled_scroll_bar)
			mouse_cursor = on_scroll_bar() ? &right_pointer
										   : &std_pointer;
		else if (on_scroll_bar())
			show_scroll_bar();
		if (ungot_key == -1 || ungot_key == MOUSE_MOVE)
			invisible_cmd();
	}
}

get_focus() on reg_tab[GETFOCUS], cx_tab[GETFOCUS]
{
	if (mouse_screen) {
		int w = screen_to_window(mouse_screen);
		if (w != -1)
			window_handle = w;
	}
	if (!ignoring_file_change)
		check_dates(0);
}

lose_focus() on reg_tab[LOSEFOCUS], cx_tab[LOSEFOCUS]
{
}

win_resize() on reg_tab[WIN_RESIZE], cx_tab[WIN_RESIZE]
{
}

lost_selection() on reg_tab[LOST_SELECTION], cx_tab[LOST_SELECTION]
{
}

mouse_leaving_window() on reg_tab[WIN_MOUSE_LEAVES], cx_tab[WIN_MOUSE_LEAVES],
						  reg_tab[WIN_MOUSE_ENTERS], cx_tab[WIN_MOUSE_ENTERS]
{
}

mouse_get_another() on cx_tab[MOUSE_MOVE]
{
	while (key == MOUSE_MOVE) {
		table_prompt();
		getkey();
	}
	say("");
	do_again();
}

#ifdef LEFTPTR_NOT_BUILT_IN	/* this is actually built-in */
volatile MOUSE_CURSOR std_pointer = {
	{
		0b00000000,
		0b01000000,
		0b01100000,
		0b01110000,
		0b01111000,
		0b01111100,
		0b01111110,
		0b01111111,
		0b01111000,
		0b01001100,
		0b00001100,
		0b00000110,
		0b00000110,
		0b00000000,
		0b00000000,
		0b00000000,
	}, {
		0b11000000,
		0b11110000,
		0b11111000,
		0b11111100,
		0b11111110,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b00011111,
		0b00001111,
		0b00000111,
		0b00000000,
		0b00000000,
	},
		2, 2,
};
#endif

volatile MOUSE_CURSOR left_pointer = {
	{
		0b00000000,
		0b01000000,
		0b01100000,
		0b01110000,
		0b01111000,
		0b01111100,
		0b01111110,
		0b01111111,
		0b01111000,
		0b01001100,
		0b00001100,
		0b00000110,
		0b00000110,
		0b00000000,
		0b00000000,
		0b00000000,
	}, {
		0b11000000,
		0b11110000,
		0b11111000,
		0b11111100,
		0b11111110,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b00011111,
		0b00001111,
		0b00000111,
		0b00000000,
		0b00000000,
	},
		2, 2,
		CURSOR_ARROW
};

volatile MOUSE_CURSOR drag_and_drop_pointer = {
	{
		0b00000000,
		0b01000000,
		0b01100000,
		0b01110000,
		0b01111000,
		0b01111100,
		0b01111110,
		0b01111111,
		0b01111000,
		0b01001100,
		0b00001100,
		0b00000110,
		0b11100110,
		0b11100000,
		0b11100000,
		0b00000000,
	}, {
		0b11000000,
		0b11110000,
		0b11111000,
		0b11111100,
		0b11111110,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111000,
		0b11111000,
	},
		2, 2,
		CURSOR_ARROW
};

volatile MOUSE_CURSOR right_pointer = {
	{
		0b00000000,
		0b00000010,
		0b00000110,
		0b00001110,
		0b00011110,
		0b00111110,
		0b01111110,
		0b11111110,
		0b00011110,
		0b00110010,
		0b00110000,
		0b01100000,
		0b01100000,
		0b00000000,
		0b00000000,
		0b00000000,
	}, {
		0b00000011,
		0b00001111,
		0b00011111,
		0b00111111,
		0b01111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111000,
		0b11110000,
		0b11100000,
		0b00000000,
		0b00000000,
	},
		6, 2,
		CURSOR_IBEAM
};

volatile MOUSE_CURSOR horiz_arrows = {
	{
		0b00011000,
		0b00110000,
		0b01100000,
		0b11111111,
		0b01100000,
		0b00110000,
		0b00011000,
		0b00000000,
		0b00011000,
		0b00001100,
		0b00000110,
		0b11111111,
		0b00000110,
		0b00001100,
		0b00011000,
		0b00000000,
	}, {
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
	},
		4, 8,
		CURSOR_SIZEWE
};

volatile MOUSE_CURSOR vert_arrows = {
	{
		0b00000000,
		0b00011000,
		0b01111110,
		0b11011011,
		0b00011000,
		0b00011000,
		0b00011000,
		0b00000000,
		0b00000000,
		0b00011000,
		0b00011000,
		0b00011000,
		0b11011011,
		0b01111110,
		0b00011000,
		0b00000000,
	}, {
		0b00111100,
		0b01111110,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b01111110,
		0b00111100,
		0b00000000,
		0b00000000,
	},
		4, 8,
		CURSOR_SIZENS
};

volatile MOUSE_CURSOR move_arrows = {
	{
		0b00000000,
		0b00011000,
		0b01111110,
		0b11011011,
		0b00011000,
		0b00011000,
		0b00011000,
		0b00000000,
		0b00011000,
		0b00110000,
		0b01100000,
		0b11111111,
		0b01100000,
		0b00110000,
		0b00011000,
		0b00000000,
	}, {
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
	},
		4, 8,
		CURSOR_ARROW
};

volatile MOUSE_CURSOR pan_neutral = {
	{
		0b00000000,
		0b00011000,
		0b01111110,
		0b11011011,
		0b00011000,
		0b00011000,
		0b00011000,
		0b00000000,
		0b00000000,
		0b00011000,
		0b00011000,
		0b00011000,
		0b11011011,
		0b01111110,
		0b00011000,
		0b00000000,
	}, {
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
	},
		4, 8,
		CURSOR_PAN
};

volatile MOUSE_CURSOR pan_up = {
	{
		0b00000000,
		0b00011000,
		0b01111110,
		0b11011011,
		0b00011000,
		0b00011000,
		0b00011000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
	}, {
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
	},
		4, 8,
		CURSOR_PAN_UP
};

volatile MOUSE_CURSOR pan_down = {
	{
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00011000,
		0b00011000,
		0b00011000,
		0b11011011,
		0b01111110,
		0b00011000,
		0b00000000,
	}, {
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b00000000,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
	},
		4, 8,
		CURSOR_PAN_DOWN
};

int _orig_thumb = -1, _orig_pos;

end_scroll()
{
	_orig_thumb = -1;
}

unix_scroll_thumb_track(int w, int thumb, int maxval)
{
	if (_orig_thumb == -1 || w == SCROLL_THUMB) {
		_orig_thumb = thumb;	// starting to scroll
		_orig_pos = point;
		return;
	}
	if (scroll_bar_type != 1) {		// fast character-based scroll bar
		point = _orig_pos + muldiv(size(), thumb - _orig_thumb, maxval);
		window_start = prev_screen_line(text_height() / 2);
		return;
	}
	go_line(thumb + 1);
	window_start = point;
	if (thumb >= maxval)
		point = size();
	else if (thumb > 0)
		point = next_screen_line(text_height() / 2);
	else
		point = 0;
	move_to_column((point > 0 && goal_column >= 0) ? goal_column : 0);
}

scroll_thumb_track(int thumb, int maxval)
{
	int s = size();

	if (thumb == 0){
		point = 0;
		return;
	} else if (thumb == maxval){
		point = s;
		return;
	}

	if (scroll_bar_type == 1 && is_win32 == IS_WIN32_GUI) {
		if (_orig_thumb == -1){		// line-based scroll bar
			_orig_thumb = thumb;
			_orig_pos = lines_between(0, window_start, 0) + 1;
			return;
		}

		go_line(_orig_pos + muldiv(lines_between(0, size(), 0)
								   - text_height() / 2,
								   thumb - _orig_thumb, maxval));
		window_start = point;
		point = next_screen_line(text_height() / 2);
		move_to_column((point > 0 && goal_column >= 0) ? goal_column : 0);
		return;
	}

	if (_orig_thumb == -1){
		_orig_thumb = thumb;
		_orig_pos = point;
		return;
	}

// Compute the amount to move;
	point = _orig_pos + muldiv(s, thumb - _orig_thumb, maxval);
	if (point > 0 && goal_column >= 0)
		move_to_column(goal_column);
	else
		to_begin_line();
	window_start = prev_screen_line(text_height() / 2);
}

scrollbar_handler(w, thumb, maxval, screen)
int w, thumb, maxval, screen;
{
	save_var iter = 1, has_arg = 0;
	if (screen) {
		int win =  screen_to_window(screen);
		if (win != -1)
			window_handle = win;
		else			// Window to scroll no longer exists.
			return;
	}
	switch(w){
		case SCROLL_UPARROW: scroll_down(); break;	// pressed arrow at top
		case SCROLL_DOWNARROW: scroll_up(); break;	// pressed arrow at bottom
		case SCROLL_PAGEUP: previous_page(); break;
		case SCROLL_PAGEDOWN: next_page(); break;
		case SCROLL_TOTOP: goto_beginning(); break;
		case SCROLL_TOBOT: goto_end(); break;
		case SCROLL_END: end_scroll(); break;
		case SCROLL_THUMBPOS:
		case SCROLL_THUMB:	if (is_unix)
								unix_scroll_thumb_track(w, thumb, maxval);
							else
								scroll_thumb_track(thumb, maxval);
							break;
		default: note("unimplemented scroll message: 0x%x thumb=%d, max=%d",
			      w, thumb, maxval);
	}
	set_display_func_name();
	refresh();
}

// Rotating the wheel on an IntelliMouse calls this.
// Epsilon calls this function directly, then optionally (see
// the permit_window_keys flag PERMIT_WHEEL_KEY) sends a
// WIN_WHEEL_KEY.

scroll_by_wheel(clicks, per_click)
{
	if (wheel_click_lines >= 0)		// Override control panel setting?
		per_click = wheel_click_lines;
	if (per_click < 1 || per_click >= text_height())
		per_click = text_height() - 1;	// scroll by pages
	window_scroll(clicks * per_click);
	set_display_func_name();
	redisplay();
}

// Ignore the wheel key; it's already been handled.
mouse_wheel_key() on reg_tab[WIN_WHEEL_KEY], cx_tab[WIN_WHEEL_KEY]
{
}

// Let the mouse's position relative to the origin control
// the speed of continuous scrolling.

command mouse_center() on reg_tab[MOUSE_CENTER_DN], reg_tab[MOUSE_DBL_CENTER]
{
	if (interpret_mouse_variable(mouse_center_yanks))
		mouse_yank();
	else
		mouse_pan();
}

command mouse_yank()
{
	if (mouse_other_handler())
		return;
	else if (!in_text_area(mouse_x, mouse_y)) // clicked in border
		mouse_move_border(0);
	else {
		highlight_off();
		to_mouse_window(mouse_x, mouse_y, mouse_screen);
		to_mouse_position(mouse_x, mouse_y);
		yank();
	}
}

command mouse_pan()
{
	TIMER ts;
	int rate, per_elem, dir, lines, delay, repaint_speed = 1;
	int before, we_moved = 0;

//	clip_mouse();
//	to_mouse_window(mouse_x, mouse_y, mouse_screen);

	save_var mouse_cursor;
	save_var mouse_panning = 1;
	save_var mouse_mask |= MASK_UP;
	save_var permit_window_keys |= PERMIT_WHEEL_KEY;

	time_begin(&ts, 0);
	for (;;) {
		if (char_avail()) {		// If a key or mouse event arrives, stop.
			getkey();			// But if we've clicked the mouse button
			if (key != MOUSE_MOVE && (!IS_MOUSE_UP(key) || we_moved))
				break;			// without moving, continue (auto-scroll).
		}		// Otherwise, exit (unless it's just mouse movement).

		rate = mouse_panning_rate(40, 2000, 1); // Screen range, max, min.
						// Get scroll speed (lines/millisec).
		if (!rate) {					// Don't scroll right now.
			mouse_cursor = &pan_neutral;
			continue;
		} else if (rate > 0)
			mouse_cursor = &pan_down;
		else
			mouse_cursor = &pan_up;
		we_moved = 1;		// Distinguish panning from auto-scroll.

		per_elem = (rate > 0) ? rate : -rate;
		dir = (rate > 0) ? 1 : -1;
		if (per_elem > repaint_speed) {		// Scroll slower than we could,
			lines = 1;						// even going line by line.
			delay = per_elem - repaint_speed;
		} else {		// Faster scroll--do multiple lines at once.
			lines = (repaint_speed + per_elem - 1) / per_elem;
			delay = per_elem * lines - repaint_speed;
		}
		if (time_remaining(&ts) > delay / 10)	// Moved to a faster rate,
			time_begin(&ts, delay / 10);		// so skip some delaying.

		if (!time_done(&ts))		// Time for the next scroll?
			continue;

		before = time_ms();
		window_scroll(dir * lines);	// Now scroll, then prepare to delay.
		set_display_func_name();
		redisplay();
		time_begin(&ts, delay / 10);
		repaint_speed = time_ms() - before;	// Time taken for one refresh.
	}
}


// Retrieve a drag-drop file name, a DDE message, or some other sort of
// message from another instance of Epsilon or a helper program.

// The DDE message can be part of a command-line argument
// sent from another copy of Epsilon using the -add flag,
// or from another program.  It can be a file name (optionally
// preceded by +linenum), or the flags -dVARNAME=VALUE to set
// an Epsilon variable, -lFILENAME to load an EEL bytecode file,
// or -rFUNCNAME to run an EEL function.
// The WIN_DRAG_DROP key must be bound to a function named
// drag_drop_handler() for correct DDE/drag-drop functioning.

drag_drop_handler() on reg_tab[WIN_DRAG_DROP]
{
	char buf[FNAMELEN], *s, dir[FNAMELEN];
	int line = -1, column = -1, j, dir_flags = directory_flags, first = 1;

	tiled_only();
	if (mouse_screen >= 0)
		to_mouse_window(mouse_x, mouse_y, mouse_screen);
	while (j = drag_drop_result(buf)){
		if (*buf == '+') {			// a +linenum parameter
			line = numtoi(buf + 1);
			s = strchr(buf, ':');
			if (s)
				column = numtoi(s + 1);
		} else if (*buf == '-') {
			switch (buf[1]) {
				case 'd':
					s = index(buf + 2, '=');
					if (!s)		// accept either VAR=VAL or VAR!VAL
						s = index(buf + 2, '!');
					if (!s)
						break;
					*s = 0;
					if (j = find_index(buf + 2)) {
						set_var_val(j, s + 1, 1);
						continue;
					} else
						say("No such variable %s.", buf + 2);
					break;
				case 'l':
					load_commands(buf + 2);
					break;
				case 'r':
					try_calling(buf + 2);
					break;
				case 'w':
					dir_flags = numtoi(buf + 2);
					break;
			}
			continue;
		} else if (*buf) {
			absolute(buf);
			if (is_directory(buf) || is_remote_file(buf) || (is_pattern(buf) & 2))
				do_find(buf, default_translation_type);
			else
				find_it(buf, default_translation_type);
			if (line >= 0) {
				go_line(line);
				line = -1;
			}
			if (column >= 0) {
				move_to_column(column);
				column = -1;
			}
			if ((dir_flags & DIR_CWD_FROM_FILE) && first) {
				strcpy(dir, buf);
				*get_tail(dir, 1) = 0;
				chdir(dir);
			}
			first = 0;
			if (j == 2)
				say("Use Alt-x resume-client to release the Epsilon client when you finish.");
		}
	}
}

drag_drop_repeat() on cx_tab[WIN_DRAG_DROP]
{
	drag_drop_handler();
	table_prompt();
	getkey();
	say("");
	do_again();
}

command resume_client()
{
	if (is_unsaved_buffer() && ask_save_buffer())
		do_save_file(1, 1, 1);
	do_resume_client();
}

set_mouse_keys(table)	// set up event keys for a table like cx_tab
short *table;
{
	table[MOUSE_MOVE] = (short) mouse_get_another;
	table[GETFOCUS] = (short) get_focus;
	table[LOSEFOCUS] = (short) lose_focus;
	table[WIN_RESIZE] = (short) win_resize;
	table[LOST_SELECTION] = (short) lost_selection;
	table[WIN_MOUSE_LEAVES] = (short) mouse_leaving_window;
	table[WIN_WHEEL_KEY] = (short) mouse_wheel_key;
	table[WIN_DRAG_DROP] = (short) drag_drop_repeat;
}

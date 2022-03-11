/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1983, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

// This file has commands relating to screen windows.

#include "eel.h"

/* Center the current line, or make it the line specified by the argument. */
/* If the argument is too large, put it at the bottom of the window. */

command center_window() on reg_tab[CTRL('L')], reg_tab[NUMDIGIT(5)]
{
	if (has_arg) {
		if (iter < 0)
			iter = 0;
		else if (iter >= text_height())
			iter = text_height() - 1;
		window_start = prev_screen_line(iter);
		iter = 0;
	} else {
		window_start = prev_screen_line(text_height() / 2);
		if (prev_cmd == CTR_WINDOW)
			screen_messed();
		this_cmd = CTR_WINDOW;
	}
	build_first = 1;
	say("");
}

command line_to_top()		// scroll current line to top of window
{
	window_start = prev_screen_line(0);
}

command line_to_bottom()	// scroll current line to bottom of window
{
	window_start = prev_screen_line(text_height() - 1);
}

move_by_screen_lines(pos, n)	// return start of screen line n away
{				// n may be positive or negative
	save_var point = pos;

	return (n > 0) ? next_screen_line(n) : prev_screen_line(-n);
}

move_by_pages(dir)	// page up or down by one page
{
	int col, wide = window_width - 1, n;

	if (prev_cmd != SAMECOL)
		_preserve_column = virtual_space ? virtual_column()
					: current_column();
	if (window_overlap < 0)
		n = ((100 - (-window_overlap)) * text_height()) / 100;
	else
		n = text_height() - window_overlap;
	if (n < 1)
		n = 1;
	n *= dir;		// move by n lines
	window_start = move_by_screen_lines(window_start, n);
	if (paging_centers_window)	// go halfway down window
		point = move_by_screen_lines(window_start, text_height() / 2);
	else				// go one screenful from orig place
		point = move_by_screen_lines(point, n);
	col = (goal_column >= 0) ? goal_column : _preserve_column;
	if (virtual_space)
		to_virtual_column(col);
	else {
		if (display_column < 0)	/* move to same screen column */
			col = (col % wide) + (current_column() / wide) * wide;
		move_to_column(col);
	}
}

command previous_page() on reg_tab[ALT('v')], reg_tab[KEYPGUP]
{
	do_shift_selects();
	this_cmd = SAMECOL;
	if (window_start == narrow_start) {	/* top of page */
		if (paging_centers_window)
			point = 0;
		return 1;
	}
	move_by_pages(-1);
	return 0;
}

command next_page() on reg_tab[CTRL('V')], reg_tab[KEYPGDN]
{
	do_shift_selects();
	this_cmd = SAMECOL;
	if (window_end == size() - narrow_end) {
		if (paging_centers_window)
			point = size();		/* no more pages */
		return 1;
	}
	move_by_pages(1);
	return 0;
}

command scroll_left() on reg_tab[ALT('{')]
{
	int old = display_column < 0, col;
	char *msg;

	display_column += iter;
	iter = 0;
	build_first = 1;
	if (display_column < 0) {
		display_column = -1;
		msg = "Long lines wrap";
	} else {
		msg = "Horizontal scrolling is on";
		col = current_column();
		if (col < display_column) {
			move_to_column(display_column);
			if ((col = current_column()) < display_column)
				display_column = col;
		} else if (col >= text_width() + display_column)
			move_to_column(text_width() + display_column - 1);
		fix_window_start();
	}
	if (old != (display_column < 0))
		say(msg);
}

command scroll_right() on reg_tab[ALT('}')]
{
	iter = -iter;
	scroll_left();
}

// Move to this column, then maybe scroll horizontally to display it.

to_column_and_center(int col)
{
	move_to_column(col);
	if (display_column >= 0)
		if (current_column() < text_width() - 3)
			display_column = 0;
		else
			display_column = MAX(current_column() - text_width() / 2, 0);
}

command jump_to_column() on reg_tab[ALT('g')]
{
	to_column_and_center(get_number("Jump to column: "));
}

command page_left() on reg_tab[NUMALT(KEYPGUP)], reg_tab[NUMALT(NUMDIGIT(9))]
{
	to_column_and_center(current_column() - text_width() / 2);
}

command page_right() on reg_tab[NUMALT(KEYPGDN)], reg_tab[NUMALT(NUMDIGIT(3))]
{
	to_column_and_center(current_column() + text_width() / 2);
}

command change_line_wrapping()
{
	display_column = has_arg ? iter : (display_column >= 0) ? -1 : 0;
	if (display_column < 0)
		say("Long lines wrap");
	else
		say("Horizontal scrolling is on");
}

command beginning_of_window() on reg_tab[ALT(',')], reg_tab[KEYHOME]
{
	do_shift_selects();
	point = window_start;
}

command end_of_window() on reg_tab[ALT('.')], reg_tab[KEYEND]
{
	do_shift_selects();
	point = window_end;
}

command to_left_edge()
{
	to_virtual_column(MAX(display_column, 0));
}

command to_right_edge()
{
	to_virtual_column(MAX(display_column, 0) + text_width() - 1);
}

fix_window_start()	/* if 1st char of win is in middle of line, fix it */
{
	int oldedge = narrow_start;

	if (window_start <= narrow_start
				|| character(window_start - 1) == '\n')
		return;
	save_var point = window_start;
	save_var narrow_start = point - screen_cols;	/* not too far */
	if (nl_reverse())
		window_start = point + 1;
	else if (point <= oldedge)
		window_start = oldedge;
}

/* Make the current window taller by raising the top line.
   If not possible, lower the bottom line. */
command enlarge_window() on reg_tab[NUMCTRL(KEYPGUP)], cx_tab['^']
{
	window_height++;
}


/* Make the current window shorter by lowering the top line.
   If not possible, raise the bottom line. */
command shrink_window() on reg_tab[NUMCTRL(KEYPGDN)]
{
	window_height--;
}

/* Make the current window wider by moving the left-hand border to the right.
   If not possible, move the right border. */
command enlarge_window_horizontally() on cx_tab['@']
{
	window_width++;
}


/* Make the current window narrower by moving the left-hand border
   farther left.  If not possible, move the right border. */
command shrink_window_horizontally()
{
	window_width--;
}


command next_window() on cx_tab['n'], cx_tab['o'], reg_tab[NUMALT(KEYEND)],
						 reg_tab[NUMALT(NUMDIGIT(1))]
{
	to_next_user_window(1);
}

command previous_window() on cx_tab['p'], reg_tab[NUMALT(KEYHOME)],
							 reg_tab[NUMALT(NUMDIGIT(7))]
{
	to_next_user_window(-1);
}

to_next_user_window(dir)	// permanently switch to next window
{
	tiled_only();
	next_user_window(dir);
	switching_to_buffer();
	check_dates(0);
}

next_user_window(dir)	/* go to next non-system window in dir */
{
	int i = 30;	// if no good windows, give up eventually

	do {
		window_number += dir;
	} while (system_window && i-- > 0);
}

number_of_user_windows()
{
	return number_of_windows() - (!is_gui && (permanent_menu != 0));
}

// An alternative command for Ctrl-Tab (reg_tab[NUMCTRL(GREYTAB)]).
command switch_windows()
{
	to_next_user_window(was_key_shifted() ? -1 : 1);
}

get_direction()		/* convert keys to direction code */
{			/* or -1 */
	int k = key;

	if (k < 512)
		k &= 255;
	else if (IS_TRUE_KEY(k))
		k = NUMPLAIN(k);
	switch (k) {
		case KEYUP: case CTRL('P'): case NUMDIGIT(8): case '8':
			return BTOP;
		case KEYDOWN: case CTRL('N'): case NUMDIGIT(2): case '2':
			return BBOTTOM;
		case KEYLEFT: case CTRL('B'): case NUMDIGIT(4): case '4':
			return BLEFT;
		case KEYRIGHT: case CTRL('F'): case NUMDIGIT(6): case '6':
			return BRIGHT;
	}
	return -1;
}

command move_to_window() on cx_tab[KEYLEFT], cx_tab[KEYRIGHT],
			cx_tab[KEYUP], cx_tab[KEYDOWN]
{
	int dir, edge, row, col, max_cols = screen_cols;

	tiled_only();
	while ((dir = get_direction()) == -1) {
		say("Move to window (press an arrow key)");
		getkey();
		check_abort();
	}
	edge = get_wattrib(window_number, dir);
	get_window_pos(point, &row, &col);	/* get pt's window coords */
	row += window_top;		/* convert to screen coords */
	col += window_left;
	switch (dir) {
		case BTOP:	row = edge - 1; break;
		case BBOTTOM:	row = edge + 1; break;
		case BLEFT:	col = edge - 1; break;
		case BRIGHT:	col = edge + 1; break;
	}				/* now adjust to screen bounds */
	if (is_gui && col == screen_cols && (dir == BTOP || dir == BBOTTOM))
		col--;			// Cursor can be after all characters.
	row = (row + screen_lines - 1) % (screen_lines - 1);
	col = (col + max_cols) % max_cols;
	window_handle = window_at_coords(row, col);
	say("");
	switching_to_buffer();
	check_dates(0);
}

command enlarge_window_interactively() on cx_tab['+'], cx_tab[GREYPLUS]
{
	resize_window_interactively(1);
}

command shrink_window_interactively() on cx_tab['-'], cx_tab[GREYMINUS]
{
	resize_window_interactively(0);
}

resize_window_interactively(grow)
{
	int dir;

	for (;;) {
		say("Use arrow keys to %s this window, press %c to %s, "
			"<Enter> when done.",
			grow ? "enlarge" : "shrink", "+-"[grow],
			grow ? "shrink" : "enlarge");
		getkey();
		check_abort();
		dir = get_direction();
		if (dir >= 0)
			alter_window_size(window_handle, dir, grow);
		if (binding_of(key, root_keys) == (short) help
			  || key == 'h' || key == '?')
			help_on_command("enlarge-window-interactively");
		switch (key) {
			case GREYPLUS:
			case '+':	grow = 1; break;
			case GREYMINUS:
			case '-':	grow = 0; break;
			case ' ':
			case GREYENTER:
			case '\n':
			case '\r':	say("");
					return;
		}
		maybe_refresh();
	}
}

alter_window_size(w, edge, grow)
{
	int val;

	if (!grow)
		edge ^= 2;	/* swap left & right, top & bottom */
	val = get_wattrib(w, edge);
	if (edge == BTOP || edge == BLEFT)
		grow = !grow;
	if (grow)
		val++;
	else
		val--;
	set_wattrib(w, edge, val);
}

command kill_window() on cx_tab[CTRL('D')], cx_tab['0']
{
	iter = 0;
	window_kill();
	switching_to_buffer();
	check_dates(0);
}

command one_window() on cx_tab['1']
{
	int menu = permanent_menu;
	tiled_only();
	if (menu)
		drop_perm_menu();
	iter = 0;
	window_one();
	if (menu)
		make_perm_menu();
}

command split_window() on cx_tab['2']
{
	iter = 0;
	tiled_only();
	window_split(HORIZONTAL);
}

command split_window_vertically() on cx_tab['5']
{
	iter = 0;
	tiled_only();
	if (display_column.default != -1 && display_column < 0)
		display_column = 0;		/* turn on horiz scrolling in both */
	window_split(VERTICAL);
	if (display_column.default != -1 && display_column < 0)
		display_column = 0;
}

command scroll_up() on reg_tab[CTRL('Z')]
{
	window_scroll(iter);
	iter = 0;
}

command scroll_down() on reg_tab[ALT('z')]
{
	window_scroll(-iter);
	iter = 0;
}

locate_window(buf, file)	 /* go to window with buffer or file */
char *buf, *file;
{
	int orig = window_number;

	bufnum = window_bufnum;
	do {
		if (!system_window && (*buf && !strcmp(bufname, buf)
							   || *file && !fnamecmp(filename, file)
							   && force_save_as != FSA_NEWFILE))
			break;
	} while (++window_number != orig);
	if (*buf)
		to_buffer(buf);
}

// Does the specified buffer appear in any window?  If so, return its
// handle, else -1.
is_buf_in_window(int buf)
{
	int orig = window_number;

	if (buf < 0)
		return -1;
	save_var window_handle;
	bufnum = window_bufnum;
	do {
		if (!system_window && buf == bufnum)
			return window_handle;
	} while (++window_number != orig);
	return -1;
}

// Does the specified buffer appear in any window?  If so, return its
// handle, else -1.
is_buffer_in_window(char *buf)
{
	return is_buf_in_window(name_to_bufnum(buf));
}

tiled_only()	/* a buffer-switching command: make sure we're in a */
{		/* tiled window */
	quit_bufed();	/* just remove a bufed window and continue */
	quit_blist();
	error_if_input(1);	/* if doing input, exit from that command */
	if (is_window(window_handle) == ISPOPUP)
		quick_abort();	/* some odd type of window, abort */
}

window_to_fit(max)	/* adjust window size to display whole buffer */
{
	window_height = max;		/* set to max size */
	build_window();			/* construct it internally */
/* if whole buffer fits in window, shrink by # of blank lines at bottom */
	if (!window_start && window_extra_lines() > 0)
		window_height -= window_extra_lines();
}

// Find width of widest item in buffer; widen window to that.
window_width_to_fit()
{
	int max = screen_cols - 7, w = 0, i;

	save_var point = size();
	do {
		i = current_column();
		if (i > w)
			w = i;
	} while (nl_reverse());
	w += 5;			// Make extra room.
	if (w > max)
		w = max;
	if (w > window_width)
		window_width = w;
}

popup_near_window(popup, tiled) /* adjust popup window's position & size so */
{				/* it's near tiled & as small as possible */
	int old_top;

	save_var window_handle = tiled;
	old_top = window_top;		/* see where tiled win starts */
	window_handle = popup;
	window_top = 2;				/* let popup run from top */
	window_to_fit(screen_lines - 6);	/* to bottom, then shrink */
	if (window_top < old_top) {	/* make popup touch affected win */
		window_top = old_top + 2;	/* move it down */
		window_top--;		/* but keep it out of echo area */
	}
}

// The following functions display different kinds of dialogs.
// The first parameter to display_dialog_box() must be a dialog name that
// Epsilon knows about.

one_window_to_dialog(title, win, b1, b2, b3)
char *title, *b1, *b2, *b3;
{
	do_display_dialog_box("GeneralBox", title, win, 0, 0, b1, b2, b3);
}

prompt_box(title, win1, win2)
char *title;
{
	do_display_dialog_box("PromptBox", title, win1, win2, 0,
						  "OK", "Cancel", "Help");
}

two_scroll_box(title, win1, win2, b1, b2, b3)
char *title, *b1, *b2, *b3;
{
	do_display_dialog_box("EditVarBox", title, win1, win2, 0, b1, b2, b3);
}

do_display_dialog_box(dialog, title, win1, win2, win3, b1, b2, b3)
char *dialog, *title, *b1, *b2, *b3;
{
	if (use_alternate_dialog)
		use_alternate_dialog(win1, win2, win3);
	else
		display_dialog_box(dialog, title, win1, win2, win3, b1, b2, b3);
}

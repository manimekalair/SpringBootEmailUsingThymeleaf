/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1993, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

// This file has the edit-variables command.

#include "eel.h"

when_loading()
{		// list variables for editing; with arg, includes system vars
	int listbuf, orig_buf, orig, part = 1;
	int listwin, helpwin, orig_win, win;
	int setit, origpos, ind, type, hasdef, i, lasthelp;
	TIMER ts;	// for searching in list
	char var[100], partial[100], *val;
	char tmp[FNAMELEN * 2], curval[FNAMELEN * 2];
	jmp_buf this_level;

	tiled_only();
	if (use_winhelp()) {
		if (has_arg)
			win_help_string("", "all variables, list of");
		else
			win_help_string("", "preference variables, list of");
		return;
	}
	orig_buf = bufnum;
	orig_win = window_handle;
	noteput("Listing variables...");
	save_var abort_searching = 0;
	if (has_arg)
		save_var show_all_variables = 1;
	iter = has_arg = lasthelp = 0;
	listbuf = tmp_buf();	// put list of variables here
	bufnum = listbuf;
	add_region(point_spot, point_spot, color_class menu_highlight,
			   REGLINE);
	save_var _nt_filter = BIT(NT_VAR) | BIT(NT_BUFVAR) | BIT(NT_WINVAR)
			      | BIT(NT_BUILTVAR);
	list_matches("", var_match, 0, listbuf);	// construct list of vars
	point = 0;
	listwin = add_popup(_view_left, 1, 30, 9, ALL_BORD(BSINGLE), listbuf);
	set_menu_look(listwin);
	window_title(listwin, BTOP, TITLECENTER, " Variables ");
	mode_keys = menu_tab;
	_window_flags |= HIGHLIGHT_LINE;

	get_doc(0);
	helpwin = add_popup(_view_left, 11,	// put help text here
						MIN(screen_cols - _view_left - _view_right, 80),
						11, _view_border, zap(HELPBUF));

	text_color = (is_gui && want_gui_prompts) ? color_class text : color_class viewed_text;
	display_column = 0;		/* prevent continuation lines */

	restore_vars();		// don't let save_var undo user's changes
	time_begin(&ts, 0);
	while (is_window(listwin) && is_window(helpwin)) {
		setit = 0;		// assume we don't want to set variable
		window_handle = listwin;
		origpos = point;
		to_begin_line();
		grab_full_line(bufnum, var);	// get name of current variable
		ind = find_index(var);
		switch (name_type(ind)) {	// has a default value too?
			case NT_BUFVAR:	hasdef = 1; break;
			case NT_WINVAR: hasdef = 2; break;
			default:	hasdef = 0; break;
		}
		type = vartype(ind);

		if (ind != lasthelp) {	// show info on variable
			window_handle = orig_win; // if buffer/window-specific,
			bufnum = orig_buf;	// get value from before this
			val = get_var_val(ind, curval, 0); // command

			window_handle = helpwin;
			make_var_help(var, orig_buf, orig_win, 1);
			window_to_fit(screen_lines - 15);
			sprintf(tmp, " %s ", var);
			window_title(helpwin, BTOP, TITLECENTER, tmp);
			display_scroll_bar = !window_extra_lines();
			lasthelp = ind;
		}
		window_handle = helpwin;
		build_window();
		window_title(helpwin, BBOTTOM, TITLERIGHT(2), 
					 all_blanks(window_end, size() - narrow_end)
					 ? "" : " Press <Space> for more ");
		window_handle = listwin;
//		do {			// prompt for a key
			maybe_refresh();
			note("Select a variable & press <Enter> to set, "
				 "<Esc> when done, ? for help.");
			i = permit_window_keys;
			permit_window_keys = PERMIT_SCROLL_KEY;
			getkey();
			permit_window_keys = i;
//		} while (!IS_TRUE_KEY(key) && !IS_MOUSE_DOWN(key));
		if (key == ESC || user_abort || key == abort_key)
			break;
		else if (IS_MOUSE_DOWN(key)) {
			win = window_at_coords(mouse_y, mouse_x, mouse_screen);
			if (is_window(win) != ISPOPUP)
				break;
			window_handle = win;
			get_text_area(win);
			if (in_text_area(mouse_x, mouse_y)) {
				point_to_pos(mouse_x, mouse_y, mouse_screen);
				if (win == listwin && IS_MOUSE_DOUBLE(key))
					setit = 1;
				else if (win == helpwin)
					key = KEYPGDN;
			} else if (display_scroll_bar && bar_on_border())
				mouse_scroll_bar();
			else
				continue;
		} else if (is_search_dir()) {
			save_var top_level = &this_level;
			if (!setjmp(top_level))	// come here on abort
				do_again();	// let search cmds run normally
			restore_vars();
			continue;
		}
		if (!isdigit(key))	// do arrow keys, C-n, etc.
			switch (get_direction()) {
				case BTOP:
					if (!nl_reverse()) point = size();
					break;
				case BBOTTOM:
					if (!nl_forward()) point = 0;
					break;
			}
		switch (key) {
			case KEYHOME:
			case NUMDIGIT(7): point = 0; break;
			case KEYEND:
			case NUMDIGIT(1): point = size(); break;
			case KEYPGDN:
			case NUMDIGIT(3): next_page(); break;
			case KEYPGUP:
			case NUMDIGIT(9): previous_page(); break;
			case GREYENTER:
			case '\n':
			case '\r':
				setit = 1; break;
			case ' ':
				window_handle = helpwin;
				next_page();
				break;
			case '\b':
			case GREYBACK:
				if (!time_done(&ts)) { // backsp in srch
					if (part > 1)
						part--;
					goto search_for;
				}
				window_handle = helpwin; // or scroll help
				previous_page();
				break;
			default:
				if (binding_of(key, root_keys) == (short) help
				    || key == '?') {
					help_on_command("edit-variables");
					lasthelp = 0;
				} else if (key >= ' ' && key <= '~') {
					if (time_done(&ts))
						part = 1; // new search
					partial[part++] = key;
search_for:				orig = point, point = 0;
					partial[0] = '^';
					partial[part] = 0;
					save_var see_delay = new_search_delay;
					say("Searching for %s", partial+1);
					restore_vars();
					if (do_searching(FOLD|REGEX, partial)
					    != 1)
						point = orig;
					time_begin(&ts, new_search_delay);
				} else if (IS_WIN_KEY(key) || key == '\t' || key == BACKTAB) {
					run_topkey();
				} else if (IS_TRUE_KEY(key)
					 && !setit && point == origpos) {
					maybe_ding(bell_on_bad_key);
				}
				break;
		}
		if (setit) {		// user wants to set a variable
			refresh();
			part = 1;	// reset searcher
			ungot_key = CTRL('S');	// bring in default value
			save_var top_level = &this_level;
			i = 0;
			if (setjmp(top_level))	// come here on abort
				i = 1;		// and record it
			else if (is_gui && want_gui_prompts)
				get_strpopup(tmp, var, val, var);
			else
				get_strnone(tmp, "New value: ", val);
			restore_vars();
			if (i)		// aborted
				continue;
			if (type <= TYPE_INT) {
				numtoi(tmp);
				if (got_bad_number)
					continue;
			}
			i = 0;		// assume current val only
			if (is_gui && want_gui_prompts && hasdef)
				i = 1;			// assume set both, for now
			else if (hasdef) {
				sayput("Set D=default value of %s, C=current"
				       " value, or B=both? [B]", var);
				getkey();
				if (user_abort)
					continue;
				if (toupper(key) == 'D')
					i = -1;
				else if (toupper(key) != 'C')
					i = 1;	// set current & default
			}
			window_handle = orig_win;
			bufnum = orig_buf;
			if (i >= 0)
				set_var_val(ind, tmp, 0);
			if (i)
				set_var_val(ind, tmp, 1);
			full_redraw = 1; // might have set a display-type var
			lasthelp = 0;	// refresh help win
		}
	}
	say("");
	if (is_window(orig_win))
		window_handle = orig_win;
	remove_window(listwin);
	remove_window(helpwin);
	buf_delete(listbuf);
	delete_buffer(HELPBUF);
	user_abort = 0;
}

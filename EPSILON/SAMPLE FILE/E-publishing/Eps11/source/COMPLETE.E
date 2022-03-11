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

// This file has subroutines for name completion, and for getting a
// line of input from the user with no completion.

#include "eel.h"

comp_read(trystr, prmpt, finder, flags, def)
char *trystr, *prmpt;
char *(*finder)();
char *def;		/* default value */
{
	int oldbuf, editbuf, ocmd_len = cmd_len, olen_def_mac = _len_def_mac;
	int skipped_redisp = char_avail();

	save_var postpone_asynchronous_notify = 1;
	error_if_input(1);
	*trystr = 0;
	if (run_by_mouse && ungot_key == -1 && finder
		&& ((flags & MUST_MATCH) || show_mouse_choices))
		ungot_key = '?';
	else if (insert_default_response)
		strcpy(trystr, def);
	save_var iter, has_arg, this_cmd, prev_cmd;
	save_var return_raw_buttons = 0;
	save_var permit_window_keys |= PERMIT_WHEEL_KEY;
	if ((flags & COMP_FILE) && !completion_literal_char)
		save_var completion_literal_char = literal_if_quoted;
	_grab_word_loc = point;
	_grab_word_start = 0;
	prompt_orig_buf = oldbuf = bufnum;
	editbuf = bufnum = tmp_buf();
	stuff(trystr);
	full_comp_read(trystr, prmpt, finder, flags, editbuf, def);
	bufnum = oldbuf;
	buf_delete(editbuf);
	if (_len_def_mac >= 0)	// now treat as one big cmd
		cmd_len = ocmd_len + _len_def_mac - olen_def_mac;
	check_abort();
	hide_auto_show_delimiter();
	if (!skipped_redisp)		// skipped before, so skip now
		maybe_refresh();
	if (!(flags & PASSWORD_PROMPT))
		save_completion(trystr, finder);
	if (flags & COMP_FILE)
		drop_quotes(trystr);
	say("");
}

full_comp_read(trystr, prmpt, finder, flags, edit, def)
char *trystr, *prmpt, *def;
char *(*finder)();
{
	int i, j, num_match = 0, maxlen = ptrlen(trystr) - 1, pbuf, res;
	int pwin, editwin, owin = window_handle;
	int olen = 0, in_menu = 0, menu = -1, mbuf = 0;
	jmp_buf this_level;
	int *(*lister)();
	char password_display_class[256];

	save_var last_index;
	save_var _help_on_cmd = last_index;
	save_var _doing_input = DI_LINEINPUT;
	save_var _doing_completion = (finder != 0);
	save_var top_level = &this_level;

	while (!in_macro() && !char_avail() && unseen_msgs())
		check_abort();	// Wait for unseen msgs to display so we don't cover them.
	pwin = add_popup(0, echo_line, screen_cols - 1, 1, 0,
		pbuf = tmp_buf());	/* make system window with prompt */
	stuff(prmpt);
	i = current_column();
	system_window = 1;	/* don't let user switch to it */
	point = display_column = 0;
	text_color = color_class echo_area;
	_display_class = _echo_disp_class;

	editwin = add_popup(i, echo_line, screen_cols - i, 1,
							0, edit);
	display_column = 0;	/* horizontally scroll this window */
	text_color = color_class echo_area;
	_display_class = _echo_disp_class;
	if (flags & PASSWORD_PROMPT) {
		memset(password_display_class, '*', 256);
		_display_class = password_display_class;
		build_first = 1;
		save_var disable_recording_last_keys = 1;
	}
	mouse_handler = allow_mouse_switching;
	if (insert_default_response == 1) {
		highlight_on();
		shift_selecting = 2;
	}
	if ((flags & POP_UP_PROMPT) && (has_feature & FEAT_GUI_DIALOGS)) {
		remove_window(pwin);
		do_display_dialog_box("OneLineBox", prmpt, editwin, 0, 0,
							  "OK", "Cancel", "Help");
	}
	maybe_refresh();
	if (setjmp(top_level)) {
		if (in_menu == 2) {	/* menu is half-created */
			remove_window(menu);
			buf_delete(mbuf);
			in_menu = mbuf = 0;
			if (is_gui && want_gui_prompts) {
				res = INP_ABORT;
				goto done;
			}
		}
	}
	for (;;) {
		window_handle = menu;
		if (in_menu && line_gets_highlight())
			make_line_highlight();
		else
			remove_line_highlight();
		window_handle = in_menu ? menu : editwin;
		mode_keys = in_menu ? menu_tab : comp_tab;
		_doing_input = (response_tracks_list && mbuf)
					   ? DI_LISTBOX : DI_LINEINPUT;
		if (_doing_input == DI_LISTBOX) {
			maybe_refresh();
			getkey();
			cmd_result = 0;
			run_topkey();
			res = cmd_result;
		} else
			res = do_recursion();	/* let user edit input */
		if (!is_window(editwin) || in_menu && !is_window(menu)) {
			res = INP_ABORT;
			break;
		} else if (window_handle == (in_menu ? editwin : menu))
			in_menu = !in_menu;
		window_handle = editwin;
		if (res == INP_ADD) {
			window_handle = editwin;
			run_topkey();
			if (search_in_menu) {
				window_handle = editwin;
				grab(0, maxlen, trystr);
				if (strlen(trystr) >= olen) {
					window_handle = menu;
					point = 0;
					if (!col_search(trystr, 0))
						in_menu = 0;
				}
			} else
				in_menu = 0;
		} else if (res == INP_SEEN)
			in_menu = 0;
		else if (res == INP_TO_LIST && mbuf) {
			window_handle = menu;
			in_menu = 1;
		} else if (res == INP_GET || res == INP_GET_EXIT) {
			window_handle = menu;
			get_menu_line(edit);
			window_handle = editwin;
			in_menu = 0;
		} else if (!res) {
			if (_doing_input == DI_LISTBOX)
				if (in_menu) {
					window_handle = menu;
					get_menu_line(edit);
				} else {
					window_handle = editwin;
					grab(0, maxlen, trystr);
					window_handle = menu;
					point = 0;
					col_search(trystr, 0);
				}
			continue;
		}
		restart_file_paths();
		if (res == INP_ABORT || res == INP_GET_EXIT || res == INP_EXIT)
			break;
		else if (res == INP_GRAB_WORD) {
			grab_buffer_word(owin, 0);
			continue;
		} else if (res == INP_GRAB_LINE) {
			grab_buffer_word(owin, 1);
			continue;
		} else if (res == INP_DEFAULT) {
			if (!size())	/* type in default text */
				stuff(def);
			in_menu = 0;
			continue;
		} else if (res == INP_LAST_RECALL) {
			get_last_recall(finder, trystr);
			if (*trystr && !mbuf) {
				delete(0, size());
				stuff(trystr);
			}
			in_menu = 0;
		} else if (res == INP_SHOW_MATCHES || res == INP_RECALL) {
show_matches:		grab(0, maxlen, trystr);	/* typed '?' */
			if (is_highlight_on() || res == INP_RECALL) {
				if (flags & COMP_FILE)
					*get_tail(trystr, 0) = 0;
				else
					*trystr = 0;
				highlight_off();
			}
			olen = strlen(trystr);
			if (!mbuf) {
				menu = new_menu(mbuf = tmp_buf());
				if (is_gui && want_gui_prompts) {
					remove_window(pwin);
					say("");
					make_prompt_box(res == INP_RECALL, prmpt, editwin, menu);
				}
			}
			in_menu = 2;		/* initializing */
			if (res == INP_RECALL)
				lister = list_recalls;
			else if (completion_lister)
				lister = completion_lister;
			else
				lister = list_matches;
			make_menu(menu, trystr, finder, flags, editwin, mbuf, lister);
			in_menu = 1;
			mode_keys = menu_tab;
			cursor_to_column = -1;
		} else if (res == INP_TRY || res == INP_COMPLETE) {
			if (res == INP_TRY && cursor_to_column
						== current_column() + 1)
				break;	/* exactly 1 match last time */
			grab(0, maxlen, trystr);
			i = strlen(trystr);
			num_match = complete(trystr, finder, flags);
			j = strlen(trystr);
			if ((flags & SPACE_VALID) && key == ' ' && trystr[i] == ' '
				  && could_add_space(trystr, finder, flags) == 1)
				i++, num_match++;
			else if (num_match && i != j)
				i = j;
			else if (num_match != 1) {
				if ((flags & SPACE_VALID) && key == ' ' && is_window(menu)
//					  && trystr[i] == ' ' 
// Given dirs c:\program files and c:\programs, this commented-out code
// made selecting the former fail.
					  && could_add_space(trystr, finder, flags)) {
					trystr[i++] = ' ';
				} else {
					maybe_ding(bell_on_completion);
					if (completion_pops_up)
						ungot_key = '?';
				}
			}
			if ((flags & COMP_FILE) && num_match == 1 && i > 0
			    && is_path_separator(trystr[i - 1]))
				num_match++;	/* might be directory */
			trystr[i] = 0;
			buf_zap(edit);
			stuff(trystr);
			if (num_match == 1) {
				if (res == INP_COMPLETE)
					break;	/* <Esc> worked */
				maybe_refresh();
				cursor_to_column = current_column() + 1;
			}
		}
	}
done:
	if (res != INP_ABORT)
		grab(0, maxlen, trystr);
	else if (!user_abort)		/* user deleted edit window */
		user_abort = 1;
	if (res == INP_EXIT && must_match(trystr, finder, flags))
		goto show_matches;
	if (is_window(owin))
		window_handle = owin;
	remove_window(editwin);
	remove_window(pwin);
	buf_delete(pbuf);
	if (mbuf) {
		remove_window(menu);
		buf_delete(mbuf);
	}
}

new_menu(buf)
{
	int menu;

	menu = add_popup(3, 3, menu_width, 2, ALL_BORD(BSINGLE), buf);
	_window_flags |= HIGHLIGHT_LINE;
	display_column = 0;	/* horizontally scroll this window */
	mouse_handler = allow_mouse_switching;
	mouse_dbl_selects = 1;
	make_line_highlight();
	window_title(menu, BTOP, TITLECENTER, " One of the following: ");
	set_menu_look(menu);
	return menu;
}
									
set_menu_look(int win)
{
	display_more_msg(win);
	text_color = (is_gui && want_gui_prompts) ? color_class dialog_gui_text
											  : color_class menu;
	mouse_cursor = &left_pointer;
}

make_prompt_box(is_prev_resp, prmpt, editwin, menu)
char *prmpt;
{
	char title[FNAMELEN];
	int len;

	sprintf(title, "%s%s",
			is_prev_resp ? "Previous responses to " : "", prmpt);
	len = strlen(title);
	if (len > 2 && !strcmp(&title[len - 2], ": "))
		title[len - 2] = 0;
	prompt_box(title, editwin, menu);
}

make_line_highlight()	/* have current line always be highlighted */
{
	if (_line_highlight)
		remove_region(_line_highlight);
	_line_highlight = add_region(point_spot, point_spot,
		color_class menu_highlight, REGLINE);
	modify_region(1, MRCOLOR, color_class overlap_even);
}

remove_line_highlight()
{
	if (_line_highlight) {
		remove_region(_line_highlight);
		_line_highlight = 0;
	}
}

make_menu(menu, trystr, finder, flags, editwin, mbuf, lister)
char *trystr;			/* put up menu */
char *(*finder)();
int *(*lister)();
{
	buf_zap(mbuf);
	window_handle = menu;
	window_height = 2;		/* show just box, no contents */
	window_handle = editwin;
	if (!in_macro() && !(is_gui && want_gui_prompts))
		refresh();		/* let user know we're working */
	window_handle = menu;
	(*lister)(trystr, finder, flags, mbuf);
	buf_delete_final_newlines(mbuf);
	window_to_fit(screen_lines - 7);
	if (resize_menu_list)
		window_width_to_fit();
	return menu;
}

make_recall_id(char *id, char *(*finder)())
{
	char *s, *t;

	if (!recall_id) {
		s = name_name((short) finder);
		sprintf(id, "%s ", s ? s : "string");	// Name_name() reuses
		t = name_name(_help_on_cmd);		// a static area.
		if (t)
			strcat(id, t);
	} else
		strcpy(id, recall_id);
}

list_recalls(trystr, finder, flags, mbuf)
char *trystr, *(*finder)();	/* fill mbuf with list of prev responses */
{
	char id[80], prefix[80];
	int p;

	trystr = trystr;				// Avoid EEL warning--recall doesn't
	flags = flags;					// care what you typed.
	save_var matchstart, matchend;
	window_title(window_handle, BTOP, TITLECENTER,
		     " Previous responses: ");
	make_recall_id(id, finder);
	sprintf(prefix, "^%q: ", id);
	if (exist(OLDRESP)) {
		save_var bufname = OLDRESP;
		save_var point = 0;
		while (re_search(1, prefix)) {
			p = point;
			nl_forward();
			buf_xfer(mbuf, p, point);
		}
		bufnum = mbuf;
		delete_final_newlines();
		to_begin_line();	// start of last (most recent) line
	}
}

get_last_recall(char *(*finder)(), char *result)
{
	char prefix[FNAMELEN], id[FNAMELEN];

	make_recall_id(id, finder);
	*result = 0;
	sprintf(prefix, "^%q: ", id);
	if (exist(OLDRESP)) {
		save_var bufname = OLDRESP;
		save_var point = 0;
		while (re_search(1, prefix))
			grab(point, give_end_line(), result);
	}
}

save_completion(trystr, finder)	// save response to prompt based on cmd
char *trystr;
char *(*finder)();
{
	char *s, type[FNAMELEN];

	if (!*trystr)
		return;
	if (!recall_id) { // name_name() return val overwritten by next call
		s = name_name((short) finder);
		sprintf(type, "%s ", s ? s : "string");
		s = name_name(last_index);
		strcat(type, s ? s : "none");
		save_recall(trystr, type);
	} else
		save_recall(trystr, recall_id);
}

save_recall(text, key)	// save response to prompt using this key
char *text, *key;
{
	char resp[FNAMELEN * 2];

	save_var matchstart, matchend, user_abort = 0, abort_searching = 0;
	if (*text) {
		save_var bufnum = create(OLDRESP);
		if (size() > recall_maximum_size) {
			point = size() - recall_maximum_size;
			to_begin_line();
			delete(0, point);
		}
		if (strlen(key) + strlen(text) < sizeof(resp) / 2) {
			point = size();		// delete old identical resps
			sprintf(resp, "^%q: %q\n", key, text);
			if (re_search(-1, resp))
				delete(matchstart, matchend);
		}
		point = size();
		bprintf("%s: %s\n", key, text);
	}
}

must_match(trystr, finder, flags)	/* return 1 if we should put up */
char *trystr;				/* list of possible completions */
char *(*finder)();
{
	char first[FNAMELEN], *s;

	if (!(flags & MUST_MATCH) || (flags & NONE_OK) && !*trystr)
		return 0;
	s = (*finder)(trystr, STARTMATCH | flags);
	if (!s)			/* no matches at all, return it */
		return 0;
	strcpy(first, s);
	if (!(*finder)(trystr, flags))
		strcpy(trystr, first);	/* 1 match, expand it */
	else if (!(*finder)(trystr, (flags | STARTMATCH | EXACTONLY)))
		return 1;		/* if 2+ but none exact, ask */
	return 0;
}

error_if_input(abort)	/* disallow recursive cmd line editing */
{
	switch (_doing_input) {
		case DI_SEARCH:		quick_abort(); break;
		case DI_LINEINPUT:	leave_recursion(abort ? INP_ABORT : 0);
					break;
		case DI_VIEWLAST:	remove_final_view(); break;
		case DI_LISTBOX:	break;
	}
}

pass_back(cmd)	/* send cmd to caller to be processed */
{
	cmd_result = cmd;
	if (_doing_input == DI_VIEWLAST)
		remove_final_view();
	else if (_doing_input == DI_LISTBOX)
		return;
	else if (_doing_input)
		leave_recursion(cmd);
	else
		do_command(binding_of(key, root_keys));
}

pass_if_complete(cmd)	/* if we're doing completion, pass it, else */
{			/* run default definition of key */
	if (_doing_completion)
		pass_back(cmd);
	else
		do_command(binding_of(key, root_keys));
}

inp_add_search()	/* self-insert, then maybe search in menu */
{
	pass_back(INP_ADD);
}

/* abort the command that asked for input */
inp_abort()	on menu_tab[WIN_DRAG_DROP], comp_tab[WIN_DRAG_DROP],
			   view_tab[WIN_DRAG_DROP]
{
	pass_back(INP_ABORT);
}

when_loading()
{
	fix_key_table(reg_tab, (short) normal_character,
		menu_tab, (short) inp_add_search);
	fix_key_table(reg_tab, (short) backward_delete_character,
		menu_tab, (short) inp_add_search);
	fix_key_table(reg_tab, (short) abort, menu_tab, (short) inp_abort);
	fix_key_table(reg_tab, (short) abort, view_tab, (short) inp_abort);
	fix_key_table(reg_tab, (short) abort, comp_tab, (short) inp_abort);
}

inp_show_matches() on comp_tab['?'], menu_tab['?']
{
	pass_if_complete(INP_SHOW_MATCHES);
}

inp_get() on menu_tab['\t']
{
	if ((has_feature & FEAT_GUI_DIALOGS) && window_to_screen(window_handle))
		next_dialog_item();
	else
		pass_back(INP_GET);
}

inp_always_get() on menu_tab[ALT('e')]
{
	pass_back(INP_GET);
}

inp_backtab() on menu_tab[NUMSHIFT(GREYTAB)], comp_tab[NUMSHIFT(GREYTAB)]
{
	if ((has_feature & FEAT_GUI_DIALOGS) && window_to_screen(window_handle))
		prev_dialog_item();
}

inp_get_and_exit() on menu_tab['\n'], menu_tab['\r'], menu_tab[GREYENTER]
{
	if (insert_newlines_in_dialog)
		do_command(binding_of(key, root_keys));
	else
		pass_back(INP_GET_EXIT);
}

inp_tab_key() on comp_tab['\t']
{
	if ((has_feature & FEAT_GUI_DIALOGS) && window_to_screen(window_handle))
		next_dialog_item();
	else if (key == '\t' && !_doing_completion)
		normal_character();
	else
		pass_if_complete(INP_COMPLETE);
}

inp_wheel() on comp_tab[WIN_WHEEL_KEY], menu_tab[WIN_WHEEL_KEY]
{
	if (mode_keys == comp_tab)
		pass_back(INP_TO_LIST);		// switch to list win
}

inp_complete() on comp_tab[ESC]
{
	if ((has_feature & FEAT_GUI_DIALOGS) && window_to_screen(window_handle))
		pass_back(INP_ABORT);
	else
		pass_if_complete(INP_COMPLETE);
}

buffer_has_pattern(char *s)
{
	save_var point = 0;
	return re_search(1, s);
}

literal_if_quoted()
{
	return buffer_has_pattern("\"");
}

literal_always()
{
	return 1;
}

inp_try() on comp_tab[' ']
{
	if (completion_literal_char && (*completion_literal_char)())
		insert(' ');
	else
		pass_if_complete(INP_TRY);
}

inp_get_default() on comp_tab[CTRL('S')], comp_tab[CTRL('R')]
{
	pass_back(INP_DEFAULT);
}

inp_get_last_recall() on comp_tab[ALT('e')]
{
	pass_back(INP_LAST_RECALL);
}

inp_recall() on comp_tab[ALT(CTRL('P'))], comp_tab[NUMALT(KEYUP)],
				comp_tab[CTRL('P')], comp_tab[KEYUP],
				comp_tab[NUMALT(NUMDIGIT(8))]
{
#if 0
	if (!IS_ALT_KEY(key))
		pass_back(INP_TO_LIST);		// switch to list win
	else
#endif
		pass_back(INP_RECALL);
}

inp_grab_word() on comp_tab[ALT(CTRL('N'))], comp_tab[NUMALT(KEYDOWN)],
				   comp_tab[NUMALT(NUMDIGIT(2))]
{
	if (!IS_ALT_KEY(key))
		pass_back(INP_TO_LIST);		// switch to list win
	else
		pass_back(INP_GRAB_WORD);
}

inp_grab_line() on comp_tab[ALT(CTRL('V'))], comp_tab[NUMALT(KEYPGDN)],
				   comp_tab[NUMALT(NUMDIGIT(3))]
{
	if (!IS_ALT_KEY(key))
		pass_back(INP_TO_LIST);		// switch to list win
	else
		pass_back(INP_GRAB_LINE);
}

// Redirect <PgUp> to list window.
inp_pgup()
{
	pass_back(INP_TO_LIST);		// switch to list win first
}

line_gets_highlight()
{
	return (_window_flags & HIGHLIGHT_LINE);
}

inp_get_focus() on comp_tab[GETFOCUS], menu_tab[GETFOCUS], view_tab[GETFOCUS]
{
	if (mouse_screen) {
		int w = screen_to_window(mouse_screen);
		if (w != -1)
			window_handle = w;
		if (line_gets_highlight())
			make_line_highlight();	// highlight listbox when it's current
	}
}

inp_lose_focus() on comp_tab[LOSEFOCUS], menu_tab[LOSEFOCUS], view_tab[LOSEFOCUS]
{
	if (mouse_screen) {
		save_var window_handle = screen_to_window(mouse_screen);
		if (line_gets_highlight())
			remove_line_highlight();
	}
}

grab_buffer_word(origwin, wline) // copy word/line from origwin to cur window
{
	int orig, obuf = bufnum, osize;

	point = osize = size();
	save_var window_handle = origwin;
	save_var point = _grab_word_loc;
	if (!_grab_word_start && is_highlight_on()) {	// 1st time.
		buf_xfer(obuf, point, mark);
		_grab_word_loc = MAX(mark, point);
	} else {
		if (!_grab_word_start) {		// 1st time:
			if (parse_string(1, word_pattern))	// If we're in a word, go
				point -= parse_string(-1, word_pattern); // to its start.
			re_search(1, "[ \t\n]*");	// Don't include leading wspace.
		}
		orig = point;
		if (osize && wline && curchar() == '\n')
			point++;
		if (wline)
			to_end_line();
		else
			re_search(1, word_pattern);	// copy one word in
		buf_xfer(obuf, orig, point);
		_grab_word_loc = point;
	}
	_grab_word_start = 1;
}

inp_exit() on comp_tab['\r'], comp_tab['\n'], comp_tab[GREYENTER]
{
	pass_back(INP_EXIT);
}

inp_next_page() on menu_tab[' '], view_tab[' ']
{
	if (_doing_input) {
		if ((all_blanks(window_end, size() - narrow_end) + next_page())
			&& !paging_retains_view)
			if (_doing_input == DI_VIEWLAST)
				remove_final_view();
			else
				leave_recursion(INP_SEEN);
	} else
		do_command(binding_of(key, root_keys));
}

inp_previous_page() on menu_tab['\b'], view_tab['\b'],
					   menu_tab[GREYBACK], view_tab[GREYBACK]
{
	if (_doing_input) {
		if (search_in_menu)
			pass_back(INP_ADD);
		else if (previous_page() && !paging_retains_view)
			if (_doing_input == DI_VIEWLAST)
				remove_final_view();
			else
				leave_recursion(INP_SEEN);
	} else
		do_command(binding_of(key, root_keys));
}

// Display a list of choices in a buffer, let user select one,
// and return in resp.  Return 1 if ok, 0 if user canceled.
// Takes a title, optional msg to display (for non-gui version),
// and button labels (for gui).

get_choice(list, resp, title, msg, b1, b2, b3)
char *resp, *title, *msg, *b1, *b2, *b3;
{
	int w = window_handle, win;

	error_if_input(1);	/* error if we're in the middle of input */
	save_var _doing_input = DI_LINEINPUT;
	win = new_menu(list);
	window_title(win, BTOP, TITLECENTER, title);
	window_to_fit(screen_lines - 7);
	save_var _window_flags |= HIGHLIGHT_LINE;
	save_var search_in_menu = 0;
	save_var display_column = 0;	// don't wrap
	if (*resp)			// Otherwise use initial position.
		col_search(resp, 0);
	if (is_gui && want_gui_prompts) {
		one_window_to_dialog(title, win, b1, b2, b3);
	} else if (msg)
		say(msg);
	select_menu_item(0, win, w, 0);
	grab_full_line(list, resp);
	ungot_key = -1;
	return !user_abort;
}

select_menu_item(resbuf, menuwin, owin, dir)
{	// let user select line from menu window, maybe copy line to resbuf
	int res; // dir tells how to srch on norm keys, or 0 if they're cmds
	char str[FNAMELEN], pat[FNAMELEN * 2];

	save_var mode_keys;
	cursor_to_column = -1;
	do {
		mode_keys = menu_tab;
		res = do_recursion();
		if (!is_window(menuwin))
			res = INP_ABORT;
		else if (res == INP_ADD && search_in_menu && dir) {
			window_handle = owin;
			run_topkey();
			window_handle = owin;
			grab(0, FNAMELEN - 1, str);
			sprintf(pat, "^%q", str);
			window_handle = menuwin;
			point = (dir == 1) ? 0 : size();
			re_search(dir, pat);
			to_begin_line();
			res = 0;
		} else if (res == INP_ADD && !dir)
			switch (isalpha(key) ? toupper(key) : 0) {
				case 'N':
				case 'P':	ungot_key = CTRL(key);
				default:	res = 0;	// fall through
				case 'Q':	break;
			}
	} while (!res);
	switch (res) {		// try all other chars
		case INP_ADD:	ungot_key = key;
				break;
		case INP_GET_EXIT:
		case INP_GET:	if (resbuf)
					get_menu_line(resbuf);
				break;
	}
	if (res == INP_ABORT && !user_abort)	// user deleted edit window?
		user_abort = 1;
	remove_line_highlight();
	window_handle = owin;
	remove_window(menuwin);
	return res;
}

get_menu_line(edit)	/* copy cur line from menu to edit buf */
{
	int i;

	to_end_line();
	i = point;
	to_begin_line();
	if (i != point) {
		buf_zap(edit);
		buf_xfer(edit, point, i);
	}
}

char *general_matcher(s, flags) 
char *s;
{
	char tmp[TAGLEN];

	save_var bufnum;
	save_var abort_searching = 0;
	bufname = _MATCH_BUF;
	save_var case_fold = (flags & COMP_FOLD) != 0;
	if (flags & STARTMATCH)
		point = 0;
	if (*s) {
		sprintf(tmp, "^%q", s);
		if (!re_search(1, tmp))
			return 0;
		to_begin_line();
	} else {
		if (curchar() == '\n')
			point++;
		if (point == size())
			return 0;
	}
	parse_string(1, ".+", _this_match);
	to_end_line();
	if ((flags & EXACTONLY) && strfcmp(_this_match, s))
		return 0;
	return _this_match;
}

run_topkey()		/* call do_topkey() with appropriate setup */
{
	jmp_buf *old_level = top_level, this_level;

	iter = 1;
	has_arg = this_cmd = table_count = 0;
	top_level = &this_level;
	undo_mainloop();	/* make sure undoing is on for this buffer */
	if (!setjmp(top_level))
		do_topkey();
	top_level = old_level;
	prev_cmd = this_cmd;
}

// Remove any " characters from s.

drop_quotes(char *s)
{
	was_quoted = 0;
	while (s = index(s, '"')) {
		was_quoted = 1;
		strcpy(s, s + 1);
	}
}


// Would adding a <Space> to this file name provide some matches?
// Returns number of matches (2 means 2 or more).

could_add_space(char *s, char *(*finder)(), int flags)
{
	char file[FNAMELEN];

	sprintf(file, "%s ", s);
	return !finder(file, STARTMATCH | flags) ? 0 :
			finder(file, flags) ? 2 : 1;
}

complete(s, finder, flags)	/* perform completion by modifying s */
	char *s;		/* return 0: no matches, 1: 1 match, */
	char *(*finder)();	/* else many matches, or some matches */
{				/* don't start with s */
	char biggest[FNAMELEN], *t;
	int i, start, end, num = 1, c;

	if (!(t = (*finder)(s, STARTMATCH | flags)))
		return 0;				/* if no matches */
	strcpy(biggest, t);			/* start off with first */
	start = (flags & CAUTIOUS) ? 0 : strlen(s);
			/* assume all matches start with s unless cautious */
	save_var case_fold = (flags & COMP_FOLD) != 0;
	end = strlen(biggest);
	while (t = (*finder)(s, flags)) {
		if (strnfcmp(t, biggest, end))	/* if this differs, */
			for (i = start; i < end; i++) /* find where */
				if (charfcmp(t[i], biggest[i]))
					end = i;
		num++;
		if (end <= start)	/* if all chars gone, stop */
			break;
	}
	if ((flags & COMP_FILE) == COMP_FILE)
		// it's a file; use special folding
		for (i = 0; s[i]; i++) { // compare with std path chars
			c = (s[i] != ':' && is_path_separator(s[i])) ? path_sep
				: _srch_case_map[s[i]];
			if (end < i || c != _srch_case_map[biggest[i]])
				return 2; // some matches didn't start with s
		}
	else if (flags & CAUTIOUS) {
		if (strnfcmp(s, biggest, strlen(s)) || end < strlen(s))
			return 2; // some matches didn't start with s
	}
	strncpy(s, biggest, end);
	return num;
}

		/* insert matches into current buffer */
load_matches(char *s, char *(*finder)(), int flags)
{
	char *t;

	if (list_finder)
		finder = list_finder;
	if (t = (*finder) (s, flags | STARTMATCH | LISTMATCH))
		do {
			bprintf("%s\n", t);
			check_abort();
		} while (t = (*finder) (s, flags | LISTMATCH));
}

/* put matches for s in menu buf */
list_matches(char *s, char *(*finder)(), int flags, int mbuf)
{
	save_var bufnum = zap("-list-temp");
	load_matches(s, finder, flags);
	buf_zap(mbuf);
	do_buffer_sort(bufnum_to_name(mbuf), 0, 0);
	bufnum = mbuf;
	delete_buffer("-list-temp");
	point = 0;
	delete_final_newlines();
}

delete_final_newlines()	/* remove any newlines at end of this buffer */
{
	while (character(size() - 1) == '\n')	/* remove final \n's */
		delete(size() - 1, size());
}

buf_delete_final_newlines(buf)
{
	save_var bufnum = buf;
	delete_final_newlines();
}

/* put matches for s in menu buf */
list_file_matches(char *s, char *(*finder)(), int flags, int mbuf)
{
	save_var bufnum = zap("-list-temp");
	load_matches(s, finder, flags);
	point = 0;		/* ensure that . sorts before .. */
	strip_final_slash();	/* assumes that . and .. are on 1st 2 lines */
	point++;		/* go to line with .. */
	strip_final_slash();
	buf_zap(mbuf);
	do_buffer_sort(bufnum_to_name(mbuf), 0, 0);
	bufnum = mbuf;
	delete_buffer("-list-temp");
	point = 0;
	buf_delete_final_newlines(mbuf);
}

strip_final_slash()	/* change ./ and ../ to . and .. */
{			/* stays at eol */
	save_var abort_searching = 0;
	to_end_line();
	if (parse_string(-1, "(.*[\\/:])*(<.><.>?)[\\/]", (char *)0))
		delete(point - 1, point);
}

// If buffer contains a pattern which appears to be an absolute pathname
// with another pathname stuck in front, replace with just the
// absolute pathname.  We try to avoid modifying valid UNC pathnames
// like \\machine\dirname\filename or network file names like
// machine:\dir\file or FTP names like ftp:\\host.com\\.

restart_file_paths()
{
	char pat[FNAMELEN];
	int res, res2;

	if (insert_default_response != 3)
		return;
	save_var point = 0, abort_searching = 0, case_fold = 1;
	point += parse_string(1, "(ftp|http|telnet):[\\/][\\/][^\\/]+");
		// Don't consider ftp://host.com part, which may have \\ after.
	if (opsys == OS_UNIX) {
		res = parse_string(1, "/.*/!~");
		if (res)	// Delete /dir/name/ before a ~.
			delete(0, point + res);
	}
	sprintf(pat, "((ftp|http|telnet%s):)?"	// optional a: or ftp:
			"[\\/].*[\\/]!"			// slash, stuff, slash
			"([\\/]|(ftp|http|telnet|[a-z]):)",		// slash or a: or ftp:
			(opsys == OS_UNIX) ? "" : "|[a-z]");
	res = parse_string(1, pat);
	if (res) {	// Delete abc:\dirname\dir2\ or \dir\ or k:\dir\, etc.
		point += res;	// But exclude a trailing URL part.
		res2 = parse_string(-1, "(ftp|http|telnet):[\\/]+");
		if (res2 && res2 < point)
			point -= res2;
		delete(0, point);
	}
	if (opsys != OS_UNIX) {
		res = parse_string(1, "[a-z]:[\\/]!([\\/]|(ftp|http|telnet|[a-z]):)");
		if (res)	// Delete c:\ or similar before an absolute path.
			delete(0, point + res);
	}
}


inp_remove_file_path() on comp_tab['/'], comp_tab['\\'],
						  comp_tab[':'], comp_tab['~']
{
	normal_character();
	undo_mainloop();
	if (point == size())
		restart_file_paths();
}

// Combine prompt pr with default def and write to full.  If the
// combination would be too wide, or if omit is nonzero, omit the
// default from the prompt, or abbreviate it.  If rel is nonzero, insert
// the relative filename form of the default (which assumes def is a
// filename), otherwise insert it exactly.

// If there's very little space left, omit the default from the prompt
// entirely, to give the user maximum room.  If there's space for
// two copies, include the default in full (the user will have an equal
// amount of space left over to type).  Otherwise abbreviate the prompt.

build_prompt(char *full, char *pr, char *def, int omit, int rel)
{
	int len, room = screen_cols - strlen(pr) - 6, skip;
	char s[FNAMELEN];

	strcpy(full, pr);
	full += strlen(full);
	if (*def && !omit) {
		sprintf(s, rel ? "%r" : "%s", def);
		len = strlen(s);
		if (room > 15) {	// Enough room to contemplate showing the default.
			skip = len - room / 2 + 5;	// How many characters should we skip over?
			if (skip < 5)	// Plenty of room for 2 copies, skip nothing.
				sprintf(full, " [%s]", s);
			else if (skip < len)	// Should always be true at this point.
				sprintf(full, " [...%s]", s + skip);
		}
	}
	strcat(full, ": ");
}

prompt_comp_read(trystr, prmpt, finder, flags, def)
char *trystr, *prmpt, *def;	/* use when entering nothing means default */
char *(*finder)();
{
	char fullprompt[FNAMELEN];

	build_prompt(fullprompt, prmpt, def, insert_default_response, 0);
	comp_read(trystr, fullprompt, finder, flags, def);
	if (!*trystr)
		strcpy(trystr, def);
}

ok_file_match(s)	/* is filename s ok as a match, or excluded? */
char *s;	/* see if extension occurs in ignore_file_extensions, */
{		/* but if only_file_extensions, use that instead */
	char pat[FNAMELEN];

	save_var case_fold = (FOLDFILE != 0);
	sprintf(pat, "|%s|", get_extension(s));
	if (only_file_extensions)
		return strstr(only_file_extensions, pat) != NULL;
	return strstr(ignore_file_extensions, pat) == NULL;
}

char _admit_all_extensions;	/* ignore list of extensions to skip? */

char *f_match(s, flags)	/* return files that match pattern unless ruled */
	char *s;	/* out by ignore_file_extensions */
{			/* but if none remain, include all file extensions */
	char *r;
	int start = (flags & STARTMATCH); /* nonzero if starting from top */

	if (start)
		_admit_all_extensions = 0;
	for (;;) {
		do {
			r = do_file_match(s, (flags & ~STARTMATCH) | start);
			start = 0;
		} while (r && !_admit_all_extensions && !ok_file_match(r));
		if (r || !(flags & STARTMATCH) || _admit_all_extensions)
			return r;
		start = _admit_all_extensions = 1;
	}
	return r;
}

/* Return files that match pattern. */
/* If it's not a directory, it must permitted by
 only_file_extensions/ignore_file_extensions. */

char *f_only_match(s, flags)
	char *s;
{
	char *r;
	int start = (flags & STARTMATCH); /* nonzero if starting from top */
	int alsoflags = FM_NO_DIRS;

	if (start)	// For us, this variable also means "begin listing dirs".
		_admit_all_extensions = 0;
	for (;;) {
		do {
			r = do_file_match(s, (flags & ~STARTMATCH) | start | alsoflags);
			start = 0;
		} while (r && !_admit_all_extensions && !ok_file_match(r));
		if (r || _admit_all_extensions)
			return r;
		start = _admit_all_extensions = 1;	// list matching dirs instead
		alsoflags = FM_ONLY_DIRS;
		flags |= 1;
	}
	return r;
}


get_file(res, pr, def)
	char *res, *pr, *def;
{
	char rel[FNAMELEN];

//	relative(def, rel);
	strcpy(rel, def);
	if (!*rel) {
		get_buffer_directory(rel);
		save_var insert_default_response = 3;
	}
	if (*rel && is_directory(rel))
		save_var insert_default_response = 3;
	save_var completion_lister = list_file_matches;
	save_var abort_file_matching = ABORT_JUMP;
	save_var resize_menu_list = 1;
	if (only_file_extensions)  {
		prompt_comp_read(res, pr, f_only_match, COMP_FILE | FOLDFILE, rel);
	} else {
		save_var list_finder = do_file_match;
		prompt_comp_read(res, pr, f_match, COMP_FILE | FOLDFILE, rel);
	}
	if (*res && !wild_pattern(res))
		absolute(res);
}

	/* offer default based on current file or directory */
get_file_dir(res, pr)
	char *res, *pr;
{
	jmp_buf *old_level = top_level, this_level;
	char def[FNAMELEN], old[FNAMELEN];
	int ret = 0, ok;

	ok = get_buffer_directory(def);
	save_var completion_lister = list_file_matches;
	save_var list_finder = do_file_match;
	save_var abort_file_matching = ABORT_JUMP;
	save_var resize_menu_list = 1;
	save_var insert_default_response = 0;

	if (prompt_with_buffer_directory == PBD_INSERT)
		insert_default_response = 3;
	if (prompt_with_buffer_directory == PBD_TEMPCD) {
		top_level = &this_level;
		getcd(old);
		if (ok)
			chdir(def);
		ret = setjmp(top_level);
	}
	if (!ret)
		comp_read(res, pr, f_match, COMP_FILE | FOLDFILE, def);
	if (prompt_with_buffer_directory == PBD_TEMPCD)
		chdir(old);
	if (prompt_with_buffer_directory == PBD_INSERT && !strcmp(res, def)
		  && !is_remote_file(res))
		*res = 0;
	top_level = old_level;
	if (*res && !is_remote_file(res) && ok && !wild_pattern(res)
		&& prompt_with_buffer_directory == PBD_TEMPCD)
		absolute(res, def);
	else if (*res && !wild_pattern(res))
		absolute(res);
	if (ret)
		longjmp(top_level, ret);
}

char *b_match(s, flags)
	char *s;
{
	char *res;

	do {			/* omit temps, unless explicit */
		res = buf_match(s, flags);
		flags = 0;
	} while (res && *res == '-' && *s != *res);
	return res;
}

get_buf(res, pr, def)
	char *res, *pr, *def;
{
	prompt_comp_read(res, pr, b_match, CAUTIOUS, def);
}

char *nt_match(s, flags)	/* return entries that match _nt_filter */
	char *s;		/* can start with "-" only if s does */
{
	int i, j, sdash = (*s == '-' || *s == '_');
	char *res;

	if (flags & EXACTONLY)
		return (j = name_type(find_index(s))) && (BIT(j) & _nt_filter)
			&& (flags & STARTMATCH) ? s : 0;

	for (; i = name_match(s, flags & STARTMATCH); flags &= ~STARTMATCH)
		if ((j = name_type(i)) && (BIT(j) & _nt_filter)) {
			res = name_name(i);
			if (sdash || *res != '-')
				return res;
		}
	return 0;
}

get_cmd(res, pr, def)
	char *res, *pr, *def;
{
	save_var _nt_filter = BIT(NT_MACRO) | BIT(NT_COMMAND)
			      | BIT(NT_AUTOLOAD);
	prompt_comp_read(res, pr, nt_match, 0, def);
}

get_macname(res, pr, def)
	char *res, *pr, *def;
{
	save_var _nt_filter = BIT(NT_MACRO);
	prompt_comp_read(res, pr, nt_match, 0, def);
}

get_func(res, pr, def)
	char *res, *pr, *def;
{
	save_var _nt_filter = BIT(NT_COMMAND) | BIT(NT_SUBR)
			      | BIT(NT_AUTOLOAD) | BIT(NT_AUTOSUBR);
	prompt_comp_read(res, pr, nt_match, 0, def);
}

get_any(res, pr, def)
	char *res, *pr, *def;
{
	save_var _nt_filter = ~0;	/* allow all entries */
	prompt_comp_read(res, pr, nt_match, 0, def);
}

char *var_match(s, flags) 
	char *s;
{
	char *res;
	int i;

	while (res = nt_match(s, flags)) {
		flags = 0;
		i = find_index(res);
		if (!show_all_variables && !name_user(i) && *s != '-')
			continue;
		switch (vartype(i)) {
			case TYPE_CHAR:
			case TYPE_SHORT:
			case TYPE_INT:
			case TYPE_CARRAY:
			case TYPE_CPTR:
				return res;
		}
	}
	return 0;
}

get_var(res, pr, def, flags)
	char *res, *pr, *def;
{
	save_var _nt_filter = BIT(NT_VAR) | BIT(NT_BUFVAR) | BIT(NT_WINVAR)
			      | BIT(NT_BUILTVAR);
	prompt_comp_read(res, pr, var_match, flags, def);
}

get_string(res, pr)		/* with no completion */
	char *res, *pr;
{
	comp_read(res, pr, (char *(*)()) 0, 0, "");
}

get_strdef(res, pr, def)	/* as above, but gives default if no entry */
	char *res, *pr, *def;
{
	prompt_comp_read(res, pr, (char *(*)()) 0, 0, def);
}

// Get a string, use last entry as default.
get_str_auto_def(char *res, char *pr)
{
	char def[FNAMELEN];

	save_var _help_on_cmd = last_index;
	get_last_recall((char *(*)()) 0, def);
	prompt_comp_read(res, pr, (char *(*)()) 0, 0, def);
}

get_strnone(res, pr, def)	/* as above, but doesn't substitute default */
	char *res, *pr, *def;	/* if user enters nothing */
{
	comp_read(res, pr, (char *(*)()) 0, 0, def);
}

// Gui version: pop up a box for a one-line response.
// If the user presses the help button, show help for the given topic.

get_strpopup(res, pr, def, help)
	char *res, *pr, *def, *help;
{
	if (help)
		save_var _show_help_on = help;
	comp_read(res, pr, (char *(*)()) 0, POP_UP_PROMPT, def);
}


get_number(pr)	/* return the numeric argument, or prompt if none */
	char *pr;
{
	char res[FNAMELEN];
	int v = iter;

	got_bad_number = iter = 0;
	if (has_arg)
		return v;
	get_string(res, pr);
	return numtoi(res);
}

/* View Mode (aka More Mode), for displaying help text to the user */

when_loading()
{
	fix_key_table(reg_tab, (short) normal_character,
		view_tab, (short) inp_exit);
	view_tab[WIN_BUTTON] = (short) inp_exit;
	view_tab[' '] = (short) inp_next_page;
	menu_tab[' '] = (short) inp_next_page;
	fix_key_table(reg_tab, (short) next_page,
		view_tab, (short) inp_next_page);
	fix_key_table(reg_tab, (short) previous_page,
		view_tab, (short) inp_previous_page);
	fix_key_table(reg_tab, (short) up_line, comp_tab, (short) inp_recall);
	fix_key_table(reg_tab, (short) down_line,
		      comp_tab, (short) inp_grab_word);
	fix_key_table(reg_tab, (short) next_page,
		      comp_tab, (short) inp_grab_line);
	fix_key_table(reg_tab, (short) previous_page,
		      comp_tab, (short) inp_pgup);
}

inp_select_link() on view_tab['\r'], view_tab['\n'], view_tab[GREYENTER]
{
	char link[200];
	int start, end;

	if (go_to_link) {
		if (in_link()) {
			get_character_color(point, &start, &end);
			grab(start, end, link);		// Get text of link.
			(*go_to_link)(link);
			return;
		} else if (IS_MOUSE_KEY(key))
			return;
	}
	pass_back(INP_EXIT);
}

inp_next_link() on view_tab['\t']
{
	if (go_to_link || (has_feature & FEAT_GUI_DIALOGS) && window_to_screen(window_handle))
		switch_link(1);
	else
		pass_back(INP_EXIT);
}

inp_previous_link() on view_tab[NUMSHIFT(GREYTAB)]
{
	if (go_to_link || (has_feature & FEAT_GUI_DIALOGS) && window_to_screen(window_handle))
		switch_link(-1);
	else
		pass_back(INP_EXIT);
}

view_buffer(name, last)	/* show buffer in view-mode in std window */
char *name;
{
	view_buf(name_to_bufnum(name), last);
}

view_buf(buf, last)	/* show buffer in view-mode in std window */
{
	view_linked_buf(buf, last, 0);
}

view_linked_buf(buf, last, linker)
int (*linker)();
{
	int win, res, height, prev;

	remove_final_view();
	prev = window_handle;
	if (!last)
		save_var _doing_input = DI_VIEW, bufnum, window_handle;
	height = screen_lines - _view_top - _view_bottom;
	win = add_popup(_view_left, _view_top,
					screen_cols - _view_left - _view_right, height,
					_view_border, buf);
	go_to_link = linker;
	if (linker) {
		create_links();
		mouse_dbl_selects = 1;
	}
	if (is_gui && want_gui_prompts)
		if (!linker)
			one_window_to_dialog(_view_title ? _view_title : "No Title", win,
								 "OK", "Cancel", "");
		else
			one_window_to_dialog(_view_title ? _view_title : "No Title", win,
								 "", "Done", "");

	text_color = (is_gui && want_gui_prompts) ? color_class viewed_gui_text
											  : color_class viewed_text;
	set_wattrib(win, PVERTBORDCOLOR, color_class viewed_border);
	set_wattrib(win, PHORIZBORDCOLOR, color_class viewed_border);
	if (_view_title)
		window_title(win, BTOP, TITLECENTER, _view_title);
	point = 0;
	window_to_fit(height);
	if (last) {
		_view_prev_input = _doing_input;
		_view_prev_window = prev;
		_view_prev_mode = mode_keys;
		mode_keys = view_tab;		/* switch buf to view mode */
		_doing_input = DI_VIEWLAST;
		_window_flags &= ~FORCE_MODE_LINE;
		display_more_msg(win);
	} else {
		res = view_loop(win);
		if (res == INP_EXIT && !IS_ENTER_KEY(key))
			ungot_key = key;
		remove_window(win);
	}
	user_abort = 0;
}

view_loop(win)		/* process some view-mode cmds */
{
	int res;
	short *old_mode;

	old_mode = mode_keys;
	mode_keys = view_tab;		/* switch mode temporarily */
	_window_flags &= ~FORCE_MODE_LINE;
	display_more_msg(win);
	res = do_recursion();
	if (!is_window(win))	/* user deleted it, give up */
		return INP_ABORT;
	window_handle = win;
	if (mode_keys == view_tab)
		mode_keys = old_mode;
	return res;
}

remove_final_view()		/* remove view-mode window & restore buf */
{
	int orig = window_handle;

	window_number = -1;		/* go to topmost popup window */
	for (; is_window(window_handle) == ISPOPUP; window_number--) {
		if (mode_keys == view_tab) {
			mode_keys = _view_prev_mode;
			if (window_handle == orig) // switch to prev window
				orig = _view_prev_window;
			window_kill();
			_doing_input = _view_prev_input;
			if (!is_window(orig))	// view-mode win was current,
				return;		// stay in topmost popup
			break;			//  (or 1st tiled)
		}
	}
	window_handle = orig;
}

create_links()	// replace ^A^B codes with links
{
	int p;

	save_spot point = 0;
	while (search(1, "\1")) {
		delete(point - 1, point);
		p = point;
		if (search(1, "\2"))
			delete(point - 1, point);
		set_character_color(p, point, color_class viewed_link);
	}
}

remove_links()		// discard ^A^B codes in this buffer
{
	simple_re_replace(1, "[\1\2]", "");
}

count_links()		// how many links are there in buffer?
{
	int p = 0, color, start, end, count = 0;

	while (p < size()) {
		color = get_character_color(p, &start, &end);
		if (color == color_class selected_link
		    || color == color_class viewed_link) {
			count++;
		}
		p = end;
	}
	return count;
}

in_link()	// is point inside a link?
{
	int color = get_character_color(point);
	return (color == color_class viewed_link
			|| color == color_class selected_link);
}

// Go to colored region before (adj=-1)/after (adj=1) this one.
// Return 0 if none, 1 if a link, 2 if text.

link_edge(adj)
{
	int color, start, end, i, j;

	color = get_character_color(point, &start, &end);
	point = i = ((adj > 0) ? end : (start - 1));
	color = get_character_color(point);
	j =  (i < 0 || i >= size()) ? 0
			: (color == color_class viewed_link
			   || color == color_class selected_link) ? 1 : 2;
	return j;
}

switch_link(adj)	// Go to link adj away (1 or -1) from current one.
{
	int i, dialog = 0;

	i = link_edge(adj);	// What have we moved to?
	if (i == 2)			// To text, so move again to a link.
		i = link_edge(adj);
	if (!i) {			// Hit end of buffer.
		if ((has_feature & FEAT_GUI_DIALOGS) && window_to_screen(window_handle))
			dialog = adj;
		point = (adj > 0) ? 0 : size();
		if (!in_link())		// Go to link at other end.
			link_edge(adj);
	}
	if (in_link()) {		// Move to start of link.
		get_character_color(point, &i);
		point = i;
	}
	if (dialog > 0)
		next_dialog_item();
	else if (dialog < 0)
		prev_dialog_item();
}

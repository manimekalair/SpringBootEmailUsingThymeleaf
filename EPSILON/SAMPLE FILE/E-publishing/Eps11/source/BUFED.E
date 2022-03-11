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

// This file has the bufed command and its subcommands.

#include "eel.h"
#include "proc.h"
#include "bufed.h"
#include "colcode.h"

when_loading()	/* disable normal keys */
{
	fix_key_table(reg_tab, (short) normal_character, bufed_tab, -1);
}

bufed_help() on bufed_tab['h'], bufed_tab['?'], bufed_tab[HELPKEY],
				bufed_tab[FKEY(1)]
{
	help_on_command("bufed");
}

bufed_tab_key() on bufed_tab['\t']
{
	if ((has_feature & FEAT_GUI_DIALOGS) && window_to_screen(window_handle))
		next_dialog_item();
}

bufed_backtab_key() on bufed_tab[NUMSHIFT(GREYTAB)]
{
	prev_dialog_item();
}

bufed_button() on bufed_tab[WIN_BUTTON]
{
	switch (key_is_button) {
		case 4: bufed_kill(); break;
		case 5: save_var run_by_mouse = 1, show_mouse_choices = 1;
				bufed_save(); break;
	}
}

bufed_pick() on bufed_tab[' '], bufed_tab['\n'],
		bufed_tab['e'], bufed_tab['\r'], bufed_tab[GREYENTER]
{
	bufed_examine(0);
}

bufed_examine_in_window() on bufed_tab['1'], bufed_tab['2'],
			bufed_tab['5'], bufed_tab['z']
{		/* do appropriate window cmd, then examine */
	bufed_examine(cx_tab[key]);
}

bufed_examine(cmd)	/* go to buffer on this line, but 1st do cmd if > 0 */
{
	char bname[FNAMELEN];
	int ok = bufed_getname(bname);

	say("");
	remove_bufed();
	if (ok) {
		if (cmd > 0)
			do_command(cmd);
		to_buffer(bname);
	}
	iter = 0;
}

bufed_when_displaying(from, to)
{
	char bname[FNAMELEN];
	int ok = bufed_getname(bname);

	from = from;		// not used
	to = to;
	if (ok && exist(bname) && is_window(_bufed_orig_window)) {
		save_var window_handle = _bufed_orig_window;
		window_bufnum = name_to_bufnum(bname);
		_highlight_control = (window_bufnum == _bufed_orig_buffer)
							 ? _bufed_orig_highlight : 0;
	}
}

in_bufed()
{
	save_var bufnum = window_bufnum;
	return (window_handle == _bufed_window && mode_keys == bufed_tab);
}

quit_bufed()	/* if in a bufed window, go back to orig */
{
	if (in_bufed()) {
		remove_bufed();
		maybe_refresh();
	}
}

bufed_restore_orig()	/* restore contents of cur window prior to bufed */
{
	if (is_window(_bufed_orig_window)) {
		window_handle = _bufed_orig_window;
		if (buf_exist(_bufed_orig_buffer))
			window_bufnum = _bufed_orig_buffer;
		_highlight_control = _bufed_orig_highlight;
	}
}

remove_bufed()		/* remove bufed window from screen */
{
	bufed_restore_orig();
	remove_window(_bufed_window);
	if (_bufed_caption_window)
		remove_window(_bufed_caption_window);
}

bufed_abort()		/* remove bufed window if ^G'd */
{
	remove_bufed();
}

bufed_kill() on bufed_tab['k'], bufed_tab['d']
{
	char bname[FNAMELEN];
	int buf, win, prev, newbuf = 0;

	if (!bufed_getname(bname) || !strcmp(bname, BUFED_BUF))
		return;
	buf = name_to_bufnum(bname);
	if (!buf || !check_drop_buffer(bname))
		return;
	bufed_restore_orig();
	while ((win = buf_in_window(buf)) >= 0) {
		window_handle = win;
		if (prev = give_prev_buf())
			to_buffer_num(prev);
		else if (newbuf)			// Make a new buffer, switch all
			to_buffer_num(newbuf);	// windows to it if we can't find
		else {						// a better buffer for them to show.
			make_newfile_buf();
			newbuf = bufnum;
		}
		check_abort();
	}
	window_handle = _bufed_window;
	delete_user_buffer(bname);
	set_read_only(0);
	save_var modified;	// leave modify bit alone
	to_begin_line();	// but delete line
	delete(point, give_end_line() + 1);
	if (point >= size() && character(point - 1) == '\n')
		delete(point - 1, point);
	set_read_only(1);
	to_bufed_column();
}

// Return 0 if saved, 1 if error, or 2 if user canceled.
int bufed_save_one(char *s)
{
	int res, old = bufnum;

	if (!exist(s))
		return 1;
	bufname = s;
	res = do_save_file(1, 1, 1);
	if (buf_exist(old))
		bufnum = old;
	return res;
}

bufed_save() on bufed_tab['s']
{
	char bname[FNAMELEN];
	int res = 1;

	if (bufed_getname(bname) && exist(bname)) {
		res = bufed_save_one(bname);
		window_handle = _bufed_window;
		bufname = BUFED_BUF;
		set_read_only(0);
		if (!res && character(point - 2) == '*')
			replace(point - 2, ' ');
		set_read_only(1);
	}
	if (res == 1)
		quick_abort();
}

bufed_set_sort() on bufed_tab['a'], bufed_tab['b'], bufed_tab['f'],
			bufed_tab['i'], bufed_tab['u']
{
	_bufed_sort = key;
	do_bufed(has_arg ? BUFED_ALL : 0);
}

bufed_getname(s)
char *s;
{
	int start, oline;

	*s = 0;
	save_var abort_searching = 0;
	move_to_column(BNAME_COL);
	start = point;
	if (character(point) == '"') {
		oline = lines_between(0, point, 0);
		start = ++point;
		if (!search(1, "\"") || oline != lines_between(0, point, 0))
			return 0;
		point--;
	} else {
		move_to_column(FNAME_COL);
		if (character(point - 1) != ' ')
			if (!search(1, " "))
				return 0;
		if (!re_search(-1, " *"))
			return 0;
	}
	grab(start, point, s);
	to_bufed_column();
	return 1;
}

to_bufed_column()
{
	move_to_column(BNAME_COL);
}

when_loading()
{
	int i;

	set_list_keys(bufed_tab);
	fix_key_table(reg_tab, (short) abort, bufed_tab, (short) bufed_abort);
	fix_key_table(reg_tab, (short) help, bufed_tab, (short) bufed_help);
	for (i = 'a'; i <= 'z'; i++)		// Some keys do reverse-sorting.
		if (bufed_tab[i] == bufed_set_sort)
			bufed_tab[toupper(i)] = bufed_set_sort;
}

bufed_print() on bufed_tab['P']
{
	char bname[FNAMELEN];

	if (bufed_getname(bname) && exist(bname))
		if (do_print_region(name_to_bufnum(bname), 1, 0))
			quick_abort();
}

char _bufed_mode_name[] = "Bufed";

bufed_mode()
{
	mode_default_settings();
	mode_keys = bufed_tab;
	major_mode = _bufed_mode_name;
	mouse_dbl_selects = 1;
	goal_column = BNAME_COL;
	make_mode();
}

quote_bufname(bname)	/* add quotes around bname if necessary */
char *bname;
{
	char tmp[FNAMELEN];

	if (index(bname, ' ') || strlen(bname) >= 16) {
		strcpy(tmp, bname);
		sprintf(bname, "\"%s\"", tmp);
	}
}

list_line(inbuffer)	/* insert a line into the buffer list */
char *inbuffer;
{
	char file[FNAMELEN], msg[FNAMELEN * 2], bname[FNAMELEN];
	int width;

	strcpy(bname, bufname);
	quote_bufname(bname);
	relative(filename, file);
	if (force_save_as == FSA_NEWFILE)
		*file = 0;

	width = sprintf(msg, "%10d%9d %c%c %-18s %s\n",
					buf_accessed, size(), _buf_readonly ? 'R' : ' ',
					modified ? '*' : ' ', bname, file);
	bufname = inbuffer;
	stuff(msg);
	width = width - ACCESS_WIDTH + 2;
	if (width > bufed_width)
		bufed_width = width;
}

/* macros to determine where in the list a buffer should appear */
#define FIRSTGROUP	(*filename && !buffer_not_saveable)
#define GOODNAME	(*bufname != '-' && strcmp(bufname, inbuffer))
#define SECONDGROUP	(GOODNAME || bufnum == old)

make_buffer_list(flags, inbuffer)
char *inbuffer;		/* put buffer list in specified buffer */
{
	int old = bufnum, i, opos;

	if (exist(inbuffer)) {
		bufname = inbuffer;
		set_read_only(0);
		bufnum = old;
	}
	zap(inbuffer);
	i = buf_list(0, 2);	/* start at end of list (most recent) */
	do {
		bufnum = i;
		if (FIRSTGROUP && !(flags & BUFED_ONLY_UNSAVED)
			|| is_unsaved_buffer())
			list_line(inbuffer);
	} while (i = buf_list(-1, 1));
	if (bufed_grouping)
		opos = sort_buffer_list(0, inbuffer);
	i = buf_list(0, 2);
	do {
		bufnum = i;
		if (!FIRSTGROUP && SECONDGROUP
			&& (!(flags & BUFED_ONLY_UNSAVED) || is_unsaved_buffer()))
			list_line(inbuffer);
	} while (i = buf_list(-1, 1));
	if (bufed_grouping)
		opos = sort_buffer_list(opos, inbuffer);
	if (flags & BUFED_ALL) {
		i = buf_list(0, 2);
		do {
			bufnum = i;
			if (!FIRSTGROUP && !SECONDGROUP
				&& (!(flags & BUFED_ONLY_UNSAVED) || is_unsaved_buffer()))
				list_line(inbuffer);
		} while (i = buf_list(-1, 1));
		if (bufed_grouping)
			opos = sort_buffer_list(opos, inbuffer);
	}
	if (!bufed_grouping)
		sort_buffer_list(0, inbuffer);
	bufname = inbuffer;
	point = 0;
	delete_final_newlines();
	set_read_only(1);
	bufnum = old;
}

sort_buffer_list(opos, buf)
char *buf;		/* sort from opos to the end, & return new end */
{
	int col, want_sort = 1, rev = 0;

	switch (tolower(_bufed_sort)) {
		case 'f':	col = FNAME_COL + ACCESS_WIDTH; break;
		case 'b':	col = BNAME_COL + ACCESS_WIDTH; break;
		case 'i':	col = ACCESS_WIDTH; break;
		case 'a':	col = 0; rev = 1; break;
		default:	want_sort = 0; break;
	}
	if (isupper(_bufed_sort))
		rev = !rev;
	save_var bufnum;
	bufname = buf;
	if (want_sort)
		do_sort_region(opos, size(), col, rev);
	save_var narrow_start = opos;
	strip_columns(0, ACCESS_WIDTH);		// remove access timestamps
	return size();
}

do_bufed(flags)
{
	char find[FNAMELEN], msg[FNAMELEN];
	int count;

	if (in_bufed()) {
		bufnum = window_bufnum;
		set_read_only(0);
		if (bufed_getname(find)) {
			quote_bufname(find);
			strcat(find, " ");
		} else
			*find = 0;
		bufed_restore_orig();
		make_buffer_list(flags, BUFED_BUF);
		window_handle = _bufed_window;
		window_bufnum = name_to_bufnum(BUFED_BUF);
		point = 0;
	} else {
		_bufed_orig_window = window_handle;
		_bufed_orig_buffer = window_bufnum;
		_bufed_orig_highlight =_highlight_control;
		strcpy(find, bufname);
		quote_bufname(find);
		strcat(find, " ");
		make_buffer_list(flags, BUFED_BUF);
		build_first = 1;
		_bufed_window = add_popup(2, 2, bufed_width, screen_lines - 6,
			ALL_BORD(BSINGLE), name_to_bufnum(BUFED_BUF));
		if (is_gui && want_gui_prompts) {
			count = lines_between(0, size(), 0) + 1;
			mouse_cursor = &left_pointer;
			_bufed_caption_window = add_popup(0, 0, bufed_width, 1, 0,
									  create(BUFED_CAPTION_BUF));
			buf_zap(bufnum);
			bprintf("    Size     Buffer             File ");
			point = 0;
			system_window = 1;
			mouse_cursor = &left_pointer;
			window_handle = _bufed_window;

			if (flags & BUFED_EXIT) {
				sprintf(msg, "%d buffer%s not saved.  Exit?", count,
						(count == 1) ? "" : "s");
				display_dialog_box("AskExitBox", msg,
								   _bufed_caption_window, _bufed_window, 0,
								   "E&xit", "&Cancel", "");
			} else if (flags & BUFED_SAVE) {
				sprintf(msg, "Save %d unsaved buffers first? "
						"(! to never ask)", count);
				display_dialog_box("AskSaveBox", msg,
								   _bufed_caption_window, _bufed_window, 0,
								   "&Save", "&No Save", "&Cancel");
			} else if (flags & BUFED_SWITCH)
				display_dialog_box("SwitchBufBox", "Select a Buffer",
								   _bufed_caption_window, _bufed_window, 0,
								   "OK", "Cancel", "Help");
			else
				display_dialog_box("CaptionBox", "Select a Buffer",
								   _bufed_caption_window, _bufed_window, 0,
								   "OK", "Cancel", "Help");
		}
		window_handle = _bufed_window;
	}
	set_menu_look(_bufed_window);
	if (flags & (BUFED_EXIT | BUFED_SAVE))
		remove_line_highlight();
	else
		make_line_highlight();
	window_title(_bufed_window, BTOP, TITLELEFT(4),
		" Size     Buffer             File ");
	display_column = 0;	/* horizontally scroll this window */
	popup_near_window(_bufed_window, _bufed_orig_window);
	bufed_mode();
	if (*find)
		col_search(find, BNAME_COL);
	to_bufed_column();
	modified = 0;
	goal_column = BNAME_COL;
	when_displaying = bufed_when_displaying;
}

// Return 1 if user says to exit, 0 if user says don't.

bufed_ask_exit()
{
	char save_it[FNAMELEN];

	if (is_gui && want_gui_prompts) {
		tiled_only();
		save_var _doing_input = DI_VIEW;
		save_var bufnum, window_handle;
		save_var return_raw_buttons = 1;
		for (;;) {
			do_bufed(BUFED_EXIT | BUFED_ONLY_UNSAVED);
			go_to_link = 0;
			view_loop(_bufed_window);
			bufed_getname(save_it);
			remove_bufed();
			if (user_abort) {
				user_abort = 0;
				return 0;
			}
			switch (key_is_button) {
				case 1:	key = 'Y'; break;
				case 2: key = 'N'; break;
				case 5: key = 'S'; break;
				}
			switch (toupper(key)) {
				case 'X':
				case 'Y':	return 1;
				case 'E':
				case 'N':
				case 'C':
				case GREYENTER:
				case '\n':
				case '\r':	return 0;
				case 'S':	if (*save_it && exist(save_it))
								bufed_save_one(save_it);
							if (!unsaved_buffers())
								return 1;
							break;
			}
		}
	} else {
		do_bufed(BUFED_ONLY_UNSAVED);
		maybe_refresh();
		sayput("Buffers not saved.  Exit? [N]");
		do {
			maybe_refresh();
			getkey();
		} while (!IS_TRUE_KEY(key));
		say("");
		switch (toupper(key)) {
			case 'X':
			case 'Y':	break;
			case 'N':
			case 'C':
			case GREYENTER:
			case '\n':
			case '\r':	bufed_msg();
					return 0;
			default:	check_abort();
					ungot_key = key;
					return 0;
		}
		remove_bufed();
		maybe_refresh();
	}
	return 1;
}

// Return 2 if user said to save first, 1 to do command without saving,
// 0 if user said don't do the command.

bufed_ask_save()
{
	if (is_gui && want_gui_prompts) {
		save_var _doing_input = DI_VIEW;
		save_var bufnum, window_handle;
		save_var return_raw_buttons = 1;
		for (;;) {
			do_bufed(BUFED_SAVE | BUFED_ONLY_UNSAVED);
			go_to_link = 0;
			view_loop(_bufed_window);
			remove_bufed();
			switch (key_is_button) {
				case 1:	key = 'S'; break;
				case 2: key = 'N'; break;
				case 3:	key = 'C'; break;
				default: check_abort(); break;
			}
			switch (toupper(key)) {
				case '!':	save_when_making = 0;
				case 'N':	return 1;
				case GREYENTER:
				case '\n':
				case '\r':
				case 'S':
				case 'Y':	return 2;
				case 'C':	return 0;
			}
		}
	} else {
		do_bufed(0);
		sayput("Save unsaved buffers first? [N] (! to never ask) ");
		do {
			maybe_refresh();
			getkey();
		} while (key == MOUSE_MOVE);
		switch (toupper(key)) {
			case '!':	save_when_making = 0;
			case 'N':
			case GREYENTER:
			case '\n':
			case '\r':	remove_bufed();
						return 1;
			case 'Y':	break;
			default:	check_abort();
						say("");
						ungot_key = key;
						return 0;
		}
		remove_bufed();
		return 2;
	}
}

bufed_msg()
{			// show msg till next key
	if (!in_macro() && !(is_gui && want_gui_prompts)) {
		say("Press Space to return to the previous buffer.");
		expire_message = 1;
	} else
		say("");
}

command bufed() on cx_tab[CTRL('B')]
{
	error_if_input(1);
	tiled_only();
	do_bufed(has_arg ? BUFED_ALL : 0);
	iter = 0;
	bufed_msg();
}

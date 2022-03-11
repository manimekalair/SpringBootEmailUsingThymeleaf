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

// This file has functions related to the menu bar.

#include "eel.h"
#include "menu.h"
#include "lowlevel.h"

command show_standard_bitmaps()
{
	want_toolbar = 1;
	toolbar_create();
	toolbar_add_button("STD_CUT", "STD_CUT", "find-file");
	toolbar_add_button("STD_COPY", "STD_COPY", "find-file");
	toolbar_add_button("STD_PASTE", "STD_PASTE", "find-file");
	toolbar_add_button("STD_UNDO", "STD_UNDO", "find-file");
	toolbar_add_button("STD_REDOW", "STD_REDOW", "find-file");
	toolbar_add_button("STD_DELETE", "STD_DELETE", "find-file");
	toolbar_add_button("STD_FILENEW", "STD_FILENEW", "find-file");
	toolbar_add_button("STD_FILEOPEN", "STD_FILEOPEN", "find-file");
	toolbar_add_button("STD_FILESAVE", "STD_FILESAVE", "find-file");
	toolbar_add_button("STD_PRINTPRE", "STD_PRINTPRE", "find-file");
	toolbar_add_button("STD_PROPERTIES", "STD_PROPERTIES", "find-file");
	toolbar_add_button("STD_HELP", "STD_HELP", "find-file");
	toolbar_add_button("STD_FIND", "STD_FIND", "find-file");
	toolbar_add_button("STD_REPLACE", "STD_REPLACE", "find-file");
	toolbar_add_button("STD_PRINT", "STD_PRINT", "find-file");
}

command show_view_bitmaps()
{
	want_toolbar = 1;
	toolbar_create();
	toolbar_add_button(	"VIEW_LARGEICONS", "VIEW_LARGEICONS", "find-file");
	toolbar_add_button(	"VIEW_SMALLICONS", "VIEW_SMALLICONS", "find-file");
	toolbar_add_button(	"VIEW_LIST", "VIEW_LIST", "find-file");
	toolbar_add_button(	"VIEW_DETAILS", "VIEW_DETAILS", "find-file");
	toolbar_add_button(	"VIEW_SORTNAME", "VIEW_SORTNAME", "find-file");
	toolbar_add_button(	"VIEW_SORTSIZE", "VIEW_SORTSIZE", "find-file");
	toolbar_add_button(	"VIEW_SORTDATE", "VIEW_SORTDATE", "find-file");
	toolbar_add_button(	"VIEW_SORTTYPE", "VIEW_SORTTYPE", "find-file");
	toolbar_add_button(	"VIEW_PARENTFOLDER", "VIEW_PARENTFOLDER", "find-file");
	toolbar_add_button(	"VIEW_NETCONNECT", "VIEW_NETCONNECT", "find-file");
	toolbar_add_button(	"VIEW_NETDISCONNECT", "VIEW_NETDISCONNECT", "find-file");
	toolbar_add_button(	"VIEW_NEWFOLDER", "VIEW_NEWFOLDER", "find-file");
}


command standard_toolbar()
{
	want_toolbar = 1;
	toolbar_create();
	toolbar_add_separator();
	toolbar_add_button("STD_FILENEW", "New", "new_file");
	toolbar_add_button("STD_FILEOPEN", "Open", "find_file");
	toolbar_add_button("STD_FILESAVE", "Save", "save_file");
	toolbar_add_separator();
	toolbar_add_button("STD_PRINT", "Print", "print-buffer");
	toolbar_add_separator();
	toolbar_add_button("STD_CUT", "Cut", "kill_region");
	toolbar_add_button("STD_COPY", "Copy", "copy_region");
	toolbar_add_button("STD_PASTE", "Paste", "yank");
	toolbar_add_separator();
	toolbar_add_button("STD_UNDO", "Undo", "undo-changes");
	toolbar_add_button("STD_REDOW", "Redo", "redo-changes");
	toolbar_add_separator();
	toolbar_add_button(	"STD_FIND", "Find", "dialog-search");
	toolbar_add_button(	"STD_REPLACE", "Replace", "dialog-replace");
	toolbar_add_separator();
	toolbar_add_button("VIEW_DETAILS", "List Buffers", "bufed");
	toolbar_add_button("STD_DELETE", "Delete Buffer", "kill-current-buffer");
}

void set_toolbar()
{
	if (want_toolbar == 0)
		toolbar_destroy();
	else {
		toolbar_create();
		standard_toolbar();
	}
}

command toggle_toolbar()
{
	want_toolbar = !want_toolbar;
	set_toolbar();
}

init_menu()
{
	char *s;

	if (has_feature & FEAT_OS_MENUS) {
		if (s = lookpath(gui_menu_file))
			win_load_menu(s);
		win_display_menu(want_gui_menu);
	} else if (permanent_menu) {
		make_perm_menu();
		avoid_top_lines--;
	}
}

check_rebuild_menu()
{
	if ((has_feature & FEAT_OS_MENUS) && need_rebuild_menu)
		init_menu();
	need_rebuild_menu = 0;
}

load_menu()
{
	char buf[FNAMELEN], *s;
	spot sp;

	if (!exist(MENU_BNAME)) {
		if (!(s = lookpath(menu_file)))
			error("Can't find %s", menu_file);
		strcpy(buf, s);
		absolute(buf);
		save_var bufnum = zap(MENU_BNAME);
		if (err_file_read(buf, FILETYPE_AUTO))
			quick_abort();
		tab_size = 100;		// hide second column
		menu_window = 0;
		modify_region(1, MRCOLOR, color_class menu_bar_highlight);
		menu_line_spot = sp = alloc_spot();
		add_region(sp, sp, color_class submenu_highlight, REGLINE);
		submenu_highlight(0);
		save_var abort_searching = 0;
		for (point = 0; re_search(1, "^#.*\n"); )
			delete(matchstart, point);
	}
}

command rebuild_menu()
{
	if (has_feature & FEAT_OS_MENUS) {
		need_rebuild_menu = 1;
		return;
	}
	save_var bufnum;
	if (permanent_menu)
		drop_perm_menu();
	if (exist(MENU_BNAME))
		delete_buffer(MENU_BNAME);
	if (permanent_menu)
		make_perm_menu();
}

get_menu_width() // modify menu to include bindings & return new width of menu
{		// call with point just before current width number
	int width, numfrom, numto;
	char widthb[20];

	parse_string(1, "[0-9]+", widthb);	// get width of menu
	width = numtoi(widthb);
	if (menu_bindings && curchar() != '@') { // did we do col already?
		grab(numfrom = matchstart, numto = matchend, widthb);
		nl_forward();
		width += sub_menu_binding(width);
		point = numfrom;
		delete(numfrom, numto);		// put in new width &
		bprintf("%d@", width);		// mark this column done
	}
	return width;
}

sub_menu_binding(width)		/* add bindings to a single menu column */
{
	int p, textlen, puthere, i, addwidth = 0, atname;
	char func[100];

	while (p = parse_string(1, "([^\n\t]*)\t+")) {
		puthere = find_group(1, 0);
		textlen = puthere - point;
		point += p;
		atname = point;
		to_end_line();
		grab(atname, point, func);
		point = puthere;
		i = one_menu_binding(func, width - textlen);
		addwidth = MAX(addwidth, textlen - width);
		addwidth = MAX(addwidth, i);
		nl_forward();
	}
	return addwidth;
}

one_menu_binding(func, needspace)	/* add binding to a menu item */
char *func;
{
	int i;
	char b[160];

	if (*func == '#' || needspace < 0)
		return 0;
	*b = 0;
	i = find_index(func);
	if (!i || !find_bindings(b, i, root_keys, root_keys, "", 0))
		return 0;
	for (i = 0; i < needspace; i++)
		insert(' ');
	stuff(b);
	return strlen(b);
}

command toggle_menu_bar()	// toggle whether menu bar always appears
{
	if (has_feature & FEAT_OS_MENUS)
		set_gui_menu(has_arg ? (iter != 0) : !want_gui_menu);
	else
		set_menu_bar(has_arg ? (iter != 0) : !permanent_menu);
}

set_gui_menu(newval)
{
	want_gui_menu = newval;
	if (!(has_feature & FEAT_OS_MENUS))
		return;
	init_menu();
}

set_menu_bar(newval)	// turn perm menu bar on or off
{
	if (has_feature & FEAT_OS_MENUS)
		return;
	if (permanent_menu && (!menu_window || !exist(MENU_BNAME)))
		error("Permanent menu internal error: %d", menu_window);
	if (menu_window && permanent_menu && exist(MENU_BNAME))
		drop_perm_menu();
	menu_window = 0;
	permanent_menu = newval;
	if (permanent_menu)
		make_perm_menu();
}

restore_menu(want)	// do we want permanent menu?
{			// assume avoid_top_lines is already correct
	if (!(has_feature & FEAT_OS_MENUS))
		if (!permanent_menu && want) {
			make_perm_menu();
			avoid_top_lines--;
		} else if (permanent_menu && !want) {
			avoid_top_lines++;
			drop_perm_menu();
		}
	permanent_menu = want;
}

is_menu_here()	// has mouse moved onto (possibly not displayed) menu bar?
{
	return !(has_feature & FEAT_OS_MENUS) && still_on_menu_bar()
			&& (auto_menu_bar && mouse_pixel_y <= 0
				&& y_pixels_per_char() > 1 && opsys != OS_UNIX
				|| permanent_menu);
}

still_on_menu_bar()	// is mouse still on menu bar?
{
	return mouse_y <= 0 && mouse_x < screen_cols - 1;
}

num_of_popups()
{
	return number_of_popups() - (permanent_menu != 0);
}

click_menu()		// clicked over menu bar, begin doing menu stuff
{
	do {
		show_menu();
	} while (!permanent_menu && still_on_menu_bar() && await_menu_click());
	refresh();
}

show_menu_while_over()	// show menu while mouse is over it
{
	if (await_menu_click())
		click_menu();
	else
		invisible_cmd();
	if (!permanent_menu)
		remove_window(menu_window);
}

await_menu_click()	// show menu, return 1 if user clicked on it
{
	save_var mouse_cursor = &std_pointer;
	load_menu();
	prep_menu_bar();
	save_var window_handle = menu_window;
	do {
		move_to_column(mouse_x);
		maybe_refresh();
		getkey();
	} while (key == MOUSE_MOVE && still_on_menu_bar());
	remove_window(menu_window);
	if (IS_MOUSE_DOWN(key) && still_on_menu_bar())
		return 1;
	ungot_key = key;
	return 0;
}

make_perm_menu()
{
	int oldwin = window_handle;

	if (has_feature & FEAT_OS_MENUS)
		return;
	load_menu();
	avoid_top_lines++;
	if (echo_line == 0) {
		echo_line = 1;
		say("");
	}
	prep_menu_bar();
	window_handle = menu_window;
	system_window = 1;	// user can't switch to it
	submenu_highlight(0);
	mark = point = 0;
	if (is_window(oldwin) && oldwin != menu_window)
		window_handle = oldwin;
	else
		window_number = 0;
}

drop_perm_menu()
{
	if (has_feature & FEAT_OS_MENUS)
		return;
	remove_window(menu_window);
	avoid_top_lines--;
	if (echo_line == 1) {
		echo_line = 0;
		say("");
	}
	menu_window = 0;
}

get_movement_or_release()	/* wait until mouse moves or buttons up */
{
	int ox = mouse_x, oy = mouse_y;

	while (mouse_pressed() && ox == mouse_x && oy == mouse_y)
		if (char_avail())
			getkey();
}

get_menu_cmd(cmd, sub)
char *cmd;
{
	*cmd = 0;
	if (sub && submenu_is_highlighted()) {
		window_handle = sub;
		save_var point += parse_string(1, "[^\t\n]*\t[ \t]*");
		parse_string(1, ".*", cmd);
	}
}

in_top_menu(sub, num)	// mouse on top line, maybe switch submenus
{			// return submenu handle, or 0 if none
	int new;

	window_handle = menu_window;
	new = show_submenu(sub, num);
	window_handle = menu_window;
	if (new)
		highlight_on();		// highlight on menu bar
	else
		highlight_off();
	if (sub && sub != new)		// remove old submenu
		remove_window(sub);
	return new;
}

show_submenu(old, num)  // put up submenu, return handle, or 0 if none
{			// if num, select that submenu #, else mouse col
	char word[80];
	int before;

	before = point;		// remember where on top line we were
	if (!to_submenu_name(num))
		return 0;
	mark = point;		// highlight from here to after name
	if (!parse_string(1, " [^ \n\t]+ ", word))	// get name of submenu
		return 0;
	if (before == point && is_window(old))	// same submenu selected
		return old;
	return make_submenu(word);
}

to_submenu_name(num)	// move to just before start of num'th submenu name
{			// (if -1, to name under mouse), and return nonzero
	point = 0;	// if a name's there
	if (num < 0)
		move_to_column(mouse_x + 2);
	else {
		while (num-- >= -1 && re_search(1, " +"))
			;		// get right behavior on spaces
		re_search(-1, " *");	// between words
	}
	return curchar() != '\n' && re_search(-1, " [^ \n\t]+");
}

make_submenu(word)
char *word;
{
	char pat[100];
	int sub;

	sub = add_popup(mark, 1, 30, screen_lines, LR_BORD(BBLANK), MENU_BNUM);
	prep_menu_window(color_class submenu);
	display_scroll_bar = 0;
	nl_forward();			// starting from 2nd line,
	sprintf(pat, "^%q[ \t]*", word);
	if (!re_search(1, pat)) {	// look for matching menu
		remove_window(sub);	// can't find menu, give up
		return 0;
	}
	window_width = get_menu_width() + 2;
	nl_forward();
	window_start = point;
	search(1, "\n\n");		// go to blank line after submenu items
	window_height = lines_between(window_start, point) - 1;
	point = window_start;
	return sub;
}

in_sub_menu(sub)	// mouse in a submenu, get to right line
{
	window_handle = sub;
	point_to_pos(mouse_x, mouse_y, mouse_screen);
	to_begin_line();
}

prep_menu_bar()		// Create menu bar
{
	save_var window_handle;
	menu_window = add_popup(0, 0, screen_cols, 1, 0, MENU_BNUM);
	prep_menu_window(color_class menu_bar);
	display_scroll_bar = 0;
	point = 0;
}

prep_menu_window(color)	// Do setup for a menu window
{
	text_color = color;
	set_wattrib(window_handle, PHORIZBORDCOLOR, color);
	set_wattrib(window_handle, PVERTBORDCOLOR, color);
	display_column = 0;
}

submenu_highlight(i)	// turn off submenu highlight, or put it on cur line
{
	*menu_line_spot = i ? point : size();
}

submenu_is_highlighted() // tell if any submenu line is being highlighted
{
	return *menu_line_spot != size();
}

run_menu_selection(p, shift)	// execute cmd named in string p
char *p;
{
	save_var run_by_mouse = 1;
	if (*p && *p != '#') {
		refresh();
		if (shift & (KB_CTRL_DN | KB_SHIFT_DN))
			has_arg = iter = 1;
		do_command(check_command(p));
	}
}

flash_menu_item()
{
	int i;

	for (i = 0; i < menu_bar_flashes; i++) {
		submenu_highlight(0);
		refresh();
		delay(5, 0);
		submenu_highlight(1);
		refresh();
		delay(5, 0);
	}
}

command show_menu() on reg_tab[FALT(2)]
{
	if (has_feature & FEAT_OS_MENUS) {
		invoke_menu(0);
		return;
	}
	save_var mouse_cursor = &std_pointer;
	load_menu();
	if (!permanent_menu)
		prep_menu_bar();
	do_show_menu(0);
}

do_show_menu(num)
{
	char cmd[300];
	int sub, doit;

	save_var window_handle;
	save_var abort_searching = 0;
	save_var mouse_mask |= MASK_MOVE | MASK_UP;
	if (!IS_MOUSE_KEY(key))
		save_var menu_stays_after_click = 1;
	sub = show_menu_loop(num, cmd);
	restore_vars();
	doit = !exit_menu_cancel();
	finish_menu_selection(cmd, sub, doit);
	if (!echo_line)	// if echo line at top, clear menu from it
		note("");
	if (doit)
		run_menu_selection(cmd, (shift_pressed()
						   & (KB_ALT_DN | KB_CTRL_DN | KB_SHIFT_DN)));
}

show_menu_loop(num, cmd)
char *cmd;
{
	int sub = 0, line = 0, max, isdir, oldsub, orignum;

	max = max_submenus();
	if (IS_MOUSE_KEY(key))
		ungot_key = key;
	do {
		oldsub = sub;
		sub = to_sub_line(sub, num, line);
		if (getkey() == MOUSE_MOVE) {
			refresh();
			while (getkey() == MOUSE_MOVE)
				;
		}
		isdir = 1;		// assume it's a direction key
		switch (get_direction()) {
			case BTOP:	line--; break;
			case BBOTTOM:	line++; break;
			case BLEFT:	num--, line = 0; break;
			case BRIGHT:	num++, line = 0; break;
			default:	isdir = 0; break;
		}
		if (isalpha(key))
			line = do_menu_search(key);
		else if (IS_MOUSE_DOWN(key)) {
			if (oldsub && mouse_y <= 0)	// maybe drop menu
				orignum = count_submenus(mouse_x) - 1;
			else
				orignum = -2;	// upclick on bar won't drop
			sub = while_mouse_pressed(sub);
			num = after_mouse_pressed(sub, num, orignum);
			line = 0;
		} else if (binding_of(key, reg_tab) == (short) help) {
			get_menu_cmd(cmd, sub);
			if (*cmd && find_index(cmd))
				help_on_command(cmd);
			isdir = 1;
		}
		num = (num + max) % max;
		line = (line + window_height) % window_height;
	} while (isdir || isalpha(key) || IS_MOUSE_KEY(key));
	if (!exit_menu_doit() && !exit_menu_cancel()) {
		ungot_key = key;
		key = ESC;
	}
	return sub;
}

to_sub_line(sub, num, line)	// move to submenu # & line, maybe switching
{				// submenus, show result, & return new submenu
	sub = in_top_menu(sub, num);
	window_handle = sub;
	for (point = window_start; line-- > 0; )
		nl_forward();
	submenu_highlight(1);
	maybe_refresh();
	return sub;
}

while_mouse_pressed(sub)
{
	mouse_display = 1;
	while (mouse_pressed()) {
		if (mouse_y <= 0) {
			submenu_highlight(0);
			sub = in_top_menu(sub, -1);
			window_handle = menu_window;
		} else if (window_at_coords(mouse_y, mouse_x) == sub) {
			in_sub_menu(sub);
			submenu_highlight(1);
		} else
			submenu_highlight(0);
		refresh();
		get_movement_or_release();
	}
	return sub;
}

after_mouse_pressed(sub, num, orignum)	// convert mouse release to key
{					// and return new submenu #
	int i, max = max_submenus();

	if (mouse_y <= 0) {	// exit menu if we clicked from orig title
		i = count_submenus(mouse_x) - 1;
		if (orignum == num || !menu_stays_after_click)
			key = ESC;
		num = MIN(MAX(i, 0), max - 1);
		if (num != i)	// or if we clicked in blank area of menu bar
			key = ESC;
	} else if (window_at_coords(mouse_y, mouse_x) == sub) {
		in_sub_menu(sub);	// clicked on a cmd
		key = '\r';
	} else				// clicked somewhere else, exit menu
		key = ESC;
	return num;
}

count_submenus(max)	// return number of words on menu bar within max chars
{
	int i;

	save_var window_handle = menu_window;
	save_var point = 0;
	save_var narrow_end = size() - max;
	save_var abort_searching = 0;
	for (i = 0; curchar() != '\n' && re_search(1, " +"); i++)
		;
	return i;
}

max_submenus()		// give total # of submenus
{
	return count_submenus(1000) - 1;
}

do_menu_search(letter)	// look for menu item that starts with letter
{			// return its line number in submenu
	char buf[10];
	int orig = point;

	save_var case_fold = 1;
	save_var narrow_end = size() - window_end;
	nl_forward();		// find next match
	sprintf(buf, "^%c", letter);
	if (!re_search(1, buf)) {
		point = window_start;	// try again from start
		if (!re_search(1, buf))
			point = orig;
	}
	return lines_between(window_start, point);
}

exit_menu_doit()	// does this key do current menu item?
{
	switch (make_alt(key)) {
		case ALT('\r'):
		case ALT('\n'):
		case NUMALT(GREYENTER):	return 1;
	}
	return 0;
}

exit_menu_cancel()	// does this key exit from menu?
{
	return key == ESC || user_abort;
}

finish_menu_selection(cmd, sub, doit)
char *cmd;		// fill in cmd name from menu, then clean up
{
	save_var window_handle;
	if (doit) {
		get_menu_cmd(cmd, sub);
		if (*cmd && *cmd != '#')
			flash_menu_item();
	}
	window_handle = menu_window;
	highlight_off();
	if (!permanent_menu)
		remove_window(menu_window);
	if (sub)
		remove_window(sub);
}

// Take two command lines to execute, separated by "!"s.
// Use the first if there's no highlighted region (or there's just one).
// Otherwise use the second, and replace instances of "!" in it with
// the highlighted region.  Warning: the program to run cannot contain
// spaces in its name or path.  Use convert_to_8_3_filename() on it.

run_by_pattern(p)
char *p;
{
	char text[FNAMELEN], cmdline[FNAMELEN], *s;

	s = index(p, '!');
	save_spot point, mark;
	fix_region();
	if (is_highlight_on() && s && mark - point < sizeof(text)){
		grab(point, mark, text);
		highlight_off();
	} else
		*text = 0;
	if (s && *text) {
		strcpy(cmdline, s + 1);
		p = index(cmdline, '!');
		if (p) {
			strcpy(p, text);
			strcat(p, index(s + 1, '!') + 1);
		}
	} else if (s) {
		strcpy(cmdline, p);
		if (s = index(cmdline, '!'))
			*s = 0;
	}
	if (is_gui || is_win32) {
		char prog[FNAMELEN];
		strcpy(prog, cmdline);
		if (index(prog, ' '))
			*index(prog, ' ') = 0;
		winexec(prog, cmdline, SW_SHOWNORMAL, 0);
	} else
		shell("", cmdline, "");
}

// GUI menu selections or requests from WinHelp run this subroutine.

menu_invoked() on reg_tab[WIN_MENU_SELECT], reg_tab[WIN_HELP_REQUEST]
{
	int i;

	if (_doing_input == DI_LINEINPUT && is_gui) {
		ungot_key = key;
		error_if_input(1);
	}
	if (*menu_command == '$') {		// help file
		char old[FNAMELEN], dir[FNAMELEN];
// MSVC 2 wants the current directory to be \msvc20\bin, when using the help
// file \msvc20\help\xxx.hlp.  The other help files we know about don't care.
// So temporarily set the current directory based on the help file name.
		getcd(old);
		strcpy(dir, menu_command + 1);
		*get_tail(dir, 0) = 0;
		sprintf(get_tail(dir, 0), "bin");
		chdir(dir);
		i = windows_help_from(menu_command + 1, winhelp_display_contents);
		chdir(old);
		if (!i)
			error("Could not display help from %s", menu_command + 1);
		return;
	} else if (*menu_command == '!') {
		run_by_pattern(menu_command + 1);
		return;
	}
	save_var run_by_mouse = 1;
	i = find_index(menu_command);
	switch (name_type(i)) {
		case NT_MACRO:
			run_by_mouse = 0;
		case NT_COMMAND:
		case NT_SUBR:
		case NT_AUTOLOAD:
		case NT_AUTOSUBR:
			add_key_to_macro(CMD_INDEX_KEY + i);
			if (shift_pressed() & (KB_CTRL_DN | KB_SHIFT_DN))
				has_arg = iter = 1;
			do_command(i);
			break;
		case NT_WINVAR:
		case NT_BUFVAR:
		case NT_VAR:
		case NT_BUILTVAR:
			do_set_variable(i);
			break;
		default:
			error("Couldn't call `%s' from menu.", menu_command);
	}
}

// Return 0 if we can't because program's missing.
int set_font_for_unix()
{
	char buf[200];

	pipe_text(NULL, _MATCH_BUF, "xlsfonts", NULL,
			  PIPE_SYNCH | PIPE_CLEAR_BUF | PIPE_NOREFRESH, 0);
	save_var bufname = _MATCH_BUF;
	if (lines_between(0, size(), 0) < 5) {
		say("Couldn't run xlsfonts to list the fonts.");
		return 0;
	}
	point = 0;			// Discard obviously proportional fonts.
	save_var sort_status = 0;
	// Comment out to list var-width fonts.
	do_drop_matching_lines(REGEX, "-p-[^-\n]*-[^-\n]*-[^-\n]*$", 1);
	drop_pending_says();
	do_uniq(1, 1, 0);
	restore_vars();
	save_var resize_menu_list = 1;
	prompt_comp_read(buf, "Select a font", general_matcher,
					 COMP_FOLD | MUST_MATCH | NONE_OK, font_fixed);
	if (!user_abort)
		font_fixed = buf;
	if (strcmp(font_fixed, buf))
		say("Sorry, can't use that font.");
	else
		say("Edit your ~/.Xdefaults file (or similar) to use this font in future sessions.");
	return 1;			// User picked one, even if it was bad.
}

do_set_font(char *prompt, int type, char *varname)
{
	if (has_feature & FEAT_FONT_DIALOG)
		windows_set_font(prompt, type);
	else if (has_feature & FEAT_SET_FONT)
		do_set_variable(find_index(varname));
}

command set_font()
{
	if (opsys != OS_UNIX || ! (has_feature & FEAT_SET_FONT)
		  || !set_font_for_unix())
		do_set_font("Select font", 0, "font-fixed");
}

command set_printer_font()
{
	do_set_font("Select printer font", 1, "font-printer");
}

command set_dialog_font()
{
	do_set_font("Select font for dialogs", 2, "font-dialog");
}

// Helps to select odd font sizes that set-font can't handle
// (for example, many of the fonts used in the DOS box).  Press
// arrow keys to change desired height & width of the current font.
// Press <Enter> or <Space> to exit.  Press the abort key to restore
// the old font size, then exit.  This command cannot select font
// names, or toggle bold/italic settings--use set-font for that.

// To choose a font, first use the set-font command to select the
// desired font name, and select italic or bold options if desired.
// Then run change-font-size (this command) and use the arrow keys to
// move among the different font sizes.  The font size (height & width)
// will be displayed at all times.  A width or height of 0 means
// use a suitable default.

command change_font_size()
{
	char *s, name[50], buf[50], old[50];
	int h, w, dir;

	if (is_unix)
		error("Please use the set-font command to select a font.");
	strcpy(old, font_fixed);
	strcpy(name, font_fixed);
	s = index(name, ',');
	*s = 0;
	h = numtoi(s + 1);
	s = index(s + 1, ',');
	w = numtoi(s + 1);
	s = index(s + 1, ',') + 1;		// rest of spec
	for (;;) {
		note("Using font %s %dx%d, screen is %dx%d. "
			"(Press an arrow key to change.)",
			name, h, w, screen_cols, screen_lines);
		getkey();
		if (user_abort || key == BELL || key == ESC) {
			font_fixed = old;
			break;
		}
		dir = get_direction();
		switch (dir) {
			case BTOP:		if (h > 0) h--; break;
			case BBOTTOM:	h++; break;
			case BLEFT:		if (w > 0) w--; break;
			case BRIGHT:	w++; break;
		}
		if (dir != -1) {
			sprintf(buf, "%s,%d,%d,%s", name, h, w, s);
			font_fixed = buf;
			refresh();
		} else if (IS_ENTER_KEY(key) || key == ' ')
			break;
		else if (IS_TRUE_KEY(key))
			say("Press <Esc> to abort, <Enter> to keep these settings.");
	}
	say("");
}

command invoke_windows_menu() on reg_tab[ALT(' ')]
{
	int k = ' ';

	if (IS_EXT_ASCII_KEY(key))
		k = key & 0xff;	/* strip meta bit */
	invoke_menu(k);
}

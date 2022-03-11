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

// This file has the commands for getting help on Epsilon.

#include "eel.h"
#include "menu.h"
#include "info.h"

command help() on reg_tab[CTRL('_')], reg_tab[ALT('?')], reg_tab[FKEY(1)]
{
	if (_show_help_on)
		help_on_command(_show_help_on);
	else if (_help_on_cmd)
		help_on_command(name_name(_help_on_cmd));
	else if (_doing_input == DI_VIEWLAST || _doing_input == DI_LINEINPUT)
		help_on_command(name_name(last_index));
	else
		general_help();
}

general_help()
{
	if ((has_feature & FEAT_WINHELP) && run_by_mouse)
		win_help_contents("");		// Show Epsilon's contents topic.
	else
		prompt_for_help();
}

prompt_for_help()
{
	for (;;) {
		mention("Help on (? for choices): ");
		do {
			getkey();
		} while (!IS_TRUE_KEY(key));
		check_abort();
		say("");
		if (binding_of(key, root_keys) == (short) help || key == '?')
			dodesc("help", "help", 0);
		else if (key < 128)
			switch (tolower(key)) {
				case 'k': describe_key(); return;
				case 'c': describe_command(); return;
				case 'a': apropos(); return;
				case 'b': show_bindings(); return;
				case 'q': what_is(); return;
				case 'l': show_last_keys(); return;
				case 'v': about_epsilon(); return;
				case 'r': describe_variable(); return;
				case 'm': help_on_mode(); return;
				case 'i': info(); return;
				case 'f': epsilon_info_look_up(); return;
				case 'w': windows_only_help();
						  win_help_contents(""); return;
				case 'h': epsilon_html_look_up(); return;
				case CTRL('C'): info_goto_epsilon_command(); return;
				case CTRL('K'): info_goto_epsilon_key(); return;
				case CTRL('V'):
				case CTRL('R'): info_goto_epsilon_variable(); return;
			}
	}
}

// Run Windows help on file, looking up highlighted text.
// If none, either display the Contents help topic, or display
// the help file's list of search keywords.

windows_help_from(file, show_contents)
char *file;
{
	char buf[FNAMELEN];

	windows_only_help();
	save_spot point, mark;
	fix_region();
	iter = 1;

	if (is_highlight_on() && mark - point < sizeof(buf)){
		grab(point, mark, buf);
		highlight_off();
		return win_help_string(file, buf);
	} else if (show_contents)
		return win_help_contents(file);
	else
		return win_help_string(file, "");
}

help_from_path(file, show_contents)
char *file;
{
	char abs[FNAMELEN], *s;

	windows_only_help();
	s = lookpath(file);
	if (!s)
		error("Can't find %s.", file);
	strcpy(abs, s);
	absolute(abs);
	windows_help_from(abs, show_contents);
}

use_winhelp()
{
	if (has_feature & FEAT_WINHELP)
		if (is_win32 == IS_WIN32_GUI)
			return want_gui_help;
		else
			return want_gui_help_console;
	return 0;
}

command search_all_help_files()
{
	help_from_path("epswhlp.hlp", 0);
}

command epsilon_manual()
{
	if (!(has_feature & FEAT_WINHELP))
		epsilon_manual_html();
	else
		win_help_string("", "Epsilon Manual Contents");
}

html_help_check_ok()
{
	if (is_unix != IS_UNIX_XWIN && !is_gui && !is_win32)
		error("Don't know how to run a web browser in this environment, sorry.");
}

// Cause this URL to be displayed by a browser.
show_url(char *url)
{
	char cmd[300], prog[300];

	if (is_win32) {
		get_executable_directory(prog);
		strcat(prog, "lhelp.exe");
		sprintf(cmd, "lhelp -u \"%s\"", url);
		winexec(prog, cmd, SW_SHOWMINNOACTIVE, 0);
		return;
	} else if (is_unix == IS_UNIX_XWIN) {
		sprintf(cmd, "goto_url \"%s\" >/dev/null 2>&1", url);
		if (!shell("", cmd, ""))	// Search along the path; fail silently.
			return;		// If we failed, try again with std copy we provide.
		get_executable_directory(cmd);
		sprintf(cmd + strlen(cmd), "goto_url \"%s\"", url);
		if (!shell("", cmd, ""))
			return;
	}
	error("Can't start a browser, please access %s manually.", url);
}

html_help_string(char *topic)
{
	char url[FNAMELEN], prog[FNAMELEN], *p, *q, cmdline[100], dir[FNAMELEN];

	if (epsilon_manual_port > 0)
		sprintf(url, "http://127.0.0.1:%d/man/", epsilon_manual_port);
	else
		strcpy(url, "http://www.lugaru.com/cgi-bin/lhelp/man/");
	for (p = topic, q = url + strlen(url); *p; p++, q++)
		if (*p == ' ') {
			strcpy(q, "%20");
			q += 2;
		} else
			*q = *p;
	*q = 0;
	if (!*topic)
		strcat(url, "0");
	get_executable_directory(prog);
	p = lookpath("lhelp/epsilon.lhl");
	if (p) {		// Find name of directory containing our lhelp files.
		strcpy(dir, p);
		*get_tail(dir, 0) = 0;
	} else
		get_executable_directory(dir);
	convert_to_8_3_filename(dir);
	if (opsys == OS_UNIX) {
		sayput("Running a browser...");
		sprintf(prog + strlen(prog), "lhelpd -p %d -d %s &",
				epsilon_manual_port, dir);
		if (epsilon_manual_port > 0)
			shell("", prog, "");
	} else if (is_gui || is_win32) {
		sayput("Starting a browser, please wait...");
		strcat(prog, "lhelp.exe");
		sprintf(cmdline, "lhelp -p %d -d %s", epsilon_manual_port, dir);
		if (epsilon_manual_port > 0)
			winexec(prog, cmdline, SW_SHOWMINNOACTIVE, 0);
	} else
		error("Don't know how to run a web browser in this environment, sorry.");
	show_url(url);
	note("");
}

command epsilon_html_look_up()
{
	char topic[FNAMELEN], def[FNAMELEN], file[FNAMELEN], *p;

	html_help_check_ok();
	*def = 0;
	if (!strcmp(bufname, INFO_BUF)) {
		info_get_file(file);
		if (strstr(file, "epsilon")) {
			p = strchr(filename, ')');
			strcpy(def, p ? (p + 1) : filename);
		}
	}
	get_strnone(topic, "Epsilon help topic to show in browser [title page]: ", def);
	html_help_string(topic);
}

command epsilon_manual_html()
{
	html_help_check_ok();
	html_help_string("");
}

command view_lugaru_web_site()	// point browser to Lugaru's web site
{
	html_help_check_ok();
	if (is_unix == IS_UNIX_XWIN) {
		show_url("www.lugaru.com");
	} else {
		char *s = lookpath("lugaru.url");

		if (!s)			// Can't find URL file, so try this other method.
			s = "http://www.lugaru.com";
		run_viewer(s, "Open", "");
	}
}

#define MAX_HELP_DESCR	40		/* help file descriptions can't be longer */

select_help_dialog_1(w1, w2, w3)
{
	w2 = w2;		// Prevent compiler warnings.
	w3 = w3;
	display_dialog_box("HelpSetup1", "Search for help files", w1, 0, 0,
					   "OK", "Cancel", "");
}

command select_help_files()
{
	char drives[FNAMELEN];
	int buf;

	tiled_only();
	windows_only_help();
	save_var use_alternate_dialog = select_help_dialog_1;
	get_strpopup(drives, "Search these drive letters for help files",
				 "C", "select-help-files");
	restore_vars();
	if (!*drives)
		return;
	save_var window_bufnum;
	buf = tmp_buf();
	to_buffer_num(buf);
	case_fold = 1, indent_with_tabs = 1, tab_size = 4;
	add_help_lines(drives);
	if (user_abort)
		return;
	say("Edit to remove unwanted help files, then type Ctrl-X Ctrl-Z.");
//	use_alternate_dialog = select_help_dialog_2;
//	save_var insert_newlines_in_dialog = 1;
//	view_buf(buf);
	recursive_edit();
	save_var sort_status = 0;
	point = 0;
	add_to_menu(buf, 0);
	point = 0;
	add_to_menu(buf, 1);
	point = 0;
	add_to_keyword_search(buf);
	restore_vars();
	buf_delete(buf);
	init_menu();
	say("Done.");
}

// Look for files matching this pattern:
#define HELP_PAT	"{*.hlp,*.chm,*.col,msdntool.exe,iv2tool.exe}"

add_help_lines(drives)
char *drives;
{
	char pat[FNAMELEN], drivelist[FNAMELEN], *s;

	save_var abort_file_matching = ABORT_ERROR;
	for (*drivelist = 0; *drives; drives++) {
		if (!isalpha(*drives))	// convert drive list to file pattern
			continue;
		strcat(drivelist, "X,");
		drivelist[strlen(drivelist) - 2] = *drives;
	}
	if (strlen(drivelist) < 1)
		return;
	drivelist[strlen(drivelist) - 1] = 0;
	sprintf(pat, "{%s}:\\**\\%s", drivelist, HELP_PAT);
	s = do_file_match(pat, STARTMATCH | EXACTONLY | FM_NO_DIRS);
	while (s) {
		noteput("Searching for known help files...%s", s);
		add_help_line(s);
		s = do_file_match(pat, EXACTONLY | FM_NO_DIRS);		// Get the next match.
	}
}

add_help_line(s)
char *s;
{
	one_help_line(s, "api32.hlp", "Windows API (32-bit)"); // VC2
	one_help_line(s, "win32.hlp", "Windows API (32-bit)");	// Old name
	one_help_line(s, "win31wh.hlp", "Windows API (16-bit)"); // VC1
	one_help_line(s, "tcwhelp.hlp", "Windows API (16-bit)"); // BC3.1
	one_help_line(s, "mfc.hlp", "MFC v1.0"); // VC1
	one_help_line(s, "mfc20.hlp", "MFC v2.0"); // VC2
	one_help_line(s, "mfc30.hlp", "MFC v3.0"); // VC2
	one_help_line(s, "cxx20.hlp", "C/C++ Language"); // VC2
	one_help_line(s, "mscxx.hlp", "C/C++ Language (VC 1.X)"); // VC1
	one_help_line(s, "crt20.hlp", "MSVC 2.X Run Time"); // VC2
	one_help_line(s, "msvc20.hlp", "MSVC 2.X Tools"); // VC2
	one_help_line(s, "mscopts.hlp", "MSVC 1.X Build Tools"); // VC1
	one_help_line(s, "classlib.hlp", "Borland Class Library"); // BC5
	one_help_line(s, "bcpp.hlp", "Borland C/C++ Library"); // BC5
	one_help_line(s, "bcb4.hlp", "Borland C++ Builder v4"); // Borland C++...
	one_help_line(s, "bcb5.hlp", "Borland C++ Builder v5"); // ...Builder
	one_help_line(s, "obpascal.hlp", "Borland Object Pascal Reference");
	one_help_line(s, "vcl.hlp", "Borland Visual Component Library");
	one_help_line(s, "cwg.hlp", "Borland Component Writers Guide");

	// HTML Help files
	one_help_line(s, "htmlhelp.chm", "HTML Help Authoring");
	one_help_line(s, "msdn*.col", "MS Developer Network");

		// MSDL interface (not actually help files)
	one_help_line(s, "msdntool.exe", "Find in MSDL");
	one_help_line(s, "msdntool.exe", "Look Up Keyword in MSDL");
		// MSDL interface (not actually help files)
	one_help_line(s, "iv2tool.exe", "Find in MSDL");
	one_help_line(s, "iv2tool.exe", "Look Up Keyword in MSDL");
}

one_help_line(found, want, descr)
char *found, *want, *descr;
{
	if (!fpatmatch(get_tail(found, 1), want, 0, 1))
		return;
	stuff(descr);
	to_column(MAX_HELP_DESCR);
	bprintf("%s\n", found);
}

// Do special stuff for MSDL lines.

is_help_exe()
{
	char fname[FNAMELEN], find_cmd;

	save_var point;
	save_var narrow_end = size() - give_end_line();
	if (!search(1, ".exe"))
		return 0;
	move_to_column(MAX_HELP_DESCR);
	grab(point, size(), fname);
	convert_to_8_3_filename(fname);
	delete(point, size());		// Is it Find or Keyword Search?
	find_cmd = character(give_begin_line()) == 'F';
	bprintf("!%s!%s /%c !", fname, fname, find_cmd ? 's' : 'k');
	return 1;
}

add_to_menu(buf, context)
{
	char abs[FNAMELEN], *s;
	char line[FNAMELEN], *from, *to;

	save_var bufnum;
	s = lookpath(gui_menu_file);
	if (!s)
		error("Can't find %s", gui_menu_file);
	strcpy(abs, s);
	absolute(abs);
	if (do_find(abs, FILETYPE_AUTO))
		error("Can't read %s", abs);
	save_var case_fold = 1, indent_with_tabs = 1, tab_size = 4;
	if (context) {		// put at end of context menu
		from = "^ _popup";
		to = "^$";
	} else {		// find first separator in help menu
		from = "^ Help";
		to = "#### Put help files before here";
	}
	point = 0;
	if (!re_search(1, from))		// Narrow to one section of the menu.
		error("Can't locate start of menu in gui.mnu.");
	nl_forward();
	save_var narrow_start = point;
	if (!re_search(1, to))
		error("Can't locate end of menu in gui.mnu.");
	to_begin_line();
	save_var narrow_end = size() - point;

	point = 0;
	do_drop_matching_lines(REGEX, "\t[$!]", 1);
	while (grab_line(buf, line)) {
		point = 0;
//		if (search(1, get_tail(line, 1)))
//			delete(give_begin_line(), give_end_line() + 1);
		point = size();
		bprintf("%s\n", line);
		point--;
		move_to_column(MAX_HELP_DESCR);
		if (!is_help_exe())
			stuff("$");
	}
	save_file();
}

add_to_keyword_search(buf)
{
	char abs[FNAMELEN], *s;
	char line[FNAMELEN];

	save_var bufnum;
	s = lookpath("epswhlp.cnt");
	if (!s)
		error("Can't find epswhlp.cnt");
	strcpy(abs, s);
	absolute(abs);
	if (do_find(abs, FILETYPE_AUTO))
		error("Can't read %s", abs);
	point = 0;
	save_var case_fold = 1, indent_with_tabs = 1, tab_size = 4;
	do_drop_matching_lines(REGEX, ":Index .*", 1);
	while (grab_line(buf, line)) {
		point = size();
		bprintf("%s\n", line);
		point--;
		move_to_column(MAX_HELP_DESCR);
		delete_horizontal_space();
		stuff("=");
		to_begin_line();
		stuff(":Index ");
	}
	point = 0;
	do_drop_matching_lines(0, "msdntool.exe", 1);
	save_file();
}

windows_only_help()
{
	if (!(has_feature & FEAT_WINHELP))
		error("This command is only available in Epsilon for Windows.");
}


/* provide help on current command */
help_on_current()
{
	char *name;

	name = name_name(last_index);
	dodesc(name, name, 0);
}

help_on_command(cmd)
char *cmd;
{
	dodesc(cmd, cmd, 0);
}

help_on_mode()		// show help for current buffer's mode
{		// uses convention that foo-mode command goes into foo mode
	char mode_cmd[FNAMELEN];

	sprintf(mode_cmd, "%s-mode", major_mode);
	dodesc(mode_cmd, mode_cmd, 1);
}


/* list all commands with a specifed substring in name or short description */
command apropos()
{
	char str[80], msg[160], name[80];
	int found = 0, start, old = bufnum, helpbuf;

	iter = 0;
	get_string(str, "Apropos: ");
	save_var bufnum;
	if (!*str || !get_doc(0))
		return;
	helpbuf = bufnum;
	noteput("Searching for %s...", str);
	point = 0;
	while (search(1, str)) {
		if (nl_reverse())
			point++;
		if (curchar() != '~')
			nl_forward();
		else {
			found = 1;
			point++;
			parse_string(1, "[^ \t\n]*", name);
			bufnum = old;
			descr_bindings(name, msg);
			buffer_printf(HELPBUF, "%s\n", msg);
			bufnum = helpbuf;
			start = point;
			nl_forward();
			xfer(HELPBUF, start, point);
			add_variable_info(find_index(name));
		}
	}
	if (found) {
		bufname = HELPBUF;
		point = 0;
		string_replace("^[^ \n\t]+", "\1#0\2", REGEX);
	} else
		buffer_printf(HELPBUF, "No matches.\n");
	bufnum = old;
	say("");
	sprintf(msg, " Apropos \"%s\" ", str);
	view_help(msg, 1);
}

add_variable_info(i)		// modify help buf to describe variable i
{
	if (vartype(i)) {
		save_var bufname = HELPBUF;
		point--;
		if (!isspace(character(point - 1)))
			insert(' ');
		bprintf("%s variable.", variable_type_name(vartype(i)));
		to_indentation();
		replace(point, toupper(curchar()));
		point = size();
	}
}


command describe_key()
{
	iter = 0;
	tell_key(1, "Describe key: ");
}

tell_key(full, pr)
char *pr;
{
	char msg[80],tmp[80], *flavor;
	int index;

	index = *ask_key(pr, tmp);
	user_abort = 0;
	say("");
	if (index <= 0)
		sprintf(msg, "The key %s is not bound to any command.", tmp);
	else {
		switch (name_type(index)) {
			case NT_MACRO:	flavor = "macro"; break;
			case NT_SUBR:	flavor = "subroutine"; break;
			default:	flavor = "command"; break;
		}
		sprintf(msg, "%s runs the %s %s.",
			tmp, flavor, name_name(index));
		if (full == 2)
			info_to_epsilon_node(name_name(index), 1);
		else if (full) {
			if (use_winhelp())
				show_help_for(name_name(index));
			else
				dodesc(name_name(index), msg, 1);
			return;
		}
	}
	say("%s", msg);
}

show_help_for(name)
char *name;
{
	switch (name_type(find_index(name))) {
		case NT_WINVAR: case NT_BUFVAR: case NT_VAR:
		case NT_BUILTVAR:
			show_var_help(name);
			return;
	}
	show_cmd_help(name);
}

command describe_command()
{
	char cmd[80];

	if (use_winhelp() && run_by_mouse) {
		win_help_string("", "commands, list of");
		return;
	}
	iter = 0;
	save_var show_mouse_choices = 1;
	get_cmd(cmd, "Describe command", "");
	show_cmd_help(cmd);
}

show_cmd_help(cmd)
char *cmd;
{
	char msg[160];

	if (use_winhelp()) {
		sprintf(msg, "%s command", cmd);
		win_help_string("", msg);
	} else {
		descr_bindings(cmd, msg);
		dodesc(cmd, msg, 1);
	}
}

command describe_variable()
{
	char var[80];

	if (use_winhelp() && run_by_mouse) {
		win_help_string("", "all variables, list of");
		return;
	}
	iter = 0;
	save_var show_mouse_choices = 1, show_all_variables = 1;
	get_var(var, "Describe variable", "", MUST_MATCH);
	restore_vars();
	show_var_help(var);
}

show_var_help(var)
char *var;
{
	char msg[80];

	if (use_winhelp()) {
		sprintf(msg, "%s variable", var);
		win_help_string("", msg);
	} else {
		make_var_help(var, bufnum, window_handle, 0);
		sprintf(msg, " Help on %s ", var);
		view_help(msg, 1);
	}
}

make_var_help(var, buf, win, strip_links)	// make help on var with
char *var;			// index i using values in buf, win
{					// maybe remove links to other topics from help text
	char *quotes, *val;
	int i, start, is_number;
	char tmp[FNAMELEN * 2];	// temp loc for values

	i = find_index(var);
	is_number = (vartype(i) <= TYPE_INT);
	save_var window_handle = win;	// if buffer/window-specific,
	save_var bufnum = buf;		// get value from before this
	val = get_var_val(i, tmp, 0); // command
	restore_vars();

	save_var bufnum = zap(HELPBUF);
	if (!i || !vartype(i)) {
		buffer_printf(HELPBUF, "%s is not a variable.", var);
		return;
	} else if (!get_doc(1)) {
		say("");
		buffer_printf(HELPBUF, "\n\nCan't find edoc file.");
	} else if (name_help(i) < 0) {
		buffer_printf(HELPBUF, "\n\nNo information on %s.", var);
	} else {
		point = name_help(i);
		start = point;
		save_var abort_searching = 0;
		do_searching(REGEX, "^!~");
		xfer(HELPBUF, start, point);
	}
	bufname = HELPBUF;
	point = 0;
	if (strip_links)
		remove_links();
	to_end_line();	// add to end of 1st help line
	bprintf("%s%s variable %s.\n", current_column() ? " " : "",
		variable_type_name(vartype(i)), var);
	replace(0, toupper(character(0)));
	quotes = is_number ? "" : "\"";
	bprintf("Current value: %s%s%s",
		quotes, val ? val : "<Not available>", quotes);
	switch (name_type(i)) {	// has a default value too?
		case NT_BUFVAR:
		case NT_WINVAR:	// show default value
			val = get_var_val(i, tmp, 1);
			bprintf("%sefault value: %s%s%s",
				is_number ? ", d" : "\nD", quotes,
				val ? val : "<Not available>", quotes);
	}
	point = 0;
	delete_final_newlines();
}

descr_bindings(cmd, msg)	/* put line with binding info in msg */
char *cmd, *msg;		/* if none, just put cmd */
{
	int ind, n = 0;
	short *mkeys = mode_keys;

	if ((ind = find_index(cmd)) > 0) {
		sprintf(msg, "%s may be invoked by ", cmd);
		n = find_bindings(msg, ind, mkeys, root_keys, "", 0);
		strcat(msg, ".");
	}
	if (!n)
		strcpy(msg, cmd);
}

show_binding(fmt, cmd)	/* print msg, substituting binding of cmd at %s */
char *fmt, *cmd;
{
	char msg[160];

	give_binding(msg, cmd);
	say(fmt, msg);
}

give_binding(s, cmd) // put text telling how to invoke cmd in s
char *s, *cmd;
{
	int ind;

	ind = find_index(cmd);
	*s = 0;
	if (ind <= 0 || !find_bindings(s, ind, mode_keys, root_keys, "", 0))
		sprintf(s, "Alt-x %s", cmd);
}

dodesc(str, also, last)
char *str, *also;
{
	char *old = bufname, msg[80];
	int start, i;

	if (use_winhelp()) {
		show_help_for(str);
		return;
	}
	if (!get_doc(0))
		return;
	i = find_index(str);
	if (!i || name_help(i) < 0) {
		gripe("No information on %s", str, last);
		bufname = old;
		return;
	}
	point = name_help(i);
	while (isspace(curchar()))
		point++;
	start = point;
	re_search(1, "^!~");
	xfer(HELPBUF, start, point);
	bufname = HELPBUF;
	if (also && *also)
		point = 0, stuff(also);
	insert('\n');
	point = 0;
	bufname = old;
	sprintf(msg, " Help on %s ", str);
	view_help(msg, last);
}

get_doc(quiet)	/* make sure doc file is ready to go, clear help buffer */
{		/* if !quiet, complain if can't find edoc file */
	int exists = exist("-edoc"), i;
	char *s, name[80], *oldbuf = bufname;

	create("-edoc");
	bufname = "-edoc";
	if (!exists) {
		sayput("Loading doc file...");
		if (!(s = lookpath(_docname)) || file_read(s, FILETYPE_AUTO)) {
			bufname = oldbuf;
			delete_buffer("-edoc");
			if (quiet)
				say("");
			else
				gripe("Can't find doc file %s", _docname, 0);
			return 0;
		}
		say("");
		for (i = 1; i <= final_index(); i++)
			set_name_help(i, -1);
		point = 0;
		while (re_search(1, "^~")) {
			parse_string(1, "[^ \t\n]*", name);
			if (i = find_index(name))
				set_name_help(i, point + 1);
		}
	}
	point = 0;
	zap(HELPBUF);
	return 1;
}


command what_is() on reg_tab[FKEY(6)]
{
	iter = 0;
	if (has_arg)
		describe_key();
	else
		tell_key(0, "What is key: ");
}

// Retrieve the word at pos in buffer b.
grab_man_word_from_buffer(int b, int pos, char *word, char *pat)
{
	*word = 0;
	save_var bufnum = b, point = pos;
	point--;		// Get to start of word nearest point.
	re_search(1, pat);
	re_search(-1, pat);
	re_search(1, pat);
	if (point - matchstart + 1 < ptrlen(word))
		grab(matchstart, point, word);
}

literal_if_args()
{
	save_var point = 0;
	return !isalpha(curchar()) || search(1, " ");
}

// Matches path lines from man.conf or manpath.conf.
#define MANCONF_PATH	"^(MANDATORY_|OPTIONAL_)?MANPATH" \
						"(_MAP[ \t]+[^ \t\n]+)?[ \t]+([^ \t\n]+)$"

// Compute a list of directories where man pages might be, and put in
// dest.

build_man_path(char *dest)
{
	int tmp = tmp_buf();

	save_var bufnum = tmp;
	if (!file_read("/etc/manpath.config", FILETYPE_AUTO)
		  || !file_read("/etc/man.config", FILETYPE_AUTO)) {
		do_drop_matching_lines(REGEX, MANCONF_PATH, 0);
		string_replace(MANCONF_PATH, "#3", REGEX);
	}
	stuff("/usr/man\n/usr/share/man\n");
	do_sort_region(0, size(), 0, 0);
	do_uniq(1, 1, 0);
	simple_re_replace(0, "\n", ":");
	simple_re_replace(REGEX, ":<eof>", "");
	grab(0, size(), dest);
	restore_vars();
	buf_delete(tmp);
}

// Return matches for man pages that start with s.
char *man_match(s, flags)
char *s;
{
	char pat[FNAMELEN], match[FNAMELEN], *path, *t, *f, *q;
	char man_path[FNAMELEN * 2];

	if ((flags & STARTMATCH) && *s && (!isalpha(*s) || s[1] == ' ')) {
		zap(_MATCH_BUF);	// Something like "-k foo" or "2 bar".
		buffer_printf(_MATCH_BUF, "%s%s\n", s, (flags & LISTMATCH) ? "" : " ");
		// Just return text itself as the match.
	} else if (flags & STARTMATCH) {
		sayput("Listing matches...");
		zap(_MATCH_BUF);
		path = getenv("MANPATH");
		if (!path)
			build_man_path(path = man_path);
		while (!user_abort) {
			t = strchr(path, path_list_char);
			if (t)
				strncpy(pat, path, t - path);
			else
				strcpy(pat, path);
			if (*pat && pat[strlen(pat) - 1] != '/')
				strcat(pat, "/");
			sprintf(pat + strlen(pat), "man*/%s*", s);
			f = do_file_match(pat, STARTMATCH);
			for (; f && !user_abort; f = do_file_match(pat, 0)) {
				strcpy(match, get_tail(f, 0));
				q = get_extension(match);
				if (q && !strcmp(q, ".gz"))
					*q = 0;
				q = get_extension(match);
				if (!q || !*q)
					continue;
				*q = 0;
				buffer_printf(_MATCH_BUF, "%s\n", match);
			}
			if (!t)
				break;
			path = t + 1;
			drop_pending_says();
		}
		save_var bufname = _MATCH_BUF;
		point = 0;
		do_sort_region(0, size(), 0, 0);
		do_uniq(1, 1, 0);
		restore_vars();
	}
	return general_matcher(s, flags);
}

// Make find-linked-file use the rules for C mode.
man_find_linked_file(char *file)
{
	c_find_linked_file(file);
}

keytable man_tab;
char _man_mode_name[] = "Man";

man_mode()
{
	mode_keys = man_tab;
	major_mode = _man_mode_name;
	mouse_dbl_selects = 1;
	make_mode();
}

man_follow_link() on man_tab['\n'], man_tab['e'], man_tab['\r'],
					 man_tab[GREYENTER]
{
	char buf[FNAMELEN];

	save_var sort_status = 0, abort_searching = 0;
	grab_man_word_from_buffer(bufnum, point, buf,
							  "[-+_0-9a-z.:]+(%(..?%))?");
	if (man_rewrite(buf))
		make_man_page(buf);
	else if (key == MOUSE_DBL_LEFT)
		mouse_selecting();
	else
		error("Not a manual page cross-reference; must use open(2) format.");
}

// Rewrite "open(2)" into "2 open"; return nonzero if we did.
man_rewrite(char *buf)
{
	char p1[FNAMELEN], p2[FNAMELEN], *p;

	if (*buf && buf[strlen(buf) - 1] == '.')
		buf[strlen(buf) - 1] = 0;		// Discard final . char.
	if (*buf && (p = strchr(buf, '('))) {
		strcpy(p1, p + 1);
		*p = 0;
		p = strchr(p1, ')');
		if (p)
			*p = 0;
		strcpy(p2, buf);
		for (p = p1; *p; p++)
			*p = tolower(*p);
		sprintf(buf, "%s %s", p1, p2);
		return 1;
	}
	return 0;
}

command man() on man_tab['m']
{
	char topic[FNAMELEN], buf[FNAMELEN];

	save_var sort_status = 0, abort_searching = 0;
	grab_man_word_from_buffer(bufnum, point, buf,
							  "[-+_0-9a-z.:]+(%(..?%))?");
	man_rewrite(buf);
	save_var completion_literal_char = literal_if_args;
	prompt_comp_read(topic, "Show manual entry for", man_match,
					 COMP_FOLD | SPACE_VALID | CAUTIOUS, buf);
	if (!*topic)
		return;
	make_man_page(topic);
}

make_man_page(char *topic)
{
	char cmdline[FNAMELEN], buf[FNAMELEN];
	int color;

	sprintf(cmdline, "man %s", topic);
	sprintf(buf, "man-%s", topic);
	quiet_set_bookmark();
	to_buffer(buf);
	man_mode();
	if (!size()) {
		set_read_only(0);
		pipe_text(NULL, buf, cmdline, NULL,
				  PIPE_SYNCH | PIPE_CLEAR_BUF | PIPE_NOREFRESH, 0);
		point = 0;
		if (parse_string(1, "Reformatting.*please wait.*\n"))
			delete(0, matchend);
		simple_re_replace(1, "\n\n\n+", "\n\n");
		set_character_color(0, size(), -1);
		point = 0;
		while (re_search(1, ".\b.")) {
			if (character(point - 3) == '_')
				color = color_class man_underlined;
			else
				color = color_class man_bold;
			delete(point - 3, point - 1);
			set_character_color(point - 1, point, color);
			point--;
		}
		filename = "fake-man-file.man";	// So find-linked-files works.
		force_save_as = FSA_NEWFILE;
		discardable_buffer = buffer_not_saveable = 1;
	}
	modified = point = 0;
	set_read_only(3);
}

#define DEFN(c)    ((mtab[c] == 0) ? rtab[c] : mtab[c])
#define WALLINDENT	24	/* indentation of cmd in wall chart */

command wall_chart()
{
	short *mkeys = mode_keys;

	iter = 0;
	tiled_only();
	noteput("Building wall chart...");
	to_buffer_num(zap("wall"));
	chart_table(mkeys, root_keys, "");
	point = 0;
	say("");
}

chart_table(mtab, rtab, prefix)
short *mtab, *rtab;
char *prefix;
{
	int c, last, i, j;
	short *newtab, *newalt;
	char msg[80];

	for (c = 0; c < NUMKEYS; c++) {
		if (DEFN(c) > 0 && name_type(DEFN(c)) != NT_TABLE) {
			strcpy(msg, prefix);
			show_char(msg, c, 1);
			for (last = c; last + 1 < NUMKEYS; last++)
				if (DEFN(last + 1) != DEFN(c))
					break;
			i = strlen(msg);
			if (last > c + 1)
				strcat(msg, "\nto"), i = 2;
			j = (WALLINDENT / tab_size) * tab_size;
			if (!j)
				j = tab_size;
			if (j <= i)
				strcat(msg, " ");
			for (; j > i; j -= tab_size)
				strcat(msg, "\t");
			if (name_type(DEFN(c)) == NT_MACRO)
				strcat(msg,"macro ");
			else if (name_type(DEFN(c)) == NT_SUBR)
				strcat(msg,"subroutine ");
			strcat(msg, name_name(DEFN(c)));
			strcat(msg, "\n");
			if (last > c + 1) {
				strcat(msg, prefix);
				show_char(msg, last, 1);
				strcat(msg, "\n");
				c = last;
			}
			stuff(msg);
		}
	}
	for (c = 0; c < NUMKEYS; c++) {
		if (DEFN(c) > 0 && name_type(DEFN(c)) == NT_TABLE) {
			strcpy(msg, prefix);
			show_char(msg, c, 1);
			strcat(msg, " ");
			newtab = index_table(mtab[c] ? mtab[c] : rtab[c]);
			newalt = index_table(rtab[c] ? rtab[c] : mtab[c]);
			newtab = newtab ? newtab : newalt;
			newalt = newalt ? newalt : newtab;
			chart_table(newtab, newalt, msg);
		}
	}
}

/* take name table index and make a string showing bindings */
find_bindings(msg, ind, mtab, rtab, prefix, count)
char *msg, *prefix;
short *mtab, *rtab;
{
	char tmp[120];
	short *newtab, *newalt;
	int i;

	i = list_bindings(-1, mtab, rtab, ind);
	while (i != -1) {
		if (DEFN(i) == ind) {
			if (strlen(msg) > 56) {
				if (strlen(msg) < 62)
					strcat(msg, ", ...");
				return count;
			}
			if (count++)
				strcat(msg, ", ");
			strcat(msg, prefix);
			show_char(msg, i, 1);
		} else if (DEFN(i) > 0 && name_type(DEFN(i)) == NT_TABLE) {
			strcpy(tmp, prefix);
			show_char(tmp, i, 1);
			strcat(tmp, " ");
			newtab = index_table(mtab[i] ? mtab[i] : rtab[i]);
			newalt = index_table(rtab[i] ? rtab[i] : mtab[i]);
			newtab = newtab ? newtab : newalt;
			newalt = newalt ? newalt : newtab;
			count += find_bindings(msg, ind, newtab, newalt,
						tmp, count);
		}
		i = list_bindings(i, mtab, rtab, ind);
	}
	return count;
}

command show_bindings() on reg_tab[FKEY(5)]
{
	char cmd[80], msg[160];
	int ind, n;
	short *mkeys = mode_keys;

	iter = 0;
	if (has_arg) {
		describe_command();
		return;
	}
	save_var show_mouse_choices = 1;
	get_cmd(cmd, "Show bindings of command", "");
	if ((ind = find_index(cmd)) <= 0)
		sprintf(msg, "Couldn't find %s", cmd);
	else {
		sprintf(msg, "%s may be invoked by ", cmd);
		n = find_bindings(msg, ind, mkeys, root_keys, "", 0);
		if (!n)
			sprintf(msg, "%s is not bound to any key", cmd);
	}
	say("%s", msg);
}

command show_last_keys()
{
	char line[200];
	int i, c, len;

	len = MIN(screen_cols - _view_left - _view_right - 15, sizeof(line));
	if (use_winhelp())
		len = 48;
	bufnum = zap(HELPBUF);
	bprintf("The last %d keys pressed were:\n", MAXRECENT);
	*line = 0;
	for (i = 0; i < MAXRECENT; i++) {
		c = _recent_keys[(i + _recent_place) % MAXRECENT];
		if (c == ' ')
			strcat(line, "<Sp>");
		else
			show_char(line, c, 1);
		if (strlen(line) >= len)
			bprintf("%s\n", line), *line = 0;
		else
			strcat(line, " ");
	}
	bprintf("%s", line);
	view_help(" Last Keys Pressed ", 1);
}

command about_epsilon()
{
	if (is_gui)
		about_box();
	else {
		save_var bufnum = zap(HELPBUF), window_start;
		about_box();
		save_var indents_separate_paragraphs = 1;
		save_var margin_right = screen_cols - _view_left - _view_right - 10;
		fill_paragraph();
		margin_right = screen_cols - _view_left - _view_right;
		point = 0;
		do {
			center_line();
		} while (nl_forward());
		point = 0;
		restore_vars();
		view_help(" About Epsilon ", 1);
	}
}

command release_notes()
{
	char fname[FNAMELEN], *s;

	tiled_only();
	s = lookpath("readme.txt");
	if (!s)
		error("Can't find readme.txt");
	strcpy(fname, s);
	absolute(fname);
	if (!do_find(fname, FILETYPE_AUTO))
		force_save_as = FSA_READONLY;
}

command tutorial()
{
	char *s;

	tiled_only();
	to_buffer("myteach");
	if (s = lookpath("eteach"))
		do_file_read(s, FILETYPE_AUTO);
	else
		error("Can't find tutorial. Install first.");
	filename = "myteach";
	display_column = -1;
}

gripe(msg, str, last)
	char *msg, *str;
{
	save_var bufnum = zap(HELPBUF);
	bprintf(msg, str);
	insert('\n');
	view_help(" Error ", last);
}

help_linker(link)
char *link;
{
	show_help_for(link);
}

view_help(title, last)	/* show help buffer */
char *title;		/* if last, set up & return immediately */
{			/* else return after user reads it */
	buf_delete_final_newlines(name_to_bufnum(HELPBUF));
	save_var _view_title = title;
	if (last)
		save_var paging_retains_view = 1;
	if (window_bufnum != name_to_bufnum(HELPBUF)
			|| window_handle != top_popup())
		view_linked_buf(name_to_bufnum(HELPBUF), last, help_linker);
	else {
		int height = screen_lines - _view_top - _view_bottom;

		create_links();
		window_title(window_handle, BTOP, TITLECENTER, _view_title);
		window_to_fit(height);
	}
}

top_popup()	/* give window handle of top popup, or 0 if no popups */
{
	save_var window_number = -1;	/* switch to top popup */
	return is_window(window_handle) == ISPOPUP ? window_handle : 0;
}

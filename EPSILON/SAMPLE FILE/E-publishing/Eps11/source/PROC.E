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

// This file has commands for running other programs.

#include "eel.h"
#include "proc.h"
#include "colcode.h"
#include "kill.h"

/* Process commands. */

no_running(int talk)			/* make sure no process is running */
{
	if (!is_process_buffer(name_to_bufnum(PROCBUF)))
		return 0;
	if (talk)
		say("A process is already running in buffer %s.", PROCBUF);
	if (strcmp(bufname, PROCBUF)) {
		tiled_only();
		locate_window(PROCBUF, "");
		maybe_refresh();
	}
	point = size();
	return 1;
}

char *get_cmdline(msg, buf)	/* prompt for & return cmd */
char *msg, *buf;		/* if !has_arg, prepare cmd in buf */
{				/* but don't return it */
	if (has_arg) {
		get_strdef(buf, msg, push_cmd);
		strcpy(push_cmd, buf);
		iter = 1;
	}
	build_filename(buf, push_cmd, filename);
	return has_arg ? buf : "";
}

command push() on cx_tab[CTRL('E')]
{
	char cmd[FNAMELEN];

	_last_was_grep = 0;
	do_push(get_cmdline("Push With Command", cmd), capture_output, 1);
}

do_push(cmdline, cap, show)
char *cmdline;	// cap nonzero means capture output, show means show it to user
{		// but show -1 means don't wait for keystroke
	char *s, dir[FNAMELEN], old[FNAMELEN];
	int result, tbuf;

	if (!(has_feature & FEAT_MULT_CONCUR) && !another_process())
		save_var restart_concurrent = 0;
	if (opsys == OS_DOS && !is_gui && !is_win32)
		try_exit_concurrent();
	if (is_unix == IS_UNIX_XWIN && !*cmdline)
		cmdline = push_cmd_unix_interactive;
	iter = 1;
	before_push();
	if (start_process_in_buffer_directory) {
		getcd(old);
		get_buffer_directory(dir);
		chdir(dir);
	}
	result = shell("", cmdline, cap ? bufnum_to_name(tbuf = tmp_buf())
					: "");
	if (start_process_in_buffer_directory == 2)
		chdir(old);
	if (cap) {
		process_captured(tbuf, cmdline);
		buf_delete(tbuf);
	} else if (cmdline[0] && show != -1 && !is_gui && !is_win32 && !is_unix) {
		if (!char_avail()) {
			s = "Press any key to return to Epsilon";
			term_write(0, screen_lines - 1, s, strlen(s),
				color_class after_exiting, 1);
			term_position(strlen(s), screen_lines - 1);
		}
		getkey();
	}
	after_push();
	if (cmdline[0] && cap && show) {
		locate_window(PROCBUF, "");
		point = size();
	}
	if (result == -1 && errno) {
		file_error(errno, "During exec", "Couldn't exec");
		quick_abort();
	}
	maybe_restart_concurrent();
	if (cmdline[0] && result)
		say("Process returned %d", result);
	else
		check_dates(0);
	return result;
}

before_push()
{
	if (is_gui || opsys == OS_UNIX)
		return;
	save_screen(&push_info);
	sayput("");
	while (!in_macro() && unseen_msgs())
		check_abort();
	term_position(0, screen_lines - 1);
	term_mode(0);
}

after_push()
{
	if (is_gui || opsys == OS_UNIX)
		return;
	build_first = 1;
	screen_messed();
	if (term_mode(1))
		restore_screen(&push_info);
	say("");
}

process_captured(b, cmdline)	/* move captured output to process buffer */
char *cmdline;
{
	save_var bufnum;
	create(PROCBUF);
	bufname = PROCBUF;
	if (clear_process_buffer)
		zap(PROCBUF);
	point = is_process_buffer(bufnum) ? type_point : size();
	set_error_spot();
	_had_errors = 0;
	if (point > 0 && character(point - 1) != '\n')
		insert('\n');
	if (cmdline[0])
		bprintf("%s\n", cmdline);
	grab_buffer(b);
	if (point > type_point)
		type_point = point;
}


command start_process() on cx_tab[CTRL('M')]
{
	char cmd[FNAMELEN], *cmdline, *sh, fixup[FNAMELEN], *p;
	char cust1[FNAMELEN], cust2[FNAMELEN], buf[FNAMELEN];
	int i = 1;

	_last_was_grep = 0;
	tiled_only();
	error_if_input(1);
	strcpy(buf, PROCBUF);
	if (has_arg && (has_feature & FEAT_MULT_CONCUR)) {
		if (is_process_buffer(name_to_bufnum(buf)))
			do {
				sprintf(buf, "process-%d", i++);
			} while (is_process_buffer(name_to_bufnum(buf)));
	} else if (no_running(1))
		return;
	iter = has_arg = 0;
	cmdline = get_cmdline("Start Process With Command", cmd);
	create_concur(cmdline, buf);
	locate_window(buf, "");
	if (opsys == OS_UNIX && (sh = getenv("SHELL"))) {
		*cust1 = *cust2 = *fixup = 0;
		if (p = lookpath("epsilon.sh", 0))
			strcpy(cust1, p);
		if (p = lookpath("epsilon.csh", 0))
			strcpy(cust2, p);
		if (!*cust1 || !*cust2)
			sprintf(fixup, "echo \"Customization file not found, "
					"no customizations performed.\">/dev/null");
		else if (strstr(sh, "/sh") || strstr(sh, "/bash") || strstr(sh, "/ksh"))
			sprintf(fixup, ". %s; set +o emacs", cust1);
		else if (strstr(sh, "/csh") || strstr(sh, "/tcsh"))
			sprintf(fixup, "source %s", cust2);
		else
			sprintf(fixup, "echo \"Unrecognized shell, no customizations "
					"performed.\">/dev/null");
		delay(40, 0);	// Let's first get a prompt if we can.
		point = type_point;
		bprintf("%s\n", fixup);
	}
	point = size();
	process_mode();
}

create_concur(char *cmdline, char *buf)
{
	char dir[FNAMELEN], old[FNAMELEN];
	int err = 0;

	create(buf);
	if (clear_process_buffer)
		zap(buf);
	if (start_process_in_buffer_directory) {
		getcd(old);	// Don't switch to proc buffer before
		get_buffer_directory(dir);	// doing this.
		chdir(dir);
	}
	bufname = buf;
	point = size();
	if (!is_process_buffer(bufnum))
		err = do_concur_shell("", cmdline, buf);
	if (start_process_in_buffer_directory == 2)
		chdir(old);
	if (err) {
		file_error(errno, "During exec", "Couldn't exec");
		quick_abort();
	}
}

command stop_process() on cc_tab[CTRL('C')]
{
	halt_process(has_arg ? iter : 0, is_process_buffer(bufnum) ? bufnum : 0);
	iter = 1;
}

int exit_this_process(char *buf)
{
	save_var bufname = buf;
	if (is_process_buffer(name_to_bufnum(buf)) == ISPROC_PIPE)
		return 0;
	type_point = point = size();
	stuff("exit\n");
	delay(500, COND_PROC);
	return !is_process_buffer(name_to_bufnum(buf));
}

command exit_process()
{
	tiled_only();
	if (!exist(PROCBUF) || !is_process_buffer(name_to_bufnum(PROCBUF)))
		error("No process to exit");
	if (!exit_this_process(PROCBUF) && !char_avail()) {
		locate_window(PROCBUF, "");
		error("Couldn't exit from concurrent process.");
	}
}

command kill_process()
{
	if (!process_kill(is_process_buffer(bufnum) ? bufnum : 0))
		say("Unable to kill the process.");
}

command compile_buffer() on reg_tab[FALT(3)]
{		// compile the current buffer (mode-specific)
	int res;
	char cmd[FNAMELEN], oscmd[FNAMELEN], full[FNAMELEN], *ext;

	tiled_only();
	if (!compile_buffer_cmd) {
		ext = get_extension(filename);
		sprintf(cmd, "compile-%s-cmd", *ext ? (ext + 1) : "none");
		sprintf(oscmd, "%s-%s", cmd, is_unix ? "unix" :
				is_win32 ? "win32" : "other");
		if ((ext = get_str_var(find_index(oscmd)))
			  || (ext = get_str_var(find_index(cmd))))
			save_var compile_buffer_cmd = ext;
	}
	if (!compile_buffer_cmd) {
		get_string(cmd, "Command to compile this buffer: ");
		compile_buffer_cmd = strsave(cmd);
	}
	save_var concurrent_make, shell_shrinks;
	if (pre_compile_hook)	// hook can change above vars
		if ((*pre_compile_hook)())
			return;		// hook says don't do compile
	if (concurrent_compile < 3)
		concurrent_make = concurrent_compile;
	if (concurrent_compile == 0 && (is_gui || is_win32))	// Run in the 
		concurrent_make = 4;		// concur proc if any, but keep control.
	if (start_process_in_buffer_directory) {
		char dir[FNAMELEN], old[FNAMELEN];

		getcd(old);
		get_buffer_directory(dir);
		chdir(dir);
		build_filename(full, compile_buffer_cmd, filename);
		chdir(old);
		if (start_process_in_buffer_directory == 2)	// For error msgs.
			save_var start_process_in_buffer_directory = 1;
	} else
		build_filename(full, compile_buffer_cmd, filename);
	res = do_compile(full);
	if ((!res || res == 4) && post_compile_hook)
		(*post_compile_hook)(res);
}

load_this_bytecode_file(res)	// load .b file made from current file
{
	char file[FNAMELEN];

	strcpy(file, filename);
	strcpy(get_extension(file), byte_extension);
	if (check_file(file, NULL) == CHECK_FILE) {
		load_commands(filename);
		say("%s compiled and loaded.%s", *filename ? filename : "Buffer",
		   res == 4 ? "  (There were warnings.)" : "");
	}
}

compile_via_dll()	// Try to compile .e file using a DLL, return 1 if ok.
{
	if (!(has_feature & FEAT_EEL_COMPILE))
		return 0;			// Not supported under this platform.
	_had_errors = 0;
	save_var point;
	switch (eel_compile(bufname, 0, compile_eel_dll_flags, "eel-errors")) {
		case 2:		// Couldn't access DLL.
			say("Unable to compile using eel_lib.dll, running process.");
			return 0;
		case 1:
			break;
		case 0:
			say("%s compiled and loaded.%s",
				filename ? filename : "Buffer",
				buffer_size("eel-errors") ? "  (There were warnings.)" : "");
			break;
		default:
			say("Unable to compile internally, running process.");
			return 0;
	}
	restore_vars();
	save_var bufname = "eel-errors";
	if (size()) {
		point = 0;			// Starting at the beginning,
		set_error_spot();	//    scan in this buffer.
		do_next_error(1, NULL);	// Scan for error messages.
	} else {
		restore_vars();
		delete_buffer("eel-errors");
	}
	return 1;
}

command make() on cx_tab['m']
{
	char cmd[FNAMELEN];

	tiled_only();
	get_cmdline("Make using command", cmd);
	save_var start_process_in_buffer_directory
			= start_make_in_buffer_directory;
	do_compile(cmd);
}

compile_handler(int activity, int buf, int from, int to)
{
	to = to;			// Prevent compiler warning.
	if (activity == NET_DONE) {
		save_var bufnum = buf;
		point = size();
		if (size() && character(point - 1) != '\n')
			bprintf("\n");
		bprintf("Process exited with status %d\n", from);
	}
}

// Run the given cmd, then search for errors.
// Return 0 if the compile was ok,
// 1 if the process returned an error code,
// 2 if we ran it concurrently and the user started typing,
// 3 if the user didn't ok saving,
// 4 if the process returned 0, but next-error found some errors.
// 5 if we can't tell when the process has finished.
do_compile(cmd)
char *cmd;
{
	int err = 0, nerr, sep_buf_ok = 0;
	int obuf = bufnum;
	char *procbuf = PROCBUF, curdir[FNAMELEN];

	_last_was_grep = 0;
	if (maybe_save_all())
		return 3;
	if (start_process_in_buffer_directory)
		get_buffer_directory(curdir);
	else
		getcd(curdir);
	drop_final_slash(curdir);
	if (!(has_feature & FEAT_MULT_CONCUR) && !another_process())
		save_var restart_concurrent = 0;

	// If we're allowed to run non-concur, then use separate buffer.
	if (concurrent_make < 2 && (has_feature & FEAT_MULT_CONCUR)
		  && compile_in_separate_buffer)
		sep_buf_ok = 1;
	if (concurrent_make == 2)
		create_concur("", PROCBUF);
	else if (!sep_buf_ok && concurrent_make == 0)
		try_exit_concurrent();
	if (sep_buf_ok) {
		bufnum = create(procbuf = "compilation-output");
		tab_size = process_tab_size;
		discardable_buffer = 1;
		point = size();
		set_error_spot();
		_had_errors = 0;
		bprintf("Running `%s' in directory `%s'\n", cmd, curdir);
		type_point = size();
		if (!concur_shell("", cmd, curdir, procbuf)) {
			while (process_exit_status == PROC_STATUS_RUNNING) {
				if (char_avail() && getkey() != MOUSE_MOVE) {
					ungot_key = key;	// Wait until user presses a key
					return 2;			// or process finishes.
				}
				delay(10, COND_KEY);	// Delay 0.1 secs
			}
			err = process_exit_status;
		} else
			err = -1;
	} else if (concurrent_make == 4 && is_process_buffer(name_to_bufnum(PROCBUF))) {
		save_var bufname = PROCBUF;	// Run the program in the concur
		set_error_spot();			// proc buffer, but don't process
		_had_errors = 0;			// the user's keys until it finishes.
		if (*cmd) {
			point = size();
			bprintf("%s\n", cmd);
		}
		maybe_refresh();
		iter = 1;
		delay(-1, COND_PROC);
		if (!is_process_buffer(name_to_bufnum(PROCBUF)) || !process_input())
			return 2;	/* else assume it's compiled */
	} else if (no_running(0)) {	/* goes to end of proc buffer */
		set_error_spot();
		_had_errors = 0;
		if (*cmd)
			bprintf("%s\n", cmd);
		maybe_refresh();
		iter = 1;
		if (opsys != OS_UNIX)
			delay(-1, COND_PROC | COND_KEY);
		if (!is_process_buffer(name_to_bufnum(PROCBUF)) || !process_input())
			return 2;	/* else assume it's compiled */
		if (!(has_feature & FEAT_DETECT_CONCUR_WAIT))
			return 5;
	} else
		err = do_push(cmd, 1, 0);
	maybe_restart_concurrent();
	nerr = do_next_error(1, cmd);	// scan for error messages
	if (!nerr && err) {	// no message recognized, but error code
		say("Process returned %d", err);
		locate_window(procbuf, "");
		point = size();		/* show end of process buffer */
		return err;
	} else
		bufnum = obuf;
	if (err)
		return 1;
	else if (nerr)
		return 4;
	return 0;
}

// The following functions save & restore a concurrent process.  To use,
// you must first execute:
// 	if (!another_process()) save_var restart_concurrent = 0;
// Then call try_exit_concurrent(), run the process, and then call
// maybe_restart_concurrent().
// These functions are disabled in versions that support multiple
// concurrent processes, as they're not useful there.

try_exit_concurrent()
{
	if (!(has_feature & FEAT_MULT_CONCUR) && another_process()) {
		exit_process();
		if (another_process())
			error("Couldn't exit from concurrent process.");
	}
}

maybe_restart_concurrent()
{
	if (!(has_feature & FEAT_MULT_CONCUR) && restart_concurrent
		  && !another_process())
		do_concur_shell("", "", PROCBUF);
}

// Epsilon calls this function whenever something happens with the
// process.

concur_handler(int activity, int buf, int from, int to)
{
	switch (activity) {
		case NET_SEND:	do_when_process_input(buf, from, to); break;
		case NET_RECV:	do_when_process_output(buf, from, to); break;
	}
}

do_concur_shell(char *prog, char *cmd, char *buf)
{
	save_var bufnum = create(buf);
	when_activity = concur_handler;
	restore_vars();
	return concur_shell(prog, cmd, "", buf);
}

process_find_linked_file(char *file)
{
	int buf = bufnum, pos = point;

	save_var _had_errors = 2;
	if (do_next_error(0, NULL)) {		// Found an error message here.
		save_var bufnum = buf, point = pos;
		quiet_set_bookmark();
		quick_abort();
	}
	say("");
	default_find_linked_file(file);
}

command next_error()
{
	do_next_error(iter, NULL);
	iter = 1;
}

command previous_error()
{
	do_next_error(-iter, NULL);
	iter = 1;
}

// A reference to this file was found in compiler output in the
// specified buffer.  Determine the directory it's in and make it an
// absolute pathname.  We recognize the "Running" message we insert,
// and the Entering and Leaving messages created by Gnu Make that
// indicate it's changing directories.

process_find_directory(char *file, int buf, int pos)
{
	char dir[FNAMELEN];
	int level = 0, got = 0;

	save_var bufnum = buf, point = pos;
	*dir = 0;
	if (is_process_buffer(bufnum) && *process_current_directory)
		strcpy(dir, process_current_directory);
	while (!got && re_search(-1, "(Entering|Leaving|Running `.*' in)"
							 " directory `(.*)'$")) {
		switch (character(find_group(1, 1))) {
			case 'L':	level++; break;
			case 'E':	if (--level > 0)
							break;
			case 'R':	got = 1;
						grab(find_group(2, 1), find_group(2, 0), dir);
						break;
		}
	}
	convert_cygwin_filename(dir);
	if (*dir)
		absolute(file, dir);
	else
		absolute(file);
}

/* if you change ERROR_PATTERN, change the next 3 macros as well */
#define ERROR_PATTERN	"^([1-9]>|e \"|w \"|<*>*(error|warning|fatal|[a-z0-9]+ )" \
			"( [a-z][0-9]+)?<*>*:?|[\"(]?) *" \
			"(([a-z]:)?[+-9A-z~][+-9A-z~ ]*<.>[+-9A-z]+[0-9<>]*)\"?" \
			"([ (:,]( *line|L)?) *" \
			"([0-9]+)(<rparen|:>|[^0-9\n].*[:;]).*"
#define FILE_PAREN	4	/* filename is in 4th () pair above */
#define LINE_PAREN	8	/* line# is in 8th pair of parens above */
#define SIMP_PATTERN	"[:;)]| line "	/* search with simple pattern first */

#define ERROR_PATTERN2	".* at (.+) line ([0-9]+)[.,].*"
#define FILE_PAREN2	1	/* filename in () pair above */
#define LINE_PAREN2	2	/* line# in pair of parens above */

// An error pattern that permits file names with no . character, but
// with more restrictions on the format.
#define ERROR_PATTERN3	"^([+-9A-z~:]+[0-9<>]*)([ (:,]( line|L)?) *" \
						"([0-9]+)[ :)]*(error|warning).*[:;].*"
#define FILE_PAREN3	1	/* filename is in 1st () pair above */
#define LINE_PAREN3	2	/* line# is in 2nd pair of parens above */

// You can define ERROR_PATTERN4 with an alternate pattern.  Epsilon
// will look for either one, on lines that contain SIMP_PATTERN.
// Define FILE_PAREN4 and LINE_PAREN4 to match.  (Also ERROR_PATTERN5
// etc.)

do_next_error(int count, char *cmd)	// return 0 if no errors, else 1
{
	char file[FNAMELEN], number[30], line[130], *p;
	int lineno, origpt, dir, from, to, is_bufname, file_paren, line_paren;
	int orig = bufnum, procbuf;

	tiled_only();
	_last_was_grep = 0;
	if (spot_to_buffer(error_spot) <= 0 && !exist(PROCBUF))
		error("No process buffer to read errors from.");
	tiled_only();
	if (spot_to_buffer(error_spot) > 0)
		bufnum = spot_to_buffer(error_spot);
	else
		bufname = PROCBUF;
	procbuf = bufnum;
	origpt = point;
	case_fold = 1;
	if (spot_to_buffer(error_spot) > 0)
		point = *error_spot;
	else {
		error_spot = alloc_spot();
		point = 0;
	}
	if (!count && procbuf == orig)
		point = origpt;

	noteput("Searching...");
	if (!count)
		find_error(-1, &file_paren, &line_paren), count = 1;
	dir = (count > 0) ? 1 : -1;
	for (; count; count -= dir) {
		if (!find_error(dir, &file_paren, &line_paren)) {
			point = origpt;
			bufnum = orig;
			if (_had_errors == 2)
				return 0;
			else if (_had_errors)
				say("No more errors.");
			else if (cmd)
				say("No errors running \"%s\".", cmd);
			else
				say("No errors.");
			return 0;
		}
	}
	_had_errors = 1;
	grab(find_group(file_paren, 1), find_group(file_paren, 0), file);
	grab(find_group(line_paren, 1), find_group(line_paren, 0), number);
	from = find_group(line_paren, 0);
	to = find_group(0, 0);
	if (to - from < 20)	// error message at end is too short
		from = find_group(0, 1);	// so try including whole line
	if (to > from + sizeof(line) - 1)
		to = from + sizeof(line) - 1;
	grab(from, to, line);
	is_bufname = (parse_string(1, "Buffer ") != 0);
	if (dir > 0)
		to_end_line();
	*error_spot = point;
	point = origpt;
	lineno = strtoi(number, 10);
	bufnum = orig;
	if (is_bufname)
		locate_window(file, "");
	else {
		process_find_directory(file, procbuf, from);
		locate_window("", file);
		find_it(file, default_translation_type);
	}
	go_line(lineno);
	for (p = line; *p && index("() :;\t", *p); p++)
		;			// skip over these chars at start of msg
	say("=> %s", p);
	return 1;
}

/* Find next error in direction, return 1 and set vars to find_group() paren count */
find_error(int dir, int *file_paren, int *line_paren)
{
	int old = point;

	if (point > 0 && dir > 0)
		to_end_line();
	else
		to_begin_line();
	while (re_search(dir, SIMP_PATTERN)) {
		to_begin_line();
		if ((!*ignore_error || !parse_string(1, ignore_error, NULL))
			  && !parse_string(1, "In file included from ", NULL)) {
			if (parse_string(1, ERROR_PATTERN, (char *)0)) {
				*file_paren = FILE_PAREN;
				*line_paren = LINE_PAREN;
				return 1;
			}
#ifdef ERROR_PATTERN2
			if (parse_string(1, ERROR_PATTERN2, (char *)0)) {
				*file_paren = FILE_PAREN2;
				*line_paren = LINE_PAREN2;
				return 1;
			}
#endif
#ifdef ERROR_PATTERN3
			if (parse_string(1, ERROR_PATTERN3, (char *)0)) {
				*file_paren = FILE_PAREN3;
				*line_paren = LINE_PAREN3;
				return 1;
			}
#endif
#ifdef ERROR_PATTERN4
			if (parse_string(1, ERROR_PATTERN4, (char *)0)) {
				*file_paren = FILE_PAREN4;
				*line_paren = LINE_PAREN4;
				return 1;
			}
#endif
#ifdef ERROR_PATTERN5
			if (parse_string(1, ERROR_PATTERN5, (char *)0)) {
				*file_paren = FILE_PAREN5;
				*line_paren = LINE_PAREN5;
				return 1;
			}
#endif
#ifdef ERROR_PATTERN6
			if (parse_string(1, ERROR_PATTERN6, (char *)0)) {
				*file_paren = FILE_PAREN6;
				*line_paren = LINE_PAREN6;
				return 1;
			}
#endif
		}
		if (dir > 0)
			nl_forward();
	}
	*error_spot = old;
	return 0;
}

command view_process() on reg_tab[FSHIFT(3)]	// put up a list of errors,
{					//  let user select one, and go there
	int w = window_handle, win, buf, pos, proc;

	tiled_only();
	if (buf_exist(spot_to_buffer(error_spot)))
		proc = spot_to_buffer(error_spot);
	else if (exist(PROCBUF))
		proc = name_to_bufnum(PROCBUF);
	else
		error("No process buffer to read errors from.");
	save_var menu_width = screen_cols - _view_left - _view_right;
	save_var _doing_input = DI_LINEINPUT;

	save_var bufnum = proc;
	if (spot_to_buffer(error_spot) != bufnum) {
		pos = 0;
		set_error_spot();
	} else
		pos = *error_spot;
	win = new_menu(buf = tmp_buf());
	grab_buffer(proc);
	point = pos;
	to_begin_line();
	window_title(win, BTOP, TITLECENTER, " Compiler Errors ");
	window_to_fit(screen_lines - 7);
	save_var _window_flags |= HIGHLIGHT_LINE;
	save_var search_in_menu = 0;
	save_var display_column = -1;	// ensure all of msg is visible
	if (is_gui && want_gui_prompts) {
		one_window_to_dialog("Select an error message", win,
							 "To Error", "Cancel", "");
	} else
		say("Select an error message and press <Enter>.");
	set_read_only(1);
	select_menu_item(0, win, w, 0);
	bufnum = buf;
	pos = point;
	bufnum = proc;
	buf_delete(buf);
	check_abort();
	point = pos;
	set_error_spot();
	ungot_key = -1;
	restore_vars();
	do_next_error(0, NULL);
}

color_process_range(from, to)
{
	if (from >= to || spot_to_buffer(process_input_starts_at) <= 0)
		return to;
	save_var point, matchstart, matchend;
	point = *process_input_starts_at;
	if (get_character_color(point - 1) != color_class process_prompt)
		return to;
	to_end_line();
	set_character_color(*process_input_starts_at, point,
						color_class process_input);
	return to;
}

process_cmds_to_end()
{
	save_var bufname = PROC_CMDS_BUF;
	point = 0;
	do_uniq(1, 1, 0);		// discard adjacent duplicate cmds silently
	point = size();
}

// This process buffer region might be a prompt containing a directory
// name.  If this is NT, where we can't get concurrent process directory
// names in any other way, grab it and set Epsilon to that dir.
// We assume here that the prompt is the usual "$P$G".

try_grab_directory_name(int from, int to)
{
	char dir[FNAMELEN];

	if (is_gui != IS_NT || !use_process_current_directory
		|| to - from > 200)
		return;					// Too long for a likely dir name.
	if (character(--to) != '>')
		return;
	grab(from, to, dir);
	convert_cygwin_filename(dir);
	if (is_directory(dir)) {
		process_current_directory = dir;
		if (use_process_current_directory == 2)
			chdir(dir);
		can_get_process_directory = 1;
	}
}

// Called in versions that only permit one process buffer.
when_process_input(int type, int start)
{
	do_when_process_input(name_to_bufnum(PROCBUF), type, start);
}

when_process_output(int start, int end)
{
	do_when_process_output(name_to_bufnum(PROCBUF), start, end);
}

notice_password_prompt(int pos)
{
	UNREFERENCED_PARAMETER(pos);
	save_var case_fold = 1, point = size();
	if ((recognize_password_prompt & 2) && (has_feature & FEAT_PROC_SEND_TEXT)
		  && parse_string(-1, "^(type the |.*@.* )?password( for .*)?:[ \t]*")
		  && ungot_key == -1 && !_doing_input && !number_of_popups()) {
		ungot_key = WIN_HELP_REQUEST;	// Make Epsilon run this cmd:
		menu_command = "password-prompt";
	}
}

// The process is now ready for or has just been sent some input.
do_when_process_input(int buf, int type, int start)
{
	save_var bufnum = buf;
	save_var point = start;
	if (type == PROCESS_INPUT_LINE) {
		if (opsys == OS_UNIX)	// Our only opportunity to color.
			set_character_color(give_begin_line(), start,
								color_class process_prompt);
		create(PROC_CMDS_BUF);
		process_cmds_to_end();
		nl_forward();
		if (point > start + 1)		// don't store empty (just \n) cmds
			xfer(PROC_CMDS_BUF, start, point);
		process_cmds_to_end();
	} else if (type == PROCESS_INPUT_CHAR)
		set_character_color(start, start + 1, color_class process_input);
	else if (!type) {		// Got a request for line input (might now wait).
		if (spot_to_buffer(process_input_starts_at) <= 0)
			process_input_starts_at = alloc_spot();
		*process_input_starts_at = start;
		point = start;
		to_begin_line();
		set_character_color(point, start, color_class process_prompt);
		try_grab_directory_name(point, start);
	}
}

// Process ANSI color setting sequence with cnt colors specified.
// We expect that we've just searched for
// ESC [ mode ; mode ; mode m SomeText ESC [ 0 m
// where there may be 1, 2, or 3 modes specified.

color_ansi_output_section(int cnt)
{
	char val[20], *colortrans = "\0\4\2\6\1\5\3\7";
	int i, color, matches[4];
	int fore, back, bold = 0, wanted, have, tcolor, newcolor;

	tcolor = alter_color(color_class process_output, -1);
	fore = tcolor & 0xf;		// Get colors for normal text in buffer.
	back = (tcolor / 16) & 0xf;
	for (i = 1; i <= cnt; i++) {	// Parse color spec.
		if (find_group(i, 0) - find_group(i, 1) > sizeof(val) - 2)
			return;				// Don't touch this odd one.
		grab(find_group(i, 1), find_group(i, 0), val);
		color = numtoi(val);
		if (color >= 30 && color <= 37)		// Set the foreground.
			fore = colortrans[color - 30];
		else if (color >= 40 && color <= 47)	// Background.
			back = colortrans[color - 40];
		else if (color == 1)				// Set bold.
			bold = 1;
	}
	wanted = fore + back * 16 + bold * 8;
	matches[0] = matches[1] = matches[2] = matches[3] = -1;
	for (i = 0; i < number_of_color_classes(); i++) {
		have = alter_color(i, -1);	// Look for approx desired color.
		if (matches[0] == -1 && have == wanted)
			matches[0] = i;		// Pretty good match.
		if (matches[1] == -1 && (have & 0x77) == (wanted & 0x77))
			matches[1] = i;		// Only boldness doesn't match.
		if (matches[2] == -1 && (have & 0x7) == (wanted & 0x7))
			matches[2] = i;		// Only foreground matches.
		if (matches[3] == -1 && (have & 0xf0) == (tcolor & 0xf0)
			&& (have & 0xf) != (tcolor & 0xf))
			matches[3] = i;		// A suitable default -- same bg,
	}							// different fg as normal text.
	for (i = 4, newcolor = 0; --i >= 0; )		// Find the best option.
		if (matches[i] != -1)
			newcolor = matches[i];

	if (color && get_character_color(find_group(cnt, 0))
		  == color_class process_output)
		set_character_color(matchstart, matchend, newcolor);
	delete(find_group(cnt + 1, 1), find_group(cnt + 1, 0));
	delete(matchstart, find_group(cnt, 0));	// Delete color specs.
}

// Delete ANSI color setting commands, typically produced by the "ls"
// command, and replace them with buffer coloring.  We only look for
// certain color sequences, and leave the rest alone.  For each color
// spec, we try to find the best match among the current set of color
// classes.

color_ansi_output(int start)
{
	save_var point = start - 25;
	if (search(1, "\x1B")) {
		point = start - 25;
		while (re_search(1, "\x1B%[([0-9]+);([0-9]+);([0-9]+m)[^\n\x1B]*"
						 "(\x1B%[0*m)"))
			color_ansi_output_section(3);
		point = start - 25;
		while (re_search(1, "\x1B%[([0-9]+);([0-9]+m)[^\n\x1B]*(\x1B%[0*m)"))
			color_ansi_output_section(2);
		point = start - 25;
		while (re_search(1, "\x1B%[([0-9]+m)[^\n\x1B]*(\x1B%[0*m)"))
			color_ansi_output_section(1);
		point = start - 25;
		while (re_search(1, "\x1B%[0*m"))	// Remove stray resets.
			delete(matchstart, matchend);
	}
	point = start - 1;	// For Unix, color user input after system echos it.
	if ((get_character_color(point) == color_class process_prompt
		 || get_character_color(point) == color_class process_input)
		  && curchar() != '\n')
		set_character_color(start, give_end_line(),
							color_class process_input);
}

// If the current line would be off the bottom of the window, adjust
// the window so it's on the last line instead.  (If we didn't,
// redisplay would center the window around this line.)

line_up_to_bottom()
{
	int new_window_start = prev_screen_line(text_height() - 1);

	if (new_window_start > window_start)
		window_start = new_window_start;
}

// The process has just produced some output.

do_when_process_output(int buf, int start, int end)
{
	save_var bufnum = buf;
	set_character_color(start, end, color_class process_output);
	if (opsys == OS_UNIX)
		color_ansi_output(start);
	notice_password_prompt(start);
	save_var position_window_on_screen_line = 100;
	if (buf_in_window(buf) >= 0)
		refresh();
}

command process_mode()
{
	mode_keys = process_tab;
	major_mode = _process_mode_name;
	tab_size = process_tab_size;
	discardable_buffer = 1;
	recolor_range = color_process_range;	// set up coloring rules
	recolor_from_here = recolor_from_top;
	when_setting_want_code_coloring();	// maybe turn on coloring
	make_mode();
}

command process_enter() on process_tab['\r'], process_tab[GREYENTER]
{
	int set_err = 1;

	if (process_enter_whole_line == 2 && point < type_point) {
		char line[FNAMELEN];

		to_begin_line();
		point += parse_string(1, "[^>$#%]*[>$#%] *");
		parse_string(1, ".*", line);
		point = size();	// grab current line excluding prompt
		stuff(line);	// and copy to the end
		return;
	}
	if (process_enter_whole_line && point >= type_point)
		to_end_line();
	if (parse_string(-1, "Terminate batch job.*"))
		set_err = 0;
	enter_key();

// Pressing Enter should usually set the error spot.  When shouldn't it?
// 1. When you've pre-typed the next compilation command in the middle
// of a previous compile?
// 2. When you've just hit enter without typing anything?
//	if (point > type_point + 1 && (spot_to_buffer(error_spot) != bufnum
//								   || point < *error_spot))
// 3. When you're confirming aborting a batch file in Windows.

	if (set_err)
		set_error_spot(), (*error_spot)--;
	_last_was_grep = 0;
	if (point >= window_end && process_output_to_window_bottom)
		line_up_to_bottom();
}

process_get_previous_cmd(int down)
{
	int buf = bufnum;
	char cmd[FNAMELEN];

	point = size();
	if (!exist(PROC_CMDS_BUF))
		return;
	*cmd = 0;
	if (has_arg) {
		iter = 0;
		save_var bufname = PROC_CMDS_BUF;
		if (point == size())
			point--;
		to_begin_line();
		restore_vars();
		if (!get_choice(name_to_bufnum(PROC_CMDS_BUF), cmd,
						"Previous commands", "Select a previous command",
						"OK", "Cancel", ""))
			return;
	}
	if (spot_to_buffer(process_input_starts_at) > 0
		&& !lines_between(*process_input_starts_at, point))
		delete(*process_input_starts_at, point);
	else {
		if (spot_to_buffer(process_input_starts_at) <= 0)
			process_input_starts_at = alloc_spot();
		*process_input_starts_at = point;
	}
	if (*cmd)
		stuff(cmd);
	else {
		save_var bufname = PROC_CMDS_BUF;
		down_or_up_lines(down);
		buf_xfer(buf, give_begin_line(), give_end_line());
	}
}

command process_previous_cmd() on process_tab[ALT('p')]
{
	process_get_previous_cmd(0);
}

command process_next_cmd() on process_tab[ALT('n')]
{
	process_get_previous_cmd(1);
}

// Like normal kill-word, but don't include prompt.
command process_backward_kill_word() on process_tab[ALT(CTRL('H'))],
										process_tab[NUMALT(GREYBACK)]
{
	int start;

	check_modify(bufnum);
	start = point;
	backward_word();
	if (spot_to_buffer(process_input_starts_at) > 0
		  && *process_input_starts_at < start
		  && point < *process_input_starts_at)
		point = *process_input_starts_at;
	do_save_kill(start, point);
}

command process_yank()
{
	int buf, lines;
	char msg[FNAMELEN];

	get_clipboard();
	buf = name_to_bufnum(_cur_kill_buf);
	lines = buf_exist(buf) ? count_lines_in_buf(buf, 0) : 0;
	sprintf(msg, "Are you sure you want to yank %d lines "
			"for immediate execution? ", lines);
	if (!in_macro() && _len_def_mac <= 0 && point >= type_point && lines > 1)
		if (!ask_yn("Confirm yank", msg, "Yes", "No", 0))
			return;
	delete_if_highlighted();
	retrieve(0);
}

when_loading()
{
	fix_key_table(reg_tab, (short) yank, process_tab, (short) process_yank);
}

// Transfer the list of matches into the process buffer, adding
// formatting.

proc_complete_show_matches()
{
	int buf = name_to_bufnum(_MATCH_BUF), orig = bufnum;

	columnize_buffer_text(buf, text_width(), 3);
	save_spot point;
	if (point >= type_point)
		point = type_point - 1;
	to_begin_line();
	buf_xfer_colors(buf, point, size());
	save_var bufnum = buf;
	insert('\n');
	buf_xfer_colors(orig, 0, size());
}

// Prepare a list of matches of pat in the match buffer.  If initial is
// nonzero, use special rules for getting command name matches from the
// path.

int proc_complete_list_matches(char *pat, int initial)
{
	int flags = 0;
	char *pat2 = 0, file[FNAMELEN], *s;

	if (initial && (s = getenv("PATH")) && !strchr(pat, '/') &&
		  (opsys == OS_UNIX || !strchr(pat, '\\') && !strchr(pat, ':'))) {
		pat2 = malloc(strlen(s) + strlen(pat) + 100);
		sprintf(pat2, (opsys == OS_UNIX) ? "{%s}/%s*" :
				"{%s,.}/%s*.{exe,bat,cmd,com}", s, pat);
		while (s = strchr(pat2, path_list_char))
			*s = ',';
		flags = EXACTONLY;
		pat = pat2;
	}
	zap(_MATCH_BUF);
	if (s = do_file_match(pat, STARTMATCH | flags))
		do {
			if (opsys == OS_UNIX && initial && lowaccess(s, LOWACC_X))
				continue;
			if (flags) {
				strcpy(file, s);
				s = get_tail(file, 0);
				if (opsys != OS_UNIX)
					*get_extension(s) = 0;
			}
			buffer_printf(_MATCH_BUF, "%s\n", s);
		} while (s = do_file_match(pat, 0));
	free(pat2);	// Free if we allocated it.
	save_var bufname = _MATCH_BUF;
	do_sort_region(0, size(), 0, 0);
	do_uniq(1, 1, 0);
	return lines_between(0, size(), 0);
}

// Prepare a list of matches of pat in the match buffer.  If initial is
// nonzero, use special rules for getting command name matches from the
// path.  Also ensure we use process's directory.

int proc_complete_do_list_matches(char *pat, int initial)
{
	char orig_dir[FNAMELEN], dir[FNAMELEN];
	int cnt;

	if (!can_get_process_directory)
		error("Can't determine process's current directory.");
	getcd(orig_dir);
	if (*process_current_directory) {
		strcpy(dir, process_current_directory);
		chdir(dir);
	} else
		getcd(dir);
	cnt = proc_complete_list_matches(pat, initial);
	chdir(orig_dir);
	return cnt;
}

// Is the current file name on this line inside an open "?  If so,
// return nonzero and with matchend set to just before it.

process_line_inside_quoting()
{
	return parse_string(-1, "^([^\"\n]|\"[^\"\n]*\"|)*!\"[^\"\n]*");
}

command process_complete() on process_tab['\t']
{
	char pat[FNAMELEN], pref[FNAMELEN];
	int cnt, start, end;

	start = end = point;
	if (start < type_point)
		error("Can't complete here.");
	*pat = 0;
	if (process_line_inside_quoting() || parse_string(-1, "[^\n\t <>\"]+", pat)) {
		start = point;
		point = end;
		if (process_line_inside_quoting())
			grab(start = matchend + 1, end, pat);
		if (start < type_point && type_point < end) {
			start = type_point;		// exclude prompt
			grab(start, end, pat);
		}
	}
	if (!*pat)
		strcpy(pat, "*");
	cnt = proc_complete_do_list_matches(pat, all_blanks(type_point, start));
	if (!cnt)
		error("No matches for %s.", pat);
	set_buf_point(name_to_bufnum(_MATCH_BUF), 0);
	find_buffer_prefix_folding(name_to_bufnum(_MATCH_BUF), pref, !is_unix);

	if (strlen(pref) > end - start) {
		delete(start, end);
		if (strchr(pref, ' ') && !process_line_inside_quoting())
			stuff("\"");
		stuff(pref);
		if (cnt == 1 && !is_path_separator(character(point - 1))) {
			if (strchr(pref, ' ') && process_line_inside_quoting())
				stuff("\"");
			stuff(" ");
		}
	} else if (prev_cmd == CMD_PROC_COMPL) {
		proc_complete_show_matches();
		this_cmd = CMD_PROC_COMPL;
	} else if (cnt == 1 && !is_path_separator(character(point - 1))) {
		if (strchr(pref, ' ') && process_line_inside_quoting())
			stuff("\"");
		stuff(" ");
	} else if (buffer_size(_MATCH_BUF) < screen_cols - 20 - strlen(pat)) {
		save_var bufname = _MATCH_BUF;
		simple_re_replace(1, "\n", " ");
		grab(0, size(), pref);
		say("%d matches for %s: %s", cnt, pat, pref);
		expire_message = 1;
	} else {
		say("%d matches for %s: press again to see matches.", cnt, pat);
		expire_message = 1;
		this_cmd = CMD_PROC_COMPL;
	}
}

set_error_spot()	/* maybe allocate, then set to point */
{
	if (spot_to_buffer(error_spot) == bufnum)
		*error_spot = point;
	else {
		if (spot_to_buffer(error_spot) > 0)
			free_spot(error_spot);
		error_spot = alloc_spot();
	}
}

// Run a process (cmdline), pass it a buffer of input, retrieve
// its output.  Either the input or output buffer names may be NULL.
// Start the process in curdir (or Epsilon's current directory, if
// curdir == NULL).  Returns 0 and sets errno if the function could
// not be started, returns 1 if the function started successfully.

// The PIPE_SYNCH flag means don't return from the function until the
// process has finished.  The PIPE_CLEAR_BUF flag means empty the
// output buffer before inserting the process's text (but do nothing
// if the process can't be started); it's convenient when the input
// and output buffers are the same, to filter a buffer in place.
// PIPE_NOREFRESH keeps Epsilon from automatically displaying the
// output buffer as it receives text.

// If handler is nonzero, it's the index of a function to call each
// time text is received from the process, and when the process
// terminates.  There must be an output buffer for a handler to be
// called.

pipe_text(char *input, char *output, char *cmdline, char *curdir,
			 int flags, int handler)
{
	int inbuf = 0, outbuf = 0;

	if (input && *input)
		inbuf = create(input);
	if (output && *output) {
		outbuf = create(output);
		save_var bufnum = outbuf;
		if (handler)
			when_activity = handler;
		restore_vars();
	}
	return buf_pipe_text(inbuf, outbuf, cmdline, curdir ? curdir : "",
						 flags);
}

command filter_region() on reg_tab[ALT('|')]
{
	int in_place = has_arg, b, width, orig = bufnum;
	char cmd[FNAMELEN];

	iter = 0;
	get_str_auto_def(cmd, in_place ? "Send region to command" : 
			   "Filter region through command");
	b = zap("filter-output");
	if (region_type() == REGRECT) {
		width = extract_rectangle(b, 0);
	} else {
		save_spot point, mark;
		fix_region();		// handle other types of regions
		buf_xfer(b, point, mark);
	}
	if (!buf_pipe_text(b, b, cmd, "", PIPE_CLEAR_BUF | (in_place ? PIPE_SYNCH : 0))) {
		if (bufnum != b)
			buf_delete(b);
		file_error(errno, "During exec", "Couldn't exec");
		quick_abort();
	}
	if (in_place) {
		if (region_type() == REGRECT) {
			save_var bufnum = b;
			xfer_rectangle(orig, width, 1);
		} else {
			delete(point, mark);
			restore_vars();
			grab_buffer(b);
		}
	} else
		to_buffer_num(b);
	highlight_off();
}

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

// This file interprets Epsilon's command line switches.

#include "eel.h"
#include "menu.h"

early_restoring()
{
	char fname[FNAMELEN];
	int i;

	after_loading(); /* call early, so we can display errors, etc. */
	putenv("EPSRUNS=Y");	/* for catching nested Epsilons */
	if (opsys == OS_DOS)
		putenv("PKNOFASTCHAR=Y"); //make PKZIP, UNZIP output capturable
	root_keys = reg_tab;
		/* now set buffer-specific variables */
	if (has_feature & FEAT_ANSI_CHARS) {
		word_pattern.default = default_word;
		_char_class.default = _def_ansi_char_class;
		_case_map.default = _def_ansi_case_map;
		_srch_case_map.default = _def_ansi_srch_case_map;
	} else {
		word_pattern.default = default_oem_word;
		_char_class.default = _def_char_class;
		_case_map.default = _def_case_map;
		_srch_case_map.default = _def_srch_case_map;
	}
	_display_class.default = _std_disp_class;
	_echo_display_class = _echo_disp_class;
	i = *get_color_scheme_variable();
	if (name_type(i) == NT_COLSCHEME)
		selected_color_scheme = i;
	else
		get_standard_color_scheme();
	use_default = 1;		/* default is fundamental mode */
	mode_default_settings();
	use_default = 0;
	apply_defaults();	/* apply defaults to init buffer & window */

	force_save_as = FSA_NEWFILE;	// make startup buffer prompt
	strcpy(fname, "startup.txt");	// for filename
	absolute(fname);
	filename = fname;
	strcpy(_docname, "edoc");
}

restore_check_version()
{
	if (load_from_state && (strcmp(eel_version, versioned_file_string) < 0
							|| (strchr(eel_version, 'b')
								&& !strchr(versioned_file_string, 'b')))
		  && !strchr(versioned_file_string, 'a')) {
		// Each user has a private state file, so we can't update them
		// all automatically.
		save_var bufnum = zap(HELPBUF);
		bprintf("Your version %s state file requires updating.\n"
				"You need to start Epsilon with its -quickup flag.\n", 
				eel_version);
		bprintf("Until you do this, Epsilon will not work correctly.\n");
		view_help(" Update Needed! ", 0);
	}
}

when_restoring()
{
	int tflag = 0, i, j, splitmode = HORIZONTAL;
	char *s, *flag, *arg;

	early_restoring();
	early_init();

	for (i = 1; i < argc && argv[i][0] == '-'; i++) {
		flag = argv[i];
		switch (flag[1]) {
		case 'f':
			arg = (flag[2] && flag[3] || i + 1 >= argc) ? (flag + 3) : argv[++i];
			switch (flag[2]) {
			case 's':
				set_swapname(arg);
				break;
			case 'h':
				set_shrinkname(arg);
				break;
			case 'd':
				strcpy(_docname, arg);
				break;
			default:
				bad_flag(flag);
			}
			break;
		case 't':
			tflag = 1;
			break;
		case 'r':
		case 'l': if (!flag[2] && i + 1 < argc)
					  i++;
				  break;
		case 'h': case '?': usage();
		case 'p':
			if (!flag[2])
				preserve_session_once = preserve_session ? 1 : 2;
			else if (isdigit(flag[2]))
				preserve_session_once = numtoi(flag + 2) + 1;
			else
				cmd_line_session_file = flag + 2;
			break;
		case 'v':
			switch (flag[2]) {
				case 'v':
					splitmode = VERTICAL;
					break;
				default:
					bad_flag(flag);
			}
			break;
		case 'd':
			arg = (flag[2] || i + 1 >= argc) ? (flag + 2) : argv[++i];
			s = index(arg, '=');
			if (!s)		// accept either VAR=VAL or VAR!VAL
				s = index(arg, '!');
			if (!s)
				bad_flag(flag);
			*s = 0;
			if (j = find_index(arg)) {
				safe_set_var_val(j, s + 1, 1);
				break;
			}
			bprintf("No such variable %s.\n", arg);
			init_help_abort();
			break;
		default:
			bad_flag(flag);
		}			/* i is 1st file argument */
	}
	term_init();
#include "keyext.h"
	try_calling("key-setup");
	middle_init();
	init_menu();
	term_cmd_line();
	if (tflag) {
		preserve_session_once = 1;
		tutorial();
	} else {
		if (load_from_state && (i >= argc || session_always_restore)) {
			if (session_restore_files == 2 && i < argc)	// Have cmdline files,
				save_var session_restore_files = 0;	// skip session files.
			load_session();
		}
		if (i < argc)
			load_cmd_line_files(i, splitmode);
		delete_dull_buffer("startup");
	}
	switching_to_buffer();
	set_toolbar();
	restore_check_version();
	show_text(0, 1, "Epsilon Programmer's Editor %s, EEL version %s",
			  version, eel_version);
	try_calling("start-up");
	for (i = 1; i < argc && argv[i][0] == '-'; i++) {
		flag = argv[i];
		arg = (flag[1] && flag[2] || i + 1 >= argc) ? (flag + 2) : argv[i + 1];
		switch (flag[1]) {
			case 'l': load_commands(arg); break;
			case 'r': if (!try_calling(arg))
						  say("No command %s, %s ignored.", arg, flag);
					  break;
		}
	}
}

load_cmd_line_files(i, splitmode)	/* start at argv[i] */
{
	int wins = 0, tot_size = window_height, line, column, j;
	char fname[FNAMELEN], fixed[FNAMELEN], *s, first = 1;

	one_window();			// Don't use windows specified by session
	if (is_gui && i + 1 < argc && argv[i][0] != '+') {	// multiple args
		for (j = i, *fixed = 0; j < argc; j++) {
			if (strlen(fixed) + strlen(argv[j]) >= FNAMELEN - 1) {
				*fixed = 0;
				break;		// See if perhaps a stray association is
			}				// passing us a file name w/o the quotes.
			if (*fixed)
				strcat(fixed, " ");
			strcat(fixed, argv[j]);
		}
		if (check_file(fixed) == 1 && !check_file(argv[i])) {
			argv[i] = strsave(fixed);
			argc = i + 1;
		}
	}
	line = column = -1;
	for (; i < argc; i++) {
		if (argv[i][0] == '+') {
			line = strtoi(argv[i] + 1, 10);
			s = strchr(argv[i], ':');
			if (s)
				column = strtoi(s + 1, 10);
		} else {
			strcpy(fname, argv[i]);
			absolute(fname);
			if ((directory_flags & DIR_CWD_FROM_FILE) && first) {
				char dir[FNAMELEN];
				strcpy(dir, fname);
				*get_tail(dir, 1) = 0;
				chdir(dir);
				first = 0;
			}
			s = expand_wildcards ? do_file_match(fname, STARTMATCH | EXACTONLY)
				: fname;
			if (!s)		/* new file */
				s = fname;
			do {
				if (wins < max_initial_windows && wins++ > 0) {
					window_split(splitmode);
					window_height = 1000;
				}
				if (!(is_pattern(s) & 2) && !is_directory(s)
					&& !is_remote_file(s))	// Has quotable wildcards.
					find_it(s, default_translation_type);
				else
					do_find(s, default_translation_type);
				if (line > 0)
					go_line(line);
				if (column >= 0)
					move_to_column(column);
			} while (expand_wildcards
				&& (s = do_file_match(fname, EXACTONLY)));
			line = column = -1;
		}
	}
	for (; window_number > 0; window_number--)
		window_height = tot_size / number_of_user_windows();
}

delete_dull_buffer(buf)		/* delete if no file & not in window */
char *buf;
{
	int orig, keep;

	orig = bufnum;
	bufname = buf;
	keep = (*filename && force_save_as != FSA_NEWFILE)
		   || buf_in_window(bufnum) > 0;
	bufnum = orig;
	if (!keep)
		delete_buffer(buf);
}

usage_new_page()
{
	if (!is_gui) {
		if (is_unix != IS_UNIX_XWIN)
			bprintf("\nPress any key for more flags.");
		file_write(TERMINAL, 1);
		leave_blank = 1;
		if (is_unix == IS_UNIX_TERM)
			term_position(0, screen_lines - 1);
		if (is_unix != IS_UNIX_XWIN)
			getkey();

		buf_zap(bufnum);
	}
}

usage()
{
	char name[FNAMELEN], *p;

	bufnum = zap("usage");
	bprintf("\n");
	strcpy(name, get_tail(argv[0], 0));
	*get_extension(name) = 0;
	if (opsys != OS_UNIX)
		for (p = name; *p; p++)
			*p = tolower(*p);
	bprintf("Usage: %s [flags...] [files...]\n", name);
	bprintf("A file name may have +linenum before it.\n\n");

	bprintf("Flags:\n");
	bprintf("-sFILE   Load state from FILE.sta (default: epsilon.sta).\n");
	bprintf("-bFILE   Build new system from FILE.b, not .sta file "
			"(default: epsilon.b).\n");
	bprintf("-quickup Load quickup.b after loading state."
			"    -nologo Skip initial msg.\n");

	bprintf("-lFILE   Load FILE.b after loading files. ");
	bprintf("-rCMD    Run command or macro CMD.\n");
	bprintf("-teach   Run the tutorial.                ");
	bprintf("-dVAR!VAL Set variable to value.\n");
	bprintf("-add     Send files to prior instance.    ");
	bprintf("-noserver Don't accept sent files.\n");
	bprintf("-p[VAL]  Set/toggle session-preserving.   ");
	bprintf("-pFILE    Load session from FILE.\n");

	usage_new_page();
	bprintf("\n");
	bprintf("-fsDIRS  Swap/shrink to directories DIRS. ");
	if (!(has_feature & FEAT_WINHELP))
		bprintf("-fdFILE  Documentation in file FILE.");
	bprintf("\n");
	bprintf("-fhDIRS  Shrink to directories in DIRS.\n\n");

	bprintf("-vmono   Use monochrome color scheme.     ");
	bprintf("-vlNUM   Screen has NUM lines.\n");
	bprintf("-vcolor  Use colors.                      ");
	bprintf("-vcNUM   Screen has NUM columns.\n");
	if (opsys == OS_DOS && !is_gui) {
		bprintf("-vclean  Fast video mode.                 ");
		bprintf("-vsnow   Slow video mode.\n");
		bprintf("-vmNUM   Screen memory is at NUM (hex).\n");
	}
	bprintf("-vv      Put cmd line files side by side.\n\n");
	if (opsys == OS_DOS) {
		if (!is_gui && is_win32 != IS_WIN32_CONSOLE)
			bprintf("-kw      Run inside GUI window.           ");
		bprintf("-kaNUM   Kbd compatibility flags.\n");
	}
	if (opsys == OS_DOS && !is_gui || opsys == OS_OS2) {
		bprintf("-kcNUM   Mouse graphic cursor/block/off.  ");
		bprintf("-kmNUM   Mouse relative/absolute/off.\n");
	}
	if (opsys == OS_DOS && !is_gui && is_win32 != IS_WIN32_CONSOLE)
		bprintf("-kt      Don't take over system timer.    ");
	else if (opsys == OS_OS2)
		bprintf("-kpNUM   Wait NUM secs starting process.  ");
	bprintf("-ke      Extended key support.\n");
	if (opsys == OS_OS2) {
		bprintf("-ksNUM   Speed (>100) vs. abort response. ");
		bprintf("-ka      Kbd alternate mode.\n");
		bprintf("-kdNUM   Mouse delay in .001 secs [50].\n");
	}
	if (opsys == OS_DOS && !is_gui || opsys == OS_OS2)
		usage_new_page();

	bprintf("\n");
	bprintf("-mNUM    Use NUM bytes of main memory.    ");
	bprintf("-m0      Use minimum memory.\n");
	bprintf("-mNUM    Use NUM kbytes (if NUM < 1000)   ");
	bprintf("-m       Use as needed.\n\n");
	if (opsys == OS_DOS && !is_gui && is_win32 != IS_WIN32_CONSOLE) {
		bprintf("-xNUM    Like -m; sets max XMS (extended) ");
		bprintf("-eNUM    Sets maximum EMS (expanded).\n");
		bprintf("-xiNUM   Initial allocation of XMS.       ");
		bprintf("-eiNUM   Initial allocation of EMS.\n");
		bprintf("-xfNUM   Allocation for EEL funcs in XMS. ");
		bprintf("-efNUM   Alloc. for EEL funcs in EMS.\n");
		bprintf("-xuNUM   Maximum use of upper memory blocks.\n\n");
	}
	bprintf("  NUMk means kilobytes, NUMm means megabytes.\n");
	bprintf("  Without suffix, NUM is in kilobytes if < 1000, "
			"otherwise bytes.\n");
	restore_vars();
	init_abort();
}

bad_flag(s)
char *s;
{
	bprintf("\n");
	bprintf("Unrecognized flag %s on command line.\n", s);
	init_help_abort();
}

init_help_abort()
{
	bprintf("For help, type \"epsilon -help\".\n\n");
	init_abort();
}

init_abort()	/* show current buffer, then abort */
{
	if (has_feature & FEAT_GUI_DIALOGS) {
		int buf = bufnum, win;
		window_bufnum = zap("Error");
		save_var _doing_input = DI_VIEW, paging_retains_view = 1;
		win = add_popup(0, 0, screen_cols, screen_lines, 0, buf);
		point = 0;
		go_to_link = 0;
		display_dialog_box("UsageBox", "Usage", win, 0, 0, "OK", "", "");
		view_loop(win);
		leave();
	} else {
		if (is_unix == IS_UNIX_TERM)
			bprintf("\nPress any key to continue.\n");
		file_write(TERMINAL, 1);
		leave_blank = 1;
		if (is_unix == IS_UNIX_TERM) {
			term_position(0, screen_lines - 1);
			getkey();
		}
		leave();
	}
}

early_init()
{
}

middle_init()
{
}

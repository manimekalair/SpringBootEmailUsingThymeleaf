/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1984, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

#include "eel.h"
#include "proc.h"
#include "epsnet.h"
#include "grep.h"
#include "html.h"
#include "tags.h"
#include "c.h"
#include "dired.h"
#include "colcode.h"
#include "vbasic.h"
#include "bufed.h"

// For updating from 11 Beta 2 or later.

when_loading()
{
	if (!strcmp(eel_version, "11.00b1")) {
		save_var bufnum = zap(HELPBUF);
		bprintf("%s is too old to be updated.\n"
				"The above state file is for Epsilon version %s.\n"
				"This Epsilon executable is from Epsilon version %s.\n",
				state_file, eel_version, EEL_MINOR_VERSION);
		view_help(" Update Not Performed ", 0);
		quick_abort();
	}
}

int get_key_response(char *valid, int def)
{
	do {
		getkey();
		check_abort();
		if (IS_ENTER_KEY(key) && def > 0)
			key = def;
	} while (!IS_ASCII_KEY(key) || !strchr(valid, toupper(key)));
	return toupper(key);
}

ask_yn(char *title, char *question, char *yes_button,
	   char *no_button, int def_button)
{
	if (is_gui && want_gui_prompts) {
		show_text(-2, 1, "%s", question);
		return button_dialog(title, question, yes_button, no_button, "",
							 def_button) == 1;
	} else {
		sayput("%s%s", question, 
			   def_button == 1 ? "[Y] " : def_button == 2 ? "[N] " : "");
		for (;;) {
			getkey(); 
			if (user_abort)
				return 0;
			switch (toupper(key)) {
				case 'Y': say(""); return 1;
				case 'N': say(""); return 0;
			}
			if (IS_ENTER_KEY(key) && def_button) {
				say("");
				return def_button == 1;
			}
		}
	}
}

look_file(fname)	/* is there a buffer with this file? */
char *fname;		/* if so, switch to it */
{
	int i, orig = bufnum;
	int new_file_id[3];

	unique_filename_identifier(fname, new_file_id);
	if (!fnamecmp(filename, fname) && force_save_as != FSA_NEWFILE)
		return 1;	/* already in it */
	if (unique_file_ids_match(new_file_id, unique_file_identifier))
		return 1;
	i = buf_list(0, 2);	/* start with most recently created buf */
	do {
		bufnum = i;
		if (!fnamecmp(filename, fname) && force_save_as != FSA_NEWFILE)
			return 1;
		if (unique_file_ids_match(new_file_id, unique_file_identifier))
			return 1;
	} while (i = buf_list(-1, 1));
	bufnum = orig;
	return 0;
}

command count_lines()
{
	int count, here, disksize, reg_lines;

	noteput("Counting...");
	here = lines_between(0, point, 1);
	check_abort();
	noteput("Counting... point on line %d...", here + 1);
	count = here + lines_between(point, size(), 1);
	check_abort();
	disksize = size();
	if (translation_type == FILETYPE_MSDOS)
		disksize += count;
	if (file_io_converter == unicode_file_converter)
		disksize *= 2;
	if (size() && character(size() - 1) != '\n')
		count++;
	save_var point, mark;
	fix_region();
	if (is_highlight_on()) {
		reg_lines = lines_between(point, mark, 1);
		if (mark > point && character(mark - 1) != '\n')
			reg_lines++;
		say("%d line%s, %d in region, point on line %d.  %d bytes on disk.",
			  count, count == 1 ? "" : "s", reg_lines, here + 1, disksize);
	} else
		say("%d line%s, point on line %d.  %d bytes on disk.",
			  count, count == 1 ? "" : "s", here + 1, disksize);
	expire_message = 1;
	iter = 0;
}

#define UTF8_CONTIN(b)	(((b) & 0xc0) == 0x80)	/* additional UTF-8 byte? */

add_utf8_char_info(char *msg)
{
	int from, to, val, tmp, ok;

	if (!matches_at(0, 1, "\xef\xbb\xbf")
		  && (file_io_converter != unicode_file_converter
			  || (unicode_format & CONV_LATIN1)))
		return;
	from = point;
	to = point + 1;
	while (UTF8_CONTIN(character(from)) && from > narrow_start)
		from--;
	while (UTF8_CONTIN(character(to)) && to < size() - narrow_end)
		to++;
	tmp = tmp_buf();
	buf_printf(tmp, "\xef\xbb\xbf");
	buf_xfer(tmp, from, to);
	ok = perform_conversion(tmp, CONV_TO_16 | CONV_OMIT_BOM) == -1;
	if (buf_size(tmp) != 2)
		ok = 0;
	buf_grab_bytes(tmp, 0, 2, &val);
	buf_delete(tmp);
	if (ok) {
		sprintf(msg, ", U+%04x", val);
		if (point != from)
			sprintf(msg + strlen(msg), " at %d", from);
	}
}

command show_point()
{
	char msg[130], c;

	if (point < size()) {
		sprintf(msg, "Column %d, char %d of %d is ", virtual_column(),
				point, size());
		if (c = curchar())
			sprintf(msg + strlen(msg),
					"'%c'=%d decimal=%02x hex", c, c, c);
		else
			sprintf(msg + strlen(msg), "'\\0'");
		add_utf8_char_info(msg + strlen(msg));
	} else
		sprintf(msg, "Column %d, at end of %d chars",
				virtual_column(), size());
	say("%s", msg);
	expire_message = 1;
	iter = 0;
}

find_buffer_prefix_folding(int buf, char *prefix, int fold)
{
	char next[FNAMELEN];
	int i;

	save_var bufnum = buf;
	grab_line(buf, prefix);
	while (grab_line(buf, next)) {
		for (i = 0; prefix[i]; i++)
			if (fold ? charfcmp(prefix[i], next[i]) : (prefix[i] != next[i]))
				break;
		prefix[i] = 0;
	}
}

command rename_buffer()
{
	char bfname[FNAMELEN];

	get_buf(bfname, "Rename buffer to", "");
	if (*bfname)
		change_buffer_name(bfname);
	make_mode();
}

check_drop_buffer(bname) /* check if buffer can be deleted safely */
char *bname;		/* ask user if questionable */
{			/* return 1 if done, 0 if user said don't */
	char msg[80], *origbuf = bufname;
	int mod;

	if (!exist(bname))
		error("No buffer %s.", bname);
	if (another_process() && is_process_buffer(name_to_bufnum(bname))) {
		exit_this_process(bname);
		if (is_process_buffer(name_to_bufnum(bname)))
			error("A process is running in buffer %s.", bname);
	}
	bufname = bname;
	mod = modified && size() > 0 && !discardable_buffer;
	if (ftp_job && ftp_job->buf == bufnum
		&& ftp_job->operation == FTP_SEND)
		mod = 1;
	if (!strcmp(bname, MSG_BUFFER))
		mod = 0;
	bufname = origbuf;
	if (!another_process() && !strcmp(bname, PROCBUF))
		mod = 0;
	if (mod) {
		sprintf(msg, "Buffer %.40s not saved.  Delete it? ", bname);
 		if (!ask_yn("Delete buffer", msg, "&Delete", "&Cancel", 2))
			return 0;
	}
	to_another_buffer(bname);
	return 1;
}

char *get_int_buf(start)	/* return name of "interesting" buffer */
{
	char *p;

	do {
		p = buffer_list(start);
		start = 0;
	} while (p && (*p == '-' || *p == '#'));
	return p;
}

int find_c_func_info(char *type, char *class, char *func, int stop_on_key)
{
	char funcname[FNAMELEN], classname[FNAMELEN];
	int start, funcstart, i, j;

	*classname = *funcname = 0;
	if (func)
		*func = 0;
	if (class)
		*class = 0;
	if (type)
		*type = 0;
	save_var point, matchstart, matchend, narrow_start = 0, narrow_end = 0;
	save_var tag_declarations = 0;	// We use tagging sometimes.
	to_begin_line();
	start = point;
	point--;		// Begin searching at the last } char on the left margin...
	while (search(-1, "\n}")) {
		point++;		// ...that's not in a comment.
		if (!in_c_comment(c_look_back))
			break;
		point--;
	}

	while (re_search(1, "{|/<*|/>|(~?[a-zA-Z0-9_]+|" CPP_OPSPEC ")[ \t\n]*%(")) {
		point = matchstart;
		if (stop_on_key && (char_avail() || is_key_repeating()))
			return -1;		// Give up search now?
		if (parse_string(-1, "^[ \t]*#[ \t]*(define|if).*(\\\n.*)*")) {
			nl_forward();	// Ignore everything in a macro definition.
			continue;
		}
		switch (curchar()) {
			case '{':		// Could be start of class def.
				j = point;
				i = find_c_class_info(start, type, class, func);
				if (i)
					return i;
				point = j;
				c_skip_level('{', '}');
				break;
			case '/':
				if (character(point + 1) == '*') {		// Skip over comment.
					point += 2;
					search(1, "*/");
				} else
					nl_forward();	/* c++ comment */
				break;
			default:		// Found an identifier; is it a function def?
				if (give_begin_line() > start)
					return 0;		// Gone too far, so give up.
				funcstart = point;
				if (!parse_string(1, "~?[a-zA-Z0-9_]+|" CPP_OPSPEC, funcname))
					return 0;
				if (parse_string(1, "[ \t\n]*%("))
					narrow_end = size() - (point + 1000);
				if (tag_c_func(0) == 2 && !find_c_func_oneliner(start)) {
					point = funcstart;	// Checks out as a function def.
					*classname = 0;
					if (parse_string(-1, "[ \t\n]*::[ \t\n]*")) {
						point = matchend;
						parse_string(-1, "[a-zA-Z0-9_]+", classname);
					}
					if (func)
						strcpy(func, funcname);
					if (class)
						strcpy(class, classname);
					return CF_INFO_FUNC | (*classname ? CF_INFO_CLASS : 0);
				}
				*funcname = 0;
				narrow_end = 0;
				break;
		}
	}
	return 0;
}

suffix_cs()
{
	c_mode();
	compile_buffer_cmd = compile_csharp_cmd;	// can compile this
	c_extra_keywords = CSHARP_KEYWORDS;
}

// Is orig inside an initializer?  It is if we're inside {}'s and just
// before is a comma or equal sign.
int in_c_initializer(int orig)
{
	save_var point = orig;
	c_rev_skip_level('{', '}');
	if (curchar() != '{')
		return 0;
	cind_try_space();
	if (!strchr("=,", character(point - 1)))
		return 0;
	return !c_skip_level('{', '}') || point >= orig;
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

is_c_keyword(p)		// is text in p (must be surrounded by |'s) a keyword?
char *p;
{
	if (strstr("|if|else|for|do|while|return|break|continue|switch|"
			   "case|default|goto|char|short|int|static|volatile|const|"
			   "float|double|long|void|", p))
		return 1;
	if (p[1] == '_' &&
		  strstr("|_asm|_based|_cdecl|_emit|_except|_export|_far|_fastcall|"
				 "_fortran|_huge|_interrupt|_loadds|_near|_pascal|_saveregs|"
				 "_segment|_segname|_stdcall|_syscall|_try|__int64|", p))
		return 1;
	if ((c_extra_keywords & EEL_KEYWORDS) &&
		  strstr("|keytable|buffer|window|command|on|color_class|"
				 "spot|save_spot|save_var|on_exit|user|zeroed|", p))
		return 1;
	if ((c_extra_keywords & CPP_KEYWORDS) &&
		  strstr("|asm|catch|class|delete|friend|inline|new|operator|"
				 "private|protected|public|template|try|this|virtual|"
				 "throw|_self|and|and_eq|bitand|bitor|bool|compl|const_cast|"
				 "dynamic_cast|explicit|false|mutable|namespace|not|not_eq|"
				 "or|or_eq|reinterpret_cast|static_cast|true|typeid|typename|"
				 "using|wchar_t|xor|xor_eq|", p))
		return 1;
	if ((c_extra_keywords & JAVA_KEYWORDS) &&
		  strstr("|abstract|boolean|byte|catch|class|extends|false|final|"
				 "finally|function|implements|import|in|instanceof|"
				 "interface|native|new|null|package|private|protected|"
				 "public|super|synchronized|this|throw|throws|transient|"
				 "true|try|var|with|", p))
		return 1;
	if (!(c_extra_keywords & JAVA_KEYWORDS) &&
		  strstr("|auto|enum|extern|register|unsigned|signed|sizeof|"
				 "struct|union|typedef|", p))
		return 1;		// C keywords not in Java.
	if ((c_extra_keywords & IDL_KEYWORDS) &&
		  strstr("|appobject|auto_handle|bindable|boolean|broadcast|byte|"
				 "callback|coclass|code|comm_status|context_handle|"
				 "control|decode|defaultbind|dispinterface|displaybind|"
				 "dual|enable_allocate|encode|error_status_t|"
				 "explicit_handle|fault_status|handle|handle_t|hidden|"
				 "hyper|idempotent|ignore|immediatebind|import|in|"
				 "include|interface|library|licensed|local|maybe|module|", p))
		return 1;
	if ((c_extra_keywords & IDL_KEYWORDS) &&
		  strstr("|ms_union|nocode|nonextensible|notify|object|odl|"
				 "oleautomation|optional|out|pipe|propget|propput|"
				 "propputref|public|ptr|readonly|ref|requestedit|"
				 "restricted|retval|small|source|string|unique|"
				 "usesgetlasterror|v1_enum|vararg|", p))
		return 1;
	if ((c_extra_keywords & CSHARP_KEYWORDS) &&
		  strstr("|abstract|as|base|bool|break|byte|case|catch|char|"
				 "checked|class|const|continue|decimal|default|delegate|"
				 "do|double|else|enum|event|explicit|extern|false|finally|"
				 "fixed|float|for|foreach|goto|if|implicit|in|int|"
				 "interface|internal|is|lock|long|namespace|new|null|"
				 "object|operator|out|override|params|private|protected|"
				 "public|readonly|ref|return|sbyte|sealed|short|sizeof|"
				 "stackalloc|static|string|struct|switch|this|throw|true|"
				 "try|typeof|uint|ulong|unchecked|unsafe|ushort|using|"
				 "virtual|void|volatile|while|", p))
			return 1;
	return 0;
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

check_running_processes()
{
	char *buf, *open = 0;

	if (!process_warn_on_exit)
		return;
	buf = buffer_list(1);
	save_var bufnum;
	do {
		if (is_process_buffer(name_to_bufnum(buf))
			  && !exit_this_process(buf)) {
			open = buf;
			break;
		}
	} while (buf = buffer_list(0));
	restore_vars();
	if (open) {
		locate_window(open, "");
		error("Couldn't exit from concurrent process.");
	}
}

command exit()
{
	iter = 0;
	if (!has_arg) {
		error_if_input(0);
		check_running_processes();
	}
	if (opsys == OS_DOS && !is_gui && is_win32 != IS_WIN32_CONSOLE
		  && another_process()) {
		if (!ask_yn("Kill process", "A subprocess is running.  Kill it? ",
					"Yes", "No", 1)) {
			check_abort();
			tiled_only();
			locate_window(PROCBUF, "");
			point = size();
			say("You must kill this subprocess before exiting.");
			return;
		}
		exit_process();
	}
	if (!has_arg) {
		if (unsaved_buffers() && !bufed_ask_exit())
			return;
		if (load_from_state)
			save_session();
	}
	sayput("");
	while (!in_macro() && unseen_msgs())
		check_abort();
	finish_up();
	if (!is_gui) {
		term_position(0, screen_lines - 1);
		term_mode(0);
		if (restore_blinking_on_exit)
			vid_bright_back(0);
	}
	when_exiting();
	leave();
}

#define MAX_BUFFER_WHEN_IDLE	5
buffer int (*buffer_when_idle[MAX_BUFFER_WHEN_IDLE])();
zeroed TIMER idle_display_time;
int auto_show_delimiter_delay;	// time before next check (.01 sec units)

when_idle(cnt)
{
	int delay, disp, i, j;

	if (leave_blank)		// Exiting or similar--don't touch screen.
		return -1;
	if (!cnt || time_done(&idle_display_time)) {
		show_idle_text();
		time_begin(&idle_display_time, 10);	// wait .1 seconds next time
	}
	if ((auto_show_matching_characters && *auto_show_matching_characters
		 || mode_auto_show_delimiter) && cnt == 1) {
		auto_show_delimiter_delay = 5;
		if (maybe_auto_show_delimiter() == 2)	// No match, wait .5 sec
			auto_show_delimiter_delay = 50;	 // before looking on next key.
		refresh();
	}
	if (is_unix == IS_UNIX_XWIN && is_key_repeating())
		return -1;
	if (cnt == 2 && set_display_func_name())
		maybe_refresh();
	delay = when_idle_coloring(cnt);
	if (*show_when_idle) {		// Wait for .1 seconds.
		disp = time_remaining(&idle_display_time);
		if (delay < 0 || disp < delay)
			delay = disp;
	}
	if (cnt < 2 && (delay < 0 || auto_show_delimiter_delay < delay))
		delay = auto_show_delimiter_delay;
	for (i = 0; i < MAX_BUFFER_WHEN_IDLE; i++)
		if (buffer_when_idle[i]) {
			j = (*buffer_when_idle[i])(cnt);
			if (delay < 0 || j >= 0 && j < delay)
				delay = j;
		}
	if (!_doing_input
		  && (text_color == color_class echo_area || system_window)) {
		// Perhaps this should be in when_ function called after eel error.
		say("Recovering from previous error...");
		for (i = 0; i < 5; i++) {
			window_number = 0;
			window_number--;		// to topmost popup
			if (text_color == color_class echo_area || system_window)
				window_kill();
		}
		in_echo_area = 0;
	}
	return (cnt < 2) ? 0 : delay;
}

dired_live_link()
{
	iter = 0;
	if (is_buffer_in_window(LIVE_LINK_BUF) == -1) {
		save_var window_handle;
		if (number_of_user_windows() == 1)
			window_split(has_arg ? VERTICAL : HORIZONTAL);
		else
			to_next_user_window(1);
		to_buffer(LIVE_LINK_BUF);
	}
}

dired_show_live_link(char *file, char *msg)
{
	struct file_info fi;

	save_var readonly_warning |= ROWARN_GREP, no_popup_errors = 1;
	readonly_warning &= ~(ROWARN_MSG | ROWARN_BELL);
	save_var bell_on_read_error = 0;
	if (!*msg)
		if (check_file(file, &fi) != CHECK_FILE)
			sprintf(msg, "Can't read %s: ", get_tail(file, 1));
		else if (fi.fsize > dired_live_link_limit)
			sprintf(msg, "%s too big: ", get_tail(file, 1));
	set_read_only(0);
	filename = "";
	zap(bufname);
	fundamental_mode();
	if (!*msg) {
		if (do_file_read(file, FILETYPE_AUTO))
			sprintf(msg, "Can't read %s: ", get_tail(file, 1));
		else {
			unique_filename_identifier(file, unique_file_identifier);
			file_io_converter = 0;
			unicode_on_read(FILETYPE_AUTO);
			file_convert_read(FILE_CONVERT_QUIET);
			call_mode(filename);
			check_filevars();
		}
	}
	modified = 0;
	display_column = -1; // Binary files can be slow to display when wrapped.
	make_mode();
	set_read_only(1);
	buffer_not_saveable = 1;
	force_save_as = FSA_NEWFILE;
	if (!*msg)
		sprintf(msg, "%s: ", get_tail(file, 1));
	set_mode_message(msg);
}

dired_when_idle(int cnt)
{
	char file[FNAMELEN], msg[FNAMELEN];
	int win;
	jmp_buf this_level;

	if (!cnt)			// On our first call when idle, do nothing,
		return 0;		// but ask to be called again.
	if (cnt > 1)		// On our third or later call, do nothing and
		return -1;		// say we don't need to be called again.
	if (!exist(LIVE_LINK_BUF))
		return -1;
	win = is_buffer_in_window(LIVE_LINK_BUF);
	if (win == -1)
		return -1;
	*file = *msg = 0;
	save_var point;
	if (!dired_getname(file, 0) || is_remote_file(file))
		strcpy(msg, "none: ");	// Say why we're not displaying a file.
	else if (is_directory(file))
		strcpy(msg, "dir: ");
	save_var window_handle = win;
	if (!strcmp(filename, file) || modified)
		return -1;	// If file name's unchanged, or user modified buf, stop.
	save_var top_level = &this_level;
	if (!setjmp(top_level))
		dired_show_live_link(file, msg);
	restore_vars();
	refresh();
	return -1;
}

char *oem_file_converter(int func)
{
	int write = (func & FILE_CONVERT_WRITE) != 0;

	if (!is_win32 && is_gui != IS_WIN31)
		return NULL;		// Not supported.
	if (func & FILE_CONVERT_ASK) {
		if (!(func & FILE_CONVERT_QUIET))
			return ask_oem_ansi_translate(write) ? "OK" : NULL;
		if (test_oem_ansi_translate(write))
			return "OK";
		save_var see_delay = 400;
		say("%s not converted from OEM: not reversible.", filename);
		return NULL;
	}
	if (func & (FILE_CONVERT_READ | FILE_CONVERT_WRITE))
		oem_ansi_translate(write);
	return " OEM";
}

file_convert_write(char *fname, int trans, struct file_info *finfo)
{
	int tmp, err, mod;
	char *(*func)();

	if (is_remote_file(fname))
		return save_remote_file(fname, trans, finfo);
	if (!file_io_converter)
		return new_file_write(fname, trans, finfo, -1, -1);
	if (!file_io_converter(FILE_CONVERT_WRITE | FILE_CONVERT_ASK))
		error("Canceled.");
	func = file_io_converter;
	tmp = tmp_buf();
	buf_xfer(tmp, 0, size());
	copy_buffer_variables(tmp, bufnum);
	save_var bufnum = tmp;
	translation_type = trans;	// func might modify this
	func(FILE_CONVERT_WRITE);
	err = new_file_write(fname, translation_type, finfo, -1, -1);
	mod = modified;
	restore_vars();
	modified = mod;
	return err;
}

file_convert_read(int flags)
{
	save_var _buf_readonly = 0;
	if (file_io_converter)
		if (file_io_converter(FILE_CONVERT_READ | FILE_CONVERT_ASK | flags)) {
			save_var modified;
			file_io_converter(FILE_CONVERT_READ | flags);
		} else
			file_io_converter = 0;	// Don't convert on write either.
}

char *name_of_filetype(t)
int t;
{
	int usual = (opsys == OS_UNIX) ? FILETYPE_UNIX : FILETYPE_MSDOS;

	if (default_translation_type == FILETYPE_AUTO)
		if (t == usual || t == FILETYPE_AUTO)
			return "";		// If this file uses the usual settings, say nothing.
	if (t == FILETYPE_AUTO)
		t = usual;
	switch(t){
		case FILETYPE_MSDOS:   return " DOS";
		case FILETYPE_BINARY:  return " Binary";
		case FILETYPE_UNIX:    return " Unix";
		case FILETYPE_MAC:     return " Mac";
		default: return " Unknown translation type";
	}
}

ftp_activity(int activity, int buf, int from, int to)
{
	char msg[FNAMELEN];
	int show_log = 0, orig_buf = bufnum;

	if (!buf_exist(buf))
		return;
	save_var iter, has_arg;
	save_var bufnum = buf;
	switch (activity) {
		case NET_DONE:
			if (ftp_job->operation == FTP_SEND)
				show_text(0, 1, "%s written.", filename);
			if (translation_type == FILETYPE_AUTO
				  && ftp_job->operation == FTP_RECV)
				translation_type = new_buffer_translation_type;
			if (!modified && !point) {
				save_var undo_size = 0;
				undo_mainloop();
			}
			free(ftp_job);		// Fall through.
		case NET_LOG_DONE:
			ftp_job = 0;
			set_mode_message(NULL);
			break;
		case NET_RECV:
			if (!from) {		// First block.
				position_in_all_windows(buf, 0);
				if (mode_keys == buf_tab && !*get_extension(filename))
					suffix_none();		// Switch out of Fundamental mode.
			}
			show_ftp_percent("got", from);
			break;
		case NET_SEND:
//			ftp_job->so_far = from;
			ftp_job->file_size = to;
			show_ftp_percent("sent", from);
			break;
		case NET_LOG_WRITE:
			save_var point = from;	// Get file size from msg.
			if (re_search(1, "^150 ") && re_search(1, "[0-9]+ bytes")) {
				char filesize[100];
				grab(matchstart, matchend, filesize);
				if (numtoi(filesize) && !got_bad_number)
					ftp_job->file_size = numtoi(filesize);
			}
			point = from;
			if (found_ftp_status("^220 "))	// Welcome msg.
				set_both_mode_message("[FTP: Sending user name] ");
			if (found_ftp_status("^331 "))	// Host wants password.
				set_both_mode_message("[FTP: Sending password] ");
			if (found_ftp_status("^230 "))	// User logged in.
				set_both_mode_message("[FTP: Working] ");
			if (found_ftp_status("^530 "))	// Bad password.
				discard_password_data();
			if (re_search(1, "^[45][0-9][0-9] ") && !parse_string(-1, "PASV\n... ")) {
				parse_string(1, ".*", msg);		// Some error code.
				say("FTP error: %s", msg);
				// Don't go to log if we're just creating a new file.
				if (ftp_job->operation != FTP_RECV
					  || !parse_string(-1, "^550 .*"))
					show_log = 1;
			}
			break;
	}
	if (buffer_ftp_activity)	// Do some buffer-specific FTP work.
		buffer_ftp_activity(activity, buf, from, to);
	switch (activity) {		// These don't automatically refresh later.
		case NET_DONE:
		case NET_LOG_DONE:
		case NET_SEND:
			refresh();
			break;
	}
	if (show_log) {
		if (num_of_popups() > 0 || orig_buf != ftp_job->buf) {
			say("FTP errors occurred, see buffer %s.",
				  buf_exist(ftp_job->log_buf) ?
				  bufnum_to_name(ftp_job->log_buf) : "<deleted>");
		} else {
			restore_vars();
			save_var iter, has_arg;
			save_var bufnum = buf;
			if (buf_exist(ftp_job->buf)) {
				to_buffer_num(ftp_job->buf);
				if (ftp_job->operation == FTP_SEND)
					modified = 1;
			}
			if (buf_exist(ftp_job->log_buf))
				to_buffer_num(ftp_job->log_buf);
			point = size();
			refresh();
			restore_vars();
			bufnum = window_bufnum;
		}
	}
	restore_vars();
	if (num_of_popups() > 0 && !strcmp(bufname, CONNECT_LIST_BUF)) {
		int line = lines_between(0, point, 0) + 1, col = current_column();
		make_connect_list();
		go_line(line);
		move_to_column(col);
		refresh();
	}
}

int save_remote_file(char *fname, int trans, struct file_info *finfo)
{
	int op = FTP_SEND;

	if (ftp_job)
		error("This buffer's FTP job has not yet completed.");
	inet_only();
	if (finfo)
		finfo->check_type = 0;		// Don't check file dates.
	translation_type = trans;
	modified = 0;
	if (ftp_ascii_transfers && trans != FILETYPE_BINARY)
		op |= FTP_ASCII;
	return url_operation(fname, op);
}

command send_invisible()
{
	char res[FNAMELEN];

	iter = 0;
	if (!can_send_invisible())
		error("This is not a process or telnet buffer.");
	comp_read(res, "Text to send without inserting into buffer: ", (int (*)()) 0,
			  POP_UP_PROMPT | PASSWORD_PROMPT, "");
	do_send_invisible(res, !has_arg);
}

int do_send_invisible(char *s, int add_term)
{
	if (telnet_id) {
		telnet_send(telnet_id, s);
		if (add_term)
			telnet_send(telnet_id, "\r");
	} else if (is_process_buffer(bufnum)) {
		process_send_text(bufnum, s, strlen(s));
		if (add_term)
			process_send_text(bufnum, "\n", 1);
	} else
		return 0;
	return 1;
}

int password_prompt()
{
	char msg[FNAMELEN], res[FNAMELEN];

	if (!can_send_invisible())
		return;
	save_var point = type_point;
	grab_full_line(bufnum, msg);
	comp_read(res, *msg ? msg : "Password: ", (int (*)()) 0,
			  POP_UP_PROMPT | PASSWORD_PROMPT, "");
	do_send_invisible(res, 1);
}

int telnet_activity();

void do_telnet(char *host, int port, char *bname)
{
	zap(bname);
	to_buffer(bname);
	type_point = 0;
	telnet_mode();
	discardable_buffer = 1;
	buffer_not_saveable = 1;
	set_read_only(0);
	when_net_activity = telnet_activity;
	telnet_id = telnet_host(host, port, bname);
}

command telnet()
{
	char hostname[FNAMELEN], buf[FNAMELEN], *p;
	int port = 23, i = 1;

	inet_only();
	tiled_only();
	if (has_arg){
		port = iter;
		iter = 0;
	}
	*hostname = 0;
	get_str_auto_def(hostname, "Host");
	if (!*hostname)
		return;
	if (!has_arg && (p = strchr(hostname, ':')) && numtoi(p + 1)
		  && !got_bad_number) {
		port = numtoi(p + 1);
		*p = 0;
	}
	sprintf(buf, "%s", hostname);
	p = buf + strlen(buf);
	for (;;) {		// Find an unused buffer.
		if (!exist(buf))
			break;
		bufname = buf;
		if (!telnet_id)
			break;
		sprintf(p, " %d", i++);
	}
	do_telnet(hostname, port, buf);
}

maybe_auto_read(struct file_info *now)
{
	int pos;

	// Only auto-read if size on disk is > 90% of current size, or
	// file is very small.
	if (!modified && (now->fsize / 9 >= size() / 10 || size() < 300)) {
		pos = point;
		if (!read_file(filename, reading_translation_type()))
			say("%s: Modified file read from disk.", filename);
		else
			auto_read_changed_file = _force_auto_read_changed_file = 0;
		point = pos;
		to_begin_line();
		maybe_add_readonly_once(now);
		return 1;
	}
	return 0;
}

 /* Compare this file's time info with version on disk. */
/* Return 0 to indicate ok, 1 to indicate user said to cancel saving
 * the file, or 2 to tell grep that it skipped asking to read a modified
 * file from disk. */
check_dates(save)
{
	struct file_info now, *then = &file_info;
	int ret = 1, temp, orig = bufnum, pos;

	if (num_of_popups() > 0)	// Don't pop up over bufed or similar.
		return 0;
	ignoring_file_change = 0;	// Resume checking on getting focus.
	if (!want_warn || !filename || then->check_type != CHECK_FILE
		  || check_file(filename, &now) != CHECK_FILE)
		return 0;
	update_readonly_warning(&now);
	if (!compare_dates(&now, then)) {
		maybe_add_readonly_once(&now);
		return 0;
	}
	switch_to_buffer(bufnum);
	maybe_add_readonly_once(&now);

	if ((auto_read_changed_file || _force_auto_read_changed_file)
		  && !save && maybe_auto_read(&now))
		return 1;
	if ((readonly_warning & ROWARN_GREP) && !save)
		return 2;
	tiled_only();
	switch_to_buffer(bufnum);
	maybe_ding(bell_on_date_warning);
	temp = tmp_buf();
	save_var _view_right = 0, _view_bottom = screen_lines - 22;
	save_var return_raw_buttons = 1;
	while (!user_abort) {
		show_date_warning(temp, orig, then, &now, save);
		bufnum = orig;
		pos = point;
		if (is_gui && want_gui_prompts) {
			int win, owin = window_handle;

			remove_final_view();
			save_var _doing_input = DI_VIEW;
			win = add_popup(0, 0, 75, 15, _view_border, temp);
			go_to_link = 0;
			display_dialog_box("FileDateBox2", "File has changed on disk",
							   win, 0, 0,
							   "Compare", "Read", save ? "Save" : "Ignore");
			text_color = (is_gui && want_gui_prompts) ? color_class text
				: color_class viewed_text;
			point = 0;
			view_loop(win);
			switch (key_is_button) {
				case 1:	key = 'C'; break;
				case 2:	key = 'R'; break;
				case 3:	key = save ? 'S' : 'I'; break;
			}
			window_handle = owin;
			remove_window(win);
			if (user_abort)
				break;
		} else {
			char junk[FNAMELEN];
			view_buf(temp, 0);
			if (key == abort_key)
				user_abort = 1;
			if (user_abort)
				break;
			getkey();
			if (key == WIN_DRAG_DROP)	// Ignore dropped files.
				while(drag_drop_result(junk))
					;
		}
		key = toupper(key);
		if (key == 'C') {
			refresh();
			split_window_vertically();
			window_number--;	/* to 1st window */
			find_in_other_buf(filename, default_translation_type);
			point = pos;
			to_begin_line();
			set_buffer_filename("");
			error("This buffer has disk version.");
			break;		/* abort out of calling func */
		} else if (key == 'R') {
			refresh();
			if (!read_file(filename, reading_translation_type()))
				say("%s: Read from disk.", filename);
			point = pos;
			to_begin_line();
			break;
		} else if (key == (save ? 'S' : 'I')) {
			if (key == 'I')
				ignoring_file_change = 1;	// Don't check on getting focus.
			refresh();
			ret = 0;
			break;
		} else if (key == '!')
			want_warn = !want_warn;
		else if (key == 'A')
			ask_read_changed_file();
		say("");
	}
	buf_delete(temp);
	return user_abort ? 1 : ret;
}

print_headings(fname, page, total_pages, date)
char *fname, *date;
{
	char buf[FNAMELEN];
	int scheme = find_index(print_color_scheme);

	if (print_heading & PRHEAD_FNAME) {
		sprintf(buf, "%s", fname);
		print_line(buf, scheme);
	}
	if (print_heading & (PRHEAD_PAGECNT | PRHEAD_DATE)) {
		*buf = 0;
		if (print_heading & PRHEAD_PAGECNT)
			sprintf(buf, "Page %d of %d     ", page, total_pages);
		if (print_heading & PRHEAD_DATE)
			strcat(buf, date);
		print_line(buf, scheme);
	}
	if (print_heading)
		print_line("", scheme);
}

do_print_region(b, all, silent)
{
	int buf, err, skipped_lines, cnt, cols;
	char to[FNAMELEN], title[FNAMELEN], *dest;

	iter = 0;
	dest = is_unix ? print_destination_unix : print_destination;
	if ((has_feature & FEAT_OS_PRINTING) && want_gui_printing) {
		print_options.flags = all ? 0 : PD_SELECTION;
		if (silent)
			print_options.flags |= PD_RETURNDEFAULT;
		if (!select_printer(&print_options))
			return -1;		// User canceled.
		all = !(print_options.flags & PD_SELECTION);
		if (*filename)
			strcpy(title, get_tail(filename, 1));
		else
			strcpy(title, bufname);
	} else if (!silent) {
		get_strdef(to, "Print to device (or !command)", dest);
		strcpy(dest, to);
	}
	save_var bufnum = b;
	buf = tmp_buf();
	save_spot point, mark;
	fix_region();		// handle other types of regions
	skipped_lines = all ? 0 : lines_between(0, point, 0);
	if (all)
		buf_xfer(buf, 0, size());
	else if (region_type() == REGRECT)
		extract_rectangle(buf, 0);
	else
		buf_xfer(buf, point, mark);
	bufnum = buf;
	safe_copy_buffer_variables(buf, b);

	point = 0;
	if (!print_tabs || print_line_numbers)
		tab_convert(0, size(), 0);
	if (print_line_numbers) {
		cnt = lines_between(0, size(), 0) + 1 + skipped_lines;
		for (cols = 0; cnt > 0; cols++)
			cnt /= 10;		// Compute maximum width of line numbers.
		cnt = 1;
		do {
			if (point >= size())
				break;
			bprintf("%*d  ", cols, skipped_lines + cnt++);
			set_character_color(give_begin_line(), point, -1);
		} while (nl_forward());
		point = 0;
	}
	do_print_adjustments();
	if ((has_feature & FEAT_OS_PRINTING) && want_gui_printing) {
		gui_print(title, title);
		err = 0;
	} else
		err = send_to_file_or_cmd(buf, dest);
	bufnum = b;
	buf_delete(buf);
	if (!err && !all)
		highlight_off();
	if (!err && !((has_feature & FEAT_OS_PRINTING) && want_gui_printing))
		say("%s printed.", all ? "Buffer" : "Region");
	return err;
}

int reading_translation_type()
{
	return (file_io_converter == unicode_file_converter)
			? FILETYPE_BINARY : translation_type;
}

command visit_file()
{
	char tmp[FNAMELEN];

	iter = 0;
	save_var show_mouse_choices = 1;
	get_file(tmp, "Visit file", force_save_as == FSA_NEWFILE ? "" : filename);
	if (!*tmp)
		return;
	if (!has_arg && modified) {	/* buffer need to be saved? */
		if (ask_save_buffer())
			do_save_file(1, 1, 1);
	}
	read_file(tmp, reading_translation_type());
}

command revert_file()
{
	char pr[FNAMELEN], rel[FNAMELEN];

	save_var point;
	if (!*filename || force_save_as)
		error("No file for this buffer.");
	iter = 0;
	if (modified) {		/* buffer need to be saved? */
		relative(filename, rel);
		sprintf(pr, "Discard changes and revert to %s? ", rel);
		if (!ask_yn("Discard changes", pr, "Discard", "Cancel", 1))
			return;
	}
	read_file(filename, reading_translation_type());
	build_first = 1;
	fix_window_start();
}

command refresh_files()
{
	TIMER talk_now;
	int i, cnt = 0, res;

	time_begin(&talk_now, 100);		// Wait a second before chatter.
	save_var readonly_warning;
	save_var bufnum, window_bufnum;
	i = buf_list(0, 0);
	do {
		bufnum = i;
		readonly_warning |= ROWARN_GREP;
		res = check_dates(0);
		if (res)
			cnt++;
		if (res == 2) {
			readonly_warning &= ~ROWARN_GREP;
			to_buffer_num(i);
			check_dates(0);
			time_begin(&talk_now, 100);
		}
		check_abort();
		if (*filename && time_done(&talk_now)) {
			note("%r: refreshing.", filename);
			time_begin(&talk_now, 100);
		}
	} while (i = buf_list(1, 1));
	if (!cnt)
		say("No files have been modified on disk since they were read.");
	else if (time_done(&talk_now))
		say("");
}

do_file_read(s, strip)	/* read file, updating file_info */
char *s;
{
	int i;

	highlight_off();
	filename = s;
	unique_file_identifier[0] = 0;
	if (is_remote_file(s))
		return find_remote_file(s, strip);
	i = new_file_read(s, strip, &file_info, -1, -1);
	unique_filename_identifier(filename, unique_file_identifier);
	undo_set_flag(UNDO_READ_FILE);
	_read_aborted = (i == EREADABORT);
	unicode_on_read(strip);
	file_convert_read(0);
	return i;
}

note_written(char *fname)
{
	if (is_remote_file(fname))
		show_text(0, 1, "%s: write request queued.", fname);
	else
		show_text(0, 1, "%s written.", fname);
}

auto_save_one()
{
	char name[FNAMELEN];
	int err, origfile = !strcmp(auto_save_name, "%f");

	build_filename(name, auto_save_name, filename);
	if (_read_aborted)		// we didn't read whole file in,
		err = EREADABORT;	// so don't save it
	else if (!origfile)			// auto-save to a different file
		err = file_convert_write(name, translation_type, NULL);
	else if (check_dates(1))	// make sure other prog hasn't changed
		return;
	else				// get new time info
		err = file_convert_write(filename, translation_type, &file_info);
	if (err) {
		if (is_gui)		// Don't pop up dialog when autosave fails.
			say("Error autosaving %s", name);
		else
			file_error(err, name, "couldn't autosave");
		maybe_ding(bell_on_autosave_error);
	} else
		show_text(0, 1, "%s autosaved.", name);
	if (!origfile)
		modified = 1;
}

do_save_all_buffers(int newfile_bufs, int *count, int *failed)
{
	int i;

	save_var bufnum, window_bufnum;
	i = buf_list(0, 0);
	do {
		bufnum = i;
		if (!*filename || !modified || buffer_not_saveable)
			continue;
		if (newfile_bufs ? (force_save_as != FSA_NEWFILE)
						 : (force_save_as == FSA_NEWFILE))
			continue;	// Only do one group.
		if (newfile_bufs) {
			if (save_all_without_asking) {
				buffer_printf(MSG_BUFFER, "save-all-buffers: Could not"
							  " save buffer %s, no file name\n", bufname);
				(*failed)++;
				continue;
			}
			to_buffer_num(i);	// Show the buffer we'll be prompting for.
		}
		switch (do_save_file(1, 1, 1)) {
			case 1:
				buffer_printf(MSG_BUFFER, "save-all-buffers: Could not save %s\n",
							  filename);
				(*failed)++;
				break;
			case 0:
				show_text(-2, 1, "save-all-buffers: Saved %s\n", filename);
				(*count)++;
				break;
		}
	} while (i = buf_list(1, 1));
}

guess_mode_without_extension(char *res, char *pat)
{
	if (!strfcmp(get_tail(filename), "makefile")
		  || !strfcmp(get_tail(filename), "makefile.in")) {
		sprintf(res, pat, "mak");	// Recognize special file names
		return 1;					// w/o .mak extension.
	}
	if (mode_keys == telnet_tab) {
		sprintf(res, pat, "telnet");
		return 1;
	}		
	save_var point = 0;
	if (parse_string(1, "#%!.*/perl")) {
		sprintf(res, pat, "perl");
		return 1;
	}
	if (parse_string(1, "[ \t\n]*%<%??(%!DOCTYPE|html|xml|xst|%!--)")) {
		sprintf(res, pat, "html");
		return 1;
	}
	if (parse_string(1, "(:.*\n)?#%!.*/(sh|csh|bash)</word>|:\n")) {
		sprintf(res, pat, "sh");
		return 1;
	}
	if (parse_string(1, "%%%!PS-Adobe-")) {
		sprintf(res, pat, "ps");
		return 1;
	}
	if (size() > 1000)		// Look in 1st 1000 chars only.
		save_var narrow_end = size() - 1000;
	if (parse_string(1, "[ \t\n]*(//|/%*|#)")
		  && re_search(1, "^[ \t]*(#define|#include)[ \t]+")) {
		// It starts with a comment or preprocessor line, and it's
		// got a #define or #include, so assume it's a C++ header
		// file.
		sprintf(res, pat, "hpp");
		return 1;
	}
	point = 0;
	if (translation_type == FILETYPE_UNIX && parse_string(1, "([ \t]*\n)*#")) {
		sprintf(res, pat, "conf");
		return 1;
	}
	return 0;
}

char *do_file_match(s, flags)	// hook this function to change the rules
char *s;			// for matching file names
{
	char pat[FNAMELEN * 2];

	if (strlen(s) > FNAMELEN) {
		char *t = malloc(strlen(s) + 1), *r;
		strcpy(t, s);
		drop_quotes(t);
		r = file_match(t, flags);
		free(t);
		return r;
	}
	strcpy(pat, s);
	drop_quotes(pat);
	return file_match(pat, flags);
}

when_setting_sentence_end_double_space()
{
	if (ask_yn("Set sentence-end too?",
			   "Set the sentence-end variable to match?", "Yes", "No", 1))
		sprintf(sentence_end, "([.?!]<rsquare|rparen|squote|dquote>*"
				"[ \t\n]*(%s[ \t]|\n))", sentence_end_double_space ? "[ \t]" : "");
}

char *(*give_grep_finder)()(inbufs, filepat, ps)
char *filepat, **ps;	// put 1st match in ps & return finder for next matches
{
	char *(*finder)();

	finder = inbufs ? b_match : do_file_match;
	*ps = (*finder)(filepat, STARTMATCH | EXACTONLY
					| (inbufs ? 0 : FM_NO_DIRS));
	if (!ps)
		error("No matches");
	return finder;
}

get_grep_file(inbufs, filepat)
char *filepat;
{
	char pr[FNAMELEN], dir[FNAMELEN];

	if (!inbufs) {
		build_prompt(pr, "In file(s)", _grep_files, 0, 1);
		save_var prompt_with_buffer_directory = grep_prompt_with_buffer_directory;
		get_file_dir(filepat, pr);
		if (!*filepat && grep_default_directory || grep_default_directory == 3) {
			save_var _help_on_cmd = last_index;
			get_last_recall(f_match, filepat);
			if (grep_default_directory >= 2 && *filepat
				  && get_buffer_directory(dir)) {
				absolute(filepat, dir);
				return 1;
			}
		}
		if (*filepat) {
			if (is_directory(filepat))
				sprintf(filepat + strlen(filepat), "%c*", path_sep);
			strcpy(_grep_files, filepat);
		}
		relative(_grep_files, filepat);
		if (!*filepat)
			return 0;
	} else
		comp_read(filepat, "In buffers [pattern]: ", b_match, 0, bufname);
	return 1;
}

ok_grep_file_match(char *s)
{
	char pat[FNAMELEN];

	if (!use_grep_ignore_file_extensions)
		return 1;
	save_var case_fold = (FOLDFILE != 0);
	sprintf(pat, "|%s|", get_extension(s));
	return strstr(grep_ignore_file_extensions, pat) == NULL;
}

grep_date_warning(char *buf, char *file)
{
	int i;

	save_var bufname = buf;
	i = point;
	bprintf("Searching version of %s in memory, "
			"but version on disk has changed.\n", file);
	set_character_color(i, point, color_class grep_header);
}

grep_examine()
{
	int start, end, colon, old, instance, i, toolong = 0;
	char file[FNAMELEN], string[FNAMELEN], line[FNAMELEN], curdir[FNAMELEN], *p;

	_last_was_grep = 1;
	to_begin_line();
	save_var case_fold = 0;		/* turn off for grep buffer */
	if (!search(1, ": "))
		error("Can't read file name");
	colon = point;
	to_begin_line();
	start = point;
	to_end_line();
	end = point;
	point = start;
	grab(start, colon - 2, file);
	if (start + FNAMELEN - 3 < end)
		end = toolong = start + FNAMELEN - 3;
	grab(colon, end, string);
	line[0] = '\n';		// Put \n at start and end of line.
	grab(start, end + 1, line + 1);
	instance = count_instances(line) + 1;
	if (strstr(file, BUFPREFIX) != file) {
		grep_get_curdir(curdir);
		absolute(file, curdir);
		if (find_it(file, ask_line_translate()))
			return;
	} else if (exist(p = file + sizeof(BUFPREFIX) - 1))
		to_buffer(p);
	else
		error("Can't find buffer %s.", p);
	if (strlen(line) != end - start + 2)
		error("Can't find matching lines with null characters.");
	old = point;
	save_var case_fold = 0;		/* turn off for user buffer */
	point = 0;
	for (i = 0; i < instance; i++)
		if (toolong ? !search(1, string) : !line_search(1, string)) {
			point = old;
			if (i == 0 || instance == 1)
				error("Can't find \"%s\"", string);
			else
				error("Can't find this copy of "
					  "repeated line");
		} else {
			old = point;
			if (i + 1 < instance)
				nl_forward();
		}
	to_begin_line();
	if (toolong)
		say("Line too long; this may not be the correct match.");
}

do_file_replace(str, with, flags, filepat, inbufs)
char *str, *with, *filepat;	// (query-) replace across files/buffers
{
	int res, oldbuf = 1, prevbuf = 0, total = 0, cnt = 0;
	char rel[FNAMELEN], abs[FNAMELEN], *s, *(*finder)();
	int total_found = 0, total_changed = 0, old_readonly;

	old_readonly = readonly_warning;
	save_var readonly_warning;			// Don't show msg or ring bell
	readonly_warning &= ~(ROWARN_MSG | ROWARN_BELL); // unless matches.
	finder = give_grep_finder(inbufs, filepat, &s);	// Get 1st match
	save_var window_bufnum;
	for (; s; s = (*finder)(filepat, 0)) {
		if (!inbufs && !ok_grep_file_match(s))
			continue;
		grep_make_names(rel, abs, s, inbufs);
		noteput("Searching %s...", rel);
		if (!inbufs) {
			oldbuf = look_file(abs);
			if (find_it(abs, default_translation_type) == EREADABORT)
				user_abort = 1;
		} else
			to_buffer(s);
		undo_mainloop();
		if (!user_abort) {
			res = one_file_replace(str, with, flags, oldbuf, old_readonly);
			total_found += replace_num_found;
			total_changed += replace_num_changed;
			total++;
			if (res >= 0)
				cnt++;
		} else {
			res = DSABORT;
			user_abort = 0;
		}
		if (prevbuf && buf_in_window(prevbuf) == -1) {
			buf_delete(prevbuf);	// delete untouched new bufs
			prev_forget(_prev_num - 1); // fix default
		}
		prevbuf = (oldbuf || modified) ? 0 : bufnum;
		if (res == 0 && (flags & QUERY) && key == '!'
			  && ask_continue_replace("Replace without asking"))
			flags &= ~QUERY;	// no more querying
		else if (res == DSABORT || res == 1 && ungot_key != -1) {
			if (!ask_continue_replace("Continue replacing"))
				break;
		} else if (res > 0) {	// User said to stop, or bad pattern.
			if (res == DSBAD)
				show_replace(str, with, flags | BAD);
			user_abort = 0;
			return;
		}
		ungot_key = -1;
		if (user_abort)
			break;
	}
	ungot_key = -1;
	user_abort = 0;
	say("Replaced %d of %d matches in %d of %d %s.",
		  total_changed, total_found, cnt, total,
		  inbufs ? "buffers" : "files");
}

command help()
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

man_follow_link()
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

color_html_attributes(script, orig)
{
	int len, start, lang;

	if (script == 2)		// A <jsp:> tag.
		lang = get_html_asp_language(html_javascript_coloring);
	else if (script)
		lang = get_html_asp_language(html_other_coloring);
	while (len = parse_string(1, "[-_./a-z0-9]*")) {	// An attribute?
		if (script == 1 && parse_string(1, "(language|type)[ \t\n]*=[ \t\n]*"
										"[\"']*(text/)?(javascript|jscript|ecmascript)"))
			lang = html_javascript_coloring;
		else if (script == 1 && parse_string(1, "(language|type)[ \t\n]*=[ \t\n]*"
											 "[\"']*(text/)?(vbscript)"))
			lang = html_vbscript_coloring;
		if (character(point + len) == ':'
			  && matches_at(point + len, 1, ":[-_./a-z0-9]*")) {
			set_character_color(point, point + len + 1, color_class html_namespace);
			point += len + 1;
			len = matchend - point;
		}
		set_character_color(point, point + len, color_class html_attribute);
		point += len;			// Followed by a value?
		if (len = parse_string(1, "[ \t\n]*=[ \t\n]*")) {
			set_character_color(point, point + len, color_class html_punctuation);
							// Color the = and whitespace.
			point += len;		// Value might be quoted.
			start = point;
			if (curchar() == '"') {
				point++;
				search(1, "\"");
			} else if (curchar() == '\'') {
				point++;
				search(1, "'");
			} else	// No quotes, assume it's whitespace-delimited.
				re_search(1, "[^ \t\n<>]*");
			set_character_color(start, point, color_class html_value);
		}
		re_search(1, "[ \t\n]*");	// Parse whitespace.
		set_character_color(matchstart, matchend, color_class html_punctuation);
	}
	if (curchar() == '>') {
		set_character_color(point, point + 1, color_class html_punctuation);
		point++;
	}
	start = point;
	if (script && !parse_string(-1, "/%>")) {
		if (re_search(1, script == 2 ? "%</jsp:.*%>" : "%</script%>")) {
			set_tagged_region("color-as-unit", orig, point, 99);
			point = matchstart;
		} else
			set_tagged_region("color-as-unit", orig, point, 99);
		color_embedded_code(start, point, lang);
	}
}

color_embedded_code(from, to, lang)
{
	save_var point;
	save_var narrow_start = from;
	save_var narrow_end = size() - to;
	set_tagged_region("color-as-unit", from, to, lang);
	if (lang == 1) {
		save_var c_extra_keywords |= JAVA_KEYWORDS;
		save_var recolor_range = color_c_range;
		save_var recolor_from_here = color_c_from_here;
		color_for_narrowed_area(from, to);
	} else if (lang == 2) {
		save_var recolor_range = color_vbasic_range;	// set up coloring rules
		save_var recolor_from_here = recolor_by_lines;
		save_var sublanguage_code = SUBLANG_VBSCRIPT;
		color_for_narrowed_area(from, to);
	} else
		set_character_color(from, to, color_class html_attribute);
}

color_html_comment()
{
	int s;

	search(-1, "<");	// Find start of comment.
	s = point;
	if (parse_string(1, "%<%!%[CDATA%[")) {	// xml cdata
		re_search(1, "%]%]%>");
		set_character_color(s, point, color_class html_value);
		return;
	} else if (parse_string(1, "%<[ \t\n]*%![ \t\n]*--?")) {
		// A legal comment?
		point = matchend;
		re_search(1, "-[ \t\n]*>");	// Search for end of legal comment.
	} else	// Some odd flavor of comment; don't be too picky about its end.
		search(1, ">");
	set_character_color(s, point, color_class html_comment);
}

get_html_asp_language(int def)
{
	save_var point = 0;
	if (re_search(1, "%<(%%@|jsp:directive.page)[^>]*</word>Language=[\"']?")) {
		if (parse_string(1, "VBScript"))
			return 2;
		if (parse_string(1, "(java|j|ecma)script"))
			return 1;
	}
	return def;
}

color_html_include()
{
	int s, t, c, lang;
	char *end;

	search(-1, "<");	// Find start of include.
	c = character(point + 1);
	s = point;
	switch (c) {
		case '%':	point += parse_string(1, "%<%%[a-z0-9]*");
					end = "%>";
					lang = get_html_asp_language(html_asp_coloring);
					break;
		case '?':	point += parse_string(1, "%<%?[a-z0-9]*");
					end = "?>";
					lang = html_php_coloring;
					break;
		default:	point++;
					end = ">";
					lang = get_html_asp_language(html_asp_coloring);
					break;
	}
	t = point;
	set_character_color(s, point, color_class html_attribute);
	search(1, end);
	set_character_color(matchstart, point, color_class html_attribute);
	set_tagged_region("color-as-unit", s, point, 99);
	color_embedded_code(t, matchstart, lang);
}

color_html_move_back()
{
	int start = point, p;

	save_var narrow_start = point - color_html_look_back;
	if (re_search(-1, "%<%!%[CDATA%[|%]%]%>")
		  && !parse_string(-1, "%<script[^<]*%><wspace>*"))
		if (curchar() == '<')
			return 1;
		else {
			point += parse_string(1, "%]%]%>");
			return -1;
		}
	point = start;
	if (re_search(-1, "<Langle>[ \t\n]*/?script")
		  && parse_string(1, "<Langle>[ \t\n]*script"))
		return 2;				// Found a <script>, not a </script>.
	point = start;
	if (re_search(-1, "<Langle>[%?]|[%?]<Rangle>")
		  && curchar() == '<')
		return 3;				// Found a <% or <?, not a %> or ?>.
	point = start;
	do {			// start coloring from the previous tag
		if (!search(-1, "<"))
			break;	// but ignore <'s before " or ' characters
		if (get_character_color(point, &p, NULL) == color_class html_comment) {
			point = p + 2;	// If we're in a comment,
			search(-1, "<!");	// go back to its start.
		}
	} while (html_in_quoted_attribute());
	return 0;
}

color_html_range(from, to) // recolor just this section
{			// last colored region may go past to
	int s, script, t, i;

	if (from >= to)
		return to;
	save_var point, matchstart, matchend;
	if (from < to) {
		set_character_color(from, to, color_class html_text);
		set_tagged_region("needs-color", from, to, -1);	// Say it needs coloring.
	}
	point = from;
	save_var case_fold = 1;
	color_html_move_back();
	while (point > narrow_start
		   && get_tagged_region("color-as-unit", point - 1, &from) != -1)
		point = from;		// Move before script areas.
	if (to > size() - narrow_end)
		to = size() - narrow_end;
	set_tagged_region("color-as-unit", from, to, -1);
	for (s = point; point < to; ) {
		if (curchar() == '&') {
			set_character_color(s, point, color_class html_text);
			s = point++;	 // Color an entity like &amp; or &#251;
			if (parse_string(1, "([a-z]+|#[0-9]+|#x[0-9a-f]+);?"))
				point = matchend;
			set_character_color(s, point, color_class html_entity);
			s = point;
			continue;
		}
		if (curchar() != '<') {
			point++;
			continue;
		}
		set_character_color(s, point, color_class html_text);
		i = t = point++;
		while (strchr(" \t\n", curchar()))
			point++;	// Parse < followed by whitespace.
		set_character_color(t, point, color_class html_punctuation);
		if (curchar() == '!')
			color_html_comment();
		else if (strchr("%?", curchar()))
			color_html_include();
		else if (s = parse_string(1, "[-_./a-z0-9]*")) { // Parse the tag.
			set_character_color(point, point + s, color_class html_tag);
			script = (s == 6 && parse_string(1, "script"));
			if (s == 3 && parse_string(1, "jsp:(declaration|expression"
									   "|scriptlet)</word>"))
				script = 2;
			point += s;			// Look for javascript tag.
			if (curchar() == ':' && parse_string(1, ":[-_./a-z0-9]*")) {
				set_character_color(point - s, point + 1,
									color_class html_namespace);
				set_character_color(point + 1, matchend,
									color_class html_tag);
				point = matchend;
			}
			for (i = point; strchr(" \t\n", curchar()); )
				point++;	// Parse whitespace.
			set_character_color(i, point, color_class html_punctuation);
			color_html_attributes(script, t);
		}
		s = point;
	}
	re_search(1, "![<&]");
	if (s < point)
		set_character_color(s, point, color_class html_text);
	set_tagged_region("needs-color", from, point, 0);	// Say it's colored.
	return point;
}

html_move_level(int dir, int stop_on_key)
{
	char *findch = (dir > 0) ? "<" : ">";
	char *otherch = (dir < 0) ? "<" : ">";

	recolor_buffer_range(point, point + 1);
	switch (get_tagged_region("color-as-unit", point - (dir < 0))) {
		case 1:
			return c_move_level(dir, stop_on_key);
		case 2:
			findch = (dir > 0) ? "[({" : "])}";
			otherch = (dir < 0) ? "[({" : "])}";
			break;
	}
	return default_move_level(dir, findch, otherch);
}

// Narrowing may not have excluded the <script line itself, so do it
// now.
html_exclude_script_head()
{
	save_spot point = narrow_start;
	if (parse_string(1, "<langle>[%?][a-z0-9]*"))
		point = matchend;
	else if (parse_string(1, "<Langle>[ \t\n]*script"))
		search(1, ">");
	if (parse_string(1, "%<%!--"))
		point = matchend;
	if (parse_string(1, "%<%!%[CDATA%["))
		point = matchend;
	narrow_start = point;
}

html_indent() on html_tab['\t']
{
	int region, start;

	region = get_tagged_region("color-as-unit", point, &start);
	if (IS_ENTER_KEY(key) && !(html_auto_indent &
							   (region == 1 ? 2 : region == 2 ? 4 : 1)))
		return;
	save_var narrow_start = start;
	switch (region) {
		case 1:
			html_exclude_script_head();
			save_var c_extra_keywords |= JAVA_KEYWORDS;
			do_c_indent();
			return;
		case 2:
			html_exclude_script_head();
			do_vbasic_indent();
			return;
	}
	indent_previous();
}

html_redirect_active_key() on html_tab['{'], html_tab['}'], html_tab[')'],
							  html_tab[']'], html_tab[':'], html_tab['#']
{
	int region, start, end, f = 0;
	short *tab = 0;

	recolor_buffer_range(point, point + 1);
	region = get_tagged_region("color-as-unit", point, &start, &end);
	switch (region) {
		case 1:
			save_var auto_show_matching_characters = c_auto_show_delim_chars;
			save_var mode_move_level = c_move_level;
			tab = c_tab;
			break;
		case 2:
			save_var auto_show_matching_characters = vbasic_auto_show_delim_chars;
			save_var mode_move_level = 0;
			tab = vbasic_tab;
			break;
	}
	if (tab)
		f = binding_of(key, tab);
	if (f > 0) {
		save_var narrow_start = start, narrow_end = size() - end;
		html_exclude_script_head();
		save_var Matchdelim = 0;	// Don't refresh while we're narrowed.
		do_command(f);
		return;
	}
	normal_character();
}

html_fill_paragraph() on html_tab[ALT('q')]
{
	int region, start, end;

	recolor_buffer_range(point, point + 1);
	region = get_tagged_region("color-as-unit", point, &start, &end);
	switch (region) {
		case 1:
			save_var major_mode = _c_mode_name;
			fill_comment();
			return;
		case 2:		// Can't fill vbscript block comments in html yet.
			break;
	}
	fill_paragraph();
}

int html_auto_show_delimiter()
{
	int region, start, end;

	save_var point;
	region = get_tagged_region("color-as-unit", point, &start, &end);
	save_var narrow_start = start, narrow_end = size() - end;
	switch (region) {
		case 1:
			html_exclude_script_head();
			save_var auto_show_matching_characters = c_auto_show_delim_chars;
			save_var mode_move_level = c_move_level;
			break;
		case 2:
			html_exclude_script_head();
			save_var auto_show_matching_characters = vbasic_auto_show_delim_chars;
			save_var mode_move_level = 0;
			break;
	}
	return default_auto_show_delimiter();
}

int html_recolor_from_here();


command html_mode()
{
	mode_default_settings();
	mode_keys = html_tab;		/* Use these keys. */
	major_mode = _html_mode_name;

	strcpy(comment_start, "%<%!-- *");
	strcpy(comment_pattern, "%<%!--(.|<newline>)*--%><FirstEnd>");
	strcpy(comment_begin, "<!-- ");
	strcpy(comment_end, " -->");
	indenter = html_indent;
	auto_indent = 1;
	mode_move_level = html_move_level;
	if (auto_show_html_delimiters)
		auto_show_matching_characters = html_auto_show_delim_chars;
	mode_auto_show_delimiter = html_auto_show_delimiter;
	recolor_range = color_html_range;	// set up coloring rules
	recolor_from_here = html_recolor_from_here;
	idle_coloring_size = 5000;
	if (want_code_coloring)		// maybe turn on coloring
		when_setting_want_code_coloring();
	try_calling("html-mode-hook");
	drop_all_colored_regions();
	make_mode();
}

suffix_xst()		// XML script
{
	html_mode();
}

suffix_php4()		// PHP server-side page
{
	html_mode();
}

command toggle_scroll_bar()	// want constant scroll bar on tiled wins?
{
	if (is_gui)
		error("Can't toggle scroll bar in this version.");
	tiled_scroll_bar = has_arg ? (iter != 0) : !tiled_scroll_bar;
	border_right = (permit_scroll_bar_border() && tiled_scroll_bar);
	full_redraw = 1;
}

drag_drop_handler()
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


process_line_inside_quoting()
{
	return parse_string(-1, "^([^\"\n]|\"[^\"\n]*\"|)*!\"[^\"\n]*");
}

command process_complete()
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

int maybe_auto_show_delimiter()
{
	int i;

	if (retain_highlight_area)
		return 0;
	if (highlight_area_end[0]) {	// Remove existing highlight.
		if (spot_to_buffer(highlight_area_start[0]) != bufnum) {
			highlight_area_start[0] = 0;	// A spot in some other buffer.
			highlight_area_end[0] = 0; // (we must have copied it).
			highlight_area_start[1] = 0;
			highlight_area_end[1] = 0;
		}
		modify_region(SHOW_MATCHING_REGION, MRTYPE, 0);
	}
	if (num_of_popups() > 0 || is_key_repeating())
		return 0;
	if (mode_auto_show_delimiter) {
		i = (*mode_auto_show_delimiter)();
		if (i != 1)
			return i;
	}
	return default_auto_show_delimiter();
}

default_auto_show_delimiter()
{
	char *p, left[FNAMELEN], right[FNAMELEN];
	int i, rightside, adjacent = 0, len;

	if (!auto_show_matching_characters || !*auto_show_matching_characters
		  || !curchar())
		return 0;
	p = index(auto_show_matching_characters, curchar());
	if (!p && auto_show_adjacent_delimiter) {
		adjacent = 1;	// Check prev character, maybe it's a delim.
		save_var point--;
		p = index(auto_show_matching_characters, curchar());
	}
	if (!p)
		return 1;				// Not a delimiter we can match.
	i = p - auto_show_matching_characters;		// Index of char.
	len = strlen(auto_show_matching_characters);
	rightside = i * 2 >= len;
	if (adjacent && !(auto_show_adjacent_delimiter & (rightside ? 1 : 2)))
		return 1;	// Maybe reject some adjacent delimiters.
	save_var point, matchstart, matchend, abort_searching = 0;
	save_var mouse_mask &= ~MASK_MOVE;	// Don't give up due to mouse motion.
	init_auto_show_delimiter();
	for (i = 0; i * 2 < len; i++) {
		left[i] = auto_show_matching_characters[i];
		right[i] = auto_show_matching_characters[len - i - 1];
	}
	left[i] = right[i] = 0;
	if (rightside ? try_auto_show_delimiter(-1, right, left)
				  : try_auto_show_delimiter(1, left, right)) {
		modify_region(SHOW_MATCHING_REGION, MRTYPE, REGINCL);
		return 3;			// Show the two regions.
	}
	return 2;
}

command pull_word()
{
	int pl_key;

	check_modify(bufnum);
	iter = 1;
	if (at_word_interior()){
		note("Can't pull word here.");
		return;
	}


	alloc_pl();

	for (pl_key = pl_trans(key); 1; pl_key = pl_getkey()){

		switch(pl_key){
			case 1:
			case -1:
				if (pl_search(pl_key) == 0){
					pl_restore();
					free_pl();
					expire_message = 1;
					return;
				}
				break;
			case 7:
				pl_restore();
				free_pl();
				user_abort = 0;
				return;
			case '?':
				help_on_command("pull-word");
				break;
			default:
				free_pl();
				/* Run the key that caused us
				 * to exit.
				 */
				run_topkey();
				return;
		}
	}
}

int pl_getkey()
{
	int ch;
	for (;;) {
		switch (ch = getkey()) {
			case MOUSE_MOVE:
			case GETFOCUS:
			case LOSEFOCUS:
			case LOST_SELECTION:
			case WIN_MOUSE_LEAVES:
			case WIN_MOUSE_ENTERS:
				break;
			default:
				return pl_trans(ch);
		}
	}
}

// Go to this remembered position (including its item).
int to_old_place(old_place *p)
{
	save_var window_start;
	if (search_continuation)
		(*search_continuation)(SCON_RESTORE, 0, p->item);
	point = p->pos;
}

// Return 1 if point/current item is bigger than old position.
int past_old_place(old_place *p)
{
	int c;

	save_var window_start;
	if (search_continuation)
		if (c = (*search_continuation)(SCON_COMPARE, 0, p->item))
			return c > 0;
	return point > p->pos;
}

word_search(dir, str)		/* search for whole words only */
char *str;
{
	char *pat, *s, *t;
	int ret, a = abort_searching, c;

	if (a == ABORT_JUMP)
		save_var abort_searching = ABORT_ERROR;
	pat = malloc(strlen(str) * 8 + 20);
	*pat = 0;
	if (isident(str[0]) || str[0] >= 0x80)
		strcpy(pat, "</word>");
	for (s = str, t = pat + strlen(pat); *s; s++)
		if (isalnum(*s))
			*t++ = *s;
		else if (*s == ' ') {
			strcpy(t, "<wspace>+");
			t += strlen(t);
		} else {
			*t++ = '%';
			*t++ = *s;
		}
	if (strlen(str) > 1 && isident(c = str[strlen(str) - 1]) || c >= 0x80)
		strcpy(t, "</word>");
	say("%s", pat);
	ret = re_search(dir, pat);
	free(pat);
	if (ret == ABORT_ERROR && a == ABORT_JUMP)
		quick_abort();
	return ret;
}

save_session()		/* write out the session */
{			/* return error code */
	char file[FNAMELEN];

	if (preserve_session_once)
		save_var preserve_session = preserve_session_once - 1;
	if (!(preserve_session & (SAVE_RESTORE_SESSION | SAVE_SESSION)))
		return 0;
	give_session_file(file);
	return do_save_session(file);
}

session_save_buffer(int b, char *sdir)
{
	char file[FNAMELEN];
	int transl = translation_type;

	if (file_io_converter == unicode_file_converter)
		transl = FILETYPE_BINARY;
	relative(filename, file, sdir);
	buf_printf(b, "%s\n%s\n%d %d %d\n",
			   bufname, file, point, mark, transl);
	buf_printf(b, "%d %d %d %d\n", over_mode, fill_mode,
			   indent_with_tabs, margin_right);
	buf_printf(b, "%d %d %d %d %d %d %d %d %d\n", tab_size,
			   case_fold, 0, want_warn,
			   _buf_readonly, buf_accessed,
			   (file_io_converter == oem_file_converter),
			   (file_io_converter == unicode_file_converter),
			   translation_type);
}

remember_this_buffer()	/* should we record this buffer in session file? */
{
	if (*bufname == '-' || is_dired_buf() || !size() || !*filename)
		return 0;
	if (is_process_buffer(bufnum) || buffer_not_saveable || _read_aborted)
		return 0;
	if (file_info.year && file_info.check_type != CHECK_FILE)
		return 0;
	if (is_remote_file(filename))
		return 0;
	return 1;
}

load_session()		/* maybe search for a session file & load it */
{			/* return 1 if session was loaded */
	char file[FNAMELEN];

	if (preserve_session_once)
		save_var preserve_session = preserve_session_once - 1;
	if (!(preserve_session & (SAVE_RESTORE_SESSION | RESTORE_SESSION)))
		return 0;
	give_session_file(file);
	return load_this_session(file);
}

int session_restore_one_file_2(int b)
{
	int nums[10], i;

	if ((i = grab_numbers(b, nums)) < 5)
		return 0;
	if (session_restore_files) {
		tab_size = nums[0];
		case_fold = nums[1]; // nums[2] var was removed
		want_warn = nums[3];
		if (nums[4] == 1)
			set_read_only(1);
		buf_accessed = i > 5 ? nums[5] : 0;
		file_io_converter = 0;
		if (i > 6 && nums[6]) {
			file_io_converter = oem_file_converter;
			file_convert_read(FILE_CONVERT_QUIET);
		} else if (i > 8 && nums[7]) {
			file_io_converter = unicode_file_converter;
			translation_type = nums[8];
			file_convert_read(FILE_CONVERT_QUIET);
		}
		undo_mainloop();
	}
	return 1;
}

int session_restore_one_file(int b, char *file, char *sdir, int *readerrs,
							 int *nums)
{
	int i;

	if (session_restore_files)
		filename = file;
	if (*file && session_restore_files) {
		absolute(file, sdir);
		i = do_file_read(file, nums[2]);
		force_save_as = 0;
		if (user_abort || i == EREADABORT)
			return 0;
		if (!i || i == 2) {
			if (!i)
				set_readonly_from_file();
			window_bufnum = bufnum;		// make suffix- kbd macros work
			call_mode(filename);
			make_mode();
		} else if (!*readerrs++) {
			file_error(i, file, "read error");
			maybe_ding(bell_on_read_error);
		} else
			show_text(0, 1, "%d files could not be read", *readerrs);
	}
	if (session_restore_files) {
		if (bufnum != b)	/* same tmp name as session buffer */
			point = nums[0];
		mark = nums[1];
		translation_type = nums[2];
	}
	if (!session_restore_one_file_1(b))
		return 3;
	if (!session_restore_one_file_2(b))
		return 4;
	return -1;
}

restore_session(b)	/* if error in session file, return error code # */
{			/* for debugging purposes, else 0 */
	int nums[10], j, err, readerrs = 0;
	int def_buf = 0;
	char buf[FNAMELEN], file[FNAMELEN];
	char sdir[FNAMELEN];	// dir of session file

	give_session_file(sdir);
	absolute(sdir);
	*get_tail(sdir, 0) = 0;
	bufnum = b;
	point = 0;
	if (!grab_line(b, buf) || strcmp(buf, SES_HDR))
		return 1;
	while (grab_line(b, buf)) {
		grab_line(b, file);
		if (grab_numbers(b, nums) < 3)
			return 2;
		if (session_restore_files)
			bufnum = create(buf);
		if (!def_buf) {
			if (is_gui)
				show_text(0, 1, "Restoring session...");
			else
				show_text(-1, 1, "Restoring session...");
			def_buf = bufnum;
		}
		j = session_restore_one_file(b, file, sdir, &readerrs, nums);
		if (j != -1)
			return j;
	}
	if (session_restore_prev_buffers(b))
		return 12;
	if (restore_bookmark_session(b))
		return 13;
	err = session_restore_windows(b, def_buf);
	if (err < 0)
		return 5;
	if (session_restore_misc(b))
		err = 11;
	return err ? err : readerrs ? 100 : 0;
}

when_setting_preserve_session()
{
	preserve_session_once = 0;
}

set_var_val(i, tmp, def)	/* set var at index i to tmp */
char *tmp;
{
	char when_setting[FNAMELEN];

	save_var use_default = def;
	if (strstr(" selected-color-scheme -our-mono-scheme -our-color-scheme "
			   "-our-gui-scheme -our-unixconsole-scheme ", name_name(i))
		  && isalpha(*tmp)) {
		if (name_type(find_index(tmp)) != NT_COLSCHEME)
			error("%s is not a color scheme", tmp);
		sprintf(tmp, "%d", find_index(tmp));
	}

	switch (vartype(i)) {
		case TYPE_CHAR:
		case TYPE_SHORT:
		case TYPE_INT:
			if (*tmp)
				set_num_var(i, numtoi(tmp));
			break;
		case TYPE_CARRAY:
			strncpy(varptr(i), tmp, ptrlen(varptr(i)) - 1); break;
		case TYPE_CPTR:
			set_str_var(i, strsave(tmp)); break;
	}
	sprintf(when_setting, "when-setting-%s", name_name(i));
	try_calling(when_setting);
}

safe_set_var_val(i, tmp, def)	/* set var at index i to tmp */
char *tmp;
{
	jmp_buf this_level;
	save_var top_level = &this_level;
	if (!setjmp(top_level))
		set_var_val(i, tmp, def);
}

command create_file_associations()
{
	int buf = zap("File Associations");
	char ext[FNAMELEN], cmd[FNAMELEN], dir[FNAMELEN], tmp[FNAMELEN];

	tiled_only();
	save_var window_bufnum;
	to_buffer_num(buf);
	stuff("# Associate Epsilon with the following extensions:\n\n");
	stuff("# Delete or add lines as required, then type Ctrl-X Ctrl-Z\n");
	stuff("# (the exit-level command) to carry out the change.  This\n");
	stuff("# command cannot remove existing Epsilon associations, only\n");
	stuff("# add new ones.  Changes you make here cannot be undone by\n");
	stuff("# uninstalling; make new associations using Windows Explorer\n");
	stuff("# or by running this command again.\n");
	stuff("\n.c\n.cpp\n.h\n.e\n.txt\n");
	conf_mode();
	for (;;) {
		recursive_edit();
		if (strcmp(bufname, "File Associations"))
			error("Canceled.");
		point = 0;
		if (!re_search(1, "^%.(exe|bat|cmd)$"))
			break;
		say("Don't modify the association for .exe, .bat, or .cmd files.");
	}
	make_registration_entry("Epsilon", "Epsilon");
	get_executable_directory(dir);
	strcpy(tmp, argv[0]);
	absolute(tmp, dir);
	if (is_gui == IS_WIN31)
		sprintf(cmd, "%s %%1", tmp);
	else
		sprintf(cmd, "\"%s\" \"%%1\"", tmp);
	make_registration_entry("Epsilon\\shell\\open\\command", cmd);
	make_registration_entry("Epsilon\\shell\\open\\ddeexec", "\"%1\"");
	make_registration_entry("Epsilon\\shell\\open\\ddeexec\\application",
							"Epsilon");
	make_registration_entry("Epsilon\\shell\\open\\ddeexec\\topic",
							"Open");
	point = 0;
	while (point < size() - narrow_end) {
		grab_line(bufnum, ext);
		if (*ext == '.')
			make_registration_entry(ext, "Epsilon");
		else if (*ext && *ext != '#')
			say("Ignoring invalid extension \"%s\"", ext);
	}
	restore_vars();
	buf_delete(buf);
	say("File associations created.");
}

command export_colors()
{
	char name[FNAMELEN];
	int i, max = final_index();

	iter = 0;
	strcpy(name, "mycolors.e");
	absolute(name);
	if (warn_existing_file(name))
		return;
	do_find(name, FILETYPE_AUTO);
	buf_zap(bufnum);
	stuff("// Automatically generated by export-colors.\n\n");
	stuff("#include \"eel.h\"\n\n");
	if (has_arg) {
		for (i = 1; i <= max; i++) {
			check_abort();
			if (name_type(i) == NT_COLSCHEME)
				export_colors_one_scheme(i);
		}
	} else
		export_colors_one_scheme(selected_color_scheme);
	restore_vars();
	point = 0;
	for (i = 0; i < 10; i++) {	// Assume class names have no more than 10 -'s.
		noteput("Working...%d", i);
		string_replace("(color_class .*)-", "#1_", REGEX);
		if (!replace_num_changed)	// Convert -'s in class names to _'s.
			break;
	}
	add_color_class_declarations();
	substitute_color_names();
	say("Done.");
}

add_color_class_declarations()
{
	int tmp;

	tmp = tmp_buf();
	buf_xfer(tmp, 0, size());
	save_var bufnum = tmp, sort_status = 0;
	point = 0;
	do_drop_matching_lines(0, "= color_class", 0);
	point = 0;
	string_replace(".* = ", "", REGEX);
	point = 0;
	do_sort_region(0, size(), 0, 0);
	point = 0;
	do_uniq(1, 1, 0);
	restore_vars();
	point = 0;
	search(1, "{");
	to_begin_line();
	grab_buffer(tmp);
	stuff("\n");
	buf_delete(tmp);
}

substitute_color_names()
{
	char *codes, name[100], defn[100];
	int tmp, orig = bufnum;

	codes = lookpath("eel.h");
	if (!codes)
		codes = lookpath("include/eel.h");
	if (!codes)
		error("Can't locate eel.h to substitute color names");
	bufnum = tmp = tmp_buf();
	if (err_file_read(codes, FILETYPE_AUTO))
		quick_abort();
	filename = "";	// Don't accidentally overwrite the real eel.h.
	save_var case_fold = 1;
	if (!re_search(1, "#define[ \t]+black"))
		error("Can't locate start of color names");
	delete(0, give_begin_line());
	if (!re_search(1, "#define[ \t]+END_COLOR_MARKER"))
		error("Can't locate end of color names");
	delete(give_begin_line(), size());
	point = 0;
	string_replace(",[ \t]*", ", ", REGEX);	// standardize MAKE_RGB() calls
	while (re_search(1, "#define[ \t]+")) {
		if (!parse_string(1, "[a-z0-9_]+", name))
			error("Can't interpret color name");
		point += parse_string(1, "[ \t]*");
		if (!parse_string(1, "MAKE_RGB%([a-z0-9, \t]+%)", defn))
			error("Can't interpret color definition");
		bufnum = orig;
		string_replace(defn, name, 0);
		bufnum = tmp;
	}
	bufnum = orig;
	buf_delete(tmp);
}

do_go_tag(s, n_fwd)
char *s;
{
	char pat[2048], tdir[FNAMELEN], *file, *p, modal_tag_next[FNAMELEN];
	int pos, oldbuf = bufnum, i;

	sprintf(modal_tag_next, "tag_to_next_%s", major_mode);
	bufnum = _tags_buffer;
	save_var case_fold = !tag_case_sensitive;
	if (*s) {
		if (p = index(s, '\t')) {
			strcpy(_last_tag_file, p + 1);
			*p = 0;		/* remove file name from s */
			if (p = index(_last_tag_file, '\t'))
				*p = 0;
		} else
			*_last_tag_file = 0;
		strcpy(_last_tag, s);
		if (!*_last_tag)	/* no last tag */
			return 0;
		if (*_last_tag_file)
			sprintf(pat, "^%q\t%q\t",
				_last_tag, _last_tag_file);
		else
			sprintf(pat, "^%q\t", _last_tag);
		point = 0;
		if (!re_search(1, pat))		/* look for 1st */
			return 1;
	} else {		/* find next matching tag */
		pos = point;
		sprintf(pat, "^%q\t", _last_tag);
		i = find_index(modal_tag_next);
		switch (name_type(i)) {		// Call mode-specific version.
			case NT_SUBR: case NT_COMMAND:
			case NT_AUTOSUBR: case NT_AUTOLOAD:
				if ((*(int (*)())i)(pat, n_fwd))
					return 1;
				break;
			default:
				if (!tag_search_by_offset(pat, n_fwd))
					return 1;
		}
	}
	grab(give_begin_line(), give_end_line(), pat);	/* tag, file, pos */
	file = index(pat, '\t');
	*file++ = 0;

	p = index(file, '\t');		/* find start of pos */
	pos = strtoi(p + 1, 10);
	*p = 0;
	p = index(p + 1, '\t');		/* if p, p+1 has line's text */
	strcpy(_last_tag_file, file);
	put_directory(tdir);
	bufnum = oldbuf;
	absolute(_last_tag_file, tdir);
	locate_window("", _last_tag_file);
	find_it(_last_tag_file, default_translation_type);
	sprintf(tdir, "%q[^a-zA-Z0-9_]", _last_tag);
	point = pos;
	if (!parse_string(1, tdir, NULL))
		if (!p || !prox_line_search(p + 1))	/* search by text */
			return 2;
	to_begin_line();
	window_start = prev_screen_line(show_tag_line);
	return 0;
}

command retag_files()
{
	char file[FNAMELEN], tdir[FNAMELEN];
	int t, aborted = 0;

	init_tags();
	if (tags_from_bsc)
		error("Can't modify a .BSC file.");
	say("");
	if (!ask_yn("Retag files", "Retag all files? ", "Yes", "No", 1))
		return;
	t = zap(TAGGED_FILES_BUF);
	get_tagged_file_names(t);
	to_another_buffer("-tag-errors");
	delete_buffer("-tag-errors");
	save_var tag_batch_mode = 1;
	put_tag_directory(tdir);
	while (grab_line(t, file) > 0 && !user_abort) {
		absolute(file, tdir);
		if (do_retag_file(file))
			user_abort = aborted = 1;
	}
	if (!aborted)
		do_save_tags();
	if (exist("-tag-errors")) {
		to_buffer("-tag-errors");
		discardable_buffer = 1;
	} else if (!aborted)
		say("All files retagged.");
}

tag_a_file(s)
char *s;
{
	jmp_buf *old_level = top_level, this_level;
	int ok = 1, err = 0, orig = bufnum, temp = 0, oldmod, aborted = 0;

	top_level = &this_level;
	bufnum = _tags_buffer;	/* go to right place in tags buffer */
	point = 0;
	nl_forward();
	oldmod = modified;	/* want to see if we add new tags */
	modified = 0;
	bufnum = orig;
	if (!setjmp(top_level)) {
		if (!look_file(s)) {
			if (!temp)
				temp = tmp_buf();
			bufnum = temp;
			save_var readonly_warning = 0;
			err = read_file(s, default_translation_type);
			filename = s;
		}
		if (!err) {
			save_var point = 0;
			ok = call_by_suffix(s, "tag-suffix-%s");
		}
	} else
		aborted = 1;
	bufnum = _tags_buffer;
	if (modified)		/* we added new tags, mark unsorted */
		mark_tags(0);
	else
		modified = oldmod;
	bufnum = orig;
	top_level = old_level;
	if (temp)
		buf_delete(temp);
	if (err == EREADABORT)
		aborted = 1, err = 0;
	if (err && tag_batch_mode)
		buffer_printf("-tag-errors", "Couldn't read the file %s.\n", s);
	else if (err)		/* couldn't read file */
		quick_abort();	/* already showed error msg */
	else if (!ok && tag_batch_mode)
		buffer_printf("-tag-errors", "Don't know how to tag the file %s.\n", s);
	else if (!ok)
		error("Don't know how to tag the file %s", s);
	return aborted || user_abort;
}

tag_suffix_cs()		{	tag_suffix_c();	}

skip_c_delims(int start, int end, int restore)
{
	int level = 0, c, orig = point, iflevel = 0, skipping = 0;
	char buf[4], pat[80];

	strcpy(buf, "X|\\");
	sprintf(pat, "[%c%c\"']|/<*|/>|(" PREPROC_LINE ")", end, start);
	while (re_search(1, pat)) {
		buf[0] = c = character(point - 1);
		if (c == '\"' || c == '\'')
			while (re_search(1, buf)
				   && character(point - 1) == '\\')
				point++;
		else if (c == '*')				/* Found block comment */
			search(1, "*/");
		else if (c == '/')		/* Found c++ one line comment */
			nl_forward();
		else if (c == start) {			/* Found char like (. */
			if (!skipping)
				level++;
		} else if (c == end) {			/* Found char like ). */
			if (!skipping) {
				if (!--level)			/* Found proper end. */
					return 0;
				else if (level < 0) {	/* Found extra closing delim, give up. */
					if (restore)
						point = orig;
					return 2;
				}
			}
		} else if (parse_string(-1, PREPROC_ELSE)) {
			if (iflevel <= 1)		// found #else or #elif line
				skipping = 1;	// Skip to matching #endif.
		} else if (parse_string(-1, PREPROC_ENDIF)) {
			if (iflevel <= 1)		// found #endif line
				skipping = 0;	// Stop skipping.
			if (iflevel > 0)			/* Ignore extra #endif's. */
				iflevel--;
		} else if (parse_string(-1, PREPROC_IF)) {
			iflevel++;				// found #if/#ifdef line
		}
	}
	if (restore)						/* Couldn't find match, give up. */
		point = orig;
	return 1;
}

int list_definitions_when_displaying();

command list_definitions()
{
	char tag[FNAMELEN], pat[FNAMELEN], *title;
	int tags, tmp, pos, decls = 0;
	int orig = bufnum, oldpoint = point, starthere = -1, old_ws = window_start;
	int orig_tab_size;

	if (when_displaying == list_definitions_when_displaying)
		return;		// Ignore double-presses.
	error_if_input(1);
	tags = zap("-list-definitions");
	tmp = tmp_buf();
	delete_buffer("-tag-errors");
	iter = 0;
	save_var point = 0, _tags_buffer = tags, tag_show_percent = 1;
	save_var tag_by_text = 1;
	if (has_arg)
		save_var tag_declarations = decls = 3;
	if (!*filename || !call_by_suffix(filename, "tag-suffix-%s"))
		error("Don't know how to list definitions in this buffer.");
	orig_tab_size = tab_size;
	if (!buffer_size("-list-definitions")) {
		save_var tag_declarations = decls = 3;
		point = 0;
		call_by_suffix(filename, "tag-suffix-%s");
	}
	if (!buffer_size("-list-definitions"))
		error("No definitions or declarations found in this buffer.");
	say("");
	restore_vars();
	if (want_code_coloring && recolor_range)
		recolor_buffer_range(0, size());	// Update colors for whole buffer.
	save_var point, bufnum = tags;
	point = 0;		// Copy colored lines of original file into tmp, based on tags.
	while (point < size() && parse_string(1, "^[^\t\n]+\t[^\t\n]+\t([^\t\n]+)\t")) {
		grab(find_group(1, 1), find_group(1, 0), pat);
		pos = strtoi(pat, 10);		// Position in original buffer.
		bufnum = orig;
		point = pos;
		if (give_begin_line() > oldpoint && starthere < 0)	// Look for starting pos.
			starthere = buffer_size(bufnum_to_name(tmp)) - 1;
		buf_xfer_colors(tmp, give_begin_line(), give_end_line() + 1);
		bufnum = tags;
		nl_forward();
	}
	bufnum = tmp;
	delete_final_newlines();
	point = (starthere == -1) ? size() : starthere;
	to_begin_line();	// Begin at corresponding point to original location.
	goal_column = 0;
	tab_size = orig_tab_size;
	when_displaying = list_definitions_when_displaying;
	restore_vars();
	*tag = 0;
	save_var menu_width = screen_cols - _view_left - _view_right;
	save_var _bufed_orig_window = window_handle;	// Save it here.
	save_var tag_declarations = decls;
	title = tag_declarations ? "Select a declaration or definition"
							 : "Select a definition";
	if (get_choice(tmp, tag, title, title, "OK", "Cancel", "")) {
		save_var bufnum = tmp;
		pos = tag_line_to_position(lines_between(0, point, 0) + 1, NULL);
		restore_vars();
		point = oldpoint;
		quiet_set_bookmark();
		point = pos;
		position_to_tag_line();
	} else
		point = oldpoint, window_start = old_ws;
	buf_delete(tmp);
	buf_delete(tags);
}

undo_it(is_undo, group_movements)
{
	int ret, before_count;
	char msg[200], *name = is_undo ? "un" : "re", *spec = 0;
	int orig_nar_start = narrow_start;
	int orig_nar_end = narrow_end;

	if (undo_count(is_undo) < 1)
		error("Nothing to %sdo.", name);
	before_count = undo_count(0);
	if (!before_count)
		_buffer_saved_here = -1;
	if (!undo_keeps_narrowing)
		narrow_start = narrow_end = 0;
	*name = tolower(*name);
	if (group_movements)
		ret = undo_group_movements(is_undo);
	else					/* plain undo */
		ret = undo_op(is_undo);
	narrow_start = orig_nar_start;
	narrow_end = orig_nar_end;
	if ((point < orig_nar_start || point > size() - orig_nar_end)
		  && !undo_keeps_narrowing) {
		say("Undoing outside narrowed region, removing narrowing.");
		narrow_start = narrow_end = 0;
	}
	*name = toupper(*name);
	if (ret & UNDO_FLAG)
		switch (undo_flag) {
			case UNDO_READ_FILE:	spec = "Buffer read from disk";
									break;
			case UNDO_WRITE_FILE:	spec = "Buffer written to disk";
									break;
			case UNDO_UNMODIFIED:	spec = "Buffer was marked unmodified";
									break;
		}
	if (spec) {
		sprintf(msg, "%s, ", spec);
		if (_buffer_saved_here == -1)
			_buffer_saved_here = undo_count(0);
		if (undo_count(0) == _buffer_saved_here || before_count == _buffer_saved_here)
			modified = 0;
	} else if (ret & (UNDO_CHANGES | UNDO_MOVE | UNDO_REDISP | UNDO_MAINLOOP))
		sprintf(msg, "%sdid %s%s%s%s%s%s%s",
				name,
				(ret & UNDO_END ? "Partial " : ""),
				(ret & UNDO_MAINLOOP ? "Command, " : ""),
				(ret & UNDO_REDISP ? "Display, " : ""),
				(ret & UNDO_MOVE ? "Move, " : ""),
				(ret & UNDO_INSERT ? "Insert, " : ""),
				(ret & UNDO_DELETE ? "Delete, " : ""),
				(ret & UNDO_REPLACE ? "Replace, " : ""));
	else
		sprintf(msg, "%sdid, ", name);
	show_text(0, 1, "%s%d bytes remain", msg, undo_count(is_undo));
	return ret;
}

#include "unicode.e"

uniq_lines_match(a, b)
{
	int i, ca, cb;

	if (!case_fold) {
		for (i = 0; character(a + i) == character(b + i); i++)
			if (character(a + i) == '\n')
				return 1;
		return 0;
	}
	for (i = 0; (ca = character(a + i)) >= 0 && (cb = character(b + i)) >= 0
			 && _srch_case_map[ca] == _srch_case_map[cb]; i++)
		if (ca == '\n')
			return 1;
	return 0;
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

color_class vbasic_function = color_class c_keyword;
color_class vbasic_identifier = color_class c_identifier;

#include "filter.h"

/*
Load this file to update your Epsilon state file to this version.
*/

when_loading()
{
	if (state_file && get_file_read_only(state_file) == 1) {
		save_var bufnum = zap(HELPBUF);
		if (strcmp(eel_version, EEL_MINOR_VERSION))
			bprintf("%s is read-only.\n"
					"Therefore it cannot be updated.\n"
					"The above state file is for Epsilon version %s.\n"
					"This Epsilon executable is from Epsilon version %s.\n"
					"Perhaps EPSPATH is set incorrectly?\n",
					state_file, eel_version, EEL_MINOR_VERSION);
		else
			bprintf("%s is read-only.\n"
					"Therefore it cannot be updated.\n"
					"But this Epsilon executable is from version %s,\n"
					"and so is the above state file.\n"
					"Therefore it appears no update is needed.\n",
					state_file, eel_version);
		view_help(" Update Not Performed ", 0);
		return;
	}

	// Load or autoload these as appropriate.
	update_autoload("perl-mode", "perl");
	update_autoload("vbasic-mode", "vbasic");
	update_autoload("python-mode", "python");
	update_autoload("hex-mode", "hex");
	update_autoload("info", "info");

	if (strchr(eel_version, 'b')) {		// From a beta version.
		if (strcmp("11.00b2", eel_version) >= 0) {
			new_c_comments = 1;	// Only update when going from 11b2 or earlier.
			reg_tab[GREYBACK] = find_index("backward_delete_character");
			drop_name("unicode-translation-type");
		}
		if (strcmp("11.00b3", eel_version) >= 0) {	// Only for b3 or earlier.
			html_other_coloring = 1;
			drop_name("latin1-to-unicode");
			drop_name("unicode-to-latin1");
			drop_name("ask-unicode-latin1-translate");
			drop_name("maybe-unicode-latin1-translate");
			drop_name("test-unicode-latin1-translate");
			drop_name("unicode-latin1-translate");
			
		}
		if (strcmp("11.00b4", eel_version) >= 0) {	// Only for b4 or earlier.
			if (c_look_back < 100000)
				c_look_back = 100000;
		}
		if (strcmp("11.00b5", eel_version) >= 0) {	// Only for b5 or earlier.
			process_warn_on_exit = 0;
		}
	}

	strcpy(eel_version, EEL_MINOR_VERSION);
	delay(1, COND_KEY);	// Make sure the X window is up.
	refresh();
	sayput("Update complete, preparing to write state file...");
	delay(300, COND_KEY);	// Give the user a chance to abort.
	check_abort();
	if (!*state_file)
		write_state();		// Prompt for name.
	else
		do_save_state(state_file);	// Rewrite current state file.
	exit();
}

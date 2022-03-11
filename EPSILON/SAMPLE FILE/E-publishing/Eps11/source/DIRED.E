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

// This file has dired mode.

#include "eel.h"
#include "dired.h"
#include "colcode.h"
#include "epsnet.h"

when_loading()		/* disable self-inserting chars */
{
	fix_key_table(reg_tab, (short) normal_character, dired_tab, -1);
	set_case_indirect(dired_tab);
}

dired_help() on dired_tab['h'], dired_tab['?']
{
	help_on_command("dired-mode");
}

// If the buffer was manually switched to dired mode, it may lack a
// proper pattern.
char *get_dired_buffer_pattern()
{
	return dired_buffer_pattern ? dired_buffer_pattern : bufname;
}

// Given a prefix like "dired-isdir-", returns an index to
// the subroutine dired-isdir-unix when the buffer has a Unix-style
// directory list, dired-isdir-simple when the buffer has that format
// of directory list, or NULL if the buffer isn't from an FTP or the
// appropriate function doesn't exist.  Func is nonzero if the item
// should be a subroutine, or 0 if it should be a variable.

int get_dired_item(char *prefix, int func)
{
	char item[100];
	int i;

	strcpy(item, prefix);
	switch (dired_format) {
		case DF_UNIX:		strcat(item, "unix"); break;
		case DF_SIMPLE:		strcat(item, "simple"); break;
		case DF_OLDNT:		strcat(item, "oldnt"); break;
		case DF_VMS:		strcat(item, "vms"); break;
		default:			return 0;
	}
	i = find_index(item);
	switch (name_type(i)) {
		case NT_COMMAND: case NT_SUBR:
		case NT_AUTOLOAD: case NT_AUTOSUBR:
			if (func)
				return i;
			break;
		case NT_VAR: case NT_BUFVAR:
		case NT_WINVAR:
			if (!func)
				return i;
			break;
	}
	return 0;
}

dired_examine() on dired_tab[' '], dired_tab['\n'],
		   dired_tab['e'], dired_tab['\r'], dired_tab[GREYENTER]
{
	char fname[FNAMELEN];

	dired_getname(fname, 1);
	do_dired_examine(fname, dired_isdir());
	iter = 0;
}

dired_parent() on dired_tab['^'], dired_tab['.']
{				/* view parent directory */
	char fname[FNAMELEN];

	to_begin_line();
	dired_try_getdir(fname, 1);
	strcat(fname, "..");
	do_dired_examine(fname, 1);
	iter = 0;
}

do_dired_examine(fname, isdir)
char *fname;
{
	char file[FNAMELEN], *p;

	save_var file_pattern_wildcards = 0;	// []'s etc in file name are literal.
	strcpy(file, fname);
	absolute(file);
	if (isdir == 3 && !is_remote_file(file))
		isdir = 0;	// symbolic link to a local file; get directly
	if (isdir) {
		if (is_remote_file(file) && isdir == 1
			&& is_path_separator(file[strlen(file) - 1]) != 1)
			strcat(file, "/");	// If dir, not link, add /.
		if (dired_one(file) || is_remote_file(file))
			return;
		strcpy(file, fname);
		p = get_tail(file, 0);	/* for .., go to right place */
		if (p > file && strcmp(p, "..") == 0) {
			p[-(opsys != OS_UNIX)] = 0;	// Remove / too unless Unix.
			p = get_tail(file, 0);
			strcat(p, "\n");
			col_search(p, goal_column);
			move_to_column(goal_column);
			build_first = 1;
		}
	} else			/* regular file */
		find_it(file, ask_line_translate());
}

dired_examine_in_window() on dired_tab['1'], dired_tab['2'],
				dired_tab['5'], dired_tab['z']
{		/* do appropriate window cmd, then examine */
	int olditer = iter, oldarg = has_arg;

	has_arg = iter = 0;
	do_command(cx_tab[key]);
	iter = olditer, has_arg = oldarg;
	ungot_key = 'e';
}

dired_examine_in_next_window() on dired_tab['o']
{
	char fname[FNAMELEN];
	int isdir;

	dired_getname(fname, 1);
	isdir = dired_isdir();
	if (number_of_user_windows() == 1)
		window_split(HORIZONTAL);
	next_user_window(1);
	do_dired_examine(fname, isdir);
	iter = 0;
}

dired_refresh() on dired_tab['r']
{
	char msg[FNAMELEN];
	int yes, remote;

	if (modified) {
		sprintf(msg, "Relist %s, discarding markings? ", bufname);
		yes = ask_yn("Discard markings", msg, "Yes", "No", 1);
		check_abort();
		if (!yes)
			return;
	}
	remote = is_remote_file(get_dired_buffer_pattern());
	if (remote)
		point = 0;
	else
		save_var point, window_start;
	create_dired_listing(get_dired_buffer_pattern());
	restore_vars();
	if (!remote)
		move_to_column(goal_column);
	dired_orig_position = point;
	fix_window_start();
}

dired_create_directory() on dired_tab['+']
{
	do_create_directory(1);
}

do_create_directory(int in_dired)
{
	char dir[FNAMELEN], cmd[FNAMELEN], url[FNAMELEN];

	if (!prompt_with_buffer_directory)
		save_var prompt_with_buffer_directory = 2;
	get_file_dir(dir, "Create directory: ");
	if (is_remote_file(dir)) {
		if (in_dired)
			dired_getdir(url);
		else
			strcpy(url, dir);
		sprintf(cmd, "MKD %s", get_url_file_part(dir, 0));
		ftp_misc_operation(url, cmd);
		say("Operation queued.");
	} else {
		mkdir(dir);
		if (is_dired_buf())
			dired_refresh();
	}
}

do_shell_command(char *file, char *dir)
{
	char cmd[FNAMELEN], cmdline[FNAMELEN], buf[FNAMELEN], pr[FNAMELEN];

	sprintf(pr, "! on %s: ", get_tail(file, 0));
	get_string(cmd, pr);
	sprintf(buf, "shell-output-%s-%s", cmd, get_tail(file, 0));
	sprintf(cmdline, opsys == OS_UNIX ?"%s '%s'" : "%s \"%s\"", cmd, file);
	if (opsys == OS_UNIX) {
		pipe_text(NULL, buf, cmdline, dir,
				  PIPE_SYNCH | PIPE_CLEAR_BUF | PIPE_NOREFRESH, 0);
		if (buffer_size(buf)) {
			to_buffer(buf);
			point = 0;
		}
	} else
		do_push(cmdline, 1, 1);
}

dired_shell_command() on dired_tab['!']
{
	char dir[FNAMELEN], file[FNAMELEN];

	dired_getname(file, 1);
	dired_getdir(dir);
	do_shell_command(file, dir);
}

dired_sort() on dired_tab['s']
{
	char *p, msg[200];
	int rev, sort;

	if (dired_format == DF_VMS)
		error("Sorting VMS directories not supported.");
	rev = isupper(dired_sorts_files);
	switch (sort = toupper(dired_sorts_files)) {
		case 'N': case 'D': case 'S':  case 'E': 
			break;
		case 0: case 'U':
			sort = 'U', rev = 0; break;
		default:
			sort = 'N';
	}
	for (;;) {
		strcpy(msg, "Name, Ext, Size, Date, Unsorted,");
		p = index(msg, sort);
		p = index(p, ',');
		msg[strlen(msg) - 1] = 0;
		sayput("Sort by %.*s (now)%s; Reverse; %sGroup dirs"
			   " [NESDURG] ", p - msg, msg, p,
			   dired_groups_dirs ? "un" : "");
		getkey();
		check_abort();
		switch (toupper(key)) {
			case 'N':
			case 'D':
			case 'S':
			case 'E': sort = toupper(key); break;
			case 'U': say("Future listings will be unsorted.");
					  sort = 0; break;
			case 'R': rev = !rev; break;
			case '+': rev = 0; break;
			case '-': rev = 1; break;
			case 'G': dired_groups_dirs = !dired_groups_dirs;
					  break;
			default:  if (IS_ENTER_KEY(key))
						  break;
					  else if (binding_of(key, root_keys) == (short) help
							   || key == 'h' || key == '?')
						  help_on_command("dired-sort");
					  continue;
		}
		break;
	}
	dired_sorts_files = rev ? toupper(sort) : tolower(sort);
	if (sort) {
		sprintf(msg, "%s%s, %s", rev ? "Reverse " : "",
				(sort == 'N') ? "Name" : (sort == 'E') ? "Extension"
			: (sort == 'S') ? "Size" : "Date",
				dired_groups_dirs ? "grouping directories at top"
								  : "not grouping directories");
		noteput("Sorting...");
		sort_for_dired();
		say("Sorted by %s.", msg);
	} else
		say("Future listings will be unsorted.");
	maybe_refresh();
}

dired_live_link() on dired_tab['l']
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

dired_repl(newchar)
{
	to_begin_line();
	if (parse_string(1, SKIPLINEPAT))
		nl_forward();
	if (index("DCMULR ", curchar()) && character(point + 1) == ' ')
		replace(point, newchar);
	save_var iter = 1;		// call us to do each repetition
	dired_down_line();
}

dired_mark_for_delete() on dired_tab['d']
{
	dired_repl('D');
}

dired_mark_for_copy() on dired_tab['c']
{
	if (is_remote_file(get_dired_buffer_pattern()))
		error("Copy operation not implemented for remote files.");
	dired_repl('C');
}

dired_mark_for_move() on dired_tab['m']
{
	dired_repl('M');
}

dired_mark_for_uppercase() on dired_tab['U']
{
	dired_repl('U');
}

dired_mark_for_lowercase() on dired_tab['L']
{
	dired_repl('L');
}

dired_mark_for_regex_rename() on dired_tab['R']
{
	dired_repl('R');
}

dired_unmark() on dired_tab['u']
{
	dired_repl(' ');
}

dired_do_uppercase(name, to, in_dired)	/* return 1 if error */
char *name, *to;
{
	char newname[FNAMELEN];

	strcpy(newname, name);		// Rename file to uppercase.
	for (to = get_tail(newname, 0); *to; to++)
		*to = toupper(*to);
	return dired_do_move(name, newname, in_dired);
}

dired_do_lowercase(name, to, in_dired)	/* return 1 if error */
char *name, *to;
{
	char newname[FNAMELEN];

	to = to;
	strcpy(newname, name);		// Rename file to lowercase.
	for (to = get_tail(newname, 0); *to; to++)
		*to = tolower(*to);
	return dired_do_move(name, newname, in_dired);
}

dired_do_delete(name, to, in_dired)	/* return 1 if error */
char *name, *to;
{
	int isdir = in_dired ? dired_isdir() : 0;

	to = to;
	if (is_remote_file(name)) {
		buffer_printf(REMOTE_FTP_OP_BUFFER,
					  isdir ? "RMD %s\n" : "DELE %s\n",
					  get_url_file_part(name, 0));
	} else {
		if (in_dired)
			noteput("Deleting %s.", name);
		if ((isdir && dired_isdir() == 1) ? rmdir(name) : delete_file(name))
			return 1;
	}
	if (in_dired) {
		save_var modified;	// leave modify bit alone
		to_begin_line();	// but delete line
		delete(point - 1, give_end_line());
	}
	return 0;
}

/* Return 1 if error, 2 if we didn't do it but already showed error. */
dired_do_copy(name, to, in_dired)
char *name, *to;
{
	char dest[FNAMELEN];

	make_copy_name(name, to, dest);
	if (is_remote_file(name)) {
		if (!in_dired)
			noteput("Copy operation not implemented for remote files.");
		return 2;
	}
	if (in_dired)
		noteput("Copying %s to %s.", name, dest);

	if (!strcmp(name, dest) || warn_existing_file(dest))
		return 2;
	if (copyfile(name, dest))
		return 1;	// disallow copying file to itself
	if (in_dired) {
		save_var modified;	// leave modify bit alone
		dired_unmark();
		nl_reverse();
	}
	return 0;
}

/* Return 1 if error, 2 if we didn't do it but already showed error. */
dired_do_move(name, to, in_dired)
char *name, *to;
{
	char dest[FNAMELEN];

	make_copy_name(name, to, dest);
	if (is_remote_file(name)) {
		buffer_printf(REMOTE_FTP_OP_BUFFER, "RNFR %s\nRNTO %s\n",
				get_url_file_part(name, 0), get_url_file_part(dest, 0));
	} else {
		if (in_dired)
			noteput("Moving %s to %s.", name, dest);
		if (rename_file(name, dest)) {
			if (!strcmp(name, dest) || warn_existing_file(dest))
				return 2;
			if (copyfile(name, dest))
				return 1;
			if (delete_file(name))
				return 1;
		}
	}
	if (in_dired) {
		save_var modified;	// leave modify bit alone
		to_begin_line();	// but delete line
		delete(point - 1, give_end_line());
	}
	return 0;
}

make_copy_name(src, dest, res)	// if dest is a dir, append src to it
char *src, *dest, *res;		// else copy dest
{
	int remote = is_remote_file(dest);

	strcpy(res, dest);
	if (remote ? is_path_separator(res[strlen(res) - 1])
			   : is_directory(res)) {
		dest = res + strlen(res);
		if (*res && !is_path_separator(dest[-1]))
			*dest++ = remote ? '/' : path_sep;
		strcpy(dest, get_tail(src, 0));
	}
}

// Confirm each change to be made, then make it.
dired_do_regex_rename(name, to, in_dired)	/* return 1 if error */
char *name, *to;
{
	char newname[FNAMELEN];
	int tmp = tmp_buf();

	strcpy(to = newname, name);
	if (!dired_regex_rename_data->whole_name)
		to = get_tail(newname, 0);	// Leave the dir name alone.
	save_var bufnum = tmp;
	stuff(to);
	point = 0;
	save_var abort_searching = ABORT_ERROR;
	string_replace(dired_regex_rename_data->str, dired_regex_rename_data->with,
				   dired_regex_rename_data->flags & ~INCR);
	grab(0, size(), to);
	restore_vars();
	buf_delete(tmp);
	if (user_abort)
		return 0;
	if (dired_regex_rename_data->prompt) {
		sayput("Rename %s to %s? [Y, N, ! for all] ",
			   get_tail(name, 1), get_tail(newname, 1));
		for (;;) {
			getkey();
			if (user_abort)
				return 0;
			if (IS_ENTER_KEY(key))
				key = 'Y';
			switch (toupper(key)) {
				case 'N':	return 1;
				case '!':	dired_regex_rename_data->prompt = 0;
				case 'Y':	break;
				default:	continue;	// loop
			}
			break;		// user said yes
		}
	}
	return dired_do_move(name, newname, in_dired);
}

// Ask for search/replace patterns to transform each file name.
char *dired_prompt_regex_replace()
{
	if (!dired_regex_rename_data)		/* Get space for it. */
		dired_regex_rename_data = (struct dired_regex_rename_data *)
								  malloc(sizeof(struct dired_regex_rename_data));
	dired_regex_rename_data->whole_name = has_arg;
	dired_regex_rename_data->prompt = 1;
	dired_regex_rename_data->flags = get_replace_text(REGEX,
		dired_regex_rename_data->with);
	strncpy(dired_regex_rename_data->str,
			default_search_string(dired_regex_rename_data->flags), FNAMELEN - 1);
	return NULL;
}

// If the buffer of operations is nonempty, start executing it.

send_remote_ftp_op(char *url)
{
	char *p;

	if (!exist(REMOTE_FTP_OP_BUFFER))
		return;
	save_var bufname = REMOTE_FTP_OP_BUFFER;
	delete_final_newlines();
	if (!size())
		return;
	p = malloc(size() + 1);
	grab(0, size(), p);
	ftp_misc_operation(url, p);
	free(p);
	say("Operation queued.");
}

dired_execute() on dired_tab['q'], dired_tab['x']
{
	char url[FNAMELEN];
	int del, copy, move, uc, lc, rr;

	if (is_remote_file(get_dired_buffer_pattern()) && exist(REMOTE_FTP_OP_BUFFER))
		zap(REMOTE_FTP_OP_BUFFER);
	del = dired_do_no_param("Delete", "\nD ", "deleted", dired_do_delete, 0);
	copy = dired_do_param("Copy", "\nC ", "copied", dired_do_copy);
	move = dired_do_param("Move", "\nM ", "moved", dired_do_move);
	uc = dired_do_no_param("Uppercase", "\nU ", "uppercased",
						   dired_do_uppercase, 0);
	lc = dired_do_no_param("Lowercase", "\nL ", "lowercased",
						   dired_do_lowercase, 0);
	rr = dired_do_no_param("Regex-rename", "\nR ", "regex-renamed",
							 dired_do_regex_rename, dired_prompt_regex_replace);
	if (del + copy + move + uc + lc + rr == 0)
		error("No files marked");
	modified = 0;
	if (!is_remote_file(get_dired_buffer_pattern()) && (move + copy + uc + lc + rr))
		dired_refresh();	// could be rename or similar, make new listing
	if (is_remote_file(get_dired_buffer_pattern())) {
		dired_getdir(url);
		send_remote_ftp_op(url);
	}
	fix_window_start();
	iter = 0;
}

dired_do_no_param(op, tag, past, func, extra)
char *op, *tag, *past, *(*extra)();
int (*func)();
{
	int count = dired_ask(op, tag, "? ", NULL);

	if (count > 0)
		dired_do(past, tag, count, func, extra ? (*extra)() : NULL);
	return count;
}

dired_do_param(op, tag, past, func)
char *op, *tag, *past;
int (*func)();
{
	char to[FNAMELEN];
	int count = dired_ask(op, tag, " to: ", to);

	if (count > 1 && !is_remote_file(to))	// can only copy/move mult
		switch (check_file(to, NULL)) {		// to a dir
		case 0:		if (mkdir(to)) {
					file_error(errno, to, "make dir");
					quick_abort();
				}
		case CHECK_DIR:	break;
		default:	error("%s is not a directory.", to);
		}
	if (count > 0)
		dired_do(past, tag, count, func, to);
	return count;
}

dired_ask(op, tag, end, file)	// make list of files, confirm/get param if any
char *op, *tag, *end, *file;	// return count or 0 if none were marked
{
	int list = tmp_buf(), count = 0;
	char msg[FNAMELEN], name[FNAMELEN];

	save_var point = 0;
	save_var abort_searching = ABORT_ERROR;
	while (search(1, tag) == 1) {
		dired_getname(name, 3);
		count++;
		if (count > 1)
			sprintf(msg, "%s these %d files%s", op, count, end);
		else
			sprintf(msg, "%s this file%s", op, end);
		if (count > 1 && !(is_gui && want_gui_prompts))
			note(msg);
		buf_printf(list, "%s\n", name);
	}
	restore_vars();

	if (!count) {
		buf_delete(list);
		return 0;
	} else if (count == 1 && (!(is_gui && want_gui_prompts) || file)
			   && strlen(name) < screen_cols / 2)
		sprintf(msg, "%s file %s%s", op, name, end);
	else {
		if (!(is_gui && want_gui_prompts) || file)
			say(msg);
		sprintf(name, " Files to %s ", op);
		save_var _view_title = (is_gui && want_gui_prompts && !file)
							   ? msg : name;
		buf_delete_final_newlines(list);
		save_var paging_retains_view = 1;
		view_buf(list, 0);
	}
	save_var prompt_with_buffer_directory = PBD_INSERT;
	if (is_gui && want_gui_prompts && key == abort_key)
		file = 0, *name = 'N';		// User clicked Cancel.
	else if (file) {
		get_file_dir(file, msg);
		if (count > 1 && is_remote_file(file)
			&& !is_path_separator(file[strlen(file) - 1]))
			strcat(file, "/");
	} else if (is_gui && want_gui_prompts) {	// Already prompted so don't
		*name = toupper(key) == 'Y' || IS_ENTER_KEY(key) // ask again.
				|| toupper(key) == 'O' ? 'Y' : 'N';
		ungot_key = -1;
	} else
		get_string(name, msg);
	buf_delete(list);
	if (file ? *file : (toupper(*name) == 'Y'))
		return count;
	error("No action taken.");
}

dired_do(op, tag, count, func, to)
char *op, *tag, *to;
int (*func)();
{
	spot final;
	int bad = 0;
	char name[FNAMELEN];

	final = alloc_spot();
	point = 0;
	save_var abort_searching = 0;
	while (search(1, tag)) {
		if (user_abort) {
			if (!bad)
				*final = point;
			break;
		}
		dired_getname(name, 3);
		if ((*func)(name, to, 1))
			if (!bad++)		/* error occurred */
				*final = point;	/* 1st error */
	}
	point = *final;
	free_spot(final);
	move_to_column(goal_column);
	if (bad)
		error("%d of %d file%s not %s", bad, count,
			count != 1 ? "s" : "", op);
	say("%d file%s %s", count, count != 1 ? "s" : "", op);
}

dired_del_line()	/* delete current line, leave modify bit alone */
{
	save_var modified;	// leave modify bit alone
	to_begin_line();	// but delete line
	delete(point, give_end_line() + 1);
}

do_shell_execute(char *fname, char *op, char *descr)
{
	char dirname[FNAMELEN];

	strcpy(dirname, fname);
	*get_tail(dirname, 1) = 0;
	if ( run_viewer(fname, op, dirname) == 0)
		say("Could not %s for \"%s\"", descr, fname);
}

dired_run_viewer() on dired_tab['v']
{
	char fname[FNAMELEN];

	dired_getname(fname, 1);
	do_shell_execute(fname, "Open", "run viewer");
}

dired_show_properties() on dired_tab['t']
{
	char fname[FNAMELEN];

	dired_getname(fname, 1);
	do_shell_execute(fname,  "Properties", "show properties");
}

dired_goto_dir() on dired_tab['g']
{
	char fname[FNAMELEN];

	dired_getname(fname, 1);
	if (chdir(fname) && (dired_try_getdir(fname, 1), chdir(fname)))
		file_error(errno, fname, "unknown error");
	else {
		getcd(fname);
		say("Current directory: %s", fname);
	}
	iter = 0;
}

dired_print() on dired_tab['P']
{
	char fname[FNAMELEN];
	int had, old = window_bufnum, err = 0, repeated = has_arg, newbuf;

	save_var has_arg = 0, iter = 1;
	dired_getname(fname, 1);
	had = look_file(fname);
	if (had)
		to_buffer(bufname);
	else
		err = find_in_other_buf(fname, ask_line_translate());
	newbuf = bufnum;
	if (!err)
		err = do_print_region(bufnum, 1, repeated);
	to_buffer_num(old);
	if (!had)
		buf_delete(newbuf);
	if (err)
		quick_abort();
}

command quick_dired_command() on reg_tab[ALT('o')]
{
	char file[FNAMELEN], rel[FNAMELEN], msg[FNAMELEN], dest[FNAMELEN];
	char dir[FNAMELEN];

	strcpy(file, filename);
	strcpy(dir, filename);
	*get_tail(dir, 0) = 0;
	if (!*file)
		error("This buffer has no associated file.");
	strcpy(rel, get_tail(file, 0));
again:
	do {
		sayput("%s: D=Delete, Move, Copy, View, T=Props, .=Dired, "
			   "G=Go dir, ?=Show more: ", rel);
		getkey();
		check_abort();
	} while (!IS_TRUE_KEY(key));
	say("");
	if (is_remote_file(file) && exist(REMOTE_FTP_OP_BUFFER))
		zap(REMOTE_FTP_OP_BUFFER);
	switch (toupper(key)) {
		case '.':
			dired_one(file);
			break;
		case 'D':
			sprintf(msg, "Delete %s? ", rel);
			if (!ask_yn("Delete file", msg, "Delete", "Cancel", 1))
				break;
			if (dired_do_delete(file, NULL, 0))
				file_error(errno, file, "Could not delete");
			else if (!is_remote_file(file))
				say("%s deleted.", file);
			break;
		case 'C':
			if (is_remote_file(file))
				error("Copy operation not implemented for remote files.");
			sprintf(msg, "Copy %s to: ", rel);
			get_file_dir(dest, msg);
			if (*dest) {
				switch (dired_do_copy(file, dest, 0)) {
					case 1:
						file_error(errno, dest, "Could not copy");
						break;
					case 0:
						say("%s copied.", file);
						break;
				}
			}
			break;
		case 'M':
			sprintf(msg, "Move %s to: ", rel);
			get_file_dir(dest, msg);
			if (*dest) {
				if (dired_do_move(file, dest, 0))
					file_error(errno, dest, "Could not move");
				else if (!is_remote_file(file))
					say("%s moved.", file);
			}
			break;
		case 'V':
			do_shell_execute(file, "Open", "run viewer");
			break;
		case 'T':
			do_shell_execute(file,  "Properties", "show properties");
			break;
		case 'F':
			do_shell_execute(dir, "Open", "run viewer");
			break;
		case 'G':
			if (chdir(dir))
				file_error(errno, dir, "unknown error");
			else {
				getcd(dir);
				say("Current directory: %s", dir);
			}
			break;
		case '+':
			do_create_directory(0);
			break;
		case '!':
			do_shell_command(file, dir);
			break;
		default:
			if (key == '?' || key == HELPKEY || key == FKEY(1))
				help_on_command("quick-dired-command");
			else
				say("Invalid key.");
			goto again;
	}
	if (is_remote_file(file))
		send_remote_ftp_op(file);
}

dired_down_line() on dired_tab['n']
{
	down_line();
	to_begin_line();
	while (parse_string(1, SKIPLINEPAT))
		nl_forward();
	move_to_column(goal_column);
}

dired_up_line() on dired_tab['p']
{
	up_line();
	to_begin_line();
	while (parse_string(1, SKIPLINEPAT)) {
		if (!nl_reverse())
			break;
		to_begin_line();
	}
	move_to_column(goal_column);
}

dired_getdir(fullname)	// grab directory, add / to end, for completion
char *fullname;		// set fullname to "" if error
{
	return dired_try_getdir(fullname, 0);
}

dired_try_getdir(fullname, showerr)	// grab directory, add / or \ to end
char *fullname;		// if we can't find, set fullname "" if !showerr
{			// return nonzero if ok
	int i;
	char *p, path_char;

	*fullname = 0;
	save_var point;
	to_end_line();
	if (!re_search(-1, DIRLINEPAT))	// find prev "Directory of "
		if (showerr)		// bad dired buf
			error("Can't determine directory of files");
		else
			return 0;
	point = matchstart;
	re_search(1, " *");		// skip initial spaces
	parse_string(1, FILECHARS, fullname);
	p = fullname + (i = strlen(fullname));
	path_char = is_remote_file(fullname) ? '/' : path_sep;
	if (i > 0 && !is_path_separator(fullname[i - 1]))
		p[0] = path_char, p[1] = 0; // add final / or \ if none
	return 1;
}

// Get name of file/dir on current line and return 1.  If none, return 0
// (or, if flags&1, abort with error).  Return destination of a
// symbolic link unless flags&2.

int dired_getname(char *fullname, int flags)
{
	char *p, *q;

	dired_try_getdir(fullname, 1);
	p = fullname + strlen(fullname);
	dired_getindex(p, goal_column);		/* the file name */
	to_begin_line();
	if (parse_string(1, SKIPLINEPAT))  /* on dir line, make name illegal */
		*p = 0;
	move_to_column(goal_column);
	if (!*p || isspace(*p))
		if (flags & 1)
			error("Can't read file name");
		else
			return 0;
	q = strstr(p, " -> ");			// replace file name with link dest
	if (q)
		if (flags & 2)
			*q = 0;
		else
			strcpy(p, q + 4);
	if (is_path_separator(*p) == 1)	// If link dest starts with /,
		strcpy(get_url_file_part(fullname, 0), p);	// just use that.
	if (dired_format == DF_SIMPLE) {
		q = index(fullname, ' ');		// Remove stuff after file name.
		if (q)
			*q = 0;
	} else if (dired_format == DF_VMS) {
		q = index(fullname, ' ');		// Remove stuff after file name.
		if (q)
			*q = 0;
		q = strstr(fullname, ".DIR;");	// Refer to directories without
		if (q)							// .DIR extension to see contents.
			*q = 0;
		q = strstr(fullname, ";");		// Remove version number.
		if (q && isdigit(q[1]))
			*q = 0;
	}
	p += strlen(p) - 1;		// Unix file name might use "ls -F" format
	if (*p == '/' || *p == '*')
		*p = 0;
	return 1;
}

// Look for continuation lines in VMS directory listing, combine.

dired_vms_fix_lines()
{
	save_var modified;
	simple_re_replace(1, "\n                    ", "");
}

// Look for extra-wide columns in Unix directory listing, repair.

dired_unix_fix_lines()
{
	save_var modified, indent_with_tabs = 0;
	right_align_columns("[0-9]+ *" UNIX_DATE);
	right_align_columns(UNIX_DATE);
	save_var point = 0;
	if (re_search(1, ".*" UNIX_DATE))
		goal_column = current_column();
}

// Return 3 if symbolic link to file, 2 if symbolic link to dir, 1 if
// actual dir, else 0.  Unix-specific version.

dired_isdir_unix()
{
	save_var point;
	to_begin_line();
	save_var case_fold = 1;
	if (!parse_string(1, dired_dirsearch_unix))
		return 0;
	switch (character(matchend - 1)) {
		case 'l':	return 3;
		case 'L':	return 2;
	}
	return 1;
}

// Return 3 if symbolic link to file, 2 if symbolic link to dir, 1 if
// actual dir, else 0.

dired_isdir()
{
	char buf[FNAMELEN];
	int i;

	i = get_dired_item("dired-isdir-", 1);
	if (i)
		return (*(int (*)())i)();
	i = get_dired_item("dired-dirsearch-", 0);
	if (i) {
		save_var point;
		to_begin_line();
		return parse_string(1, get_str_var(i)) != 0;
	}
	dired_getindex(buf, ISDIR_START);
	return !strncmp(buf, DIRMARK, strlen(DIRMARK));
}

dired_getindex(s,i)	/* put current line in s, starting at column i */
char *s;
{
	save_var point;
	move_to_column(i);
	re_search(1, " *");		/* skip initial spaces */
	parse_string(1, FILECHARS, s);
}

is_dired_buf()		/* is the current buffer a dired buffer? */
{
	return mode_keys == dired_tab;
}

color_dired_range(from, to)
{
	int color, namecolor, old, namestart, nameend, isdir;
	char buf[FNAMELEN];

	if (from >= to)
		return to;
	detect_dired_format();
	save_var point, matchstart, matchend;
	point = from;
	save_var narrow_start = give_begin_line();
	point = to;
	nl_forward();
	save_var narrow_end = size() - point;
	point = 0;
	while (point < size() - narrow_end) {
		switch (curchar()) {
			case 'D': color = color_class dired_deleted; break;
			case 'U': case 'L': case 'R':
			case 'M': color = color_class dired_moved; break;
			case 'C': color = color_class dired_copied; break;
			default: color = color_class dired_normal; break;
		}
		old = point;
		if (parse_string(1, SKIPLINEPAT) != 0) {
			color = color_class dired_header;
			namestart = matchend;
			nameend = give_end_line();
			namecolor = color_class dired_dir_name;
		} else {
			dired_getindex(buf, goal_column);
			namestart = matchstart;
			nameend = matchend;
			namecolor = color_class dired_file_name;
			if (dired_format == DF_VMS)
				nameend = point + parse_string(1, "[^\n;]*;?[0-9]*");
			isdir = dired_isdir();
			if (isdir) {
				namecolor = color_class dired_dir_name;
				if (!dired_format)
					namestart = column_to_pos(ISDIR_START);
				if (isdir == 3)
					nameend = point + parse_string(1, ".* -> ");
			}
			if (!is_remote_file(get_dired_buffer_pattern())
				  && character(namestart - 1) == ' ')
				namestart--;
		}
		nl_forward();
		set_character_color(old, point - 1, color);
		set_character_color(namestart, nameend, namecolor);
	}
	return point;
}

command dired() on cx_tab['d']
{
	char dir[FNAMELEN];

	tiled_only();
	get_file_dir(dir, "Edit directory: ");
	if (was_quoted)		// []'s etc in file name are literal.
		save_var file_pattern_wildcards = 0;
	return dired_one(dir);
}

detect_dired_format()
{
	int old = dired_format;

	dired_format = 0;
	goal_column = NAME_START;
	save_var point = 0, case_fold = 1;
	while (parse_string(1, SKIPLINEPAT))
		nl_forward();
	if (point >= size())
		return;
	if (parse_string(1, ".*" UNIX_DATE)) {
		dired_format = DF_UNIX;
		goal_column = get_column(matchend);
	} else if (parse_string(1, ".*" OLDNT_DATE)) {
		dired_format = DF_OLDNT;
		goal_column = 41;
	} else if (parse_string(1, ".*" VMS_DATE)) {
		dired_format = DF_VMS;
		goal_column = 2;
	} else if (!parse_string(1, ". [ 0-9][0-9]-[a-z?][a-z?][a-z?]-[0-9][0-9]")) {
		dired_format = DF_SIMPLE;
		goal_column = 2;
	}
	if (dired_format != old)
		drop_all_colored_regions();
}

char _dired_mode_name[] = "Dired";

dired_mode()
{
	mode_keys = dired_tab;
	major_mode = _dired_mode_name;
	mouse_dbl_selects = 1;
	detect_dired_format();
	recolor_range = color_dired_range;	// set up coloring rules
	recolor_from_here = recolor_by_lines;
	when_setting_want_code_coloring();	// maybe turn on coloring
	discardable_buffer = 1;
	make_mode();
}

dired_one(dir)	/* dir is absolute pathname of directory or pattern */
char *dir;	/* return 0 if ok */
{
	char buf[FNAMELEN], *to;
	int uniq = 1;

	if (is_remote_file(dir))
		standardize_remote_pathname(dir);	// Try to remove . and ..
	if (*dir)
		strcpy(buf, dir);
	else if (prompt_with_buffer_directory) {
		get_buffer_directory(buf);	// this file's directory
		dir = buf;
	} else {
		dir = ".";	/* "" means current directory */
		getcd(buf);
	}
	if (!is_remote_file(buf))
		dired_standardize(buf);		/* fix appropriately for this o/s */
	else {
		standardize_remote_pathname(buf);	// Try to remove . and ..
		standardize_remote_pathname(dir);	// Try to remove . and ..
	}
	to = buf + strlen(buf);
	while (exist(buf)) {	/* make it unique */
		bufname = buf;
		if (is_dired_buf())	/* reuse existing dired buffer */
			break;
		sprintf(to, "<%d>", uniq++);
	}
	to_buffer(buf);
	move_to_column(goal_column);
	if (is_remote_file(buf) && is_dired_buf())
		return 0;			// Don't reread unless user explicitly says to.
	return create_dired_listing(dir);
}

int create_dired_listing(char *dir)
{
	buf_zap(bufnum);
	translation_type = FILETYPE_AUTO;
	dired_mode();
	noteput("Building directory listing...");
	if (make_dired(dir)) {
		say("No matches.");
		return 1;
	}
	say("");
	return 0;
}

dired_ftp_activity(int activity, int buf, int from, int to)
{
	to = to;
	save_var bufnum = buf;
	switch (activity) {
		case NET_DONE:
			detect_dired_format();
			if (dired_format == DF_VMS)
				dired_vms_fix_lines();
			else if (dired_format == DF_UNIX)
				dired_unix_fix_lines();
			if (!modified && point == dired_orig_position)
				sort_for_dired();
			else
				say("Sorting omitted, press S to sort.");
			break;
		case NET_RECV:
			save_spot point = from;
			save_var modified;
			while (re_search(1, "^.")) {
				point--;
				stuff("  ");
				point++;
			}
			break;
		case NET_LOG_WRITE:
			break;
	}
}

do_remote_dired(char *dir)
{
	char plain[FNAMELEN], *p;

	strcpy(plain, dir);
	p = get_tail(plain, 1);	// If name contains wildcards, strip them.
	if (index(p, '*') || index(p, '?'))
		*p = 0;
	buffer_ftp_activity = dired_ftp_activity;
	bprintf("     Directory of %s\n", plain);
	point = modified = 0;
	dired_orig_position = point;
	if (index(dir, '*') || index(dir, '?'))	// Make FTP listing
		save_var ftp_compatible_dirs = 1;	// show just the basename.
	return url_operation(dir, FTP_LIST);
}

make_dired(dir)
char *dir;
{
	char tmp[FNAMELEN];

	modified = 0;
	save_var abort_file_matching = ABORT_JUMP;
	strcpy(tmp, dir);		// Our arg might be a dired_buffer_pattern that we're
	if (dired_buffer_pattern)	// about to delete.
		free(dired_buffer_pattern);
	dired_buffer_pattern = strsave(tmp);
	dir = tmp;
	if (is_remote_file(dir))
		do_remote_dired(dir);
	else if (do_dired(dir))
		return 1;
	detect_dired_format();
	switching_to_buffer();
	modified = 0;
	add_buffer_when_idle(bufnum, dired_when_idle);
	if (!is_remote_file(dir))
		sort_for_dired();
	else {
		to_end_line();
		type_point = size();
	}
	dired_orig_position = point;
	return 0;
}

sort_for_dired()
{
	int start, done = 0, chat = size() - narrow_end - narrow_start > 100000;

	if (dired_format == DF_VMS)
		return;		// Sorting not supported.
	if (chat)
		noteput("Sorting...");
	save_var modified;
	window_start = point = 0;
	save_var abort_searching = 0;
	while (!done) {
		do {			/* skip past . and .. */
			nl_forward();	/* exclude 1st lines */
			move_to_column(goal_column);
		} while (parse_string(1, "<.><.>?[/\\]?($| )"));
		to_begin_line();
		start = point;
		if (re_search(1, SKIPLINEPAT))
			to_begin_line();
		else
			done = 1;
		if (start < point - 1)
			dired_sorter(start, point - (parse_string(-1, "\n\n") ? 1 : 0));
	}
	point = 0;
	dired_down_line();		/* position on 2nd line */
	window_start = 0;
	if (chat)
		say("");
}

dired_sorter(start, end)
{
	int tmp, next;
	char *pat = DIRSEARCH;
	int i = get_dired_item("dired-dirsearch-", 0);

	if (i)
		pat = get_str_var(i);
	save_var case_fold = 1, sort_case_fold = (opsys != OS_UNIX);
	save_var narrow_start = start;
	save_var narrow_end = size() - end;
	if (dired_groups_dirs) {
		save_var point = 0;
		tmp = tmp_buf();
		while (re_search(1, pat) && !user_abort) {
			to_begin_line();
			next = give_end_line() + 1;
			buf_xfer(tmp, point, next);
			delete(point, next);
		}
		dired_group_sorter(start, point);
		point = 0;
		grab_buffer(tmp);
		buf_delete(tmp);
		dired_group_sorter(mark, point);
	} else
		dired_group_sorter(start, end);
}

dired_group_sorter(start, end)
{
	int on_col = goal_column, stripwid = 0, i;

	if (!dired_sorts_files || user_abort)
		return;
	save_var narrow_start = start;
	save_var narrow_end = size() - end;
	save_var point;
	save_var abort_searching = ABORT_ERROR;
	switch (toupper(dired_sorts_files)) {
		case 'D': stripwid = dired_sort_by_date(); break;
		case 'E': stripwid = dired_sort_by_exten(); break;
		case 'S': i = get_dired_item("dired-sort-by-size-", 1);
				  if (i)		// Call style-specific function.
					  stripwid = (*(int (*)())i)();
				  else
					  on_col = SIZE_COL;
				  break;
	}
	do_sort_region(0, size(), on_col, isupper(dired_sorts_files));
	if (stripwid)
		strip_columns(goal_column, goal_column + stripwid);
}

dired_sort_by_size_simple()
{
	say("Sorting by size not supported.");
	return 0;
}

// Insert size in each line, return length.
dired_sort_by_size_unix()
{
	char line[FNAMELEN];

	point = 0;
	while (re_search(1, UNIX_DATE)) {
		point = matchstart;
		if (!parse_string(-1, "[0-9]+ *", line)) {
			note("Unrecognized format, can't sort.");
			strcpy(line, "0");
		}
		move_to_column(goal_column);
		bprintf("%15d", numtoi(line));
		to_end_line();
	}
	return 15;
}

dired_sort_by_date_simple()
{
	say("Sorting by date not supported.");
	return 0;
}

	/* insert numeric sortable date in each line, return length */
dired_sort_by_date_unix()
{
	char line[FNAMELEN], *p, *months, *time;
	int month, year;
	struct time_info now;

	time_and_day(&now);
	months = "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ";
	point = 0;
	while (re_search(1, UNIX_DATE)) {
		grab(matchstart + 1, point, line);
		if (line[3] != ' ' || line[6] != ' ') {
			say("Unrecognized date format, can't sort.");
			strcpy(line, " Jan  1  1970 ");	// Fake default date.
		}
		line[3] = line[6] = 0;	// break into pieces
		p = strstr(months, line);
		if (!p) {
			say("Unrecognized month %s, can't sort.", line);
			p = months;
		}
		month = 1 + (p - months) / 4;	// Compute month 1..12.

		if (line[9] == ':') {	// Either a time (in the last 6 months)...
			time = line + 7;	// Year is this year or late last year.
			year = now.year - (month > now.month + 1);
		} else {			// Or a prior year, so make up a fake time.
			time = "00:00 ";
			year = numtoi(line + 7);
		}
		move_to_column(goal_column);
		bprintf("%5d%02d%2s%5s", year, month, line + 4, time);
		to_end_line();
	}
	return 15;
}


/* insert numeric sortable date in each line, return length */
dired_sort_by_date_oldnt()
{
	char line[FNAMELEN];
	int hour;

	point = 0;
	while (re_search(1, OLDNT_DATE)) {
		grab(matchstart, point, line);
		hour = numtoi(line + 10);
		if (hour == 12)
			hour = 0;
		if (toupper(line[15]) == 'P')
			hour += 12;
		move_to_column(goal_column);
		bprintf("%.2s%.5s%02d%.2s", line + 6,
				line, hour, line + 13);
		to_end_line();
	}
	return 11;
}

dired_sort_by_date()	/* insert stuff in each line, return length */
{
	char line[FNAMELEN], *p, *months;
	int end, hour, i, month;

	months = "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ";
	point = 0;
	i = get_dired_item("dired-sort-by-date-", 1);
	if (i)		// Call style-specific function.
		return (*(int (*)())i)();
	do {
		end = give_end_line();
		if (point == end)
			break;
		grab(point, end, line);
		hour = numtoi(line + 15);
		if (hour == 12)
			hour = 0;
		if (line[23] == 'p')
			hour += 12;
		line[8] = 0;
		p = strstr(months, line + 5);
		if (!p) {
			say("Unrecognized month %s, can't sort.", line + 5);
			p = months;
		}
		month = 1 + (p - months) / 4;	// Compute month 1..12.

		move_to_column(goal_column);
		bprintf("%.4s%2d%.2s%2d%.5s",
				line + 9, month, line + 2, hour, line + 18);
		point = end;
	} while (nl_forward());
	return 15;
}

dired_sort_by_exten()	/* insert stuff in each line, return length */
{
	char line[FNAMELEN];

	point = 0;
	do {
		if (point == give_end_line())
			break;
		dired_getindex(line, goal_column);
		move_to_column(goal_column);
		bprintf("%-30.30s", get_extension(line));
	} while (nl_forward());
	return 30;
}

strip_columns(scol, ecol)
{
	point = 0;
	do {
		delete(column_to_pos(scol), column_to_pos(ecol));
	} while (nl_forward());
}

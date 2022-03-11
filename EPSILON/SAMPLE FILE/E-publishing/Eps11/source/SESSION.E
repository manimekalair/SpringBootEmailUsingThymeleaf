/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1989, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

// This file handles remembering the window and buffer configuration
// you used the last time you ran Epsilon.

#include "eel.h"
#include "proc.h"
#include "bufed.h"

/* functions for remembering window configurations, which files
   we were editing, etc., from session to session */

#define DEFSESSNAME	"epsilon.ses"
#define DEFSESSDIR	((opsys == OS_UNIX) ? "~/.epsilon" : "/")

give_session_file(file)
char *file;
{
	char *s, *p, dir[FNAMELEN];

	if (explicit_session_file) {
		strcpy(file, explicit_session_file);
		return;
	}
	s = cmd_line_session_file;
	if (!s)
		s = verenv("ESESSION");
	if (!s && *session_file_name)
		s = session_file_name;
	if (!s)
		s = DEFSESSNAME;
	if (look_up_tree(file, s, NULL, session_tree_root))
		return;
	strcpy(file, s);
	if (*session_default_directory)
		absolute(file, session_default_directory);
	else if (p = verenv("EPSPATH")) {
		strcpy(dir, p);
		p = index(dir, path_list_char);
		if (p)
			*p = 0;
		absolute(file, dir);
	} else
		absolute(file, DEFSESSDIR);
}

ask_session_file(file, pr)	/* ask user for a session file */
char *file, *pr;
{
	char def[FNAMELEN];

	save_var only_file_extensions = "|.ses|";
	give_session_file(def);
	get_file(file, pr, def);
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

command write_session()
{
	char file[FNAMELEN];
	int err;

	ask_session_file(file, "Write session to");
	err = do_save_session(file);
	if (err) {
		file_error(err, file, "write error");
		maybe_ding(bell_on_write_error);
	} else {
		say("Session saved on %s", file);
		if (explicit_session_file)
			free(explicit_session_file);
		explicit_session_file = strsave(file);
	}
}

do_save_session(file)	/* write out the session putting fname in file */
char *file;		/* and return error code */
{
	int b, err;

	make_session(b = tmp_buf(), file);
	save_var bufnum = b;
	err = file_write(file, 0);
	restore_vars();
	buf_delete(b);
	return err;
}

char *give_buffer_name(buf)	/* give name or "" if bad buffer # */
{
	return buf_exist(buf) ? bufnum_to_name(buf) : "";
}

// Write info on window 
session_save_window(int b, int i)
{
	struct window_info w;

	get_window_info(i, &w);
	buf_printf(b, "%d %d %d %d\n",
			   w.left, w.top, w.right, w.bottom);
	buf_printf(b, "%d %d %d %d\n",
			   w.textcolor, w.hbordcolor, w.vbordcolor, w.titlecolor);
	buf_printf(b, "%d %d\n", w.borders, w.other);
	buf_printf(b, "%s\n", give_buffer_name(w.bufnum));
	buf_printf(b, "%s\n", give_buffer_name(w.prevbuf));
	buf_printf(b, "%d %d %d\n", w.point, w.dcolumn, w.dpoint);
}

session_save_misc(int b)
{
	buf_printf(b, "%d %d %d\n",
			   _default_flags, _default_regex_flags, _last_was_regex);
	buf_printf(b, "%s" SES_DELIM "%s" SES_DELIM,
			   _default_search ? _default_search : "",
			   _default_regex_search ? _default_regex_search : "");
	buf_printf(b, "%s" SES_DELIM "%s" SES_DELIM,
			   _default_replace, _default_regex_replace);
	buf_printf(b, "%s" SES_DELIM "%s" SES_DELIM,
			   push_cmd, _region_file);
	buf_printf(b, "%s" SES_DELIM "\n", _grep_files);
}

make_session(b, sesfile)
char *sesfile;
{
	int i, wins, owin = window_number;
	char sdir[FNAMELEN];	// dir of session file
	char file[FNAMELEN];

	strcpy(sdir, sesfile);
	absolute(sdir);
	*get_tail(sdir, 0) = 0;
	buf_printf(b, SES_HDR "\n");
	save_buffer_list(sdir, b);
	buf_printf(b, "\n%d\n", _prev_num);
	for (i = 0; i < _prev_num; i++)
		buf_printf(b, "%s\n", give_buffer_name(_prev_old_buffers[i]));
	save_bookmark_session(b);

	wins = number_of_windows() - number_of_popups();
	buf_printf(b, "%d %d %d %d %d %d\n",
			   wins, screen_cols, screen_lines, is_gui, opsys,
			   buf_accessed_clock);
	for (i = 0; i < wins; i++)
		session_save_window(b, i);
	buf_printf(b, "%d %d %d %d %d 0 0\n", owin, echo_line,
			   permanent_menu, avoid_top_lines, avoid_bottom_lines);
	session_save_misc(b);
	make_session_hook(b);
	save_recall_session(b);
	getcd(file);
	buf_printf(b, "CWD: %s\n", file);
	buf_printf(b, "OPENCWD: %s\n", common_open_curdir);
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

save_buffer_list(char *sdir, int b)
{
	int i, j, k;

	save_var bufnum;
	minimize_buf_accessed();
	// All buffers should now have a buf_accessed setting from 0 to buf_accessed_clock.
	for (j = buf_accessed_clock, k = 0; j >= 0; j--) {
		for (i = buf_list(0, 0); i; i = buf_list(1, 1)) {
			bufnum = i;
			if (buf_accessed < 0 || buf_accessed > buf_accessed_clock)
				error("Internal error: buffer %s clock %d, not 0..%d",
					  bufname, buf_accessed, buf_accessed_clock);

			if (i == b || buf_accessed != j || !remember_this_buffer())
				continue;
			if (session_restore_max_files >= 0
				  && ++k > session_restore_max_files)
				return;
			if (session_restore_biggest_file >= 0
				  && size() > session_restore_biggest_file)
				continue;		// too big to restore
			session_save_buffer(b, sdir);
		}
	}
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

save_bookmark_session(b)
{
	int i, buf;
	spot m;

	buf_printf(b, "%d %d\n", _bookmark_slot, _last_bookmark);
	for (i = 0; i < NUM_BOOKMARKS; i++) {
		m = _bookmark_spots[i];
		if (m && (buf = spot_to_buffer(m)) > 0)
			buf_printf(b, "%s\n%d\n", give_buffer_name(buf), *m);
		else
			buf_printf(b, "\n0\n");
	}
}

save_recall_session(b)	// store saved prompt responses in session file
{
	save_var bufnum = create(OLDRESP);
	point = size() - recall_maximum_session;
	to_begin_line();	// only keep last N chars worth
	buf_xfer(b, point, size());
	buf_printf(b, SES_DELIM "\n");
}

command read_session() on reg_tab[FSHIFT(5)]
{
	char file[FNAMELEN];
	int res;

	if (maybe_save_all())
		return 0;
	ask_session_file(file, "Read session from");
	res = load_this_session(file);
	return res;
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

load_this_session(file)		/* return 1 if session was loaded */
char *file;
{
	int b, err, old = bufnum;

	bufnum = b = create(SES_BNAME);
	err = file_read(file, 0);
	if (!err) {
		if (explicit_session_file)
			free(explicit_session_file);
		explicit_session_file = strsave(file);
		maybe_refresh();
		err = restore_session(b);
		switching_to_buffer();
		if (buf_in_window(b) == -1)
			buf_delete(b);
		if (!err)
			note("");
		else if (err != 100)
			say("Invalid format, code %d, in session %s",
				err, file);
		return 1;
	} else if (err != 2) {
		file_error(err, file, "couldn't read session");
		maybe_ding(bell_on_read_error);
	}
	bufnum = old;
	buf_delete(b);
	return 0;
}

int session_restore_one_file_1(int b)
{
	int nums[10];

	if (grab_numbers(b, nums) < 4)
		return 0;
	if (session_restore_files) {
		over_mode = nums[0];
		fill_mode = nums[1];
		indent_with_tabs = nums[2];
		margin_right = nums[3];
	}
	return 1;
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

// Read one file, return -1 to continue, 0 if user aborted, or error code.

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

int session_restore_prev_buffers(int b)
{
	int nums[10], i, j;
	char buf[FNAMELEN];

	if (grab_numbers(b, nums) != 1)
		return 1;
	j = nums[0];
	if (session_restore_files)
		_prev_num = j;
	for (i = 0; i < j; i++) {
		grab_line(b, buf);
		if (session_restore_files)
			_prev_old_buffers[i] = name_to_bufnum(buf);
	}
	return 0;
}

int session_restore_windows(int b, int def_buf)
{
	int nums[10], i, wins, err;

	i = grab_numbers(b, nums);
	if (i < 3)
		return -1;
	wins = nums[0];
	if (((has_feature & FEAT_EEL_RESIZE_SCREEN))
		  && !want_lines && !want_cols)
		try_set_screen_size(nums[2], nums[1], "");
	if (i > 5)
		buf_accessed_clock = nums[5];
	fix_buf_accessed_clock();
	err = rest_sess_wins(b, wins, !session_restore_files, def_buf,
						 nums[2], nums[1]);
	if (err) {
		def_buf = give_prev_buf();
		if (def_buf)
			to_buffer_num(def_buf);
	}
	return err;
}

int session_restore_misc(int b)
{
	int nums[10];
	char file[FNAMELEN];

	if (grab_numbers(b, nums) < 3)
		return 1;
	_default_flags = nums[0];
	_default_regex_flags = nums[1];
	_last_was_regex = nums[2];
	grab_string_expanding(b, &_default_search, SES_DELIM, FNAMELEN);
	grab_string_expanding(b, &_default_regex_search, SES_DELIM, FNAMELEN);
	grab_string(b, _default_replace, SES_DELIM);
	grab_string(b, _default_regex_replace, SES_DELIM);
	grab_string(b, push_cmd, SES_DELIM);
	grab_string(b, _region_file, SES_DELIM);
	grab_string(b, _grep_files, SES_DELIM);
	restore_session_hook(b);
	restore_recall(b);
	grab_line(b, file);		// skip \n after recall buffer
	grab_line(b, file);
	if (!strncmp(file, "CWD: ", 5)) {
		switch (session_restore_directory) {
			default:	if (directory_flags & DIR_CWD_RESTORE)
			case 1:			chdir(file + 5);
			case 0:		break;
		}
		grab_line(b, file);
		if (!strncmp(file, "OPENCWD: ", 9))
			common_open_curdir = file + 9;
	}
	return 0;
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

set_readonly_from_file()
{
	if (file_info.check_type == CHECK_FILE &&
			(file_info.attr & ATTR_READONLY) &&
			(readonly_warning & ROWARN_BUF_RO)) {
		_buf_readonly = 2;	// set from file
		call_on_modify = 1;
	}
}

restore_bookmark_session(b)
{
	int nums[10], i;
	char buf[FNAMELEN];

	if (grab_numbers(b, nums) < 2)
		return 1;
	_bookmark_slot = nums[0];
	_last_bookmark = nums[1];
	for (i = 0; i < NUM_BOOKMARKS; i++) {
		grab_line(b, buf);
		if (grab_numbers(b, nums) < 1)
			return 1;
		if (*buf && exist(buf)) {
			bufname = buf;
			_bookmark_spots[i] = alloc_spot(0);
			*_bookmark_spots[i] = nums[0];
		}
	}
	return 0;
}

/* restore windows from b */
/* if skip, just parse them, don't restore */

rest_sess_wins(b, wins, skip, def_buf, lines, cols)
{
	int nums[10], i, err = 0, bnum, must_default;
	char buf[FNAMELEN];
	struct window_info w;

	for (i = 0; i < wins; i++) {
		if (grab_numbers(b, nums) < 4)
			err = 6;
		w.left = nums[0];
		w.top = nums[1];
		w.right = nums[2];
		w.bottom = nums[3];
		if (grab_numbers(b, nums) < 4)
			err = 7;
		w.textcolor = nums[0];
		w.hbordcolor = nums[1];
		w.vbordcolor = nums[2];
		w.titlecolor = nums[3];
		if (grab_numbers(b, nums) < 2)
			err = 8;
		w.borders = nums[0];
		w.other = nums[1];
		grab_line(b, buf);
		w.point = -1;
		w.dpoint = -1;
		bnum = name_to_bufnum(buf);
		must_default = !bnum;
		grab_line(b, buf);
		w.prevbuf = name_to_bufnum(buf);
		w.bufnum = bnum ? bnum : w.prevbuf ? w.prevbuf :
			(bnum = give_prev_buf()) ? bnum : def_buf;
		if (grab_numbers(b, nums) < 3)
			err = 9;
		w.dcolumn = nums[1];
		if (!must_default) {
			w.point = nums[0];
			w.dpoint = nums[2];
		}
		if (err)
			break;
		if (!skip) {
			window_create(!i, &w);
			fix_window_start();
		}
	}
	nums[1] = screen_lines - 1;	/* echo line */
	nums[2] = 0;			/* want perm menu? */
	nums[3] = 0;			/* top avoid lines */
	nums[4] = 1;			/* bottom avoid lines */
	if (!err && !grab_numbers(b, nums))
		err = 10;
	if (err)
		one_window();
	else if (!skip) {
		echo_line = nums[1];
		select_low_window(nums[0], nums[3], nums[4], lines, cols);
		i = permanent_menu;
		restore_menu(nums[2]);
		set_menu_bar(i);	// undo setting in session file
	}
	return err;
}

restore_recall(b)	// get saved prompt responses from session
{
	int orig;

	save_var bufnum = b;
	orig = point;
	if (search(1, SES_DELIM))
		buf_xfer(zap(OLDRESP), orig, matchstart);
}

// Set buf_accessed_clock so it's higher than any buffer's buf_accessed.

fix_buf_accessed_clock()
{
	int i = buf_list(0, 2);
	save_var bufnum;
	do {
		bufnum = i;
		if (buf_accessed_clock <= buf_accessed)
			buf_accessed_clock = buf_accessed + 1;
	} while (i = buf_list(-1, 1));
}

// If the user manually changes preserve-session, it overrides -p.
when_setting_preserve_session()
{
	preserve_session_once = 0;
}

make_session_hook(b)
{
	b = b;				/* silence eel's warning */
}

restore_session_hook(b)
{
	b = b;				/* silence eel's warning */
}

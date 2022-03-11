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

// This file has commands for manipulating files.

#include "eel.h"
#include "proc.h"
#include "colcode.h"
#include "epsnet.h"
#include "filter.h"
#include "info.h"

use_common_open_file_dlg(fname, title, flags, save)
char *fname, *title;
int *flags;
{
	int ret;

	ret = common_file_dlg(fname, title, flags, save,
						 filter_str, custom_filter, &filter_index);
	if (ret)
		absolute(fname);
	return ret;
}

// Should we use the GUI dialog?
use_common_dialog(int var)
{
	if (!(has_feature & FEAT_FILE_DIALOG))
		return 0;
	switch (var) {
		case 0:	return 0;	// Never use.
		case 2:	return 1;	// Always use.
	}
	return run_by_mouse;	// Use if command was invoked by menu or toolbar.
}

// Should we use the GUI file dialog?
use_common_file_dialog()
{
	return use_common_dialog(want_common_file_dialog);
}

/* Ask for a file name and save buffer to that file if one is given. */
command write_file() on cx_tab[CTRL('W')]
{
	char tmp[FNAMELEN], tmp2[FNAMELEN];
	int flags = OFN_NOREADONLYRETURN | OFN_HIDEREADONLY;

	iter = 0;
	if (use_common_file_dialog()) {
		strcpy(tmp, force_save_as == FSA_NEWFILE ? "" : filename);
		if (!use_common_open_file_dlg(tmp, "Save file as", &flags, 1))
			return 0;
	} else
		get_file_dir(tmp, "Write file: ");
	if (*tmp && is_directory(tmp) && *filename) {
		make_copy_name(filename, tmp, tmp2);
		strcpy(tmp, tmp2);
	}
	if (*tmp) {
		if (get_file_read_only(tmp) == 1)
			error("File %s is read-only.", get_tail(tmp, 0));
		if (warn_existing_file(tmp))
			return 0;
		if (has_arg)
			translation_type = ask_line_translate();
		set_buffer_filename(tmp);
		already_made_backup = 0;
		modified = 1;
		return do_save_file(1, 0, 1);
	}
	return 0;
}

command copy_to_file() on reg_tab[FCTRL(7)]
{
	int mod = modified;
	int flags = OFN_NOREADONLYRETURN | OFN_HIDEREADONLY;
	char tmp[FNAMELEN], orig[FNAMELEN];

	iter = 0;
	strcpy(orig, filename);
	if (use_common_file_dialog()) {
		strcpy(tmp, force_save_as == FSA_NEWFILE ? "" : filename);
		if (!use_common_open_file_dlg(tmp, "Copy to file", &flags, 1))
			return;
	} else
		get_file(tmp, "Copy to file",
				 force_save_as == FSA_NEWFILE ? "" : filename);
	if (warn_existing_file(tmp))
		return;
	filename = tmp;
	save_var already_made_backup = 0, force_save_as = 0;
	do_save_file(1, 0, 0);
	filename = orig;
	modified = mod;
}

warn_existing_file(s)	// maybe warn if file s already exists
char *s;		// return nonzero to skip writing it
{
	char msg[FNAMELEN];

	if (is_remote_file(s))
		inet_only();
	if (!warn_before_overwrite || check_file(s, NULL) != CHECK_FILE)
		return 0;
	sprintf(msg, "Overwrite %r? ", s);
	return !ask_yn("Confirm overwrite", msg, "Overwrite", "Cancel", 1);
}

command print_setup()
{
	switch (is_gui) {
		case IS_WIN31:
			print_options.flags = PD_PRINTSETUP;
			select_printer(&print_options);
			break;
		case IS_NT:
		case IS_WIN95:
			page_setup_dialog();
			break;
	}
}

// Printing helper functions for Windows.

#define FORMFEED	"\x0C"		/* a string with a Ctrl-L */

// Return start of printed page following the one that starts at pt.
next_printed_page(pt)
{			// Either go one screenful down, or till next Ctrl-L.
	int full = move_by_screen_lines(pt, text_height());
	save_var point = pt, narrow_end = size() - full;
	return search(1, FORMFEED) ? point : full;
}

next_formfeed()		// How much of this page should we print?
{					// Stop before next Ctrl-L, if any.
	save_var point;
	if (search(1, FORMFEED))	// Go to next Ctrl-L 
		return point - 1;	// and return new position.
	return point;		// Or return end of buffer.
}

// Send current page to the printer.
show_printed_page()
{
	save_var narrow_end = size() - next_formfeed();
	redisplay();	// Fill this window.
	print_window(window_handle); // Send this window to the printer.
}

// How many printed pages will this buffer generate?

count_printed_pages()
{
	int i = 0;

	window_start = 0;
	while (window_start < size() - narrow_end && !user_abort) {
		window_start = next_printed_page(window_start);
		i++;
	}
	return i;
}

print_this_page(page)	// Did the user ask to print this page number?
{
	if (print_options.flags & PD_PAGENUMS)
		if (page < print_options.frompage || page > print_options.topage)
			return 0;
	return 1;
}

// Maybe show headings at the top of the page.
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

// Cycle the pages of this buffer through the printing window.
// Return # of pages we printed.

send_printed_pages(fname)
char *fname;
{
	int total_pages, page = 1, printed = 0;
	char date[FNAMELEN];
	struct time_info t;

	// Collect info we need for the page header.
	time_and_day(&t);
	format_date(date, t.year, t.month, t.day, t.hour, t.minute, t.second);
	save_var display_column = print_long_lines_wrap ? -1 : 0;
	total_pages = count_printed_pages();

	window_start = point = 0;
	while (point < size() - narrow_end) {
		if (print_this_page(page)) {
			note("Printing page %d of %d...", page, total_pages);
			print_headings(fname, page, total_pages, date);
			show_printed_page();
			if (!print_eject())
				break;
			printed++;
		}
		point = window_start = next_printed_page(window_start);
		page++;
		if (user_abort)
			break;
	}
	return printed;
}

gui_print(jobname, fname)
char *jobname, *fname;
{
	int height = print_options.height;	// Leave room for our heading.
	int win, cnt, scheme;

	if (print_heading)		// any heading takes 2 lines (one blank)
		height -= 2;
	if ((print_heading & (PRHEAD_PAGECNT | PRHEAD_DATE))
		&& (print_heading & PRHEAD_FNAME))
		height--;			// a two-line heading
	if (!start_print_job(jobname))
		error("Printing failed.");
	save_var window_handle;
	win = create_invisible_window(print_options.width, height, bufnum);
	if (print_color_scheme && (scheme = find_index(print_color_scheme))
		&& name_type(scheme) == NT_COLSCHEME)
		window_color_scheme = scheme;
	cnt = send_printed_pages(fname);
	remove_window(win);
	end_print_job();
	say("%d page%s printed.", cnt, cnt == 1 ? "" : "s");
}

command print_buffer() on reg_tab[FALT(9)]
{
	do_print_region(window_bufnum, !is_highlight_on(), has_arg);
}

command print_region() on reg_tab[FSHIFT(9)]
{
	do_print_region(window_bufnum, 0, has_arg);
}

command print_buffer_no_prompt()
{
	do_print_region(window_bufnum, !is_highlight_on(), 1);
}

// Make other changes to the buffer before printing it.
do_print_adjustments()
{
	if (print_doublespaced)
		simple_re_replace(1, "\n", "\n\n");
}

// Print the region, or the whole buffer if "all" is nonzero.
// If silent, try not to display any dialog, just do it.

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

send_to_file_or_cmd(b, file)	// copy buffer b to file, or send to cmd
char *file;
{
	int err;
	char *thisfile = file, cmdline[FNAMELEN], tempfile[FNAMELEN];

	if (!size()) {
		say("Nothing to print.");
		return -1;
	}
	save_var bufnum = b;
	if (*file == '!')
		make_temp_file(thisfile = tempfile, size());
	if (err = file_write(thisfile, translation_type)) {
		file_error(err, thisfile, "write error");
		maybe_ding(bell_on_write_error);
	}
	if (!err && *file == '!') {
		convert_to_8_3_filename(tempfile);
		build_filename(cmdline, file + 1, tempfile);
		err = do_push(cmdline, 0, -1);
		delete_file(tempfile);
	}
	return err;
}

ask_save_buffer()
{
	if (!(is_gui && want_gui_prompts)) {
		int res = ask_yn("Unsaved changes", "Save buffer? ",
					  "Yes", "No", 1);
		check_abort();
		return res;
	}
	switch (button_dialog("Unsaved changes", "This buffer contains "
						  "unsaved changes.  Save first? ",
						 "Save", "Discard", "Cancel", 1)) {
		case 1:	return 1;
		case 2: return 0;
	}
	quick_abort();
}

int reading_translation_type()
{
	return (file_io_converter == unicode_file_converter)
			? FILETYPE_BINARY : translation_type;
}

command visit_file() on cx_tab[CTRL('V')]
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

/* read the specified file into the current buffer */
read_file(tmp, strip)
char *tmp;
{
	int err;

	err = do_file_read(tmp, strip);
	if (err == 2) {
		zap(bufname);
		modified = 0;
		say("%s: New file.",tmp);
	} else if (err && err != EREADABORT) {
		file_error(err, tmp, "read error");
		maybe_ding(bell_on_read_error);
	} else if (file_info.check_type == CHECK_FILE
				&& (file_info.attr & ATTR_READONLY))
		do_readonly_warning();
	else
		update_readonly_warning(&file_info);
	if (window_bufnum == bufnum)
		switching_to_buffer();
	make_mode();
	return err;
}

do_readonly_warning()	// alert user: just read a read-only file
{
	if (readonly_warning & ROWARN_MSG)
		say("%s: File is read-only.", filename);
	if (readonly_warning & ROWARN_BUF_RO) {
		_buf_readonly = 2;	// set from file
		call_on_modify = 1;
	}
	maybe_ding(readonly_warning & ROWARN_BELL);
	make_mode();
}

update_readonly_warning(p)  // if file's no longer readonly, and we made
struct file_info *p;	// buffer readonly because it was, make writeable
{
	if (p->check_type == CHECK_FILE && !(p->attr & ATTR_READONLY)
	    && (_buf_readonly == 2)) {
		_buf_readonly = 0;	// if set from file, reset
		make_mode();
	}
}

command change_file_read_only()
{
	int old;
	char fname[FNAMELEN];

	iter = 0;
	save_var show_mouse_choices = 1;
	get_file(fname, "Change read-only status of file",
			force_save_as == FSA_NEWFILE ? "" : filename);
	old = get_file_read_only(fname);
	if (old == -1 || !set_file_read_only(fname, !old))
			error("Can't change read-only status of %r", fname);
	say("%r is now %s.", fname, !old ? "read-only" : "writable");
	check_dates(0);
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

command insert_file() on cx_tab['i']
{
	char file[FNAMELEN];
	int flags = OFN_HIDEREADONLY;

	save_var show_mouse_choices = 1;
	if (use_common_file_dialog()) {
		strcpy(file, _region_file);
		if (!use_common_open_file_dlg(file, "Insert file", &flags, 0))
			return;
	} else {
		if (!insert_file_remembers_file || !*_region_file)
			get_buffer_directory(_region_file);
		get_file(file, "Insert file", _region_file);
	}
	if (!*file)
		return;
	strcpy(_region_file, file);
	mark = point;			/* put mark before it */
	set_region_type(REGNORM);
	build_first = 1;
	do_insert_file(file, ask_line_translate());
	iter = 0;
}

do_insert_file(file, strip)	/* insert file into current buffer at pt */
char *file;
{
	int orig = bufnum, buf, err;

	bufnum = buf = tmp_buf();
	err = err_file_read(file, strip);
	if (!err)
		buf_xfer(orig, 0, size());
	bufnum = orig;
	buf_delete(buf);
	return err;
}

err_file_read(file, strip)	/* like file_read, but show error */
char *file;
{
	int err = file_read(file, strip);

	if (window_bufnum == bufnum)
		switching_to_buffer();
	_read_aborted = (err == EREADABORT);
	if (err && !_read_aborted) {
		file_error(err, file, "read error");
		maybe_ding(bell_on_read_error);
	}
	return err;
}

command write_region() on cx_tab['w']
{
	char file[FNAMELEN];
	int b = -1;
	int flags = OFN_NOREADONLYRETURN | OFN_HIDEREADONLY;

	if (use_common_file_dialog()) {
		strcpy(file, _region_file);
		if (!use_common_open_file_dlg(file, "Write region to file", &flags, 1))
			return;
	} else {
		if (!insert_file_remembers_file || !*_region_file)
			get_buffer_directory(_region_file);
		get_file(file, "Write region to file", _region_file);
	}
	if (!*file)
		return;
	if (warn_existing_file(file))
		return;
	if (has_arg)
		save_var translation_type = ask_line_translate();
	strcpy(_region_file, file);
	save_spot point, mark;
	fix_region();		// handle other types of regions
	highlight_off();
	if (region_type() == REGRECT) {
		b = tmp_buf();
		extract_rectangle(b, 0);
		save_var bufnum = b;
		mark = 0;
	}
	if (!write_part(file, translation_type, point, mark))
		note_written(file);
	if (b != -1)
		buf_delete(b);
}

note_written(char *fname)
{
	if (is_remote_file(fname))
		show_text(0, 1, "%s: write request queued.", fname);
	else
		show_text(0, 1, "%s written.", fname);
}

write_part(file, strip, start, end)
char *file;
{
	int orig = bufnum, buf, err;

	buf = tmp_buf();
	buf_xfer(buf, start, end);
	bufnum = buf;
	if (is_remote_file(file)) {
		filename = file;
		err = save_remote_file(file, strip, NULL);
	} else
		err = file_write(file, strip);
	bufnum = orig;
	if (!is_remote_file(file))
		buf_delete(buf);
	if (err) {
		file_error(err, file, "write error");
		maybe_ding(bell_on_write_error);
	}
	return err;
}

command save_file() on cx_tab[CTRL('S')]
{
	tiled_only();
	if (has_arg)
		translation_type = ask_line_translate();
	return do_save_file(1, 1, 1);
}

do_save_file(backup, checkdate, getdate) /* 0=ok, 1=err, 2=user canceled */
{				/* always prints status in echo area */
	struct file_info *finfo;
	char othername[FNAMELEN], msg[FNAMELEN];
	int err;

	iter = 0;
	if (!*filename || force_save_as)
		return write_file();
	if (checkdate)
		if (check_dates(1))
			return 2;
	if (_read_aborted) {
		relative(filename, othername);
		sprintf(msg, "Only part of %s was read from disk.  "
			"Save anyway? ", othername);
		if (!ask_yn("Confirm save", msg, "Save", "Cancel", 0))
			return 2;
	}
	build_filename(othername, backup_name, filename);
	if (backup && (want_backups && !already_made_backup
				   || want_backups == 2) && fnamecmp(filename, othername)) {
		make_backup(filename, othername);
		already_made_backup = 1;
	}
	finfo = getdate ? &file_info : 0;
	if (err = file_convert_write(filename, translation_type, finfo)) {
		auto_read_changed_file = 0;
		file_info.check_type = 0;	// Prevent checking date.
		file_error(err, filename, "write error");
		maybe_ding(bell_on_write_error);
	} else {
		note_written(filename);
		undo_set_flag(UNDO_WRITE_FILE);
		if (finfo)
			update_readonly_warning(finfo);
	}
	return (err != 0);
}

auto_save_buffers()	/* maybe save buffers */
{
	int i;

	save_var bufnum;
	i = buf_list(0, 0);	/* start with oldest buf */
	do {
		bufnum = i;
		if (*filename != '\0' && modified && !buffer_not_saveable)
			auto_save_one();
	} while (i = buf_list(1, 1));
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

// Is this buffer unsaved?
int is_unsaved_buffer()
{
	if (discardable_buffer || buffer_not_saveable)
		return 0;
	if (modified && *filename && size() && !is_dired_buf())
		return 1;
	if (ftp_job && ftp_job->buf == bufnum && ftp_job->operation == FTP_SEND)
		return 1;
	return 0;
}

unsaved_buffers()	/* return 1 if any unsaved buffers exist */
{
	int i = buf_list(0, 0), ret = 0;

	save_var bufnum;
	do {
		bufnum = i;
		if (is_unsaved_buffer()) {
			ret = 1;
			break;
		}
	} while (i = buf_list(1, 1));
	return ret;
}
 
maybe_save_all()	/* possibly save all buffers, depending on variable */
{			/* returns 0 normally; 1 means don't do cmd */
	switch (save_when_making) {
		case 0:		return 0;	/* never do it */
		case 1:		break;		/* always do it */
		default:	if (!unsaved_buffers())
						return 0;
					switch (bufed_ask_save()) {
						case 0:	return 1;
						case 1: return 0;
						case 2:	break;
					}
					break;
	}
	save_all_buffers();
	return 0;
}

// Move to the end of this buffer; also chop lines from the start so it
// doesn't exceed limit chars (-1=no limit).

buffer_to_end(char *buf, int limit)
{
	if (exist(buf)) {
		save_var bufname = buf;
		if (limit > 0) {
			point = size() - limit;
			to_begin_line();
			delete(0, point);
		}
		point = size();
	}
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

command save_all_buffers() on cx_tab['s']
{
	int count = 0, failed = 0;

	buffer_to_end(MSG_BUFFER, message_history_size);
	do_save_all_buffers(0, &count, &failed);
	do_save_all_buffers(1, &count, &failed);
	if (failed) {
		if (in_bufed())
			do_bufed(0);
		error("%d file%s saved, %d file%s could not be saved, see %s buffer.",
			  count, (count != 1) ? "s" : "",
			  failed, (failed != 1) ? "s" : "", MSG_BUFFER);
	}
	if (count) {
		say("%d file%s saved.", count, (count != 1) ? "s" : "");
		if (in_bufed())
			do_bufed(0);
	} else
		say("No files needed saving.");
	return count;
}

set_buffer_filename(f)
char *f;
{
	char abs[FNAMELEN];
	char bname[FNAMELEN+10];

	if (*f) {
		strcpy(abs, f);
		absolute(abs);
		filename = abs;
		do_make_bname(abs, bname, bufname);
		if (!exist(bname))
			change_buffer_name(bname);
		force_save_as = 0;
	} else
		filename = f;
	unique_filename_identifier(filename, unique_file_identifier);
	if (window_bufnum == bufnum)
		switching_to_buffer();
}

command set_file_name()
{
	char tmp[FNAMELEN];

	get_file_dir(tmp, "Enter new output file name: ");
	if (*tmp)
		set_buffer_filename(tmp);
}

command set_want_backup_file()
{
	want_backups = has_arg? (iter != 0) : !want_backups;
	say("Epsilon will%s create a backup file for this buffer.",
	    want_backups ? "" : " not");
}

command write_files_and_exit()
{
	if (unsaved_buffers()) {
		save_all_buffers();
		refresh();
	}
	exit();
	iter = 1;
}

// If file is in cygwin format, change it to native format in place.

convert_cygwin_filename(char *file)
{
	char buf[FNAMELEN], *home;

	if (opsys != OS_DOS || !cygwin_filenames)
		return;
	if (file[0] == '/' && file[1] == '/' && isalpha(file[2]) && file[3] == '/') {
		strcpy(buf, file + 3);		// Rewrite //f/file into f:/file.
		sprintf(file, "%c:%s", file[2], buf);
		return;
	}
	if (file[0] == '~' && cygwin_filenames > 1 && (!file[1] || file[1] == '/')
		  && (home = getenv("HOME"))) {
		strcpy(buf, file + 1);
		sprintf(file, "%s%s", home, buf);
	}
	if (!strncmp(file, "/cygdrive/", 10)) {
		sprintf(buf, "%c:%s", file[10], file + 11);
		strcpy(file, buf);
	}
}

// Read a file with no character set conversion (even if that's the
// default).
command find_unconverted_file()
{
	save_var default_character_set = 1;
	find_file();
}

command find_file() on cx_tab[CTRL('F')]
{
	char fname[FNAMELEN];
	int want_readonly = 0, flags = 0;

	tiled_only();
	was_quoted = 0;
	save_var show_mouse_choices = 1;
	if (use_common_file_dialog()) {
		*fname = 0;
		if (!use_common_open_file_dlg(fname, "Open file", &flags, 0))
			return;
		if (flags & OFN_READONLY)
			want_readonly = 1;
	} else
		get_file_dir(fname, "Find file: ");
	if (!*fname)
		dired_one(fname);
	else if (was_quoted && !is_directory(fname) && !is_remote_file(fname))
		find_it(fname, ask_line_translate());
	else 
		do_find(fname, ask_line_translate());
	if (want_readonly)
		force_save_as = FSA_READONLY;
	iter = 0;
}

command new_file()
{
	iter = 0;
	tiled_only();
	make_newfile_buf();
}

make_newfile_buf()
{
	char bname[FNAMELEN], fname[FNAMELEN];
	int unique = 2;

	strcpy(bname, "New File");
	for (;;) {
		sprintf(fname, "New%d%s", unique - 1, new_file_ext);
		absolute(fname);
		if (!exist(bname) && !do_file_match(fname, STARTMATCH | EXACTONLY)
			|| unique >= 99)
			break;
		sprintf(bname, "New File %d", unique++);
	}
	to_buffer(bname);
	force_save_as = FSA_NEWFILE;
	filename = fname;
	fundamental_mode();
	try_calling(new_file_mode);
}

command find_read_only_file()
{
	find_file();
	if (!is_dired_buf()) {
		_buf_readonly = 1;	// not set from file
		call_on_modify = 1;
		force_save_as = FSA_READONLY;
		make_mode();
	}
}

// Search on line for link, set file to its name.
lst_find_linked_file(char *file)
{
	to_begin_line();
	point += parse_string(1, "[ \t]*");
	if (!parse_string(1, ".*[^ \t\n]![ \t\n]*$", file))
		error("Can't find any file here.");
}

#define URL_PATTERN	"|((ftp|http):[/\\][/\\][^\n\t >]+)"

default_find_linked_file(char *file)
{
	char *pat;

	if (opsys == OS_UNIX)
		pat = "[+-9A-z~]+[/.][+-9A-z]*[--9+A-z]" URL_PATTERN;
	else
		pat = "([a-z]:)?[+-9A-z~]+<.>[+-9A-z]*[--9+A-z]" URL_PATTERN;
	point -= parse_string(-1, "[^ \t\n]*");
	if (!re_search(1, pat)) {
		to_begin_line();
		if (!re_search(1, pat))
			error("Can't find any file name on this line.");
	}
	if (strchr("\"'`<", character(matchstart)))
		matchstart++;
	if (strchr("\"'`.,>", character(matchend - 1)))
		matchend--;
	grab(matchstart, matchend, file);
}

// Look for a file name after point on the current line.

find_linked_file_here(char *file)
{
	char subr[FNAMELEN], curdir[FNAMELEN], *s;
	int i = 0;

	save_var narrow_end = size() - give_end_line();
	if (*filename) {
		s = get_extension(filename);
		sprintf(subr, "%s_find_linked_file", *s ? (s + 1) : "none");
		i = find_index(subr);		// Any special method for this file extension?
	}
	if (!i) {
		sprintf(subr, "%s_find_linked_file", major_mode);
		i = find_index(subr);		// Any special method for this buffer?
	}
	switch (name_type(i)) {		// i has name table index of subr/var
		case NT_SUBR: case NT_COMMAND:
		case NT_AUTOSUBR: case NT_AUTOLOAD:
			(*(int (*)())i)(file);		// Cast i to a func ptr, then call it.
			break;
		default:		// Look in file for something like a file name.
			default_find_linked_file(file);
			break;
	}
	get_buffer_directory(curdir);
	if (!is_remote_file(file))
		absolute(file, curdir);
}

// Look for a file name on this line, then view it.

command find_linked_file() on cx_tab[CTRL('L')]
{
	char file[FNAMELEN], curdir[FNAMELEN];

	*file = 0;
	if (is_highlight_on()) {
		save_var point, mark;
		fix_region();
		if (mark - point < FNAMELEN - 1 && !lines_between(point, mark, 0))
			grab(point, mark, file);
	}
	if (!*file)
		find_linked_file_here(file);
	get_buffer_directory(curdir);
	if (!is_remote_file(file))
		absolute(file, curdir);
	quiet_set_bookmark();
	tiled_only();
	locate_window("", file);
	do_find(file, ask_line_translate());
}

string_matches_pattern(char *str, char *pat)
{
	int tmp = tmp_buf(), res;
	save_var bufnum = tmp;
	stuff(str);
	point = 0;
	res = parse_string(1, pat);
	restore_vars();
	buf_delete(tmp);
	return res;
}

command view_web_site() on reg_tab[FSHIFT(8)]
{
	char url[FNAMELEN], def[FNAMELEN];

	*def = 0;
	html_help_check_ok();
	save_var point, mark;
	if (is_highlight_on()) {
		fix_region();
		if (mark - point < FNAMELEN - 1 && !lines_between(point, mark, 0))
			grab(point, mark, def);
	}
	if (!*def)
		if (re_search(1, "(www%.|(https?|ftp):[/\\][/\\])[^\n\t <>\"]+"
					  "[^\n\t <>()\"',.]"))
			if (character(matchstart) == 'w') {	// No http://
				strcpy(def, "http://");
				grab(matchstart, matchend, def + strlen(def));
			} else
				grab(matchstart, matchend, def);
	restore_vars();
	get_strdef(url, "View web site", def);
	if (!*url)
		return;
	if (is_win32)
		do_shell_execute(url, "Open", "view web page");
	else
		show_url(url);
}

// Call dired if file has wildcards or is a directory name.
// For remote files, assume it's an FTP directory name if the name
// ends in /, if there's no name at all, or if the ftp spec includes
// wildcards, otherwise assume file (or other URL).

do_find(char *file, int strip)
{
	if (is_remote_file(file) ? is_remote_dir(file)
							 : (is_pattern(file) || is_directory(file)))
		return dired_one(file);
	else
		return find_it(file, strip);
}

find_it(fname, strip)	/* find named file (must be in absolute form) */
char *fname;
{
	if (!*fname)
		return 2;
	if (look_file(fname)) {
		save_var _force_auto_read_changed_file = 1;
		to_buffer(bufname);
		return 0;
	}
	return find_in_other_buf(fname, strip);
}

find_in_other_buf(fname, transl)
char *fname;
{
	char bname[FNAMELEN+10];
	int err;

	make_bname(fname, bname);
	to_buffer(bname);
	if (default_character_set == 2)
		file_io_converter = oem_file_converter;
	else
		file_io_converter = 0;
	err = read_file(fname, transl);
	unique_filename_identifier(fname, unique_file_identifier);
	call_mode(filename);
	make_mode();
	check_filevars();
	return err;
}

// Find a file variable that matches this pattern; return nonzero if we
// did.  This can be on an -*- var: value -*- line at the start, or in a
// Local Variables section at the end.  If oldpat is non-NULL, it says
// what old-style pattern to look for, where just a value is present
// between -*- markers.
int look_for_filevar_pattern(char *var, char *value, char *oldvalue)
{
	char fullpat[FNAMELEN];

	save_var point = 0;
	if (parse_string(1, "#!"))	// Look in first line or two only.
		nl_forward();
	save_var narrow_end = size() - give_end_line();
	point = 0;
	if (oldvalue) {
		sprintf(fullpat, ".*-%%*-[ \t]*%s[ \t]*-%%*-", oldvalue);
		if (re_search(1, fullpat))
			return 1;
	}
	point = 0;
	sprintf(fullpat, ".*-%%*-.*</word>%s:[ \t]*%s</word>.*-%%*-", var, value);
	if (re_search(1, fullpat))
		return 1;
	restore_vars();
	save_var point = size() - 3000;
	sprintf(fullpat, "</word>%s:[ \t]*%s", var, value);
	if (search(1, "Local Variables:") && re_search(1, fullpat))
		return 1;
	return 0;
}

// Look for file variables and set our variables appropriately.  We
// only do one right now.
check_filevars()
{
	char buf[FNAMELEN];
	int i;

	save_var case_fold = 1;
	if (!look_for_filevar_pattern("tab-(size|width)", "([0-9]+)", NULL))
		return;
	grab(find_group(2, 1), find_group(2, 0), buf);
	i = numtoi(buf);
	if (i > 0)
		tab_size = i;
}

// Set to mode specified by filevar and return 1, or return 0 if none.
check_filevar_mode()
{
	char buf[FNAMELEN], mode[FNAMELEN];

	save_var case_fold = 1;
	if (!look_for_filevar_pattern("mode", "([^:; \t\n]+)", "([^:; \t\n]+)"))
		return 0;
	grab(find_group(1, 1), find_group(1, 0), buf);
	if (!strfcmp(buf, "C++"))
		strcpy(mode, "suffix-cpp");
	else
		sprintf(mode, "%s-mode", buf);
	return try_calling(mode);
}

command reset_mode()
{
	call_mode(filename);
}

call_mode(f)		/* go into appropriate mode based on extension of f */
char *f;
{
	if (!check_filevar_mode())
		call_by_suffix(f, "suffix-%s");
}

call_by_suffix(file, pattern)	// construct a subr name from extension
char *file, *pattern;		// of file name, try to call it
{				// return 1 if we found something to call
	char *s, subr[FNAMELEN], def[FNAMELEN];

	s = get_extension(file);
	sprintf(subr, pattern, *s ? (s + 1) : "none");
	sprintf(def, pattern, "default");
	return try_calling(subr) || try_calling(def);
}

// The current file has no extension.  Examine it and guess its mode.
// If we can, use pat as a sprintf pattern, put the result in res,
// and return 1.  Otherwise return 0.

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

suffix_none()		// Try to detect the file type from its contents.
{
	char mode[FNAMELEN];

	if (guess_mode_without_extension(mode, "suffix-%s"))
		if (try_calling(mode))
			return;
	suffix_default();
}

suffix_default()
{
	char mode[FNAMELEN];

	if (guess_mode_without_extension(mode, "suffix-%s"))
		if (try_calling(mode))
			return;
	fundamental_mode();
}

build_filename(result, template, file)	/* interpret filename templates */
char *result, *template, *file;	/* copy res to pat, replacing % */
{				/* codes with parts of filename */
	char *start;
	int len;

	for (; *result = *template; template++) {
		len = -1;
		if (template[0] == '%' && template[1]) {
			switch (*result = *++template) {
			case 'p': start = file;
				len = get_tail(start, 0) - start;
				break;
			case 'b': start = get_tail(file, 0);
				len = get_extension(start) - start;
				break;
			case 'e': start = get_extension(file);
				len = strlen(start);
				break;
			case 'f': start = file;
				len = strlen(start);
				break;
			case 'r': relative(file, result);
				result += strlen(result) - 1;
				break;
			case 'x': get_executable_directory(result);
				result += strlen(result) - 1;
				break;
			case 'X': get_executable_directory(result);
				convert_to_8_3_filename(result);
				result += strlen(result) - 1;
				break;
			}
		}
		if (len >= 0) {
			strncpy(result, start, len);
			result += strlen(result);
		} else
			result++;
	}
}

put_directory(s)		// put directory of current file in s
char *s;
{
	strcpy(s, filename);
	*get_tail(s, 0) = 0;
}

// Look in dir & its parents for a file.
// If found, put the file's name in res & return 1.
// If not found, return 0.
// If dir is null, use the current directory.
// If stop is non-null and non-empty, Epsilon will only look for
// matches within it.  (It must be in absolute form.)

look_up_tree(res, file, dir, stop)
char *res, *file, *dir, *stop;
{
	char subdir[FNAMELEN], stopdir[FNAMELEN];
	int len, last = 1000;

	strcpy(stopdir, stop ? stop : "");
	if (*stopdir == '~')		// Expand home directory for Unix.
		absolute(stopdir);
	if (dir)
		strcpy(subdir, dir);
	else
		getcd(subdir);
	for (;;) {
		if (stopdir && *stopdir && fnamecmp(subdir, stopdir)
			&& !is_in_tree(subdir, stopdir))
			return 0;
		strcpy(res, file);
		absolute(res, subdir);
		if (check_file(res, NULL) == CHECK_FILE)
			return 1;
		if (strchr(file, '\\') || strchr(file, '/') || strchr(file, ':'))
			return 0;
		*get_tail(subdir, 0) = 0;
		len = strlen(subdir);
		if (len > 3 && is_path_separator(subdir[len - 1]))
			subdir[--len] = 0;
		if (len >= last)
			break;
		last = len;
	}
	return 0;
}

is_in_tree(file, tree)		// is file inside this directory tree?
char *file, *tree;		// assumes both are in absolute form
{
	char rel[FNAMELEN];

	relative(file, rel, tree);
	return fnamecmp(file, rel) != 0;
}

wild_pattern(s)		/* does this filename use the {}[],; wildcards? */
char *s;
{
	return is_pattern(s) & 1;
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

command list_files()	// list files that match a pattern
{			// with num arg, include directories
	char filepat[FNAMELEN], *s;
	int count = 0;

	iter = 0;
	tiled_only();
	get_file_dir(filepat, "List files matching pattern: ");
	if (!*filepat)
		return;
	zap("file-list");
	to_buffer("file-list");
	noteput("Listing files...");
	s = do_file_match(filepat, STARTMATCH | EXACTONLY
			| (has_arg ? 0 : FM_NO_DIRS));
	for (; s; s = do_file_match(filepat, 0)) {
		if (++count % 10 == 0)
			noteput("Listing file %d... %s", count, s);
		bprintf("%s\n", s);
		check_abort();
	}
	do_sort_region(0, size(), 0, 0);
	point = modified = 0;
	say("%d files found.", count);
}

command locate_file()
{
	char file[FNAMELEN], pat[FNAMELEN], tmp[FNAMELEN];
	int d;

	get_string(file, "Locate files matching the pattern: ");
	if (is_unix) {
		sprintf(pat, "%s%s", locate_path_unix, file);
	} else {
		strcpy(pat, "{");
		for (d = 'C'; d < 'Z'; d++) {
			sprintf(tmp, "%c:\\", d);
			if (filename_rules(tmp) & FSYS_LOCAL)
				sprintf(pat + strlen(pat), "%c,", d);
		}
		if (strlen(pat) < 2)
			error("Can't determine local drive list.");
		pat[strlen(pat) - 1] = '}';
		sprintf(pat + strlen(pat) - 1, "}:\\**\\%s", file);
	}
	sayput("Listing files matching %s...", pat);
	dired_one(pat);
}

ask_line_translate()
{
	int res = -1;

	if (!has_arg)
		return default_translation_type;
	iter = 1;
	while (res == -1) {
		sayput("File translation? D=DOS, B=Binary, U=Unix, M=Mac [%c] ",
			   (opsys == OS_UNIX) ? 'U' : 'D');
		getkey();
		check_abort();
		if (IS_ENTER_KEY(key))
			res = (opsys == OS_UNIX) ? FILETYPE_UNIX : FILETYPE_MSDOS;
		switch (toupper(key)) {
			case 'B':	res = FILETYPE_BINARY; break;
			case 'D':	res = FILETYPE_MSDOS; break;
			case 'U':	res = FILETYPE_UNIX; break;
			case 'M':	res = FILETYPE_MAC; break;
		}
	}
	say("");
	return res;
}

command set_line_translate()
{
	has_arg = 1;
	translation_type = ask_line_translate();
	switch(translation_type) {
		case FILETYPE_MSDOS:   say("Read/write as Windows/DOS file: ^M^J separates lines");
							   break;
		case FILETYPE_BINARY:  say("Binary file: No changes when reading or writing");
							   break;
		case FILETYPE_UNIX:    say("Read/write as Unix file: ^J separates lines");
							   break;
		case FILETYPE_MAC:     say("Read/write as Macintosh file: ^M separates lines");
							   break;
		default: say("Unknown translation type"); break;
	}
	make_mode();
	iter = 0;
}

command cd() on reg_tab[FKEY(7)]	/* change current directory */
{
	char resp[FNAMELEN], dir[FNAMELEN];

	save_var recall_id = "changedir";
	if (get_buffer_directory(dir))
		save_completion(dir, 0);
	getcd(dir);
	if (*dir && is_path_separator(dir[strlen(dir) - 1]) != 1)
		sprintf(dir + strlen(dir), "%c", path_sep);
	save_var show_mouse_choices = 1, insert_default_response = 3;
	save_var completion_lister = list_file_matches;
	save_var abort_file_matching = ABORT_JUMP;
	prompt_comp_read(resp, "Change to directory", f_match,
					 COMP_FILE | FOLDFILE | FM_ONLY_DIRS, dir);
	if (*resp && chdir(resp)) {
		if (errno == 2)
			error("%s: no such directory", resp);
		else
			file_error(errno, resp, "unknown error");
	} else {
		getcd(dir);
		say("Current directory: %s", dir);
	}
}

// Get default directory for this buffer and return nonzero.
// If none, set dir to current directory and return zero.

get_buffer_directory(dir)
char *dir;
{
	int ok = 1;

	*dir = 0;
	if (is_dired_buf())		/* get directory name from dired */
		dired_getdir(dir);
	else if (!strcmp(bufname, PROCBUF))	// process buffer?
		strcpy(dir, process_current_directory);
	else if (!strcmp(bufname, INFO_BUF))
		ok = 0;
	else {
		strcpy(dir, filename);
		if (!*filename || (force_save_as & FSA_NEWFILE)) {
			ok = 0;			// No file name, so use Epsilon's cur dir
			*dir = 0;		// but say we couldn't find anything specific.
		}
		absolute(dir);
		if (ok)			/* want only directory part */
			*get_tail(dir, 1) = 0;
	}
	if (!*dir) {
		ok = 0;
		getcd(dir);
	}
	if (*dir) {
		dir += strlen(dir);	/* ptr to end of string */
		if (!is_path_separator(dir[-1])) {
			*dir++ = path_sep; /* make sure it ends with slash */
			*dir = 0;
		}
	}
	return ok;
}

// Called whenever a window starts displaying a different buffer
// or the user switches windows.

switching_to_buffer()
{		// put "timestamp" on this buffer showing last access
	hide_auto_show_delimiter();
	buf_accessed = ++buf_accessed_clock;
}

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

// This file compares file dates and issues warnings.

#include "eel.h"

get_file_date()		/* record this file's date for later comparison */
{
	if (check_file(filename, &file_info) != CHECK_FILE)
		file_info.year = 0;
}

// The file has been modified on disk; maybe re-read it without prompting.
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

// If the file's become read-only, set buffer to match.

maybe_add_readonly(struct file_info *now)
{
	if (!(now->attr & ATTR_READONLY) || (file_info.attr & ATTR_READONLY))
		return;
	if (modified) {
		refresh();
		if (!ask_yn("File is read-only", "This file is now read-only.  "
					"Set buffer read-only too? ", "Yes", "No", 1))
			return;
	}
	do_readonly_warning();
}

// Like above, but also remembers new attribute.

maybe_add_readonly_once(struct file_info *now)
{
	if (readonly_warning & ROWARN_GREP)
		return;
	maybe_add_readonly(now);
	file_info.attr = now->attr;
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

show_date_warning(temp, orig, then, now, save)
struct file_info *now, *then;
{
	struct time_info time;
	char msg[30], *file;
	int mod, warn, auto;

	save_var bufnum = orig;
	file = filename;
	mod = modified;
	warn = want_warn;
	auto = auto_read_changed_file;
	bufnum = temp;
	buf_zap(temp);
	bprintf("%s has changed since it was read from disk", file);
	bprintf(mod ? "!\n" : ".\nFortunately, you haven't edited it.\n");

	stuff_file_date("\nThe version being edited was dated %s on disk.\n",
		then);
	stuff_file_date("         The copy on disk is dated %s.\n\n", now);
	time_and_day(&time);
	format_date(msg, time.year, time.month, time.day,
		time.hour, time.minute, time.second);
	bprintf("                         It is now %s.\n\n", msg);

	bprintf("Options:\n");
	bprintf("C) Compare the two versions by reading the disk version ");
	bprintf("in its own buffer.\n");
	bprintf("   You may then use compare-windows or diff to ");
	bprintf("see the changes.\n");
	bprintf("R) Read in the new version now, replacing the ");
	bprintf("version already read in.\n");
	if (save)
		bprintf("S) Save your changes, replacing ");
	else
		bprintf("I) Ignore ");
	bprintf("the version on disk.\n");
	bprintf("!) %s this warning for this buffer.  ",
		warn ? "Disable" : "Re-enable");
	bprintf("(You may then choose\n");
	bprintf("   another option.)\n");

	bprintf("A) %s auto-read.  Read changed files without prompting, "
			"if it's safe.\n", auto ? "Disable" : "Enable");
	bprintf("   (You may then choose another option.)\n");

	bprintf("\nYour choice? ");
	point = 0;
}

ask_read_changed_file()
{
	char ques[200];
	int res;

	sprintf(ques, "%s auto-reading for new buffers? ",
			auto_read_changed_file ? "Disable" : "Enable");
	if (!(is_gui && want_gui_prompts))
		res = ask_yn("Set default", ques, "Yes", "No", 2) ? 1 : 2;
	else
		res = button_dialog("Set default", ques, "Yes", "No", "Cancel", 2);
	if (!user_abort) {
		if (res == 1 || res == 2)
			auto_read_changed_file = !auto_read_changed_file;
		if (res == 1)
			auto_read_changed_file.default = auto_read_changed_file;
	}
	user_abort = 0;
}

// Do these two file_info structures indicate the file has been modified?
// Return nonzero if modified, zero if unchanged.
compare_dates(a, b)
struct file_info *a, *b;
{
	int diff;

	if (a->fsize != b->fsize)
		return 1;
	// We test raw times to avoid an NT problem with daylight savings
	// time.  (Files on some file systems change their timestamps when
	// daylight savings time starts or ends, while files on other file
	// systems do not.)  Also we can easily ignore small time differences
	// which can occur over networks or in various other situations.
	diff = b->raw_file_date_low - a->raw_file_date_low;
	if (diff < 0)
		diff = -diff;
	if (a->raw_file_date_high || a->raw_file_date_low)	// Good, we have raw times.
		if (a->raw_file_date_high == b->raw_file_date_high)
			if (diff < file_date_tolerance)		// Raw times are available,
				return 0;					// and close, so they're equal.

	return a->year != b->year || a->month != b->month
			|| a->day != b->day || a->hour != b->hour || a->minute != b->minute
			|| a->second != b->second;
}

stuff_file_date(fmt, p)	/* bprintf the date in p using fmt's %s */
char *fmt;
struct file_info *p;
{
	char msg[50];

	format_date(msg, p->year, p->month, p->day,
		p->hour, p->minute, p->second);
	bprintf(fmt, msg);
}

format_date(msg, year, month, day, hour, minute, second)
char *msg;
{
	char ampm = 'a';

	if (hour >= 12)
		ampm = 'p', hour -= 12;
	sprintf(msg, "%d-%02d-%d %d:%02d:%02d %cm",
		month, day, year,
		hour ? hour : 12, minute, second, ampm);
}

/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1988, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

// This file has the commands for search and replacing in multiple
// files.

#include "eel.h"
#include "grep.h"
#include "colcode.h"

when_loading()	/* disable normal keys, copy some dired definitions */
{

	fix_key_table(reg_tab, (short) normal_character, grep_tab, -1);
	set_list_keys(grep_tab);
	fix_key_table(dired_tab, (short) dired_examine_in_window,
		grep_tab, (short) dired_examine_in_window);
}

command grep() on reg_tab[FALT(7)]
{
	grep_prompt(REGEX | UNKNOWN, has_arg);
}

grep_prompt(flags, inbufs)
{
	char filepat[FNAMELEN];

	_last_was_grep = 1;
	tiled_only();
	iter = 0;
	error_if_input(1);	/* error if we're in the middle of input */
	flags = get_search_string("List lines with: ",
				  flags | (inbufs ? BUFGREP : FILEGREP));
	flags &= ~(INCR | FAILING | BAD | REVERSE);
	if (!inbufs)
		save_var full_path_on_mode_line = 1;
	all_must_build_mode = 1;
	if (!get_grep_file(inbufs, filepat))
		return;
	restore_vars();
	all_must_build_mode = 1;
	do_grep("grep", default_search_string(flags), flags, filepat, inbufs);
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

// Is this file name acceptable in grep (not excluded by
// grep-ignore-file-extentions)?

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

do_grep(buf, pat, flags, filepat, inbufs)
char *buf, *pat, *filepat;
{
	int res = 0, aborted = 0, cnt = 0, tempbuf = 0, i, skipped = 0;
	int orig, before_head, this_err;
	char *s, rel[FNAMELEN], abs[FNAMELEN], search_type[80], *(*finder)();
	spot start;

	create(buf);
	if (grep_empties_buffer)
		zap(buf);
	locate_window(buf, "");
	point = size();
	if (size())
		bprintf("\n");	/* separate from previous query */
	make_search_prompt(search_type, flags & SMODES);
	before_head = point;
	getcd(abs);
	bprintf("Found 0 lines with %s\"%s\" in %s (cur dir \"%s\")\n",
			search_type, pat, filepat, abs);
	set_character_color(before_head, point, color_class grep_header);
	start = alloc_spot(0);
	if (display_column.default != -1)
		display_column = 0;	/* horizontally scroll this window */
	grep_mode();
	finder = give_grep_finder(inbufs, filepat, &s);	// get 1st match
	save_var readonly_warning |= ROWARN_GREP, no_popup_errors = 1;
	readonly_warning &= ~(ROWARN_MSG | ROWARN_BELL);
	orig = bufnum;
	for (; s; s = (*finder)(filepat, 0)) {
		if (!inbufs && !ok_grep_file_match(s)) {
			skipped++;
			continue;
		}
		grep_make_names(rel, abs, s, inbufs);
		noteput("%d matches, searching %s...", cnt, rel);
		if (inbufs)	// skip over grep results buffer
			this_err = !strcmp(s, buf);
		else if (!look_file(abs)) {
			this_err = find_it(abs, default_translation_type);
			if (!grep_keeps_files)
				tempbuf = bufnum;
		} else {
			this_err = 0;
			if (check_dates(0) == 2)
				grep_date_warning(buf, filename);
		}
		if (this_err == EREADABORT || user_abort) {
			aborted = 1;
			break;
		} else if (this_err) {
			window_bufnum = orig;
			if (tempbuf)
				buf_delete(tempbuf);
			tempbuf = 0;
			continue;
		}
		res = copy_matches(name_to_bufnum(buf), flags, pat, rel);
		window_bufnum = orig;
		if (res < 0)	/* error occurred during search */
			break;
		else if (res > 0) {
			cnt += res;
			build_first = 1;
			point = before_head;
			delete(point, point + parse_string(1, "Found [0-9]+ "));
			bprintf("Found %d ", cnt);
			set_character_color(before_head, point, color_class grep_header);
			point = size();
			refresh();
		}
		if (tempbuf)
			buf_delete(tempbuf);
		tempbuf = 0;
	}
	window_bufnum = orig;
	point = i = *start;
	free_spot(start);
	build_first = 1;
	if (tempbuf)
		buf_delete(tempbuf);
	say("");
	if (aborted)
		quick_abort();
	if (res == -DSBAD)
		error("Illegal search pattern: %s", pat);
	else if (res != -DSABORT) {
		locate_window(buf, "");
		modified = 0;
		point = i;
		if (skipped)
			say("Skipped %d files due to grep-ignore-file-extensions", skipped);
	}
}

grep_make_names(rel, abs, s, inbufs)	// put name to use in grep results
char *rel, *abs, *s;				// for any matches in rel
{
	if (inbufs) {
		bufname = s;
		if (*filename)
			relative(filename, rel);
		else
			sprintf(rel, BUFPREFIX "%s", s);
	} else
		relative(s, rel);
	strcpy(abs, rel);
	if (!inbufs)
		absolute(abs);
}

/* copy matches in current buf to other buffer */
/* returns 0=no matches, >0=# of matches, <0= -(error code) */

copy_matches(tobuf, flags, pat, rel)
char *pat, *rel;
{
	int sbuf = bufnum, cnt = 0, i, more, srcherr;
	int before, file, do_color;

	do_color = want_code_coloring && recolor_range;
	save_var point = 0;
	while ((srcherr = do_searching(flags, pat)) == 1) {
		to_begin_line();
		i = point;
		more = nl_forward();
		before = get_buf_point(tobuf);
		buf_printf(tobuf, "%s: ", rel);
		file = get_buf_point(tobuf);
		if (do_color) {			// Color in place, then copy.
			if (do_color == 1 && idle_coloring_size > 1000
				  && (recolor_from_here != recolor_by_lines)) {
				recolor_buffer_range(0, size());
				do_color = 2;		// Color all at once if coloring pieces is
			}						// slow.
			if (do_color == 1)
				recolor_buffer_range(i, point - more);
		}
		buf_xfer_colors(tobuf, i, point - more);
		bufnum = tobuf;
		set_character_color(before, file, color_class grep_filename);
		if (!do_color)
			set_character_color(file, point, color_class grep_text);
		bprintf("\n");
		set_character_color(point - 1, point, color_class grep_filename);
		point = file;
		while ((srcherr = do_searching(flags, pat)) == 1 && point > file) {
			set_character_color(matchstart, matchend, color_class grep_match);
			file = point;
		}
		point = size();
		bufnum = sbuf;
		cnt++;
		if (srcherr)
			return -srcherr;
		if (!more)
			return cnt;
	}
	return srcherr ? -srcherr : cnt;
}

grep_mode()
{
	do_mode_default_settings(1);
	mode_keys = grep_tab;
	major_mode = _grep_mode_name;
	mouse_dbl_selects = 1;
	make_mode();
}

grep_help() on grep_tab['h'], grep_tab['?']
{
	help_on_command("grep-mode");
}

grep_examine() on grep_tab[' '], grep_tab['\n'],
		   grep_tab['e'], grep_tab['\r'], grep_tab[GREYENTER]
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

line_search(dir, s)	/* search for line with only s on it */
char *s;		/* go to its end (if reverse: start) */
{
	int start, end;

	if (!*s)
		return re_search(dir, "^$");
	while (search(dir, s)) {
		start = (dir > 0) ? matchstart : point;
		end = (dir > 0) ? point : matchstart;
		if ((end >= size() - narrow_end || character(end) == '\n')
				&& (start <= narrow_start
					|| character(start - 1) == '\n'))
			return 1;
	}
	return 0;
}

grep_get_curdir(char *dir)
{
	save_var point;
	search(-1, "\nFound ");
	point += parse_string(1, "\nFound .* lines with \"");
	search(1, "\"");
	if (parse_string(1, ".*%(cur dir \"(.*)\"%)\n"))
		grab(find_group(1, 1), find_group(1, 0), dir);
	else
		getcd(dir);
}

count_instances(s)	/* how many times does s occur before pt in this */
char *s;		/* search? */
{
	int count = 0;

	save_var point, narrow_end = size() - point;
	search(-1, "\nFound ");
	save_var narrow_start = point;
	for (; search(1, s); point--)
		count++;
	return count;
}

command next_match()
{
	by_matches(iter);
	iter = 0;
}

command previous_match()
{
	by_matches(-iter);
	iter = 0;
}

by_matches(val)
{
	int owin, win, pt, dir = RE_FORWARD, buf = name_to_bufnum("grep");

	tiled_only();
	_last_was_grep = 1;
	if (!buf)
		error("No grep buffer.");
	win = buf_in_window(buf);
	if (win >= 0) {
		owin = window_handle;
		window_handle = win;
	} else
		bufnum = buf;
	if (val < 0)
		val = -val, dir = RE_REVERSE;
	else
		to_end_line();
	while (val-- > 0)
		if (!re_search(dir, "^(<(>buffer<)> )?[^\n\t]+: "))
			error("No more matches.");
	if (win >= 0) {
		pt = point;
		window_handle = owin;
		bufnum = buf;
		point = pt;
	}
	has_arg = iter = 0;
	grep_examine();
}

command next_position() on cx_tab[CTRL('N')]
{
	if (_last_was_grep)
		next_match();
	else
		next_error();
}

command previous_position() on cx_tab[CTRL('P')]
{
	if (_last_was_grep)
		previous_match();
	else
		previous_error();
}

command keep_matching_lines()
{
	drop_matching_lines(0, "Delete lines not containing: ");
}

command delete_matching_lines()
{
	drop_matching_lines(1, "Delete lines containing: ");
}

drop_matching_lines(drop, pr)
char *pr;
{
	int flags;

	tiled_only();
	iter = 0;
	error_if_input(1);	/* error if we're in the middle of input */
	save_var point;
	flags = get_search_string(pr, UNKNOWN | REGEX | BUFGREP);
	restore_vars();
	flags &= ~(INCR | FAILING | BAD | REVERSE);
	do_drop_matching_lines(flags, default_search_string(flags), drop);
}

// Keep or drop lines after pt matching pattern.
// This version handles patterns that may match \n, but it's much slower.
slow_drop_matching_lines(flags, pat, drop)
char *pat;
{
	int res, cnt = 0;

	save_spot point, narrow_start, narrow_end;
	to_begin_line();
	do {
		narrow_start = point;
		narrow_end = size() - give_end_line();
		res = do_searching(flags, pat);
		narrow_end = 0;
		nl_forward();
		if (res != 0 && res != 1)
			break;
		if (drop && res || !drop && !res)
			delete(narrow_start, point);
		if (res)
			  cnt++;
	} while (point < size() - narrow_end);
	return cnt;
}

do_drop_matching_lines(flags, pat, drop)
char *pat;		// keep or drop lines after pt matching pattern
{
	int res, here, there, cnt = 0;

	flags &= ~REVERSE;
	save_spot point;
	to_begin_line();
	for (;; cnt++) {
		here = point;
		res = do_searching(flags, pat);
		if (res && lines_between(matchstart, matchend, 0)) {
			point = here;	// Must use slow version instead.
			cnt += slow_drop_matching_lines(flags, pat, drop);
			res = 1;
			break;
		}
		if (res != 1 || point == size() - narrow_end)
			break;
		there = give_begin_line();
		nl_forward();
		delete(there, drop ? point : here);
	}
	if (!res && !drop)
		delete(here, size());
	if (!res || res == 1) {
		if (sort_status)
			say("Deleted %s%d line%s.", drop ? "" : "all but ", cnt,
			   cnt == 1 ? "" : "s");
	} else if (res == DSBAD)
		error("Bad search pattern: %s", pat);
	return cnt;
}

command file_query_replace() on reg_tab[FSHIFT(7)]
{
	prompt_file_replace(QUERY | UNKNOWN, has_arg);
}

prompt_file_replace(flags, inbufs)
{		// prompt for replacing in files/buffers, then do it
	char *str, with[FNAMELEN], filepat[FNAMELEN];

	flags = get_replace_text(flags | (inbufs ? BUFGREP : FILEGREP),
				 with);
	if (flags == -1 || !get_grep_file(inbufs, filepat))
		return;
	str = default_search_string(flags);
	do_file_replace(str, with, flags, filepat, inbufs);
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

ask_continue_replace(pr)	// ask question, return 1 if default of yes,
char *pr;			// or 0 if user pressed N
{
	char msg[FNAMELEN];

	drop_pending_says();
	sprintf(msg, "%s in remaining files? ", pr);
	return ask_yn(pr, msg, "Yes", "No", 1);
}

one_file_replace(str, with, flags, oldbuf, old_readonly)
char *str, *with;	// return 0=ok, 1=user said to stop,
{			// DSABORT=aborted, DSBAD=bad pat, -1=no matches
	int res;

	replace_num_found = replace_num_changed = 0;
	save_var point = 0;
	res = do_searching(flags, str);
	if (res != 1)
		return res ? res : -1;
	if (!oldbuf && (flags & FILEGREP))	// had to read file to search
		replace_in_readonly_hook(old_readonly);
	else
		replace_in_existing_hook(old_readonly);
	if (_buf_readonly)
		if ((flags & FILEGREP) && file_info.check_type == CHECK_FILE
			  && (file_info.attr & ATTR_READONLY))
			error("File %r is read-only.", filename);
		else
			error("Buffer %s is read-only.", bufname);
	point = matchstart - 1;
	show_replace(str, with, flags);
	return string_replace(str, with, flags);
}

replace_in_readonly_hook(old_readonly)	// called when file-query-replace
{			// needs to modify a file that might be read-only
	if (file_info.check_type == CHECK_FILE
				&& (file_info.attr & ATTR_READONLY)) {
		save_var readonly_warning = old_readonly;
		do_readonly_warning();
		make_mode();
	}
}

// Epsilon wants to replace in an existing buffer.  (Might be readonly.)

replace_in_existing_hook(old_readonly)
{
	old_readonly = old_readonly;		// prevent compiler warning
}

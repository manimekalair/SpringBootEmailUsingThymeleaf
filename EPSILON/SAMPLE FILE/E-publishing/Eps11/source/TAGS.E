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

// This file contains the commands relating to tags.

#include "eel.h"
#include "tags.h"
#include "c.h"
#include "colcode.h"
#include "bufed.h"

init_tags()		/* read tags if necessary */
{
	char buf[FNAMELEN];

	if (tags_from_bsc)
		return;
	if (!exist("-tags")) {
		if (!look_up_tree(buf, initial_tag_file, NULL, NULL))
			strcpy(buf, initial_tag_file);
		absolute(buf);
		sayput("Loading tags from %s...", buf);
		load_tags(buf);
		say("");
	}
	_tags_buffer = name_to_bufnum("-tags");
}

tags_available()
{
	char buf[FNAMELEN];

	if (tags_from_bsc)
		return 0;
	return (exist("-tags") || look_up_tree(buf, initial_tag_file, NULL, NULL));
}

tags_header()	/* return length of tags file header */
{		/* header line says if tags file is sorted */
	point = 0;		/* also goes to top */
	return parse_string(1, "<tab>TAGS<tab>(UN)?SORTED\n", NULL);
}

are_tags_sorted()	/* -1: no header, 0=not sorted, 1=sorted */
{			/* also goes to top */
	return tags_header() ? (character(6) == 'S') : -1;
}

mark_tags(sorted)	/* update header line (adding if needed) */
{
	bufnum = _tags_buffer;
	if (are_tags_sorted() != sorted) {
		delete(0, tags_header());
		bprintf("\tTAGS\t%sSORTED\n", sorted ? "" : "UN");
	}
}

load_tags(file)
char *file;
{
	int i;

	tags_from_bsc = 0;
	*_last_tag = *_last_tag_file = 0;
	if (!strfcmp(get_extension(file), ".bsc")) {
		tags_from_bsc = 1;
		strcpy(bsc_file, file);
		absolute(bsc_file);
		return;
	}
	save_var bufnum = _tags_buffer = zap("-tags");
	i = read_file(file, FILETYPE_AUTO);
	if (i == 2)			/* new file */
		mark_tags(0);		/* make new-fmt tags file */
	else if (i) {			/* error reading file */
		restore_vars();
		delete_buffer("-tags");
		quick_abort();
	} else if (!tags_header()) {
		if (!ask_yn("Convert", "Convert old-format tags file? ",
					"Yes", "No", 1))
			quick_abort();
		sayput("Converting old-format tags file...");
		if (!string_replace(";", "\t", 0)) {
			mark_tags(0);
			do_save_tags();
		}
	}
}

do_save_tags()		/* save tags to their file if unsaved */
{
	int oldbuf = bufnum;

	if (exist("-tags")) {
		bufnum = _tags_buffer;
		if (modified) {
			if (size() > 2000000)
				sayput("Saving tags...");
			do_save_file(1, 1, 1);
		}
		bufnum = oldbuf;
	}
}

command sort_tags()	/* sort & save if needed */
{
	init_tags();
	if (tags_from_bsc)
		error("This type of tag file may not be sorted.");
	bufnum = _tags_buffer;
	if (are_tags_sorted() == 1)
		return;
	sayput("Sorting tags...");
	save_var narrow_start = tags_header();	/* don't sort header */
	save_var sort_status = 1;
	save_var abort_searching = ABORT_ERROR;
	if (sort_another("-tags", 0, 0))
		return;		/* user aborted */
	narrow_start = 0;
	delete(0, tags_header());	/* remove header */
	mark_tags(1);		/* add header saying it's sorted */
	do_save_tags();
}

char *tag_match(s, flags) 
char *s;
{
	char tmp[TAGLEN];

	if (tags_from_bsc) {
		strcpy(_this_match, s);
		return (flags & STARTMATCH) ? s : 0;
	}
	save_var bufnum;
	save_var abort_searching = 0;
	bufnum = _tags_buffer;
	save_var case_fold = !tag_case_sensitive;
	if (flags & STARTMATCH)
		point = 0;
	if (*s) {
		sprintf(tmp, "^([^\t\n]+(::|'))?%s", s);
		do {
			if (!search(1, s))
				return 0;
		} while (!parse_string(-1, tmp)
				 || (flags & EXACTONLY) && curchar() != '\t');
		to_begin_line();
	} else if (!nl_forward() || point == size())
		return 0;
	parse_string(1, "[^\t\n]+", _this_match);
	to_end_line();
	return _this_match;
}

	/* make list of matches for s in mbuf */
tag_lister(char *s, char *(*finder)(), int flags, int mbuf)
{
	char pat[TAGLEN], look_for[TAGLEN];
	int sorted;

	finder = finder;	/* silence eel's warning */
	flags = flags;
	save_var bufnum;
	save_var abort_searching = 0;
	if (tags_from_bsc) {
		buf_printf(mbuf, "%s", s);
		return;
	}
	if (!*s) {
		tags_look_for(look_for);
		if (*look_for) {
			s = look_for;
			save_var tag_list_exact_only = 1;
		}
	}
	if (want_sorted_tags && !*s)
		sort_tags();
	bufnum = _tags_buffer;
	save_var case_fold = !tag_case_sensitive;
	sorted = are_tags_sorted();	/* also goes to top */
	if (*s) {
		sprintf(pat, "^([^\t\n]+(::|'))?%q", s);
		while (search(1, s)) {
			if (parse_string(-1, pat)
				&& (!tag_list_exact_only || curchar() == '\t')) {
				to_end_line();
				buf_xfer(mbuf, matchend, point + 1);
			}
		}
	} else {
		nl_forward();
		buf_xfer(mbuf, point, size());
	}
	bufnum = mbuf;
	if (want_sorted_tags && !sorted && !user_abort) {
		abort_searching = ABORT_ERROR;
		sort_another(bufnum_to_name(mbuf), 0, 0);
	}
	point = 0;
	tab_size = 30;
	goal_column = display_column = 0;
}

get_tag(res, pr)	/* do completion on tags */
char *res, *pr;		/* returns either tag, or tag <Tab> file */
{			/* or tag <Tab> file <Tab> pos */
	save_var menu_width = 60, completion_lister = tag_lister;
	comp_read(res, pr, tag_match, (tag_case_sensitive ? 0 : COMP_FOLD)
			  | MUST_MATCH | NONE_OK | CAUTIOUS, "");
}

tag_searcher_c(char *tag)
{
	char classname[FNAMELEN], fulltag[FNAMELEN], pr[FNAMELEN];
	int err, cnt = 0, selected = 0, try = 1;

	if (parse_string(-1, "-%>|%.[ \t\n]"))	// Ignore func's class.
		*classname = 0;
	else
		find_c_func_info(NULL, classname, NULL, 0);
again:
	strcpy(fulltag, tag);
	if (!strchr(tag, ':')) {		// Class not known yet.
		if (*classname && strcmp(classname, tag)) {		// See if current class 
			sprintf(fulltag, "%s::%s", classname, tag);	// has such a member.
			if (!(err = go_tag(fulltag, 1)))
				return err;
			bufnum = window_bufnum;
		}			// Is there more than one function by that name in any class?
		*fulltag = 0;
		bufnum = window_bufnum;
		if (tag_match(tag, STARTMATCH | EXACTONLY)) {
			do {
				cnt++;
			} while (tag_match(tag, EXACTONLY));
			if (cnt != 1) {
				sprintf(pr, "%d matches for %s: ", cnt, tag);
				save_var menu_width = 60, completion_lister = tag_lister;
				save_var insert_default_response = 2, tag_list_exact_only = 1;
				ungot_key = '?';
				comp_read(fulltag, pr, tag_match, (tag_case_sensitive ? 0 : COMP_FOLD)
						  | MUST_MATCH | NONE_OK | CAUTIOUS, tag);
				selected = 1;
			} else
				strcpy(fulltag, tag_match(tag, STARTMATCH | EXACTONLY));
		} else
			strcpy(fulltag, tag);
	}
	err = go_tag(fulltag, 1);
	strcpy(_last_tag, tag);
	if (err && !selected) {		// Try retagging current file before giving up.
		bufnum = window_bufnum;
		sprintf(pr, "Tag %s has moved, retag file %s? ",
				fulltag, filename);
		if (!tag_ask_before_retagging || try > 1
			  || ask_yn("Retag file", pr, "Yes", "No", 1)) {
			if (try < 2)
				do_retag_file(filename);
			err = go_tag(fulltag, 1);
			if (try < 2)
				do_save_tags();
			if (err && try++ < 2)
				goto again;
			if (!err)
				say("Found %s in this file.", tag);
		}
	}
	if (!err && !selected && strcmp(tag, fulltag))
		say("Searched for %s, found %s", tag, fulltag);
	report_tag_error(err);
}

// Adjust the name of a tag to indicate what we'll really search for.
tag_prompter_c(char *tag)
{
	char *p = _last_tag, *q;

	for (;;) {
		if ((q = strstr(p, "::")) && q[2])
			p = q + 2;		// Remove classname:: prefix.
		else if ((q = strstr(p, "'")) && q[1])
			p = q + 1;		// Remove classname' prefix for Perl.
		else
			break;
	}
	strcpy(tag, p);
}

// Search for another instance of the last tag (1==next instance,
// -1==previous, 0==same as before.  Return nonzero if we couldn't find
// any such tag, zero if could (and move to it).

tag_to_next_c(char *pat, int n_fwd)
{
	char raw_tag[FNAMELEN];

	tag_prompter_c(raw_tag);		// strip class names
	sprintf(pat, "^([^\t\n]+(::|'))?%q\t", raw_tag);
	return !tag_search_by_offset(pat, n_fwd);
}

modal_goto_tag(char *tag)
{
	char tag_searcher[FNAMELEN], fulltag[FNAMELEN], pr[FNAMELEN];
	int i, err;

	quiet_set_bookmark();
	sprintf(tag_searcher, "tag_searcher_%s", major_mode);
	i = find_index(tag_searcher);
	if (*tag && !strchr(tag, '\t'))		// If not yet fully specified,
		switch (name_type(i)) {		// Call mode-specific version.
			case NT_SUBR: case NT_COMMAND:
			case NT_AUTOSUBR: case NT_AUTOLOAD:
				(*(int (*)())i)(tag);
				return;
		}
	strcpy(fulltag, tag);
	err = go_tag(fulltag, 1);
	bufnum = window_bufnum;
	if (err && can_tag_a_file(filename)) {
		sprintf(pr, "Tag %s has moved, retag file %s? ", fulltag, filename);
		if (!tag_ask_before_retagging
			  || ask_yn("Retag file", pr, "Yes", "No", 1)) {
			do_retag_file(filename);
			err = go_tag(fulltag, 1);
			do_save_tags();
			if (!err)
				say("Found %s in this file.", fulltag);
		}
	}
	report_tag_error(err);	// Default behavior.
}

command pluck_tag() on cx_tab[',']
{		 /* read a function name at point & go there via tags */
	char tag[TAGLEN], *tag_pat;

	tag_pat = get_mode_string_variable("tag-pattern-%s");
	if (got_bad_number || !tag_pat)
		tag_pat = tag_pattern_default;
	tiled_only();
	init_tags();
	iter = 0;
	point--;
	re_search(1, tag_pat);
	re_search(-1, tag_pat);
	re_search(1, tag_pat);	// Needed in case we start inside "operator".
	re_search(-1, tag_pat);
	grab(point, matchstart, tag);
	modal_goto_tag(tag);
}

// Figure out what name to include in the prompt.
tags_look_for(char *tag)
{
	char tag_prompter[FNAMELEN];
	int i;

	strcpy(tag, _last_tag);
	if (buf_exist(prompt_orig_buf))
		save_var bufnum = prompt_orig_buf;
	sprintf(tag_prompter, "tag_prompter_%s", major_mode);
	i = find_index(tag_prompter);
	switch (name_type(i)) {		// Call mode-specific version.
		case NT_SUBR: case NT_COMMAND:
		case NT_AUTOSUBR: case NT_AUTOLOAD:
			(*(int (*)())i)(tag);
	}
}

command goto_tag() on cx_tab['.'] /* asks for a tag, then goes there */
{
	char tag[TAGLEN], pr[FNAMELEN], look_for[FNAMELEN];

	tiled_only();
	init_tags();
	iter = 0;
	*tag = 0;
	tags_look_for(look_for);
	if (!has_arg) {
		if (!*_last_tag)
			sprintf(pr, "Find tag: ");
		else if (tags_from_bsc)
			sprintf(pr, "Find tag [next %s]: ", look_for);
		else
			sprintf(pr, "Find tag [next %s of %d]: ",
					look_for, count_tags(look_for));
		if (*_last_tag)
			save_completion(_last_tag, tag_match);
		get_tag(tag, pr);
	}
	modal_goto_tag(tag);
}

command next_tag() on reg_tab[NUMCTRL(GREYPLUS)]
{
	quiet_set_bookmark();
	next_prev_tag(iter);
	iter = 0;
}

command previous_tag() on reg_tab[NUMCTRL(GREYMINUS)]
{
	quiet_set_bookmark();
	next_prev_tag(-iter);
	iter = 0;
}


next_prev_tag(dir)
{
	init_tags();
	if (tags_from_bsc) {
		char fname[FNAMELEN];
		int linenum;

		if (!browser_find_match(fname, &linenum, dir))
			say("No %smatches.", dir ? "more " : "");
		else
			get_to_tag_match_line(fname, linenum);
		if (dir)
			say("Going to %s instance of %s",
				(dir > 0) ? "next" : "previous", _last_tag);
	} else
		must_go_tag("", dir);
}

position_to_tag_line()
{
	to_begin_line();
	if (point < window_start || point > window_end)
		window_start = prev_screen_line(show_tag_line);
}


// Get to a tag match by line number (counting from 1).

get_to_tag_match_line(char *fname, int linenum)
{
	char tdir[FNAMELEN];

	strcpy(_last_tag_file, fname);
	strcpy(tdir, bsc_file);
	*get_tail(tdir, 0) = 0;
	absolute(_last_tag_file, tdir);
	locate_window("", _last_tag_file);
	if (find_it(_last_tag_file, default_translation_type))
		return;	// Error reading the file, already reported.
	go_line(linenum);
	window_start = prev_screen_line(show_tag_line);
}

// Return nonzero if we can't find the tag.
go_bsc_tag(char *s)
{
	if (!*s) {		// Old way to go to next tag.
		next_prev_tag(1);
		return 0;
	}
	if (browser_query(bsc_file, s, 0) == -1)	// error
		return 1;
	strcpy(_last_tag, s);
	next_prev_tag(0);
	return 0;
}

// Take result code from go_tag() and report error if any.
report_tag_error(int err)
{
	if (err == 1)
		error("%s is not in the tag list", _last_tag);
	else if (err == 2)
		error("%s is not in file %s", _last_tag, _last_tag_file);
}

/* Find this tag, complain if not found. */
/* If s is "", look for a duplicate tag.  In that case, n_fwd determines
   which one: 1==next, -1==previous, 0==same as before. */

must_go_tag(s, n_fwd)
char *s;
{
	report_tag_error(go_tag(s, n_fwd));
}

/* Return 0 if ok, 1 if not a tag, 2 if not in that file. */
/* If s is "", look for a duplicate tag.  In that case, n_fwd determines
   which one: 1==next, -1==previous, 0==same as before. */
/* This routine hands off to the BSC stuff if necessary, and also
   does retagging and searching again when appropriate. */

go_tag(s, n_fwd)
char *s;
{
	char msg[FNAMELEN];
	short err;

	if (!*s && !*_last_tag)
		error("No current tag.");
	if (tags_from_bsc)
		return go_bsc_tag(s);
	err = do_go_tag(s, n_fwd);
	if (err != 2)
		return err;
	if (narrow_start || narrow_end) {
		say("Tag not found in narrowed buffer, removing narrowing.");
		narrow_start = narrow_end = 0;
		make_mode();
		err = do_go_tag(_last_tag, n_fwd);
		if (err != 2)
			return err;
	}
	if (can_tag_a_file(_last_tag_file)) {
		sprintf(msg, "Tag %s has moved, retag file %s? ",
				_last_tag, _last_tag_file);
		if (tag_ask_before_retagging)
			if (!ask_yn("Retag file", msg, "Yes", "No", 1))
				return 0;
		do_retag_file(_last_tag_file);		// Tag has moved, so retag.
		do_save_tags();
	}
	return do_go_tag(_last_tag, n_fwd);
}

// Search for nth occurrence of the tag pat, wrapping if necessary.
// N may be negative (or 0 to repeat the last one).
// Return 1 if we found one, 0 if there are none.

tag_search_by_offset(char *pat, int n_fwd)
{
	int dir = RE_FORWARD;

	if (n_fwd < 0){
		dir = RE_REVERSE;
		n_fwd = -n_fwd;
		to_begin_line();
	} else if (n_fwd > 0) {
		to_end_line();
	} else {			// n_fwd == 0: return current match again
		to_begin_line();
		n_fwd = 1;
	}
	while (n_fwd-- > 0)
		if (!re_search(dir, pat)) {
			point = (dir == RE_FORWARD) ? 0 : size();
			if (!re_search(dir, pat))	// Wrap and repeat.
				return 0;
		}
	return 1;
}

// How many tags have this name?
count_tags(char *s)
{
	char pat[FNAMELEN], *p, tag[FNAMELEN], fast_pat[FNAMELEN];
	int cnt = 0;

	strcpy(tag, s);
	if (p = index(tag, '\t'))
		*p = 0;		/* remove file name from tag spec */
	sprintf(pat, "^([^\t\n]+(::|'))?%q\t", tag);
	sprintf(fast_pat, "%s\t", tag);
	save_var bufnum = _tags_buffer;
	save_var case_fold = !tag_case_sensitive;
	save_var point = 0;
	while (search(1, fast_pat))
		if (parse_string(-1, pat))
			cnt++;
	return cnt;
}

/* Go to tag s, return 0=ok, 1=no such tag, 2=tag moved. */
/* If s is "", look for a duplicate tag.  In that case, n_fwd determines
   which one: 1==next, -1==previous, 0==same as before. */

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

prox_line_search(p)	/* search for line with p on it closest to point */
char *p;		/* and go there, return 1, else 0 */
{
	int orig = point, fwd, bwd, fwdok, bwdok;

	fwdok = line_search(1, p);
	fwd = point;
	point = orig;
	bwdok = line_search(-1, p);
	bwd = point;
	point = orig;
	if (!fwdok && !bwdok)	/* neither one found it, fail */
		return 0;
	if (fwdok && bwdok)	/* if both found it, use closest */
		fwdok = (fwd - point) <= (point - bwd);
	point = fwdok ? fwd : bwd;
	return 1;
}

command select_tag_file() on cx_tab[ALT(',')]
{				/* switch to a particular tags file */
	char file[FNAMELEN], *def = initial_tag_file;
	int old = bufnum;

	do_save_tags();
	if (tags_from_bsc)
		def = bsc_file;
	else if (exist("-tags")) {
		bufname = "-tags";
		def = filename;
		bufnum = old;
	}
	save_var only_file_extensions = "|.tag|.bsc|";
	get_file(file, "Tag or browser file", def);
	load_tags(file);
	say("Tags loaded from %s", file);
}

command clear_tags()	/* erase all tags */
{
	init_tags();
	if (tags_from_bsc)
		error("Delete the .BSC file %s to remove all tags.", bsc_file);
	buf_zap(_tags_buffer);
	mark_tags(1);
	do_save_tags();
}

// List the names of all files we've tagged in buffer b.  The file
// names will be relative to the tag file's directory.
get_tagged_file_names(int b)
{
	int p, above = 0;
	char this[FNAMELEN], last[FNAMELEN];

	buf_zap(b);
	save_var bufnum = _tags_buffer;
	point = 0;
	*last = 0;
	while (nl_forward()) {
		if (!search(1, "\t"))
			break;
		p = point;
		if (!search(1, "\t"))
			break;
		grab(p, point - 1, this);
		if (!strcmp(this, last))
			continue;
		strcpy(last, this);
		buf_printf(b, "%s\n", this);
		if (point > above) {
			noteput("Extracting file names: %2d%%...",
					muldiv(point, 100, size()));
			above += 50000;
			check_abort();
		}
	}
	bufnum = b;
	do_sort_region(0, size(), 0, 0);
	do_uniq(1, 1, 0);
	point = 0;
	say("");
}

command untag_files()
{
	int t, p, count;
	char this[FNAMELEN], resp[FNAMELEN], msg[FNAMELEN];

	init_tags();
	if (tags_from_bsc)
		error("Can't modify a .BSC file.");
	t = zap(TAGGED_FILES_BUF);
	get_tagged_file_names(t);

	save_var bufnum, window_bufnum;
	to_buffer_num(t);
	p = tmp_buf();
	buf_xfer(p, 0, size());
	point = 0;
	stuff("# Press Ctrl-X Ctrl-Z to untag all files not named below.\n");
	stuff("# Only files remaining in this list will keep their tags.\n\n");
	recursive_edit();
	if (!buf_exist(t) || !buf_exist(p)) {
		say("No files untagged.");
		return;
	}
	to_buffer_num(t);
	simple_re_replace(1, "^(# .*)?\n", "");
	restore_vars();
	do_compare_sorted(t, p, NULL, "-untag-these-files", NULL);
	buf_delete(p);

	save_var bufname = "-untag-these-files";
	count = lines_between(0, size(), 0);
	restore_vars();
	sprintf(msg, (count == 1) ? " Untag this %d file? "
							  : " Untag these %d files? ", count);
	if (!(is_gui && want_gui_prompts))
		say("%s", msg + 1);
	else
		say("");
	if (count) {
		save_var _view_title = msg;
		save_var paging_retains_view = 1;
		view_buffer("-untag-these-files", 0);
		if (is_gui && want_gui_prompts && key == abort_key)
			count = 0;		// User clicked Cancel.
		else if (is_gui && want_gui_prompts) {	// Already prompted so don't
			if (toupper(key) != 'Y' && !IS_ENTER_KEY(key) // ask again.
				&& toupper(key) != 'O')
				count = 0;
			ungot_key = -1;
		} else {
			get_string(resp, msg + 1);
			if (toupper(*resp) != 'Y')
				count = 0;
		}
		user_abort = 0;
	}
	if (count) {
		save_var bufname = "-untag-these-files";
		for (point = 0; point < size(); nl_forward()) {
			grab(give_begin_line(), give_end_line(), this);
			if (size() > 1000)
				noteput("Deleting tags: %2d%%...", muldiv(point, 100, size()));
			do_delete_tags(this);
		}
		do_save_tags();
		say("%d file%s untagged.", count, count == 1 ? "" : "s");
	} else
		say("No files untagged.");

	restore_vars();
	delete_buffer("-untag-these-files");
	buf_delete(t);
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

command tag_files() on cx_tab[ALT('.')]
{
	char pat[FNAMELEN], *s, file[FNAMELEN];
	int aborted = 0;

	init_tags();
	if (tags_from_bsc)
		error("Must tag files using the BSCMAKE program.");
	if (has_arg)
		save_var tag_declarations = 3;
	get_file(pat, "Add/update tags for files matching", filename);
	iter = 0;
	if (!(s = do_file_match(pat, STARTMATCH | EXACTONLY | FM_NO_DIRS)))
		error("No matches");
	to_another_buffer("-tag-errors");
	delete_buffer("-tag-errors");
	save_var tag_batch_mode = 1;
	for (; s; s = do_file_match(pat, EXACTONLY | FM_NO_DIRS)) {
		strcpy(file, s);
		absolute(file);
		if (aborted = do_retag_file(file))
			break;
	}
	if (!aborted) {
		do_save_tags();
		say("%s tagged.", pat);
	}
	if (exist("-tag-errors")) {
		to_buffer("-tag-errors");
		discardable_buffer = 1;
	}
}

// Is there a tagging function for this file?
can_tag_a_file(s)
char *s;
{
	char subr[FNAMELEN], def[FNAMELEN], *pattern = "tag-suffix-%s";

	s = get_extension(s);
	sprintf(subr, pattern, *s ? (s + 1) : "none");
	sprintf(def, pattern, "default");
	return find_index(subr) || find_index(def);
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

tag_suffix_none()
{
	char mode[FNAMELEN];

	if (guess_mode_without_extension(mode, "tag-suffix-%s"))
		try_calling(mode);
}

tag_suffix_asm()	/* tag all labels or procs in the file */
{
	char func[TAGLEN];
	int start, ofold = case_fold;

	case_fold = 1;
	while (re_search(1, "^[ \t]*([a-z0-9@$_]+)[ \t]*:")) {
		grab(start = find_group(1, 1), find_group(1, 0), func);
		add_tag(func, start);
	}
	point = 0;
	while (re_search(1, "^[ \t]*([a-z0-9@$_]+)[ \t]+proc[ \t\n;]+")) {
		grab(start = find_group(1, 1), find_group(1, 0), func);
		add_tag(func, start);
	}
	case_fold = ofold;
}

tag_suffix_e()		{	tag_suffix_c();	}
tag_suffix_h()		{	tag_suffix_c();	}
tag_suffix_y()		{	tag_suffix_c();	}
tag_suffix_cpp()	{	tag_suffix_c();	}
tag_suffix_cc()		{	tag_suffix_c();	}
tag_suffix_cxx()	{	tag_suffix_c();	}
tag_suffix_hpp()	{	tag_suffix_c();	}
tag_suffix_hxx()	{	tag_suffix_c();	}
tag_suffix_inl()	{	tag_suffix_c();	}
tag_suffix_java()	{	tag_suffix_c();	}
tag_suffix_cs()		{	tag_suffix_c();	}

tag_suffix_c()		/* tag all c functions in this file */
{
	int end;

	save_var case_fold = 0;	// don't confuse STRUCT with struct
	tag_extern_decl = 0;
	*c_tagging_class = 0;	// initially, not inside a class block
	while (re_search(1, "([{};<]|/<*|/>|[a-zA-Z0-9_]+)")) {
		end = point;		/* find braces, ;, <, comment open, or ident */
		point = matchstart;
		switch (curchar()) {
			case '{':	skip_c_braces();
						break;
			case '<':	skip_cpp_template();
						break;
			case '}':	*c_tagging_class = 0;
						point++;
						break;
			case ';':	tag_extern_decl = 0;	// assume next var
						point++;		// is being defined
						break;
			case '/':	if (character(point + 1) == '*') {
							point += 2;
							search(1, "*/");
						} else
							nl_forward();	/* c++ comment */
						break;
			default:	if (!good_c_tag())
							point = end;
						break;
		}
	}
}

// We're just before an instance of the start character.  Go to the
// matching end character and return 0.  If we can't find it, return
// 1 if too many start characters or 2 if too many end characters,
// and restore point to start if restore!=0.  Attempt to handle
// preprocessor conditionals by skipping over #else clauses when
// appropriate.

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

skip_cpp_template()		/* skip over matched <> pairs */
{
	int start = point;		/* Don't look too far for them. */

	save_var narrow_end = size() - (point + 200);
	if (skip_c_delims('<', '>', 1))		// unmatched character
		point = start + 1;	// Skip over that <, we can't match it.
}

skip_c_braces()		/* skip over c function definition */
{
	if (parse_string(-1, "<dquote>[A-Za-z0-9_]*<dquote>[ \t\n]*") && !at_c_comment(point, 0)
		&& !parse_string(-1, "color_scheme.*")) {
		point++;	// if C++'s extern "C" { or similar, don't skip
		return;
	}
	skip_c_delims('{', '}', 0);
}

good_c_tag()	// tag name at point if a valid c tag
{		// return 0 to go back to orig point before searching again
	char func[TAGLEN], tmp[TAGLEN];
	int start = point, i = 1;

	if (!parse_string(1, "[a-zA-Z0-9_]+", func))
		return 0;
	else if (!strcmp(func, "struct") || !strcmp(func, "union"))
		return tag_c_struct(0);		// maybe struct tag
	else if (!strcmp(func, "class"))
		return tag_c_struct(1);		// or similar class def
	else if (!strcmp(func, "interface") && (c_extra_keywords & JAVA_KEYWORDS))
		return tag_c_struct(1);		// for java: like a class
	else if (!strcmp(func, "enum"))
		return tag_c_struct(2);		// or similar enum def
	else if (!strcmp(func, "namespace"))
		return tag_c_struct(3);		// or namespace def
	else if (!strcmp(func, "operator") && parse_string(1, CPP_OPLIST)) {
		grab(matchstart, matchend, func + strlen(func));
		point = matchend;
	} else if (!strcmp(func, "extern")) {
		tag_extern_decl = 1;	// next vars are just declarations
		return 1;
	} else if (!strcmp(func, "__declspec")) {
		return 1;
	} else if (parse_string(-1, "^[ \t]*#[^#\n]*"))
		return tag_c_define(func);	// do preproc line
	c_fwd_space();
	if (curchar() == '_' && parse_string(1, "(_ANSI_ARGS_|__P)</word>")) {
		point = matchend;	// skip over arg-hiding macro
		c_fwd_space();
	}
	if (curchar() == '(') {
		if (matches_at(start, -1, "~[ \t]*")) {
			point = matchend;
			parse_string(1, "~[ \t]*[a-zA-Z0-9_]+", func);
		}
		i = tag_c_func(1);
	} else if (curchar() == ':' && parse_string(1, "::[ \t\n]*"
			"(_?(near|far)[ \t\n]+)?([a-zA-Z0-9_~]+|" CPP_OPSPEC ") *%(")) {
		strcat(func, "::");	// make raw class::func w/o spaces
		grab(find_group(3, 1), find_group(3, 0), func + strlen(func));
		i = tag_c_func(1);
	} else if (tag_c_variable() && ((tag_declarations & 2)
									|| !tag_extern_decl))
		i = 2;
	if (i == 2 && !isdigit(*func)) {
		if (*c_tagging_class && !index(func, ':')) {
			strcpy(tmp, func);	// put class:: before func name
			sprintf(func, "%s::%s", c_tagging_class, tmp);
		}
		add_tag(func, start);
	}
	return i;
}

// Skip over a thing that might appear before the function body, and
// return 1 if we did.

tag_c_skip_before_body(int show)
{
	if (parse_string(1, "#.*(\\\n.*)*")) {
		point = matchend;
		return 1;
	}
	if (parse_string(1, "(try|const|volatile)![^_A-Za-z0-9]")) {
		point = matchend;
		return 1;
	}
	if (parse_string(1, "throws[ \t]")) {	// for java
		point = matchend;
		skip_identifier_list();
		return 1;
	}
	if (parse_string(1, "throw[ \t]*!%(")) {	// for C++
		point = matchend;
		if (skip_c_delims('(', ')', 1)) {
			if (show)
				buffer_printf("-tag-errors", "Couldn't parse %s at line %d\n",
							  filename, lines_between(0, point, 0) + 1);
			return 0;
		}
		return 1;
	}
	return 0;
}

// We're positioned between an identifier and a left paren (and not
// inside a function body).  Return 2 (yes) if it looks like a function
// definition (or optionally a declaration), and we should therefore tag
// it.  Move just before the function body or semicolon if so.

// Otherwise, return 0 if we should go back to our starting point and
// look for more identifiers from there, or 1 if we should stay where
// this function moved to, and continue searching from there.

// We also use this function to help recognize function definitions in
// other contexts than tagging.

tag_c_func(show)
{
	int ret = 2;

	if (skip_c_delims('(', ')', 1)) {
		if (show)
			buffer_printf("-tag-errors", "Couldn't parse %s at line %d\n",
						  filename, lines_between(0, point, 0) + 1);
		return 0;	/* after identifier, skip over arg list */
	}
	c_fwd_space();
	while (tag_c_skip_before_body(show))
		c_fwd_space();
	if (parse_string(1, "on[ \t]")) {	// eel command
		search(1, "\n{");
		point--;
		ret = 2;
	} else if (parse_string(1, "[A-Za-z{]")) // func definition
		ret = skip_param_decls();
	else if (curchar() == ':')		// C++ initializer
		ret = skip_cpp_init();
	else if (curchar() == '=')		// C++ function using =0.
		return 2;
	else if (!parse_string(1, "[,;]"))	// not even a declaration
		ret = (point >= size());	// Skip parens if it looks like a macro.
	else if (!(tag_declarations & 1))	// a declaration, don't tag it?
		ret = 1;
	if (ret)
		tag_extern_decl = 0;
	return ret;
}

skip_cpp_init()		// found base class initializer, skip past it
{
	if (!search(1, "{"))
		return 0;
	point--;
	return 2;
}

// We're just past the ) of an apparent func definition.
// There should be a { now, with perhaps some old-style param declarations
// before it.  Skip past the { and return 2.  If this doesn't look like
// a func definition after all, go back to where started and return 1.

skip_param_decls()
{
	int orig = point, last;

	save_var narrow_end = size() - (point + 5000);
	c_fwd_space();
	if (curchar() == '{')		// No params.
		return 2;
	do {
		last = point;
		if (curchar() == '{' && semi_before(point))
			return 2;	// had ; just before {, good decls
		point += parse_string(1, "[][a-zA-Z0-9_@;,()*]*");
		c_fwd_space();
	} while (last != point);
	point = orig;		// these weren't param decls, go back
	return 1;
}

semi_before(p)	// is there a semicolon just before p (ignoring comments)?
{
	save_var point = p;
	return !cind_try_space() && character(point - 1) == ';';
}

// Move past a series of comma-separated identifiers with
// whitespace/comments between.  Return how many.
int skip_identifier_list()
{
	int cnt = 0;
	for (;; point++) {
		c_fwd_space();
		if (!parse_string(1, "[a-zA-Z0-9_.]+"))
			break;
		point = matchend;
		cnt++;
		c_fwd_space();
		if (curchar() != ',')
			break;
	}
	return cnt;
}

// Tag the following structure/class/enum if we're defining a tag for it.
// Flavor: 0=struct/union, 1=class/interface, 2=enum, 3=namespace.
tag_c_struct(int flavor)
{
	char func[TAGLEN];
	int start;

	c_fwd_space();
	start = point;
	if (!parse_string(1, "[a-zA-Z0-9_]+", func)) {
		if (flavor != 1)
			*func = 0;	// all but class don't require a name
		else
			return 1;
	}
	c_fwd_space();	// skip compiler-specific junk betw "class" & name
	if (flavor == 1 && !is_java_buffer() && parse_string(1, "[a-zA-Z0-9_]+")) {
		parse_string(1, "[a-zA-Z0-9_]+", func);
		c_fwd_space();
	}
	if (curchar() != '{' && (flavor != 1 || !parse_other_class()))
		return 1;	// classes can have other stuff before {
	if (flavor == 1 || flavor == 3 || flavor == 0) {
		point++;	// skip over { so we do stuff within
		strcpy(c_tagging_class, func);	// remember, now in class
	} else if (flavor == 2)
		tag_c_enum();
	if (*func)
		add_tag(func, start);
	return 1;
}

/* We've parsed "class foo" but there's no { character right after.
 * See if there's some inheritance information we can skip past to find
 * the { character.
 * Return nonzero if we found ": foo {" or similar (C++).
 * Return nonzero if we found Java's "extends foo implements bar {" or similar.
 * In either case, move before the final { character.  Otherwise return
 * zero.
 */
parse_other_class()
{
	if (curchar() == ':') {
		point++;
		for (;;) {
			c_fwd_space();
			if (!parse_string(1, "[a-zA-Z0-9_]+|,"))
				break;
			point = matchend;
			if (curchar() == '<')
				point += parse_string(1, "%<[a-zA-Z0-9_, \n\t]+%>");
		}
		c_fwd_space();
	} else if (is_java_buffer()) {
		while (strchr("ei", curchar())
			   && parse_string(1, "(extends|implements)</word>")) {
			point = matchend;
			skip_identifier_list();
		}
	}
	return curchar() == '{';
}

tag_c_enum()	// just before { of enum list; tag them all
{
	char name[TAGLEN];

	do {
		point++;
		c_fwd_space();
		if (!parse_string(1, "[a-zA-Z0-9_]+", name))
			return;
		add_tag(name, matchstart);
		c_fwd_space();
		if (curchar() == '=')
			skip_initializer();
	}  while (curchar() == ',');
}

tag_c_define(keyw)	// found a preproc line, maybe enter #define
char *keyw;		// either way, skip past line
{
	char func[TAGLEN];
	int start;

	if (!strcmp(keyw, "asm"))	// Found #asm, look for matching #endasm.
		return re_search(1, "^[ \t]*#[^#\n]*endasm");
	if (!strcmp(keyw, "define")) {
		point += parse_string(1, "[ \t]*");
		start = point;
		if (parse_string(1, "[a-zA-Z0-9_]+", func) && !isdigit(*func))
			add_tag(func, start);
	}
	if (parse_string(1, ".*/<*>"))
		search(1, "*/");
	do {
		if (!nl_forward())
			break;
	} while (character(point - 2) == '\\');
	return 1;
}

tag_c_variable()	// is this a var definition?
{
	if (parse_string(1, "([) \t\n]|<[>[^]\n]*<]>)*[,;=]")) {	
		point = matchend;	// ordinary variable definition
		if (character(point - 1) == '=')
			skip_initializer();
	} else if (parse_string(1, "[ \t\n]*<)>+[ \t\n]*!"
							"(_ANSI_ARGS_|__P)?<(>"))
		re_search(1, "![;{]");	// func ptr definition
	else
		return 0;
	return 1;
}

skip_initializer()		// move past c initializer
{		
	int level = 0;

	c_fwd_space();
	if (curchar() == '{')	// don't bother skipping over {}'s,
		return;		// caller does that anyway
	while (re_search(1, "[,;(){}'\"]"))
		switch (character(point - 1)) {
			case '"':
			case '\'':	point--;
						c_skip_item(curchar(), RE_FORWARD);
						break;
			case ',':
			case ';':	if (level < 0)
							break;
						point--;
						return;
			case '(':	level--; break;
			case ')':	level++; break;
			case '{':
			case '}':	point--;
						return;
		}
}

c_fwd_space()	/* move fwd past whitespace or comments */
{
	while (point < size() - narrow_end)
		switch (curchar()) {
		case ' ': case '\t': case '\n':
			point++; break;
		case '/':
			switch (character(point + 1)) {
			case '*':	point += 2; search(1, "*/"); break;
			case '/':	nl_forward(); break;
			default:	return;
			}
			break;
		default:
			return;
		}
}

is_java_buffer()
{
	return !stricmp(".java", get_extension(filename));
}

add_tag(func, pos)
char *func;
{
	char rel[FNAMELEN], *file = filename, tdir[FNAMELEN];

	if (tag_relative) {		/* use relative version instead */
		put_tag_directory(tdir);
		relative(file, rel, tdir);
		file = rel;
	}
	if (tag_show_percent == 2)
		noteput("%s: adding %s...", file, func);
	else if (tag_show_percent == 1)
		noteput("Working %2d%%...", muldiv(point, 100, size()));
	if (tag_by_text) {
		int start;

		save_var point;
		point = pos;
		to_begin_line();
		start = point;
		to_end_line();
		buf_printf(_tags_buffer, "%s\t%s\t%d\t",
			func, file, pos);
		buf_xfer(_tags_buffer, start, point);
		buf_printf(_tags_buffer, "\n");
	} else
		buf_printf(_tags_buffer, "%s\t%s\t%d\n", func, file, pos);
}

put_tag_directory(dir)	// put directory of current tag file in dir
char *dir;
{
	save_var bufnum = _tags_buffer;
	put_directory(dir);
}

do_retag_file(file)	/* takes abs pathname, retags it */
char *file;
{
	char rel[FNAMELEN];

	relative(file, rel);
	delete_tags(file);
	if (tag_batch_mode)
		noteput("%s: searching for tags...", rel);
	return tag_a_file(file);
}

delete_tags(file)	/* delete all tags pointing to file (abs name) */
char *file;
{
	char rel[FNAMELEN], tdir[FNAMELEN];

	save_var abort_searching = 0;
	put_tag_directory(tdir);
	relative(file, rel, tdir);
//	noteput("%s: deleting old tags...", rel);
	do_delete_tags(tag_relative ? rel : file);
}

do_delete_tags(file)
char *file;
{
	int start, del;
	char pat[FNAMELEN], str[FNAMELEN];

	save_var bufnum;
	bufnum = _tags_buffer;
	point = 0;
	sprintf(pat, "^[^\t\n]+\t%q\t", file);
	sprintf(str, "\t%s\t", file);	// Quick search first.
	while (search(1, str)) {
		to_begin_line();
		del = parse_string(1, pat);		// Confirm this match.
		start = point;
		nl_forward();
		if (del)
			delete(start, point);
	}
}

// What's the orig buffer position associated with this line of tag buffer?
tag_line_to_position(int line, char *tagname)
{
	char buf[FNAMELEN];

	save_var bufname = "-list-definitions";
	go_line(line);
	if (parse_string(1, "^([^\t\n]+)\t[^\t\n]+\t([^\t\n]+)\t")) {
		grab(find_group(2, 1), find_group(2, 0), buf);
		if (tagname)
			grab(find_group(1, 1), find_group(1, 0), tagname);
		return strtoi(buf, 10);
	} else if (tagname)
		*tagname = 0;
	return 0;	// Shouldn't happen; we couldn't find tag info on the line.
}

list_definitions_when_displaying(from, to)
{
	char tagname[FNAMELEN], msg[FNAMELEN];

	from = from;		// not used
	if (1) {
		set_wattrib(window_handle, PVERTBORDCOLOR, color_class text);
		set_wattrib(window_handle, PHORIZBORDCOLOR, color_class text);
//		set_wattrib(window_handle, PTITLECOLOR, color_class text);
		text_color = color_class text;
	}
	to = tag_line_to_position(lines_between(0, point, 0) + 1, tagname);
	if (*tagname) {
		sprintf(msg, " %s - %q ", tag_declarations ? "Select a declaration or definition"
				: "Select a definition", tagname);
		window_title(window_handle, BTOP, TITLELEFT(2), msg);
		set_window_caption(window_handle, msg);
	}
	save_var window_handle = _bufed_orig_window;
	point = to;
	position_to_tag_line();
}

command list_definitions() on reg_tab[ALT('\'')]
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

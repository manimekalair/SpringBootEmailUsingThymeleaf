/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1996, 2001 Lugaru Software Ltd.  All rights reserved.  *
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

#include "eel.h"
#include "proc.h"
#include "colcode.h"
#include "grep.h"
#include "info.h"

// Construct the "dir" node by collecting all "dir" files and merging
// them.

read_info_dir(int transl, char *path)
{
	int i, cnt = 0;
	char *s, file[FNAMELEN];

	buf_zap(bufnum);
	for (i = 0; s = look_on_path("dir", 0, path, i); i++)
		bprintf("%s\n", s);		// Use the provided path variable.
	path = getenv("INFOPATH");
	if (path)	// And the environment setting.
		for (i = 0; s = look_on_path("dir", 0, path, i); i++)
			bprintf("%s\n", s);
	s = do_file_match("/usr/*/info/dir", STARTMATCH | EXACTONLY);
	if (s)		// And search in other places too.
		do {
			bprintf("%s\n", s);
		} while (s = do_file_match("/usr/*/info/dir", EXACTONLY));
	point = 0;
	do_sort_region(0, size(), 0, 0);
	do_uniq(1, 1, 0);		// Discard duplicates.
	point = 0;		// We now have a buffer of dir file names.
	for (;;) {
		i = point;
		if (!grab_line(bufnum, file))
			break;
		delete(i, point);
		do_insert_file(file, transl);
		save_spot point = i;
		if (++cnt > 1 && re_search(1, "^%* Menu:.*\n"))
			delete(i, point);	// Discard the extra headings.
		restore_vars();
	}
	return 0;
}

// Locate the file on the info path and read it.  Return 0 if we did,
// error code otherwise.

read_info_file(char *file, int transl)
{
	char *s, *info_path, fixed_path[FNAMELEN], *t;
	int err = 2;

	info_path = (opsys == OS_UNIX) ? info_path_unix : info_path_non_unix;
	build_filename(fixed_path, info_path, file);
	if (!strcmp(file, "dir"))	// Special rules for dir file.
		return read_info_dir(transl, fixed_path);
	s = look_on_path(file, 0, fixed_path);
	if (!s) {
		info_path = getenv("INFOPATH");
		if (info_path)
			s = look_on_path(file, 0, info_path);
	}
	if (!s) {	// Look in every place containing an Info dir file.
		t = do_file_match("/usr/*/info/dir", STARTMATCH | EXACTONLY);
		if (t)
			do {
				strcpy(fixed_path, t);
				strcpy(get_tail(fixed_path, 1), file);
				if (check_file(fixed_path) == 1) {
					s = fixed_path;
					break;
				}
			} while (t = do_file_match("/usr/*/info/dir", EXACTONLY));
	}
	if (s)
		err = file_read(s, transl);
	return err;
}

// Read the named info file, also trying suffixes that indicate
// compression and uncompressing.  Return 0 if ok, error code (or
// abort) otherwise.

info_read_unzipping(char *file)
{
	char name[FNAMELEN];
	int err;

	if (!read_info_file(file, FILETYPE_AUTO))
		return 0;
	sprintf(name, "%s.gz", file);
	if (read_info_file(name, FILETYPE_BINARY)) {
		sprintf(name, "%s.z", file);
		if (err = read_info_file(name, FILETYPE_BINARY))
			return err;
	}
	if (!pipe_text(bufname, bufname, "gunzip", NULL,
				   PIPE_SYNCH | PIPE_CLEAR_BUF | PIPE_NOREFRESH, 0)) {
		info_return(0);
		error("Could not uncompress %s", name);
	}
	return 0;
}

// Read the named info file, if not found try lowercasing it first.
// Return 0 if OK, error code if error.

info_read_fix_case(char *file)
{
	char lower[FNAMELEN], *p;

	if (!info_read_unzipping(file))
		return 0;
	strcpy(lower, file);
	for (p = lower; *p; p++)
		*p = tolower(*p);
	return info_read_unzipping(lower);
}

// An info file may be in many tiny parts.
// Keep things simple -- combine parts into one.

info_load_indirect_file(char *base)
{
	int orig = bufnum, tmp, pos;
	char file[FNAMELEN], part[FNAMELEN];

	point = 0;
	if (!re_search(1, "\n" INFO_CSTR "\f?\nIndirect:.*\n"))
		return;		// Find the list of component files.
	tmp = tmp_buf();
	while (parse_string(1, ".*!: [0-9]+\n", part)) {
		strcpy(file, base);		// Look in the same dir as base file.
		strcpy(get_tail(file, 0), part);
		nl_forward();
		pos = point;
		point = size();
		bufnum = tmp;
		if (info_read_fix_case(file))
			break;		// Read the component if we can.
		point = 0;
		if (re_search(1, "\n" INFO_CSTR "\f?\n"))
			point = matchstart;
		buf_xfer(orig, point, size());
		bufnum = orig;		// Append it to the original buffer.
		note("Reading %s...", file);
		point = pos;
	}
	bufnum = orig;
	buf_delete(tmp);
	note("");
}

// Load the specified info file (which won't include any needed
// extension or path).  Abort if we couldn't.  Handle split info
// files by combining them when we read them.

load_info_file(char *file)
{
	char modfile[FNAMELEN];
	int err;

	drop_quotes(file);
	set_read_only(0);		// Let us modify the info buffer.
	err = info_read_fix_case(file);
	if (err && err != EREADABORT) {		// Try adding suffixes.
		sprintf(modfile, "%s-info", file);
		err = info_read_fix_case(modfile);
		if (err && err != EREADABORT) {
			sprintf(modfile, "%s.info", file);
			err = info_read_fix_case(modfile);
		}
		if (err && err != EREADABORT) {
			sprintf(modfile, "%s.inf", file);
			err = info_read_fix_case(modfile);
		}
		if (!err)
			file = modfile;
	}
	if (err && err != EREADABORT)
		file_error(err, file, "read error");
	if (err) {
		info_return(0);
		quick_abort();
	}
	info_mode();
	point = size();
	if (re_search(-1, "\n" INFO_CSTR "\f?\nTag table:[\t ]*\n!")
		  && parse_string(1, "%(Indirect%)"))
		info_load_indirect_file(file);
	modified = 0;
	translation_type = FILETYPE_AUTO;
	set_read_only(3);
}

// Remember this place so we can return after an error or via L command.
info_record()
{
	to_info_buffer();
	if (exist(INFO_BUF)) {
		save_var bufname = INFO_BUF;
		buffer_printf(INFO_HISTORY, "%d %d %s\n",
					  point, window_start, filename);
	}
}

// Return to last node recorded in history.
// 0=Go back silently to last position.
// 1=Go back to last position, complain if we can't.
// 2=Delete last recorded position.
info_return(int mode)
{
	char node[FNAMELEN], pt[FNAMELEN], winst[FNAMELEN];

	if (info_recovering || !exist(INFO_HISTORY))
		return;		// Prevent failures from calling us recursively.
	save_var bufname = INFO_HISTORY, abort_searching = 0;
	if (!parse_string(-1, "([0-9]+) ([0-9]+) (.*)\n")) {
		if (mode == 1)
			error("No earlier node.");
		return;
	}
	grab(find_group(1, 1), find_group(1, 0), pt);
	grab(find_group(2, 1), find_group(2, 0), winst);
	grab(find_group(3, 1), find_group(3, 0), node);
	delete(matchend, size());
	restore_vars();
	if (mode != 2) {
		save_var info_recovering = 1;
		info_go_node(node, 0);
		point = numtoi(pt);
		window_start = numtoi(winst);
	}
}

// If we've been to this node before, go back to same place.
info_restore_point()
{
	char pat[FNAMELEN], pt[FNAMELEN], winst[FNAMELEN], *node = filename;
	int found;

	save_var bufname = INFO_HISTORY, abort_searching = 0;
	sprintf(pat, "([0-9]+) ([0-9]+) %q\n", node);
	if (found = re_search(-1, pat)) {
		grab(find_group(1, 1), find_group(1, 0), pt);
		grab(find_group(2, 1), find_group(2, 0), winst);
	} 
	point = size();
	restore_vars();
	if (found) {
		point = numtoi(pt);
		window_start = numtoi(winst);
	}
}

to_info_buffer()
{
	to_buffer(INFO_BUF);
	discardable_buffer = 1;
	force_save_as = FSA_READONLY;
	display_column = -1;
	tab_size = 8;
	undo_keeps_narrowing = 1;	// Keep it from removing narrowing.
}

// Get the file name for the current node.
info_get_file(char *file)
{
	char *p;

	if (*filename == '(') {
		strcpy(file, filename + 1);
		if (p = strchr(file, ')')) {
			*p = 0;
			return;
		}
	}
	*file = 0;
}

// Put in a standard one-line format.
info_standardize(char *text)
{
	int tmp = tmp_buf();
	save_var bufnum = tmp, abort_searching = 0;
	stuff(text);
	simple_re_replace(1, "[\n\t]", " ");
	simple_re_replace(1, " +", " ");
	simple_re_replace(1, "^ | $", "");
	simple_re_replace(1, "\\\\", "");
	grab(0, size(), text);
	restore_vars();
	buf_delete(tmp);
}

// Give name of the node linked as Next, Prev, or Up from this node.
info_give_linked_node(char *which, char *node)
{
	char pat[FNAMELEN];

	save_var point = 0, abort_searching = 0;
	*node = 0;
	sprintf(pat, "\n*(.*[\t\n, ])?%s:[\t ]*([^ \t][^\t\n,]+)", which);
	if (parse_string(1, pat))
		grab(find_group(2, 1), find_group(2, 0), node);
}

// Go to a node linked as Next, Prev, or Up from this node.
// Return 1 if OK, 0 on error.
int info_get_link(char *which)
{
	char node[FNAMELEN];

	to_info_buffer();
	info_give_linked_node(which, node);
	if (!*node)
		error("This node has no %s.", which);
	return info_go_node(node, 1);
}

// Complain if this node has no menu/footnote.
info_check_valid_link(int menu)
{
	save_var point = 0, abort_searching = 0;
	if (menu) {
		if (!re_search(1, "^%* Menu:"))
			error("This node has no menu.");
	} else
		if (!re_search(1,  "!%*Note[\n\t ]+([^:]+):"))
			error("This node has no footnotes.");
}

// Return nonzero if this node is an index node (if title contains
// the word "Index").
info_is_index()
{
	char *p = strstr(filename, "Index");
	return p && (p == filename || !isalpha(p[-1])) && !isalpha(p[5]);
}

// Color this info node.
int info_color_node(int start, int end)
{
	int cnt = 0;
	char node[FNAMELEN];

	save_var narrow_start, narrow_end, point = start + 2;
	info_narrow_to_node();	// Color the entire node.
	point = start = narrow_start;
	end = MAX(end, size() - narrow_end);
	set_character_color(start, end, -1);
	while (re_search(1, "^%* ([^\n:]+):")) {	// Menu items.
		grab(find_group(1, 1), find_group(1, 0), node);
		if (++cnt != 1 || stricmp(node, "Menu"))
			set_character_color(find_group(1, 1), find_group(1, 0),
								color_class man_bold);
	}
	point = 0;
	while (re_search(1, "%*Note[\n\t ]+([^:]+):"))	// References.
		set_character_color(find_group(1, 1), find_group(1, 0),
							color_class man_bold);
	point = 0;
	narrow_end = size() - give_end_line();	// Links in header line.
	while (re_search(1, "(Node|Next|Prev|Up):[\t ]*([^ \t][^\t\n,]+)"))
		set_character_color(find_group(2, 1), find_group(2, 0),
							color_class man_bold);
	add_colored_area(start, end);
	return end;
}

// Try to look in the tag table if any to guess this node's location.
info_guess_node_position(char *node)
{
	char pat[FNAMELEN];
	int pos, endtags, endhead, atend = 0;

	save_var point = 0, narrow_start, narrow_end;
	if (!re_search(1, "\n" INFO_CSTR))
		return 0;
	endhead = point;
	point = size();
	if (narrowed_search(REGEX | REVERSE, "\n" INFO_CSTR "\f?\nEnd Tag Table", 500)) {
		re_search(-1, "\n" INFO_CSTR "\f?\nTag Table:");
		atend = 1;
	} else
		point = 0;
	if (!narrowed_search(REGEX, "\n" INFO_CSTR "\f?\nTag Table:", 10000))
		return 0;
	narrow_start = point;
	if (!re_search(1, "\n" INFO_CSTR "\f?\nEnd Tag Table"))
		return 0;
	endtags = point;
	sprintf(pat, "\nNode: %s\x7F", node);
	if (!search(-1, pat))
		return 0;
	point = matchstart;
	if (grab_numbers(bufnum, &pos) != 1)
		return 0;
	return pos + (atend ? 0 : (endtags - endhead)) - 10000;
}

// Locate the node point's in and narrow to it.
info_narrow_to_node()
{
	if (re_search(-1, "\n" INFO_CSTR "\f?\n"))
		narrow_start = matchstart;
	if (re_search(1, "\n[" INFO_CSTR "\f]"))
		point--;
	narrow_end = size() - point;
	point = 0;
}

// Now that we're in the right file, go to a node based on its local
// node name (no file).  Return nonzero if we could.
info_to_local_node(char *node)
{
	char pat[FNAMELEN];
	int guess;

	narrow_start = narrow_end = 0;
	guess = point = info_guess_node_position(node);
	sprintf(pat, "\n" INFO_CSTR "\f?\n(.*[\t, ])?Node:[\t ]*%q[\t\n,]", node);
	if (!re_search(1, pat)) {
		point = guess + 1000;
		if (!re_search(-1, pat))
			return 0;
		point = matchstart;
	}
	info_narrow_to_node();		// Now narrow to the node point's in.
	return 1;
}

// Main function for going to a node.
// If record, put current node in the history.
// Return 1 if ok, 0 if we couldn't get there (in which case we've tried to
// return to the original place, or some default place if we couldn't).
info_go_node(char *node, int record)
{
	char file[FNAMELEN], *p, nodename[FNAMELEN], thisfile[FNAMELEN];
	int ret = 1;

	if (record)
		info_record();
	save_var abort_searching = 0;
	info_standardize(node);
	*file = 0;
	if (*node == '(' && (p = strchr(node, ')'))) {
		strcpy(file, node + 1);		// Node includes a file name.
		file[p - node - 1] = 0;
		node = p + 1;
	} else
		p = node;
	if (!*file)		// Assume it's to the same file as the current one.
		info_get_file(file);
	if (!*file)		// No current file, so use this default one.
		strcpy(file, "dir");
	if (!*node)		// No node within this file, use default.
		node = "Top";
	to_info_buffer();
	info_get_file(thisfile);	// Get file name for current node.
	if (strcmp(file, thisfile))
		load_info_file(file);	// Doesn't match, get to right file.
	if (!info_to_local_node(node)) {	// Get to right node.
		say("Info file %s contains no node %s.", file, node);
		ret = 0;
		node = "Top";
		if (!info_to_local_node("Top")) {
			strcpy(file, "dir");
			load_info_file(file);
			info_to_local_node("Top");
		}
	}
	sprintf(nodename, "(%s)%s", file, node);
	filename = nodename;		// Record this node name.
	make_mode();
	recolor_range = info_color_node;	// set up coloring rules
	recolor_from_here = recolor_by_lines;
	coloring_flags |= COLOR_RETAIN_NARROWING;
	when_setting_want_code_coloring();
	idle_coloring_delay = -1;		// No idle coloring.
	return ret;
}

///////////////////////// Info Commands ///////////////////////////

when_loading()		/* disable self-inserting chars */
{
	fix_key_table(reg_tab, (short) normal_character, info_tab, -1);
	set_case_indirect(info_tab);
	info_tab['b'] = goto_beginning;
}

info_help() on info_tab['?']
{
	help_on_command("info-mode");
}

info_tutorial() on info_tab['h']
{
	one_window();
	info_to_epsilon_node("Info Mode", 1);
}

// Back to last node visited.
command info_last() on info_tab['l']
{
	to_info_buffer();
	if (!exist(INFO_HISTORY))
		error("No last node.");
	info_return(1);
}

command info_next() on info_tab['n']
{
	info_get_link("Next");
}

command info_previous() on info_tab['p']
{
	info_get_link("Prev");
}

command info_up() on info_tab['u']
{
	char orignode[FNAMELEN], pat[FNAMELEN * 3];

	to_info_buffer();
	strcpy(orignode, strchr(filename, ')') ? strchr(filename, ')')  + 1 : "");
	if (!info_get_link("Up"))
		return;
	if (*orignode) {
		point = 0;
		if (re_search(1, "^%* Menu:.*\n")) {
			sprintf(pat, "^%%* ((%%([^\t\n,()]+%%))?%q+::"
					"|.*: *(%%([^\t\n,()]+%%))?%q[\t\n,.])",
					orignode, orignode);
			if (re_search(1, pat)) {
				to_begin_line();
				return;
			}
		}
	}
	info_restore_point();	// If we've been to this node before, to same place within.
}

command info_top() on info_tab['t']
{
	info_go_node("Top", 1);
}

command info_directory_node() on info_tab['d']
{
	info_go_node("(dir)Top", 1);
}

char *info_node_matcher(char *s, int flags)
{
	char node[FNAMELEN];
	int res;

	if (!buffer_size(_MATCH_BUF)) {
		save_var bufname = INFO_BUF;
		save_var narrow_start = 0, narrow_end = 0;
		save_var point = 0, abort_searching = ABORT_ERROR;
		if (size() > 500000)
			noteput("Listing nodes...");
		while ((res = re_search(1, "\n" INFO_CSTR "\f?\n(.*[\t, ])?"
								"Node:[\t ]*([^\t\n,]+)[\t\n,]")) == 1) {
			grab(find_group(2, 1), find_group(2, 0), node);
			info_standardize(node);	// Make list of choices.
			buffer_printf(_MATCH_BUF, "%s\n", node);
		}
		if (size() > 500000)
			note("");
		if (res == ABORT_ERROR)
			zap(_MATCH_BUF);
	}
	restore_vars();
	return general_matcher(s, flags);
}

command info_goto() on info_tab['g']
{
	char node[FNAMELEN];

	to_info_buffer();
	zap(_MATCH_BUF);
	save_var insert_default_response = 0;
	comp_read(node, "Go to node: ", info_node_matcher,
			  COMP_FOLD | SPACE_VALID, "");
	if (*node)
		info_go_node(node, 1);
}

command info_quit() on info_tab['q']
{
	to_another_buffer(bufname);
}

/* Do the first one of these we can:
 * If a non-index menu is visible in the window, go to its next item after point.
 * (If paging != 0) Page down.
 * Move to this node's Next node.
 * Move Up until we get to a node with a Next, then move to it.
 * (If no_top != 0, don't move up to the top node.)
 * Return nonzero if we could.
 */

int info_forward_sequence(int paging, int no_top, int talk)
{
	char node[FNAMELEN];
	int pt = point, ws = window_start;

	if (info_menu_before(window_end) && !info_is_index()) {
		info_to_this_menu_item();
		return 1;
	}
	if (paging)
		if (!all_blanks(window_end, size() - narrow_end) && !next_page()) {
			point = window_start;	// Don't land in the middle of a menu.
			return 1;
		}
	point = pt, window_start = ws;
	info_record();
	for (;;) {
		info_give_linked_node("Next", node);
		if (*node) {
			info_go_node(node, 0);
			return 1;
		}
		info_give_linked_node("Up", node);
		if (!*node || no_top && !stricmp(node, "Top")) {
			info_return(0);
			if (talk)
				error("No more nodes.");
			return 0;
		}
		info_go_node(node, 0);
	}
}

command info_next_page() on info_tab[' ']
{
	info_forward_sequence(1, 0, 1);
}

command info_forward_node() on info_tab[']']
{
	info_forward_sequence(0, 1, 1);
}

// Get to last node: last item in top menu, then follow Next until we
// can't, then info_forward_node() until we stop.
command info_last_node() on info_tab['>']
{
	info_go_node("Top", 1);
	info_to_nth_item(info_count_menu_items(), 1);
	info_return(2);		// Discard this movement.
	while (info_forward_sequence(0, 1, 0))
		;
	info_last_menu_sequence();
	point = 0;
}

/* Do the first one of these we can:
 * If a menu is above point, go to its closest item.  Then keep
 * selecting the last item in the current node's menu until we reach
 * one without a menu.
 * Page up.
 * Move to this node's Previous node (unless it's the same as its Up
 * node).  Then while the node's got a menu, go to its last item.
 * Move to this node's Up node unless it leads to a different file.
 */

command info_previous_page() on info_tab['\b'], info_tab[KEYDELETE],
								info_tab[GREYBACK]
{
	char upnode[FNAMELEN], prevnode[FNAMELEN];

	if (window_start < narrow_start || window_start > size() - narrow_end)
		window_start = point;		// Might be in a macro.
	if (info_menu_before(point)) {
		info_record();
		info_to_this_menu_item();	// Go to last menu item while we can.
		info_last_menu_sequence();
		return;
	}
	if (!previous_page())
		return;			// We paged back.
	info_give_linked_node("Up", upnode);
	info_give_linked_node("Prev", prevnode);
	if (*prevnode && strcmp(upnode, prevnode)) {
		info_go_node(prevnode, 1);
		info_last_menu_sequence();
		return;
	}
	if (*upnode && !strchr(upnode, '(')) {		// If Up is in same file.
		info_go_node(upnode, 1);
		if (!info_menu_before(size())) {
			point = size();
			line_to_bottom();
		}
		return;
	}
	error("No previous node.");
}

/*
 * If up leads out of file, stop.
 * Otherwise go to Up node if there's no distinct Prev.
 * Otherwise go to Prev node, then while in menu, go to last menu item.
 */
command info_backward_node() on info_tab['[']
{
	char upnode[FNAMELEN], prevnode[FNAMELEN];

	info_give_linked_node("Up", upnode);
	info_give_linked_node("Prev", prevnode);
	if (strchr(upnode, '('))
		error("First node in file.");
	if (*upnode && (!*prevnode || !stricmp(prevnode, upnode)))
		info_go_node(upnode, 1);
	else if (*prevnode) {
		info_go_node(prevnode, 1);
		info_last_menu_sequence();
		point = 0;
	} else
		error("No previous node.");
}

// Move to next or previous cross reference or menu item.
info_move_by_reference(int dir)
{
	int orig = point, cnt, good;

	to_info_buffer();
	for (cnt = 0; cnt < 3; cnt++) {
		if (dir > 0)		// Don't find the same match again.
			point++;
		if (!re_search(dir, "(%*Note[\n\t ]+|^%* )([^:]+):")) {
			point = (dir > 0) ? 0 : size();	// Wrap around.
			continue;
		}
		good = (dir > 0) ? matchstart : matchend;
		if (parse_string(-dir, "^%* Menu:"))
			continue;		// This one doesn't count.
		point = good;
		if (point == orig)
			say("No other reference in this node.");
		return;
	}
	point = orig;
	error("No references in this node.");
}

command info_next_reference() on info_tab['\t']
{
	info_move_by_reference(1);
}

command info_previous_reference() on info_tab[NUMSHIFT(GREYTAB)],
									 info_tab[ALT('\t')]
{
	info_move_by_reference(-1);
}

// Follow the reference at point.  If exact, point must be in the
// link; otherwise we find a close one.
// Return 0 if !exact and point wasn't anywhere good.
info_follow_this_reference(int exact)
{
	char node[FNAMELEN];
	int orig = point, i, menu_at;

	info_record();
	if (lines_between(0, point, 0) < 1) {
		save_var point = 0;		// Look only in header line.
		save_var narrow_end = size() - give_end_line();
		while (re_search(1, "(Node|Up|Next|Prev):[\t ]*([^ \t][^\t\n,]+)")) {
			if (point > orig) {
				if (exact && orig < find_group(2, 1))
					continue;
				grab(find_group(2, 1), find_group(2, 0), node);
				restore_vars();		// We were in this one, so go there.
				info_go_node(node, 0);
				return 1;
			}
		}
		info_return(2);
		restore_vars();
		return 0;
	}
	point = 0;
	menu_at = re_search(1,  "^%* Menu:") ? matchstart : -1;
	point = orig;
	save_var point;
	for (i = 0; i < 10; i++)
		nl_reverse();		// Go up a bit to get out of cross refs.
	while (re_search(1, "(%*Note[\n\t ]+|^%* )([^:]+):")) {
		if (point > orig) {		// We've passed original point, so pick this one.
			if (exact && orig < matchstart || menu_at == matchstart)
				continue;
			if (curchar() != ':')	// Get the separate node name.
				parse_string(1, "[ \t\n]*(((%([^\t\n,()]+%))?[^\t\n,.()]*))[\t\n,.]");
			grab(find_group(2, 1), find_group(2, 0), node);
			restore_vars();
			info_go_node(node, 0);
			return 1;
		}
	}
	info_return(2);
	return 0;
}

command info_follow_nearest_reference() on info_tab['\r'], info_tab[GREYENTER]
{
	info_follow_this_reference(0);
}

command info_mouse_double() on info_tab[MOUSE_DBL_LEFT]
{
	if (!in_text_area(mouse_x, mouse_y) || !info_follow_this_reference(1))
		mouse_select();
}

////////////////// Searching and Indexing ///////////////////////

command info_search() on info_tab['s']
{
	char *s, node[FNAMELEN];
	int flags, ret, found;

	flags = get_search_string("Search Info: ", UNKNOWN);
	flags &= ~(INCR | FAILING | BAD);
	s = default_search_string(flags);
	if (flags & UNKNOWN)
		flags = known_flags(flags);
	info_record();
	narrow_start = narrow_end = 0;
	while ((ret = do_searching(flags, s)) == 1) {
		found = point;		// Now see if it's in a node.
		if (re_search(-1, "\n" INFO_CSTR "\f?\n(.*[\t, ])?"
					  "Node:[\t ]*([^\t\n,]+)[\t\n,]")) {
			grab(find_group(2, 1), find_group(2, 0), node);
			info_go_node(node, 0);	// Narrow to this node.
			point = found;		// Narrowing might modify point here.
			if (point == found) {	// Yes, match is in this node.
				save_var point = 0;
				color_for_narrowed_area(narrow_start, size() - narrow_end);
				while ((ret = do_searching(flags, s)) == 1)
					set_character_color(matchstart, matchend,
										color_class man_underlined);
				return;
			}
			narrow_start = narrow_end = 0;
			point = found;		// No, so continue searching.
		} else
			point = found;
	}
	info_return(0);
	if (ret == DSABORT)
		say("Search canceled");
	else
		say("%s: not found", s);
}

// Get to the first index node of the file, return 0 if we couldn't.
int info_to_index()
{
	to_info_buffer();
	info_go_node("Top", 1);
	point = 0;
	save_var abort_searching = 0;
	if (!re_search(1, "^%* menu:")
		|| !re_search(1, "^%* ([^\n:]*[^a-z])?Index[^a-z]"))
		return 0;
	to_begin_line();
	info_follow_this_reference(0);
	info_return(2);			// Don't put follow in history.
	return info_is_index();
}

command info_index() on info_tab['i']
{
	char item[FNAMELEN];
	int have_index;

	have_index = info_to_index();
	info_return(0);			// Don't stay there for now.
	if (!have_index)
		error("This file has no index.");
	get_string(item, "Index topic: ");
	if (!do_info_index(item, 1))
		error("No index entry for %s.", item);
}

// Make a list of index entries, go to the first (if any), and return how many.
// If item is empty, go to top of first index node and return -1.

int do_info_index(char *item, int record)
{
	char node[FNAMELEN], pat[FNAMELEN];
	char title[FNAMELEN], file[FNAMELEN];
	int cnt = 0;

	info_to_index();
	if (!*item)		// Just go there.
		return -1;
	save_var abort_searching = ABORT_ERROR;
	zap(INFO_INDEX);	// Look for menu items containing this pat.
	sprintf(pat, "^%%* ([^\n:]*%q[^\n:]*):([^.\n]+)%%.[ \t]*[0-9]*$", item);
	while (info_is_index() && !user_abort) {
		if (re_search(1, "\n%* Menu:")) {
			file[0] = '(';
			info_get_file(file + 1);	// Get file name for current node.
			strcat(file, ")");
			while (re_search(1, pat) == 1) {
				grab(find_group(1, 1), find_group(1, 0), title);
									// Get the separate node name.
				grab(find_group(2, 1), find_group(2, 0), node);
				info_standardize(node);	// Make list of choices.
				cnt++;
				buffer_printf(INFO_INDEX, "%s\t%s%s\t%s\t%s\n",
							  title, strchr(node, '(') ? "" : file,
							  node, strchr(filename, ')') + 1, item);
			}
		}
		info_give_linked_node("Next", node);
		if (!*node)
			break;
		info_go_node(node, 0);
	}
	info_return(0);
	if (cnt) {
		info_prefer_matches(item, "^%s.*\n", 0);
		info_prefer_matches(item, "^%s[^-_a-z0-9].*\n", 0);
		info_prefer_matches(item, "^%s[ \t].*\n", 0);
		info_prefer_matches(item, "^%s[ \t].*Concept Index.*\n", 1);
		do_info_index_next(record);
	}
	return cnt;
}

// Rearrange the matches of s so substring matches come after more
// direct matches, by moving lines matching pat to the top or bottom.
info_prefer_matches(char *s, char *pat, int avoid)
{
	char fullpat[FNAMELEN];
	int tmp = tmp_buf();

	save_var bufname = INFO_INDEX;
	sprintf(fullpat, pat, s);
	point = 0;
	while (re_search(1, fullpat)) {
		buf_xfer(tmp, matchstart, matchend);
		delete(matchstart, matchend);
	}
	point = avoid ? size() : 0;
	grab_buffer(tmp);
	point = 0;
	buf_delete(tmp);
}

// Look in node for the first of several patterns that indicate s
// is being defined there.  Return 1 if we found one, else 0.
info_locate_match(char *s)
{
	char pat[FNAMELEN], pat2[FNAMELEN], *p;

	point = 0;
	sprintf(pat, "[a-z]+: %q!( |$)", s);
	if (re_search(1, pat))		// sometext: ourmatch
		return 1;
	point = 0;
	sprintf(pat, "`%q'", s);	// `ourmatch'
	if (re_search(1, pat))
		return 1;
	point = 0;
	sprintf(pat, "^%q$", s);	// ourmatch on its own line
	if (re_search(1, pat))
		return 1;
	point = 0;
	strcpy(pat, s);			// If we're searching for ourmatch (sometext),
	p = strstr(pat, " (");		// try looking for ourmatch.
	if (p && strchr(p, ')')) {
		*p = 0;
		sprintf(pat2, "`%q'", s);	// `ourmatch'
		if (re_search(1, pat2))
			return 1;
		point = 0;
		sprintf(pat2, "^%q$", pat);	// ourmatch on its own line
		if (re_search(1, pat2))
			return 1;
		point = 0;
		if (search(1, pat))
			return 1;
	}
	point = 0;
	if (search(1, s))		// Look for the plain text.
		return 1;
	point = 0;
	return 0;
}

command info_index_next() on info_tab[',']
{
	do_info_index_next(1);
}

do_info_index_next(int record)
{
	char title[FNAMELEN], *node = 0, *foundin = 0, *pat = 0;
	int tot, thiscnt;

	if (!exist(INFO_INDEX) || !buffer_size(INFO_INDEX))
		error("No previous index search.");
	save_var bufname = INFO_INDEX;
	if (point >= size())		// Go back to the first again.
		point = 0;
	tot = lines_between(0, size(), 0);	// Compute nth match of m.
	thiscnt = lines_between(0, point, 0) + 1;
	restore_vars();		// Now retrieve four tab-separated parts.
	if (grab_line(name_to_bufnum(INFO_INDEX), title)
		&& (node = strchr(title, '\t')) && (foundin = strchr(node + 1, '\t'))
		&& (pat = strchr(foundin + 1, '\t')))
		*node++ = *foundin++ = *pat++ = 0;
	else
		error("Internal error retrieving next index entry.");
	if (!info_go_node(node, record))	// Couldn't get there.
		return;
	say("Found \"%s\" in %s.  (%d of %d, <Comma> for next)", 
		title, foundin, thiscnt, tot);
	point = 0;
	for (thiscnt = 0; thiscnt < 3; thiscnt++)
		nl_forward();		// Ignore matches in headers.
	info_locate_match(title);
	to_begin_line();
}

////////////////// Menus and Cross References ///////////////////////

// Is there a menu in this node starting before this position?
int info_menu_before(int p)
{
	save_var narrow_end = size() - narrow_position(p), point = 0;
	return re_search(1, "^%* Menu:");
}

// How many menu items are there?
info_count_menu_items()
{
	int cnt = 0;

	save_var point = 0;
	while (re_search(1, "^%* ([^:]+):"))
		cnt++;
	return cnt - 1;		// Don't count "Menu:".
}

// Go to i'th menu item or cross reference.
info_to_nth_item(int i, int menu)
{
	char node[FNAMELEN];
	int cnt = 0;

	info_check_valid_link(menu);
	save_var point = 0;
	if (menu)
		re_search(1, "^%* Menu:");
	while (re_search(1, menu ? "^%* ([^\n:]+):" : "%*Note[\n\t ]+([^:]+):")) {
		if (++cnt >= i) {
			if (curchar() != ':')	// Get the separate node name.
				parse_string(1, "[ \t\n]*((%([^\t\n,()]+%))?[^\t\n,.()]*)[\t\n,.]");
			grab(find_group(1, 1), find_group(1, 0), node);
			restore_vars();
			info_go_node(node, 1);
			return;
		}
	}
	if (menu)
		error("This node has no menu item %d.", i);
	else			// Shouldn't happen.
		error("Internal reference error.");
}

// Follow the menu item at point.
info_to_this_menu_item()
{
	int cnt;

	save_var narrow_end = size() - give_end_line();
	cnt = info_count_menu_items();
	restore_vars();
	info_to_nth_item(MAX(cnt, 1), 1);
}

// Jump to the last item of the current node's menu until we
// get to a node without a menu, then go to its end.
info_last_menu_sequence()
{
	while (info_menu_before(size()) && !info_is_index()) {
		info_to_nth_item(info_count_menu_items(), 1);
		info_return(2);
	}
	point = size();
	line_to_bottom();
}

// Ask user which menu item or reference to follow.
info_prompt_for_link(int menu)
{
	char item[FNAMELEN], def[FNAMELEN], pat[FNAMELEN];
	int orig = point, cnt = 0;

	to_info_buffer();
	save_var point = 0;
	info_check_valid_link(menu);	// Complain if none.
	zap(_MATCH_BUF);
	*def = *item = 0;
	while (re_search(1, menu ? "^%* ([^\n:]+):" : "%*Note[\n\t ]+([^:]+):")) {
		grab(find_group(1, 1), find_group(1, 0), item);
		info_standardize(item);	// Make list of choices.
		if (menu && ++cnt == 1 && !stricmp(item, "Menu"))
			continue;	// Menu header doesn't count.
		if (!*def && point > orig)
			strcpy(def, item);
		buffer_printf(_MATCH_BUF, "%s\n", item);
	}
	restore_vars();
	if (!*def)
		strcpy(def, item);
	save_var insert_default_response = 0;
	prompt_comp_read(item, menu ? "Menu item" : "Follow reference",
					 general_matcher, COMP_FOLD | MUST_MATCH
					 | SPACE_VALID | NONE_OK, def);
	if (!*item)
		strcpy(item, def);
	save_var bufname = _MATCH_BUF, point = 0;
	sprintf(pat, "^%q$", item);
	if (!re_search(1, pat))
		error("No such %s.", menu ? "menu item" : "reference");
	cnt = lines_between(0, point, 0) + 1;
	restore_vars();
	info_to_nth_item(cnt, menu);
}

command info_menu() on info_tab['m']
{
	info_prompt_for_link(1);
}

command info_follow_reference() on info_tab['f']
{
	info_prompt_for_link(0);
}

// Go to menu item based on key 1-9.  0 means last item.
command info_nth_menu_item()
{
	int i = key - '0';

	if (!i)
		info_to_nth_item(info_count_menu_items(), 1);
	else if (i >= 0 && i <= 9)
		info_to_nth_item(i, 1);
}

////////////////// Building Info Files ///////////////////////


command info_tagify()
{
	char node[100];
	int pos, cnt = 0;

	widen_buffer();
	zap("Info-tags");
	point = 0;
	if (re_search(1, "^" INFO_CSTR "\f?\nIndirect:"))
		error("Can't tag indirect info files.");
	point = 0;
	while (re_search(1, "^" INFO_CSTR "\f?\n(.*[\t, ])?Node:[\t ]*")) {
		pos = matchstart;
		parse_string(1, "[^,\n]+", node);
		buffer_printf("Info-tags", "Node: %s\x7F%d\n", node, pos);
		cnt++;
	}
	point = 0;
	if (!cnt)
		error("Not an info file.");
	if (re_search(1, "\n" INFO_CSTR "\f?\nTag table:\n")) {
		pos = matchstart;
		if (parse_string(1, "(Node: .*\x7F[0-9]+\n)+" INFO_CSTR
						 "\nEnd tag table\n") != size() - point)
			error("Please delete this existing tag table first.");
		delete(pos, size());
	}
	stuff("\n" INFO_CSTR "\f\nTag table:\n");
	grab_buffer(name_to_bufnum("Info-tags"));
	stuff(INFO_CSTR "\nEnd tag table\n");
	say("Info tags added.");
}

// Check that nodes point somewhere valid, no duplicate node names, collect
// statistics too.

command info_validate()
{
	char node[100];
	int i, nodes = 0, xrefs = 0, menu_items = 0, menus = 0;

	noteput("Collecting nodes...");
	save_var narrow_start, narrow_end;
	widen_buffer();
	zap("Have-Nodes");
	zap("Want-Nodes");
	point = 0;
	while (re_search(1, "\n" INFO_CSTR "\f?\n(.*[\t, ])?Node:[\t ]*")) {
		parse_string(1, "[^,\n]+", node);
		buffer_printf("Have-Nodes", "%s\n", node);
		nodes++;
		while (i = parse_string(1, "[, ]+(Next|Prev|Up): ")) {
			point += i;
			if (!parse_string(1, "[^,\n]+", node))
				error("Bad node name.");
			info_standardize(node);
			buffer_printf("Want-Nodes", "%s\n", node);
		}
		if (curchar() != '\n')
			error("Bad node.");
	}
	if (!nodes)
		error("Not an info file.");
	noteput("Collecting cross-references...");
	point = 0;
	re_search(1, "\n" INFO_CSTR "\f?\n");
	while (re_search(1, "%*Note[ \n]")) {
		if (!parse_string(1, "[^:]+!::", node))
			if (!parse_string(1, "[^:]+:", node)
				|| !parse_string(1, "([ \t\n]*%([^)]+%))?[^:.]+!%.", node))
				error("Bad link name.");
		info_standardize(node);
		buffer_printf("Want-Nodes", "%s\n", node);
		xrefs++;
	}
	noteput("Collecting menu items...");
	point = 0;
	re_search(1, "\n" INFO_CSTR "\f?\n");
	while (search(1, "\n* Menu:")) {
		info_narrow_to_node();		// Now narrow to the node point's in.
		search(1, "\n* Menu:");
		while (re_search(1, "^%* !([^\n:]+):")) {
			if (!parse_string(1, "[^:]+!::", node))
				if (!parse_string(1, "[^:\n]+( : [^:\n]+)?:", node)
					|| !parse_string(1, "[ \t\n]*(%([^)]+%))?[^:.]+!%.", node))
					error("Bad link name at offset %d.", point);
			info_standardize(node);
			buffer_printf("Want-Nodes", "%s\n", node);
			menu_items++;
		}
		widen_buffer();
		menus++;
	}
	noteput("Comparing...");
	bufname = "Have-Nodes";
	do_lowercase_region(0, size());
	do_sort_region(0, size(), 0, 0);
	zap("Dupl-Nodes");
	xfer("Dupl-Nodes", 0, size());
	do_uniq(1, 1, 0);
	bufname = "Dupl-Nodes";
	do_uniq(0, 1, 0);
	bufname = "Want-Nodes";
	do_lowercase_region(0, size());
	do_sort_region(0, size(), 0, 0);
	do_uniq(1, 1, 0);
	do_compare_sorted(name_to_bufnum("Have-Nodes"), name_to_bufnum("Want-Nodes"),
					  NULL, "Info-Summary", NULL);
	to_buffer("Info-Summary");
	point = 0;
	stuff("\n\nThe following linked nodes were not found within this file.\n");
	stuff("Normally only links to other files, using (filename) notation,\n");
	stuff("should appear in this list.  Missing nodes:\n\n");
	point = 0;
	bprintf("%d nodes.\n%d cross-references.\n%d menu items in %d menus.\n\n",
			nodes, xrefs, menu_items, menus);
	stuff("\nThe following node names occur in this file more than once:\n\n");
	grab_buffer(name_to_bufnum("Dupl-Nodes"));
	point = 0;
}

////////////////// Top-Level Commands ///////////////////////

when_loading()
{
	int c;
	for (c = '0'; c <= '9'; c++)
		info_tab[c] = info_nth_menu_item;
}

command info_mode()
{
	mode_keys = info_tab;		/* Use these keys. */
	major_mode = _info_mode_name;
	case_fold = 1;
	make_mode();
}

command info()
{
	if (!exist(INFO_BUF))
		info_go_node("(dir)", 0);
	else
		to_info_buffer();
}

// Return nonzero if we could get to the specified node in Epsilon's
// info file.

info_to_epsilon_node(char *node, int record)
{
	char full[FNAMELEN], *s;

	s = lookpath("epsilon.inf", 0);
	if (s) {			/* Find it even if it's not installed properly. */
		sprintf(full, "(%s", s);
		*get_extension(full) = 0;
		strcat(full, ")");
	} else
		strcpy(full, "(epsilon)");
	strcat(full, node);
	return info_go_node(full, record);
}

command epsilon_manual_info()
{
	info_to_epsilon_node("Top", 1);
}

// Look in Epsilon's info file for an index topic.
command epsilon_info_look_up()
{
	char topic[FNAMELEN], def[FNAMELEN], *p;

	if (!strcmp(get_extension(filename), ".e")) {
		save_var point--;
		re_search(1, word_pattern);
		re_search(-1, word_pattern);
		grab(matchstart, matchend, def);
		restore_vars();
	} else
		*def = 0;
	get_strnone(topic, "Show full Epsilon documentation on topic: ", def);
	if (*topic) {
		info_record();
		if (!info_to_epsilon_node("Top", 0))
			quick_abort();
		narrow_start = narrow_end = 0;
		if (info_guess_node_position(topic) && info_to_epsilon_node(topic, 0))
				return;		// Go to a node by that name; no error if not.
		if (!do_info_index(topic, 0)) {
			strcpy(def, topic);		// No match, so try swapping - with _'s.
			for (p = def; p = strchr(p, '-'); )
				*p = '_';
			if (!do_info_index(def, 0)) {
				for (p = def; p = strchr(p, '_'); )
					*p = '-';
				if (!do_info_index(def, 0))
					error("No index entry for %s.", topic);
			}
		}
	} else
		epsilon_manual_info();
}

command info_goto_epsilon_command()
{
	char cmd[FNAMELEN];
	iter = 0;
	save_var show_mouse_choices = 1;
	get_cmd(cmd, "Go to Info documentation for command", "");
	info_to_epsilon_node(cmd, 1);
}

command info_goto_epsilon_key()
{
	iter = 0;
	tell_key(2, "Go to Info documentation for command on key: ");
}

command info_goto_epsilon_variable()
{
	char var[FNAMELEN];

	iter = 0;
	save_var show_mouse_choices = 1, show_all_variables = 1;
	get_var(var, "Go to Info documentation for variable", "", MUST_MATCH);
	restore_vars();
	info_to_epsilon_node(var, 1);
}

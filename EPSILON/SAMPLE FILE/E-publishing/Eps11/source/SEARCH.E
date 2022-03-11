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

// This file has the searching and replacing commands.

#include "eel.h"
#include "colcode.h"

// Remember this position.
remember_old_place(old_place *p, int pos)
{
	if (search_continuation)
		(*search_continuation)(SCON_RECORD, pos, p->item);
	p->pos = pos;
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

search_read(trystr, prmpt, flags)
char *trystr, *prmpt;
{
	int lastok, goodchars, oldflags, origwin = window_handle;
	int editbuf, pbuf, pwin, editwin, s_code, ostart, cnt;
	int oreg_type, old_mark = -1, search_contin = search_continuation != 0;
	char tmpbuf[FNAMELEN];
	old_place orig, mstart, okpoint;

	if (_doing_input == DI_SEARCH)
		error_if_input(0);
	if (is_highlight_on() && point != mark && ABS(point - mark) < 200
		  && !*trystr && typing_deletes_highlight
		  && !in_macro() && _len_def_mac < 1) {
		old_mark = mark;	// Use this as the initial search string.
		highlight_off();
	}
	save_var iter, has_arg, this_cmd, prev_cmd;
	save_var _doing_input = DI_SEARCH;
	save_var last_index;
	save_var mark = point, _highlight_control;
	save_var postpone_asynchronous_notify = 1;
	save_var macro_runs_immediately = 0;	// Make special keys work in macros.
	oreg_type = region_type();
	set_region_type(REGNORM);
	flags &= ~SEARCH_EMPTY | SEARCH_CONTIN;
	remember_old_place(&orig, point);
	remember_old_place(&mstart, point);
	remember_old_place(&okpoint, point);
	ostart = window_start;
	goodchars = lastok = 0;	/* 2 versions of len of last good string */
				/* (only lastok is set by getting default) */

	editbuf = tmp_buf();		/* make buffer for cmd line editing */
	pwin = add_popup(0, echo_line, screen_cols - 1, 1, 0,
			pbuf = tmp_buf());	/* prompt in window */
	stuff(trystr);
	trystr = malloc(FNAMELEN);
	display_column = 0;
	system_window = 1;	/* don't let user switch to it */
	text_color = color_class echo_area;

	editwin = add_popup(1, echo_line, screen_cols - 1, 1,
			0, editbuf);	/* window on top of prompt window */
	text_color = color_class echo_area;
	_display_class = _echo_disp_class;
	display_column = 0;

	if (old_mark != -1) { // Start out with highlighted region.
		window_handle = origwin;
		buf_xfer(editbuf, old_mark, point);
		window_handle = editwin;
		point = 0;
		if (flags & REGEX)	// Quote special chars.
			string_replace("[[%.!#()*+|?^$<]", "%#0", REGEX);
		point = size();
		highlight_on();		// Mark it so user can delete by typing.
	}

	for (;;) {
		do {
			show_search_prompt(prmpt, flags, origwin,
					   pwin, editwin);
			getkey();
		} while (key == MOUSE_MOVE);
		if (IS_MOUSE_KEY(key))
			if (mouse_y == echo_line)
				flags &= ~INCR;
			else {
				flags |= SONCE;
				ungot_key = key;
				break;
			}
		cnt = 1;
		if (key == CTRL('^'))
			full_getkey("", CTRLIFY_KEY);
		window_handle = editwin;
		s_code = 0;
		oldflags = flags;
		flags &= ~(BAD | FAILING | SONCE);	/* assume ok */
		if (is_search_dir()) {
			window_handle = origwin;
			to_old_place(&okpoint);
			window_handle = editwin;
			if ((key == CTRL('R')) != ((flags & REVERSE) != 0)) {
				flags ^= REVERSE;	/* switch dir */
				if (goodchars)
					flags |= SONCE;
				lastok = size();
			} else if (!size()) {
				if (flags & UNKNOWN)
					flags = known_flags(flags);
get_defaults:
				stuff(default_search_string(flags));
				lastok = size();
			} else if (oldflags & FAILING) {
				if (search_contin) {
					flags |= SEARCH_CONTIN;
					s_code = FHERE;			/* Try other records. */
				} else if (search_wraps) {
					flags |= (flags & SEARCH_WRAPPED) ? SEARCH_OVERWRAPPED
						: SEARCH_WRAPPED;
					window_handle = origwin; /* Wrap to other end of buffer. */
					point = (flags & REVERSE) ? size() : 0;
					window_handle = editwin;
					s_code = FHERE;			/* And search again. */
				} else
					flags |= FAILING; /* no more matches, stop */
			} else
				flags |= SONCE;
			if ((flags & (INCR | SONCE)) && !(flags & FAILING))
				flags |= SONCE, s_code = FHERE;
		} else if (set_flag_modes(&flags)) {
			if ((flags & INCR) && size())
				s_code = FMATCH; /* if modes changed, search again */
		} else if (key == CTRL('O')) {
			flags ^= INCR;
			point = size();
			if (flags & INCR)
				s_code = FMATCH;
		} else if (binding_of(key, reg_tab) == (short) help)
			help_on_command(help_on_search(flags));
		else if (IS_ENTER_KEY(key)) {
			if (oldflags & SONCE)
				flags |= SONCE;
			break;
		} else if (binding_of(key, reg_tab) == (short) backward_delete_character
				   && (flags & INCR)) {
			run_topkey();
			window_handle = editwin;
			if (!(oldflags & FAILING) || size() <= lastok)
				s_code = FORIG;
			else		/* don't bother searching */
				flags |= FAILING;
		} else if (key == abort_key && (oldflags &
					((flags & INCR) ? FAILING : SONCE))) {
			if (flags & INCR)
				delete(goodchars, size());
		} else if (binding_of(key, comp_tab) == (short) inp_recall
				   && (IS_ALT_KEY(key) || !(flags & INCR))) {
			flags = pick_prev_search(flags) & ~INCR;
			if (user_abort)
				break;
		} else if (user_abort || (flags & INCR) && exit_incr())
			break;
		else {
			flags &= ~UNKNOWN;
			if ((binding_of(key, comp_tab) == (short) inp_grab_word
				 || binding_of(key, comp_tab) == (short) inp_grab_line)
				  && (IS_ALT_KEY(key) /*|| !(flags & INCR) */ )) {
				if (!(oldflags & FAILING)) {
					if (grab_search_word(flags, origwin,
						(binding_of(key, comp_tab) == (short) inp_grab_line))) {
						window_handle = origwin;	// Move origin
						remember_old_place(&orig, point);
						remember_old_place(&mstart, point);	// to start of word.
						window_handle = editwin;
						s_code = FORIG;
					} else
						s_code = (flags & REVERSE) ? FHERE : FMREGEX;
				}
			} else if (key == '\t')
				normal_character();
			else
				run_topkey();
			window_handle = editwin;
			if (flags & INCR)
				if (flags & (REGEX | WORD))
					s_code = FMREGEX;
				else if (oldflags & FAILING)
					flags |= FAILING;
				else
					s_code = FMADD;
		}
		_doing_input = DI_SEARCH;
		if (!is_window(origwin) || !is_window(editwin)
		    || !is_window(pwin)) {	// user deleted our window
			user_abort = 1;
			goto end;
		}
		user_abort = 0;
		grab_expanding(0, size(), &trystr, 256);
		if (!s_code)
			continue;
		window_handle = origwin;
		if (s_code == FORIG || s_code == FMREGEX)
			to_old_place(&orig);
		else if (s_code >= FMATCH) {
			to_old_place(&mstart);
			if (flags & REVERSE)
				point++;
		}
		_highlight_control = 0;
search_again:
		switch (do_searching(flags, trystr)) {
			case DSBAD:
				flags = BAD | (flags & ~INCR);
				flags |= FAILING;
				to_old_place(&okpoint);
				if (in_macro())
					goto end;
				else if (!(oldflags & FAILING))
					maybe_ding(bell_on_search);
				break;
			case 0:
				if ((flags & SEARCH_CONTIN) && search_contin
					  && (*search_continuation)(cnt++, flags, trystr))
					goto search_again;
				flags |= FAILING;
				to_old_place(&okpoint);
				if (in_macro())
					goto end;
				else if (!(oldflags & FAILING))
					maybe_ding(bell_on_search);
				break;
			case 1:
				remember_old_place(&okpoint, point);
				remember_old_place(&mstart, matchstart);
				mark = matchstart;
				highlight_on();
				if ((flags & SEARCH_WRAPPED)
					  && past_old_place(&orig) == !(flags & REVERSE))
					flags |= SEARCH_OVERWRAPPED;
				window_handle = editwin;
				goodchars = lastok = size();
				break;
			case DSABORT:
				to_old_place(&okpoint);
				window_handle = editwin;
				if ((flags & INCR) && s_code == FMADD)
					delete(size() - 1, size());
				while (ungot_key == -1 && char_avail()
					   && getkey() == abort_key || !IS_TRUE_KEY(key))
					;
				if (key != abort_key && IS_TRUE_KEY(key))
					ungot_key = key;
				drop_pending_says();
				break;
		}
	}
	window_handle = origwin;
	if (key == abort_key || user_abort) {
		to_old_place(&orig);
		window_start = ostart;
	} else {
		window_handle = editwin;
		if (size()) {
			_last_was_regex = ((flags & REGEX) != 0);
			*(_last_was_regex ? &_default_regex_flags
					  : &_default_flags) = flags;
			grab_expanding(0, size(), &trystr, 256);
			if (_last_was_regex)
				grab_expanding(0, size(), &_default_regex_search, 256);
			else
				grab_expanding(0, size(), &_default_search, 256);
			save_search_recall(flags, trystr);
		} else
			flags |= SEARCH_EMPTY;
		if ((flags & INCR) && !IS_ENTER_KEY(key) && key != ESC)
			ungot_key = key;
	}
end:
	strncpy(tmpbuf, trystr, FNAMELEN - 1);
	free(trystr);
	if (is_window(origwin))
		window_handle = origwin;
	set_region_type(oreg_type);
	remove_window(editwin);
	remove_window(pwin);
	buf_delete(editbuf);
	buf_delete(pbuf);
	if ((flags & FAILING) && in_macro())
		error("%s: not found", tmpbuf);
	check_abort();
	say("");
	restore_vars();
	maybe_refresh();	/* put cursor back in prev window */
	return flags;
}

char *help_on_search(flags)	/* give help on correct command */
{
	if (flags & GREP)
		return (flags & QUERY) ? "file-query-replace" : "grep";
	else if (flags & REGEX)
		return (flags & REPLACE) ? "regex-replace"
				: "regex-search";
	else
		return !(flags & REPLACE) ? "incremental-search"
				: (flags & QUERY) ? "query-replace"
				: "replace-string";
}

exit_incr()	/* does this key exit an incremental search? */
{
	return key != '\t' && key != CTRL('Q') && (key < ' ' || !IS_ASCII_KEY(key))
			&& ((binding_of(key, comp_tab) != (short) inp_grab_word
				 && binding_of(key, comp_tab) != (short) inp_grab_line)
				|| !IS_ALT_KEY(key)) && !norm_binding();
}

norm_binding()	/* does this key run normal-character? */
{
	return ((key & CMD_INDEX_KEY) ? (key & ~CMD_INDEX_KEY)
			: (mode_keys[key] ? mode_keys[key] : root_keys[key]))
			== (short) normal_character;
}

set_flag_modes(fp)	/* maybe set *fp from key, return 1 if we could */
int *fp;
{
	if (key == CTRL('C')) {
		*fp ^= FOLD;
		*fp |= MODFOLD;
		return 1;
	} else if (key == CTRL('W'))
		*fp ^= WORD;
	else if (key == CTRL('T')) {
		*fp ^= REGEX;
		if (*fp | REGEX) /* if entering regex, not incremental */
			*fp &= ~INCR;
	} else
		return 0;
	if (*fp & UNKNOWN)	/* setting regex or word makes type known */
		*fp &= ~(INCR | UNKNOWN);
	return 1;
}

is_search_dir()	/* return 1 if it's a direction key inside search */
{		/* also replace with standard key value */
	if (key == CTRL('R') || key == ALT(CTRL('R'))
					|| key == rev_search_key)
		key = CTRL('R');
	else if (key == CTRL('S') || key == ALT(CTRL('S'))
					|| key == fwd_search_key)
		key = CTRL('S');	/* substitute standard one */
	else
		return 0;
	return 1;
}

known_flags(flags)	/* set flags when user pulls in default string */
{
	int def, new;

	flags &= ~(SMODES | UNKNOWN);
	def = _last_was_regex ? _default_regex_flags : _default_flags;
	def &= (SMODES | INCR);
	new = flags | (def & ~INCR);	/* no incr if grep, e.g., calls */
	if ((flags & REGEX) && !(def & INCR))
		new &= ~INCR;	/* only allow explicit incr regex search */
	if (((new & FOLD) != 0) != case_fold.default)
		new |= MODFOLD;
	return new;
}

make_search_prompt(s, flags)
char *s;
{
	sprintf(s, "%s%s%s%s%s%s%s",
		(flags & SEARCH_CONTIN) ? "Continued " :
		(flags & SEARCH_OVERWRAPPED) ? "Overwrapped " :
			(flags & SEARCH_WRAPPED) ? "Wrapped " : "",
		(flags & BAD) ? "Bad " : (flags & FAILING) ? "Failing " : "",
		(flags & REVERSE) ? "Reverse " : "",
		!(flags & MODFOLD) ? "" :
				(flags & FOLD) ? "Folding " : "Exact ",
		(flags & REGEX) ? "R-E " : "",
		(flags & WORD) ? "Word " : "",
		(flags & INCR) ? "I-" : "");
}

show_search_prompt(prmpt, flags, origwin, pwin, editwin)
char *prmpt;
{
	char tmp[80];

	window_handle = pwin;
	buf_zap(bufnum);
	make_search_prompt(tmp, flags);
	stuff(tmp);
	stuff(prmpt);
	point = 0;
	set_wattrib(editwin, BLEFT, size());	/* reset window edges */
	window_handle = (flags & (INCR | SONCE)) ? origwin : editwin;
	maybe_refresh();
}

save_search_recall(int flags, char *str)
{
	char *srch;
	int buf = tmp_buf();

	save_var bufnum = buf;
	bprintf("%s%s%s",
		!(flags & MODFOLD) ? "" : (flags & FOLD) ? "Fold " : "Nofold ",
		(flags & WORD) ? "Word " : "",
		(flags & REGEX) ? "Regex " : "");
	if (character(point - 1) == ' ')
		delete(point - 1, point);
	bprintf(": %s", str);
	simple_re_replace(1, "%<NL>", "%<NL>");	// Put a % before actual <NL> strings.
	simple_re_replace(1, "\n", "<NL>");	// Convert newlines to <NL>.
	srch = malloc(size() + 1);
	grab(0, size(), srch);
	restore_vars();
	buf_delete(buf);
	save_recall(srch, "search");
	free(srch);
}

pick_prev_search(flags)	// select old search string from list, insert in curbuf
{
	int w = window_handle, menu, mbuf, obuf = bufnum, res;

	buf_zap(bufnum);
	save_var recall_id = "search";
	menu = new_menu(mbuf = tmp_buf());
	make_menu(menu, "", (char *(*)()) 0, 0, w, mbuf, list_recalls);
	if (is_gui && want_gui_prompts)
		one_window_to_dialog("Search for", menu, "OK", "Cancel", "");
	res = select_menu_item(obuf, menu, w, -1);
	buf_delete(mbuf);
	point = 0;			// parse and remove flag info
	switch (res) {
		case INP_ABORT:
			user_abort = 1;
		default:
			return flags;
		case INP_GET_EXIT:
		case INP_GET:
			break;
	}
	if (!search(1, ":")) {
		user_abort = 1;
		return flags;
	}
	narrow_end = size() - point - 1;
	point = 0;
	if (curchar() == 'N') {		// explicit Nofold flag
		flags &= ~FOLD;
		search(1, " ");
	}
	flags = recall_search_flag('F', flags, FOLD, 0);
	flags = recall_search_flag('W', flags, WORD, 1);
	flags = recall_search_flag('R', flags, REGEX, 1);
	if (((flags & FOLD) != 0) != case_fold.default)
		flags |= MODFOLD;
	point = size();		// get to end of flag info
	narrow_end = 0;
	delete(0, point);	// remove flag info
	point = 0;
	while (search(1, "<NL>")) {
		if (character(matchstart - 1) == '%')	// Unquote actual <NL> we searched for.
			delete(matchstart, matchstart - 1);
		else {						// Convert <NL> back to \n.
			delete(matchstart, matchend);
			stuff("\n");
		}
	}
	point = size();
	if ((flags & GREP) && res == INP_GET_EXIT)
		ungot_key = '\n';
	return flags;
}

recall_search_flag(letter, flags, thisflag, def)
{			// set flag based on keyword, skip past it
	if (curchar() == letter) {
		flags |= thisflag;
		search(1, " ");
	} else if (def)		// if letter's missing, maybe turn off flag
		flags &= ~thisflag;
	return flags;
}

// Copy word or line from origwin to current window.
// Return nonzero if we moved the origin.

int grab_search_word(flags, origwin, line)
{
	char text[FNAMELEN];
	int orig, len = size(), ret = 0;

	save_var window_handle = origwin;
			// First time, if we're inside a word, go to its start.
	if (!len && !line && !(flags & FAILING) && parse_string(1, word_pattern)
		&& parse_string(-1, word_pattern)) {
		point -= parse_string(-1, word_pattern);
		ret = 1;
	}
	if (!(flags & REVERSE))
		save_var point;
	else if (len && !(flags & FAILING))
		point = matchstart;
	orig = point;
	if (!(flags & FAILING))
		if (line) {
			if (curchar() == '\n')
				point++;
			to_end_line();
		} else
			re_search(1, word_pattern);		// Get the next word.
	grab(orig, point, text);
	restore_vars();
	point = size();
	bprintf((flags & REGEX) ? "%q" : "%s", text);
	return ret;
}


/* string-search command */
command regex_search() on reg_tab[ALT(CTRL('S'))]
{
	conv_search(REGEX);
}

/* reverse-string-search backward */
command reverse_regex_search() on reg_tab[ALT(CTRL('R'))]
{
	conv_search(REGEX | REVERSE);
}

command incremental_search() on reg_tab[CTRL('S')]
{
	conv_search(UNKNOWN | INCR);
}

command reverse_incremental_search() on reg_tab[CTRL('R')]
{
	conv_search(UNKNOWN | INCR | REVERSE);
}

command string_search()
{
	conv_search(0);
}

command reverse_string_search()
{
	conv_search(REVERSE);
}

get_search_string(pr, flags)	/* prompt for search string & return flags */
char *pr;
{
	return search_read("", pr, default_fold(flags));
}

search_flags_with_direction(flags)
{			// return default search flags including direction
	int def = _last_was_regex ? _default_regex_flags : _default_flags;

	return known_flags(flags) | (def & REVERSE);
}

command search_again()
{	// search for last thing without prompting, in same direction
	do_search_again(search_flags_with_direction(UNKNOWN));
}

command forward_search_again()
{
	do_search_again(known_flags(UNKNOWN) & ~REVERSE);
}

command reverse_search_again()
{
	do_search_again(known_flags(REVERSE));
}

do_search_again(flags)
{
	char tmp[FNAMELEN];

	make_search_prompt(tmp, flags);
	say("%sSearch: %s", tmp, default_search_string(flags));
	repeat_search(iter, flags);
	iter = 0;
	say("");
}

command replace_again()
{	// right now, we can only replace forward
	int flags = search_flags_with_direction(UNKNOWN) | QUERY;
	char tmp[FNAMELEN], *s, *t;

	make_search_prompt(tmp, flags);
	say("%sReplace string: %s", tmp, default_search_string(flags));
	s = default_search_string(flags);
	t = (flags & REGEX) ? _default_regex_replace : _default_replace;
	last_index = find_index(help_on_search(flags));
	show_replace(s, t, flags);
	string_replace(s, t, flags | INCR);
	iter = 0;
	say("");
}

conv_search(flags) /* prompt for search string, then search, but see flags */
{
	flags = get_search_string("Search: ", flags);
	if (!(flags & (INCR | SONCE)))
		repeat_search(iter, flags);
	iter = 0;
}

repeat_search(cnt, flags)	 // search & report errors
{
	int orig, ret;
	char *s;

	s = default_search_string(flags);
	while (cnt-- > 0) {
		orig = point;
		ret = do_searching(flags, s);
		if (ret == 1)
			continue;
		if (ret == DSABORT)
			say("Search canceled");
		else {
			say("%s: not found", s);
			point = orig;
			if (in_macro())
				quick_abort();
		}
		break;
	}
}

default_fold(flags)		/* initialize flag from buffer variable */
{
	if (case_fold)
		flags |= FOLD;
	if (case_fold != case_fold.default)
		flags |= MODFOLD;
	return flags;
}

// Return the most recent search string.  For functions that may wish
// to write short amounts to these, we ensure there's some room.
char *default_search_string(int flags)
{
	if (flags & REGEX) {
		if (!_default_regex_search)
			_default_regex_search = malloc(FNAMELEN);
	} else {
		if (!_default_search)
			_default_search = malloc(FNAMELEN);
	}
	return (flags & REGEX) ? _default_regex_search : _default_search;
}

command replace_string() on reg_tab[ALT('&')]
{
	gen_replace(0);
}

command query_replace() on reg_tab[ALT('%')], reg_tab[ALT('r')]
{
	gen_replace(QUERY);
}

command regex_replace() on reg_tab[ALT('*')], reg_tab[NUMALT(GREYSTAR)]
{
	gen_replace(QUERY | REGEX);
}

command reverse_replace()
{
	gen_replace(QUERY | REVERSE);
}

gen_replace(flags)	/* get input, then do replace */
{
	char *str, with[FNAMELEN];

	if (has_arg)
		flags |= WORD;
	save_var point;
	flags = get_replace_text(flags, with);
	restore_vars();
	str = default_search_string(flags);
	if (flags != -1) {
		show_replace(str, with, flags);
		string_replace(str, with, flags | INCR);
	}
}

get_replace_text(int flags, char *with)
{
	char prompt[80], *str;

	iter = 0;
	flags = default_fold(flags);
	sprintf(prompt, "%s%sreplace string: ", (flags & FILEGREP) ? "file " :
		(flags & BUFGREP) ? "buffer " : "",
		(flags & QUERY) ? "query " : "");
	*prompt = toupper(*prompt);
	flags = search_read("", prompt, flags | REPLACE);
	flags &= ~(INCR | FAILING | BAD);
	if (flags & SEARCH_EMPTY)
		return -1;
	str = (flags & REGEX) ? _default_regex_replace
		: _default_replace;
	last_index = find_index(help_on_search(flags));
	save_var recall_id = "replace";
	get_strnone(with, "with: ", str);
	strcpy(str, with);
	return flags;
}

show_replace(str, with, flags)	/* print in echo area */
char *str, *with;
{
	char msg[FNAMELEN];

	make_search_prompt(msg, flags);
	if (flags & BAD) {
		say("%sReplace %s", msg, str);
		return;
	}
	strcat(msg, "Replacing ");
	if (strlen(str) > screen_cols / 2) {
		strncat(msg, str, screen_cols / 2);
		strcat(msg, "...");
	} else
		strcat(msg, str);
	strcat(msg, " with ");
	if (strlen(with) > screen_cols / 2) {
		strncat(msg, with, screen_cols / 2);
		strcat(msg, "...");
	} else
		strcat(msg, with);
	if (!in_macro())
		if (flags & QUERY)
			note("%s", msg);
		else
			noteput("%s", msg);
}

any_uppercase(char *p)	// return nonzero if p has any uppercase letters
{
	for (; *p; p++)
		if (isupper(*p))
			return 1;
	return 0;
}

want_case_replace(char *str, char *with, int flags)
{
	if (flags & MODFOLD) {
		if (!(flags & FOLD))
			return 0;
	} else if (!case_fold)
		return 0;
	return !any_uppercase(str) && !any_uppercase(with);
}

// Are words in the range i..j entirely uppercase, all capitalized
// (each word starts with an uppercase letter, optionally followed
// by nothing but lowercase letters until spaces), or something else?
// Return 1 for uppercase, 2 for capitalized, 0 otherwise.

check_for_case_replace(i, j)
{
	int k;
	int sofar = 0;

	if (i > j)
		k = i, i = j, j = k;
	while (i < j) {
		for (; !isalpha(character(i)); )
			if (++i >= j)
				return sofar;
		if (islower(character(i)))		// Is 1st alpha character lowercase?
			return 0;			// Otherwise, must look further.
		else if (++i >= j)
			return sofar ? sofar : 1;	// Only found 1 ltr words, assume UC.
		while (isalpha(character(i))) {
			if (islower(character(i))) {	// Are other alpha chars lowercase?
				if (sofar == 1)		// Last word was upper, this is mixed.
					return 0;
				sofar = 2;
			} else {
				if (sofar == 2)		// Last word was mixed, this is upper.
					return 0;
				sofar = 1;
			}
			if (++i >= j)
				return sofar;
		}
	}
	return sofar;
}

/* General replace routine. */

/* Interprets flag INCR to mean "interactive, show results". */

/* Returns DSABORT if the user aborted, DSBAD if illegal search string, */
/* 1 if user said to exit early, or 0 if we got to the last match. */

string_replace(str, with, flags)
char *str, *with;
{
	spot orig, prev, oldmark;
	int skip = 0, show = 0, ret, evershow = 0, oldstart, null_detect = -1, new_null_detect;
	int perform_case_replace, this_case_replace;

	if (_buf_readonly)
		error("Buffer is read-only.");
	if (!*str)
		return 0;
	perform_case_replace = want_case_replace(str, with, flags);
	orig = alloc_spot();
	prev = alloc_spot();
	save_var postpone_asynchronous_notify = 1;
	replace_num_found = replace_num_changed = 0;
	for (;;) {
		skip = 0;
		*prev = point;
		oldstart = matchstart;
		ret = do_searching(flags, str);
		if (!ret || ret == DSBAD) {
			point = *orig;
			break;
		} else if (ret == DSABORT)
			break;
		new_null_detect = (flags & REVERSE) ? point : (size() - point);
		if (null_detect == new_null_detect) {
			if ((flags & REVERSE) ? (point-- <= 0) : (point++ >= size())) {
				point = *orig;
				break;	// Make sure replacing a nullable pattern like $
			}			// moves forward.
			continue;
		} else
			null_detect = new_null_detect;
		replace_num_found++;
ask:
		if (show) {
			show_replace(str, with, (flags & ~INCR));
			evershow = 1;
			show = 0;
		}
		if (!(flags & QUERY)) goto do_replace;
		if (!get_replace_key(flags, str, skip)) { // show match, then get key
			point = *orig;		// match went away (maybe flags changed)
			break;
		}
		if (key == '?' || key == 'h'
			  || binding_of(key, root_keys) == (short) help) {
			help_on_command("query-replace");
			show = 1;
			point = *prev;
			null_detect = -1;
			continue;
		} else if (user_abort || key == abort_key) {
			point = *orig;
			ret = DSABORT;
			goto done;
		}
		switch(tolower(key)) {
			case '^': point = *prev; matchstart = oldstart;
			case '\b':
			case GREYBACK:
			case 'n': skip = 1;	/* go to the next match */
			case ' ':
			case 'y':		/* do the replace */
			case '!':
			case ',':
			case '.': break;
			case CTRL('R'):
				say("");
				oldmark = alloc_spot();
				*oldmark = mark;	/* save mark */
				mark = matchstart;
					/* set temporary mark before text */
				recursive_edit();
				if (spot_to_buffer(oldmark) < 0) {
					ret = DSABORT;	// user deleted buf
					goto done;
				}
				mark = *oldmark;	/* restore mark */
				free_spot(oldmark);
				show = 1;
				continue;
			default:	if (set_flag_modes(&flags)) {
						show = 1;
						goto ask;
					}
					if (!IS_ENTER_KEY(key))
						ungot_key = key;
			case ESC:	ret = 1; goto done;
		}
do_replace:
		if (!skip) {
			save_spot matchstart;
			if (perform_case_replace)
				this_case_replace = check_for_case_replace(matchstart, point);
			if (flags & REGEX)
				fromorig(with);
			else {
				delete(matchstart, point);
				stuff(with);
			}
			if (perform_case_replace)
				switch (this_case_replace) {
					case 1: do_uppercase_region(matchstart, point); break;
					case 2: do_capitalize_region(matchstart, point); break;
				}
			replace_num_changed++;
			restore_vars();
		}
		if (flags & QUERY)
			switch (key) {
			case ',': case '^':	skip = 1; goto ask;
			case '.':		ret = 1; goto done;
			case '!':		flags &= ~QUERY; show = 1;
			}
	}
done:
	if (ret == DSABORT)
		say("Replacement canceled");
	else if (ret == DSBAD)
		show_replace(str, with, (flags & ~INCR) | BAD);
	else if (!in_macro())
		if (evershow || (flags & INCR))
			say("Replaced %d of %d.", replace_num_changed,
			    replace_num_found);
		else if (evershow)
			say("");
	free_spot(orig);
	free_spot(prev);
	return ret;
}

get_replace_key(flags, str, skip)	// show match, then get a key
char *str;
{
	int oreg_type = region_type();

	if (!skip) {	// make sure we're in the right place given current flags
		save_var abort_searching = 0;
		point = matchstart;
		if (!do_searching(flags, str))
			return 0;
	}
	save_var mark = matchstart, _highlight_control;
	set_region_type(REGNORM);
	highlight_on();
	save_var matchstart, matchend;	// refresh could clobber this
	do {
		maybe_refresh();		/* show the selection */
		getkey();
	} while (!IS_TRUE_KEY(key));
	if (key == CTRL('^'))
		full_getkey("", CTRLIFY_KEY);
	user_abort = 0;
	restore_vars();
	set_region_type(oreg_type);
	if (!skip) {	// refresh could've clobbered regex state info
		save_var abort_searching = 0;	// so repeat srch
		point = matchstart;
		if (!do_searching(flags, str))
			return 0;
	}
	return 1;
}

do_searching(flags, str)	/* search according to flags */
char *str;	/* return 0=not found, 1=found, 2=aborted, 3=bad pattern */
{
	int ret, dir = (flags & REVERSE) ? -1 : 1;

	if (flags & MODFOLD)
		save_var case_fold = (flags & FOLD);
	save_var abort_searching = ABORT_ERROR;
	if (flags & REGEX)
		ret = do_regex_searching(flags, str);
	else if (flags & WORD)
		ret = word_search(dir, str);
	else
		ret = search(dir, str);
	if (ret == ABORT_ERROR)
		ret = DSABORT;
	return ret;
}

do_regex_searching(flags, str)
char *str;
{
	int ret, rflags = (flags & REVERSE) ? RE_REVERSE : 0;

	if (regex_first_end)		/* construct flags for */
		rflags |= RE_FIRST_END;	/* regex search from vars */
	if (regex_shortest)
		rflags |= RE_SHORTEST;
	do {
		ret = re_compile(rflags, str) ? DSBAD : re_search(rflags, str);
	} while (ret == 1 && (flags & WORD) &&
		!check_buffer_word(matchstart, matchend));
	return ret;
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

check_buffer_word(from, to) /* is this text surrounded by non-word chars? */
{
	int t;
	if (from > to)			/* ensure from <= to */
		t = from, from = to, to = t;
	return !(is_word_char(from - 1) || is_word_char(to));
}

is_word_char(pos)	/* is there a word character in buffer at pos? */
{
	int c = character(pos);

	return isident(c) || c >= 0x80;
}

fromorig(with)	/* do replace with #0, #1 */
char *with;
{
	int group;
#ifdef BIGREPL		/* this version handles any size replacement string */
	int orig = bufnum, tmp = tmp_buf();

	bufnum = tmp;
	for (; *with; with++) {
		if (*with != '#')
			insert(*with);
		else if (isdigit(*with++)) {
			bufnum = orig;
			group = *with - '0';
			buf_xfer(tmp, find_group(group, 1),
				find_group(group, 0));
			bufnum = tmp;
		} else if (*with)
			insert(*with);
		else
			with--;
	}
	bufnum = orig;
	delete(matchstart, point);
	grab_buffer(tmp);
	buf_delete(tmp);
#else		/* this version quickly handles replacements < 1000 chars */
	char *p, str[1000], *q = str;

	while (*with) {
		p = with;
		if (p)
			p = index(p, '#');
		if (!p) break;
		strncpy(q, with, p - with);	/* add till just before # */
		q += strlen(q);
		if (isdigit(*++p)) {
			group = *p - '0';
			grab(find_group(group, 1), find_group(group, 0), q);
			q += strlen(q);		/* add variable part */
		} else
			*q++ = *p;		/* #x gives x */
		with = p + 1;
	}
	strcpy(q, with);			/* add trailing part */
	delete(matchstart, point);		/* do replacement */
	stuff(str);
#endif
}

col_search(pat, col)		/* go to start of next line w/ string pat */
char *pat;			/* starting in column col */
{				/* return 1 if found, else 0 & go to start */
	int i;

	while (search(1, pat)) {
		i = point;
		point = matchstart;
		if (current_column() == col) {
			if (nl_reverse())
				point++;
			return 1;
		}
		point = i;
	}
	point = 0;
	return 0;
}

narrowed_search(int flags, char *str, int limit)
{
	save_var narrow_start = point - limit;
	save_var narrow_end = size() - (point + limit);

	return do_searching(flags, str);
}

// A quick and simple function for replacing one regex string with another.
// Use string_replace for replacement text with #1, replace counts, etc.
simple_re_replace(int flags, char *str, char *repl)
{
	save_spot point = 0;
	while (re_search(flags, str)) {
		delete(matchstart, matchend);
		stuff(repl);
	}
}

// Search and replace from a dialog box, for the Windows version.

struct find {
	char *find_text;
	char *replace_text;
	int flags;
} find_data;		// The find dialog looks at this variable directly.

// The search and replace strings.
char sbuf[FNAMELEN], rbuf[FNAMELEN];

setup_find_struct(replace)
{
	if (_last_was_regex)
		find_data.flags = _default_regex_flags;
	else
		find_data.flags = _default_flags;
	strncpy(sbuf, default_search_string(find_data.flags), sizeof(sbuf));
	find_data.find_text = sbuf;
	if (replace) {
		strcpy(rbuf, (find_data.flags & REGEX) ? _default_regex_replace
									 : _default_replace);
		find_data.replace_text = rbuf;
	} else
		find_data.replace_text = 0;
}


// Do a redisplay, but make sure that point is displayed
// within the top n lines.

redisplay_in(n)
int n;
{
	if (n > text_height())
		n = text_height();
	if (point < window_start
		|| point > move_by_screen_lines(window_start, n))
		window_start = move_by_screen_lines(point, -n/2);
	redisplay();
}

// Set the default search string & mode, and record in list of strings.
record_search(flags, s)
char *s;
{
	_last_was_regex = ((flags & REGEX) != 0);
	*(_last_was_regex ? &_default_regex_flags : &_default_flags) = flags;
	strcpy(default_search_string(flags), s);
	save_search_recall(flags, default_search_string(flags));
	if (find_data.replace_text) {
		save_recall(find_data.replace_text, "replace");
		strcpy((flags & REGEX) ? _default_regex_replace : _default_replace,
			   find_data.replace_text);
	}
}

int our_matchstart;	// make sure matchstart no longer changes unexpectedly

// Before replacing, we position to the start of the match and search
// for it again.  We need to do this for regex matches since code
// coloring might have occurred, preventing #1, #2 from working right.
// Also, flags might have changed since we searched, and the next
// match might have moved.  We don't replace when this happens.

perform_replace()
{
	int ostart = matchstart;

	save_spot matchstart;
	if (matchstart != our_matchstart)
		say("internal error: match start moved before replace");
	point = matchstart;
	if (find_from(find_data.flags, find_data.find_text, matchstart,
				  point) != 1 || ostart != matchstart) {
//		find_dialog_say("Pattern changed, text not replaced");
		return;		// Match has moved (flags changed?)
	}
	if (find_data.flags & REGEX)
		fromorig(find_data.replace_text);
	else {
		delete(matchstart, point);
		stuff(find_data.replace_text);
	}
}

find_from(flags, text, start_at, on_failure)
char *text;
{
	int r;
	point = start_at;
	r = do_searching(flags, text);
	if ( r != 1)
		point = on_failure;
	return r;
}

int search_and_show(flags, find_text, start_here, on_failure)
char *find_text;
{
	char msg[256];
	int r = find_from(flags, find_text, start_here, on_failure);
	switch (r){
		case 1:
			mark = matchstart;
			highlight_on();
			redisplay_in(window_lines_visible(window_handle));
			our_matchstart = matchstart;
			find_dialog_say("");
			break;
		case 0:
			sprintf(msg, "Not found: %s", find_data.find_text);
			redisplay_in(window_lines_visible(window_handle));
			find_dialog_say(msg);
			// button_dialog("Search failed", msg, "OK", "", "", 1);
			break;
		case 3:
			sprintf(msg, "Bad regex pattern: %s", find_data.find_text);
			find_dialog_say(msg);
			break;
	}
	return r;
}

int start_here;

int _basic_search()
{
	int r = search_and_show(find_data.flags, find_data.find_text, point, point);
	if (r){
			start_here = our_matchstart;
			if (matchstart != our_matchstart)
				say("matchstart trouble");
	}
	return r;
}

// If a flag is present in flags, turn it on.
// If a bit is present in mask but not in flags, turn it off.
// The bits we know about are MODFOLD, FOLD, WORD, REGEX, and REVERSE.
// We also accept REPLACE in flags to display a replace dialog instead
// of a search dialog.

_find(flags, mask)
{
	int oreg_type;

	save_var mark = point, _highlight_control = 0;	
	oreg_type = region_type();
	set_region_type(REGNORM);

	setup_find_struct(flags & REPLACE);
	find_data.flags &= ~mask;
	find_data.flags |= flags;
	find_dialog(1);
	start_here = point;
	while(1){
		int k = getkey();
		switch (k){
			case 'a':  // Replace All
				if (is_highlight_on())
					point = matchstart;		// include current match
				record_search(find_data.flags, find_data.find_text);
				set_region_type(oreg_type);
				find_dialog(0);
				string_replace(find_data.find_text, find_data.replace_text,
							   ((SMODES | REVERSE) & find_data.flags)
							   | REPLACE | INCR);
				return;
			case 'p':	// Replace
				if (is_highlight_on())		// Is there a current match?
					perform_replace();
//				else
//					note("No current match, doing find...");
				if (_basic_search() == 0){
					note("Replacement finished.");
					record_search(find_data.flags, find_data.find_text);
					find_dialog(0);
					set_region_type(oreg_type);
					return;
				}
				break;
			case CTRL('r'):
				find_data.flags |= REVERSE;
				find_dialog(1);
				_basic_search();
				break;
			case CTRL('s'):
				find_data.flags &= ~REVERSE;
				find_dialog(1);
				_basic_search();
				break;
			case CTRL('m'):
				_basic_search();
				break;
			case 's': // Incremental character.
				if (!(find_data.flags & REGEX) && !(find_data.flags & WORD))
					search_and_show(find_data.flags, find_data.find_text,
									start_here, point);
				break;
			case 'g':
				record_search(find_data.flags, find_data.find_text);
				find_dialog(0);
				set_region_type(oreg_type);
				return;
			case CTRL('t'):
				find_data.flags ^= REGEX;
				find_dialog(1);
				break;
			case CTRL('w'):
				find_data.flags ^= WORD;
				find_dialog(1);
				break;
			case CTRL('c'):
				find_data.flags ^= FOLD;
				find_data.flags |= MODFOLD;
				find_dialog(1);
				break;
		}
	}
}

command dialog_search()
{
	if (has_feature & FEAT_SEARCH_DIALOG)
		_find(0, REVERSE);
	else
		incremental_search();
}

command dialog_reverse_search()
{
	if (has_feature & FEAT_SEARCH_DIALOG)
		_find(REVERSE, REVERSE);
	else
		reverse_incremental_search();
}


command dialog_replace()
{
	if (has_feature & FEAT_SEARCH_DIALOG)
		_find(REPLACE, REVERSE | REGEX);
	else
		query_replace();
}

command dialog_regex_replace()
{
	if (has_feature & FEAT_SEARCH_DIALOG)
		_find(REPLACE | REGEX, REVERSE | REGEX);
	else
		regex_replace();
}

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

// This file has basic commands for moving around and inserting
// characters, and some handy general-purpose subroutines.

#include "eel.h"

/* insert the following extended ascii character into the buffer */

command quoted_insert() on reg_tab[CTRL('Q')]
{
	mention("Quote: ");
	do {
		getkey();
		if (IS_WIN_KEY(key)) {
			iter = 0;
			say("");
			return;
		}
	} while (key >= 512);
	if (key == CTRL('Q') && ungot_key != -1) {	// auto-quoted
		key = ungot_key;	// Strip extra auto-quoting.
		ungot_key = -1;
	}
	say("");
	if (user_abort == 2)
		check_abort();
	user_abort = 0;
	if (IS_ALT_KEY(key))
		key = key | 128;			// turn on meta bit
	delete_if_highlighted();
	while (iter-- > 0)
		insert(key);
}

/* toggle all self-inserting characters with self-overwrite */
command overwrite_mode() on reg_tab[KEYINSERT]
{
	over_mode = (has_arg? (iter != 0) : !over_mode);
	make_mode();
	iter = 1;
}

/* insert or overwrite according to mode */
command normal_character() on reg_tab['\n']		/* more bindings, see below */
{
	int i;

	check_abort();
	delete_if_highlighted();
	if (!call_maybe_break_line(3))
		return;
	if (key >= 512) return;
	if (IS_ALT_KEY(key))
		key = key | 128;			// turn on meta bit
	if (key == '\n') {
		if (over_mode) {
			if (!nl_forward())
				insert('\n');
		} else if (auto_indent && indenter) {
			delete(point, point - parse_string(-1, "[ \t]*"));
			insert('\n');		/* delete trailing whitesp */
			(*indenter)();
		} else
			insert('\n');
	} else if (over_mode && point < size() && curchar() != '\n') {
		if (curchar() == '\t')
			i = display_width('\t', current_column());
		else
			i = 0;
		replace(point++, key);
		while (--i > 0)		/* insert i-1 spaces after pt */
			insert(' '), point--;
	} else
		insert(key);
}

when_loading()		/* put it on the other keys, too */
{
	int i;

	for (i = ' '; i <= '~'; i++)
		reg_tab[i] = (short) normal_character;
	for (i = 128; i <= 255; i++)	// international keys
		reg_tab[i] = (short) normal_character;
}

// If there's a highlighted region, maybe delete it so we can replace it
// with new chars.  Return 1 if we did.
delete_if_highlighted()
{
	if (typing_deletes_highlight && is_highlight_on()) {
		save_spot point, mark;
		if (region_type() == REGRECT)
			delete_rectangle();
		else {
			fix_region();
			delete(point, mark);
		}
		highlight_off();
		return 1;
	}
	return 0;
}

/* Go to the beginning of the current line */
command beginning_of_line() on reg_tab[CTRL('A')], reg_tab[NUMALT(KEYLEFT)],
							   reg_tab[NUMALT(NUMDIGIT(4))]
{
	iter=0;				/* throw away any argument */
	do_shift_selects();
	cursor_to_column = -1;
	to_begin_line();
}

/* Go to the end of the current line */
command end_of_line() on reg_tab[CTRL('E')], reg_tab[NUMALT(KEYRIGHT)],
						 reg_tab[NUMALT(NUMDIGIT(6))]
{
	iter=0;			/* throw away any argument */
	do_shift_selects();
	cursor_to_column = -1;
	to_end_line();
}

give_begin_line()	/* return the position of this line's start */
{
	save_var point;
	to_begin_line();
	return point;
}

give_end_line()		/* return the position of this line's end */
{
	save_var point;
	to_end_line();
	return point;
}

command down_line() on reg_tab[CTRL('N')], reg_tab[KEYDOWN]
{
	int true;

	down_or_up_lines(1);
	true = point;
	while (scroll_at_end > 0 && true > window_end) {
		window_scroll(scroll_at_end);
		if (window_end + 1 >= size() - narrow_end)
			break;		/* make sure we stop at end */
		point = window_end + 1;	/* compute window_end explicitely */
		window_end = next_screen_line(scroll_at_end) - 1;
		check_abort();
	}
	point = true;
}

command up_line() on reg_tab[CTRL('P')], reg_tab[KEYUP]
{
	int max = iter + 5;

	down_or_up_lines(0);
	while (scroll_at_end > 0 && point < window_start) {
		window_scroll(-scroll_at_end);
		check_abort();
		if (max-- < 0)
			break;
	}
}

virtual_column()
{
	return (cursor_to_column >= 0) ? cursor_to_column : current_column();
}

down_or_up_lines(down_lines)
{
	int hit_end = 0, wantcol;

	do_shift_selects();
	if (iter < 0)
		iter = -iter, down_lines = !down_lines;
	if (prev_cmd != SAMECOL)
		_preserve_column = virtual_space ? virtual_column()
					: current_column();
	while (iter-- > 0)
		if (!down_lines)
			nl_reverse();
		else if (!nl_forward()) {
			hit_end = 1;
			break;
		}
	wantcol = (goal_column >= 0) ? goal_column : _preserve_column;
	if (virtual_space)
		to_virtual_column(wantcol);
	else if (!hit_end || goal_column >= 0)	/* stay at end if we tried */
		move_to_column(wantcol);	/* to move past it */
	this_cmd = SAMECOL;
	iter = 0;
}

to_virtual_column(col)
{
	move_to_column(col);
	if (current_column() != col) {
		cursor_to_column = col;
		call_on_modify = 1;
	} else
		cursor_to_column = -1;
}

/* Set point to the previous character in the buffer */
command backward_character() on reg_tab[CTRL('B')], reg_tab[KEYLEFT]
{
	do_shift_selects();
	if (virtual_space < 2) {
		point -= iter;
		iter = 0;
	} else
		to_virtual_column(virtual_column() - 1);
}


/* Set the point to the next character in the buffer */
command forward_character() on reg_tab[CTRL('F')], reg_tab[KEYRIGHT]
{
	do_shift_selects();
	if (virtual_space < 2) {
		point += iter;
		iter = 0;
	} else
		to_virtual_column(virtual_column() + 1);
}

// Return nonzero if the shift key's down.  Handles keyboard macro
// case too; records shift state if recording one, and reads shift state
// if not.

was_key_shifted()
{
	int shifted;

	if (key_type == KT_MACRO)	// Was this key from a macro?
		shifted = 0;			// Yes, and it was unshifted.
	else if (key_type == KT_EXTEND_SEL)
		shifted = 1;			// Yes, and it was shifted.
	else					// Not from a macro, look at actual shift key.
		shifted = shift_pressed() & KB_SHIFT_DN;
	if (shifted && _len_def_mac > 0 && !recording_suspended
		&& key == def_text[_len_def_mac - 1])	// And record in macro.
		def_text[_len_def_mac - 1] |= EXTEND_SEL_KEY;
	return shifted;
}

do_shift_selects()
{
	if (!shift_selects || key < 512 || NUMPLAIN(key) < KEYEND
		|| NUMPLAIN(key) > KEYPGUP) {	// only affects cursor keys
		if (shift_selecting == 2)		// except at prompts
			highlight_off();
		return;
	}
	if (was_key_shifted()) {
		if (!is_highlight_on())		// if shift key is down, begin/extend
			do_set_mark(point);		// selection
		set_region_type(REGNORM);
		highlight_on();
		shift_selecting = 1;
	} else if (shift_selecting)	// if shift was just removed, remove highlight
		highlight_off();
}

command open_line() on reg_tab[CTRL('O')]
{
	insert('\n');
	point--;
}

command goto_beginning() on reg_tab[ALT('<')], reg_tab[NUMCTRL(KEYHOME)]
{
	do_shift_selects();
	point = 0;
}

command goto_end() on reg_tab[ALT('>')], reg_tab[NUMCTRL(KEYEND)]
{
	do_shift_selects();
	point = size();
}

go_line(line)
{
	point = 0;
	while (--line > 0)
		if (!nl_forward())
			break;
}

// Prompt for a line number and go to that line.  Also recognizes:

// 40%     Go to a line 40% of the way into the buffer.
// :20     Go to column 20 on this line.
// 10:20   Go to column 20 on line 10.
// 40%:20  Go to column 20 on a line 40% of the way into the buffer.

// With a numeric argument, go to the indicated line number without prompting.

command goto_line() on cx_tab['g']
{
	char res[FNAMELEN], *p;
	int num = iter;

	got_bad_number = iter = 0;
	if (has_arg) {
		go_line(num);
		return;
	}
	get_string(res, "Go to line: ");
	num = numtoi(res);
	if (!got_bad_number) {
		if (strchr(res, '%')) {
			point = muldiv(size(), num, 100);	// handles intermediates > 32 bits
			if (num)
				nl_forward();
		} else
			go_line(num);
	}
	p = strchr(res, ':');		// a number after : or . is a column
	if (!p)
		p = strchr(res, '.');
	if (p) {
		num = numtoi(p + 1);
		if (!got_bad_number)
			to_column_and_center(num);
	}
}

int isalnum(int c)
{
	return isalpha(c) || isdigit(c);
}

int isident(int c)
{
	return isalpha(c) || isdigit(c) || c == '_';
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

full_getkey(char *prompt, int code)
{			/* get a key using ^Q, ^[, and ^^ prefixes */
	char msg[80];
	int allcode = 0, refreshed = 0;

	strcpy(msg, prompt);
	for (;;) {
		switch (code) {
			case ALTIFY_KEY:  strcat(msg, "<Alt> "); break;
			case CTRLIFY_KEY: strcat(msg, "<Ctrl> "); break;
		}
		allcode |= code, code = 0;
		for (;;) {
			mention("%s", msg);
			getkey();
			if (key != MOUSE_MOVE && !IS_WIN_KEY(key))
				break;
			if (!refreshed)
				refresh();
			refreshed = 1;
		}
		if (allcode & ALTIFY_KEY)
			key = make_alt(key);
		if (allcode & CTRLIFY_KEY)
			key = make_ctrl(key);
		if (root_keys[key] == (short) alt_prefix)
			code = ALTIFY_KEY;
		else if (root_keys[key] == (short) ctrl_prefix)
			code = CTRLIFY_KEY;
		else
			return;
	}
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

command insert_ascii() on reg_tab[ALT('#')] /* insert character by number */
{
	int res;

	if (run_by_mouse)
		has_arg = 0;
	res = get_number("Insert character with ASCII code: ");
	if (res < 0 || res > 255)
		error("Invalid ASCII code %d.", res);
	else if (!got_bad_number)
		insert(res);
}

short *ask_key(char *pr, char *keyname)
{	/* prompt for a key, giving name and pointer for binding */
	int index;
	short *tab, *alttab;
	char msg[80];

	tab = mode_keys;
	alttab = root_keys;
	*keyname = 0;			// put readable form of key here
	key_binding[0] = 1;		// also save sequence in this global
	for (;;) {
		sprintf(msg, "%s%s", pr, keyname);
		full_getkey(msg, 0);
		if (root_keys[key] == (short) quoted_insert) {
			mention("%s<Quote> ", msg);
			getkey();
			user_abort = 0;
		}
		check_abort();
		show_char(keyname, key, 1);
		key_binding[key_binding[0]] = key; // add to constructed key
		key_binding[0]++;
		index = (tab[key] == 0) ? alttab[key] : tab[key];
		if (index <= 0 || name_type(index) != NT_TABLE)
			break;
		alttab = index_table((tab[key] && !alttab[key]) ?
						tab[key] : alttab[key]);
		tab = index_table(index);
		if (!alttab)
			alttab = tab;
		strcat(keyname, " ");
	}
	say("");
	return ((tab[key] == 0) ? alttab : tab) + key;
}

char *temp_buf()	/* create a unique temporary buffer, return name */
{
	return bufnum_to_name(tmp_buf());
}

tmp_buf()	/* create a unique temporary buffer, return number */
{
	char bname[80];
	int uniq = 1;

	do {
		sprintf(bname, "-temp%d", uniq++);
	} while (exist(bname));
	return create(bname);
}

int strtoi(char *s, int base)
{	/* convert a string of digits to a number */
	char *p, *digits = "0123456789ABCDEF";
	int number, neg = 0;

	got_bad_number = 0;
	while (*s == '-')
		s++, neg = !neg;
	number = 0;
	if (!*s || !index(digits, toupper(*s)))
		got_bad_number = 1;
	while (*s && (p = index(digits, toupper(*s++))) && p - digits < base)
		number = number * base + (p - digits);
	return neg ? -number : number;
}

numtoi(char *s)	/* like strtoi(), but get base from string */
{
	int neg = 0, i;
	char *from = "nbtrf", *to = "\n\b\t\r\f", *p;

	got_bad_number = 0;
	while (isspace(*s))
		s++;
	if (*s == '\'') {		/* allow 'x' as a number (give ascii code) */
		if (s[1] != '\\' && s[2] == '\'')
			return s[1];
		if (s[1] == '\\' && s[2] && s[3] == '\'') {
			p = strchr(from, s[2]);
			if (p)
				return to[p - from];
			return s[2];
		}
		got_bad_number = 1;
		return s[1];
	}
	while (*s == '-')
		s++, neg = !neg;
	if (s[0] == '0' && tolower(s[1]) == 'x')
		i = strtoi(s + 2, 16);
	else if (s[0] == '0' && tolower(s[1]) == 'o')
		i = strtoi(s + 2, 8);
	else if (s[0] == '0' && tolower(s[1]) == 'b')
		i = strtoi(s + 2, 2);
	else
		i = strtoi(s, 10);
	return neg ? -i : i;
}

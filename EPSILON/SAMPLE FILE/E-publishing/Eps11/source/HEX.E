/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*	Copyright (C) 1999, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

// Take a file and show a hex version.

#include "eel.h"
#include "hex.h"
#include "colcode.h"
#include "diff.h"

char *hex_prefix()
{
	return (major_mode == _hex_overtype_mode_name) ? "Ctrl-C " : "";
}

// What to show in ascii column for this character.
hex_printable(int c)
{
	if ((c & 0x7f) < 0x20 || (c & 0x7f) == 0x7f || display_width(c, 0) != 1)
		return '.';
	return c;
}

color_hex_range(from, to)
{
	int cnt, pos, oldbuf = 0, dump, ascii, i, j;
	char oldbytes[20], newbytes[20];

	if (from >= to)
		return to;
	if (strlen(bufname) > sizeof(HEX_BUFNAME_PREFIX))
		oldbuf = name_to_bufnum(bufname + sizeof(HEX_BUFNAME_PREFIX) - 1);
	save_var point, matchstart, matchend;
	point = from;
	to_begin_line();
	save_var narrow_start = give_begin_line();
	point = to;
	nl_forward();
	save_var narrow_end = size() - point;
	point = 0;
	do {
		dump = column_to_pos(HEX_DUMP_COL);
		ascii = column_to_pos(HEX_ASCII_COL);
		set_character_color(point, dump, color_class hex_address);
		set_character_color(dump, ascii, -1);
		set_character_color(ascii, column_to_pos(HEX_ASCII_COL_END),
							color_class hex_ascii);
		if (!oldbuf)
			continue;
		pos = hex_get_offset();
		cnt = hex_extract(dump, newbytes, 0);
		if (cnt < 0)
			continue;
		buf_grab_bytes(oldbuf, pos, pos + cnt, oldbytes);
		for (i = 0; i < cnt; i++)
			if (oldbytes[i] != newbytes[i]) {
				j = dump + (i * 5 / 2);
				set_character_color(j, j + 2, color_class hex_change);
				set_character_color(ascii + i, ascii + i + 1,
									color_class hex_change);
			}
	} while (nl_forward());
	return point;
}

// Put hex version of current buffer in bname.
buffer_to_hex(char *bname)
{
	char trans[256];
	int i;

	zap(bname);
	save_var point = 0, narrow_start = 0, narrow_end = 0;
	for (i = 0; i < 256; i++)
		trans[i] = hex_printable(i);
#if 1			// Use primitive for faster conversion.
	do_buffer_to_hex(bname, trans);
#else
 	for (i = 0; i < size(); i += 16) {
		char bytes[30], ascii[30];
		if (i && !(i % 4096)) {	// Do occasionally.
			note("Generating hex dump: %d%% complete.", muldiv(i, 100, size()));
			check_abort();
		}
		grab(i, i + 16, bytes);
		for (j = 0; j < 16; j++)
			ascii[j] = trans[bytes[j]];
		ascii[16] = 0;
		buffer_printf(bname, "%04x:%04x  %02x%02x %02x%02x %02x%02x %02x%02x-"
				"%02x%02x %02x%02x %02x%02x %02x%02x  %s\n",
				(i >> 16) & 0xffff, i & 0xffff,
				bytes[0], bytes[1], bytes[2], bytes[3],
				bytes[4], bytes[5], bytes[6], bytes[7],
				bytes[8], bytes[9], bytes[10], bytes[11],
				bytes[12], bytes[13], bytes[14], bytes[15], ascii);
	}
	i -= size();		// Find # of excess bytes to delete.
	bufname = bname;
	point = size() - 1;
	delete(point - i, point);
	move_to_column(HEX_DUMP_COL + ((16 - i) * 5 / 2));
	for (; current_column() < HEX_ASCII_COL && point < size(); point++)
		replace(point, ' ');
	modified = 0;
	say("");
#endif
}

// Read one line of hex dump starting at pos, write bytes.
// Return # of bytes.
int hex_extract(int pos, char *bytes, int err)
{
	int i;
	char *p, *q, *hex = HEX_CHARS;

	save_var point = pos;
	for (i = 0; i < 16 && curchar() != ' '; i++) {
		p = strchr(hex, toupper(curchar()));
		point++;
		q = strchr(hex, toupper(curchar()));
		point++;
		if (!p || !q) {
			if (err)
				error("Hex dump: bad format at %d", point);
			else
				return -1;
		}
		if (strchr(" -", curchar()))
			point++;
		*bytes++ = (p - hex) * 16 + (q - hex);
	}
	return i;
}

// Set offset'th byte on this line to value.
hex_modify_byte(int offset, int value)
{
	int start = give_begin_line();

	save_var call_on_modify = 0;
	save_var point = start + HEX_ASCII_COL + offset;
	replace(point, hex_printable(value));
	point = start + HEX_DUMP_COL + (offset * 5 / 2);
	delete(point, point + 2);
	bprintf("%x%x", value >> 4, value & 0xf);
}

// Self-inserting keys run this in hex mode.
// Maybe modify the hex buffer, maybe search in it, maybe gripe.
replace_in_hex_buffer()
{
	int start = give_begin_line(), orig = point, col = point - start, i, j;
	char bytes[16];

	save_var call_on_modify = 0;
	if (hex_maybe_overtype())
		return;
	if (!IS_EXT_ASCII_KEY(key) || !strchr(HEX_CHARS, toupper(key)))
		error("Not a hex key: 0-9, a-f.  Press %sq to quit hex mode.",
			  hex_prefix());
	say("");
	if (col >= HEX_ASCII_COL && col < HEX_ASCII_COL_END) {
		hex_tab_key();
		col = point - start;
	}

	if (col < 8 && col != 4) {
		char pos[10];
		grab(start, start + 9, pos);
		pos[col] = key;
		point = 0;
		save_var case_fold = 1;
		if (!col_search(pos, 0)) {
			point = orig;
			error("Can't find offset %s", pos);
		}
		point += col + 1 + (col == 3);
	} else if (col == 8 && key == '0') {
		point += 3;
	} else if (col >= HEX_DUMP_COL && col < HEX_ASCII_COL
			   && strchr(HEX_CHARS, toupper(curchar()))) {
		replace(point++, toupper(key));
		if (strchr(" -", curchar()))
			point++;
		if (current_column() >= HEX_ASCII_COL - 1)
			nl_forward(), move_to_column(HEX_DUMP_COL);
		j = hex_extract(start + HEX_DUMP_COL, bytes, 1);
		start += HEX_ASCII_COL;
		for (i = 0; i < j; i++)
			replace(start + i, hex_printable(bytes[i]));
	} else
		error("That key is invalid in this column.");
}

when_loading()		/* disable self-inserting chars */
{
	fix_key_table(reg_tab, (short) normal_character,
				  hex_tab, replace_in_hex_buffer);
}

// If the next key is a hex command, do it.  Otherwise do the original
// Ctrl-c binding.

hex_cc_prefix() on hex_tab[CTRL('C')]
{
	int cmd;

	table_keys[table_count++] = key;
	table_prompt();
	getkey();
	cmd = binding_of(key, hex_tab);
	if (cmd <= 0 || cmd == hex_cc_prefix)
		cmd = binding_of(key, cc_tab);
	save_var hex_overtype_mode = 2;
	say("");
	do_command(cmd);
}

// If we're in the overtype submode and in the ascii column, overtype
// with the pressed key and return 1.  Otherwise return 0.

int hex_maybe_overtype()
{
	int pos, col = current_column();

	if (!is_hex_buffer(bufnum) || hex_overtype_mode == 2)
		return 0;
	if (col < HEX_ASCII_COL || col >= HEX_ASCII_COL_END)
		return 0;
	if (major_mode != _hex_overtype_mode_name || !IS_ASCII_KEY(key))
		return 0;
	save_var call_on_modify = 0;
	pos = hex_get_offset();
	if (pos >= hex_get_original_buffer_size())
		return 0;
	hex_goto_place(pos, 1);
	hex_modify_byte(pos & 0xf, key);
	hex_goto_place(pos + 1, 1);
	return 1;
}

hex_help() on hex_tab['?']
{
	if (hex_maybe_overtype())
		return;
	help_on_mode();
}

hex_down_line() on hex_tab['n']
{
	if (hex_maybe_overtype())
		return;
	down_line();
}

hex_up_line() on hex_tab['p']
{
	if (hex_maybe_overtype())
		return;
	up_line();
}

hex_backspace() on hex_tab[CTRL('H')], hex_tab[DEL],
				   hex_tab[NUMSHIFT(GREYBACK)], hex_tab[GREYBACK]
{
	int col = current_column();
	if (col >= HEX_DUMP_COL && col < HEX_ASCII_COL) {
		point--;
		if (strchr(" -", curchar()))
			  point--;
		if (current_column() < HEX_DUMP_COL) {
			hex_goto_place(hex_get_offset() - 1, 0);
			point++;
		}
	} else
		hex_goto_place(hex_get_offset() - 1, 1);
}

hex_search() on hex_tab['s'], hex_tab['r']
{
	char bytes[FNAMELEN], pat[FNAMELEN * 6], *hex = HEX_CHARS, *p, *q;
	int i, pos, dir, orig = bufnum, res;
	char *temp;

	if (hex_maybe_overtype())
		return;
	dir = (key == 'r') ? -1 : 1;
	pos = hex_get_offset();
	get_string(bytes, "Hex bytes to search for: ");
	*pat = 0;
	for (i = 0; bytes[i]; ) {
		while (bytes[i] == ' ')
			i++;
		p = strchr(hex, toupper(bytes[i]));
		q = strchr(hex, toupper(bytes[i + 1]));
		if (p && q) {
			sprintf(pat + strlen(pat), "<#0x%c%c>", bytes[i], bytes[i + 1]);
			i += 2;
		} else if (p)
			sprintf(pat + strlen(pat), "<#0x%c>", bytes[i++]);
		else
			error("Can't interpret %s, got %s.", bytes, pat);
	}
	hex_toggle_buffers();
	pos = point;
	temp = temp_buf();
	xfer(temp, 0, size());
	to_buffer_num(orig);
	hex_apply_all(temp);
	bufname = temp;
	point = pos;
	case_fold = 0;
	save_var abort_searching = ABORT_ERROR;
	res = re_search(dir, pat);
	pos = point;
	to_buffer_num(orig);
	delete_buffer(temp);
	if (res == 1) {
		hex_goto_place(pos, 0);
		say("Found.");
	} else if (res == 0)
		error("Not found: %s", bytes);
}

// Return size of original buffer.
int hex_get_original_buffer_size()
{
	char res[FNAMELEN];

	if (!is_hex_buffer(bufnum))
		return 0;
	strcpy(res, bufname + sizeof(HEX_BUFNAME_PREFIX) - 1);
	return buffer_size(res);
}

hex_overtype() on hex_tab['o']
{
	int col = current_column();

	if (hex_maybe_overtype())
		return;
	if (major_mode == _hex_overtype_mode_name)
		major_mode = _hex_mode_name;
	else if (major_mode == _hex_mode_name) {
		if (col < HEX_DUMP_COL || col >= HEX_ASCII_COL_END)
			move_to_column(HEX_ASCII_COL);
		else if (col < HEX_ASCII_COL)
			hex_tab_key();
		say("Press Ctrl-C o to leave overtype submode.");
		major_mode = _hex_overtype_mode_name;
	}
	make_mode();
}

hex_set_byte() on hex_tab['#']
{
	int val, col = current_column(), offset = 0;

	if (hex_maybe_overtype())
		return;
	val = get_number("Replace this byte with: ");
	if (col >= HEX_DUMP_COL && col < HEX_ASCII_COL)
		offset = ((col - HEX_DUMP_COL + 1) * 2) / 5;
	else if (col >= HEX_ASCII_COL && col < HEX_ASCII_COL_END)
		offset = col - HEX_ASCII_COL;
	if (offset > 15)
		offset = 15;
	hex_modify_byte(offset, val);
}

// Set bytes in buf at position represented by line to bytes.
hex_apply_change(char *buf, char *line, char *bytes, int cnt)
{
	int pos = (strtoi(line, 16) << 16) + strtoi(line + 5, 16);

	save_var call_on_modify = 0;
	save_var bufname = buf;
	save_var point = pos;
	save_var call_on_modify = 0;
	while (cnt-- > 0)
		replace(point++, *bytes++);
}

// Apply all changes in current buffer to buffer buf.

hex_apply_all(char *buf)
{
	char bytes[16];
	char line[FNAMELEN];
	int next, start, cnt;

	for (point = 0; point < size(); ) {
		if (get_character_color(point, NULL, &next)
			  == color_class hex_change) {
			start = give_begin_line();
			grab(start, start + 9, line);	// Get address of change.
			nl_forward();
			cnt = hex_extract(start + HEX_DUMP_COL, bytes, 1);
			hex_apply_change(buf, line, bytes, cnt);
		} else
			point = next;
	}
}

// Return 1 if yes, 2 if no, 3 if cancel.
hex_ask_apply()
{
	if (is_gui && want_gui_prompts) {
		say("Leaving hex mode.");
		return button_dialog("Apply changes?", "Apply these changes?",
							 "Yes", "No", "Cancel", 1);
	} else {
		sayput("Leaving hex mode; apply these changes? [Y] ");
		for (;;) {
			getkey(); 
			if (user_abort)
				return 3;
			switch (toupper(key)) {
				case 'Y': say(""); return 1;
				case 'N': say(""); return 2;
			}
			if (IS_ENTER_KEY(key)) {
				say("");
				return 1;
			}
		}
	}
}

// Apply changes to original buffer.
hex_save_key() on hex_tab['x'], hex_tab['q'], hex_tab['X'], hex_tab['Q']
{
	char orig[FNAMELEN];
	int hexbuf = bufnum, pos, answer = 2;

	if (!is_hex_buffer(bufnum))
		error("Not a hex buffer");
	if (hex_maybe_overtype())
		return;
	pos = hex_get_offset();
	strcpy(orig, bufname + sizeof(HEX_BUFNAME_PREFIX) - 1);
	if (modified)
		answer = hex_ask_apply();
	else
		say("Leaving hex mode.");
	if (answer == 3)
		return;
	if (answer == 1)
		hex_apply_all(orig);
	check_abort();
	to_buffer(orig);
	buf_delete(hexbuf);
	point = pos;
	buffer_on_modify = 0;
}

hex_tab_key() on hex_tab['\t'], hex_tab[NUMSHIFT(GREYTAB)]
{
	int start = give_begin_line(), col = point - start;

	if (col < HEX_DUMP_COL || col == HEX_ASCII_COL_END)
		move_to_column(HEX_DUMP_COL);
	else if (col < HEX_ASCII_COL)
		move_to_column(HEX_ASCII_COL + ((col - HEX_DUMP_COL + 1) * 2) / 5);
	else
		move_to_column(HEX_DUMP_COL + ((col - HEX_ASCII_COL) * 5 / 2));
}

// Return the byte offset represented by this position.
int hex_get_offset()
{
	char line[FNAMELEN];
	int start, pos, col;

	if (!is_hex_buffer(bufnum))
		return point;
	start = give_begin_line();
	col = point - start;
	grab(start, start + 9, line);	// Get address of change.
	pos = (strtoi(line, 16) << 16) + strtoi(line + 5, 16);
	if (col >= HEX_DUMP_COL && col < HEX_ASCII_COL)
		pos += ((col - HEX_DUMP_COL + 1) * 2) / 5;
	else if (col >= HEX_ASCII_COL && col < HEX_ASCII_COL_END)
		pos += col - HEX_ASCII_COL;
	return pos;
}

// Switch from hex to original buffer, retaining position.
hex_toggle_buffers() on hex_tab['t']
{
	char orig[FNAMELEN];
	int pos;

	if (hex_maybe_overtype())
		return;
	if (is_hex_buffer(bufnum)) {
		strcpy(orig, bufname + sizeof(HEX_BUFNAME_PREFIX) - 1);
		pos = hex_get_offset();
		to_buffer(orig);
		point = pos;
	}
}

// Is this a hex-format buffer?
is_hex_buffer(int b)
{
	save_var bufnum = b;
	return !strncmp(bufname, HEX_BUFNAME_PREFIX,
					sizeof(HEX_BUFNAME_PREFIX) - 1);
}

// Move in the hex buffer to the line describing this offset, in either
// the hex dump or the ascii column.
hex_goto_place(int pos, int ascii)
{
	char place[20];

	save_var case_fold = 1;
	sprintf(place, "^%04x:%04x  ", (pos >> 16) & 0xffff, pos & 0xfff0);
	point = 0;
	if (pos < 0)
		return;
	if (!re_search(1, place))
		error("Can't locate offset %x in hex listing.", pos);
	move_to_column(ascii ? (HEX_ASCII_COL + (pos & 0xf))
						 : (HEX_DUMP_COL + ((pos & 0xf) * 5 / 2)));
}

hex_on_modify()	// Tried to modify buffer with hex display.
{
	call_on_modify = 1;
	error("Edit this buffer using hex-mode commands.  "
		  "Press %s? for help.", hex_prefix());
}

hex_old_on_modify()	// Tried to modify original buffer.
{
	char bname[FNAMELEN];
	int pos;

	call_on_modify = 1;
	pos = point;
	sprintf(bname, "%s%s", HEX_BUFNAME_PREFIX, bufname);
	if (!exist(bname)) {
		buffer_on_modify = 0;
		error("Hex buffer is gone: exiting hex mode");
	}
	to_buffer(bname);
	hex_goto_place(pos, 0);
	if (binding_of(key, hex_tab) == hex_toggle_buffers || key == '\t')
		quick_abort();
	else
		error("You must press %sq to quit hex-mode before you can "
			  "edit the buffer.", hex_prefix());
}

command hex_mode()
{
	char bname[FNAMELEN];
	int pos = point;

	if (is_hex_buffer(bufnum)) {	// "Turn off mode" -- save back to real buf.
		hex_save_key();
		return;
	}
	if (!size())
		error("Buffer is empty.");
	call_on_modify = 1;		// Make the buffer read-only so only our
	buffer_on_modify = hex_old_on_modify;	// special funcs can modify it.
	sprintf(bname, "%s%s", HEX_BUFNAME_PREFIX, bufname);
	if (exist(bname)) {
		say("This buffer is in hex mode.  Press %s? for help or %sq to quit.",
			  hex_prefix(), hex_prefix());
		to_buffer(bname);
		return;
	}
	buffer_to_hex(bname);
	to_buffer(bname);
	call_on_modify = 1;		// Make the buffer read-only so only our
	buffer_on_modify = hex_on_modify;	// special funcs can modify it.
	mode_keys = hex_tab;		/* Use these keys. */
	major_mode = hex_overtype_mode ? _hex_overtype_mode_name : _hex_mode_name;
	recolor_range = color_hex_range;	// set up coloring rules
	recolor_from_here = recolor_by_lines;
	idle_coloring_delay = -1; // No idle coloring, it slows down apply-changes.
	if (want_code_coloring)		// maybe turn on coloring
		when_setting_want_code_coloring();
	try_calling("hex-mode-hook");
	drop_all_colored_regions();
	make_mode();
	say("Entering hex mode, press %s? for help or %sq to quit.",
		  hex_prefix(), hex_prefix());
	hex_goto_place(pos, hex_overtype_mode);
}

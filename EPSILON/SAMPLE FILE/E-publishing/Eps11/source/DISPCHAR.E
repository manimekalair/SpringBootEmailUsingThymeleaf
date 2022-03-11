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

// This file has the set-display-characters command.

#include "eel.h"
#include "colcode.h"

#define CHR_COL		8
#define CHR_LINE	2
#define SCRPLACE(c)	(CHR_COL + ((c) & 31) * 2), \
			(CHR_LINE + (((c) >> 5) & 7) * 2)
#define SHOW(c, l, s)	term_write(c, l, s, strlen(s), \
			color_class viewed_text, 1)

int disp_char_look(int c)
{
	if (opsys == OS_UNIX)
		if (c >= CTRL('G') && c <= CTRL('M') || (c & 0x7f) == ESC
			|| (c & 0x7F) == 0x7f)
			return 'X';
	return c;
}

when_loading()		/* query user to set display characters */
{
	int class, charac, i, matrix = 0, orig[NUMDISPCHARS], cwin;
	char buf[200];

	save_var auto_show_matching_characters = 0;
	for (i = 0; i < NUMDISPCHARS; i++)
		orig[i] = _display_characters[i];
	class = iter = 0;
	cwin = add_popup(0, 0, screen_cols, screen_lines, ALL_BORD(BNONE), bufnum);
	invisible_window = 1;
	for (;;) {
		if (!matrix) {
			term_clear();		/* write a matrix of chars */
			for (i = 0; i < 256; i++) {
				sprintf(buf, "%c", disp_char_look(i));
				term_write(SCRPLACE(i), buf, 1,
					color_class text, 0);
			}
			matrix = 1;
		}
		charac = _display_characters[class];
		i = class;
		if (i < NUMLINECHARS)
			sprintf(buf, "%s %s Line",
				(i & 1) ? "Double" : "Single",
				(i < 2) ? "Horizontal": "Vertical");
		else if ((i -= NUMLINECHARS) < NUMCORNERCHARS) {
			strcpy(buf, (i < 18) ? "Single " : "Double ");
			i %= 18;
			strcat(buf, (i < 9) ? "Single " : "Double ");
			i %= 9;
			if (i % 3 == 0)
				strcat(buf, "Left ");
			else if (i % 3 == 2)
				strcat(buf, "Right ");
			if (i < 3)
				strcat(buf, "Top ");
			else if (i >= 6)
				strcat(buf, "Bottom ");
			strcat(buf, (i == 4) ? "Plus" :
				(i & 1) ? "T" : "Corner");
		} else if ((i -= NUMCORNERCHARS) < NUMTEXTCHARS) {
			if (i < 4)
				sprintf(buf, "%s %d", i < 2 ? "Continuation"
					: "Tab", (i % 2) + 1);
			else {
				strcpy(buf, index("0Newline1^ for Tab"
					"2^ for Newline3Control4Meta 15Meta 2"
					"6Control-Meta 17Control-Meta 2"
					"8Control-Meta 39Hex:",
					i - 4 + '0') + 1);
				*index(buf, i - 4 + '1') = 0;
			}
		} else if ((i -= NUMTEXTCHARS) < NUMSCROLLCHARS) {
			sprintf(buf, "Scroll Bar %s", (i == 3) ? "Moving" :
				(i == 2) ? "Center" : i ? "Bottom" : "Top");
		} else if ((i -= NUMSCROLLCHARS) < NUMMOUSECHARS) {
			sprintf(buf, "Mouse Replacement Character %d", i + 1);
			if (i < 6)
				strcat(buf, " (0xC0 to 0xDF)");
		} else
			strcpy(buf, "Unknown");
		term_write(0, 0, "", 0, color_class screen_border, 1);
		term_write(38 - strlen(buf) / 2, 0, buf, strlen(buf),
			color_class mode_line, 0);
		sprintf(buf, " Use the arrow keys to change this character.");
		SHOW(0, screen_lines - 5, buf);
		sprintf(buf, " Type N or P to set other display characters, "
			"T to try out ");
		SHOW(0, screen_lines - 4, buf);
		sprintf(buf, " these characters temporarily, S to set "
			"these characters permanently, ");
		SHOW(0, screen_lines - 3, buf);
		sprintf(buf, " or C to cancel.  Character was initially "
			"0x%02x, this one is 0x%02x.",
			orig[class], _display_characters[class]);
		SHOW(0, screen_lines - 2, buf);
		sprintf(buf, "%c", disp_char_look(charac));
		term_write(SCRPLACE(charac), buf, 1, color_class mode_line, 0);
		term_position(SCRPLACE(charac));
		do {
			getkey();
		} while (key == MOUSE_MOVE);
		term_write(SCRPLACE(charac), buf, 1, color_class text, 0);
		key = toupper(key);
		if (key == 'C' || key == 'Q' || user_abort) {
			for (i = 0; i < NUMDISPCHARS; i++)
				_display_characters[i] = orig[i];
			say("");
			break;
		} else if (key == 'S' || key == ' ') {
			show_binding("To remember these changes for "
				"future sessions, use %s.", "write-state");
			break;
		} else if (key == 'N') {
			class = (class + 1) % NUMDISPCHARS;
			continue;
		} else if (key == 'P') {
			class = (class + NUMDISPCHARS - 1) % NUMDISPCHARS;
			continue;
		} else if (binding_of(key, root_keys) == (short) help || key == 'h'
							|| key == '?') {
			help_on_command("set-display-characters");
			matrix = 0;
			continue;
		} else if (key == 'T') {
			show_binding("Continue by typing %s", "exit-level");
			recursive_edit();
			matrix = 0;
			continue;
		} else if (IS_MOUSE_DOWN(key)) {
			if (mouse_y < CHR_LINE || mouse_y >= CHR_LINE + 8 * 2
			    || mouse_x < CHR_COL || mouse_x >= CHR_COL + 32 *2)
				continue;
			charac = (mouse_y - CHR_LINE) / 2 * 32;
			charac += (mouse_x - CHR_COL) / 2;
			_display_characters[class] = charac & 0xff;
			continue;
		}
		switch (get_direction()) {
			case BTOP:	charac -= 32; break;
			case BBOTTOM:	charac += 32; break;
			case BLEFT:	charac--; break;
			case BRIGHT:	charac++; break;
			default:	if (IS_TRUE_KEY(key))
						maybe_ding(bell_on_bad_key);
					break;
		}
		charac &= 0xff;
		_display_characters[class] = charac;
	}
	remove_window(cwin);
}

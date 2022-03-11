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

// This file defines the set-color command, which changes Epsilon's
// screen colors.

#include "eel.h"

#define FG(c)		((c) & 15)	/* extract foreground & background */
#define BG(c)		(((c) >> 4) & 7)
#define COLOR_COL	56
#define COLOR_LINE	2
#define SCRPLACE(c)	(COLOR_COL + FG(c)), (COLOR_LINE + BG(c))


when_loading()		/* query user to set colors */
{
	int class, color, i, j, *orig, classes, docbuf, wantwin;
	int swin, ccwin, cwin, infowin, newcolor, newscheme, orig_scheme;
	int *orig_fg, *orig_bg, fg_color, bg_color;
	char buf[100];
	int sbuf, ccbuf, cbuf, infobuf, orig_win = window_handle, win, page;
	char *new, *old;
	jmp_buf this_level;

	if ((has_feature & FEAT_ANYCOLOR) && !(has_feature & FEAT_COLOR_DIALOG)) {
		save_var bufnum = sbuf = tmp_buf();	/* list of color schemes */
		for (i = 1; i <= final_index(); i++)
			if (name_type(i) == NT_COLSCHEME
				  && strcmp(name_name(i), "color-defaults"))
				buf_printf(sbuf, "%s\n", name_name(i));
		point = 0;
		col_search(name_name(selected_color_scheme), 0);
		restore_vars();
		get_choice(sbuf, buf, " Color Classes ", "Select a color class",
				   "", "", "");
		say("");
		buf_delete(sbuf);
		if (!user_abort) {
			i = find_index(buf);
			if (i > 0 && name_type(i) == NT_COLSCHEME)
				selected_color_scheme = i;
			*get_color_scheme_variable() = selected_color_scheme;
		}
		return;
	}
	save_var top_level = &this_level;
	classes = number_of_color_classes();
	orig = (int *) malloc(classes * sizeof(int));
	orig_fg = (int *) malloc(classes * sizeof(int));
	orig_bg = (int *) malloc(classes * sizeof(int));
	orig_scheme = selected_color_scheme;
	class = iter = page = 0;
	for (i = 0; i < classes; i++) {
		orig_fg[i] = get_foreground_color(i, 1);
		orig_bg[i] = get_background_color(i, 1);
		orig[i] = alter_color(i, -1);
	}

	sbuf = tmp_buf();	/* list of color schemes */
	bufnum = sbuf;	/* now highlight current line in buffers */
	add_region(point_spot, point_spot, color_class menu_highlight,
			   REGLINE);

	bufnum = docbuf = tmp_buf();	// read help text for classes into buf
	if (new = lookpath("colclass.txt"))
		file_read(new, FILETYPE_AUTO);
	ccbuf = tmp_buf();	/* list of color classes */
	cbuf = tmp_buf();	/* window with colors */ 
	infobuf = tmp_buf();	/* help buffer with options */ 

	bufnum = ccbuf;
	add_region(point_spot, point_spot, color_class menu_highlight,
			   REGLINE);
	for (i = 0; i < classes; i++)
		bprintf("%s\n", name_color_class(i));
	delete(point - 1, point);

winagain:
	swin = add_popup(4, 1, 20, 10, ALL_BORD(BSINGLE), sbuf);
	window_title(swin, BTOP, TITLECENTER, " Color Schemes ");
	set_menu_look(swin);

	ccwin = add_popup(29, 1, 21, 10, ALL_BORD(BSINGLE), ccbuf);
	display_column = 0;		/* prevent continuation lines */
	window_title(ccwin, BTOP, TITLECENTER, " Color Classes ");
	set_menu_look(ccwin);

	if (!(has_feature & FEAT_ANYCOLOR)) {		// Matrix of color choices.
		cwin = add_popup(55, 1, 18, 10, ALL_BORD(BSINGLE), cbuf);
		window_title(cwin, BTOP, TITLECENTER, " Colors ");
		invisible_window = 1;
		insert('\n');
		if (selectable_colors > 128)
			window_title(cwin, BBOTTOM, TITLERIGHT(1), " More ");
	}

	infowin = add_popup(2, 14, 75, 8, _view_border, infobuf);
	display_column = 0;		/* prevent continuation lines */
	mouse_cursor = &left_pointer;
	text_color = is_gui ? color_class text : color_class menu;
	display_scroll_bar = 0;
	newscheme = 2;
	if (has_feature & FEAT_COLOR_DIALOG) {
		display_dialog_box("SetColorBox", "Set colors",
						   swin, ccwin, infowin, "OK", "Cancel", "Help");
		save_var permit_window_keys = PERMIT_SCROLL_KEY;
		save_var return_raw_buttons = 1;
		wantwin = ccwin;
	}

	if (setjmp(top_level))	/* come here if subcommand's aborted */
		;
	for (;;) {
		color = alter_color(class, -1);
		fg_color = get_foreground_color(class, 0);
		bg_color = get_background_color(class, 0);

		if ((color >= 128) != page && !newscheme)
			newscheme = 1;
		page = (color >= 128);
		if (newscheme) {
			if (!(has_feature & FEAT_ANYCOLOR)) {	// Sample window has 2 pages.
				window_handle = cwin;
				point = page;
			}
			window_handle = swin;
			if (newscheme == 2) {
				buf_zap(sbuf);
				for (i = 1; i <= final_index(); i++)
					if (name_type(i) == NT_COLSCHEME
						  && strcmp(name_name(i), "color-defaults"))
						bprintf("%s\n", name_name(i));
				delete(size() - 1, size());	/* no final \n */
			}
			point = 0;
			col_search(name_name(selected_color_scheme), 0);
			if (!(has_feature & FEAT_ANYCOLOR)) {
				j = page ? 128 : 0;
				for (i = 0; i < 128; i++, j++)
					term_write_attr(SCRPLACE(i), '+', j);
			}
		}
		window_handle = ccwin;
		point = 0;
		sprintf(buf, "^%s$", name_color_class(class));
		re_search(1, buf);
		to_begin_line();
		buf_zap(infobuf);
		window_handle = infowin;
		if (!(has_feature & FEAT_COLOR_DIALOG)) {
			bprintf("Type F or B to change the color scheme, D to "
					"define a new color scheme.\n");
			bprintf("Or use the arrow keys to change the "
					"%s color class.\n", name_color_class(class));
		} else
			bprintf("Sample text using the %s color class:\n",
					name_color_class(class));
		i = point;
		bufnum = docbuf;
		point = 0;
		sprintf(buf, "^%s\t+", name_color_class(class));
		if (re_search(1, buf))
			buf_xfer(infobuf, point, give_end_line());
		else
			buf_printf(infobuf, "This is sample text.");
		bufnum = infobuf;
		j = point + 1;
		if (!(has_feature & FEAT_COLOR_DIALOG)) {
			bprintf("\nType N or P to set other color classes, "
					"T to try out\n");
			bprintf("these colors temporarily, S to set "
					"these colors permanently,\n");
			bprintf("or C to cancel.  Color was initially "
					"0x%02x, this color is 0x%02x.", orig[class], color);
		}
		set_character_color(i, j, class);
		point = 0;
		if (has_feature & FEAT_ANYCOLOR) {
			window_handle = wantwin;
			maybe_refresh();
			getkey();
			wantwin = window_handle;
		} else {
			window_handle = cwin;
			do {
				maybe_refresh();
				term_write_attr(SCRPLACE(color), 'C', color);
				full_getkey("Your choice: ", 0);
				term_write_attr(SCRPLACE(color), '+', color);
			} while (!IS_TRUE_KEY(key) && !IS_MOUSE_DOWN(key));
		}
		key = toupper(key);
		newcolor = -100;	// Assume it's an invalid key.
		newscheme = 0;
		if (binding_of(key, reg_tab) == (short) next_page
			  || binding_of(key, reg_tab) == (short) previous_page) {
			do_command(binding_of(key, reg_tab));
			newcolor = -99;		// Mark as a valid key.
		}
		if (has_feature & FEAT_COLOR_DIALOG) {	// Scrolling might have changed these.
			window_handle = ccwin;
			class = lines_between(0, point);

			window_handle = swin;
			grab_full_line(bufnum, buf);
			i = find_index(buf);
			if (i > 0 && name_type(i) == NT_COLSCHEME)
				selected_color_scheme = i;
		}
		if (key_is_button == 4) {
			if (fg_color & ETRANSPARENT)
				fg_color = get_foreground_color(color_class text);
			fg_color = comm_dlg_color(fg_color, "Foreground color");
			if (fg_color != -1)
				set_color_pair(class, fg_color, bg_color);
		} else if (key_is_button == 5) {
			if (bg_color & ETRANSPARENT)
				bg_color = get_background_color(color_class text);
			bg_color = comm_dlg_color(bg_color, "Background color");
			if (bg_color != -1)
				set_color_pair(class, fg_color, bg_color);
		} else if (key == 'C' || key == 'Q' || key == ESC || user_abort
				   || key_is_button == 2) {
			selected_color_scheme = orig_scheme;
			for (i = 0; i < classes; i++)
				set_color_pair(i, orig_fg[i], orig_bg[i]);
			say("");
			break;
		} else if (key == 'S' || key == ' ' || IS_ENTER_KEY(key)
				   || key_is_button == 1) {
			show_binding("To remember these colors for "
						 "future sessions, use %s.", "write-state");
			break;
		} else if (IS_MOUSE_DOWN(key)) {
			win = window_at_coords(mouse_y, mouse_x, mouse_screen);
			if (!is_window(win))
				continue;
			window_handle = win;
			get_text_area(win);
			if (win == cwin) {
				if (bar_on_border()) {
					i = scroll_bar_code();
					if ((i ? (i > 0) : !page) != point)
						newcolor = color ^ 128;
				} else {
					newcolor = (mouse_y - COLOR_LINE) * 16;
					newcolor += (mouse_x - COLOR_COL);
					if (page)
						newcolor += 128;
				}
			} else if (in_text_area(mouse_x, mouse_y))
				point_to_pos(mouse_x, mouse_y, mouse_screen);
			else if (display_scroll_bar && bar_on_border())
				mouse_scroll_bar();
			else
				continue;
			if (win == ccwin)
				class = lines_between(0, point);
			else if (win == swin)
				newscheme = 1;
			else if (win == infowin && isupper(curchar())
					 && character(point - 1) == ' '
					 && character(point + 1) == ' ')
				ungot_key = curchar();
			if (win != infowin)
				wantwin = win;
		} else if ((has_feature & FEAT_COLOR_DIALOG) && key == '\t') {
			next_dialog_item();
			wantwin = window_handle;
			continue;
		} else if ((has_feature & FEAT_COLOR_DIALOG) && key == NUMSHIFT(GREYTAB)) {
			prev_dialog_item();
			wantwin = window_handle;
			continue;
		} else if ((has_feature & FEAT_COLOR_DIALOG) && key == GETFOCUS) {
			win = window_at_coords(mouse_y, mouse_x, mouse_screen);
			if (!is_window(win) || win == infowin)
				continue;
			wantwin = win;
		}
		if (!(has_feature & FEAT_ANYCOLOR))
			switch (get_direction()) {
				case BTOP:		newcolor = color + 256 - 16; break;
				case BBOTTOM:	newcolor = color + 16; break;
				case BLEFT:		newcolor = color + 256 - 1; break;
				case BRIGHT:	newcolor = color + 1; break;
			}
		else
			switch (get_direction()) {
				case BTOP: case BLEFT:
					key = (win == ccwin) ? 'P' : 'B'; break;
				case BBOTTOM: case BRIGHT:
					key = (win == ccwin) ? 'N' : 'F'; break;
			}
		if ((has_feature & FEAT_COLOR_DIALOG) && key == 'N' && win == swin)
			key = 'F';
		if ((has_feature & FEAT_COLOR_DIALOG) && key == 'P' && win == swin)
			key = 'B';
		switch (key) {
			case 'N': class++; break;
			case 'P': class--; break;
			case 'T':
				show_binding("Continue changing colors "
					"by typing %s", "exit-level");
				remove_window(swin);
				remove_window(ccwin);
				remove_window(cwin);
				remove_window(infowin);
				recursive_edit();
				goto winagain;
				break;
			case 'F':
				wantwin = window_handle = swin;
				if (!nl_forward())
					point = 0;
				newscheme = 1;
				break;
			case 'B':
				wantwin = window_handle = swin;
				if (!nl_reverse())
					point = size();
				newscheme = 1;
				break;
			case 'D':
				wantwin = swin;
				maybe_refresh();
				get_strpopup(buf, "New scheme name: ", "", "set-color");
				if (*buf) {
					new_variable(buf, NT_COLSCHEME, 0, 0);
					new = varptr(find_index(buf));
					old = varptr(selected_color_scheme);
					for (i = 0; i < ptrlen(old); i++)
						*new++ = *old++;
					newscheme = 2;
				}
				break;
			default:
				if (binding_of(key, root_keys) == (short) help
					|| key == 'h' || key == '?'
					|| key_is_button == 3) {
					if (!(has_feature & FEAT_COLOR_DIALOG))
						say("Press <Space> to continue.");
					help_on_command("set-color");
					if (!(has_feature & FEAT_COLOR_DIALOG))
						newscheme = 1;
				} else if (IS_TRUE_KEY(key) && newcolor == -100) {
					maybe_ding(bell_on_bad_key);
					newscheme = 1;
				}
				break;
		}
		if (newcolor > -99)	/* did it change? */
			alter_color(class, newcolor % selectable_colors);
		else if (newscheme) {
			window_handle = swin;
			grab_full_line(bufnum, buf);
			i = find_index(buf);
			if (i > 0 && name_type(i) == NT_COLSCHEME)
				selected_color_scheme = i;
		} else
			class = (class + classes) % classes;
	}
	remove_window(swin);
	remove_window(ccwin);
	if (!(has_feature & FEAT_ANYCOLOR))
		remove_window(cwin);
	remove_window(infowin);
	buf_delete(ccbuf);
	buf_delete(cbuf);
	buf_delete(infobuf);
	if (is_window(orig_win))
		window_handle = orig_win;
	buf_delete(sbuf);
	full_redraw = 1;
	*get_color_scheme_variable() = selected_color_scheme;
	free(orig);
	free(orig_fg);
	free(orig_bg);
}

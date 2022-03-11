/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1989, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

#include "eel.h"

save_screen(p)		/* save current window info in p */
struct screen_info *p;	/* on first call with p, p->wins must be 0 */
{
	int i, oldroom = 0, nwins = number_of_windows() - number_of_popups();

	p->lines = screen_lines, p->cols = screen_cols;
	p->cur_window = window_number;
	p->echo_line = echo_line;
	p->avoid_top = avoid_top_lines;
	p->avoid_bottom = avoid_bottom_lines;
	p->permanent_menu = permanent_menu;
	if (p->wins)
		oldroom = ptrlen(p->wins) / sizeof(struct window_info);
	if (oldroom < nwins) {
		if (p->wins)
			free(p->wins);
		p->wins = (struct window_info *) malloc(nwins
				* sizeof(struct window_info));
	}
	for (i = 0; i < nwins; i++)
		get_window_info(i, p->wins + i);
	p->num = i;
}

restore_screen(p)	/* restore windows from data in p */
struct screen_info *p;
{
	int i, origbuf, origpt;

	bufnum = origbuf = window_bufnum;
	origpt = point;
//	if (screen_lines != p->lines || screen_cols != p->cols)
//		error("Screen is in wrong mode for restore.");
	for (i = 0; i < p->num; i++)
		window_create(!i, p->wins + i);
	echo_line = p->echo_line;
	select_low_window(p->cur_window, p->avoid_top, p->avoid_bottom,
			  p->lines, p->cols);
	restore_menu(p->permanent_menu);
	if (bufnum == origbuf)
		point = origpt;
}

command zoom_window() on cx_tab['z']
{
	if (number_of_windows() - number_of_popups() > 1) {
		save_screen(&zoom_info);
		one_window();
		display_column = display_column.default;
	} else {
		if (zoom_info.num < 2)
			error("No windows to restore.");
		restore_screen(&zoom_info);
	}
}

get_window_info(win, p)
struct window_info *p;
{
	low_window_info(win, p);
	save_var window_handle = win;
	p->dcolumn = display_column;
	p->prevbuf = _prev_buffer;
	p->colscheme = window_color_scheme;
}

window_create(first, p)
struct window_info *p;
{
	low_window_create(first, p);
	display_column = p->dcolumn;
	_prev_buffer = p->prevbuf;
	window_color_scheme = p->colscheme;
}

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

// This file contains the set-display-look command.


#include "eel.h"

/* These commands alter the look of the windows on the screen. */

#define LOOK_PREFIX	"display-look-"

char *look_match(s, flags)	// give names matching display-look-?
	char *s;
{
	int i;
	char buf[80];

	sprintf(buf, LOOK_PREFIX "%s", s);
	if (flags & EXACTONLY)
		return (name_type(find_index(buf))) && (flags & STARTMATCH)
				? s : 0;
	for (; i = name_match(buf, flags & STARTMATCH); flags &= ~STARTMATCH)
		if (name_type(i))
			return name_name(i) + sizeof(LOOK_PREFIX) - 1;
	return 0;
}

command set_display_look()
{
	char res[FNAMELEN], cmd[FNAMELEN];

	ungot_key = '?';
	comp_read(res, "Select display look: ", look_match, MUST_MATCH, "");
	sprintf(cmd, LOOK_PREFIX "%s", res);
	try_calling(cmd);
	say("Display look \"%s\" selected.", res);
}

display_look_brief()	/* set up display like Brief editor */
{
	set_menu_bar(0);
	get_standard_color_scheme();
	tiled_border = LR_BORD(BSINGLE) + TB_BORD(BDOUBLE);
	border_right = border_left = 1;
	border_top = border_bottom = border_inside = 1;
	tiled_scroll_bar = 1;
	mode_line_at_top = 1;
	mode_line_position = TITLECENTER;
	mode_line_shows_mode = 0;
	strcpy(mode_end, "");
	one_window();		/* keep it simple: start with one window */
	window_title(window_number, BBOTTOM, TITLECENTER, "");
	strcpy(show_when_idle, " Line: %-4l Col: %-4C %2h:%02n %a");
	show_when_idle_column = -32;	// 32 chars from right edge
	full_redraw = 1;
}

display_look_epsilon()	/* return to our normal display */
{
	set_menu_bar(0);
	get_standard_color_scheme();
	tiled_border = ALL_BORD(BSINGLE);
	border_right = border_left = 0;
	border_top = border_bottom = 0;
	tiled_scroll_bar = 0;
	mode_line_at_top = 0;
	mode_line_position = TITLELEFT(2);
	mode_line_shows_mode = 1;
	strcpy(mode_end, " %d%p %s");
	one_window();		/* keep it simple: start with one window */
	window_title(window_number, BTOP, TITLECENTER, "");
	*show_when_idle = 0;
	full_redraw = 1;
}

display_look_dos_editor()	/* set up screen like dos editor (QBasic) */
{
	set_menu_bar(1);
	if (!monochrome)
		selected_color_scheme = find_index("dos-edit");
	tiled_border = LR_BORD(BSINGLE) + TB_BORD(BSINGLE);
	border_right = border_left = 1;
	border_top = border_bottom = border_inside = 1;
	tiled_scroll_bar = 1;
	mode_line_at_top = 1;
	mode_line_position = TITLECENTER;
	mode_line_shows_mode = 0;
	strcpy(mode_end, "");
	one_window();		/* keep it simple: start with one window */
	window_title(window_number, BBOTTOM, TITLECENTER, "");
	strcpy(show_when_idle, "%-05l:%-03C ");
	show_when_idle_column = -12;
	full_redraw = 1;
}

display_look_borlandc()	/* set up screen like Borland's C 3.1 IDE */
{
	set_menu_bar(1);
	if (!monochrome)
		selected_color_scheme = find_index("borlandc");
	tiled_border = LR_BORD(BDOUBLE) + TB_BORD(BDOUBLE);
	border_right = border_left = 1;
	border_top = border_bottom = border_inside = 1;
	tiled_scroll_bar = 1;
	mode_line_at_top = 1;
	mode_line_position = TITLECENTER;
	mode_line_shows_mode = 0;
	strcpy(mode_end, "");
	one_window();		/* keep it simple: start with one window */
	window_title(window_number, BBOTTOM, TITLECENTER, "");
	strcpy(show_when_idle, "%-05l:%-03C ");
	show_when_idle_column = -12;
	full_redraw = 1;
}

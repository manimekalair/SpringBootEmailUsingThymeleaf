/************************************************** -*- tab-width:4 -*- *
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

// definitions for displaying the menu bar

user short menu_bar_flashes = 2; // # of times to flash selected menu bar item
user char auto_menu_bar = 1; // want menu bar to appear when mouse is at top?
user char menu_bindings = 1;	// want bindings on menu bar?
user char menu_stays_after_click = 1; // does clicking on menu bar put up menu?
zeroed int menu_window;		// window handle of permanent menu bar
spot menu_line_spot;	// where should above highlight line be?
#define MENU_BNAME	("-menu")
#define MENU_BNUM	(name_to_bufnum(MENU_BNAME))
user char menu_file[80] = "epsilon.mnu";
user char gui_menu_file[80] = "gui.mnu";
zeroed char need_rebuild_menu;	// reread gui.mnu on next screen refresh

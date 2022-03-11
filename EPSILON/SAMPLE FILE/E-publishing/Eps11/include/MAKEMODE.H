/************************************************** -*- tab-width:4 -*- *
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

char _makefile_mode_name[] = "Makefile";
keytable makefile_tab;			/* key table for makefile mode */
user char compile_makefile_cmd[128] = "nmake /f \"%r\""; // Compile cmd line
user char compile_makefile_cmd_unix[128] = "make -f %r"; // Compile cmd line

color_class makefile_comment;
color_class makefile_preproc;
color_class makefile_macro;
color_class makefile_target;

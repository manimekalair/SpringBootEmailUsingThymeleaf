/************************************************** -*- tab-width:4 -*- *
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1996, 1999 Lugaru Software Ltd.  All rights reserved.  *
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

char _gams_mode_name[] = "GAMS";
user char compile_gams_cmd[128] = "gams \"%r\""; // cmd to compile this file
user char gams_auto_show_delim_chars[20] = "[()]";
user char auto_show_gams_delimiters = 1;
user char gams_files = 0;		// Point additional extensions to GAMS.

color_class gams_string;
color_class gams_comment;
color_class gams_control;
color_class gams_keyword;
color_class gams_variable;


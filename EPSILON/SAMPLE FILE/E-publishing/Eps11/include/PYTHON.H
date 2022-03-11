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

char _python_mode_name[] = "Python";
keytable python_tab;			/* key table for python mode */
user char compile_python_cmd[128] = "python \"%r\""; // execute this file
user char python_indent = 4;

user char auto_show_python_delimiters = 1;
user char python_auto_show_delim_chars[20] = "{([])}";

color_class python_comment;
color_class python_string;
color_class python_keyword;
color_class python_identifier;

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

char _vbasic_mode_name[] = "VBasic";
keytable vbasic_tab;			/* key table for vbasic mode */
//user char compile_vbasic_cmd[128] = "ml \"%r\""; // compile this file
user char auto_show_vbasic_delimiters = 1;
user char vbasic_auto_show_delim_chars[20] = "{([])}";
user buffer short vbasic_indent = 3;	/* indent by this amt; 0 means use tab size */
user char vbasic_indent_subroutines = 1;

color_class vbasic_comment;
color_class vbasic_string;
color_class vbasic_keyword;
color_class vbasic_function;
color_class vbasic_identifier;

// Values for sublanguage_code:
#define SUBLANG_VBSCRIPT	1

int color_vbasic_range();

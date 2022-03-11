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

char _postscript_mode_name[] = "PostScript";
user char auto_show_postscript_delimiters = 1;
user char postscript_auto_show_delim_chars[20] = "{[()]}";
keytable pscript_tab;

char _conf_mode_name[] = "Conf";

color_class postscript_comment;
color_class postscript_text;
color_class postscript_literal;

// Mode for .conf files.
color_class conf_comment;
color_class conf_attribute;
color_class conf_value;

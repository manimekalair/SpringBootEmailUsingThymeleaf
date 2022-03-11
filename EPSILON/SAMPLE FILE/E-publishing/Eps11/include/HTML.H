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

char _html_mode_name[] = "Html";
keytable html_tab;			/* key table for html mode */

#define HTML_NAME		"[a-z0-9_]+"
#define HTML_VALUE		"('[^']*'|\"[^\"]*\"|[^\"' <>\t\n]+)"
#define HTML_EQUALS		"[ \t\n]*=[ \t\n]*"
#define HTML_ATTRIBUTE	HTML_NAME "(" HTML_EQUALS HTML_VALUE ")?"

user char html_auto_show_delim_chars[20] = "<>";
user char html_auto_indent = 6;
user int color_html_look_back = 50000;

// Codes for embedded languages (or 0 for plain coloring).
#define HT_JSCRIPT	1
#define HT_VBSCRIPT	2

user char html_javascript_coloring = HT_JSCRIPT;	// <Script lang=jscript>.
user char html_vbscript_coloring = HT_VBSCRIPT;	// <Script lang=vbscript>.
user char html_other_coloring = HT_JSCRIPT;	// <Script> for unknown language.
user char html_asp_coloring = HT_JSCRIPT;		// <% %> sequences
user char html_php_coloring = HT_JSCRIPT;		// <? ?> sequences

color_class html_text;
color_class html_tag;
color_class html_attribute;
color_class html_value;
color_class html_comment;
color_class html_namespace;
color_class html_entity;
color_class html_punctuation;

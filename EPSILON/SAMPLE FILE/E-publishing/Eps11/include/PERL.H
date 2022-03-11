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

color_class perl_comment;
color_class perl_string;
color_class perl_keyword;
color_class perl_function;
color_class perl_variable;
color_class perl_constant;

char _perl_mode_name[] = "Perl";
char _shell_mode_name[] = "Shell";
user char compile_perl_cmd[128] = "perl \"%r\""; // Run perl on this file.
user int perl_tab_override = 8;	// Perl-specific setting for tab width.
user char auto_show_perl_delimiters = 1;
user char perl_auto_show_delim_chars[20] = "{[()]}";
char tag_pattern_perl[] = "[a-zA-Z0-9_]+(('|::)[a-zA-Z0-9_]+)?";
user int reindent_after_perl_yank = 0;
	// Reindent blocks smaller than this after yanking in Perl mode.

user char auto_show_shell_delimiters = 1;
user char shell_auto_show_delim_chars[20] = "{[()]}";
user int shell_tab_override = 8;	// Shell-specific setting for tab width.

user char perl_closeback = 1;		/* select default Perl indenting style */
user char perl_topindent = 1;
user buffer short perl_indent = 0;	/* indent by this amt; 0 means use tab size */
user short perl_label_indent = 0;	/* indent labels to this column */
user short perl_contin_offset = 0;	/* alter normal indentation of contin lines */
user char perl_align_contin_lines = 48; // line up contin lines up to this col
user short perl_brace_offset = 0;	// move braces this much from usual position
user int perl_top_braces = 0;	// indent for outer {}'s in func
user int perl_top_contin = 3;	// indent for contin lines (decls) outside func
user int perl_top_struct = 8;	// indent for body of outer struct/class

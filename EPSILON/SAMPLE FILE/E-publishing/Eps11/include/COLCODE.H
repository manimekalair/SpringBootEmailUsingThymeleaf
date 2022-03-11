/************************************************** -*- tab-width:4 -*- *
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1997, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

// general code coloring variables

user buffer char want_code_coloring = 1; // color this buffer?
user int color_whole_buffer = 0;	// color smaller buffers all at once
user int color_look_back = 0;	// set to restrict searching for comments
user buffer int idle_coloring_delay = 100; // .01secs to wait before coloring, or -1
zeroed TIMER idle_color_time;	// don't start coloring immediately
buffer int idle_coloring_size = 1000;	// # of bytes to background-color at a time

buffer int (*when_displaying)();	// called by epsilon during display
buffer int (*recolor_range)();		// how to color a part of this buffer
buffer int (*recolor_from_here)();	// how to find a good starting pos

// Some standard recolor_from_here functions for coloring from
// the start of the current line, or always coloring from the top.
int recolor_by_lines();
int recolor_from_top();

user char auto_show_c_delimiters = 1;
user char auto_show_html_delimiters = 1;
user char auto_show_tex_delimiters = 1;

// Stuff for auto-show-??-delimiters.
#define SHOW_MATCHING_REGION	100		// Region handle for our 2 regions.
buffer spot highlight_area_start[2];
buffer spot highlight_area_end[2];
// Convert from old names.
#define show_matching_start_spot	highlight_area_start[0]
#define show_matching_start_end_spot	highlight_area_end[0]
#define show_matching_end_spot		highlight_area_start[1]
#define show_matching_end_end_spot	highlight_area_end[1]
zeroed buffer char retain_highlight_area;	// Don't drop when switching windows.
buffer int (*mode_auto_show_delimiter)();	// Mode-specific auto-show logic.
buffer char *auto_show_matching_characters; // Chars that cause auto-show.
// Put left-only characters like "[" in the first half of the
// string, right-only characters like "]" in the second half -- Chars
// that can be on either side like " should appear twice.
color_class show_matching_start; /* The colors for auto-show-delimiter. */
color_class show_matching_end;
user char auto_show_adjacent_delimiter = 3;	// Highlight ) before point too?

buffer char coloring_flags;
#define COLOR_DO_COLORING	1	/* should we do coloring for this buffer? */
#define COLOR_IN_PROGRESS	2	/* are we already coloring the buffer? (error) */
#define COLOR_MINIMAL		4	/* remembered value of minimal_coloring */
#define COLOR_INVALIDATE_FORWARD	8	/* buf change discards coloring after */
#define COLOR_INVALIDATE_BACKWARD	16	/* buf change discards coloring before */
#define COLOR_INVALIDATE_RESETS		32	/* buf change sets color to -1 too */
#define COLOR_RETAIN_NARROWING		64	/* keep any narrowing when coloring */

// variables for coloring C/C++/EEL code

	/* bits for c_extra_keywords; what to color, besides std C keywords */
#define CPP_KEYWORDS	1	/* color C++ keywords too */
#define EEL_KEYWORDS	2	/* color EEL-specific keywords too */
#define JAVA_KEYWORDS	4	/* color Java-specific keywords too */
#define IDL_KEYWORDS	8	/* color IDL-specific keywords too */
#define CSHARP_KEYWORDS	16	/* color C#-specific keywords too */
buffer char c_extra_keywords = CPP_KEYWORDS | EEL_KEYWORDS;
user char minimal_coloring = 0; // if 1, skip idents, kwds, nums; faster

// colors used for syntax highlighting in C mode
color_class c_comment;		// a comment (like this one)
color_class c_preprocessor;	// a preprocessor directive
color_class c_keyword;		// a C, C++, or EEL keyword like "else"
color_class c_function;		// a function being called or declared
color_class c_identifier;	// some other identifier
color_class c_string;		// a string literal
color_class c_charconst;	// a character constant
color_class c_number;		// a numeric constant like 3.5 or 0x100
color_class c_punctuation;	// anything else

int color_c_range();
int color_c_from_here();

// colors used for syntax highlighting in ASM mode
color_class asm_keyword;
color_class asm_register;
color_class asm_identifier;

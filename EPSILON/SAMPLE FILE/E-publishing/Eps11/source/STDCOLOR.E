/*
This file contains Epsilon's standard color definitions.
Copyright 1995, 2001 Lugaru Software, Ltd.  All Rights Reserved.
*/

#include "eel.h"
#include "colcode.h"
#include "html.h"

// First declare defaults for various color classes, independent of any
// particular color scheme.

color_class text white on black;
color_class highlight white on dark_green;
color_class echo_area yellow on black;
color_class mode_line cyan;
color_class horiz_border cyan;
color_class vert_border = color_class horiz_border;

color_class popup_title dark_red on grey;
color_class popup_border dark_red on grey;

color_class after_exiting grey on black;
color_class debug_text dark_blue on grey;
color_class debug_highlight grey on dark_blue;
color_class default dark_red on grey;

color_class overlap_even dark_cyan on dark_blue;
color_class overlap_odd = color_class default;	// No longer used.
color_class screen_border = color_class text;
color_class screen_decoration grey;

color_class viewed_text dark_blue on grey;
color_class viewed_border dark_red on grey;
color_class viewed_link green on grey;
color_class selected_link red on grey;
color_class viewed_gui_text = color_class text;
color_class dialog_gui_text = color_class text;

color_class menu dark_blue on grey;
color_class menu_highlight dark_blue on dark_cyan;
color_class menu_bar black on dark_cyan;
color_class menu_bar_highlight dark_blue on grey;
color_class submenu black on dark_cyan;
color_class submenu_highlight dark_blue on grey;

color_class c_comment white;
color_class c_preprocessor grey;
color_class c_keyword green;
color_class c_function yellow;
color_class c_identifier black;
color_class c_string cyan;
color_class c_charconst = color_class c_string;
color_class c_number = color_class text;
color_class c_punctuation = color_class text;

color_class ident_completion white on dark_cyan;
color_class show_matching_start black on green;
color_class show_matching_end black on cyan;

color_class html_text = color_class c_function;
color_class html_tag = color_class c_function;
color_class html_attribute = color_class c_string;
color_class html_value = color_class c_preprocessor;
color_class html_comment = color_class c_comment;
color_class html_namespace = color_class c_preprocessor;
color_class html_entity = color_class c_comment;
color_class html_punctuation = color_class html_attribute;

color_class dired_normal = color_class text;
color_class dired_file_name = color_class c_function;
color_class dired_dir_name = color_class c_comment;
color_class dired_header = color_class c_string;
color_class dired_deleted red;
color_class dired_moved = color_class c_preprocessor;
color_class dired_copied = color_class c_comment;

color_class grep_text = color_class text;
color_class grep_match = color_class dired_copied;
color_class grep_filename = color_class dired_file_name;
color_class grep_header = color_class c_string;

color_class diff_added black on yellow;
color_class diff_removed black on light_red;

color_class process_output = color_class text;
color_class process_input = color_class c_function;
color_class process_prompt = color_class c_comment;

color_class tex_text = color_class text;
color_class tex_comment = color_class c_comment;
color_class tex_curly_brace = color_class c_function;
color_class tex_square_bracket = color_class c_string;
color_class tex_math = color_class c_string;
color_class tex_display_math = color_class tex_math;
color_class tex_literal = color_class html_attribute;
color_class tex_command = color_class c_preprocessor;
color_class tex_begin_end = color_class c_function;
color_class tex_section = ocher;

color_class perl_comment = color_class c_comment;
color_class perl_string = color_class c_string;
color_class perl_keyword = color_class c_preprocessor;
color_class perl_function = color_class c_punctuation;
color_class perl_variable = color_class c_function;
color_class perl_constant = color_class html_tag;

color_class asm_keyword = color_class html_attribute;
color_class asm_register = color_class c_function;
color_class asm_identifier = color_class c_punctuation;

color_class makefile_comment = color_class html_comment;
color_class makefile_preproc = color_class html_value;
color_class makefile_macro = color_class html_tag;
color_class makefile_target = color_class c_string;

color_class inifile_comment = color_class html_comment;
color_class inifile_section = color_class html_text;
color_class inifile_definition = color_class html_attribute;

color_class man_underlined = color_class inifile_section;
color_class man_bold = color_class inifile_comment;

color_class conf_comment = color_class html_comment;
color_class conf_attribute = color_class html_attribute;
color_class conf_value = color_class html_value;

color_class gams_string = color_class html_text;
color_class gams_comment = color_class c_comment;
color_class gams_control = color_class c_preprocessor;
color_class gams_keyword = color_class c_string;
color_class gams_variable = color_class c_identifier;

color_class postscript_comment = color_class html_comment;
color_class postscript_text = color_class html_text;
color_class postscript_literal = color_class html_tag;

color_class pull_highlight = color_class dired_moved;

color_class vbasic_comment = color_class c_comment;
color_class vbasic_string = color_class c_string;
color_class vbasic_keyword = color_class c_function;
color_class vbasic_function = color_class c_keyword;
color_class vbasic_identifier = color_class c_identifier;

color_class python_comment = color_class perl_comment;
color_class python_string = color_class perl_string;
color_class python_keyword = color_class perl_variable;
color_class python_identifier = color_class text;

color_class hex_address = color_class c_string;
color_class hex_ascii = color_class c_comment;
color_class hex_change = color_class diff_added;

// Now provide specific colors for each scheme.

color_scheme "standard-gui" {
	color_class text black on white;
	color_class highlight white on dark_blue;
	color_class echo_area red;
	color_class mode_line dark_blue;
	color_class horiz_border dark_grey;
	color_class popup_title black on light_yellow;
	color_class popup_border = color_class popup_title;
	color_class after_exiting black;
	color_class debug_text blue on yellow;
	color_class debug_highlight white on blue;
	color_class default medium_red on yellow;
	color_class overlap_even black on yellow;
	color_class viewed_text blue on light_yellow;
	color_class viewed_border = color_class popup_border;
	color_class viewed_link dark_green on light_yellow;
	color_class selected_link magenta on black;
	color_class menu black on light_yellow;
	color_class menu_highlight black on cyan;
	color_class menu_bar = color_class menu_highlight;
	color_class menu_bar_highlight blue on yellow;
	color_class submenu = color_class menu_highlight;
	color_class submenu_highlight = color_class menu_bar_highlight;
	color_class c_comment dark_green;
	color_class c_preprocessor dark_grey;
	color_class c_keyword black;
	color_class c_function blue;
	color_class c_string medium_red;
	color_class ident_completion black on MAKE_RGB(192, 224, 192);
	color_class html_tag bluish_purple;
	color_class html_attribute = color_class text;
	color_class dired_header = color_class c_comment;
	color_class dired_deleted black on light_red;
	color_class dired_moved = black on light_green;
	color_class dired_copied = black on light_blue;
	color_class grep_filename = color_class c_preprocessor;
	color_class show_matching_start = black on light_green;
	color_class show_matching_end = black on light_blue;
	color_class tex_literal = color_class html_tag;
	color_class perl_function = medium_cyan;
	color_class perl_constant = color_class html_tag;
	color_class pull_highlight = black on cyan;
};

color_scheme "visual-c" {
	color_class text black on white;
	color_class highlight white on black;
	color_class echo_area red;
	color_class mode_line dark_blue;
	color_class horiz_border dark_grey;
	color_class popup_title medium_red on yellow;
	color_class popup_border medium_red on yellow;
	color_class after_exiting black;
	color_class debug_text blue on yellow;
	color_class debug_highlight white on blue;
	color_class default medium_red on yellow;
	color_class overlap_even black on yellow;
	color_class viewed_text blue;
	color_class viewed_border medium_red on yellow;
	color_class viewed_link dark_green;
	color_class selected_link magenta on black;
	color_class menu black;
	color_class menu_highlight black on cyan;
	color_class menu_bar black on cyan;
	color_class menu_bar_highlight blue on yellow;
	color_class submenu black on cyan;
	color_class submenu_highlight blue on yellow;
	color_class c_comment dark_green;
	color_class c_preprocessor blue;
	color_class c_keyword blue;
	color_class c_function black;
	color_class c_string black;
	color_class ident_completion white on grey;
	color_class html_text = color_class c_keyword;
	color_class html_tag dark_magenta;
	color_class html_attribute = color_class text;
	color_class html_value dark_grey;
	color_class dired_file_name = color_class c_keyword;
	color_class dired_header = color_class c_comment;
	color_class process_input = color_class c_keyword;
	color_class show_matching_start = black on light_green;
	color_class show_matching_end = black on light_blue;
	color_class tex_curly_brace = color_class html_text;
	color_class tex_square_bracket = color_class html_tag;
	color_class tex_math = color_class html_value;
	color_class tex_command = color_class html_value;
	color_class tex_begin_end = color_class html_tag;
	color_class makefile_target = color_class html_text;
};

color_scheme "xterm-color" {
	color_class text black on grey;
	color_class highlight white on dark_blue;
	color_class echo_area red;
	color_class mode_line dark_blue;
	color_class horiz_border dark_grey;
	color_class popup_title white on black;
	color_class popup_border = color_class popup_title;
	color_class after_exiting black;
	color_class debug_text blue on brown;
	color_class debug_highlight = color_class highlight;
	color_class default dark_red on brown;
	color_class overlap_even black on brown;
	color_class viewed_text dark_blue;
	color_class viewed_border = color_class popup_border;
	color_class viewed_link blue;
	color_class selected_link cyan on dark_blue;
	color_class menu black;
	color_class menu_highlight black on dark_cyan;
	color_class menu_bar = color_class menu_highlight;
	color_class menu_bar_highlight blue on brown;
	color_class submenu = color_class menu_highlight;
	color_class submenu_highlight = color_class menu_bar_highlight;
	color_class c_comment dark_grey;
	color_class c_preprocessor dark_blue;
	color_class c_keyword black;
	color_class c_function blue;
	color_class c_string medium_red;
	color_class ident_completion black on dark_cyan;
	color_class html_tag = color_class c_preprocessor;
	color_class html_attribute = color_class text;
	color_class dired_file_name blue;
	color_class dired_dir_name dark_grey;
	color_class dired_header dark_grey;
	color_class dired_deleted white on dark_red;
	color_class dired_moved = white on dark_green;
	color_class dired_copied = white on dark_cyan;
	color_class grep_filename = color_class c_preprocessor;
	color_class diff_added dark_grey on brown;
	color_class diff_removed white on dark_red;
	color_class show_matching_start black on dark_green;
	color_class show_matching_end = black on dark_cyan;
	color_class tex_literal blue;
	color_class tex_section magenta;
	color_class asm_keyword dark_blue;
	color_class asm_register dark_grey;
	color_class asm_identifier blue;
};

color_scheme "other-grey" {
	color_class text black on light_grey;
	color_class highlight white on dark_blue;
	color_class echo_area blue;
	color_class mode_line dark_red;
	color_class horiz_border dark_red;
	color_class popup_title dark_red on yellow;
	color_class popup_border dark_red on yellow;
	color_class after_exiting white;
	color_class debug_text blue on yellow;
	color_class debug_highlight white on dark_blue;
	color_class default dark_red on yellow;
	color_class overlap_even dark_red on dark_blue;
	color_class viewed_text blue;
	color_class viewed_border dark_red;
	color_class viewed_link dark_green;
	color_class selected_link magenta on black;
	color_class menu black;
	color_class menu_highlight white on dark_blue;
	color_class menu_bar black on cyan;
	color_class menu_bar_highlight blue on yellow;
	color_class submenu black on cyan;
	color_class submenu_highlight blue on yellow;
	color_class c_comment dark_cyan;
	color_class c_preprocessor dark_blue;
	color_class c_keyword black;
	color_class c_function blue;
	color_class c_string dark_red;
	color_class html_tag = color_class text;
	color_class html_value dark_blue;
	color_class html_punctuation = color_class text;
	color_class dired_dir_name = color_class c_string;
	color_class dired_header = color_class c_comment;
	color_class dired_copied = dark_blue;
	color_class grep_match = color_class dired_deleted;
	color_class show_matching_start = black on light_green;
	color_class show_matching_end = black on cyan;
	color_class tex_curly_brace = color_class html_text;
	color_class tex_square_bracket = color_class html_value;
	color_class tex_math = color_class html_attribute;
	color_class tex_command = color_class html_value;
	color_class tex_begin_end = color_class html_tag;
};

color_scheme "standard-color" {
	color_class text green on black;
	color_class echo_area yellow;
	color_class c_preprocessor dark_cyan;
	color_class c_identifier green;
	color_class html_tag = color_class c_string;
	color_class html_attribute dark_green;
	color_class html_value = color_class text;
	color_class dired_file_name = color_class echo_area;
	color_class dired_deleted green on dark_red;
	color_class dired_moved = green on dark_green;
	color_class dired_copied = green on dark_blue;
	color_class diff_removed black on light_red;
	color_class perl_string dark_green;
};

color_scheme "standard-mono" {
	color_class text grey on black;
	color_class highlight black on grey;
	color_class echo_area grey;
	color_class mode_line white;
	color_class horiz_border white;
	color_class popup_title white;
	color_class popup_border white;
	color_class debug_text grey;
	color_class debug_highlight black on grey;
	color_class default blue;
	color_class overlap_even blue;
	color_class viewed_text grey;
	color_class viewed_border white;
	color_class viewed_link white;
	color_class selected_link black on white;
	color_class menu grey;
	color_class menu_highlight black on grey;
	color_class menu_bar black on grey;
	color_class menu_bar_highlight grey;
	color_class submenu black on grey;
	color_class submenu_highlight grey;
	color_class c_comment grey;
	color_class c_keyword grey;
	color_class c_function grey;
	color_class c_identifier grey;
	color_class c_string grey;
	color_class ident_completion grey on white;
	color_class html_text = color_class text;
	color_class html_punctuation = color_class text;
	color_class dired_deleted = color_class highlight;
	color_class dired_moved = color_class highlight;
	color_class dired_copied = color_class highlight;
	color_class grep_match = color_class highlight;
	color_class diff_added = black on white;
	color_class diff_removed = black on grey;
	color_class show_matching_start = black on grey;
	color_class show_matching_end = black on grey;
	color_class tex_section = color_class c_string;
};

color_scheme "night-light" {
	color_class text white on black;
	color_class highlight black on white;
	color_class echo_area yellow;
	color_class after_exiting grey;
	color_class c_comment grey;
	color_class c_preprocessor dark_green;
	color_class c_keyword cyan;
	color_class c_function white;
	color_class c_identifier white;
	color_class c_string blue;
	color_class c_number grey;
	color_class c_punctuation dark_cyan;
	color_class html_text = color_class text;
	color_class html_tag blue;
	color_class html_attribute dark_green;
	color_class html_value cyan;
	color_class grep_filename blue;
	color_class process_input cyan;
	color_class tex_math = red;
};

color_scheme "yellow-on-blue" {
	color_class text yellow on dark_blue;
	color_class highlight dark_blue on grey;
	color_class echo_area yellow;
	color_class popup_title dark_red on white;
	color_class popup_border dark_red on white;
	color_class debug_text dark_blue on white;
	color_class debug_highlight white;
	color_class default dark_red on white;
	color_class overlap_even cyan on blue;
	color_class screen_border grey;
	color_class viewed_text dark_blue on white;
	color_class viewed_border dark_red on white;
	color_class viewed_link green on white;
	color_class selected_link red on white;
	color_class menu dark_blue on white;
	color_class menu_highlight dark_blue on cyan;
	color_class menu_bar black on cyan;
	color_class menu_bar_highlight dark_blue on white;
	color_class submenu black on cyan;
	color_class submenu_highlight dark_blue on white;
	color_class c_comment grey;
	color_class c_preprocessor green;
	color_class c_keyword yellow;
	color_class c_function white;
	color_class c_identifier yellow;
	color_class c_number cyan;
	color_class c_punctuation grey;
	color_class html_text = color_class text;
};

color_scheme "white-on-blue" {
	color_class text white on dark_blue;
	color_class highlight dark_blue on grey;
	color_class echo_area yellow;
	color_class popup_title dark_red on white;
	color_class popup_border dark_red on white;
	color_class debug_text dark_blue on white;
	color_class debug_highlight white;
	color_class default dark_red on white;
	color_class overlap_even cyan on blue;
	color_class screen_border grey;
	color_class viewed_text dark_blue on white;
	color_class viewed_border dark_red on white;
	color_class viewed_link green on white;
	color_class selected_link red on white;
	color_class menu dark_blue on white;
	color_class menu_highlight dark_blue on cyan;
	color_class menu_bar black on cyan;
	color_class menu_bar_highlight dark_blue on white;
	color_class submenu black on cyan;
	color_class submenu_highlight dark_blue on white;
	color_class c_comment grey;
	color_class c_preprocessor green;
	color_class c_keyword yellow;
	color_class c_function white;
	color_class c_identifier white;
	color_class c_number cyan;
	color_class c_punctuation grey;
	color_class html_text = color_class text;
	color_class html_tag = color_class c_keyword;
	color_class grep_filename = color_class dired_header;
	color_class process_input = color_class c_keyword;
};

color_scheme "blue-on-cyan" {
	color_class text dark_grey on cyan;
	color_class highlight white on blue;
	color_class echo_area dark_blue;
	color_class mode_line black;
	color_class horiz_border black;
	color_class popup_title dark_red on white;
	color_class popup_border dark_red on white;
	color_class debug_text dark_blue on white;
	color_class debug_highlight white on dark_blue;
	color_class default dark_red on white;
	color_class overlap_even cyan on blue;
	color_class screen_border dark_grey;
	color_class viewed_text dark_blue on white;
	color_class viewed_border dark_red on white;
	color_class viewed_link green on white;
	color_class selected_link red on white;
	color_class menu dark_blue on white;
	color_class menu_highlight dark_blue on yellow;
	color_class menu_bar black on green;
	color_class menu_bar_highlight dark_blue on white;
	color_class submenu black on green;
	color_class submenu_highlight dark_blue on white;
	color_class c_comment dark_green;
	color_class c_preprocessor dark_magenta;
	color_class c_keyword black;
	color_class c_function blue;
	color_class c_identifier blue;
	color_class c_string dark_magenta;
	color_class c_number dark_green;
	color_class html_text black;
	color_class html_tag = color_class text;
	color_class html_value = color_class c_function;
	color_class grep_match = color_class dired_deleted;
	color_class show_matching_start = black on green;
	color_class show_matching_end = black on light_blue;
};

color_scheme "white-background" {
	color_class text dark_grey on white;
	color_class highlight white on dark_blue;
	color_class echo_area blue;
	color_class mode_line dark_cyan;
	color_class horiz_border dark_cyan;
	color_class popup_title blue on cyan;
	color_class popup_border blue on cyan;
	color_class debug_text dark_blue on yellow;
	color_class debug_highlight yellow on dark_blue;
	color_class default dark_red;
	color_class screen_border dark_grey;
	color_class viewed_text brown on cyan;
	color_class viewed_border blue on cyan;
	color_class viewed_link green on cyan;
	color_class selected_link red on cyan;
	color_class menu dark_blue on cyan;
	color_class menu_highlight dark_blue on yellow;
	color_class menu_bar yellow on blue;
	color_class menu_bar_highlight green on blue;
	color_class submenu yellow on blue;
	color_class submenu_highlight green on blue;
	color_class c_comment medium_red;
	color_class c_preprocessor dark_green;
	color_class c_keyword dark_magenta;
	color_class c_function black;
	color_class c_string blue;
	color_class c_number blue;
	color_class html_text dark_magenta;
	color_class html_attribute blue;
	color_class dired_copied = color_class c_keyword;
	color_class grep_match = color_class dired_deleted;
	color_class grep_filename = color_class dired_header;
	color_class tex_math = color_class c_keyword;
};

color_scheme "dos-edit" {
	color_class text grey on dark_blue;
	color_class highlight dark_blue on grey;
	color_class echo_area white on dark_cyan;
	color_class mode_line dark_blue on grey;
	color_class horiz_border grey;
	color_class popup_title black on grey;
	color_class popup_border black on grey;
	color_class debug_text dark_blue on white;
	color_class debug_highlight white on dark_blue;
	color_class default dark_red on white;
	color_class overlap_even cyan on blue;
	color_class screen_border grey on black;
	color_class viewed_text grey on black;
	color_class viewed_border grey on black;
	color_class viewed_link green on black;
	color_class selected_link red on black;
	color_class menu black on grey;
	color_class menu_highlight grey on black;
	color_class menu_bar black on grey;
	color_class menu_bar_highlight grey on black;
	color_class submenu black on grey;
	color_class submenu_highlight grey on black;
	color_class c_comment grey;
	color_class c_preprocessor green;
	color_class c_keyword white;
	color_class c_identifier yellow;
	color_class c_number cyan;
	color_class html_text = color_class c_keyword;
	color_class html_comment = color_class text;
	color_class html_entity = color_class text;
	color_class dired_copied = color_class c_keyword;
	color_class process_prompt = color_class c_keyword;
};

color_scheme "borlandc" {
	color_class text yellow on dark_blue;
	color_class highlight dark_blue on grey;
	color_class echo_area black on grey;
	color_class mode_line white;
	color_class horiz_border white;
	color_class popup_title white on grey;
	color_class popup_border white on grey;
	color_class debug_text dark_blue on white;
	color_class debug_highlight white on dark_blue;
	color_class default dark_red on white;
	color_class overlap_even cyan on blue;
	color_class screen_border white on black;
	color_class viewed_text black on grey;
	color_class viewed_border black on grey;
	color_class menu black on grey;
	color_class menu_highlight black on dark_green;
	color_class menu_bar black on grey;
	color_class menu_bar_highlight black on dark_green;
	color_class submenu black on grey;
	color_class submenu_highlight black on dark_green;
	color_class c_comment grey;
	color_class c_preprocessor green;
	color_class c_keyword white;
	color_class c_identifier yellow;
	color_class c_number cyan;
	color_class c_punctuation white;
	color_class html_text = color_class text;
	color_class html_tag = color_class c_keyword;
	color_class dired_file_name = color_class c_keyword;
	color_class process_input = color_class c_keyword;
};

color_scheme "window-black" {
	color_class text green on black;
	color_class echo_area yellow;
	color_class c_preprocessor dark_cyan;
	color_class c_identifier green;
	color_class html_tag = color_class c_string;
	color_class html_attribute dark_green;
	color_class html_value = color_class text;
};

color_scheme "window-blue" {
	color_class text green on dark_blue;
	color_class screen_border green on black;
	color_class c_preprocessor dark_cyan;
	color_class c_identifier green;
	color_class html_tag = color_class text;
	color_class tex_command = color_class c_comment;
};

color_scheme "window-green" {
	color_class text green on dark_green;
	color_class highlight black on green;
	color_class screen_border green on black;
	color_class c_preprocessor dark_blue;
	color_class c_identifier green;
	color_class html_tag = color_class text;
	color_class dired_deleted dark_magenta;
};

color_scheme "window-cyan" {
	color_class text green on dark_cyan;
	color_class mode_line cyan on dark_cyan;
	color_class horiz_border cyan on dark_cyan;
	color_class screen_border green on black;
	color_class c_preprocessor black;
	color_class c_identifier green;
	color_class html_text = color_class text;
	color_class dired_deleted dark_magenta;
};

color_scheme "window-red" {
	color_class text green on dark_red;
	color_class screen_border green on black;
	color_class c_identifier green;
	color_class html_text = color_class text;
	color_class html_attribute = color_class c_preprocessor;
	color_class html_value = color_class c_string;
};

color_scheme "window-magenta" {
	color_class text green on dark_magenta;
	color_class mode_line cyan on dark_magenta;
	color_class horiz_border cyan on dark_magenta;
	color_class screen_border green on black;
	color_class c_identifier red;
	color_class c_keyword red;
	color_class c_number red;
	color_class c_punctuation red;
	color_class html_tag = color_class text;
	color_class html_attribute = color_class c_preprocessor;
	color_class html_value = color_class c_string;
};

color_scheme "window-brown" {
	color_class text yellow on brown;
	color_class screen_border green on black;
	color_class c_preprocessor black;
	color_class c_keyword yellow;
	color_class c_function green;
	color_class c_identifier yellow;
	color_class html_text = color_class text;
	color_class dired_deleted dark_magenta;
};

color_scheme "window-white" {
	color_class text black on grey;
	color_class popup_title dark_red;
	color_class popup_border dark_red;
	color_class debug_text dark_blue;
	color_class screen_border green on black;
	color_class viewed_text dark_blue;
	color_class viewed_border dark_red;
	color_class viewed_link green;
	color_class selected_link red;
	color_class menu dark_blue;
	color_class menu_bar_highlight dark_blue;
	color_class c_preprocessor dark_red;
	color_class c_keyword black;
	color_class c_function dark_blue;
	color_class c_charconst black;
	color_class html_text = color_class c_string;
	color_class html_attribute = color_class text;
};

color_scheme "grey-background" {
	color_class text black on light_grey;
	color_class highlight black on yellow;
	color_class echo_area blue;
	color_class mode_line dark_red;
	color_class horiz_border dark_red;
	color_class popup_title dark_red on yellow;
	color_class popup_border dark_red on yellow;
	color_class after_exiting white;
	color_class debug_text blue on yellow;
	color_class debug_highlight white on dark_blue;
	color_class default dark_red on yellow;
	color_class overlap_even dark_red on dark_blue;
	color_class screen_border black;
	color_class viewed_text blue on white;
	color_class viewed_border dark_red on yellow;
	color_class viewed_link green on yellow;
	color_class selected_link red on yellow;
	color_class menu blue on white;
	color_class menu_highlight blue on cyan;
	color_class menu_bar black on cyan;
	color_class menu_bar_highlight blue on yellow;
	color_class submenu black on cyan;
	color_class submenu_highlight blue on yellow;
	color_class c_preprocessor dark_green;
	color_class c_keyword black;
	color_class c_function blue;
	color_class c_string dark_red;
	color_class html_text = color_class c_comment;
	color_class html_value dark_blue;
	color_class html_comment = color_class text;
	color_class html_entity = color_class text;
};

/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1996, 2002 Lugaru Software Ltd.  All rights reserved.  *
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

#include "eel.h"
#include "vbasic.h"
#include "proc.h"
#include "colcode.h"

color_vbasic_range(from, to) // recolor just this section
{			// last colored region may go past to
	int t = -1, talk, old;

	if (from >= to)
		return to;
	save_var point, matchstart, matchend;
	point = from;
	to_begin_line();
	set_character_color(point, to, -1);
	talk = (to - from > 2000);	// show status during long delays
	while (point < to) {
		old = point;
		if (!re_search(1, "[#0-9A-Za-z_]+[$@#%&!]?|[\"']")) {
			set_character_color(old, point, -1);
			t = size();
			break;
		}
		set_character_color(old, point, -1);
		t = matchstart;
		switch (character(point - 1)) {		// check last char
			case '\'':			// found comment
				nl_forward();
				set_character_color(t, point, color_class vbasic_comment);
				break;
			case '"':		// found a string literal
				point = t;
				re_search(1, "\"([^\"\\\n]|\\(.|\n))*[\"\n]");
				set_character_color(t, point, color_class vbasic_string);
				break;
			case 'm':
				if (parse_string(-1, "</word>rem")) {
					nl_forward();
					set_character_color(t, point, color_class vbasic_comment);
					break;
				}					// fall through
			default:		// found identifier, kywd, or number
				set_character_color(t, point, vbasic_keyword_color(t));
				break;
		}
		if (talk)
			note("Coloring VBasic program: %d%% complete...",
				 muldiv(point - from, 100, to - from));
	}
	if (talk)
		note("");
	return point;
}

vbasic_keyword_color(from)	// return color for "identifier" from here to point
{			// (something with alpha or digits)
	char buf[500];
	int p = point;

	save_var point;
	if (p - from > sizeof(buf) - 10)
		p = from + sizeof(buf) - 10;
	buf[0] = '|';		// get identifier, between | chars
	grab(from, p, buf + 1);
	if (index("0123456789-", buf[1]) || buf[1] == '.' && isdigit(buf[2]))
		return -1;
	strcpy(buf + p - from + 1, "|");
	if (is_vbasic_keyword(buf))
		return color_class vbasic_keyword;
	if (!strcmp(buf, "|_|") && parse_string(1, "[ \t]*\n"))
		return -1;
	if (color_class vbasic_function != color_class vbasic_identifier
		  && paren_follows())
		return color_class vbasic_function;
	return color_class vbasic_identifier;
}

is_vbasic_keyword(p)	// is text in p (must be surrounded by |'s) a keyword?
char *p;
{
	save_var case_fold = 1;

	if (strstr("|abs|array|asc|ascb|ascw|atn|cbool|cbyte|ccur|cdate|cdbl"
			   "|cdec|choose|chr|chr$|chrb|chrb$|chrw|cint|clng|command"
			   "|command$|cos|createobject|csng|cstr|curdir|curdir$|cvar"
			   "|cvdate|cverr|date|date$|dateadd|datediff|datepart"
			   "|dateserial|datevalue|day|ddb|dir|dir$|doevents|environ"
			   "|environ$|eof|error|error$|exp|fileattr|filedatetime|filelen"
			   "|fix|format|format$|freefile|fv|getallsettings|getattr"
			   "|getobject|getsetting|hex|hex$|hour|iif|imestatus|input"
			   "|input$|inputb|inputb$|inputbox|instr|instrb|int|ipmt|irr"
			   "|isarray|isdate|isempty|iserror|ismissing|isnull|isnumeric"
			   "|isobject|lbound|lcase|lcase$|left|left$|leftb|leftb$|len"
			   "|lenb|loc|lof|log|long|ltrim|ltrim$|mid|mid$|midb|midb$|minute"
			   "|mirr|month|msgbox|now|nper|npv|oct|oct$|partition|pmt|ppmt"
			   "|pv|qbcolor|rate|rgb|right|right$|rightb|rightb$|rnd|rtrim"
			   "|rtrim$|second|seek|sgn|shell|sin|sln|space|space$|spc|sqr"
			   "|str|str$|strcomp|strconv|string|string$|switch|syd|tab|tan"
			   "|time|time$|timer|timeserial|timevalue|trim|trim$|typename"
			   "|ubound|ucase|ucase$|val|vartype|weekday|year|", p))
			return 2;		// Function
	if (strstr("|#const|#else|#elseif|#end|if|#if|access|alias|any"
			   "|appactivate|append|as|base|beep|binary|byref|byval|call"
			   "|case|cdecl|chdir|chdrive|close|compare|const|date|declare"
			   "|defbool|defbyte|defcur|defdate|defdbl|defdec|defint|deflng"
			   "|defobj|defsng|defstr|defvar|deletesetting|dim|do|each|else"
			   "|elseif|empty|end|endif|erase|error|exit|explicit|false"
			   "|filecopy|for|function|get|global|gosub|goto|if|in|input|is"
			   "|kill|len|let|lib|line|load|local|lock|loop|lset|me|mid|midb"
			   "|mkdir|module|name|new|next|nothing|null|on|open|option"
			   "|optional|output|paramarray|preserve|print|private|property"
			   "|public|put|random|randomize|read|redim|rem|reset|resume"
			   "|return|rmdir|rset|savesetting|seek|select|sendkeys|set"
			   "|setattr|shared|static|step|stop|string|sub|text|then|time"
			   "|to|true|type|typeof|unload|unlock|until|wend|while|width"
			   "|with|withevents|write|", p))
			return 1;	// Statement or keyword.
	if (sublanguage_code == SUBLANG_VBSCRIPT &&
		  strstr("|class|eval|execute|scriptengine|", p))
		return 3;		// VBScript-specific
	return 0;
}

// Indent the following line more?  Look for keywords like While or If.
// But ignore "if" whenever the conditional part follows on that line.

int vbasic_indent_more()
{
	if (vbasic_indent_subroutines && parse_string(1, "[ \t]*</word>(Sub)</word>"))
		return 1;
	return parse_string(1, "[ \t]*</word>(While|Type|Else)</word>")
			|| parse_string(1, "[ \t]*</word>(If|Elseif)</word>.*")
			&& !parse_string(1, ".*</word>then</word>[ \t]*[^ \t\n']");
}

int vbasic_indent_less()
{
	return parse_string(1, "[ \t]*</word>(End|Wend|Else|Elseif)</word>") != 0;
}

// Is this a continuation line?
vbasic_is_continuation()
{
	save_var point;
	to_begin_line();
	return parse_string(-1, "_[ \t]*\n");
}

// If this is a continuation line, move back to the actual start.
vbasic_before_continuation()
{
	while (vbasic_is_continuation())
		nl_reverse();
	to_begin_line();
}

vbasic_step()
{
	return (vbasic_indent > 0) ? vbasic_indent : tab_size;
}

// Indent line at orig based on this one.
vbasic_indent_continuation(orig)
{
	int ind;

	vbasic_before_continuation();
	ind = get_indentation(point);
	point = orig;
	indent_to_column(ind + 10);
}

do_vbasic_indent() on vbasic_tab['\t']
{
	if (maybe_indent_rigidly(0))
		return;
	if (this_cmd != CMD_INDENT_REG)
		this_cmd = C_INDENT;
	if (current_column() > get_indentation(point) || prev_cmd == C_INDENT) {
		indent_like_tab();
		return;
	}
	vbasic_indenter();
}

// Indentation: Begin/End
vbasic_indenter()
{
	int orig = point, ind;

	if (vbasic_is_continuation()) {
		vbasic_indent_continuation(orig);
		return;
	}
	do {
		to_begin_line();
		if (!re_search(-1, "[^ \t\n]"))	/* Find previous non-blank line */
			break;
		to_indentation();
	} while (parse_string(1, "'"));	// that's not a comment.
	vbasic_before_continuation();
	ind = get_indentation(point);
	if (vbasic_indent_more())
		ind += vbasic_step();
	point = orig;
	if (vbasic_indent_less())
		ind -= vbasic_step();
	to_indentation();		/* go to current line's indent */
	indent_to_column(ind);
}

// Set display_func_name to the name of the function we're editing, and
// return 1.  If not in a function, set display_func_name to "" and
// return 1.  If user pressed a key and we gave up for now, return 0.

vbasic_func_name_finder()
{
	int from, to;

	save_var case_fold = 1, point;
	to_end_line();
	while (re_search(-1, "^[ \t]*((end|public|private|static)[ \t]+)?"
					 "(sub|function|type)</word>")) {
		if (tolower(character(find_group(1, 1))) == 'e')
			break;
		if (!matches_at(matchstart, 1, "[ \t]+([a-z_0-9]+)"))
			continue;
		from = find_group(1, 1);
		to = find_group(1, 0);
		to = MIN(to, from + ptrlen(display_func_name) - 1);
		grab(from, to, display_func_name);
		return 1;
	}
	*display_func_name = 0;
	return 1;
}

tag_suffix_bas()
{
	char func[TAGLEN];
	int start;

	save_var point = 0, case_fold = 1;
	while (re_search(1, "^[ \t]*((public|private|static)[ \t]+)?"
					 "(sub|function|type)[ \t]+([a-z_0-9]+)")) {
		grab(start = find_group(4, 1), find_group(4, 0), func);
		add_tag(func, start);
	}
}

tag_suffix_frm()
{
	tag_suffix_bas();
}

tag_suffix_vbs()
{
	tag_suffix_bas();
}

tag_suffix_cls()
{
	tag_suffix_bas();
}


command vbasic_mode()
{
	mode_default_settings();
	mode_keys = vbasic_tab;		/* Use these keys. */
	major_mode = _vbasic_mode_name;
//	compile_buffer_cmd = compile_vbasic_cmd;	// can compile this?
	indenter = vbasic_indenter;
	auto_indent = 1;
	strcpy(comment_start, "(rem |')[ \t]*");
	strcpy(comment_pattern, "(rem |').*$");
	strcpy(comment_begin, "' ");
	strcpy(comment_end, "");
	recolor_range = color_vbasic_range;	// set up coloring rules
	recolor_from_here = recolor_by_lines;
	if (want_code_coloring)		// maybe turn on coloring
		when_setting_want_code_coloring();
	if (auto_show_vbasic_delimiters)
		auto_show_matching_characters = vbasic_auto_show_delim_chars;
	vbasic_tab[ALT('q')] = (short) fill_comment;
	try_calling("vbasic-mode-hook");
	drop_all_colored_regions();
	make_mode();
}

suffix_frm()
{
	vbasic_mode();
}

suffix_bas()
{
	vbasic_mode();
}

suffix_vbs()
{
	vbasic_mode();
}

suffix_cls()
{
	vbasic_mode();
}

/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1995, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

// This file has Epsilon's code coloring functions.
// There are routines that handle code coloring in general, and
// routines specific to code coloring in C-mode buffers.

#include "eel.h"
#include "c.h"
#include "colcode.h"

init_color_code()
{
	coloring_flags |= COLOR_DO_COLORING;
}

// On each refresh, recolor_partial_code() will be called with the
// buffer range that was modified since the last redisplay.

recolor_partial_code(from, to)	// recolors during refresh
{			// params give range of buffer modified
	from = from;		// We no longer need these parameters.
	to = to;			// Silence EEL's warning.
	init_color_code();
	if (!(coloring_flags & COLOR_IN_PROGRESS)) {
		coloring_flags |= COLOR_IN_PROGRESS; // ensure errors don't restart us
		if (!(coloring_flags & COLOR_MINIMAL) != !minimal_coloring) {
			drop_all_colored_regions();		// If setting's changed.
			coloring_flags &= ~COLOR_MINIMAL;
			if (minimal_coloring)
				coloring_flags |= COLOR_MINIMAL;
		}
		save_var point, matchstart, matchend, abort_searching = 0;
		if (!(coloring_flags & COLOR_RETAIN_NARROWING))
			save_var narrow_start = 0, narrow_end = 0;
		shrink_colored_area();		// Buffer modifications shrink list of regions.
		if (size() < color_whole_buffer) // Now expand list of regions.
			color_for_area(0, size());
		else
			color_for_area(window_start, MIN(window_end + 1, size()));
		coloring_flags &= ~COLOR_IN_PROGRESS;	// no errors aborted us,
	}					// let us run next time
}

// Return -1 if this particular call to wait_for_key() doesn't need to
// call us again, or the amount of time in hundredths of a second until
// we wish to be called again.

when_idle_coloring(cnt)	// Called when idle, waiting for a key.
{			// Cnt increases while waiting for same key.
	int last = 0, from, to;

	if (idle_coloring_delay < 0 || !(coloring_flags & COLOR_DO_COLORING)
		|| (coloring_flags & COLOR_IN_PROGRESS) || !size())
		return -1;
	if (cnt < 1)
		time_begin(&idle_color_time, idle_coloring_delay);
	if (!time_done(&idle_color_time))
		return time_remaining(&idle_color_time);
	save_var narrow_start = 0, narrow_end = 0;
	if (!get_tagged_region("needs-color", 0, &from, &to)) {
		if (to >= size())	// We're done if the good region extends to eof.
			return -1;		// Otherwise, get the following (bad) region.
		get_tagged_region("needs-color", to, &from, &to);
	}
	last = from;
	save_var point, matchstart, matchend, abort_searching = 0;
	coloring_flags |= COLOR_IN_PROGRESS; // ensure errors don't restart us
	color_for_area(last, last + idle_coloring_size);
	coloring_flags &= ~COLOR_IN_PROGRESS;	// no errors aborted us, do more
	return 0;
}

/*
First invalidate the modified part of the buffer.  This typically
happens once on each refresh.

First, get the region of the buffer that has been modified since last
time we were called.

Then expand that region to include entire lines.

Then (unless this buffer uses line-based coloring), expand that region
to include entire colored regions.  For instance, if the modification
was inside a block comment, expand the region to the whole comment.
(We omit this step during line-based coloring because each region might
be very large.)

*/

shrink_colored_area()
{
	int from, to, adjfrom, adjto, by_lines;

	if (!(coloring_flags & COLOR_DO_COLORING))
		return;		// No coloring yet, so nothing to do.
	by_lines = (recolor_from_here == recolor_by_lines);
	if (modified_buffer_region(&from, &to, "needs-color")) {
		point = from - 1;
		if (by_lines)
			adjfrom = give_begin_line();
		else
			get_character_color(give_begin_line(), &adjfrom, (int *) 0);
		point = to;
		if (by_lines)
			adjto = give_end_line() + 1;
		else
			get_character_color(give_end_line(), (int *) 0, &adjto);
		if (coloring_flags & COLOR_INVALIDATE_FORWARD)
			adjto = size();
		if (coloring_flags & COLOR_INVALIDATE_BACKWARD)
			adjfrom = 0;
		set_tagged_region("needs-color", adjfrom, adjto, -1);
		if (coloring_flags & COLOR_INVALIDATE_RESETS)
			set_character_color(adjfrom, adjto, -1);
	}
	reset_modified_buffer_region("needs-color");
}

// Make sure this range in the current buffer has the right coloring.
// If the buffer has been modified since its last coloring, mark the
// modified area uncolored first.
recolor_buffer_range(start, end)
{
	if (want_code_coloring && recolor_range) {
		save_var point;
		shrink_colored_area();
		color_for_area(start, end);
	}
}

int get_character_syntax_color(int pos)
{
	save_var narrow_start = 0, narrow_end = 0, matchstart, matchend, point;
	recolor_buffer_range(pos, pos + 1);
	return get_character_color(pos);
}

/*
Now deal with the buffer range we have to color (typically the
current window).  If our starting point isn't correctly colored
already, then begin coloring at a position somewhere before,
determined by the mode's recolor_from_here() function.
Then, for each uncolored region between from and to, color it,
until the good region extends between these points.
*/

color_for_area(from, to)	// we need to color region in this range
{
	save_var point, abort_searching = 0;
	init_color_code();
	color_for_narrowed_area(from, to);
}

// Like above, but don't disturb narrowing.
color_for_narrowed_area(from, to)
{
	int i, j, give_up = 0;

	save_var point, abort_searching = 0;
	init_color_code();
	to = MIN(to, size() - narrow_end);
	for (;;) {
		if (get_tagged_region("needs-color", from, &i, &j)) {
			if (i < from) {
				point = from;		// From isn't colored, so start before it.
				nl_reverse();	// Color a few extra lines before
				nl_reverse();	// to speed up scrolling.
				nl_reverse();		// Next, find starting place guaranteed to be
				if (point > i)		// on the edge of a colored region.
					i = recolor_from_here(i);
			}						// (Or use known safe place if it's closer.)
		} else {
			if (j >= to) {		// From is colored, see if good region extends
				return;			// far enough.  If not, get following bad reg.
			} else if (!get_tagged_region("needs-color", j, &i, &j)) {
				int a, b, res;

				say("Coloring internal error 1");
				buffer_printf("debug-color", "Coloring internal error 1:\n");
				buffer_printf("debug-color", "bad color 0 from %d to %d in %s, size %d\n",
							  i, j, bufname, size());
				res = get_tagged_region("needs-color", from, &a, &b);
				buffer_printf("debug-color", "color %d at %d (from %d to %d) in %s, size %d\n",
							  res, from, a, b, bufname, size());
				res = get_tagged_region("needs-color", j - 1, &a, &b);
				buffer_printf("debug-color", "color %d at %d (from %d to %d) in %s, size %d\n",
							  res, j - 1, a, b, bufname, size());
				return;
			}
		}
		j = MIN(j, to);		// Color only some of it.
		if (i >= j)
			return;
		j = recolor_range(i, j);
		set_tagged_region("needs-color", i, j, 0);
		if (give_up++ > 100) {
			say("Coloring internal error 2");
			return;
		}
	}
}

// Record that the area between from & to is now correctly colored.
add_colored_area(from, to)
{
	set_tagged_region("needs-color", from, to, 0);
}

drop_all_colored_regions()
{
	set_tagged_region("needs-color", 0, size(), -1);
}

// A recolor_from_here function good for line-based buffers.
recolor_by_lines(safe)
{
	safe = safe;		// eliminate compiler warning
	return give_begin_line();
}

// A recolor_from_here function for always coloring from start of buffer.
recolor_from_top(safe)
{
	return safe;
}

// functions for coloring C/C++/EEL code

color_c_from_here(safe)	// Move backward to the nearest line guaranteed
{			// to start outside any colored region, return pos.
	int pos, limit; // We know safe is ok value to return.

	limit = point - safe;
	if (color_look_back && color_look_back < limit)
		limit = color_look_back;
	to_begin_line();
	pos = point;
	while ((in_c_comment(limit) == IN_OLD_COMMENT)
				       && search(-1, "/*")) {
		to_begin_line(); // move back out of an old-style comment
		pos = point;
	}
	point = pos;
	while (character(point - 2) == '\\') {	// don't stay on contin line
		point--;
		to_begin_line();
	}
	return point;
}

color_c_range(from, to) // recolor just this section
{			// last colored region may go past to
	int t = -1, talk, s, talk_at = 0;
	char pat[200];

	if (from >= to)
		return to;
	save_var point, matchstart, matchend;
	c_init_color(from, to);
	point = from;
	talk = (to - from > 20000);	// show status during long delays
	save_var case_fold = 0;
	strcpy(pat, "/<*>|//|^[ \t]*#|[\"']");
	if (!minimal_coloring)
		strcat(pat, "|[A-Za-z_][A-Za-z0-9_]*"
		       "|-?%.?[0-9]([A-Za-z0-9._]|[Ee]-)*");
	while (point < to) {
		if (!re_search(1, pat)) {
			t = size();
			break;
		}
		t = matchstart;
		switch (character(point - 1)) {		// check last char
		case '/':			// found // one-line comment
			while (nl_forward() && character(point - 2) == '\\')
				;		// Continued // comment.
			set_character_color(t, point, color_class c_comment);
			break;
		case '*':			// found /* starting comment
			search(1, "*/");
			set_character_color(t, point, color_class c_comment);
			break;
		case '#':			// found preproc line
			c_preproc_color();	// move past correct part
			set_character_color(t, point,
					    color_class c_preprocessor);
			break;
		case '"':		// found a string literal
			point = t;
			re_search(1, "\"([^\"\\\n]|\\(.|\n))*[\"\n]");
			set_character_color(t, point, color_class c_string);
			if (get_character_color(point, (int *) 0, &s) == 
			    color_class c_string && s > to)  // fix up after
				c_init_color(point, to = s); // quoted "'s
			break;
		case '\'':		// found a char const
			point = t;
			re_search(1, "\'([^\'\\\n]|\\(.|\n))*[\'\n]");
			set_character_color(t, point, color_class c_charconst);
			break;
		default:		// found identifier, kywd, or number
			set_character_color(t, point, c_keyword_color(t));
			if ((c_extra_keywords & IDL_KEYWORDS)	// Special rule for
				&& (point - t == 4)			// uuid's in IDL files.
				&& parse_string(-1, "uuid")
				&& parse_string(1, "%([0-9A-Fa-f]"))
				maybe_color_uuid();
			break;
		}
		if (talk && point > talk_at + 2000) {
			note("Coloring C program: %d%% complete...",
				 muldiv(point - from, 100, to - from));
			talk_at = point;
		}
	}
	c_init_color(to, t);
	if (talk)
		note("");
	return point;
}

c_init_color(from, to)
{
	if (from < to)
		set_character_color(from, to, minimal_coloring
				    ? color_class c_identifier
				    : color_class c_punctuation);
}

c_keyword_color(from)	// return color for "identifier" from here to point
{			// (something with alpha or digits)
	char buf[500];

	save_var point;
	if (point - from > sizeof(buf) - 10)
		point = from + sizeof(buf) - 10;
	buf[0] = '|';		// get identifier, between | chars
	grab(from, point, buf + 1);
	if (index("0123456789-.", buf[1]))
		return c_number_color(buf + 1);
	strcpy(buf + point - from + 1, "|");
	if (is_c_keyword(buf))
		return color_class c_keyword;
	if (color_class c_function != color_class c_identifier
	    && paren_follows())
		return color_class c_function;
	return color_class c_identifier;
}

is_c_keyword(p)		// is text in p (must be surrounded by |'s) a keyword?
char *p;
{
	if (strstr("|if|else|for|do|while|return|break|continue|switch|"
		   "case|default|goto|char|short|int|static|volatile|const|"
		   "float|double|long|void|", p))
		return 1;
	if (p[1] == '_' &&
	    strstr("|_asm|_based|_cdecl|_emit|_except|_export|_far|_fastcall|"
		   "_fortran|_huge|_interrupt|_loadds|_near|_pascal|_saveregs|"
		   "_segment|_segname|_stdcall|_syscall|_try|__int64|", p))
		return 1;
	if ((c_extra_keywords & EEL_KEYWORDS) &&
	    strstr("|keytable|buffer|window|command|on|color_class|"
		   "spot|save_spot|save_var|on_exit|user|zeroed|", p))
		return 1;
	if ((c_extra_keywords & CPP_KEYWORDS) &&
	    strstr("|asm|catch|class|delete|friend|inline|new|operator|"
			   "private|protected|public|template|try|this|virtual|"
			   "throw|_self|and|and_eq|bitand|bitor|bool|compl|const_cast|"
			   "dynamic_cast|explicit|false|mutable|namespace|not|not_eq|"
			   "or|or_eq|reinterpret_cast|static_cast|true|typeid|typename|"
			   "using|wchar_t|xor|xor_eq|", p))
		return 1;
	if ((c_extra_keywords & JAVA_KEYWORDS) &&
	    strstr("|abstract|boolean|byte|catch|class|extends|false|final|"
			   "finally|function|implements|import|in|instanceof|"
			   "interface|native|new|null|package|private|protected|"
			   "public|super|synchronized|this|throw|throws|transient|"
			   "true|try|var|with|", p))
		return 1;
	if (!(c_extra_keywords & JAVA_KEYWORDS) &&
	    strstr("|auto|enum|extern|register|unsigned|signed|sizeof|"
			   "struct|union|typedef|", p))
		return 1;		// C keywords not in Java.
	if ((c_extra_keywords & IDL_KEYWORDS) &&
		strstr("|appobject|auto_handle|bindable|boolean|broadcast|byte|"
			   "callback|coclass|code|comm_status|context_handle|"
			   "control|decode|defaultbind|dispinterface|displaybind|"
			   "dual|enable_allocate|encode|error_status_t|"
			   "explicit_handle|fault_status|handle|handle_t|hidden|"
			   "hyper|idempotent|ignore|immediatebind|import|in|"
			   "include|interface|library|licensed|local|maybe|module|", p))
		return 1;
	if ((c_extra_keywords & IDL_KEYWORDS) &&
		strstr("|ms_union|nocode|nonextensible|notify|object|odl|"
			   "oleautomation|optional|out|pipe|propget|propput|"
			   "propputref|public|ptr|readonly|ref|requestedit|"
			   "restricted|retval|small|source|string|unique|"
			   "usesgetlasterror|v1_enum|vararg|", p))
		return 1;
	if ((c_extra_keywords & CSHARP_KEYWORDS) &&
		  strstr("|abstract|as|base|bool|break|byte|case|catch|char|"
				 "checked|class|const|continue|decimal|default|delegate|"
				 "do|double|else|enum|event|explicit|extern|false|finally|"
				 "fixed|float|for|foreach|goto|if|implicit|in|int|"
				 "interface|internal|is|lock|long|namespace|new|null|"
				 "object|operator|out|override|params|private|protected|"
				 "public|readonly|ref|return|sbyte|sealed|short|sizeof|"
				 "stackalloc|static|string|struct|switch|this|throw|true|"
				 "try|typeof|uint|ulong|unchecked|unsafe|ushort|using|"
				 "virtual|void|volatile|while|", p))
		return 1;
	return 0;
}

paren_follows() // is there whitespace followed by a "(" at point in buffer?
{		// if so, we assume it's a function name
	for (;; point++) {
		switch (curchar()) {
			case ' ': case '\t': case '\n':
				continue;
			case '(':		return 1;
			default:		return 0;
		}
	}
}

c_number_color(s)	// return color for number in s
char *s;		// redefine to distinguish different bases
{
	s = s;		// silence eel's warning
	return color_class c_number;
}

maybe_color_uuid()
{
	save_var case_fold = 1;		// Does it look like a quoteless uuid?
	if (!parse_string(1, "%([0-9A-F][0-9A-F][0-9A-F][0-9A-F]"
					  "[0-9A-F][0-9A-F][0-9A-F][0-9A-F]-")
		|| !parse_string(1, "%([-0-9A-F]+%)"))
		return;			// No, so keep searching.
	set_character_color(matchstart, matchstart + 1,	// Do special colors.
						color_class c_punctuation);
	set_character_color(matchstart + 1, matchend - 1,
						color_class c_number);
	set_character_color(matchend - 1, matchend,
						color_class c_punctuation);
	point = matchend;			// And move past this.
}


c_preproc_color()	// color from t to end of preprocessor text
{
	int orig = point;

	re_search(1, "[ \t]*");
	if (parse_string(1, "include")) {
		while (nl_forward() && character(point - 2) == '\\')
			;			// color contin lines
		save_var narrow_end = size() - point;
		point = orig;
		while (re_search(1, "/[*/]"))	// stop before comment
			if (!(in_c_comment(c_look_back) & IN_STRING)) {
				point -= 2;
				break;
			}
	} else if (parse_string(1, "(define|undef)[ \t]+[A-Za-z0-9_]+")) {
		point = matchend;
		point += parse_string(1, "%([A-Za-z0-9_, \t]*%)");
	} else
		re_search(1, "[A-Za-z_0-9]*");
}


drop_coloring(b)
{
	save_var bufnum = b;
	set_character_color(0, size(), -1);
	if (coloring_flags & COLOR_DO_COLORING) {
		drop_all_colored_regions();
		full_redraw = 1;
	}
	coloring_flags &= ~(COLOR_DO_COLORING | COLOR_IN_PROGRESS);
}

command change_code_coloring()
{
	want_code_coloring = has_arg ? (iter != 0) : !want_code_coloring;
	iter = 0;
	say("Code coloring %sabled for this buffer.",
	    want_code_coloring ? "en" : "dis");
	when_setting_want_code_coloring();
}

// always call the following after setting want_code_coloring variable
// set-variable calls this automatically
when_setting_want_code_coloring()
{
	when_displaying = 0;
	if (want_code_coloring)
		want_code_coloring = 1;
	if (!want_code_coloring)
		drop_coloring(bufnum);
	if (want_code_coloring && recolor_range && recolor_from_here)
		when_displaying = recolor_partial_code;
	coloring_flags &= ~(COLOR_DO_COLORING | COLOR_IN_PROGRESS);
}

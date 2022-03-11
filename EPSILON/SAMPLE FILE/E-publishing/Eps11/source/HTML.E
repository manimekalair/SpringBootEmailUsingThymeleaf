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
#include "proc.h"
#include "colcode.h"
#include "c.h"
#include "html.h"
#include "vbasic.h"

// HTML syntax highlighting.

html_recolor_from_here(safe)
{
	int start = point;

	safe = safe;			// avoid compiler warning
	if (re_search(-1, "%<%!%[CDATA%[|%]%]%>!"))
		return point;
	point = start;
	if (re_search(-1, "%<%!--|-[ \t\n]*>|%<[%?]|[%?]%>"))
		return point;
	return start;
}

// We've just parsed "<tagname ", now color any attributes before the ">".
// Script is nonzero if tag name was "script".

color_html_attributes(script, orig)
{
	int len, start, lang;

	if (script == 2)		// A <jsp:> tag.
		lang = get_html_asp_language(html_javascript_coloring);
	else if (script)
		lang = get_html_asp_language(html_other_coloring);
	while (len = parse_string(1, "[-_./a-z0-9]*")) {	// An attribute?
		if (script == 1 && parse_string(1, "(language|type)[ \t\n]*=[ \t\n]*"
							   "[\"']*(text/)?(javascript|jscript|ecmascript)"))
			lang = html_javascript_coloring;
		else if (script == 1 && parse_string(1, "(language|type)[ \t\n]*=[ \t\n]*"
							   "[\"']*(text/)?(vbscript)"))
			lang = html_vbscript_coloring;
		if (character(point + len) == ':'
			  && matches_at(point + len, 1, ":[-_./a-z0-9]*")) {
			set_character_color(point, point + len + 1, color_class html_namespace);
			point += len + 1;
			len = matchend - point;
		}
		set_character_color(point, point + len, color_class html_attribute);
		point += len;			// Followed by a value?
		if (len = parse_string(1, "[ \t\n]*=[ \t\n]*")) {
			set_character_color(point, point + len, color_class html_punctuation);
							// Color the = and whitespace.
			point += len;		// Value might be quoted.
			start = point;
			if (curchar() == '"') {
				point++;
				search(1, "\"");
			} else if (curchar() == '\'') {
				point++;
				search(1, "'");
			} else	// No quotes, assume it's whitespace-delimited.
				re_search(1, "[^ \t\n<>]*");
			set_character_color(start, point, color_class html_value);
		}
		re_search(1, "[ \t\n]*");	// Parse whitespace.
		set_character_color(matchstart, matchend, color_class html_punctuation);
	}
	if (curchar() == '>') {
		set_character_color(point, point + 1, color_class html_punctuation);
		point++;
	}
	start = point;
	if (script && !parse_string(-1, "/%>")) {
		if (re_search(1, script == 2 ? "%</jsp:.*%>" : "%</script%>")) {
			set_tagged_region("color-as-unit", orig, point, 99);
			point = matchstart;
		} else
			set_tagged_region("color-as-unit", orig, point, 99);
		color_embedded_code(start, point, lang);
	}
}

// Color this region as Java or VBScript code, or plain.

color_embedded_code(from, to, lang)
{
	save_var point;
	save_var narrow_start = from;
	save_var narrow_end = size() - to;
	set_tagged_region("color-as-unit", from, to, lang);
	if (lang == 1) {
		save_var c_extra_keywords |= JAVA_KEYWORDS;
		save_var recolor_range = color_c_range;
		save_var recolor_from_here = color_c_from_here;
		color_for_narrowed_area(from, to);
	} else if (lang == 2) {
		save_var recolor_range = color_vbasic_range;	// set up coloring rules
		save_var recolor_from_here = recolor_by_lines;
		save_var sublanguage_code = SUBLANG_VBSCRIPT;
		color_for_narrowed_area(from, to);
	} else
		set_character_color(from, to, color_class html_attribute);
}

// An HTML comment starts here.  Color it appropriately.
// HTML comments start with <!.  If there's a - immediately after,
// then this is probably a legal HTML comment like <!-- Comment -->
// so search for -> (this allows commenting out HTML code).
// Otherwise, it's not a "standard" comment (might be a legal DOCTYPE
// spec, or a valid <!>, or an illegal comment).  In any case,
// assume it ends at the next >.

color_html_comment()
{
	int s;

	search(-1, "<");	// Find start of comment.
	s = point;
	if (parse_string(1, "%<%!%[CDATA%[")) {	// xml cdata
		re_search(1, "%]%]%>");
		set_character_color(s, point, color_class html_value);
		return;
	} else if (parse_string(1, "%<[ \t\n]*%![ \t\n]*--?")) {
		// A legal comment?
		point = matchend;
		re_search(1, "-[ \t\n]*>");	// Search for end of legal comment.
	} else	// Some odd flavor of comment; don't be too picky about its end.
		search(1, ">");
	set_character_color(s, point, color_class html_comment);
}

get_html_asp_language(int def)
{
	save_var point = 0;
	if (re_search(1, "%<(%%@|jsp:directive.page)[^>]*</word>Language=[\"']?")) {
		if (parse_string(1, "VBScript"))
			return 2;
		if (parse_string(1, "(java|j|ecma)script"))
			return 1;
	}
	return def;
}

// Color text delimited by <% and %>.

color_html_include()
{
	int s, t, c, lang;
	char *end;

	search(-1, "<");	// Find start of include.
	c = character(point + 1);
	s = point;
	switch (c) {
		case '%':	point += parse_string(1, "%<%%[a-z0-9]*");
					end = "%>";
					lang = get_html_asp_language(html_asp_coloring);
					break;
		case '?':	point += parse_string(1, "%<%?[a-z0-9]*");
					end = "?>";
					lang = html_php_coloring;
					break;
		default:	point++;
					end = ">";
					lang = get_html_asp_language(html_asp_coloring);
					break;
	}
	t = point;
	set_character_color(s, point, color_class html_attribute);
	search(1, end);
	set_character_color(matchstart, point, color_class html_attribute);
	set_tagged_region("color-as-unit", s, point, 99);
	color_embedded_code(t, matchstart, lang);
}

// Say if point is possibly inside some quoted attribute value like
// alt="1<2".  In such places <'s don't start tags.

// Look for the previous quote character of each type.  If there's a =
// before either one, and it looks like part of a tag, return 1 and
// move to the start of that tag.  Otherwise don't move and return 0.

html_in_quoted_attribute()
{
	if (!parse_string(-1,
					  "%<" HTML_NAME "([ \t\n]+" HTML_ATTRIBUTE ")*"
					  "[ \t\n]+" HTML_NAME HTML_EQUALS
					  "('[^']*|\"[^\"]*)"))
		return 0;
	point = matchend + 1;
	return 1;
}

// Don't start coloring from inside <>'s or in script sections, since
// we won't do it right.  Move point back to a good place.  Look back
// for openers <script, <? or <% or closers </script, ?> or %>.  If we
// found an opener, start from there.  Otherwise, move back before the
// nearest good <.  We also return codes indicating what we found.

color_html_move_back()
{
	int start = point, p;

	save_var narrow_start = point - color_html_look_back;
	if (re_search(-1, "%<%!%[CDATA%[|%]%]%>")
		  && !parse_string(-1, "%<script[^<]*%><wspace>*"))
		if (curchar() == '<')
			return 1;
		else {
			point += parse_string(1, "%]%]%>");
			return -1;
		}
	point = start;
	if (re_search(-1, "<Langle>[ \t\n]*/?script")
		&& parse_string(1, "<Langle>[ \t\n]*script"))
		return 2;				// Found a <script>, not a </script>.
	point = start;
	if (re_search(-1, "<Langle>[%?]|[%?]<Rangle>")
		&& curchar() == '<')
		return 3;				// Found a <% or <?, not a %> or ?>.
	point = start;
	do {			// start coloring from the previous tag
		if (!search(-1, "<"))
			break;	// but ignore <'s before " or ' characters
		if (get_character_color(point, &p, NULL) == color_class html_comment) {
			point = p + 2;	// If we're in a comment,
			search(-1, "<!");	// go back to its start.
		}
	} while (html_in_quoted_attribute());
	return 0;
}

color_html_range(from, to) // recolor just this section
{			// last colored region may go past to
	int s, script, t, i;

	if (from >= to)
		return to;
	save_var point, matchstart, matchend;
	if (from < to) {
		set_character_color(from, to, color_class html_text);
		set_tagged_region("needs-color", from, to, -1);	// Say it needs coloring.
	}
	point = from;
	save_var case_fold = 1;
	color_html_move_back();
	while (point > narrow_start
		   && get_tagged_region("color-as-unit", point - 1, &from) != -1)
		point = from;		// Move before script areas.
	if (to > size() - narrow_end)
		to = size() - narrow_end;
	set_tagged_region("color-as-unit", from, to, -1);
	for (s = point; point < to; ) {
		if (curchar() == '&') {
			set_character_color(s, point, color_class html_text);
			s = point++;	 // Color an entity like &amp; or &#251;
			if (parse_string(1, "([a-z]+|#[0-9]+|#x[0-9a-f]+);?"))
				point = matchend;
			set_character_color(s, point, color_class html_entity);
			s = point;
			continue;
		}
		if (curchar() != '<') {
			point++;
			continue;
		}
		set_character_color(s, point, color_class html_text);
		i = t = point++;
		while (strchr(" \t\n", curchar()))
			point++;	// Parse < followed by whitespace.
		set_character_color(t, point, color_class html_punctuation);
		if (curchar() == '!')
			color_html_comment();
		else if (strchr("%?", curchar()))
			color_html_include();
		else if (s = parse_string(1, "[-_./a-z0-9]*")) { // Parse the tag.
			set_character_color(point, point + s, color_class html_tag);
			script = (s == 6 && parse_string(1, "script"));
			if (s == 3 && parse_string(1, "jsp:(declaration|expression"
									   "|scriptlet)</word>"))
				script = 2;
			point += s;			// Look for javascript tag.
			if (curchar() == ':' && parse_string(1, ":[-_./a-z0-9]*")) {
				set_character_color(point - s, point + 1,
									color_class html_namespace);
				set_character_color(point + 1, matchend,
									color_class html_tag);
				point = matchend;
			}
			for (i = point; strchr(" \t\n", curchar()); )
				point++;	// Parse whitespace.
			set_character_color(i, point, color_class html_punctuation);
			color_html_attributes(script, t);
		}
		s = point;
	}
	re_search(1, "![<&]");
	if (s < point)
		set_character_color(s, point, color_class html_text);
	set_tagged_region("needs-color", from, point, 0);	// Say it's colored.
	return point;
}

// Search forward on line from here for link, set file to its name.
// Abort if none.
html_find_linked_file(char *file)
{
	char buf[FNAMELEN], *p;
	int orig;

	if (!re_search(1, "href[ \t\n]*=[ \t\n]*")) {
		to_begin_line();
		if (!re_search(1, "href[ \t\n]*=[ \t\n]*"))
			error("Can't find any link here.");
	}
	orig = point;
	if (curchar() == '"') {
		point++, orig++;
		search(1, "\"");
	} else if (curchar() == '\'') {
		point++, orig++;
		search(1, "'");
	} else	// No quotes, assume it's whitespace-delimited.
		re_search(1, "[^ \t\n<>]*"), point++;
	grab(orig, point - 1, buf);		// Get link from buffer.
	p = strchr(buf, '#');		// Remove #fragment if any.
	if (p)
		*p = 0;
	if (!*buf)
		error("Can't follow fragment links.");
	point = orig;
	if (!parse_string(1, "[a-z]+:")) {		// A relative URL.
		strcpy(file, filename);
		strcpy(get_tail(file, 1), buf);
	} else						// An absolute URL.
		strcpy(file, buf);
}

/*
Move in direction dir past a matched pair of characters in HTML buffers.
On success, or if the end of the buffer is encountered before the
first character is found, return the new buffer position.
Otherwise return -1.
Maybe this routine should consider <a> and </a> to be delimiters,
instead of < and >.
*/

html_move_level(int dir, int stop_on_key)
{
	char *findch = (dir > 0) ? "<" : ">";
	char *otherch = (dir < 0) ? "<" : ">";

	recolor_buffer_range(point, point + 1);
	switch (get_tagged_region("color-as-unit", point - (dir < 0))) {
		case 1:
			return c_move_level(dir, stop_on_key);
		case 2:
			findch = (dir > 0) ? "[({" : "])}";
			otherch = (dir < 0) ? "[({" : "])}";
			break;
	}
	return default_move_level(dir, findch, otherch);
}

// Narrowing may not have excluded the <script line itself, so do it
// now.
html_exclude_script_head()
{
	save_spot point = narrow_start;
	if (parse_string(1, "<langle>[%?][a-z0-9]*"))
		point = matchend;
	else if (parse_string(1, "<Langle>[ \t\n]*script"))
		search(1, ">");
	if (parse_string(1, "%<%!--"))
		point = matchend;
	if (parse_string(1, "%<%!%[CDATA%["))
		point = matchend;
	narrow_start = point;
}

html_indent() on html_tab['\t']
{
	int region, start;

	region = get_tagged_region("color-as-unit", point, &start);
	if (IS_ENTER_KEY(key) && !(html_auto_indent &
							   (region == 1 ? 2 : region == 2 ? 4 : 1)))
		return;
	save_var narrow_start = start;
	switch (region) {
		case 1:
			html_exclude_script_head();
			save_var c_extra_keywords |= JAVA_KEYWORDS;
			do_c_indent();
			return;
		case 2:
			html_exclude_script_head();
			do_vbasic_indent();
			return;
	}
	indent_previous();
}

html_redirect_active_key() on html_tab['{'], html_tab['}'], html_tab[')'],
							  html_tab[']'], html_tab[':'], html_tab['#']
{
	int region, start, end, f = 0;
	short *tab = 0;

	recolor_buffer_range(point, point + 1);
	region = get_tagged_region("color-as-unit", point, &start, &end);
	switch (region) {
		case 1:
			save_var auto_show_matching_characters = c_auto_show_delim_chars;
			save_var mode_move_level = c_move_level;
			tab = c_tab;
			break;
		case 2:
			save_var auto_show_matching_characters = vbasic_auto_show_delim_chars;
			save_var mode_move_level = 0;
			tab = vbasic_tab;
			break;
	}
	if (tab)
		f = binding_of(key, tab);
	if (f > 0) {
		save_var narrow_start = start, narrow_end = size() - end;
		html_exclude_script_head();
		save_var Matchdelim = 0;	// Don't refresh while we're narrowed.
		do_command(f);
		return;
	}
	normal_character();
}

html_fill_paragraph() on html_tab[ALT('q')]
{
	int region, start, end;

	recolor_buffer_range(point, point + 1);
	region = get_tagged_region("color-as-unit", point, &start, &end);
	switch (region) {
		case 1:
			save_var major_mode = _c_mode_name;
			fill_comment();
			return;
		case 2:		// Can't fill vbscript block comments in html yet.
			break;
	}
	fill_paragraph();
}

int html_auto_show_delimiter()
{
	int region, start, end;

	save_var point;
	region = get_tagged_region("color-as-unit", point, &start, &end);
	save_var narrow_start = start, narrow_end = size() - end;
	switch (region) {
		case 1:
			html_exclude_script_head();
			save_var auto_show_matching_characters = c_auto_show_delim_chars;
			save_var mode_move_level = c_move_level;
			break;
		case 2:
			html_exclude_script_head();
			save_var auto_show_matching_characters = vbasic_auto_show_delim_chars;
			save_var mode_move_level = 0;
			break;
	}
	return default_auto_show_delimiter();
}

command html_mode()
{
	mode_default_settings();
	mode_keys = html_tab;		/* Use these keys. */
	major_mode = _html_mode_name;

	strcpy(comment_start, "%<%!-- *");
	strcpy(comment_pattern, "%<%!--(.|<newline>)*--%><FirstEnd>");
	strcpy(comment_begin, "<!-- ");
	strcpy(comment_end, " -->");
	indenter = html_indent;
	auto_indent = 1;
	mode_move_level = html_move_level;
	if (auto_show_html_delimiters)
		auto_show_matching_characters = html_auto_show_delim_chars;
	mode_auto_show_delimiter = html_auto_show_delimiter;
	recolor_range = color_html_range;	// set up coloring rules
	recolor_from_here = html_recolor_from_here;
	idle_coloring_size = 5000;
	if (want_code_coloring)		// maybe turn on coloring
		when_setting_want_code_coloring();
	try_calling("html-mode-hook");
	drop_all_colored_regions();
	make_mode();
}

// Automatically go into HTML mode on .htm, .html files.

suffix_htm()
{
	html_mode();
}

suffix_html()
{
	html_mode();
}

suffix_shtml()
{
	html_mode();
}

// .cfm and .cfml are HTML variants for Cold Fusion by Allaire.

suffix_cfml()
{
	html_mode();
}

suffix_cfm()
{
	html_mode();
}

// .htx is an HTML variant for Microsoft's Internet Database Connector.

suffix_htx()
{
	html_mode();
}

// .asp and .asa are HTML variants for Microsoft's web server.

suffix_asp()
{
	html_mode();
}

suffix_asa()
{
	html_mode();
}

// Recognize XML and related extensions.

suffix_xml()
{
	html_mode();
}

suffix_cdf()
{
	html_mode();
}

suffix_osd()
{
	html_mode();
}

suffix_htt()
{
	html_mode();
}

suffix_wml()
{
	html_mode();
}

suffix_xsl()		// XML style sheet
{
	html_mode();
}

suffix_xst()		// XML script
{
	html_mode();
}

suffix_xsd()		// W3 Schema for XML
{
	html_mode();
}

suffix_jsp()		// Java server page
{
	html_mode();
}

suffix_php()		// PHP server-side page
{
	html_mode();
}

suffix_php3()		// PHP server-side page
{
	html_mode();
}

suffix_php4()		// PHP server-side page
{
	html_mode();
}

suffix_sgml()		// Generic SGML file.
{
	html_mode();
}

suffix_sgm()
{
	html_mode();
}

suffix_svg()
{
	html_mode();
}

/************************************************************************
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

#include "eel.h"
#include "proc.h"
#include "colcode.h"

char _asm_mode_name[] = "Asm";
keytable asm_tab;			/* key table for asm mode */
user char compile_asm_cmd[128] = "ml \"%r\""; // assemble this file

color_asm_range(from, to) // recolor just this section
{			// last colored region may go past to
	int t = -1, talk, s;

	if (from >= to)
		return to;
	save_var point, matchstart, matchend;
	c_init_color(from, to);
	point = from;
	talk = (to - from > 2000);	// show status during long delays
	while (point < to) {
		if (!re_search(1, "[0-9A-Za-z_.%]+|[\"';]")) {
			t = size();
			break;
		}
		t = matchstart;
		switch (character(point - 1)) {		// check last char
			case ';':			// found comment
				nl_forward();
				set_character_color(t, point, color_class c_comment);
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
				set_character_color(t, point, asm_keyword_color(t));
				break;
		}
		if (talk)
			note("Coloring ASM program: %d%% complete...",
				 muldiv(point - from, 100, to - from));
	}
	c_init_color(to, t);
	if (talk)
		note("");
	return point;
}

asm_keyword_color(from)	// return color for "identifier" from here to point
{			// (something with alpha or digits)
	char buf[500];

	if (point - from > sizeof(buf) - 10)
		save_var point = from + sizeof(buf) - 10;
	buf[0] = '|';		// get identifier, between | chars
	grab(from, point, buf + 1);
	if (index("0123456789-", buf[1]) || buf[1] == '.' && isdigit(buf[2]))
		return c_number_color(buf + 1);
	strcpy(buf + point - from + 1, "|");
	if (is_asm_keyword(buf))
		return color_class asm_keyword;
	if (is_asm_register(buf))
		return color_class asm_register;
	return color_class asm_identifier;
}

is_asm_keyword(p)	// is text in p (must be surrounded by |'s) a keyword?
char *p;
{
	if (strstr("|add|and|at|byte|call|cbw|cli|cmp|code|common|cwd|cwde|"
			   "dec|dup|dword|eq|far|far16|far32|flat|fword|ge|gt|high|"
			   "highword|inc|int|iret|iretd|ja|jae|jb|jbe|jcxz|je|", p))
		return 1;
	if (strstr("|jecxz|jg|jge|jl|jle|jmp|jne|jno|jnp|jns|jnz|jo|jp|js|le|"
			   "lea|leave|length|lengthof|loop|loopd|loopde|loopdne|loope|"
			   "loopne|loopw|loopwe|loopwne|low|lowword|lroffset|lt|", p))
		return 1;
	if (strstr("|mask|memory|mod|mov|movsx|movzx|ne|near|near16|near32|"
			   "nop|not|offset|opattr|or|page|para|pop|private|proc|ptr|"
			   "public|push|qword|real10|real4|real8|ret|sbyte|", p))
		return 1;
	if (strstr("|sdword|seg|shl|shld|short|shr|size|sizeof|stack|sti|"
			   "sub|sword|tbyte|test|this|type|use16|use32|width|"
			   "word|xor|equ|textequ|", p))
		return 1;
	if (strstr("|%depth|%incl|%linum|%noincl|%nomacs|%notrunc|%out|"
			   ".186|.errnz|.lall|.model|abs|adc|align|assume|cld|"
			   "compact|db|dd|dw|else|elseif|elseifdef|elseifndef|end|"
			   "endif|endm|ends|err|extrn|huge|if|if1|if2|ifb|ifdef|ife|"
			   "ifidni|ifnb|ifndef|include|jnz|jz|label|large|local|macro|"
			   "masm51|medium|nothing|nowarn|org|popa|popf|pusha|pushf|"
			   "quirks|rep|repe|sbb|scasw|segment|show|small|stosw|subttl|"
			   "tiny|title|warn|xchg|", p))
		return 1;
	return 0;
}

is_asm_register(p)	// is text in p (must be surrounded by |'s) a reg name?
char *p;
{
	if (strstr("|ah|al|ax|bh|bl|bx|ch|cl|cx|dh|dl|dx|eax|ebp|ebx|ecx|"
			   "edi|edx|esi|esp|bp|cs|ds|es|fs|gs|di|si|sp|ss|", p))
		return 1;
	return 0;
}

command asm_mode()
{
	mode_default_settings();
	mode_keys = asm_tab;		/* Use these keys. */
	major_mode = _asm_mode_name;
	compile_buffer_cmd = compile_asm_cmd;	// can compile this
	strcpy(comment_start, ";[ \t]*");
	strcpy(comment_pattern, ";.*$");
	strcpy(comment_begin, "; ");
	strcpy(comment_end, "");
	recolor_range = color_asm_range;	// set up coloring rules
	recolor_from_here = recolor_by_lines;
	if (want_code_coloring)		// maybe turn on coloring
		when_setting_want_code_coloring();
	try_calling("asm-mode-hook");
	drop_all_colored_regions();
	make_mode();
}

suffix_asm()
{
	asm_mode();
}

suffix_mac()
{
	asm_mode();
}

suffix_asi()
{
	asm_mode();
}

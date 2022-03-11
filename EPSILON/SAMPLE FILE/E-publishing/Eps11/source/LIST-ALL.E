/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1987, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

/*
Loading this file generates a list of commands, macros, bindings,
etc. defined in Epsilon.  It's especially useful when updating to a
new version of Epsilon, if you're not sure what changes you've made
to your state file.

Starting in version 7.0, the current definition of this command is in
the file store.e.  This file is provided for users updating from very
old versions of Epsilon (older than version 3.2) without a built-in
list-all command.

To locate changes in old versions of Epsilon, move the line below
marked CLOSING above all the #define lines that apply, so those lines
are outside this comment.  In versions prior to 3.1, no variable
values will be reported.

#define PRE_V3_1
#define PRE_V3_3
#define PRE_V5_0
#define PRE_V6_0
#define PRE_V6_1
**** CLOSING ****/

#include "eel.h"

#ifdef PRE_V6_0
#define noteput		sayput
#endif

list_all_macro(m)	/* insert cmd-file format macro text in buffer */
short *m;
{
	char tmp[20];
	int i, prev;

	stuff("\"");
	for (i = 1; i < m[0]; i++)
		switch (m[i]) {
			case '-':	prev = character(point - 1);
					if (index("ACSFMN", prev))
						insert('\\');
				/* "F-1" in text resembles special key */
			default:	tmp[0] = 0;	/* fall through */
					show_char(tmp, m[i]);
					stuff(tmp);
					break;
			case CTRL('\\'):
					stuff("C-\\\\"); break;
			case ALT(CTRL('\\')):
					stuff("C-A-\\\\"); break;
			case ALT('<'):
			case ALT('"'):
			case ALT('\\'):	stuff("A-");	/* fall through */
			case '<':		/* quote these */
			case '"':
			case '\\':	insert('\\');
					insert(m[i] & 0x7f);
					break;
		}
	stuff("\"");
}

when_loading()
{
	int i, j, last, val, type, max = final_index();
	char tabname[80], *p, *nm, *tname;
	short *k, onekey[2];

	onekey[0] = 2;
	noteput("Describing state...");
	zap("list-all");
	to_buffer("list-all");
	for (i = 1; i <= max; i++) {
		check_abort();
		nm = name_name(i);
		noteput("Describing state...%s", nm);
		switch (name_type(i)) {
		case NT_COMMAND:
#ifndef PRE_V6_1
		case NT_AUTOLOAD:
#endif
			bprintf("%s: command\n", nm); break;
		case NT_SUBR:
#ifndef PRE_V6_1
		case NT_AUTOSUBR:
#endif
			bprintf("%s: subroutine\n", nm); break;
		case NT_MACRO:
			bprintf("%s: macro ", nm);
			list_all_macro(get_macro(i));
			insert('\n');
			break;
		case NT_TABLE:
			bprintf("%s: table\n", nm);
			strcpy(tabname, nm);
			k = index_table(i);
			for (j = 0; j < NUMKEYS; j++) {
				if (k[j] <= 0)
					continue;
				bprintf("~%s ", tabname);
				onekey[1] = j;
				list_all_macro(onekey);
				bprintf(": %s\n", name_name(k[j]));
			}
			break;
#ifndef PRE_V5_0
		case NT_WINVAR:
#endif
		case NT_BUFVAR: case NT_VAR:
#ifdef PRE_V3_1
			bprintf("%s %svariable\n", nm,
				(name_type(i) == NT_BUFVAR) ? "buffer " : "");
#else			/* if epsilon 3.1 or higher */
			use_default = 1;
			p = varptr(i);
			type = 0;
			switch (vartype(i)) {
				case TYPE_CHAR:	val = *(char *) p;
						tname = "char ";
						break;
				case TYPE_SHORT: val = *(short *) p;
						tname = "short ";
						break;
				case TYPE_INT:	val = *(int *) p;
						tname = "int ";
						break;
				case TYPE_CPTR:	tname = "char ptr ";
						type = 2; break;
				case TYPE_CARRAY: tname = "char array ";
						type = 1; break;
				default:	tname = ""; type = 2; break;
			}
			bprintf("+%s %s%svariable", nm,
#endif
#ifndef PRE_V5_0
					(name_type(i) == NT_WINVAR)
					? "window " :
#endif
#ifndef PRE_V3_1
					(name_type(i) == NT_BUFVAR)
					? "buffer " : "", tname);
			if (type == 0)
				bprintf(": %d\n", val);
			else if (type == 2)
				stuff(": <complex>\n");
			else {
#endif
#ifdef PRE_V3_3
				stuff(": \"");
				for (j = 0; p[j]; j++)
#else
				last = ptrlen(p);
				bprintf(": %d \"", last);
				while (last > 0 && !p[last - 1])
					last--;
				for (j = 0; j < last; j++)
#endif
#ifndef PRE_V3_1
					switch (p[j]) {
					case '\t':	stuff("\\t"); break;
					case '\r':	stuff("\\r"); break;
					case '\n':	stuff("\\n"); break;
					case '\\':
					case '"':	insert('\\');
					default:	insert(p[j]); break;
					}
				stuff("\"\n");
			}
			use_default = 0;
#endif
			break;
#ifndef PRE_V6_0
		case NT_COLSCHEME:
			p = varptr(i);
			for (j = 0; j < number_of_color_classes(); j++)
				bprintf("&%s color class for %s: 0x%x\n",
					nm, name_color_class(j), p[j]);
			break;
#endif
		}
	}
	point = 0;
	say("");
#ifndef PRE_V5_0
	drop_name("list-all-macro");	/* remove helper func above */
#endif
}

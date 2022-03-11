/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1986, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

// This file modifies the table that determines how Epsilon
// interprets keys (in DOS, which keys Epsilon passes on to the BIOS).

#include "eel.h"

when_loading()
{
	short *real_key = keytran;
	short *temp_keytran = 0;
	int i, j, buf, win;
	char key1[80], key2[80], msg[80];
	jmp_buf *old_level = top_level, this_level;

	buf = zap("select-keyboard");
	win = add_popup(1, 0, 78, 24, ALL_BORD(BSINGLE), buf);
	text_color = (is_gui && want_gui_prompts) ? color_class text : color_class viewed_text;
	stuff("\
Under DOS, this program makes Epsilon compatible with those keyboard\n\
enhancement programs that use some of the same undefined key combinations\n\
that Epsilon uses.  The programs, and the keys in conflict, are:\n\
\n\
1) Microsoft Windows, DOS Shell, OS/2 Dos Box: Alt-Tab, Ctrl-Esc, Alt-Esc\n\
2) Superkey: Alt-/, Alt-\\, Alt-', Alt-`, Alt-PrtScr, Alt-Esc\n\
3) Prokey: Alt-/                  4) Ready: Ctrl-5, Shift-Ctrl-5\n\
5) Spotlight: Alt-Shift-<letters>, Alt-Shift-Enter\n\
\n\
By default these are bindable keys in Epsilon, but are unavailable to\n\
the keyboard enhancement program.  Press 1, 2, 3, 4, or 5 to let the\n\
corresponding program get the keys it uses.  These keys will then be\n\
unavailable to Epsilon.\n\
\n\
A) Disable entering graphics characters with Alt-<Numeric Keypad key>\n\
   so commands may be bound there (where supported).\n\
I) Modify individual keys.  A translation of -2 means to ignore the key,\n\
   and -1 means to use the untranslated value (under DOS, pass it to BIOS).\n\
D) Remove all these changes, restoring Epsilon to its Default state.\n\
\n\
Press Q when you're done.  All these changes will last until you exit\n\
Epsilon, but you can use the write-state command to make them permanent.\n");

	display_column = point = 0;
	sayput("Press 1-5, A, I, D, or Q to exit: ");
	top_level = &this_level;
	if (setjmp(top_level)) {	/* on exit, clean up */
		top_level = old_level;
		if (temp_keytran)
			free(temp_keytran);
		remove_window(win);
		buf_delete(buf);
		show_binding("To remember these changes for "
			"future sessions, use %s.", "write-state");
		return;
	}
	for (;;) {
		maybe_refresh();
		getkey();
		say("");
		switch (toupper(key)) {
		case 'Q': case 'X':
		case '0':	longjmp(top_level, 1);
		case '1':	keytran[NUMALT(GREYTAB)] = -1;
				keytran[NUMALT(GREYESC)] = -1;
				keytran[NUMCTRL(GREYESC)] = -1;
				sayput("Compatible with Microsoft Windows, "
					"DOS Shell, OS/2 Dos Box.");
				break;

		case '2':	keytran[0] = 0;	/* superkey mishandles null */
				keytran[ALT('/')] = -1;
				keytran[ALT('\\')] = -1;
				keytran[ALT('\'')] = -1;
				keytran[ALT('`')] = -1;
				keytran[NUMALT(GREYSTAR)] = -1;
				keytran[NUMALT(GREYESC)] = -1;
				sayput("Compatible with Superkey.");
				break;

		case '3':	keytran[ALT('/')] = -1;
				sayput("Compatible with Prokey.");
				break;

		case '4':	keytran[NUMCTRL(NUMDIGIT(5))] = -1;
				sayput("Compatible with Ready.");
				break;

		case '5':	for (i = 'A'; i <= 'Z'; i++)
					keytran[ALT(i)] = -1;
				keytran[NUMALT(GREYENTER)] = -1;
				sayput("Compatible with Spotlight.");
				break;

		case 'A':	for (i = 0; i <= 9; i++)
					keytran[NUMALT(NUMDIGIT(i))] = NUMALT(NUMDIGIT(i));
				sayput("Alt-Numpad now produces individual keys, not keys by numeric code.");
				break;

		case 'I':
			if (!temp_keytran) {
				sayput("Wait...");
				temp_keytran = (short *)
					malloc(sizeof(short) * NUMKEYS);
				for (i = 0; i < NUMKEYS; i++)
					temp_keytran[i] = i;
			}
			keytran = temp_keytran;
			sayput("Enter key to see: ");
			getkey();
			j = key;
			keytran = real_key;
			*key1 = *key2 = 0;
			show_char(key1, j, 1);
			if (keytran[j] == -1)
				strcpy(key2, "<tobios>");
			else if (keytran[j] == -2)
				strcpy(key2, "<ignore>");
			else if (keytran[j] >= KEYTRANPASS) {
				strcpy(key2, "bios-");
				show_char(key2, keytran[j] - KEYTRANPASS, 1);
			} else
				show_char(key2, keytran[j], 1);
			sayput("Key %s, #%d is translated to %s, #%d - "
				"change? [n] ", key1, j, key2, keytran[j]);
			do getkey(); while (!IS_TRUE_KEY(key));
			user_abort = 0;
			sprintf(msg, "New translation for %s, code %d? ",
					key1, j);
			if (tolower(key) == 'y') {
				get_string(key2, msg);
				if (*key2)
					keytran[j] = numtoi(key2);
			}
			*key2 = 0;
			if (keytran[j] == -1)
				strcpy(key2, "<tobios>");
			else if (keytran[j] == -2)
				strcpy(key2, "<ignore>");
			else if (keytran[j] >= KEYTRANPASS) {
				strcpy(key2, "bios-");
				show_char(key2, keytran[j] - KEYTRANPASS, 1);
			} else
				show_char(key2, keytran[j], 1);
			say("Key %s, #%d is translated to %s, #%d",
				key1, j, key2, keytran[j]);
			break;

		case 'D':	/* insert code to make standard keytran */
#include "keydef.h"
			sayput("All keys are now bindable.");
			break;
		default:
			sayput("Press Q to exit.");
			break;
		}
	}
}

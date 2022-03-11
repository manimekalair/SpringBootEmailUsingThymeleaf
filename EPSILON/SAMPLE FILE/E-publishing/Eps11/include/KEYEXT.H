/************************************************** -*- tab-width:4 -*- *
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1986, 1995 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

/* Do keytran setup that depends on value of kbd_extended, the -ke flag. */

{
	int num = 0, cursor, tmp;
	char *p;

   if (kbd_extended != _prev_kbd_extended) {
	for (tmp = NUMDIGIT(0); tmp <= KEYDELETE; tmp++)
		keytran[NUMCTRL(tmp)] = kbd_extended ? -1 : NUMCTRL(tmp);
	for (cursor = KEYINSERT; cursor <= KEYDELETE; num++, cursor++) {
		if (num == 5)		/* no cursor key for N-5 */
			num++;
		keytran[NUMDIGIT(num)] = kbd_extended ? -1
					: KEYTRANPASS + cursor;
		keytran[NUMSHIFT(NUMDIGIT(num))] = kbd_extended ? -1
					: KEYTRANPASS + cursor;
		tmp = KEYTRANPASS;
		switch (num) {	/* no old-style ctrl versions of these */
			case 0: case 2: case 8: case 10: tmp = 0;
		}
		keytran[NUMCTRL(NUMDIGIT(num))] = kbd_extended ? -1
				: tmp + NUMCTRL(cursor);
		tmp = NUMALT(NUMDIGIT(num));
		if (keytran[tmp] >= 0)	/* if we're keeping A-N- keys */
			keytran[tmp] = kbd_extended ? tmp : NUMALT(cursor);
		keytran[NUMALT(cursor)] = NUMALT(cursor);
							/* Shift-Arrow maps to Arrow */
		if (cursor != KEYINSERT && cursor != KEYDELETE)
			keytran[NUMSHIFT(cursor)] = KEYTRANPASS + cursor;
	}
	keytran[NUMSHIFT(KEYINSERT)] = NUMSHIFT(KEYINSERT);
	keytran[NUMSHIFT(KEYDELETE)] = NUMSHIFT(KEYDELETE);
	keytran[NUMSHIFT(NUMDIGIT(0))] = kbd_extended ? -1
		: KEYTRANPASS + NUMSHIFT(KEYINSERT);
	keytran[NUMSHIFT(NUMDOT)] = kbd_extended ? -1
		: KEYTRANPASS + NUMSHIFT(KEYDELETE);
	keytran[NUMDIGIT(5)] = kbd_extended ? -1 : NUMDIGIT(5);
	for (tmp = 11; tmp <= 12; tmp++) {
		keytran[FKEY(tmp)] = kbd_extended ? -1 : FKEY(tmp);
		keytran[FSHIFT(tmp)] = kbd_extended ? -1 : FSHIFT(tmp);
		keytran[FCTRL(tmp)] = kbd_extended ? -1 : FCTRL(tmp);
		keytran[FALT(tmp)] = kbd_extended ? -1 : FALT(tmp);
	}
	for (p = "',./;[\]`"; *p; p++)
		keytran[ALT(*p)] = kbd_extended ? -1 : ALT(*p);
	keytran[NUMCTRL(GREYBACK)] = DEL;
	keytran[NUMCTRL(GREYENTER)] = '\n';
    }
    _prev_kbd_extended = kbd_extended;
}

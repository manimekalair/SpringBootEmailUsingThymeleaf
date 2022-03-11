/************************************************** -*- tab-width:4 -*- *
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

/* This file sets up the keytran array in its default configuration. */

{
	int k, tk;

	for (k = 0; k < NUMKEYS; k++)	/* send all keys through */
		keytran[k] = -1;

	for (k = 256; k < 512; k++)	/* except regular alt keys */
		keytran[k] = k;
	for (k = 'a'; k <= 'z'; k++)	/* but send alt-letter */
		keytran[ALT(k)] = -1;
	for (k = '0'; k <= '9'; k++)	/* and alt-digit */
		keytran[ALT(k)] = -1;
	keytran[ALT('-')] = keytran[ALT('=')] = -1; /* and others through */

		/* do normal processing of alt versions of numeric or grey keys */
	for (k = NUMALT(NUMDIGIT(0)); k <= NUMALT(NUMDIGIT(9)); k++)
		keytran[k] = -1;
	keytran[NUMALT(NUMDOT)] = NUMALT(NUMDOT);
	for (k = GREYPLUS; k <= GREYSLASH; k++) {
		tk = "+-*\r\b\t\x1B/"[k - GREYPLUS];
		keytran[NUMALT(k)] = ALT(tk);	/* and don't send these */
		keytran[k] = tk + KEYTRANPASS;
	}
	keytran[0] = 0;
			/* load part that depends on -ke flag */
	_prev_kbd_extended = 100;	/* make sure it always sets up */
#include "keyext.h"
}

/************************************************** -*- tab-width:4 -*- *
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*	Copyright (C) 1999, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

keytable hex_tab;
char _hex_mode_name[] = "Hex";
char _hex_overtype_mode_name[] = "Hex Overtype";
user char hex_overtype_mode;	// Set to 1 to start in overtype submode.

#define HEX_CHARS			"0123456789ABCDEF"
#define HEX_BUFNAME_PREFIX	"Hex Dump of "

color_class hex_address;
color_class hex_ascii;
color_class hex_change;

/************************************************** -*- tab-width:4 -*- *
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

#define INFO_BUF		"-info"			/* info files go here */
#define INFO_HISTORY	"-info-history"	/* history of visited nodes */
#define INFO_INDEX		"-info-index"	/* last index cmd gave these matches */

// Unix paths use : as a separator, non-Unix uses ; separator.
user char info_path_unix[FNAMELEN] = "/usr/local/lib/info:/usr/local/info:/usr/info";
user char info_path_non_unix[FNAMELEN] = "%x..\\info;%x";

char _info_mode_name[] = "Info";
keytable info_tab;			/* key table for info mode */
#define INFO_CSTR	"\x1F"	/* node separator */
zeroed char info_recovering;		// Prevent failures from recursing.

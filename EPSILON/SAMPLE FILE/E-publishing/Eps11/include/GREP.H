/************************************************** -*- tab-width:4 -*- *
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1988, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

char _grep_mode_name[] = "Grep";
#define BUFPREFIX	"(Buffer) "
user char grep_ignore_file_extensions[FNAMELEN] = "|.obj|.exe|.o|.b|.dll|.lib|";
user char use_grep_ignore_file_extensions = 1;
user char grep_default_directory = 0;

color_class grep_text;
color_class grep_match;
color_class grep_filename;
color_class grep_header;

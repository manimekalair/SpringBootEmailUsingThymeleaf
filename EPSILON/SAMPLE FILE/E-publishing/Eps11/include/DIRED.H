/************************************************** -*- tab-width:4 -*- *
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1985, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

#define DIRMARK		"<DIR>"
#define DIRSEARCH	" %<DIR%> " /* search for this regex to find dirs */
char dired_dirsearch_unix[] = "^. [dl]";
char dired_dirsearch_simple[] = "^. ([^ \n/]+/|.* -> )";
char dired_dirsearch_vms[] = "^. .*%.DIR;";
char dired_dirsearch_oldnt[] = "^. .*%<DIR%>";
#define NAME_START	39
#define ISDIR_START	29
#define SIZE_COL	24	/* column with size of file */
#define FILECHARS	".*"	/* legal chars in filename */

// Data for dired's regex-replace command to rename files via a pattern.
struct dired_regex_rename_data {
	char str[FNAMELEN], with[FNAMELEN];
	int flags;			// Data for replacement.
	int prompt;			// Should we prompt each time?
	int whole_name;		// Operate on whole file name, not just tail.
} *dired_regex_rename_data;

zeroed buffer char dired_format;
// Which format of file listings does this buffer use?
// Can be:
// DF_UNIX for Unix-style listings (good for most FTP sites, or might be local),
// DF_SIMPLE for a format with just file names (some FTP sites use this),
// DF_OLDNT for some NT 3.51 servers,
// DF_VMS for VMS systems,
// or 0 for Windows/DOS-format directory listings (local).
#define DF_UNIX		1
#define DF_SIMPLE	2
#define DF_OLDNT	3
#define DF_VMS		4

buffer dired_orig_position;	// Sort only if the user hasn't moved from here.
buffer char *dired_buffer_pattern;	// The pattern that made this dired
			// buffer.  If 0, use the buffer's name instead.
#define LIVE_LINK_BUF	"dired-live-link"
user int dired_live_link_limit = 3000000;	// Biggest file live link shows.

#define DIRLINEPAT	"^(     Directory of )"
#define SKIPLINEPAT	"^(     Directory of |  total [0-9]+|  .*:(%[.*%])?$|\n" \
					"|  Directory .*:%[|  Total of .* (files|blocks)" \
					"|                    |  USR%$DISK:)"
#define UNIX_DATE " [a-z][a-z][a-z] [ 0-9][0-9] " \
				  "[ 0-9][0-9][:0-9][0-9][ 0-9] "
#define OLDNT_DATE "[0-9][0-9]-[0-9][0-9]-[0-9][0-9]  " \
				   "[0-9][0-9]:[0-9][0-9][AP]M "
#define VMS_DATE "(\n.*)?[ 0-9][0-9]-[a-z][a-z][a-z]-[0-9][0-9][0-9][0-9] " \
				   "[0-9][0-9]:[0-9][0-9](:[0-9][0-9]%.[0-9][0-9]| )"
#define REMOTE_FTP_OP_BUFFER	"-ftp-operations"

color_class dired_deleted;
color_class dired_moved;
color_class dired_copied;
color_class dired_normal;
color_class dired_file_name;
color_class dired_header;
color_class dired_dir_name;

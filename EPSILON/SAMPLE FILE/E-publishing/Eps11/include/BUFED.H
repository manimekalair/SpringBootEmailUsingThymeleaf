/************************************************** -*- tab-width:4 -*- *
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1985, 1995 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

#define BNAME_COL		(13)	/* make_buffer_list() puts bufname in column */
#define FNAME_COL		(30)	/* and file name in this column */
#define ACCESS_WIDTH	(10)	/* temp col w/access timestamp is this wide */

#define BUFED_BUF		"-bufed"
#define BUFED_CAPTION_BUF		"-bufed-caption"

zeroed int _bufed_window, _bufed_caption_window, _bufed_orig_window;
zeroed int _bufed_orig_buffer, _bufed_orig_highlight;
char _bufed_sort = 'a';
// Sort by: b=buf name, f=file, i=size, a=last access, else don't.
// If uppercase, use reverse sort.

#define BUFED_ALL				(1)		/* include hidden files */
#define BUFED_ONLY_UNSAVED		(2)		/* include only unsaved files */
#define BUFED_EXIT				(4)		/* use dialog for exiting */
#define BUFED_SAVE				(8)		/* ... for saving before make */
#define BUFED_SWITCH			(16)	/* ... for switch-buffers cmd */
user char bufed_grouping = 0;	// sort user buffers separately

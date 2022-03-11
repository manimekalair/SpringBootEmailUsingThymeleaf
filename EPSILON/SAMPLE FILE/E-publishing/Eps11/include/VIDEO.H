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

/* video mode switching support */

	/* for convenience, pass around "size", not lines&cols, for screen */
#define MAKE_SIZE(cols, lines)	((lines) * 10000 + (cols))
#define GET_COLS(size)		((size) % 10000)
#define GET_LINES(size)		((size) / 10000)

int _inside_size;	/* screen size while in epsilon */
int _outside_size;	/* size during push or at exit */
short _last_video_mode = -1;		/* last video mode we set */
zeroed char current_video_mode[30];	// name of current video mode, if known

/* extra sets of video modes (DOS only) */
#define VM_VESA		1
#define VM_UVISION	2

user char extra_video_modes = 0; // bits: 1 allows vesa, 2 allows ultravision
zeroed char using_extra_video_modes; // 0 none, 1 using vesa, 2 ultravision

char *vid_match();
char *vid_match_names();

char *(*vid_match_extra)();	// optional replacements for usual funcs
int (*change_video_extra)();

#define ati_maybe_blank(val)	if (opsys == OS_DOS && \
								using_extra_video_modes == VM_VESA) \
								ati_blank(val)
zeroed short prev_screen_lines, prev_screen_cols;

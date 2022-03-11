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

short *_kill_width;	/* array of widths for each kill buffer */
#define UNUSED	0	/* width value: this kill buffer never used */
#define REGION	-1	/* width value: kill buf has region, not rectangle */
#define REGION_LINE	-2		/* width value: kill buf has line region */
#define NORM_REGION(w)	((w) == REGION || (w) == REGION_LINE)
 /* does this width val represent a REGNORM, REGLINE, or REGINCL region? */
short _prev_kill_buffers;	/* # of kill bufs last time */
int _num_kill=0;			/* number of current kill buffer */
char _cur_kill_buf[30]="-kill-buffer-0"; /* name of current kill buffer */
user char yank_rectangle_to_corner = 1;	// Where to leave pt after yanking?
user char mark_unhighlights = 0;	// marking same type turns off hilite?
user int reindent_after_yank;	// Run buffer's indenter on yanked regions
	// smaller than this.  0=never, -1=no limit.

int _oldfrom = -1, _oldto = -1;	/* region yanked last time */
#define UNDO_FLAG_KILL	1	/* bracket each yank in undo with these */
#define UNDO_FLAG_RETR	2	/* for yank-pop */

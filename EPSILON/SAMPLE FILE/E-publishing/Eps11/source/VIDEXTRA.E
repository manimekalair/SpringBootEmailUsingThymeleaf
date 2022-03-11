/************************************************************************
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

// Epsilon support for screen modes from VESA's Super VGA BIOS Extensions
// or Ultravision utility program.

#include "eel.h"
#include "lowlevel.h"
#include "video.h"

struct videx_info {	/* structure get_videx_info fills in */
	short table_seg, table_off;	// memory location of videx table
	short mode, lines, cols;	// info on indicated mode
	short vesa_modes;		// 1=vesa modes, 0=ultravision
	short data[128];		// main block of info (vesa needs it)
} *videx_info;

	/* flags in vesa mode info */
#define VESA_EXTRA_INFO		0x2	/* full info avail on this mode */
#define VESA_GRAPHIC_MODE	0x10	/* graphics mode: epsilon can't use */

zeroed char using_extra_video_modes; // 0 none, 1 using vesa, 2 ultravision

get_videx_info(index)	// fill in above structure for index'th mode
{	// index with mode of -1 is last valid one, mode of -2 means ignore it
	videx_info->mode = videx_info->vesa_modes ? get_vesa_info(index)
						: get_uvision_info(index);
}

get_uvision_info(index)	// fill in structure for index'th mode, return mode #
{	// index with mode of -1 is last valid one, -2 means ignore this mode
	int n, off;

	n = index * 8;		// look up mode in table
	off = videx_table_word(n + 6);
	videx_info->cols = videx_byte(off);
	videx_info->lines = videx_byte(off + 1) + 1;
	return videx_table_word(n);
}

get_vesa_info(index)	// fill in structure for index'th mode, return mode #
{	// index with mode of -1 is last valid one, -2 means ignore this mode
	int lines, cols, mode = videx_table_word(index * 2);
	short buf[128];		// put vesa info here

	if (mode == 0xffff)		// end of mode table
		return -1;
	if (!read_vesa_info(mode, buf) || (buf[0] & VESA_GRAPHIC_MODE))
		return -2;		// failed, or not text mode, so ignore
	lines = 0, cols = 132;		// handle std modes
	switch (mode) {
		case 0x108:	lines = 60; cols = 80; break;
		case 0x109:	lines = 25; break;
		case 0x10a:	lines = 43; break;
		case 0x10b:	lines = 50; break;
		case 0x10c:	lines = 60; break;
	}
	if (lines) {
		videx_info->cols = cols, videx_info->lines = lines;
		return mode;
	}		// else a nonstandard mode---try to use it anyway
	if (!(buf[0] & VESA_EXTRA_INFO)) // not enough info
		return -2;		 // on it, so ignore this mode
	videx_info->cols = buf[9];
	videx_info->lines = buf[10];
	if (buf[9] > 300)		// faulty bios's don't give lines/cols
		videx_info->cols /= buf[11] & 0xff;
	if (buf[10] > 300)		// but resolution, so adjust if bogus
		videx_info->lines /= (buf[11] >> 8) & 0xff;
	return mode;
}

read_vesa_info(mode, p)	// put mode info into array p
short p[128];		// return 1 if ok, 0 if failed
{
	int ok;

	ati_maybe_blank(1);
	m_regs.w.es = get_pointer(p, SEGMENT);
	m_regs.w.di = get_pointer(p, OFFSET);
	m_regs.w.cx = mode;		// get info on this mode #
	vid_int(0x4f01);
	ok = (m_regs.w.ax == 0x004f);	// success?
	ati_maybe_blank(-1);
	return ok;
}

/*
The ATI Mach64 card takes a very long time to return information on
its VESA modes, unless the screen has been blanked.  Epsilon 
therefore blanks the screen each time it gets VESA mode information,
whenever it detects this card.

An environment variable VESABLANK overrides this detection.  Set
VESABLANK=1 to force Epsilon to blank the screen around calls (if the
video BIOS supports this), or set VESABLANK=0 to disable blanking (if
your ATI Mach64 card doesn't require it).

The ati_maybe_blank() macro takes a parameter cnt which lets EEL
functions nest calls to blank the screen.  (It calls ati_blank() if
Epsilon is actually using VESA modes.)  Normally, a function calls
ati_maybe_blank(1), accesses video information, and then calls
ati_maybe_blank(-1).  The process of accessing video information can
also call ati_maybe_blank() in this way, and Epsilon will ensure that
the screen remains blanked until the final matching call to
ati_maybe_blank().  To guard against mismatched calls, a function can
call ati_maybe_blank(0) to force Epsilon to unblank the screen.
*/

zeroed char ati_blank_cnt;	// keep track of nested blanking calls

ati_blank(cnt)			// 1: blank screen if ATI MACH64
{				// -1: unblank screen if ATI MACH64
	char *oem_name, *s;	// 0: force unblank (above nest)
	EEL_PTR *q;
	int must_blank;

	if (!videx_info || !videx_info->vesa_modes)
		return;			// not a VESA VBE card
	s = getenv("VESABLANK");	// set to 1 or 0 to force blanking
	if (s)
		must_blank = numtoi(s);
	else {		// no override, blank if it's an ATI MACH64 card
		q = (EEL_PTR *) &oem_name;
		q->base.loword = q->value.loword = videx_info->data[3];
		q->base.hiword = q->value.hiword = videx_info->data[4];
		q->size.loword = 1000;
		q->size.hiword = 0;	// see if it's an ATI MACH64 board
		must_blank = !strstr("MACH64", oem_name);
	}
	if (!must_blank)
		return;
	if (cnt)		// manage nested calls
		ati_blank_cnt = MAX(ati_blank_cnt + cnt, 0);
	else			// force screen back on
		ati_blank_cnt = 0;
	m_regs.b.cl = (ati_blank_cnt > 0) ? 4 : 0; // 4: blank; 0: normal
	vid_int(0xA00C);	 // blank/unblank the screen using DPMS call
}

videx_table_word(offset)	/* return a 16-bit word from videx table */
{
	return videx_byte(videx_info->table_off + offset) +
		256 * videx_byte(videx_info->table_off + offset + 1);
}

videx_byte(offset)		/* return a byte from videx data segment */
{
	return peek(videx_info->table_seg, offset);
}

short _videx_match_pos;	// index of next match to try
char _videx_match[30];	// current match

char *videx_only_match(s, start)	// completion helper func
char *s;	// return next or first match for s, using only videx
{
	if (start & STARTMATCH) {
		_videx_match_pos = 0;
		ati_maybe_blank(1);
	}
	for (;;) {
		get_videx_info(_videx_match_pos);
		if (videx_info->mode == -1)
			break;
		_videx_match_pos++;
		if (videx_info->mode == -2)
			continue;
		sprintf(_videx_match, "%dx%d-[Mode:%x]",
			videx_info->cols, videx_info->lines, videx_info->mode);
		_videx_match[strlen(s)] = 0;
		if (strcmp(_videx_match, s))	/* doesn't match */
			continue;
		sprintf(_videx_match, "%dx%d-[Mode:%x]",
			videx_info->cols, videx_info->lines, videx_info->mode);
		return _videx_match;
	}
	ati_maybe_blank(-1);
	return 0;
}

char *videx_match(s, start)	// completion helper func
char *s;	// return next or first match for s, using videx + normal modes
{
	char *t;

	if (start & STARTMATCH)
		_videx_match_pos = 0;
	if (_videx_match_pos != -1) {	// still working on videx modes
		t = videx_only_match(s, start);
		if (t)
			return t;
	}				// now go through normal modes
	t = vid_match_names(s, start | (_videx_match_pos == -1
					? 0 : STARTMATCH));
	_videx_match_pos = -1;	// finished new modes, now do built-ins
	return t;
}

videx_set(cols, lines, mode, active)	/* set or check if mode is avail */
char *mode;
{
	int i = 0, modenum = 0;		// cycle through list of modes
	char *s;
	
	if (s = index(mode, ':'))
		modenum = strtoi(s + 1, 16);
	do {
		get_videx_info(i++);	// see if this mode's right
		if (videx_info->mode == -2 || cols != videx_info->cols
		    || lines != videx_info->lines)
			continue;
		if (!active)		// leaving this mode, so do nothing
			return 1;
		else if (active == 1) {		// really do it
			_last_video_mode = -2;	// not in a std mode
			if (set_videx_mode(modenum ? modenum
					   : videx_info->mode))
				return 0;	// bad mode
			vid_clear_screen(lines, cols);
			term_position(0, 0);
			leave_blank = 1;
			resize_screen(lines, cols);
			when_resizing();
		}		// else active==2, checking if avail
		return 1;
	} while (videx_info->mode != -1); // try next mode
		// ran out of videx modes to try, must be built-in mode
	if (videx_info->vesa_modes)	// but only try if vesa
		return change_video_names(cols, lines, mode, active);
	return 0;		// uvision modes don't mix with built-ins
}

set_videx_mode(m)	// set to videx mode m as appropriate,
{			// return nonzero if error
	if (videx_info->vesa_modes) {
		m_regs.w.bx = m;
		vid_int(0x4f02);
		return (m_regs.w.ax != 0x004f);
	}
	vid_int(0xcd00 + (m & 0xff));	// set Ultravision mode
	return (m_regs.w.ax == 0xcdcd);
}

init_vesa()		// set up to use vesa modes (plus normal ones)
{
	if (!videx_info)
		videx_info = (struct videx_info *)
			     malloc(sizeof(struct videx_info));
	m_regs.w.es = get_pointer(videx_info->data, SEGMENT);
	m_regs.w.di = get_pointer(videx_info->data, OFFSET);
	vid_int(0x4f00);	/* check for vesa bios extensions */
	if (m_regs.w.ax != 0x004f)
		return;		// oops, no longer there, so ignore it
	videx_info->table_seg = videx_info->data[8];
	videx_info->table_off = videx_info->data[7];
	videx_info->vesa_modes = 1;
	vid_match_extra = videx_match;
	change_video_extra = videx_set;
	using_extra_video_modes = VM_VESA;
}

init_uvision()		// set up to use ultravision modes exclusively
{
	if (!videx_info)
		videx_info = (struct videx_info *)
			     malloc(sizeof(struct videx_info));
	vid_int(0xcd0f);	// get ultravision configuration
	videx_info->table_seg = m_regs.w.ds;
	videx_info->table_off = m_regs.w.di;
	videx_info->vesa_modes = 0;
	vid_match_extra = videx_only_match;
	change_video_extra = videx_set;
	using_extra_video_modes = VM_UVISION;
}

command list_svga_modes()	// list modes for this SVGA
{
	if (opsys == OS_DOS)
		dos_list_svga_modes();
	else
		os2_list_svga_modes();
}

dos_list_svga_modes()	// list modes for this SVGA under DOS
{
	int i = 0, mode;
	short buf[128];

	if (!videx_info)
		error("No SVGA support: neither a VESA SVGA driver "
		      "nor Ultravision TSR found.");
	zap("svga-modes");
	to_buffer("svga-modes");
	bprintf("Driver found.\n");
	bprintf("Available %s modes:\n\n",
		videx_info->vesa_modes ? "VESA SVGA" : "Ultravision");
	ati_maybe_blank(1);
	for (;; i++) {
		get_videx_info(i);
		if (videx_info->mode == -1)
			break;
		if (videx_info->mode == -2)
			bprintf("Unusable ");
		bprintf("%dx%d mode", videx_info->cols, videx_info->lines);
		if (videx_info->vesa_modes) {
			mode = videx_table_word(i * 2);
			read_vesa_info(mode, buf);
			bprintf(": %s, ", (buf[0] & VESA_GRAPHIC_MODE)
				? "graphics" : "text");
			if (!(buf[0] & VESA_EXTRA_INFO))
				bprintf("no other info");
			else
				bprintf("mode %xh reports %dx%d, cell %dx%d",
					mode, buf[9], buf[10],
					buf[11] & 0xff, (buf[11] >> 8) & 0xff);
		}
		bprintf("\n");
	}
	ati_maybe_blank(0);
	point = 0;
}

os2_list_svga_modes()	// define modes for this SVGA under OS/2
{
	char file[FNAMELEN], name[FNAMELEN];
	int b, err, count = 0, rows, cols, hres, vres, i;

	save_var only_file_extensions = "|.pmi|";
	save_var abort_searching = 0;
	get_file(file, "Please locate SVGADATA.PMI", "C:\\OS2\\SVGADATA.PMI");
	zap("svga-modes");
	to_buffer("svga-modes");
	stuff("Available Super VGA text modes:\n\n");
	save_var bufnum = b = tmp_buf();
	err = err_file_read(file, 0);
	if (!err)
		while (re_search(1, "Text mode: ")) {
			cols = search_grab_number(b, "");
			rows = search_grab_number(b, "cols,");
			hres = search_grab_number(b, "XResolution[ \t]*=");
			vres = search_grab_number(b, "YResolution[ \t]*=");
			sprintf(name, "video-mode-os2-%dx%d", cols, rows);
			i = find_index(name);
			buffer_printf("svga-modes", "%s %dx%d text mode with "
				      "resolution %dx%d\n",
				      i ? "Updating" : "Adding", cols, rows,
				      hres, vres);
			if (!i) {
				i = new_variable(name, NT_VAR, TYPE_INT);
				count++;
			}
			if (i > 0)
				set_num_var(i, MAKE_SIZE(hres, vres));
		}
	restore_vars();
	buf_delete(b);
	if (!err)
		say("Added %d video modes.", count);
}

search_grab_number(b, pat)	// search in b for pattern, return following #
char *pat;			// or 0 if not found
{
	char digits[150];

	save_var bufnum = b;
	switch (re_search(1, pat)) {
		case 0:
			got_bad_number = 2;
			return 0;
		case ABORT_ERROR:
			got_bad_number = ABORT_ERROR;
			return ABORT_ERROR;
		default:
			parse_string(1, "[ \t]*-?([0-9a-z]+|'?')", digits);
			return numtoi(digits);
	}
}

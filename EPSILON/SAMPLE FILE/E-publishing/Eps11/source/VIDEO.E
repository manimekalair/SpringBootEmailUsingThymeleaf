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

// This file has commands for switching video modes under DOS and
// OS/2.

#include "eel.h"
#include "lowlevel.h"
#include "video.h"

term_init()		/* record outside size */
{
	vid_match_extra = change_video_extra = 0;
	_find_outside();
	_inside_size = _outside_size;
}

term_cmd_line()		/* go to mode indicated by cmd line switches */
{
	int use_lines, use_cols, newsize;

	if (want_lines || want_cols) {
		use_lines = want_lines ? want_lines : screen_lines;
		use_cols = want_cols ? want_cols : screen_cols;
		newsize = MAKE_SIZE(use_cols, use_lines);
		if (newsize != _inside_size) {
			change_video(_inside_size, 0, "");
			change_video(newsize, 1, "");
		}
		resize_screen(use_lines, use_cols);
		_inside_size = MAKE_SIZE(screen_cols, screen_lines);
	}
}

term_mode(active)	/* set screen mode in(out) of epsilon */
{
	prev_screen_lines = 0;
	prev_screen_cols = 0;
	if (_inside_size != _outside_size) {
		change_video(active ? _outside_size : _inside_size, 0, "");
		change_video(active ? _inside_size : _outside_size, 1, "");
	}
	return _inside_size != _outside_size;
}

show_screen_size()
{
	if (prev_screen_lines && prev_screen_cols
		&& (prev_screen_lines != screen_lines
			|| prev_screen_cols != screen_cols))
		note("Now %d x %d", screen_cols, screen_lines);
	prev_screen_lines = screen_lines;
	prev_screen_cols = screen_cols;
}

char *vid_prefix()
{
	return (opsys == OS_OS2) ? "video-mode-os2-" : "video-mode-";
}

char *vid_match_names(s, start)	/* completion helper: gives funcs/vars */
char *s;			/* starting w/ "video-mode-" and (if func) */
{				/* return nonzero when called with arg=2 */
	char name[50], *prefix = vid_prefix();
	int i;

	sprintf(name, "%s%s", prefix, s);
	for (; i = name_match(name, start & STARTMATCH); start &= ~STARTMATCH)
		if (name_type(i) == NT_VAR || (*(int (*)())i)(2))
			return name_name(i) + strlen(prefix);
	return 0;
}

char *vid_match(s, start)	// completion helper: gives valid video modes
char *s;			// starting with s
{
	return (*(vid_match_extra ? vid_match_extra
				 : vid_match_names))(s, start);
}

command next_video() on reg_tab[FCTRL(5)]
{				/* pick some different video mode */
	char name[30], *s, i = 0, len;

	if (is_gui)
		error("Resize a window by dragging its border.");
	else if (opsys == OS_UNIX || is_win32)
		error("Can't change video modes in this environment.");
	iter = 0;
	if (*current_video_mode)
		strcpy(name, current_video_mode);
	else
		sprintf(name, "%dx%d", screen_cols, screen_lines);
	len = strlen(name);
	ati_maybe_blank(1);
	s = vid_match("", 1);		// find current mode in list
	while (s && (strncmp(name, s, len) || (current_video_mode ? s[len]
					       : isdigit(s[len])))
	       && (s = vid_match("", 0)))
		check_abort();
	do {
		if (!(s = vid_match("", 0)))	/* get next one, or first */
			if (!(s = vid_match("", 1)))
				break;		// can't find any, give up
		check_abort();
		if (i++ > 50) {
			ati_maybe_blank(0);
			error("Can't switch from this video mode");
		}
		if (do_set_video(s)) {
			strcpy(current_video_mode, s);
			break;
		}
	} while (strcmp(name, s));	// give up if we get same mode twice
	ati_maybe_blank(0);
	note("Now %d x %d", screen_cols, screen_lines);
}

command set_video() on reg_tab[FALT(5)]
{
	char mode[30];

	if (is_gui)
		error("Resize a window by dragging its border.");
	else if (opsys == OS_UNIX || is_win32)
		error("Can't change video modes in this environment.");
	iter = 0;
	comp_read(mode, "Set video mode to: ", vid_match, MUST_MATCH, "");
	if (do_set_video(mode))
		strcpy(current_video_mode, mode);
	ati_maybe_blank(0);
	note("Now %d x %d", screen_cols, screen_lines);
}

do_set_video(mode)	/* try to set to this mode name, return 1 if ok */
char *mode;
{
	int cols, lines;
	char *p;

	if (!(p = index(mode, 'x')) || !(cols = strtoi(mode, 10))
				|| !(lines = strtoi(p + 1, 10)))
		return 0;
	return try_set_screen_size(lines, cols, mode);
}

try_set_screen_size(lines, cols, mode)		// lines & cols required
char *mode;			// mode name can be "" if we don't care
{
	int ok;
	int nsize, osize = MAKE_SIZE(screen_cols, screen_lines);

	nsize = MAKE_SIZE(cols, lines);
	if (nsize == osize)
		return 1;
	if (!change_video(nsize, 2, mode))	/* check if legal */
		return 0;
	change_video(osize, 0, mode);		/* turn off old */
	ok = change_video(nsize, 1, mode);
	if (!ok)		/* if error, restore old */
		change_video(osize, 1, mode);
	_inside_size = MAKE_SIZE(screen_cols, screen_lines);
	return ok;
}

change_video_names(cols, lines, mode, active)
char *mode;
{	// set video mode using specific EEL subr or var, return 1 if ok
	int i;
	char func[60];

	sprintf(func, "%s%s", vid_prefix(), mode);
	i = find_index(func);
	switch (name_type(i)) {		// i has name table index of subr/var
		case NT_SUBR: case NT_COMMAND:
		case NT_AUTOSUBR: case NT_AUTOLOAD:
			return (*(int (*)())i)(active);
		case NT_VAR:		/* use dos mode # */
			if (opsys == OS_DOS) {
				if (active == 1)
					do_video_var(*(char *)varptr(i), lines, cols);
				else if (!active)	/* go to normal mode */
					do_video_var(screen_mode, lines, cols);
			} else if (active == 1)		// OS/2
				return vid_set_mode(cols, lines, GET_COLS(get_num_var(i)),
									GET_LINES(get_num_var(i)));
			return 1;
	}
	return 0;
}

change_video(size, active, mode)	/* set to size code, return 1 if ok */
char *mode;
{
	char name[20];
	int ret = 0, lines, cols;

	lines = GET_LINES(size);
	cols = GET_COLS(size);
	save_var mouse_auto_on = 0, mouse_display = 0;
	if (!mode || !*mode)	// make up appropriate mode name
		sprintf(mode = name, "%dx%d", cols, lines);
	if (!is_gui && opsys != OS_UNIX) {
		ati_maybe_blank(1);
		ret = (*(change_video_extra ? change_video_extra
			: change_video_names))(cols, lines, mode, active);
		ati_maybe_blank(-1);
	} else				// gui version: permit any size screen
		ret = 1;
	if (active == 1 && ret) {
		resize_screen(lines, cols);
		if (screen_lines != lines || screen_cols != cols)
			ret = 0;
		when_resizing();
	}
	return ret;
}

when_resizing()		/* call after changing size of screen */
{
}

_find_outside()	/* set variables for screen size outside of epsilon */
{
	if (opsys == OS_DOS)
		dos_find_outside();
	else if (opsys == OS_OS2)
		os2_find_outside();
	else
		_outside_size = MAKE_SIZE(screen_cols, screen_lines);
}

short _video_adapter;
#define IS_EGA		(_video_adapter == 1)
#define IS_VGA		(_video_adapter == 2)

#define IS_OS2_EGA		(_video_adapter == 2)
#define IS_OS2_VGA		(_video_adapter == 3 || _video_adapter >= 7)
	/* 8514A: 7, ImageAdapter 8, XGA 9, SVGA 10 */

// OS/2 video support

os2_find_outside()	/* set variables for screen size outside of epsilon */
{
	short data[2];

	_last_video_mode = screen_mode;
	_outside_size = vid_get_mode();
	data[0] = sizeof(data);
	data[1] = -1;
	os2call("VIOCALLS", 0, "VIOGETCONFIG", 4,
		0, get_pointer(data, SEGMENT),
		get_pointer(data, OFFSET), 0, 0, 0);
	_video_adapter = data[1];
	if (IS_OS2_EGA || IS_OS2_VGA)
		selectable_colors = 256;
}

video_mode_os2_80x25(active)
{
	if (opsys == OS_DOS)
		return 0;
	if (active != 1)
		return 1;		/* always supported */
	return vid_set_80x25(0, 0) || vid_set_80x25(720, 400)
		|| vid_set_80x25(720, 350) || vid_set_80x25(640, 400)
		|| vid_set_80x25(640, 350) || vid_set_80x25(640, 200);
}

vid_set_80x25(hres, vres)
{
	return vid_set_mode(80, 25, hres, vres);
}

video_mode_os2_80x30(active)
{
	return video_vga_mode(active, 30, 480);
}

video_mode_os2_80x43(active)
{
	if (opsys == OS_DOS)
		return 0;
	if (active != 1)
		return IS_OS2_EGA || IS_OS2_VGA;
	return vid_set_mode(80, 43, 0, 0) ? 1
		: vid_set_mode(80, 43, 720, 350) ? 1
		: vid_set_mode(80, 43, 640, 350);
}

video_vga_mode(active, lines, vres)
{
	if (opsys == OS_DOS)
		return 0;
	if (active != 1)
		return IS_OS2_VGA;
	return vid_set_mode(80, lines, 0, 0) ? 1
		: vid_set_mode(80, lines, 720, vres) ? 1
		: vid_set_mode(80, lines, 640, vres);
}

video_mode_os2_80x50(active)
{
	return video_vga_mode(active, 50, 400);
}

video_mode_os2_80x60(active)
{
	return video_vga_mode(active, 60, 480);
}

struct ModeData _video_mode_data;

vid_xxx_call(func, ptr)
char *func, *ptr;
{
	os2call("VIOCALLS", 0, func, 3,
		get_pointer(ptr, SEGMENT),
		get_pointer(ptr, OFFSET), 0, 0, 0, 0);
}

vid_get_mode()
{
	_video_mode_data.length = sizeof(_video_mode_data);
	vid_xxx_call("VIOGETMODE", (char *) &_video_mode_data);
	return MAKE_SIZE(_video_mode_data.col, _video_mode_data.row);
}

vid_set_mode(cols, lines, hres, vres)
{
	if (vid_get_mode() == MAKE_SIZE(cols, lines))
		return 1;
	term_clear();
	_video_mode_data.col = cols, _video_mode_data.row = lines;
	if (hres) _video_mode_data.hres = hres;
	if (vres) _video_mode_data.vres = vres;
	vid_xxx_call("VIOSETMODE", (char *) &_video_mode_data);
	term_clear();
	term_position(0, 0);
	leave_blank = 1;	/* note that screen's clear */
	vid_os2_bright_back(1);
	return vid_get_mode() == MAKE_SIZE(cols, lines);
}

vid_os2_bright_back(bright)	// set high background colors to bright or blinking
{
	short params[3];

	params[0] = sizeof(params);
	params[1] = 2;
	params[2] = bright;
	vid_xxx_call("VIOSETSTATE", (char *) params);
}

// DOS video support

dos_find_outside()	/* set variables for screen size outside of epsilon */
{
	_last_video_mode = screen_mode;
	switch (screen_mode) {
		case 2: case 3: case 7:
			if (screen_lines != 25 || screen_cols != 80)
				_last_video_mode = -1;
	}
	_outside_size = MAKE_SIZE(screen_cols, screen_lines);
	if (restore_color_on_exit)
		alter_color(color_class after_exiting, orig_screen_color());
	if (is_win32 == IS_WIN32_CONSOLE) {
		selectable_colors = 256;
		return;
	}
	_video_adapter = isega();
	if (IS_EGA || IS_VGA)
		selectable_colors = 256;
	save_var load_fail_ok = 1;
	if (have_uvision())	// use only Ultravision modes if installed
		init_uvision();	// load ultravision support & initialize
	else if (have_vesa())	// else use vesa modes (+regular) if installed
		init_vesa();
}

do_video_var(newmode, lines, cols)
{
	if (newmode != _last_video_mode) {
		leave_blank = 1;
		vid_int(_last_video_mode = newmode);
		vid_clear_screen(lines, cols);
		vid_bright_back(1);
	}
}

user char vga43 = 0;	/* 43-line mode is unreliable on some vga's */
	/* set nonzero with set-variable to use 43-line mode on your vga */

video_normal_mode()	/* give standard 80x25 mode number */
{
	switch (screen_mode) {
		case 7: case 2:	return screen_mode;
		default:	return 3;
	}
}

video_mode_80x25(active)	/* set to 80x25 color, unless we started */
{				/* in some other 80x25 mode */
	if (active < 2)
		do_video_var(active ? video_normal_mode() : screen_mode,
			80, 25);
	return 1;
}

video_mode_80x28(active)	/* for vga board */
{
	return IS_VGA ? vid_romset(active, 2, 0x11) : 0;
}

video_mode_80x35(active)	/* for ega and vga boards */
{
	return (IS_EGA || IS_VGA) ? vid_select_expanded_font(active, 1) : 0;
}

video_mode_80x40(active)	/* for vga boards */
{
	return IS_VGA ? vid_select_expanded_font(active, 2) : 0;
}

video_mode_80x43(active)	/* for ega or vga boards */
{
	return (IS_EGA || IS_VGA && vga43)
		? vid_romset(active, (active ? 1 : 2), 0x12) : 0;
}

video_mode_80x50(active)	/* for vga board */
{
	return IS_VGA ? vid_romset(active, 2, 0x12) : 0;
}

vid_select_expanded_font(active, lines)
{		/* 0 for 200 scan lines, 1 for 350, 2 for 400 */
	if (active == 2)
		return 1;
	if (active == 0) {
		vid_romset(0, 2, 0);
		return 1;
	}
	video_make_expanded_font();	/* first construct font if necessary */
	vid_set_scan_lines(lines);
	vid_int(video_normal_mode());	/* set mode to 80x25 */
	video_load_expanded_font();
	_last_video_mode = -2;
	vid_clear_screen(80, 80);
	term_position(0, 0);
	vid_bright_back(1);
	leave_blank = 1;	/* note that screen's clear */
	return 1;
}

char *_vga_expanded_font;
#define VGA_FONT_SIZE	(256 * 10)

video_make_expanded_font()	/* construct _vga_expanded_font */
{
	char *p;
	int i, j, seg, off, extra;

	if (!_vga_expanded_font) {
		p = _vga_expanded_font = malloc(VGA_FONT_SIZE);
		m_regs.b.bh = 3;	/* get ptr to 8x8 font in es:bp */
		vid_int(0x1130);
		seg = m_regs.w.es;
		off = m_regs.w.bp;	/* construct an 8x10 font */
		for (i = 0; i < 256; i++) {
			for (j = 0; j < 8; j++)
				*p++ = peek(seg, off++);
			if (i >= 0xB3 && i <= 0xDF)	/* repeat last */
				extra = peek(seg, off - 1);
			else				/* clear it */
				extra = 0;
			*p++ = extra;
			*p++ = extra;
		}
	}
}

video_load_expanded_font()	/* start using constructed font */
{
	video_make_expanded_font();	/* first, make sure it's defined */
	m_regs.w.es = get_pointer(_vga_expanded_font, SEGMENT);
	m_regs.w.bp = get_pointer(_vga_expanded_font, OFFSET);
	m_regs.w.dx = 0;	/* start with 1st char */
	m_regs.w.cx = 256;	/* load 256 chars */
	m_regs.b.bh = 10;	/* now 10 bytes per char */
	m_regs.b.bl = 0;	/* block 0 */
	vid_int(0x1110);		/* load user font */
}

/* active is 0 if leaving mode, 1 if entering mode, 2 if checking legality */
/* lines is 0 for 200 scan lines, 1 for 350, 2 for 400 */
/* font is 0x11 for 8x14, 0x12 for 8x8, or 0x14 for 8x16 */
vid_romset(active, lines, font) /* load/unload alt. rom font */
{			/* puts ega/vga boards in 43/50 line mode */
	if (active == 2)		/* just checking legality */
		return 1;
	vid_set_scan_lines(lines);
	vid_int(video_normal_mode());		/* set mode to 80x25 */
	if (active) {			/* if turning off, we're done */
		m_regs.b.bl = 0;	/* load font into block 0 */
		vid_int(0x1100 | (font & 0xff));
	}
	_last_video_mode = active ? -2 : video_normal_mode();
	vid_clear_screen(80, 80);
	term_position(0, 0);
	vid_bright_back(1);
	leave_blank = 1;	/* note that screen's clear */
	return 1;
}

vid_set_scan_lines(lines)
{		/* 0 for 200 scan lines, 1 for 350, 2 for 400 */
	m_regs.b.bl = 0x30;
	vid_int(0x1200 | (lines & 0xff));	/* set scan lines */
}

vid_clear_screen(lines, cols)	/* tell BIOS to clear screen to exit color */
{
	m_regs.b.bh = alter_color(color_class after_exiting, -1);
				/* attribute to clear with */
	m_regs.w.cx = 0;	/* upper left of rectangle to clear */
	m_regs.b.dh = lines;	/* lower right of rectangle to clear */
	m_regs.b.dl = cols;
	vid_int(0x600);		/* clear screen by scrolling */
}

vid_bright_back(bright)	// set high background colors to bright or blinking
{
	m_regs.b.bl = !bright;
	vid_int(0x1003);
}

vid_int(val)		/* set AX to val, then call BIOS video */
{
	m_regs.w.ax = val;
	do_interrupt(VIDEO_IO, &m_regs);
}

isega()		/* return 1 if ega, 2 if vga, else 0 */
{
	vid_int(0x1a00);	/* try to get display combination code */
	if (m_regs.b.al == 0x1a)
		switch (m_regs.b.bl) {
			case 4: case 5:	return 1;
			case 7: case 8: case 9:
			case 11: case 12: return 2;
			default:	return 0;
		}
	m_regs.b.bl = 0x10;	/* try to get ega information */
	vid_int(0x1200);
	return m_regs.b.bl != 0x10;	/* now return 1 if ega */
}

/* We put the following two functions in this file so we don't have  
 * to autoload vidextra.e with vesa/uvision code if neither is
 * installed.   
 */

have_vesa()		// is a vesa svga bios extension driver installed? 
{
	char buf[256];

	if (!(extra_video_modes & 1))	/* pretend it's not there? */
		return 0;
	m_regs.w.es = get_pointer(buf, SEGMENT);
	m_regs.w.di = get_pointer(buf, OFFSET);
	vid_int(0x4f00);	/* check for vesa bios extensions */
	return m_regs.w.ax == 0x004f;
}

have_uvision()		/* is ultravision 1.20 or later installed? */
{
	if (!(extra_video_modes & 2))	/* pretend it's not there? */
		return 0;
	m_regs.w.cx = 0;	/* see if ultravision is present, get vers */
	m_regs.w.si = 0;	/* early versions don't set si */
	vid_int(0xcc00);	/* check for ultravision */
	return ((m_regs.w.cx & 0xffff) == 0xabcd && m_regs.w.si >= 0x114);
}

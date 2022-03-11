/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1993, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

/* Integrated access to the clipboard. */

#include "eel.h"
#include "lowlevel.h"
#include "kill.h"

user short clipboard_format = CF_DEFAULT;

// Change \n to \r\n when copying to clipboard, \r\n to \n when retrieving?
clipboard_convert_newlines()
{
	return (translation_type != FILETYPE_BINARY && opsys != OS_UNIX);
}

command copy_to_clipboard()	// copy region to clipboard
{
	int err = 0, tmp = zap("-clipboard-");
	save_spot point, mark;
	fix_region();
	if (region_type() == REGRECT)
		extract_rectangle(tmp, 0);
	else
		buf_xfer(tmp, point, mark);
	if (!buffer_to_clipboard(tmp, clipboard_convert_newlines(), clipboard_format))
		err = errno;
	clipboard_to_buffer(zap("-clipboard-"), clipboard_convert_newlines(),
						clipboard_format);
	if (err)
		file_error(err, "", "Couldn't copy to clipboard.");
	else {
		say("Selection copied to clipboard.");
		highlight_off();
	}
}

command insert_clipboard()
{
	if (clipboard_to_buffer(zap("-clipboard-"), clipboard_convert_newlines(),
							clipboard_format)) {
		mark = point;
		set_region_type(REGNORM);
		grab_buffer(name_to_bufnum("-clipboard-"));
		build_first = 1;		/* redisplay hint */
	} else
		file_error(errno, "", "Couldn't retrieve clipboard.");
}

int should_use_clipboard()
{
	switch (clipboard_access) {
		case 0:	return 0;
		case 2:	return 1;		// Always, even in a macro.
	}
	return !in_macro() && !key_from_macro;
}

save_to_clipboard()	// try to save current kill buffer on clipboard
{
	int strip = clipboard_convert_newlines();

	if (should_use_clipboard() && clipboard_available()) {
		buffer_to_clipboard(name_to_bufnum(_cur_kill_buf), strip,
							clipboard_format);
		clipboard_to_buffer(zap("-clipboard-"), strip,
							clipboard_format);
	}
}

get_clipboard()		// push clipboard text on kill ring
{
	int new, old;

	if (!should_use_clipboard() || !clipboard_available())
		return;
	new = zap("-new-clipboard-");
	if (!clipboard_to_buffer(new, clipboard_convert_newlines(),
							 clipboard_format))
		return;
	old = create("-clipboard-");
	if (!buffers_identical(old, new)) {
		save_var bufnum = new;
		check_num_kill_buffers();	// copy clipboard to kill ring
		push_kill();
		_kill_width[_num_kill] = REGION;
		xfer(_cur_kill_buf, 0, size());
		buf_zap(old);		// copy new text to old clipboard buf
		buf_xfer(old, 0, size());
	}
	buf_zap(new);
}

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

// This file has commands for debugging and profiling editor
// extensions.

#include "eel.h"

command set_debug()
{
	char name[FNAMELEN], msg[FNAMELEN], def[FNAMELEN];
	int i;

	sprintf(msg, "%s debugging for function",
		has_arg ? (iter ? "Enable" : "Disable") : "Toggle");
	save_var show_mouse_choices = 1;
	*def = 0;
	find_c_func_info(NULL, NULL, def, 0);
	get_func(name, msg, def);
	i = find_index(name);
	if (!i || name_type(i) != NT_COMMAND && name_type(i) != NT_SUBR
	    && name_type(i) != NT_AUTOLOAD && name_type(i) != NT_AUTOSUBR)
		error("%s is not a debuggable function", name);
	set_name_debug(i, has_arg ? (iter != 0) : !name_debug(i));
	iter = 0;
	say("Debugging for %s %s", name,
		name_debug(i) ? "enabled": "disabled");
}

command profile()
{
	char line[2][150], *s, *tmp;
	int which = 0, count = 0, start, total;

	start_profiling();
	recursive_edit();
	stop_profiling();
	zap("profile");
	to_buffer("profile");
	noteput("Getting profile...");
	for (total = 0; s = get_profile(); total++)
		bprintf("%s\t\n", s);		/* get data points */
	line[1][0] = 0;
	do_buffer_sort(tmp = temp_buf(), 0, 0);
	to_buffer(tmp);
	point = 0;
	noteput("Merging...");
	for (;;) {			/* merge identical lines */
		start = point;
		if (!nl_forward())
			break;
		grab(start, point, line[which]);
		delete(start, point);
		if (strcmp(line[0], line[1])) {
			which = !which;
			if (line[which][0])
				bprintf("%4d: %s", count, line[which]);
			count = 1;
		} else
			count++;
	}
	if (line[!which][0])
		bprintf("%4d: %s", count, line[!which]);
	zap("profile");
	noteput("Sorting...");
	do_buffer_sort("profile", 0, 0);
	to_buffer("profile");
	noteput("Extracting...");
	extract_file_lines(": ", " ");
	delete_buffer(tmp);
	point = size();
	bprintf("Total of %d samples collected.\n", total);
	discardable_buffer = 1;
	say("");
}

extract_file_lines(beforefile, beforeline)
char *beforefile, *beforeline;
{
	char file[FNAMELEN];
	int i, nums[10], tempbuf = 0, obuf = bufnum, opt, isbuf;

	point = 0;
	while (!beforefile || search(1, beforefile)) {
		i = point;
		if (!search(1, beforeline))
			break;
		grab(i, matchstart, file);
		isbuf = !strcmp(file, "Buffer");
		if (isbuf) {
			i = point;
			re_search(1, " ![0-9]+\t$");
			grab(i, matchstart, file);
		}
		if (grab_numbers(bufnum, nums) != 1)
			break;
		if (character(point - 1) == '\n')
			point--;
		if (isbuf) {
			if (exist(file))
				bufname = file;
			else {
				nl_forward();
				continue;
			}
		} else if (!look_file(file)) {
			if (!tempbuf)
				tempbuf = tmp_buf();
			bufnum = tempbuf;
			if (err_file_read(file, FILETYPE_AUTO))
				break;
		}
		opt = point;
		go_line(nums[0]);
		i = point;
		to_end_line();
		buf_xfer(obuf, i, point);
		point = opt;
		bufnum = obuf;
		if (curchar() == '\n')
			point++;
	}
	if (tempbuf)
		buf_delete(tempbuf);
}

command list_undefined()
{
	int i, type, max = final_index();
	char *s;

	tiled_only();
	zap("list-undefined");
	to_buffer("list-undefined");
	discardable_buffer = 1;
	bprintf("The following items are undefined, or have been deleted:\n");
	for (i = 2; i <= max; i++) {
		check_abort();
		type = name_type(i);
		s = name_name(i);	// skip reserved names starting with @
		if (*s != '@' && (type < NT_COMMAND || type > NT_AUTOSUBR))
			bprintf("%s\n", s);
	}
}

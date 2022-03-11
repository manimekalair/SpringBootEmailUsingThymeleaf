/************************************************************************
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

// This file has commands for undoing other commands.

#include "eel.h"

command undo() on reg_tab[FKEY(9)], cx_tab['u']
{
	undo_it(1, 0);
}

command redo() on reg_tab[FKEY(10)], cx_tab['r']
{
	undo_it(0, 0);
}

command undo_changes() on reg_tab[FCTRL(9)], cx_tab[CTRL('U')]
{		/* undo changes consisting only of movement as a unit */
	undo_it(1, 1);
}

command redo_changes() on reg_tab[FCTRL(10)], cx_tab[CTRL('R')]
{
	undo_it(0, 1);
}

// Enter this flag in the undo data only if there's nothing to redo.
// If we've got stuff to redo, entering a flag would wipe it out.
undo_set_flag(int flag)
{
	if (undo_count(0) <= 0)
		undo_flag = flag;
}

// Undo until we reach the specified undo_flag value.
// Assume it's not too far away.

undo_to_flag(int f)
{
	int i = 0;

	while (!(undo_op(1) & UNDO_FLAG) || undo_flag != f)
		if (i++ > 5)	// Give up without undoing all changes.
			return;
}

undo_group_movements(is_undo)
{
	int ret, last, i, cnt, orig_modif = modified, last_cnt = -1;

	ret = last = 0;
	for (; i = undo_op(is_undo); ret |= last = i) {
		if (i & UNDO_FLAG) {
			switch (undo_flag) {
				case UNDO_READ_FILE:
				case UNDO_WRITE_FILE:
				case UNDO_UNMODIFIED:
					if (!last)
						return i;
					undo_op(!is_undo);
					return ret;
			}
			i &= ~UNDO_FLAG;
		}
		if (!i || (i & (UNDO_CHANGES | UNDO_END)))
			break;	/* repeat until buffer changes */
		orig_modif = modified;
		cnt = undo_count(!is_undo);
		if (cnt == last_cnt)	// Don't get stuck at end.
			return ret;
		last_cnt = cnt;
	}
	if (!ret)
		ret = i;
	if (last && (i & UNDO_CHANGES)) {
		do {		/* then reverse change */
			undo_op(!is_undo);
		} while (undo_count(!is_undo) > cnt);
		modified = orig_modif;
	}
	return ret;
}

undo_it(is_undo, group_movements)
{
	int ret, before_count;
	char msg[200], *name = is_undo ? "un" : "re", *spec = 0;
	int orig_nar_start = narrow_start;
	int orig_nar_end = narrow_end;

	if (undo_count(is_undo) < 1)
		error("Nothing to %sdo.", name);
	before_count = undo_count(0);
	if (!before_count)
		_buffer_saved_here = -1;
	if (!undo_keeps_narrowing)
		narrow_start = narrow_end = 0;
	*name = tolower(*name);
	if (group_movements)
		ret = undo_group_movements(is_undo);
	else					/* plain undo */
		ret = undo_op(is_undo);
	narrow_start = orig_nar_start;
	narrow_end = orig_nar_end;
	if ((point < orig_nar_start || point > size() - orig_nar_end)
	   && !undo_keeps_narrowing) {
		say("Undoing outside narrowed region, removing narrowing.");
		narrow_start = narrow_end = 0;
	}
	*name = toupper(*name);
	if (ret & UNDO_FLAG)
		switch (undo_flag) {
			case UNDO_READ_FILE:	spec = "Buffer read from disk";
									break;
			case UNDO_WRITE_FILE:	spec = "Buffer written to disk";
									break;
			case UNDO_UNMODIFIED:	spec = "Buffer was marked unmodified";
									break;
		}
	if (spec) {
		sprintf(msg, "%s, ", spec);
		if (_buffer_saved_here == -1)
			_buffer_saved_here = undo_count(0);
		if (undo_count(0) == _buffer_saved_here || before_count == _buffer_saved_here)
			modified = 0;
	} else if (ret & (UNDO_CHANGES | UNDO_MOVE | UNDO_REDISP | UNDO_MAINLOOP))
		sprintf(msg, "%sdid %s%s%s%s%s%s%s",
			name,
			(ret & UNDO_END ? "Partial " : ""),
			(ret & UNDO_MAINLOOP ? "Command, " : ""),
			(ret & UNDO_REDISP ? "Display, " : ""),
			(ret & UNDO_MOVE ? "Move, " : ""),
			(ret & UNDO_INSERT ? "Insert, " : ""),
			(ret & UNDO_DELETE ? "Delete, " : ""),
			(ret & UNDO_REPLACE ? "Replace, " : ""));
	else
		sprintf(msg, "%sdid, ", name);
	show_text(0, 1, "%s%d bytes remain", msg, undo_count(is_undo));
	return ret;
}

/************************************************************************
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1986, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

/*
WARNING:
This file contains definitions specific to this particular
implementation of Epsilon, and may change at any time.  The use
of higher-level facilities is recommended instead.
*/

// This file contains low level definitions for some of the EEL
// system calls.

#include "eel.h"
#include "lowlevel.h"

get_pointer(p, segment)	/* get either segment or offset of an eel ptr */
EEL_PTR *p;
{
	return get_ptr_helper(&p, segment);
}

get_ptr_helper(p, segment)		/* helper for get_pointer() */
EEL_PTR *p;
{
	return segment ? p->value.hiword : p->value.loword;
}

os2call(module, ordinal, proc, count, s0, s1, s2, s3, s4, s5)
char *module, *proc;		/* load global structure & call */
{
	dllcall.module = module;
	dllcall.proc = proc;
	dllcall.count = count;
	dllcall.stack[0] = s0;
	dllcall.stack[1] = s1;
	dllcall.stack[2] = s2;
	dllcall.stack[3] = s3;
	dllcall.stack[4] = s4;
	dllcall.stack[5] = s5;
	do_interrupt(ordinal, &dllcall);
}

disk_space(disk, info)		/* put information on disk in info */
	struct disk_info *info;
{
	if (opsys == OS_DOS) {
		m_regs.b.ah = 0x36;	/* get disk free space */
		m_regs.b.dl = disk;	/* for this drive (0=default, 1=A, ...) */
		do_interrupt(DOS_SERVICES, &m_regs);
		info->sects_per_cluster = m_regs.w.ax;	/* -1 if drive is invalid */
		info->bytes_per_sector = m_regs.w.cx;	/* load data into structure */
		info->avail_clusters = (m_regs.w.bx & 0xffff);	/* unsigned */
		info->tot_clusters = (m_regs.w.dx & 0xffff);
		if (info->sects_per_cluster == -1)
			errno = 15;		/* invalid drive */
		else if (m_regs.w.flags & CARRYFLAG) {	/* for crit errors */
			errno = info->sects_per_cluster;
			info->sects_per_cluster = -1;
		}
	} else if (opsys == OS_OS2) {			// OS/2
		struct FSAllocate fsinfo;

		os2call("DOSCALLS", DOSQFSINFO, "", 5, disk, 1,
			get_pointer((EEL_PTR *) &fsinfo, SEGMENT),
			get_pointer((EEL_PTR *) &fsinfo, OFFSET), sizeof(fsinfo), 0);
		info->sects_per_cluster = fsinfo.sec_per_unit;
		info->bytes_per_sector = fsinfo.bytes_sec;
		info->avail_clusters = fsinfo.avail_units;
		info->tot_clusters = fsinfo.num_units;
	} else
		error("disk_space(): not implemented");
}

doscall(func)		/* do dos function func, interpreting carry flag */
{
	int rval = 0;

	m_regs.b.ah = func;
	do_interrupt(DOS_SERVICES, &m_regs);
	if (m_regs.w.flags & CARRYFLAG) {	/* check for error */
		errno = m_regs.w.ax;
		rval = -1;
	}
	return rval;
}

#if 0			// no one uses these functions any more
dosnamecall(func, name)	/* do dos function that takes string in ds:dx */
	char *name;
{
	EEL_PTR *x;

	strlen(name);			/* check addressability */
	x = (EEL_PTR *)&name;		/* ds:dx has name */
	m_regs.w.ds = x->value.hiword;
	m_regs.w.dx = x->value.loword;

	return doscall(func);
}

os2namecall(func, name)	/* do os/2 function that takes string, then dword 0 */
	char *name;
{
	strlen(name);			/* check addressability */
	os2call("DOSCALLS", func, "", 4,
		get_pointer(name, SEGMENT),
		get_pointer(name, OFFSET), 0, 0, 0, 0);
	if (dllcall.error)
		errno = dllcall.error;
	else if (dllcall.result)
		errno = dllcall.result;
	else
		return 0;
	return -1;
}

do_call(func, name)
char *func, *name;
{
	char buf[80];

	sprintf(buf, "%s '%s' >&/dev/null", func, name);
	return shell("", buf, "");
}

#endif

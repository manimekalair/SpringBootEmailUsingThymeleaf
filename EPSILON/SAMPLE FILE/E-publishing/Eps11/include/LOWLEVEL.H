/************************************************** -*- tab-width:4 -*- *
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*	Copyright (C) 1986, 2001 Lugaru Software Ltd.  All rights reserved. *
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

// Windows functions

#define W16_32(w16, w32)	((is_gui == IS_WIN31) ? (w16) : (w32))
						// select correct value for Win16 or Win32 API's

// Access Registry functions in Windows

#define REG_DLL	(W16_32("shell.dll", "advapi32.dll"))
#define RegOpenKey(hkey, subkey, result)	(call_dll(REG_DLL, \
				W16_32("RegOpenKey", "RegOpenKeyA"), \
				"p", "LSP", hkey, subkey, result))
#define RegCreateKey(hkey, subkey, result)	(call_dll(REG_DLL, \
				W16_32("RegCreateKey", "RegCreateKeyA"), \
				"p", "LSP", hkey, subkey, result))
#define RegQueryValue(hkey, subkey, result, len) (call_dll(REG_DLL, \
												 W16_32("RegQueryValue", "RegQueryValueA"), \
												 "p", "LSPP", hkey, subkey, result, len))
#define RegQueryValueEx(hkey, subkey, type, result, len) (call_dll(REG_DLL, \
												 "RegQueryValueExA", "p", "LSPPPP", \
												  hkey, subkey, NULL, type, result, len))
#define RegCloseKey(hkey)		(call_dll(REG_DLL, \
				"RegCloseKey", "p", "L", hkey))
#define RegSetValue(hkey, subkey, type, value, len)  (call_dll(REG_DLL, \
				W16_32("RegSetValue", "RegSetValueA"), \
				"p", "LSLSL", hkey, subkey, type, value, len))

// Only HKEY_CLASSES_ROOT is defined in Win16 API.
#define HKEY_CLASSES_ROOT	(W16_32(1, 0x80000000))
#define HKEY_CURRENT_USER	(W16_32(error("Bad reg key"), 0x80000001))
#define HKEY_LOCAL_MACHINE	(W16_32(error("Bad reg key"), 0x80000002))
#define HKEY_USERS			(W16_32(error("Bad reg key"), 0x80000003))

#define REG_SZ						1	    /* string type */

// EEL Pointers

#define OFFSET	0		/* for get_pointer() calls */
#define SEGMENT	1

typedef struct eel_pointer {	/* format of EEL pointer */
	struct {
		short loword, hiword;
	} base, size, value;
} EEL_PTR;

//  DOS Definitions

typedef union {
	struct {		/* machine registers, for do_interrupt() */
		short	ax;
		short	bx;
		short	cx;
		short	dx;
		short	bp;
		short	si;
		short	di;
		short	es;
		short	ds;
		short	flags;
	} w;
	struct {		/* byte versions of same registers */
		char	al, ah;
		char	bl, bh;
		char	cl, ch;
		char	dl, dh;
	} b;
} M_REGS;

M_REGS m_regs;

#define CARRYFLAG	0x1
#define ZEROFLAG	0x40

#define DOS_SERVICES	0x21
#define VIDEO_IO	0x10

//  OS/2 Definitions

typedef struct {
	char *module, *proc;
	short result, error, count, stack[10];
} DLLCALL;

DLLCALL dllcall;

struct ModeData {
	short length;
	char type;
	char color;
	short col;
	short row;
	short hres;
	short vres;
	char fmt_ID;
	char attrib;
};

struct CursorData {
	short cur_start;
	short cur_end;
	short cur_width;
	short cur_attribute;
};

#define DOSQFSINFO	76	/* in doscalls */
struct FSAllocate {
	int filsys_id;
	int sec_per_unit;
	int num_units;
	int avail_units;
	short bytes_sec;
};

#define DOSGETDATETIME	33	/* in doscalls */
struct DateTime {
	char hour;
	char minutes;
	char seconds;
	char hundredths;
	char day;
	char month;
	short year;
	short timezone;
	char day_of_week;
};

#define DOSMKDIR	66
#define DOSRMDIR	80


#include "eel.h"
#include "colcode.h"
#include "browse.h"

	// These are the routines exported from this module.
int browser_find_match(char *filename, int *linenum, int n_fwd);
int browser_query(char *bsc_filename, char *symbol, int flags);

// This is a problem.  If the buffer named "Symbols" already
// exists, the "browse" command silently wipes it away.
// Perhaps this is less of a problem with buffer names
// like "grep", but here it is a real problem.

#define BROWSER_BUF "Symbols"

#define BSC_DLL "bsc.dll" /* Compiler-specific DLL file from Microsoft. */

// This takes the address of a pointer, and makes the pointer point
// to a BSC handle.
#define BSCOpen(browsefile, ppbsc) \
	  ((int) call_dll(BSC_DLL, \
						"BSCOpen", "c", "sr", browsefile, ppbsc))

// This takes a pointer to a BSC handle.
#define BSCClose(pbsc) ((int) call_dll(BSC_DLL, "BSCClose", "c", "p", pbsc))

#define BSCGetOverloadArray(pbsc, name, mbf, ppinst, pnum) \
						((int) call_dll(BSC_DLL, \
						"BSCGetOverloadArray", "c", "psirr", \
						pbsc, name, mbf, ppinst, pnum))


#define BSCIinstInfo(pbsc, inst, name, typ, atr) \
						((int) call_dll(BSC_DLL, \
						"BSCIinstInfo", "c", "pirpp", \
						pbsc, inst, name, typ, atr))

#define BSCFormatDname(pbsc, name) \
						((int) call_dll(BSC_DLL, \
						"BSCFormatDname", "c", "pp", \
						pbsc, name))

#define BSCGetDefArray(pbsc, inst, ppidef, pnum) \
	  ((int) call_dll(BSC_DLL, \
						"BSCGetDefArray", "c", "pirr", \
						pbsc, inst, ppidef, pnum))

#define BSCGetRefArray(pbsc, inst, ppidef, pnum) \
	  ((int) call_dll(BSC_DLL, \
						"BSCGetRefArray", "c", "pirr", \
						pbsc, inst, ppidef, pnum))


#define BSCIdefInfo(pbsc, idef, pmodname, plineno) \
						((int) call_dll(BSC_DLL, \
						"BSCIdefInfo", "c", "pirp", \
						pbsc, idef, pmodname, plineno))													  

#define BSCSzFrTyp(pbsc, typ) \
						((int) call_dll(BSC_DLL, \
						"BSCSzFrTyp", "c", "pi", \
						pbsc, typ))

#define BSCSzFrAtr(pbsc, atr) \
						((int) call_dll(BSC_DLL, \
						"BSCSzFrAtr", "c", "pi", \
						pbsc, atr))

#define BSCDisposeArray(pbsc, any_array) \
						((int) call_dll(BSC_DLL, \
						"BSCDisposeArray", "c", "pp", \
						pbsc, any_array))


/********************************************************/

int color_from;
int color_with;

change_color(color){
	    set_character_color(color_from, point, color_with);
		color_with = color;
		color_from = point;
}

use_red(){
	change_color(color_class c_string);
}
use_blue(){
	change_color(color_class c_function);
}
use_green(){
	change_color(color_class c_comment);
}
use_black(){
	change_color(color_class text);
}

//
// End of color stuff.
//



void get_inst_data(int *pbsc, int inst, char *sym_name, char *sym_descr)
{
	char sym_type[256];
	char sym_attr[256];
	char *undecor_name;
	char typ[1];
	short atr[1];

	BSCIinstInfo(pbsc, inst, &undecor_name, typ, atr);

	strcpy(sym_name, (char *) BSCFormatDname(pbsc, undecor_name));
	strcpy(sym_type, (char *) BSCSzFrTyp(pbsc, *typ));
	strcpy(sym_attr, (char *) BSCSzFrAtr(pbsc, *atr));
	
	sprintf(sym_descr, "%s%s%s",
					      sym_attr[0] ? sym_attr : "",
					      sym_attr[0] ? " " : "",
						  sym_type
	);
}

int dump_defs(int *pbsc, char *bsc_filename, char *symbol, int *insts, int num_insts)
{
	char sym_name[100];
	char sym_descr[256];
	int r = 0;
	int i, j;

	bufnum = zap(BROWSER_BUF);

	use_black(); bprintf("Browser File: ");
	use_blue();  bprintf("%s\n", bsc_filename);

	use_black(); bprintf("Symbol: ");
	use_blue();  bprintf("%s\n", symbol);
	
	use_black();bprintf("\n%s:\n", "Definitions");

	for (j = 0; j < num_insts; j++){
		int *defs, num_defs;
		int inst = insts[j];

		get_inst_data(pbsc, inst, sym_name, sym_descr);
		BSCGetDefArray(pbsc, inst, &defs, &num_defs);
		for (i = 0; i < num_defs; i++){
			char *modname;
			short line_num[1];
			BSCIdefInfo(pbsc, defs[i], &modname, line_num);
			r++;

			// The file name.
			use_black();
			bprintf("    %s(%d): ", modname, *line_num);

			// The symbol name.
			use_blue();
			bprintf("%s", sym_name);

			// The symbol description.
			use_green();
			bprintf(" (%s)", sym_descr);
			bprintf("\n");
			use_black(); // flush
		}
	}
	point = 0;
	return r;
}

/*
	This gathers def or ref data for the indicated symbol, using
	the indicated browser database.  All the data goes into a
	buffer, and the browser database is closed, and the dll is
	unloaded.  Subsequently, you can use browser_find_match()
	to retrieve information on the matches.
*/
int browser_query(char *bsc_filename, char *symbol, int flags)
{
	int *bsc;
	int *Inst, num_insts;
	int r = 0;

	save_var bufnum;

	// shut up, stupid eel compiler.
	flags = flags;
	if (BSCOpen(bsc_filename, &bsc) == 0)
		return -1;
	BSCGetOverloadArray(bsc, symbol, MBFALL, &Inst, &num_insts);	

	// flags will indicate defs or refs.
	r = dump_defs(bsc, bsc_filename, symbol, Inst, num_insts);

	if (num_insts)
		BSCDisposeArray(bsc, Inst);
	BSCClose(bsc);
		// We unload the DLL to be sure that all the resources are released.
	call_dll(BSC_DLL);
	return r;
}


#define BROWSER_ENTRY "    (.+)%(([0-9]+)%): "

/*
	This returns nonzero if there is a remaining match that hasn't
	been reported yet.  The filename and line number of the match
	are returned.  The n_fwd parameter says which match to report.
	n_fwd=1 means the next match, n_fwd=0 means the current match,
	n_fwd=-1 means the previous match, n_fwd=2 means the match after
	next, etc.
 */

int browser_find_match(char *filename, int *linenum, int n_fwd)
{
	int buf = name_to_bufnum(BROWSER_BUF);
	int dir = RE_FORWARD;
	char linestr[30];

	save_var bufnum;
	if (!buf)
		return 0;
	else
		bufnum = buf;

	if (n_fwd < 0){
		dir = RE_REVERSE;
		n_fwd = -n_fwd;
		to_begin_line();
	} else if (n_fwd > 0) {
		to_end_line();
	} else {			// n_fwd == 0: return current match again
		to_begin_line();
		n_fwd = 1;
	}
		
	while (n_fwd--){
		if (!re_search(dir, BROWSER_ENTRY))
			return 0;
	}
	grab(find_group(1, 1), find_group(1, 0), filename);
	grab(find_group(2, 1),  find_group(2, 0), linestr);
	*linenum = strtoi(linestr, 10);
	return 1;
}

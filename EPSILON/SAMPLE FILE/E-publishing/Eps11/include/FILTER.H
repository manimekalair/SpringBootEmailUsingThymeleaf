/************************************************** -*- tab-width:4 -*- *
* "Epsilon" is a registered trademark licensed to Lugaru Software, Ltd. *
*		"EEL" and "Lugaru" are trademarks of Lugaru Software, Ltd.		*
*																		*
*  Copyright (C) 1996, 2001 Lugaru Software Ltd.  All rights reserved.	*
*																		*
* Limited permission is hereby granted to reproduce and modify this		*
* copyrighted material provided that the resulting code is used only in *
* conjunction with Lugaru products and that this notice is retained in	*
* any such reproduction or modification.								*
************************************************************************/

/*
To change the available filters, edit this file, then compile and
load files.e (by editing files.e and running the compile-buffer
command on Alt-F3, for example).

The variable filter_str consists of pairs of strings.  The first
string says what to display in the dialog, while the second is a
Windows-style list of file pattterns, separated by semicolons.  For
example, the first string might be "Fortran files" and the second
string might be "*.for;*.f77".  Each string must be followed by a
"\0"; this lets Windows separate one string from the next.
*/

volatile char filter_str[] =
					"All Files *.*" "\0"	// Display this.
							  "*.*" "\0"	// Use this pattern.
					"C Files *.c;*.cpp;*.cxx;*.h;*.inl;*.idl;*.hpp;*.cs;*.e" "\0"
							"*.c;*.cpp;*.cxx;*.h;*.inl;*.idl;*.hpp;*.cs;*.e" "\0"
					"Perl Files *.pl;*.pm" "\0"
							"*.pl;*.pm" "\0"
					"Batch Files *.bat;*.cmd" "\0"
							"*.bat;*.cmd" "\0"
					"Text Files *.txt" "\0"
							"*.txt" "\0"
					"HTML Files *.html;*.htm;*.shtml;*.cfml;*.cfm;*.htx;*.asp"
							";*.asa;*.xml;*.cdf;*.osd;*.htt;*.wml;*.xst" "\0"
							"*.html;*.htm;*.shtml;*.cfml;*.cfm;*.htx;*.asp"
							";*.asa;*.xml;*.cdf;*.osd;*.htt;*.wml;*.xst" "\0"
					"Visual Basic Files *.bas;*.frm;*.vbs;*.cls" "\0"
							"*.bas;*.frm;*.vbs;*cls" "\0"
					"Python Files *.py" "\0"
							"*.py" "\0"
					"TeX Files *.tex;*.ltx;*.sty" "\0"
							"*.tex;*.ltx;*.sty" "\0"
					"Java Files *.java" "\0"
							"*.java" "\0"
					"Make Files *.mak;makefile" "\0"
							"*.mak;makefile" "\0"
					"Asm Files *.asm;*.inc;*.mac;*.s" "\0"
							"*.asm;*.inc;*.mac;*.s" "\0"
					"Lex Files *.y" "\0"
							"*.y" "\0"
					"INI Files *.ini" "\0"
							"*.ini" "\0";

volatile int filter_index = 2;		// Default to C Files above.
// Filter_index is the number of the default filter in the above list,
// counting from 1.

char custom_filter[FNAMELEN];	// Remember this user-typed pattern.

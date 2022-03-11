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

// Support reading and writing some Unicode files.

#include "eel.h"

command unicode_convert_encoding()
{
	int def, from, to, code, format;
	char *valid;

	if (matches_at(0, 1, "\xff\xfe")
			 || matches_at(2, 1, "<any><#0><any><#0>"))
		def = 'A';
	else if (matches_at(0, 1, "\xfe\xff")
			 || matches_at(2, 1, "<#0><any><#0><any>"))
		def = 'B';
	else
		def = 'C';
	sayput("Convert from? A=UTF-16 LE, B=UTF-16 BE, C=UTF-8, D=Latin1 [%c]: ",
		   def);
	from = get_key_response("ABCD", def);
	if (strchr("AB", from)) {
		sayput("Convert to? C=UTF-8, D=Latin1 [C]: ");
		valid = "CD";
		def = 'C';
	} else {
		sayput("Convert to? A=UTF-16 LE, B=UTF-16 BE [A]: ");
		valid = "AB";
		def = 'A';
	}
	to = get_key_response(valid, def);
	say("");
	if (from == 'C')
		code = CONV_TO_16;
	else if (from == 'D')
		code = CONV_TO_16 | CONV_LATIN1;
	else if (to == 'C')
		code = 0;
	else
		code = CONV_LATIN1;
	if (from == 'B' || to == 'B')
		code |= CONV_BIG_ENDIAN;
	if (!ask_unicode_translate(code))
			return;
	format = has_arg ? (iter ? FILETYPE_MSDOS : FILETYPE_UNIX)
			 : unicode_give_format(from < 'C');
	if (format == FILETYPE_MSDOS && from >= 'C')
		simple_re_replace(0, "\n", "\r\n");
	perform_conversion(bufnum, code);
	if (format == FILETYPE_MSDOS && from < 'C')
		simple_re_replace(0, "\r\n", "\n");
	point = 0;
	translation_type = (code & CONV_TO_16) ? FILETYPE_BINARY : format;
	say("Done.");
}

command set_unicode_encoding()
{
	int enc, now, def = 'C';

	iter = 1;
	if (file_io_converter == unicode_file_converter)
		def = (unicode_format & CONV_BIG_ENDIAN) ? 'B' : 'A';
	sayput("Save as Unicode encoding? A=UTF-16 LE, B=UTF-16 BE, "
		   "C=raw/8 bit [%c]: ", def);
	enc = get_key_response("ABC", def);
	if (enc == 'C') {
		file_io_converter = 0;
		make_mode();
		say("No UTF-16 encoding will be done.");
		return;
	}
	def = (unicode_format & CONV_LATIN1) ? 'B' : 'A';
	sayput("Treat the buffer as A=UTF-8, B=Latin 1 [%c]: ", def);
	now = get_key_response("AB", def);
	file_io_converter = unicode_file_converter;
	unicode_format = 0;
	if (enc == 'B')
		unicode_format |= CONV_BIG_ENDIAN;
	if (now == 'B')
		unicode_format |= CONV_LATIN1;
	make_mode();
}

// Is this conversion reversible?  Return nonzero if so.
// Leave point where problem is.

// If this is a Unicode-to-Latin 1 translation, return 0 if the buffer
// doesn't seem to be in UTF-16 format, or if it contains characters
// outside the Latin 1 set.

test_unicode_translate(int code)
{
	int t;

	save_var narrow_start = 0, narrow_end = 0;
	t = perform_conversion(bufnum, code | CONV_TEST_ONLY);
	if (t < 0)		// We could translate.
		return size() > 0;
	point = t;
	return 0;		// Go to 1st char w/o reversible translation.
}

// Ask for confirmation if the translation would lose info.  Returns 0
// if we should cancel.
ask_unicode_translate(int code)
{
	char msg[200];

	if (test_unicode_translate(code))
		return 1;
	sprintf(msg, "Some characters can't be represented in %s.  Proceed? ",
			(code & CONV_TO_16) ? "UTF-16" : (code & CONV_LATIN1)
			? "Latin-1" : "UTF-8");
	return ask_yn("Information will be lost", msg, "Yes", "No", 1);
}

// Return nonzero if this buffer contains the regex pattern anywhere,
// without moving point.
int buffer_contains_pattern(char *pat)
{
	save_var point = 0;
	return re_search(1, pat);
}

// Return the line translation format of the file, after any conversion
// from Unicode if necessary.  For Unicode, assume it's the subset we
// handle.  Going from Unicode, we can tell the right format.  Going to
// Unicode, we provide a default based on the OS.

unicode_give_format(int from_unicode)
{
	int ret = FILETYPE_MSDOS, def = is_unix ? FILETYPE_UNIX : FILETYPE_MSDOS;

	if (!from_unicode) {	// Is it a text file in 8-bit format?  Guess.
		if (buffer_contains_pattern("<Return|#0>"))
			return FILETYPE_BINARY;
		return def;
	}	// Is it a DOS text file in Unicode format?
	if (!buffer_contains_pattern("<#0><Return><#0><Newline>")) {
			// Not if it contains no CR/LF pair.
		if (buffer_contains_pattern("<#0><Newline>"))
			ret = FILETYPE_UNIX;
		else		// Unless it contains no newlines at all (so guess).
			ret = def;
		if (buffer_contains_pattern("<#0><Return>"))
			return FILETYPE_BINARY;
	}
	if (buffer_contains_pattern("<#0><Return><#0><^Newline|Return>"))
		return FILETYPE_BINARY;		// Bare CR, therefore binary.
	if (buffer_contains_pattern("<#0><#0>"))
		return FILETYPE_BINARY;		// A null, therefore binary.
	return ret;
}

unicode_translate(int code, int dos)
{
	int kibitz = size() > 100000;
	if (kibitz)
		noteput("Unicode conversion in progress...");
	save_var narrow_start = 0, narrow_end = 0;
	save_spot point = 0, mark;
	if ((code & CONV_TO_16) && dos)
		simple_re_replace(0, "\n", "\r\n");
	perform_conversion(bufnum, code);
	if (!(code & CONV_TO_16) && dos)
		simple_re_replace(0, "\r\n", "\n");
	if (kibitz)
		say("");
}

char *unicode_file_converter(int func)
{
	int write = (func & FILE_CONVERT_WRITE) != 0;
	int code = unicode_format;

	if (write)
		code |= CONV_TO_16;
	else
		code |= CONV_OMIT_BOM;
	if (func & FILE_CONVERT_ASK) {
		if (!(func & FILE_CONVERT_QUIET))
			return ask_unicode_translate(code) ? "OK" : NULL;
		if (test_unicode_translate(code))
			return "OK";
		save_var see_delay = 400;
		say("%s not converted from Unicode: not reversible.", filename);
		return NULL;
	}
	if ((func & FILE_CONVERT_READ)
		  && matches_at(0, 1, (code & CONV_BIG_ENDIAN) ? "\xff\xfe" : "\xfe\xff"))
		unicode_format ^= CONV_BIG_ENDIAN;
	if (func & (FILE_CONVERT_READ | FILE_CONVERT_WRITE))
		unicode_translate(code, translation_type == FILETYPE_MSDOS);
	if (write)		// Put temp copy of buffer in binary mode.
		translation_type = FILETYPE_BINARY;
	return " Unicode";
}

int unicode_on_read(int strip)
{
	int format, code = 0;

	if (unicode_use_latin1)
		code |= CONV_LATIN1;
	else if (unicode_detection == 2)
		save_var unicode_detection = 1;
	if (unicode_detection == 1)
		code |= CONV_REQUIRE_BOM;
	save_var point;
	if ((strip == FILETYPE_AUTO || file_io_converter == unicode_file_converter)
		  && unicode_detection) {
		int kibitz = size() > 100000;
		if (unicode_detection == 1 && (character(0) != 0xff
									   && character(0) != 0xfe))
			kibitz = 0;
		if (kibitz)
			noteput("Detecting Unicode...");
		if (test_unicode_translate(code)) {
			save_var modified;
			format = unicode_give_format(1);
			translation_type = format;
			file_io_converter = unicode_file_converter;
		} else if (kibitz)
			say("");
	}
}

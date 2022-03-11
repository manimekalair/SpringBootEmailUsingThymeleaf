/************************************************** -*- tab-width:4 -*- *
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

user char initial_tag_file[FNAMELEN] = "default.tag";
user char want_sorted_tags = 1;	/* want tags sorted when you press '?'? */
user short show_tag_line = 2; /* put tag on this line of window when finding */
user char tag_by_text = 1;	// record text of each tag line, not position
user char tag_relative = 1;	// if nonzero, use relative pathname for tags
user char tag_declarations = 0;	// 1: tag func declarations, 2: vars, 3: both
user char tag_ask_before_retagging = 0;	// Ask before retagging a file?
char tag_extern_decl;	// is this just a var declaration, or a definition?
char c_tagging_class[80]; // if not "", inside scope of this class def'n
char tag_pattern_default[] = "[a-zA-Z0-9_]+";
#define	TAGGED_FILES_BUF	"-tagged-files"
char tag_show_percent;	// Should status msg mention omit func names?
zeroed char tag_batch_mode;	// Don't stop on errors, just list them in a buffer.
char _last_tag[TAGLEN];
char _last_tag_file[FNAMELEN];	/* file last tag appeared in */
zeroed short _tags_buffer;	/* buffer number, for speed */
zeroed char tag_list_exact_only;	/* should listing for abc include abcde? */
user char tag_case_sensitive = 0; /* Are tags case-sensitive? */
zeroed char tags_from_bsc;
char bsc_file[FNAMELEN];

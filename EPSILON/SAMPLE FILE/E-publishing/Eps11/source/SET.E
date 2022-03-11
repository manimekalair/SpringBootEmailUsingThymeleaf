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

// This file has commands for setting and showing variables.

#include "eel.h"
#include "lowlevel.h"

char *get_var_val(i, tmp, def)	/* return value of variable with index i */
char *tmp;			/* (maybe in tmp), or 0 if bad type */
{
	char *p = tmp;

	save_var use_default = def;
	switch (vartype(i)) {
		case TYPE_CHAR:
		case TYPE_SHORT:
		case TYPE_INT:		sprintf(tmp, "%d", get_num_var(i));
					break;
		case TYPE_CPTR:		p = get_str_var(i);
					return p ? p : "<Null Pointer>";
		case TYPE_CARRAY:	strncpy(tmp, varptr(i),
						ptrlen(tmp) - 1);
					break;
		default:		return 0;
	}
	return p;
}

set_var_val(i, tmp, def)	/* set var at index i to tmp */
char *tmp;
{
	char when_setting[FNAMELEN];

	save_var use_default = def;
	if (strstr(" selected-color-scheme -our-mono-scheme -our-color-scheme "
			   "-our-gui-scheme -our-unixconsole-scheme ", name_name(i))
			   && isalpha(*tmp)) {
		if (name_type(find_index(tmp)) != NT_COLSCHEME)
			error("%s is not a color scheme", tmp);
		sprintf(tmp, "%d", find_index(tmp));
	}

	switch (vartype(i)) {
		case TYPE_CHAR:
		case TYPE_SHORT:
		case TYPE_INT:
			if (*tmp)
				set_num_var(i, numtoi(tmp));
			break;
		case TYPE_CARRAY:
			strncpy(varptr(i), tmp, ptrlen(varptr(i)) - 1); break;
		case TYPE_CPTR:
			set_str_var(i, strsave(tmp)); break;
	}
	sprintf(when_setting, "when-setting-%s", name_name(i));
	try_calling(when_setting);
}

safe_set_var_val(i, tmp, def)	/* set var at index i to tmp */
char *tmp;
{
	jmp_buf this_level;
	save_var top_level = &this_level;
	if (!setjmp(top_level))
		set_var_val(i, tmp, def);
}

command set_variable() on reg_tab[FKEY(8)]
{
	char res[80];
	int i;

	get_var(res, "Set variable", "", MUST_MATCH);
	i = find_index(res);
	if (name_type(i) != NT_VAR && name_type(i) != NT_BUFVAR
	    && name_type(i) != NT_WINVAR && name_type(i) != NT_BUILTVAR)
		error("%s: not a variable", res);
	save_var _show_help_on = res;
	do_set_variable(i);
}

command set_any_variable()
{
	save_var show_all_variables = 1;
	set_variable();
}

char *variable_type_name(i)	// translate type code into text
{
	switch (i) {
		case TYPE_CHAR:		return "character";
		case TYPE_SHORT:	return "short integer";
		case TYPE_INT:		return "integer";
		case TYPE_CARRAY:
		case TYPE_CPTR:		return "string";
	}
	return "other";
}

do_set_variable(i)
{
	char msg[80], res[FNAMELEN], *tname, *p, tmp[FNAMELEN];
	int def;

	tname = variable_type_name(vartype(i));
	if (!(p = get_var_val(i, tmp, 0)))
		error("Can't interpret type of %s", name_name(i));
	sprintf(msg, "Set %s variable %s to", tname, name_name(i));
	if (run_by_mouse && (has_feature & FEAT_GUI_DIALOGS)) {
		get_strpopup(res, msg, p, name_name(i));
		def = 1;			// set both
	} else {
		strcat(msg, ": ");
		get_strnone(res, msg, p);
		def = ask_default("Set", name_name(i), 1);
	}
	if (def)
		set_var_val(i, res, 1);		/* set default */
	if (def >= 0)
		set_var_val(i, res, 0);		/* set current */
	do_show_variable(name_name(i), def);
	full_redraw = 1;	/* might have set a display-type variable */
}

command show_variable() on reg_tab[FCTRL(8)]
{
	char res[80];

	save_var show_all_variables = 1;
	get_var(res, "Show variable", "", MUST_MATCH);
	do_show_variable(res, (var_settable(res) == 1) ? 1
				: ask_default("Show", res, 0));
}

do_show_variable(name, def)
char *name;
{
	char *vl = "Value", tmp[200], tmp2[20];
	int i, type, hasdef = 1;

	i = find_index(name);
	if (name_type(i) == NT_BUFVAR)
		vl = def ? "Default value" : "This buffer's value";
	else if (name_type(i) == NT_WINVAR)
		vl = def ? "Default value" : "This window's value";
	else if (name_type(i) == NT_VAR || name_type(i) == NT_BUILTVAR)
		hasdef = 0;
	else
		error("%s: not a variable", name);
	type = var_settable(name);
	if (!type)
		error("Can't interpret type of %s", name_name(i));
	else if (type == 1 && hasdef)
		say("Default value of %s is %s, and current value is %s",
			name_name(i), get_var_val(i, tmp, 1),
				get_var_val(i, tmp2, 0));
	else
		say("%s of %s is: %s", vl, name_name(i),
				get_var_val(i, tmp, def)); 
}

var_settable(name)	/* is variable settable? 1=number, 2=string, else 0 */
char *name;
{
	int i = find_index(name);

	if (i)
		switch (vartype(i)) {
			case TYPE_CHAR: case TYPE_SHORT: case TYPE_INT:
				return 1;
			case TYPE_CARRAY: case TYPE_CPTR:
				return 2;
		}
	return 0;
}

ask_default(ask, name, bothok)
char *ask, *name;	/* return -1 if we want default, 0=current, 1=both */
{
	int res = iter, type = name_type(find_index(name));

	iter = 0;
	if (type != NT_BUFVAR && type != NT_WINVAR || has_arg)
		return has_arg ? res : 0;
	sayput(bothok
		? "%s D=default value of %s, C=current value, or B=both? [B]"
		: "%s D=default value of %s or C=current value? [C]",
		ask, name);
	do {
		getkey();
	} while (!IS_TRUE_KEY(key));
	check_abort();	/* N means C for compatibility */
	switch (toupper(key)) {
		default:		if (bothok)
						return 1;
		case 'N': case 'C':	return 0;
		case 'D':		return -1;
	}
}

command create_variable()
{
	char res[80];
	int type = -1, ind, len = 1;

	iter = 0;
	save_var show_all_variables = 1;
	get_var(res, "Create variable", "", 0);
	do {
		sayput("Character, Short, Integer, or Array of characters"
		       " [C, S, I, A] ");
		getkey();
		check_abort();
		switch (toupper(key)) {
			case 'C': type = TYPE_CHAR; break;
			case 'S': type = TYPE_SHORT; break;
			case 'I': type = TYPE_INT; break;
			case 'A': type = TYPE_CARRAY;
				  len = get_number("Length of new variable: ");
				  break;
			default: if (IS_TRUE_KEY(key))
					 maybe_ding(bell_on_bad_key);
				 break;
		}
	} while (type < 0);
	ind = new_variable(res, NT_VAR, type, len);
	set_name_user(ind, 1);		/* make it a user variable */
	do_set_variable(ind);
}

command delete_name()
{
	char name[FNAMELEN];

	save_var show_mouse_choices = 1;
	get_any(name, "Delete (function, variable name...)", "");
	switch (drop_name(name)) {
		case 1: error("%s: not found", name); break;
		case 2: error("%s: in use", name); break;
	}
}

command change_name()
{
	char old[FNAMELEN], new[FNAMELEN], msg[FNAMELEN];

	save_var show_mouse_choices = 1;
	get_any(old, "Rename (function, variable name...)", "");
	if (!find_index(old))
		error("%s: not found", old);
	sprintf(msg, "New name for %s", old);
	get_any(new, msg, "");
	switch (replace_name(old, new)) {
		case 1: error("%s: not found!", old); break;
		case 2: error("%s exists, delete first", new); break;
	}
}

show_abort_key(keyname, akey)
char *keyname;
{
	*keyname = 0;
	if (akey >= 0)
		show_char(keyname, akey, 1);
	else
		strcpy(keyname, "disabled");
}

command set_abort_key()
{
	char keyname[FNAMELEN], msg[FNAMELEN];
	int newkey;

	iter = 0;
	show_abort_key(keyname, abort_key);
	mention("Set abort key (now %s) to (D to disable): ", keyname);
	do {
		newkey = getkey();
	} while (!IS_TRUE_KEY(newkey));
	user_abort = 0;
	show_abort_key(keyname, newkey);
	sprintf(msg, "Set abort key to %s? ", keyname);
	if (ask_yn("Set abort key", msg, "Yes", "No", 2)) {
		abort_key = (toupper(newkey) == 'D') ? -1 : newkey;
		say("The abort key is now %s", keyname);
		if (abort_key != -1)
			reg_tab[abort_key] = (short) abort;
		copy_bindings();	/* fix up changed bindings */
	} else
		say("No change.");
}

// Modify the provided state file name to point it to a home dir, or
// initialize it if it's "".

set_default_state_file_name(char *state_file)
{
	char fname[FNAMELEN], *p, newname[FNAMELEN];

	build_filename(fname, "%x%f", default_state_file_name);
	strcpy(newname, default_state_file_name);
	absolute(newname);
	// Force a different name if the original is read-only or the
	// suggested name differs from the usual one in the executable's
	// directory.
	if (opsys == OS_UNIX && *state_file && (strcmp(newname, fname)
											|| get_file_read_only(state_file) == 1)) {
				// Suggest first directory of EPSPATH.
		if (p = verenv("EPSPATH")) {
			strcpy(state_file, p);
			p = strchr(state_file, path_list_char);
			if (p)
				*p = 0;
		} else		// Or if none, off home dir.
			strcpy(state_file, "~/.epsilon");
		absolute(state_file);		// Strip off any trailing /.
		sprintf(state_file + strlen(state_file), "/%s",
				default_state_file_name);
	} else if (!*state_file)
		strcpy(state_file, default_state_file_name);
}

command write_state() on reg_tab[FCTRL(3)]
{
	char fname[FNAMELEN];

	set_default_state_file_name(state_file);
	save_var only_file_extensions = "|.sta|";
	if (quiet_write_state)
		strcpy(fname, state_file);
	else
		get_file(fname, "Write current state on file", state_file);
	if (!*fname)
		return;

	do_save_state(fname);
	strcpy(state_file, fname);
	iter = 0;
}

do_save_state(fname)		/* save state in file, aborting on error */
char *fname;
{
	int err;
	char file[FNAMELEN], backupname[FNAMELEN];

	strcpy(file, fname);
	copy_bindings();	/* fix up changed bindings */
	sayput("Writing...");

	strcpy(get_extension(file), state_extension);
	if (want_state_file_backups) {
		build_filename(backupname, state_file_backup_name, file);
		make_backup(file, backupname);
	}
	if (err = save_state(file)) {
		file_error(err, file, "write error");
		maybe_ding(bell_on_write_error);
		quick_abort();
	} else
		say("State saved on %s.", file);
}

make_registration_entry(name, val)
char *name, *val;
{
	RegSetValue(HKEY_CLASSES_ROOT, name, REG_SZ, val, strlen(val));
}

command create_file_associations()
{
	int buf = zap("File Associations");
	char ext[FNAMELEN], cmd[FNAMELEN], dir[FNAMELEN], tmp[FNAMELEN];

	tiled_only();
	save_var window_bufnum;
	to_buffer_num(buf);
	stuff("# Associate Epsilon with the following extensions:\n\n");
	stuff("# Delete or add lines as required, then type Ctrl-X Ctrl-Z\n");
	stuff("# (the exit-level command) to carry out the change.  This\n");
	stuff("# command cannot remove existing Epsilon associations, only\n");
	stuff("# add new ones.  Changes you make here cannot be undone by\n");
	stuff("# uninstalling; make new associations using Windows Explorer\n");
	stuff("# or by running this command again.\n");
	stuff("\n.c\n.cpp\n.h\n.e\n.txt\n");
	conf_mode();
	for (;;) {
		recursive_edit();
		if (strcmp(bufname, "File Associations"))
			error("Canceled.");
		point = 0;
		if (!re_search(1, "^%.(exe|bat|cmd)$"))
			break;
		say("Don't modify the association for .exe, .bat, or .cmd files.");
	}
	make_registration_entry("Epsilon", "Epsilon");
	get_executable_directory(dir);
	strcpy(tmp, argv[0]);
	absolute(tmp, dir);
	if (is_gui == IS_WIN31)
		sprintf(cmd, "%s %%1", tmp);
	else
		sprintf(cmd, "\"%s\" \"%%1\"", tmp);
	make_registration_entry("Epsilon\\shell\\open\\command", cmd);
	make_registration_entry("Epsilon\\shell\\open\\ddeexec", "\"%1\"");
	make_registration_entry("Epsilon\\shell\\open\\ddeexec\\application",
							"Epsilon");
	make_registration_entry("Epsilon\\shell\\open\\ddeexec\\topic",
							"Open");
	point = 0;
	while (point < size() - narrow_end) {
		grab_line(bufnum, ext);
		if (*ext == '.')
			make_registration_entry(ext, "Epsilon");
		else if (*ext && *ext != '#')
			say("Ignoring invalid extension \"%s\"", ext);
	}
	restore_vars();
	buf_delete(buf);
	say("File associations created.");
}

ev_template()		// Replaced by functions below.
{
	error("Error in eval or execute-eel.");
}

void eval_template(char *expr, char *src)
{
	char quoted[300], *p, *q;

	save_var bufnum = zap(src);
	for (p = expr, q = quoted; *q = *p; p++, q++)
		if (*p == '"') {
			*q++ = '\\';
			*q = '"';
		}
	bprintf("#include <eel.h>\n");
	bprintf("ev_template(){\n");
	bprintf("  if (sizeof(%s) <= sizeof(int))\n", expr);
	bprintf("    say(\"%s == %%d\", (%s));\n", quoted, expr);
	bprintf("  else\n");
	bprintf("    say(\"%s == %%s\", (%s));\n", quoted, expr);
	bprintf("}\n");	
}

command eval()
{
	char expr[200], *src = temp_buf();

	get_string(expr, "Expression: ");
	eval_template(expr, src);

	// Compiles the buffer src, the status messages go into the
	// buffer named "eval-comp".
	if (eel_compile(src, 0, "-s", "eval-comp") != 0){
		to_buffer("eval-comp");
		delete_buffer(src);
		error("Cannot evaluate expression.");
	}
	delete_buffer(src);
	ev_template();
}

void execute_eel_template(char *expr, char *src)
{
	save_var bufnum = zap(src);
	bprintf("#include <eel.h>\n");
	bprintf("ev_template(){ %s; }\n", expr);
}

command execute_eel()
{
	char expr[200], *src = temp_buf();

	get_string(expr, "Execute EEL statement: ");
	execute_eel_template(expr, src);

	// Compiles the buffer src, the status messages go into the
	// buffer named "eval-comp".
	if (eel_compile(src, 0, "-s", "eval-comp") != 0){
		to_buffer("eval-comp");
		delete_buffer(src);
		error("Could not compile EEL statement.");
	}
	delete_buffer(src);
	ev_template();
}

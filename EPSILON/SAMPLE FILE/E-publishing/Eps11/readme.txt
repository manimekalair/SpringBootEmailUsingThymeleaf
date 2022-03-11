Notes on Epsilon 11.00

This file describes changes since the first beta version of Epsilon
11, including changes since version 11.00.  See
http://www.lugaru.com/rel-11.html or the online manual for descriptions
of all new features since Epsilon 10.

Epsilon's complete manual is included in various electronic forms.
Info format can be read from within Epsilon.  The HTML version of the
manual can be read with a web browser.  A WinHelp version is also
included on Windows platforms.  Press F1 followed by F, H, or W,
respectively, to access each version.


******************************************************************

Changes between Epsilon 11.00 Beta 6 and Epsilon 11.00
======================================================

Visual Basic indenting now correctly indents lines following If
statements that end in comments.

Coloring of embedded scripts in HTML mode is faster.

In Epsilon for Unix running in console mode (not as an X program), the
-add flag no longer makes Epsilon crash.


Changes in Beta 6
=================

The refresh-files command now shows progress messages as it works.

The grep-default-directory variable now understands additional settings.

Filling comments now works on JavaScript embedded in html.

F1 in some dialogs now displays help on the current command, instead
of prompting for what type of help you want.

The process-warn-on-exit variable is now 0 by default.

The new variable vbasic-indent-subroutines lets you say whether
subroutine bodies should be indented.

Button dialogs in the Windows GUI version now understand Alt-letter
responses, so you can press Alt-Y or Alt-N instead of Y or N.


Bugs Fixed in Epsilon 11 B6
---------------------------

Some HTML embedded scripting bugs were fixed.

Various Visual Basic indenting bugs were fixed.  <Enter> in Visual
Basic mode now indents.

Ftp isn't as picky about the PASV messages it recognizes, and it fails
more cleanly when it doesn't recognize one.

When you tried to write a file via ftp and an ftp job was already
running in that buffer, Epsilon could clear the modified flag before
reporting an error.

Grep on buffers now does prefix matches only if you put * at the end
of the pattern.

Completion for info mode commands M and F works better when nodes
names contain spaces.

Sending a file pattern to an existing instance of Epsilon now does a
dired.

Perl coloring now understands the $#var syntax in interpolated contexts.

Shell coloring no longer gets confused by backslashed single quote
characters.

The pull-word command now fails more cleanly in read-only buffers.

Word searching now works better when the pattern has punctuation at
its edges.

Setting the preserve-session variable failed to override the -p flag.

The export-colors command failed to declare some color class
references it generated.

The toggle-scroll-bar command, which does nothing in the Windows GUI
version, now provides an error message in that environment.

Tagging c-mode files no longer gets confused by certain #if/#endif
combinations when matching braces.

******************************************************************


Changes in Beta 5
=================

Editing scripting embedded in HTML files now works more like editing a
script in a stand-alone file.  Auto-indenting, delimiter matching and
other features now work in embedded scripts.  Epsilon now recognizes
various JSP tags as scripting.

The Alt-p and Alt-n commands that retrieve previous commands in the
process buffer now display a menu of previous commands when given a
numeric prefix argument.  You can select a previous command from the
list.

Deleting a process buffer tries to make it exit first, using the
exit-process command.

Set the new variable process-warn-on-exit if you want Epsilon to warn
you whenever you try to exit with an active concurrent process that
doesn't respond to an exit command.

Setting message-history-size to zero makes Epsilon avoid creating a
#messages# buffer for most messages.

Under X, if you set the new server-raises-window variable nonzero, the
-add and -wait flags cause the server instance of Epsilon to try to
raise itself in the window order, as under MS-Windows.

The new refresh-files command makes Epsilon check each buffer to see
if its associated file has been modified on disk, just as if you had
switched to every buffer in turn.

In man mode, double-clicking selects a word as usual whenever you
click on something that doesn't look like a link to another man page.

The commands uniq, keep-unique-lines, and keep-duplicate-lines now
ignore case when determining if lines match whenever case-fold is nonzero.

A file whose reading was aborted is no longer recorded in a session file.

Tagging .cs files works now.

In Epsilon for Windows, the Open With Epsilon shell content menu now
uses a shell extension dll, and should work more reliably.

The new set-unicode-encoding command lets you change what encoding
conversion Epsilon will do when you save the current buffer.

The c-look-back variable is now 100,000 by default, so indenting
should be more accurate on very large functions.

The show-point command now shows UTF-8 info on the current character
in buffers that contain UTF-8 text.

The -p flag now affects only the current session, not the setting of
the preserve-session variable in the state file.

You can create a no-expiration-warning file to disable Epsilon's
warning about an upcoming expiration date.  The file can now contain a
number, which indicates how many days warning you want before the
expiration date.  If there's no number, Epsilon never warns.
(Disabling or postponing the warning doesn't affect the expiration
date, only the warning period before.)

When Epsilon uses an ftp url under Windows, it now tries to work
around a bug in certain firewall client software.

With a numeric prefix argument, the send-invisible command omits
sending newline after the text you enter.

Keys using the Ctrl-C prefix key are now accessible when you use the
CUA key bindings.  Press Ctrl-K instead of Ctrl-C.

Info's G subcommand now performs completion when you press <Space>.

Under Windows NT/2000/XP, setting use-process-current-directory to 2
tells Epsilon that changes in the process's current directory should
also change Epsilon's current directory.

Setting a color scheme variable with the -d flag or set-variable now
recognizes scheme names, not just numeric index values.

Epsilon now uses Visual Basic mode for files with a .vbs extension,
and recognizes more files as HTML based on their content.


Bugs Fixed in Epsilon 11 B5
---------------------------

Process buffer completion now appropriately quotes file names that
contain spaces.

Dired could sometimes create two dired buffers showing the same
directory, differing only in the presence or absence of a / or \ at
the end of the directory name.

The commands file-query-replace and retag-files now handling
aborting better.

A live link window no longer restricts movement in its dired buffer.

Some bugs in C mode's parsing of initializers were fixed.

Printing a hex listing in Epsilon for Windows no longer omits the
original file's name.

Process buffer completion should no longer generate errors if your
path is over 500 characters or so.

Setting the sentence-end-double-space variable now offers to change
the sentence-end variable too, to produce consistent behavior.

Hex mode didn't always work right if case folding was off by default.

The delay() primitive in Windows didn't return when a process exited.

Epsilon didn't handle file date messages in the grep buffer correctly.


******************************************************************


Changes in Beta 4
=================

When Epsilon detects a Unicode UTF-16 file, it no longer translates to
Latin 1 by default, but to UTF-8.  This has the advantage that any
valid UTF-16 file may now be edited.  When Epsilon displays a UTF-16
file as UTF-8, any Unicode characters outside the 7-bit ASCII range of
0-127 will be shown as multi-byte sequences of graphic characters.

Set unicode-use-latin1 nonzero if you prefer a translation to Latin 1.
This mode represents Unicode characters in the range 0-255 with the
appropriate glyph.  But unlike UTF-8, this translation cannot be used
if the file contains any characters outside that range.  If you read
such a file with unicode-use-latin1 set nonzero, Epsilon will display
it in its original binary UTF-16 format.

As before, the translations above happen automatically when you read
and write UTF-16 files.  Also, all Unicode operations are now much
faster.

The manual translation commands latin1-to-unicode and
unicode-to-latin1 have been replaced by the new command
unicode-convert-encoding.  It asks what type of conversion to do.  It
can translate from the 16-bit encodings UTF-16 LE and UTF-16 BE to the
8-bit encodings UTF-8 and Latin 1, and back.

The o command in hex mode is now a toggle that makes all printing keys
overwrite buffer text in the last column.  Since commands like q and s
overwrite in that submode, you must a Ctrl-c prefix to use these
commands from hex overtype mode when the cursor is in the last column.
You can set the variable hex-overtype-mode if you want Epsilon to
start in this mode.  Searching and other bugs in hex mode were fixed.

HTML mode is better at recognizing the language of an embedded script.
Embedded VBscript now use Visual Basic indenting.

Epsilon now uses HTML mode for .xst files, and files that start with
<xst>.

Visual Basic mode defines two new color classes that let you customize
it.

Epsilon now recognizes .cs files as C-Sharp and uses a flavor of C
mode for them.  The compile-csharp-cmd variable tells compile-buffer
how to compile such programs.

Dired's live link subcommand more clearly indicates its actions.  The
new dired-live-link-limit variable controls the size of the largest
file it will display.

Various additional messages now appear in the #messages# buffer.

The telnet command now interprets the host:port syntax at its prompt.


Bugs Fixed in Epsilon 11 B4
---------------------------

The pull-word command's highlighting no longer prevents closing
Epsilon's window, using a menu command, or similar actions.

The Send To Epsilon menu item works again under Windows 2000, as do
other uses of the sendeps.exe program that quote its file name
parameter.

Aborting a concurrent process now works even when Epsilon for Unix is
invoked directly by certain window managers.

Epsilon for Unix now exits with a suitable message whenever it
determines that it cannot get user input (due to </dev/null for
instance).

Timed messages during prompting, such as generated by key sequences
such as Ctrl-S Ctrl-Q or Ctrl-X Ctrl-F Ctrl-X =, again display
correctly.

Python coloring no longer gets confused by \ quoting within strings.

Running the list-definitions command when there's already a
list-definitions window no longer causes trouble.


Changes to Primitives in Epsilon 11 B4
--------------------------------------

int perform_conversion(int buf, int flags)

The perform_conversion() primitive converts between 16-bit Unicode
UTF-16 encodings and the 8-bit encodings Latin 1 and UTF-8.  It
converts the specified buffer buf in place.  Flags control its
behavior.

With no flags set, it converts from the UTF-16 LE encoding to the
UTF-8 encoding.  The CONV_TO_16 flag makes it convert in the opposite
direction, from an 8-bit encoding to a 16-bit one.  The CONV_LATIN1
flag makes it convert to or from Latin 1 instead of UTF-8.

The primitive returns -1 if it succeeded.  If the buffer contained
characters that could not be represented in the new format, or byte
sequences invalid in the old format, it generates default characters
or skips past the invalid text as appropriate, and returns the offset
in the modified buffer of the first such difficulty.  With the
CONV_TEST_ONLY flag, it does not modify the buffer, but only returns a
result code indicating the location of the problem, if any, in the
unmodified buffer.

By default, the primitive converts to or from the UTF-16 LE ("little
endian") encoding.  With the CONV_BIG_ENDIAN flag, it generates or
reads UTF-16 BE instead.  However, if the conversion is from, not to,
a 16-bit format, and the buffer begins with a byte order mark (BOM)
that indicates its endianness, the primitive ignores the
CONV_BIG_ENDIAN flag and uses the BOM to determine the endianness.

By default, the resulting buffer begins with a byte order mark (unless
the translation is to Latin 1, which defines no BOM).  Add the
CONV_OMIT_BOM flag to omit it.  Combine the CONV_TEST_ONLY flag with
CONV_REQUIRE_BOM to have the primitive return an error indication if
the buffer lacks a suitable BOM.

CONV_REQUIRE_BOM without CONV_TEST_ONLY returns an error code if the
buffer lacks a BOM, but converts anyway.  For conversions from Latin
1, CONV_REQUIRE_BOM has no effect.  For conversions from UTF-16, if
there's a valid UTF-16 byte order mark, but its endianness doesn't
match the specified CONV_BIG_ENDIAN flag, CONV_REQUIRE_BOM won't
return an error indication.  Either UTF-16 LE or UTF-16 BE byte order
marks are accepted.

The primitive handles aborting by interpreting the abort_searching
variable.  Set it to 0 to have it ignore the abort key and continue,
ABORT_JUMP to have it jump by calling the check_abort() primitive, or
ABORT_ERROR to have it stop the conversion and return an ABORT_ERROR
code.

int show_text(int column, int time, char *fmt, ...)

The show_text() primitive understands some additional parameter
values.  The call show_text(-2, 1, fmt) records the specified message
in the #messages# buffer without displaying anything.  The call
show_text(0, 1, fmt) displays a message ephemerally, like note(msg),
but unlike note(), it also records the message in #messages#.

int get_key_response(char *valid, int def)

The get_key_response() subroutine waits for the user to type a valid
key in response to a prompt.  The parameter valid lists the acceptable
characters, such as "YN" for a yes/no question.  (But see the ask_yn()
subroutine, more suitable for yes/no questions.)  The def parameter,
if greater than zero, indicates which key should be the default if the
user presses <Enter>.  The subroutine returns the selected key.

EEL now permits structure assignment.


******************************************************************

Changes in Beta 3
=================

Python and Vbasic modes now show the current function name in the mode line.

Vbasic mode now does tagging, and the list-definitions command (Alt-') works.

Hex mode has a new o command to overtype part of the buffer with new
text.

The new-c-comments variable is now 1 by default, so comment-creating
commands now make // comments, not /* */ comments.

Certain made-up file names used internally by the new-file command and
similar (like "new1.c" and "startup") should no longer confuse Epsilon
if they also occur as actual file names.

The button_dialog() primitive and the ask_yn() subroutine now work
properly if button labels use an & character to indicate an underlined
access key.

The -l and -r flags no longer fail when certain flags without
parameters appear immediately before them.

The check_file() primitive now recognizes URL's and returns CHECK_URL
for them.

When non-GUI versions of Epsilon show a list of choices at a prompt,
they now remove highlighting for the current choice when the cursor
moves from the list of choices to the echo area.

If the default file pattern in grep is very long, Epsilon now displays
a truncated version, instead of letting the prompt consume most of the
echo area.

Oem file conversion commands fail more gracefully under platforms
where they're not supported.

Unicode files now distinguish text from binary in a different fashion,
fixing several problems.

Unicode or Oem files, when restored in a session, no longer cause
session restoring to fail if they're read-only.

Unicode or Oem files, when restored in a session, no longer make
Epsilon prompt if their conversion is non-reversible; instead Epsilon
skips the conversion.

The count-lines command now reports the right size on disk for a
Unicode file.

Dired's live link feature now splits a single window vertically, not
horizontally, with a numeric argument.  It's more reliable too.

Process buffer completion now works with a very long PATH setting.

Under Windows 95/98/ME, Epsilon now correctly truncates input lines in
the concurrent process buffer that are too long for the subprocess.

A file_io_converter function may now receive a FILE_CONVERT_QUIET
flag.  The file_convert_read() function now takes a flag parameter.

The configuration variables CMDSHELLFLAGS and CMDCONCURSHELLFLAGS that
specify the flags that tell a shell to run a program and then exit may
now include a %% sequence to indicate that the command should be
interpolated into the flag setting at that point, not appended after
the flags.

The new use-grep-ignore-file-extensions variable makes it easier to
temporarily make grep look through binary files that would normally be
excluded.

HTML mode coloring has some bug fixes, and now recognizes numeric
hexadecimal entities.

Perl mode no longer permits here documents that use the shell-only
syntax "<<-eof", while shell mode now permits here documents that use
the non-Perl syntax "<< eof".

The find-linked-file command sometimes failed to set a bookmark in the
process buffer.

Epsilon now handles a concurrent process's current directory under
NT/W2K as documented.

Password recognition in process buffers now works better.

Tagging no longer fails on some longer file names or lines, and it handles
aborting during tagging better.

The EEL compiler now warns when a macro is redefined with a different value.

Key repeating in Windows now happens in some situations where it was
previously suppressed, like the switch-buffers command on Ctrl-Tab.

The shift_pressed() primitive is more reliable under X when the focus
changes, and as a result the Ctrl-Tab command now works properly under
additional window managers.

******************************************************************

Lugaru Software, Ltd.
1645 Shady Avenue
Pittsburgh, PA  15217

Tel: (412) 421-5911
Fax: (412) 421-6371
Internet: support@lugaru.com

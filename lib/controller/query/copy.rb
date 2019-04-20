#!/usr/bin/ruby
	
module SafeDb

  # The copy use case copies one or more chapters, one or more verses and
  # one or more lines to the clipboard so Ctrl-v can be used outside the
  # safe to paste data in (like complex passwords).
  #
  # Use {Drag} and {Drop} to move data between books, chapters, verses and
  # lines.
  #
  # Visit documentation at https://www.safedb.net/docs/copy-paste
  class Copy < QueryVerse

    # this entity can point to a book, chapter, verse or line. If no
    # parameter entity is provided, the --all switch must be present
    # to avoid an error message.
    attr_writer :entity

    # The copy use case copies one or more chapters, one or more verses and
    # one or more lines to the clipboard so Ctrl-v can be used outside the
    # safe to paste data in (like complex passwords).
    def query_verse()

      print @verse[ @key_name ]

=begin

From xclip man page

EXAMPLES
       I hate man pages without examples!

       uptime | xclip

       Put your uptime in the X selection. Then middle click in an X application to paste.

       xclip -loops 10 -verbose /etc/motd

       Exit after /etc/motd (message of the day) has been pasted 10 times. Show how many  selection  requests  (pastes)
       have been processed.

       xclip -o > helloworld.c

       Put the contents of the selection into a file.

       xclip -t text/html index.html

       Middle click in an X application supporting HTML to paste the contents of the given file as HTML.



7[0;64r8[1A[Japollo@unity:~$ xclip -o
Constant Summaryapollo@unity:~$ 
apollo@unity:~$ xclip -o; echo
Constant Summary
apollo@unity:~$ xclip -o; echo
Module: Clipboard::File
apollo@unity:~$ xclip -o; echo
character of the selection specified
apollo@unity:~$ xclip -o; echo
long as they remain unambiguous
apollo@unity:~$ xclip -o; echo
long as they remain unambiguous
apollo@unity:~$ xclip -o; echo
long as they remain unambiguous
apollo@unity:~$ xclip -i ''
xclip: : No such file or directory
apollo@unity:~$ xclip -o; echo
long as they remain unambiguous
apollo@unity:~$ xclip ''
xclip: : No such file or directory
apollo@unity:~$ xclip -o; echo
long as they remain unambiguous
apollo@unity:~$ xclip -t ''
q
adsf


apollo@unity:~$ 
apollo@unity:~$ 
apollo@unity:~$ uptime | xclip
apollo@unity:~$ xclip -o; echo
 00:34:46 up  5:10,  1 user,  load average: 0.47, 0.52, 0.35

apollo@unity:~$ uptime
 00:35:05 up  5:11,  1 user,  load average: 0.34, 0.48, 0.34
apollo@unity:~$ uptime | xclip
apollo@unity:~$ xclip -o
 00:35:29 up  5:11,  1 user,  load average: 0.22, 0.44, 0.33
apollo@unity:~$ xclip -o
 00:35:29 up  5:11,  1 user,  load average: 0.22, 0.44, 0.33
apollo@unity:~$ xclip -o
 00:35:29 up  5:11,  1 user,  load average: 0.22, 0.44, 0.33
apollo@unity:~$ xclip -o
Error: target STRING not available
apollo@unity:~$ xclip -o
Error: target STRING not available
apollo@unity:~$ xclip -o
Error: target STRING not available
apollo@unity:~$ xclip -o
       apollo@unity:~$ 
apollo@unity:~$ xclip -o; echo
       
apollo@unity:~$ xclip -o; echo
instead  of  -display.  However,  -v couldn't be used because it is ambiguous (it could be short for -verbose or
apollo@unity:~$ xclip -o; echo
0345 072 5555
apollo@unity:~$ echo "safe deleted clipboard contents" | xclip
apollo@unity:~$ xclip -o; echo
safe deleted clipboard contents

apollo@unity:~$ xclip -o; echo
 (traditionally with the middle mouse button
apollo@unity:~$ xclip -o; echo
safedb.yijx-r7zr.19093.1515.01.676152709.json

=end


    end


  end


end

#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  # This Clip class reads, writes and overwrites text that either has been
  # placed in, or will be placed in the clipboard.
  #
  # == xclip pre-condition
  #
  # xclip must be installed using `sudo apt install --assume-yes xclip`
  class Clipboard


    # Get the first line of text from the clipboard. Raise an exception
    # if the clipboard either has no text, or the text is empy, or the
    # text consists solely of whitespace.
    #
    # The text will be trimmed before being returned so any leading or
    # trailing whitespace will be removed.
    #
    # For **multiple line** text, the first line that is non-empty and
    # non whitespace only is returned.
    #
    # Due to the sensitive nature of the text the clipboards contents will
    # be immediately overwritten once the pertinent textual content has
    # been consumed.
    #
    # @raise [RuntimeError] if text is nil, empty or consists solely of whitespace
    # @return [String] trimmed version of the clipboard's contents
    def self.read_password()
      
      log.info(x) { "About to read a sensitive password from the clipboard." }
      password_text = read_line()
      put( "safe has overwritten clipboard contents." )
      return password_text

    end


    # Put the parameter text into the clipboard thus overwriting whatever
    # content may or may not exist there.
    #
    # @param text_line [String] the text line to put in the clipboard
    def self.put( text_line )

      log.info(x) { "Putting text into the clipboard thus overwriting existing content." }
      clipboard_put_command = "printf #{text_line} | xclip -selection c"
      system clipboard_put_command

    end


    # Get the first line of text from the clipboard. Raise an exception
    # if the clipboard either has no text, or the text is empy, or the
    # text consists solely of whitespace.
    #
    # The text will be trimmed before being returned so any leading or
    # trailing whitespace will be removed.
    #
    # For **multiple line** text, the first line that is non-empty and
    # non whitespace only is returned.
    #
    # @raise [RuntimeError] if text is nil, empty or consists solely of whitespace
    # @return [String] trimmed version of the clipboard's contents
    def self.read_line()
      
      log.info(x) { "About to read and process a text line from the clipboard." }
      log.info(x){ "Which Operating System is running? #{OpSys.get_host_os_string()}" }

      xclip_command = OpSys.is_mac_os?() ? "pbpaste" : "xclip -o"
      textual_content = %x[ #{xclip_command} ]
      no_content = textual_content.nil?() || textual_content.chomp().strip().empty?()
      raise RuntimeError, "The clipboard does not contain any text." if no_content
      clipboard_text = textual_content.chomp().strip()
      num_lines = clipboard_text.lines.count()
      return clipboard_text if num_lines == 1

      log.info(x) { "Clipboard text has #{num_lines} lines - will return first viable line." }

      clipboard_text.each_line do |text_line|
        candidate_line = text_line.chomp.gsub("\\n","").strip()
        return candidate_line unless candidate_line.empty()
      end

      raise RuntimeError, "The multi-line clipboard text contained no printable characters."

    end


  end


end

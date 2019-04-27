#!/usr/bin/ruby
	
module SafeDb

  # The <b>rename use case</b> when applied at the verse level changes the
  # stated <em>line keyname</em>.
  #
  class Rename < EditVerse

    # The id of the current chapter, verse or line entity to be renamed is
    # the now_name and its new name is the new_name.
    attr_writer :now_name, :new_name

    # Find the line key named now_name and replace it with the provided
    # new_name. The validation for keynames applies, both must be provided and
    # the now_name must exist. This use case also renames file keys.
    def edit_verse()

# @todo refactor to recognise file values using isMap rather than the string prefix
# @todo refactor the Remove, Show, Read and Write use cases as well as this one.

      exit(100) unless has_line?()

      current_value = @verse[ @now_name ]

# @todo instead of store and delete use the hash key rename method
      @verse.store( @new_name, current_value ) unless is_file?()
      @verse.store( "#{Indices::INGESTED_FILE_LINE_NAME_KEY}#{@new_name}", current_value ) if is_file?()

      @verse.delete( "#{Indices::INGESTED_FILE_LINE_NAME_KEY}#{@now_name}" )
      @verse.delete( @now_name )

    end


    private


    def is_file?()
      return @verse.has_key?( "#{Indices::INGESTED_FILE_LINE_NAME_KEY}#{@now_name}" )
    end

    def has_line?()

      return true if( @verse.has_key?( @now_name ) || @verse.has_key?( "#{Indices::INGESTED_FILE_LINE_NAME_KEY}#{@now_name}" ) )
      @book.print_book_mark()
      puts ""
      puts "Line [ #{@now_name} ] is not in this chapter/verse."
      puts ""
      return false

    end

  end


end

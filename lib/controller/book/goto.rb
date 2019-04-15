#!/usr/bin/ruby

module SafeDb

  # Goto is a shortcut (or alias even) for the open command that takes an integer
  # index that effectively specifies which chapter and verse to open.
  #
  # Use <b>view</b> to list the valid integer indices for each chapter and verse
  # combination.
  #
  # View maps out and numbers each chapter/verse combination.
  # Goto with the number effectively shortcuts the open pinpointer.
  # Show prints out the verse lines at the opened path but masks any secrets.
  # Tell also prints out the verse lines but unabashedly displays secrets.
  class Goto < UseCase

    # The index (number) starting with 1 of the envelope and key-path
    # combination that should be opened.
    attr_writer :index

    def execute

      book = Book.new()
      goto_location = 0
      book.branch_chapter_keys().each_pair do | chapter_name, chapter_keys |

        chapter_data = Content.unlock_chapter( chapter_keys )
        chapter_data.each_key do | verse_name |

          goto_location += 1
          next unless @index.to_i == goto_location

          open_uc = Open.new
          open_uc.chapter = chapter_name
          open_uc.verse = verse_name
          open_uc.flow()

          return

        end


      end


    end


  end


end

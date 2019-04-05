#!/usr/bin/ruby

# --
# -- Reopen the core ruby Dirctory class and add the below methods to it.
# --
class Dir

  # --
  # -- Put all the files starting with the given string in
  # -- alphabetical ascending order and then return the file
  # -- that comes last.
  # --
  # -- Throw an exception if no file in this folder starts
  # -- with the given string
  # --
  def ascii_order_file_starting_with starts_with_string

    recently_added_file = nil
    filepath_leadstr = File.join self.path, starts_with_string
    Dir.glob("#{filepath_leadstr}*").sort.each do |candidate_file|

      next if File.directory? candidate_file
      recently_added_file = candidate_file

    end

    Throw.if_nil recently_added_file
    Throw.if_not_exists recently_added_file
    return recently_added_file

  end



end

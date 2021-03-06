#!/usr/bin/ruby
	
module SafeDb

  # The <b>set <em>use case</em></b> is the generic tool for setting book scoped
  # configuration directives. These directives can only be read, written, updated
  # or removed during a logged in branch.
  #
  # The mirror of this use case is <b><em>unset</em></b>.
  #
  # == Observable Value
  #
  # The configuration directive will either be created or overwriten within the
  # book's configuration store.
  #
  class Set < Controller

    attr_writer :directive_name, :directive_value

    # The <b>set <em>use case</em></b> is the generic tool for setting book scoped
    # configuration directives. These directives can only be read, written, updated
    # or removed during a logged in branch.
    def execute

      return unless ops_key_exists?
      master_db = Book.read()

      master_db[ @directive_name ] = @directive_value

      puts ""
      puts JSON.pretty_generate( master_db )
      puts ""

      Book.write( create_header(), master_db )

    end


  end


end

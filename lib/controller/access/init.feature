# @todo enable running the cucumber tests within the RubyMine IDE

Feature: test safedb's book initialize command

    Scenario: safe help includes help for safe init
        When I run `/usr/local/bin/safe help`
        Then the output should contain:
        """
        safe init
        """

    Scenario: safe help init gives custom init help
        When I run `/usr/local/bin/safe help init`
        Then the output should contain:
        """
        initialize a new safe credentials book
        """

    Scenario: initialize a brand new book
        When I run `/usr/local/bin/safe init abcddee --password=abcdd1234455`
        Then the output should contain:
        """
        Success! You can now login.
        """

# Another commit test change again
# Another commit test change again
    Scenario: starting with step defns
        When I create a new book
#        And I run `/usr/local/bin/safe login turkey --password=abcde12345`
        And I run `/usr/local/bin/safe view`
        Then the output should contain:
        """
        turkeyX
        """

    Scenario: safedb book is really really initialized
        When I run the following commands:
        """bash
        echo "Hello shell"
        """
        Then the output should contain exactly "Hello shell"

    Scenario: safedb book is really not really initialized
        When I run the following commands:
        """bash
        safe help do
        """
        Then the output should contain:
        """
        Options
        """

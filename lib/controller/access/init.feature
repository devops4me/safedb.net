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

    Scenario: check the test data directory is being used
        When I run `printenv`
        Then the output should contain:
        """
        SAFE_DATA_DIRECTORY
        """

    Scenario: starting with step defns
        When I create book "family" with password "f4m1lyp455w0rd"
        And I run `/usr/local/bin/safe login family --password=f4m1lyp455w0rd`
        And I run `/usr/local/bin/safe view`
        Then the output should contain:
        """
        == Book Name := family [v1kxdk-639c65]
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

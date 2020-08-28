
Feature: test safedb's book initialize command

    Scenario: safe help includes help for safe init
        When I run `safe help`
        Then the output should contain:
        """
        safe init
        """

    Scenario: safe help init gives custom init help
        When I run `safe help init`
        Then the output should contain:
        """
        initialize a new safe credentials book
        """

    Scenario: initialize a brand new book
        When I run `safe init abcddee --password=abcdd1234455`
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

    Scenario: creating a book with safe init
        When I create book "family" with password "f4m1lyp455w0rd"
        And I login to book "family" with password "f4m1lyp455w0rd"
        And I run `safe view`
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

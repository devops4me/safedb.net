
Feature: test safedb's book initialize command

    # @todo remove the hardcoded directory reference which will not work in the ci pipeline
    Background: Clean previous test data
        When I run `rm -fr  /Users/apollo/RubymineProjects/safedb.net/feature.tests.dir`
        Then the directory named "/Users/apollo/RubymineProjects/safedb.net/feature.tests.dir" should not exist anymore

    Scenario: initialize a brand new book
        When I run `bin/safe init abcddee --password=abcdd1234455`
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
# @todo Then I should be logged in to book "family"
# implement this
        And I view the book
#        Then the output should contain "Correct"
#        And I run `bin/safe view`
#        Then the output should contain:
#        """
#        == Book Name := family [v1kxdk-639c65]
#        """

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

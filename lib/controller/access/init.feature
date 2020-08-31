
Feature: test safedb's book initialize command

    # @todo remove the hardcoded directory reference which will not work in the ci pipeline
    Background: Clean and ensure directory env var is set
        When I run `rm -fr  /Users/apollo/RubymineProjects/safedb.net/feature.tests.dir`
        Then the directory named "/Users/apollo/RubymineProjects/safedb.net/feature.tests.dir" should not exist anymore
        When I run `printenv`
        Then the output should contain:
        """
        SAFE_DATA_DIRECTORY
        """

    Scenario: initialize a brand new book
        When I run `bin/safe init abcddee --password=abcdd1234455`
        Then the output should contain:
        """
        Success! You can now login.
        """

    Scenario Outline: creating a book with safe init
        When I create book "<book_name>" with password "<book_password>"
        And I login to book "<book_name>" with password "<book_password>"
        Then I should be logged in to book "<book_name>"
    Examples:
        | book_name | book_password  |
        | friends   | fr13ndp455w0rd |
        | family    | f4m1lyp455w0rd |

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

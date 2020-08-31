
Feature: test safedb's obliterate command

    This test will run the `safe obliterate` command

    Scenario: checking the safe shell token exists
        When I run `printenv`
        Then the output should contain "SAFE_TTY_TOKEN"

#    Scenario: there is nothing to obliterate
#        When I run `safe obliterate`
#        Then the output should contain "There is nothing to obliterate"
#        And a directory named "~/.config/safedb/safedb-master-crypts" should not exist
#        And a directory named "~/.config/safedb/safedb-branch-crypts" should not exist
#        And a directory named "~/.config/safedb/safedb-branch-keys" should not exist

    Scenario: logging into the (just initialized) safe
        When I run `safe init book1 --password=abc123XYZ`
        And I run `printenv`
        And I run `safe login book1 --password=abc123XYZ`
        Then the output should contain "SAFE_TTY_TOKEN"
        And the output should contain "There are 0 chapters and 0 verses"

#    Scenario: now obliterating the safe we just created
#        When I run `safe init book1 --password=abc123XYZ`
#        And I run `safe login book1 --password=abc123XYZ`
#        And I run `safe obliterate`
#        Then the output should contain "The safe has been successfully obliterated"
#        And a directory named "~/.config/safedb/safedb-master-crypts" should not exist
#        And a directory named "~/.config/safedb/safedb-branch-crypts" should not exist
#        And a directory named "~/.config/safedb/safedb-branch-keys" should not exist

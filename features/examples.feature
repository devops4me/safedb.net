
Feature: test safedb's version command

    This test will run both `safe version` and `safe --version`

    Scenario: safedb version is printed
        When I run `safe version`
        Then the output should contain "safedb gem version"

      Scenario: version with dash dash is printed
        When I run `safe --version`
        Then the output should contain "safedb gem version"

    Scenario: safe return value should be zero
        When I successfully run `safe print`
        Then the exit status should be 0

    Scenario: safe show exit status should not be 0
        When I run `safe show`
        Then the exit status should not be 0

    Scenario: safe help standard output contains text safe terraform
        When I run `safe help`
        Then the stdout should contain "safe terraform"

    Scenario: safe Cleans up the written out file
        When I run `rm -r /home/apollo/Downloads/KEY_MATERIAL`
        Then a file named "/home/apollo/Downloads/KEY_MATERIAL/Dec2018-MFA-OVPN-files/lab.ovpn" should not exist
        And a directory named "/home/apollo/Downloads/KEY_MATERIAL/Dec2018-MFA-OVPN-files" should not exist

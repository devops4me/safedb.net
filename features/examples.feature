
Feature: test safedb's version command

    This test will run both `safe version` and `safe --version`

    Scenario: safedb version is printed
        When I run `safe version`
        Then the output should contain "v0.8"

      Scenario: version with dash dash is printed
        When I run `safe --version`
        Then the output should contain "v0.8"

    Scenario: safe writes out a file
        When I run `safe write --script`
        Then a file named "/home/apollo/Downloads/KEY_MATERIAL/Dec2018-MFA-OVPN-files/lab.ovpn" should exist
        And a directory named "/home/apollo/Downloads/KEY_MATERIAL/Dec2018-MFA-OVPN-files" should exist

    Scenario: safe return value should be zero
        When I successfully run `safe print`
        Then the exit status should be 0

    Scenario: safe show fails with a CipherError and a 1 exit status
        When I run `safe show`
        Then the stderr should contain "bad decrypt"
        And the stderr should contain "OpenSSL::Cipher::CipherError"
        And the exit status should be 1

    Scenario: safe show exit status should not be 0
        When I run `safe show`
        Then the exit status should not be 0

    Scenario: safe help standard output contains text safe terraform
        When I run `safe help`
        Then the stdout should contain "safe terraform"

    Scenario: using command input
        Given the input "username"
        When I run `safe safe print --script`
        Then the stdout should contain "apollo"

    Scenario: dummy proof of concept
        When I run `safe verse --script`
        Then a file named "/home/apollo/mirror.main/safedb.net/README.md" should exist
        And the file "/home/apollo/mirror.main/safedb.net/README.md" should contain:
        """
        - Jenkins picks up the latest software
        - Rake and Minitest are used to build and unit test the software
        - Docker is used to system test safedb in the key Linux environments
        - versioning is applied using the date/time and Git's commit hashes
        - if tests pass the safedb gem is deployed to RubyGems.org
        """

    Scenario: safe Cleans up the written out file
        When I run `rm -r /home/apollo/Downloads/KEY_MATERIAL`
        Then a file named "/home/apollo/Downloads/KEY_MATERIAL/Dec2018-MFA-OVPN-files/lab.ovpn" should not exist
        And a directory named "/home/apollo/Downloads/KEY_MATERIAL/Dec2018-MFA-OVPN-files" should not exist

    Scenario: safe prints the correct value of credential keys
        When I run `safe print username --script`
        Then the output should contain "apollo"
        And the output should not contain "Apollo"

# -->    Scenario: safe prints the correct value of credential keys
# -->        When I run `safe print <ValueKey> --script`
# -->        Then the output should contain "<CorrectValue>"
# -->        And the output should not contain "<WrongValue>"

# -->        Examples: safe prints the value of credential keys
# -->        | ValueKey | CorrectValue | WrongValue |
# -->        | @in.url | /home/apollo/Downloads/KEY_MATERIAL/Dec2018-MFA-OVPN-files/lab.ovpn | blahblah |
# -->        | @out.url | /home/apollo/Downloads/KEY_MATERIAL/Dec2018-MFA-OVPN-files/lab.ovpn | blahblah |
# -->        | content.xid | Wrong.kRF4CCSmS7pXkEOQvUqP6p7RYu74acbA | blahblah |
# -->        | content.key | yXb3nEAMuGjT8lE1w7%tgcc781cNlosUhlebiQPT%CgQ9AP8uvHigoZw%x0o5iEb | blahblah |
# -->        | username | apollo | blahblah |


Feature: test safedb's version command

    This test will run both `safe version` and `safe --version`

    Scenario: safedb version is printed
        When I run `safe version`
        Then the output should contain "0.2"

      Scenario: version with dash dash is printed
        When I run `safe --version`
        Then the output should contain "0.2"

    Scenario: safe writes out a file
        When I run `safe write --script`
        Then a file named "/home/apollo/Downloads/KEY_MATERIAL/Dec2018-MFA-OVPN-files/lab.ovpn" should exist
        And a directory named "/home/apollo/Downloads/KEY_MATERIAL/Dec2018-MFA-OVPN-files" should exist

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

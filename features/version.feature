
Feature: Version
  In order to portray or pluralize food
  As a CLI
  I want to be as objective as possible

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

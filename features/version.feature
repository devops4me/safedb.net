
Feature: Version
  In order to portray or pluralize food
  As a CLI
  I want to be as objective as possible

  Scenario: safedb version is printed
    When I run "safedb version"
    Then the output should contain "0.2"

  Scenario: version with dash dash is printed
    When I run "safedb --version"
    Then the output should contain "0.2"

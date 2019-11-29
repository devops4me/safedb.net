
Feature: test safedb's version command

    This test will run both `safe version` and `safe --version`

    Scenario: hip hop hoooray is the value I GET
        When I run `safe version`
        Then the output should contain "v0.8"

      Scenario: right overy here is the blood and the sweat
        When I run `safe --version`
        Then the output should contain "v0.8"


# --> safe init boys
# --> safe login boys
# --> safe import ~/safedb.test.data.json
# --> safe view
# --> safe show (failure because no open chapter has been set)
# --> safe goto 3
# --> safe checkin


Feature: test safedb's obliterate command

    This test will run the `safe obliterate` command

    Scenario: there is nothing to obliterate
        When I run `safe obliterate`
        Then the output should contain "There is nothing to obliterate"
        And a directory named "~/.config/safedb/safedb-master-crypts" should not exist
        And a directory named "~/.config/safedb/safedb-branch-crypts" should not exist
        And a directory named "~/.config/safedb/safedb-branch-keys" should not exist
        And a directory named "~/.config/safedb/safedb-backup-crypts" should not exist

Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue


    Scenario: setting up the safe shell token
# -->        When I run `SAFE_TTY_TOKEN=$(safe\ token)`
        When I run `. /project/.bash_aliases ; printenv`
# -->        When I run `export SAFE_TTY_TOKEN="hrmSirCFLnuLTEZjumBgaFunVHNl5lj8mb%DnRbd8KkVUbm9xzm0YeCw9F9Ls2fFUnX0qA3BZKwJ%kSKqtmwRvXa%KXd4%y4tfhLV6n8abn2@4AZJhozZMel@NIsqh2quPtpI4kF.mVTmrO5o6fKES01"`
## -->        And I run `printenv`
        Then the output should contain "SAFE_TTY_TOKEN"

    Scenario: initializing the safe to obliterate
# -->        When I run `export SAFE_TTY_TOKEN=\`safe token\``
        When I run `safe init book1 --password=abc123XYZ`
        Then the output should contain "Your book book1 with id r6h43w-c69155 is up"
        And the output should contain "Success"
        And a directory named "~/.config/safedb/safedb-master-crypts" should exist
        And a directory named "~/.config/safedb/safedb-master-crypts/.git" should exist
        And a directory named "~/.config/safedb/safedb-branch-crypts" should not exist
        And a directory named "~/.config/safedb/safedb-branch-keys" should not exist
        And a directory named "~/.config/safedb/safedb-backup-crypts" should not exist

    Scenario: logging into the (just initialized) safe
        When I run `export SAFE_TTY_TOKEN=\`safe token\``
        And I run `safe login book1 --password=abc123XYZ`
        Then the output should contain "There are 0 chapters and 0 verses"
        And a directory named "~/.config/safedb/safedb-master-crypts" should exist
        And a directory named "~/.config/safedb/safedb-branch-crypts" should exist
        And a directory named "~/.config/safedb/safedb-branch-keys" should exist
        And a directory named "~/.config/safedb/safedb-backup-crypts" should not exist

# -->    Scenario: now obliterating the safe we just created
# -->        When I run `safe obliterate`
# -->        Then the output should contain "The safe has been successfully obliterated"
# -->        And a directory named "~/.config/safedb/safedb-master-crypts" should not exist
# -->        And a directory named "~/.config/safedb/safedb-branch-crypts" should not exist
# -->        And a directory named "~/.config/safedb/safedb-branch-keys" should not exist
# -->        And a directory named "~/.config/safedb/safedb-backup-crypts" should exist

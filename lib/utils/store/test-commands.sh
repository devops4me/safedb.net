

First On Shell A
########################

safe init school
safe login school


safe open grounds football.pitch
safe put size "250sq/m"
safe put owner school
safe read boys.school.json projects/safedb.net/lib/utils/store/merge-boys-school.json
safe view

safe import ~/projects/safedb.net/lib/utils/store/merge-boys-school.json
safe show
safe checkin



Then On Shell B
########################



## The typical shells

Learn to run emacs commands in a batch so that we can open the below in an automated fashion. Learn to robotically communicate with and manipulate emacs. This will improve your efficiency many many fold.

.%  CORE [dir]              856 Dired by name    /home/apollo/projects/safedb.net/lib/core/
  * SEARCH [shell]           36 Shell:run        /home/apollo/projects/safedb.net/
  * RAKE [shell]             94 Shell:run        /home/apollo/projects/safedb.net/
 %  USECASE [dir]          1080 Dired by name    /home/apollo/projects/safedb.net/lib/usecase/
 %  safedb.net              924 Dired by name    /home/apollo/projects/safedb.net/
  * SAFE 2 [shell]           16 Shell:run        /home/apollo/
  * SAFE 1 [shell]           16 Shell:run        /home/apollo/

# Feature Checkin

## In one shell

safe init boys
safe login boys
safe import ~/safedb.test.data.json
safe view
safe show (failure because no open chapter has been set)
safe goto 3
safe checkin


## In Another shell

safe login boys

Failure occurs

R{\370\204m\265^v}\276\223^RZ(\320^N\333e.time":"Wed Apr 10 09:06:37 2019","book.name":"boys","book.init.version":"safedb-v0.3.1012","book.chapter.keys":{"dbms.accounts":{"content.id":"00cxarwaia0s4g","content.iv":"VzbG5IBQEuFdpRFerzGqHPejVKdKekcl","chapter.key.crypt":"Rx5BWXXM9uK5cbiH006WupaHVciXL8q%XooFdogSazMdHnqlJHuulMoeBtZxxJse"},"aws.console.accounts":{"content.id":"r6sc5ope3n3sfi","content.iv":"Jgh4c2aeh2Qjwt@ZaTEJxfK@6A%dzUoz","chapter.key.crypt":"9t5xxjDgyN4jQGQyw%9CHvTzGqJU@MiOWFGFKpGAuz@@fT8FJVO2fjoQIHEjTDfa"},"ops":{"content.id":"uk2u9bnzpynizc","content.iv":"AnvTgyJPbZpBju8kSsT8es0NmHlv2j9d","chapter.key.crypt":"TYyASQ71sgMbzNOxGVgojdb28M1%4iPDDsSDQz8TevjABYY887hqoPTRpvx18xUT"},"git":{"content.id":"r3dso6qr88l5lm","content.iv":"I9hykwLIGrvgp0j2jMQyMJC3QhWg0xSD","chapter.key.crypt":"0QLO7FawspMzEpRnB%6Wb3dVyjiJ36IX5SRp7QNOkU5ut@sMy9%KNYQ42XKA8yTj"}},"book.open.chapter":"aws.console.accounts","book.open.verse":"aimbrain.prod"}

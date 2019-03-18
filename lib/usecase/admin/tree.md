
# the safedb directory tree

On disk, the safe database is largely just **crypt files** and **indices** which contain salts and possibly remote repository urls. You'll also find a safe **user configuration file** plus activity logs.

```
~/.safedb.net
    |
    |--- safedb-master-index-local.ini
    |--- safedb-user-configuration.ini
    |--- safedb-activity-journal.log
    |
    |--- safedb-master-crypts
             |
             |--- .git
             |--- safedb.master.book.ababab-ababab
                      |
                      |--- safedb.chapter.8d04ldabcd.txt
                      |--- safedb.chapter.fl3456asdf.txt
                      |--- safedb.chapter.pw9521pqwo.txt

             |
             |--- safedb.master.book.cdcdcd-cdcdcd
                      |
                      |--- safedb.chapter.o3wertpoiu.txt
                      |--- safedb.chapter.xcvbrt2345.txt
    |
    |
    |--- safedb-session-crypts
             |
             |--- safedb-session-ababab-ababab-xxxxxx-xxxxxx-xxxxxx
                      |
                      |--- safedb.chapter.8d04ldabcd.txt
                      |--- safedb.chapter.fl3456asdf.txt
                      |--- safedb.chapter.pw9521pqwo.txt
             |
             |
             |--- safedb-session-ababab-ababab-xxxxxx-zzzzzz-zzzzzz
                      |
                      |--- safedb.chapter.id1234abcd.txt
                      |--- safedb.chapter.id3456asdf.txt
                      |--- safedb.chapter.id9521pqwo.txt

             |
             |
             |--- safedb-session-cdcdcd-cdcdcd-ghighi-ghighi-ghighi
                      |
                      |--- safedb.chapter.o3wertpoiu.txt
                      |--- safedb.chapter.xcvbrt2345.txt

    |--- safedb-session-indices
             |
             |--- safedb-ababab-ababab-xxxxxx-xxxxxx-xxxxxx.ini
```

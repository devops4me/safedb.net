
# safedb directory structure

```
~/.safedb.net
    |
    |--- safedb-master-index-local.ini
    |--- safedb-activity-journal.log
    |
    |
    |--- safedb-master-crypt-files
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
    |--- safedb-session-crypt-files
             |
             |--- safedb-session-ababab-ababab-xxxxxx-xxxxxx-xxxxxx
                      |
                      |--- safedb.chapter.id1234abcd.txt
                      |--- safedb.chapter.id3456asdf.txt
                      |--- safedb.chapter.id9521pqwo.txt
             |
             |
             |--- safedb-session-ababab-ababab-xxxxxx-zzzzzz-zzzzzz
                      |
                      |--- safedb.chapter.id1234abcd.txt
                      |--- safedb.chapter.id3456asdf.txt
                      |--- safedb.chapter.id9521pqwo.txt

    |--- safedb-session-index-files
             |
             |--- safedb-ababab-ababab-xxxxxx-xxxxxx-xxxxxx.ini
```


# safe file/folder locations

the safe keeps its assets by default in the `~/.config/safe` location.
this location can be overriden by the `safe_data_directory` environment variable and commonly is, when running unit tests.

## safe book locations
git files can be found in a remote cloud, a local mirror and a working tree. similarly the encrypted files of a safe book live in
- a remote git repository
- a local mirror repository in `~/.config/safe/master-crypts/<book-name>/.git`
- a local master working tree in `~/.config/safe/master-crypts/<book-name>`
- a local branch working tree in `~/.config/safe/branch-crypts/<branch-id>/<book-name>`

## safe location CRUD commands

What core commands will create, read, update and delete the above locations. 

| **location** | create    | read      | update    | delete    |
|:------------ |:--------- |:--------- |:--------- |:--------- |
| remote repo  | `remote` | `clone`, `pull` | `push` | n/a |
| mirror repo  | `init`, `clone` | `push` | `pull`, `commit` | `destroy` |
| master crypts  | `init`, `clone` | `login`, `diff`, `refresh` | `pull`, `commit` | `destroy` |
| master indices | `init`, `clone` | `login`, `diff`, `reset` | `login`, `commit`, `pull`, `reset` | `destroy` |
| branch crypts  | `login` | `diff`, `commit` | `pull`, `refresh` | `destroy`, `logout`, `brexit` |
| branch indices | `login` | `diff`, `commit` | `pull`, `refresh` | `destroy`, `logout`, `brexit` |

All commands that read the safe like `safe show` and `safe view` will read the branch indices and chapter crypts.
All commands that create and update the safe like `safe put` and `safe rename` will read the branch indices and create read update and/or delete the branch chapter crypts. 

## safe book files

On disk, a safe book only has **crypted chapter files** in **`chapter-crypts`** and an **index** named **`book-indices.ini`** inside the book's folder.

## safe log file

the safe writes its logs to a file in `~/.config/safe/safe-activity-journal.log`

## safe directories view

```
~/.config/safe
    |
    |--- safe-activity-journal.log
    |--- safe-master-books
        |
        |--- contacts
             |
             |--- .git
             |--- book-master-index.ini
             |--- chapter-crypts
                      |
                      |--- safe.chapter.8d04ldabcd.txt
                      |--- safe.chapter.fl3456asdf.txt
                      |--- safe.chapter.pw9521pqwo.txt

        |
        |--- app.wiki
             |
             |--- .git
             |--- book-master-index.ini
             |--- chapter-crypts
                      |
                      |--- safe.chapter.fgh1jk64n0.txt
                      |--- safe.chapter.p1rs8u48xy.txt
                      |--- safe.chapter.zn1nma53n2.txt

    |--- safe-branch-books
        |
        |--- branch-pabefgh-xydemln-x2fd9dg
            |
            |--- contacts
                 |
                 |--- book-branch-index.ini
                 |--- chapter-crypts
                          |
                          |--- safe.chapter.8d04ldabcd.txt
                          |--- safe.chapter.fl3456asdf.txt
                          |--- safe.chapter.pw9521pqwo.txt
            |
            |--- app.wiki
                 |
                 |--- book-branch-index.ini
                 |--- chapter-crypts
                          |
                          |--- safe.chapter.fgh1jk64n0.txt
                          |--- safe.chapter.p1rs8u48xy.txt
                          |--- safe.chapter.zn1nma53n2.txt

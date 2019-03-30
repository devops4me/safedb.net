

# safe rename

Changing your mind is a basic human right! In lieu of this, safe provides a **rename** use case that can be used to rename

- a chapter
- a verse
- a key (at a chapter and verse location)

<blockquote>
As yet safe has no command for renaming books. You can achieve this by first cloning the book then deleting the original.
</blockquote>

## safe rename | chapter

To rename a chapter you must not have an open location. If you do you must first close it before renaming.

    $ safe close
    $ safe view
    $ safe rename <old-name> <new-name>

When safe sees that the book is not open, it knows that you want to rename the chapter.

The rename command returns a view allowing you to check that the chapter name has indeed been updated.


## safe rename | verse

To rename the verse you must have its chapter (and only its chapter) open.

    $ safe close
    $ safe open <chapter>
    $ safe view
    $ safe rename <old-name> <new-name>

The rename command returns a view of all the verses in the open chapter allowing you to check that the verse name has indeed been updated.

## safe rename | key

Most of the time you will want to rename keys in the mini-dictionary at a chapter and verse location. To do this you must open the chapter and verse first.

    $ safe open <chapter> <verse>
    $ safe show
    $ safe rename <old-name> <new-name>

The rename command shows you the mini-dictionary (hashing out sensitive credentials) allowing you to check that the key name has indeed been updated.

## safe rename | be aware

Be aware of the following when renaming.

- key names that start with @ guard the key's value during a safe show
- renaming keys that are required for integration functionality will need you pass the --force switch


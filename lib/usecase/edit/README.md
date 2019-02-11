
### safe put | safe delete | safe copy | safe paste

# edit use cases | copy | paste | delete

The edit use cases create, delete and update the credentials and configuration inside your safe.

## Common Usage

Typically you login to a book, open a chapter and verse, then you put **`key/value`** pairs, known as **lines**.

```
safe login joe@home

# -- -------------------------------------------------- -- #
# -- Create chapter (email) and verse <<email-address>> -- #
# -- -------------------------------------------------- -- #
safe open email joebloggs@gmail.com

# -- ---------------------------- -- #
# -- Populate it with credentials -- #
# -- ---------------------------- -- #
safe put gmail.id joebloggs
safe put @password s3cr3et
safe put recovery.phone 07500875278

# -- ----------------------------------------------- -- #
# -- Now copy and then paste a line (key/value pair) -- #
# -- ----------------------------------------------- -- #
safe copy recovery.phone
safe open email joe@ywork.com
safe paste
```

## editing behaviour

**These use cases are intuitive and behave almost like what you would expect.** The safe ethos is for commands to behave according to which of the 5 levels you are at.


| Command          | Verse                         | Chapter                          | Book                            |
|:---------------- |:----------------------------- |:-------------------------------- |:------------------------------- |
| safe copy <<id>> | Copy one of the verse's lines | Copy one of the chapter's verses | Copy one of the book's chapters |
| safe copy        | Copy all of the verse's lines | Copy all of the chapter's verses | Copy all of the book's chapters |

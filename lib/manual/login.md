
# safe login | safe logout

You can login to one or more books at a shell command line.

```
safe login <<book>>
safe login <<book>> --password=<<password>>
safe login <<book>> -p <<password>>
safe login <<book>> --clip
safe login <<book>> -c
```

## Password Conventions

The safe will **search for passwords** in an orderly manner as per the conventions below.

|  #  | Location | Description (and Important Points) | Example |
|:---:|:---------- |:------------------------------ |:----------------------- |
|  1  | Command Line | Leave **a space** before the <tt>safe init</tt> or <tt>safe login</tt> commands to avoid the command being written into `.bash_history` - do not use if AN Other can run `ps` on your machine. | <tt>safe login contacts --password=secret123</tt> |
|  2  | Environment Variable | First export the password into an environment variable called SAFE_BOOK_PASSWORD and then issue a login. Don't forget to **leave a space** before the <tt>export</tt> command to avoid being logged into .bash_history | <tt>safe login contacts</tt> |
|  3  | Environment Variables | If you want to login to multiple books in the same shell (or within scripts) you can export the environment variable with the book name appended. | **export SAFE_BOOK_PASSWORD_contacts=secret123** and **export SAFE_BOOK_PASSWORD_accounts=p455w0rd** |
|  4  | **clip board** | A <tt>--clip</tt> switch **(or -c)** appended to the init and/or login commands tells safe to read the password from the clip board and then immediately delete the clip board contents. | safe login contacts --clip |
|  5  | Prompt | The ubiquitous password prompt will be issued if none of the above options are viable. | safe login contacts |

<!--
|  3  | xxx | xxxx | xxx |
-->

### login pre-conditions

To login into a safe book you must

- have installed safe and set the token (env var)
- (either) have initialized the book using safe init
- (or) have pulled in a safe database using safe clone
- know the book's name and password (from safe init)

## Related Commands

| safe command | parameters | the observable value delivered | relationship with login |
|:------------ |:---------- |:------------------------------ |:----------------------- |
| safe init | book name | creates the book for managing credentials | book must exist first |
| safe logout | (none) | deletes session information preventing further usage | can logout after login |


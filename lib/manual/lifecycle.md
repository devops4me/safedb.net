
# safe book lifecycle

Understanding the safe book lifecycle and the commands that play a part in it, is important for getting the most out of **`safe`**.

safe books encrypted at rest can be found in
1. a remote library (or repository like Github or S3)
1. a local master (in the home directory tree of the user)
1. a branch after a safe login during a shell session

The commands that play a part in the life of a book are
```
safe init  <book_name> <library_url>  # create local master and put in remote library
safe clone <library_url> <book_name>  # create local master and put in remote library
safe login <book_name>                # update local master and create session mirrors
safe diff                             # reports on the changes made to the book
safe commit                           # sends updates to local master and remote library
safe compare <other_book_name>        # compares two logged in books in the same session
safe logout                           # logout of the book that ic surrently being used
```

## How Merge Conflicts are Handled

Every data store being used concurrently will sooner or later have to handle merge conflicts. **safe** is by no means immune to this fundamental law.

**safe** conflicts happen when either or both of the local and remote book masters are progressed by one or more commits.

### Resolving the Merge Conflict

When `safe diff` or `safe commit` inform you of a merge conflict you can perform these steps to resolve it.

```
safe clone <library_url> <book_name_2>  # clone the book containing updates
safe login <book_name_2>                # login to the updated book in the same session
safe compare <book_name>                # report on the differences between the two
safe drag b:book_name/new_chapter       # copy over the new chapter you created
safe drop                               # paste that chapter into book_name_2
safe diff                               # verify that the new chapter is to be committed
safe commit                             # send changes to the local and remote masters
```

That's it. You resolved a merge conflict. Wait though, you now have two similarly named books. Remember that book_name_2 is our man.

```
safe delete b:book_name
safe rename b:book_name_2 book_name
```

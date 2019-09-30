
# safe | git interaction

safe uses git for local synchronization and also as one of the many remote backend storage engines together with S3, SSH and Google Drive. As such, the git client is a prerequisite on systems running the safe command line interface (CLI).

Now we document the safe use cases that employ the git version control system and the circumstances surrounding its use.


## safe init | use case

The safe init use case creates a book and creates the **`safedb-master-keys.ini`** file and a chapter crypt file under a new book directory.

| **git action** | **when is it done?** | **what is done and/or the circumstances in which git is used** |
|:-------------- |:-------------------- |:-------------------------------------------------------------- |
| _git init_     | at the beginning     | if the master crypts folder is not under git control |
| _git add_      | just before the end  | the master keys are added and the folder of the new book |
| _git commit_   | at the end           | the commit is done if and only if git add was invoked |


## safe init | use case



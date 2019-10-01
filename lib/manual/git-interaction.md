
# safe | git interaction

safe uses git for local synchronization and also as one of the many remote backend storage engines together with S3, SSH and Google Drive. As such, the git client is a prerequisite on systems running the safe command line interface (CLI).

With Git comes the ability to revert state to any point in time after state-changing command transactions.

Now we document the safe use cases that employ the git version control system and the circumstances surrounding its use.


## safe init | use case

The safe init use case creates a book and creates the **`safedb-master-keys.ini`** file and a chapter crypt file under a new book directory.

| **git action** | **when is it done?** | **what is done and/or the circumstances in which git is used**      |
|:-------------- |:-------------------- |:------------------------------------------------------------------- |
| _git init_     | at the beginning     | done only once if the master crypts folder is not under git control |
| _git add_      | just before the end  | every init adds master keys and the just created book folder to git |
| _git commit_   | at the end           | the git commit is issued if and only if the git add was invoked     |


## safe commit | use case

The **`safe commit`** use case uses git to **protect the master database from the ills of concurrent access**. The git interactions are not _spray and pray_ - they are specific to each given file that is added, removed and/or updated.

| **git action**   | **when is it done?** | **what is done and/or the circumstances in which git is used**      |
|:---------------- |:-------------------- |:------------------------------------------------------------------- |
| **_git add_**    | just before the end  | new files incoming to the master crypts are brought under vc        |
| **_git rm_**     | just before the end  | removed files are expunged from the git repository                  |
| **_git commit_** | at the end           | the git commit is issued if either git add or git rm was invoked    |


## safe pull | use case

If the local safe is already under version control the **`safe pull`** command will check for equivalence between the git repository url and the upstream url registered  by **`git remote`**. If it isn't - a **`git clone`** will suffice to pull down the safe repository assets.

| **git action**   | **when is it done?** | **what is done and/or the circumstances in which git is used**      |
|:---------------- |:-------------------- |:------------------------------------------------------------------- |
| **_git remote_** | at the beginning     | the upstream url is compared to the url safe pull has a handle to   |
| **_git clone_**  | towards the end      | if there are no crypts to speak of the git clone pulls them in      |
| **_git pull_**   | towards the end      | this is a git fetch and git merge to integrate remote repo changes  |


## safe push | use case

After one or more commits a **`safe push`** is called upon to sync the local crypt state with the registered remote repository.

However a git push may not be possible if the remote has moved further ahead than the local. This matter would be reported and the user encouraged to perform a **`safe pull`** first followed by a **`safe refresh`**, changes, **`safe commit`** and finally another **`safe push`**.

| **git action**   | **when is it done?** | **what is done and/or the circumstances in which git is used**      |
|:---------------- |:-------------------- |:------------------------------------------------------------------- |
| **_git push_**   | towards the end      | if this is a git fetch and git merge to integrate remote repo changes  |

## safe diff | safe merge | use cases

When a diff is requested for a branch the remote is checked to discover whether it has moved ahead. If it has the user is advised to first carry out a safe merge operation to bring the changes from the remote to the master and from the master to the branch.

## safe remote | use case

A **`safe remote`** actually creates the remote repository automatically using API integration like the one provided by Github.

A git init is enacted if necessary. Usually **`safe init <<book-name>>`** will have brought the crypts under version management. Either way - it is the remote's responsibility (after it backs up the current repository) to update the local git upstream url to match the URL of the newly created git repository.

The remote's last responsibility is to urge the user to issue a **`safe push`** in order to sync and bring the remote repository up to date.


## safe design | cap theorem

In reference to the CAP theorem, the safe is designed such that **consistency trumps availability**. Failed commits in a manner of speaking are preferable to corrupted files and race conditions. Without git, these corruptions would arise through the use of basic file operations.

 Automatons like scripts will typically branch and read the database. It is envisaged that humans will perform the vast majority of commits, pushes and pulls thus reducing the frequency of commit failures.

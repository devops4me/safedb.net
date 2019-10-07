
# safe | git interaction

safe uses git for local synchronization and also as one of the many remote backend storage engines together with S3, SSH and Google Drive. As such, the git client is a prerequisite on systems running the safe command line interface (CLI).

With Git comes the ability to revert state to any point in time after state-changing command transactions.

Now we document the safe use cases that employ the git version control system and we discuss the circumstances surrounding its use.



## **`safe init`**

The safe init use case creates a book and creates the **`safedb-master-keys.ini`** file and a chapter crypt file under a new book directory.

| **git action** | **when is it done?** | **what is done and/or the circumstances in which git is used**      |
|:-------------- |:-------------------- |:------------------------------------------------------------------- |
| _git init_     | at the beginning     | done only once if the master crypts folder is not under git control |
| _git add_      | just before the end  | every init adds master keys and the just created book folder to git |
| _git commit_   | at the end           | the git commit is issued if and only if the git add was invoked     |



## **`safe login`**

The safe init use case creates a book and creates the **`safedb-master-keys.ini`** file and a chapter crypt file under a new book directory.

| **git action**     | **what is done andr the circumstances under which git is used**     |
|:------------------ |:------------------------------------------------------------------- |
| _git rm FILENAME_  | remove the outgoing master crypt content file from the repository and working copy |
| _git add FILENAME_  | add the incoming master crypt content file into git version management |
| _git add FILENAME_  | add the master indices INI which may have new keys, a new content ID and maybe bootup ID |
| _git commit_  | commit the hot-swapped crypt files and the master indices file as an atomic (ACID) transaction |



## **`safe commit`**

The **`safe commit`** use case uses git to **protect the master database from the ills of concurrent access**. The git interactions are not **_spray and pray_**. They are specific to each given file that is added, removed and/or updated.

| **git action**   | **when is it done?** | **what is done and/or the circumstances in which git is used**      |
|:---------------- |:-------------------- |:------------------------------------------------------------------- |
| **_git add_**    | just before the end  | new files incoming to the master crypts are brought under vc        |
| **_git rm_**     | just before the end  | removed files are expunged from the git repository                  |
| **_git commit_** | at the end           | the git commit is issued if either git add or git rm was invoked    |



## **`safe pull`**

If the local safe is already under version control the **`safe pull`** command will check for equivalence between the git repository url and the upstream url registered  by **`git remote`**. If it isn't - a **`git clone`** will suffice to pull down the safe repository assets.

### safe pull invalidates every branch

**Important** - **`safe pull`** invalidates both the master branch and all active branches. Before you issue a safe pull you must **`safe commit`** on every shell branch that contains changes.

The commit provides a route back to a previous revision if the pull goes belly up and turns out to be something other than what you expected. Use **`safe compare`** to detail all the active branches that will be invalidated including the their login time and most recent access and change times.

| **git action**   | **when is it done?** | **what is done and/or the circumstances in which git is used**      |
|:---------------- |:-------------------- |:------------------------------------------------------------------- |
| **_git remote_** | at the beginning     | the upstream url is compared to the url safe pull has a handle to   |
| **_git clone_**  | towards the end      | if there are no crypts to speak of the git clone pulls them in      |
| **_git pull_**   | towards the end      | this is a git fetch and git merge to integrate remote repo changes  |

After a **`safe pull`** you must issue a **`safe login`** to continue working.

### pull first | ask questions later

A **`safe pull`** is recommended at the start of your session. Do a **`safe diff`** which does not require you to login in order to assess the differences between the local and remote master crypts.



## **`safe push`**

After one or more commits a **`safe push`** is called upon to sync the local crypt state with the registered remote repository.

However a git push may not be possible if the remote has moved further ahead than the local. This matter would be reported and the user encouraged to perform a **`safe pull`** first followed by a **`safe refresh`**, changes, **`safe commit`** and finally another **`safe push`**.

| **git action**   | **when is it done?** | **what is done and/or the circumstances in which git is used**      |
|:---------------- |:-------------------- |:------------------------------------------------------------------- |
| **_git push_**   | towards the end      | if this is a git fetch and git merge to integrate remote repo changes  |




## **`safe remote --provision`**

The **`safe remote`** command is primed to do four key tasks. It

- _automagically_ creates a remote repository (using for example **Github's API** integration)
- it provisions and installs **SSH keypairs** for **`safe push`** to write to the remote backend
- it uses **`set-upstream-url`** to tell the local repository where to **pull from** and **push to**
- urges the user commit branch changes **`safe commit`** and mirror them remotely **`safe push`**

A safe remote only acts to provision a remote mirror for your crypts when the **local git reposiotory is virginal** in that it has never been paired with a remote repository. In other words the local crypts have been created using **`safe init <<book-name>>`** as opposed to **`safe pull`**.

| **git action**               | **when is it done?** | **what is done and/or the circumstances in which git is used**    |
|:---------------------------- |:-------------------- |:----------------------------------------------------------------- |
| **_git set-upstream-url_**   | at the beginning     | if remote creates the 2nd remote repo the upstream url is changed |


The remote's last responsibility is to urge the user to issue a **`safe commit`** followed by a **`safe push`** so as to make the remote repository mirrors the state of the local safe.



## **`safe compare`**

The **`safe diff`** command reports on the difference between the local master book and the present local branch book.

**`safe compare`** on the other hand tells you that

- the remote branch has changed (leaving you behind needing to **`safe pull`**)
- the local branch has changed (putting you ahead needing to **`safe push`**)
- you cannot access the remote repository and cannot ascertain the above info

| **git action**     | **what is done and/or the circumstances in which git is used** |
|:------------------ |:-------------------------------------------------------------- |
| **_git compare_**  | this command is used to ascertain local vs remote differences  |
| **_git rev-diff_** | another command to ascertain local vs remote differences       |

So safe compare reports on the local commits informing you which branch made them, when and a rough change count. On the other hand it tells you about the remote commits, who made them and when.

### the worst of both worlds

When commits have moved on both the local and remote master branches you are in the worst ofboth worlds. Thankfully this scenario is extremely rare. The rough steps to resolve this are to

- export the local books as json
- pull the remote books down then export them as json
- externally compare the json and merge them into one
- import the merged json to create new books



## safe remote architecture

Due to its meticulous planning the safe adheres to a number of high level design rules. Let's cover these in the context of operating alongside a remote _git_ backend repository.


### 1. stand alone

The term **_stand alone_** refers to a non-networked computer that has no access neither to the internet nor to other computers in its vicinity.

The **safe cli** must be able to operate on a stand alone machine. Features like the remote backend mirror must provide succinct legible error messages when remote access is unavailable.

Furthermore, the following commands must not be impaired when the machine is in standalone mode.

- **`safe diff`** (does not report on remote differences)
- **`safe commit`** (only changes the master branch)
- **`safe init`** (only creates a local git repository

And these commands must degrade gracefully in standalone mode

- **`safe remote`**
- **`safe push`**
- **`safe pull`**
- **`safe compare`**


### 2. cap theorem

#### consistency trumps availability

In reference to the CAP theorem, the safe is designed such that **consistency trumps availability**.

Failed commits in a manner of speaking are preferable to corrupted files and race conditions. Without git, these corruptions would arise through the use of basic file operations.

 Automatons like scripts will typically branch and read the database. It is envisaged that humans will perform the vast majority of commits, pushes and pulls thus reducing the frequency of commit failures.

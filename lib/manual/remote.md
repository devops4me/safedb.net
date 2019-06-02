
#### create a remote backend store from which you can `safe push` and `safe pull` your encrypted database assets.

# provision a github repository backend

We want to provision (create) the safe's remote (github) backend so that we can access it from different machines. This is how we provision a Github remote backend do it.

```
safe init db.admin
safe login db.admin
safe open remote.backend github
safe put @github.token 43210fedcba43210fedcba43210fedcba43210fedcba
safe configure backend db.admin/remote.backend/github
safe remote --create
```

## safe put @github.token

safe knows how to talk to the Github Rest API as long as you provide a github access token. [How o acquire your Github access token](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line).

## safe configure @github.token

The **`safe configure`** command tell's safe which book, chapter and verse (in our case db.admin/remote.backend/github) that contains the backend repository access properties.

## safe remote --create

A number of setup tasks are executed when you ask that the backend repository be created.

- a repository is created in github
- the git fetch (https) and git push (ssh) urls are fabricated
- the fetch url is written to the **`safedb-master-indices.ini`**
- the push url is written to the configured chapter/verse location
- a ssh public/private keypair (using EC25519) is created
- the private and public keys are placed within the chapter/verse
- the public (deploy) key is registered with the github repository

Now you are ready to push and pull.

Visit the [safe push](push-pull) and [safe pull](push-pull) documentation to discover howto use your safe database on as many machines as you need.


## where is the safe database?

A safe database is always encrypted at rest and consiss of just 3 simple parts

- **backend** - a set of encrypted files kept either in **`~/.safedb.net/safedb-master-crypts`** or in a git repository
- **frontend** - a single state tracking file called <tt>safedb-dataase-tracker.ini</tt> (usually) on a removable drive
- one password - known by the database owner allowing them to login and access the information held within the database


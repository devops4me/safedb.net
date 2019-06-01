
#### create a remote backend store from which you can `safe push` and `safe pull` your encrypted database assets.

# create a safe database backend

A remote stored database from which you an push crypts to, and then pull from, consists of

- a **backend crypt store** in Github (or Gitlab, S3, dropbox, SFTP, GoogleDrive)
- one **frontend file** called <tt>safedb-dataase-tracker.ini</tt> on one or more removable drives
- a set of configuration directives at a safe book, chapter and verse location

Let's create our remote configuration directives and then use the **`safe remote`** command to point out the **`book/chapter/verse`** that carries the directives.

After that we issue a **`safe remote create`** to provision the remote (backend) database store.

Visit the [safe push](push-pull) and [safe pull](push-pull) documentation to discover howto use your safe database on as many machines as you need.

## configure your safe database backend

Let's use Github as the storage engine for our remote database backend.

```
safe init db.admin
safe login db.admin
safe open remote.backend github
```

| **Directive** | **Description**     | **Command Example** |
|:------------- |:------------------- |:------------------- |
| github.token  | Access to the Github Rest API is enabled via this OAuth2 token. [Github Token Documentation](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line) | **`safe put @github.token 43210fedcba43210fedcba43210fedcba43210fedcba`**




Let's use Github as the remote backend store for safe crypts and a usb key (removable drive) to store salts and other information that is worthless to an attacker without your passwords.

## push and pull pre-conditions

Ensure that you have the following accessories before integrating the safe database backend to a remote github repository.

- a github account (with username)
- the (40 character hexadecimal) github access token
- at least one path to a usb key, phone or removable drive
- your preferred github repository name

## create your safe remote backend

How do we instantiate a remote (backend)



## prepare to push and pull

Let's prepare to **push** our safe database up to a *github repository*, and then **pull it down**, restoring it on a *different machine*.

```
safe init db.admin
safe login db.admin
safe open remote.store github
safe put @github.access.token 43210fedcba43210fedcba43210fedcba43210fedcba
safe put github.repo.name safedb.backend.store
safe configure removable.drive /media/samsung/evo
```

The ***removable.drive*** folder **need not be removable**, but if you are moving from one machine to another, it helps if the path sits on a removable USB key, an external drive, or a smartphone.

## safe push

You **`safe push`** to synchronize your local and remote safe database.

```
safe login db.admin   # once per session (shell)
safe push             # as often as you like
```

The following will be true after every successful **`safe push`** operation.

After **`safe push`** notice a file called safe-database.ini within the removable drive folder.


## when to reconfigure the removable drive

Configure the removable.drive **once per user/machine** combo. You'll need to rerun the command when configuring safedb

- for **another user** on the same machine
- on a **different machine**
- to add more **removable drive** paths

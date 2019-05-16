
#### Use `safe push` and `safe pull` to remotely store and retrieve your safe books.

<span style="font-family:Papyrus; font-size:2em;">Currently safe only supports a github backend, but this will be expanded to include s3 buckets, git repositories, ssh and sftp, dropbox, google drive and even key-value stores like etcd, redis and Amazon's dynamo db.</span>

# safe push | safe pull

**We want safe to push its crypts to, and then pull them from a remote github repository.**

Let's use Github as the remote backend store for safe crypts and a usb key (removable drive) to store salts and other information that is worthless to an attacker without your passwords.

## push and pull pre-conditions

Ensure that you have the following accessories before integrating the safe database backend to a remote github repository.

- a github account (with username)
- the (40 character hexadecimal) github access token
- the path to a usb key, phone or removable drive
- your preferred github repository name

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
- for **another removable drive** path


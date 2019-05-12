
### Use `safe push` and `safe pull` to remotely store and retrieve your safe books. Currently safe only supports a github backend, but this will be expanded to include s3 buckets, git repositories, ssh and sftp, dropbox, google drive and even key-value stores like etcd, redis and Amazon's dynamo db.

# safe push | safe pull

**We want safe to push its crypts to, and then pull them from a remote github repository.**

Let's use Github as the remote backend store for safe crypts and a usb key (removable drive) to store salts and other information that is worthless to an attacker without your passwords.

## push and pull pre-conditions

Ensure that you have the following accessories before integrating the safe database backend to a remote github repository.

- a github account (with username)
- the (40 character hexadecimal) github access token
- the path to a usb key, phone or removable drive
- your preferred github repository name

## configure safe push pull

These are the setup commands for initializing the safe's push pull activity.

```
safe init db.admin
safe login db.admin
safe open remote.store github
safe put @github.access.token 43210fedcba43210fedcba43210fedcba43210fedcba
safe put github.repo.name safedb.backend.store
```

## configure the removable drive

The folder location **need not be removable**, but if you are moving from one machine to another, it helps for the folder path you specify to be on a removable USB key, drive or mounted phone.

```
safe configure removable.drive /media/samsung/evo
```

Configure the removable.drive **once per user/machine** combo. You'll need to rerun the command when configuring safedb

- for **another user** on the same machine
- on a **different machine**
- for **another removable drive** path

## safe push

You **`safe push`** to synchronize your local and remote safe database.

```
safe login db.admin   # once per session (shell)
safe push             # as often as you like
```

The following will be true after every successful **`safe push`** operation.

After **`safe push`** notice a file called safe-database.ini within the removable drive folder.


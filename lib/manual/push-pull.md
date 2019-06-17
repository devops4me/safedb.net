
#### Use `safe push` and `safe pull` to remotely store and retrieve your safe books.

<span style="font-family:Papyrus; font-size:2em;">**`safe remote --provision`** must have been run with access to the Github repository token so that it can **create the git repository backend** and furnish that repository with a public key so that a **`git push`** can occur during a **`safe push`** execution.</span>

**A push puts your crypt files into remote storage and writes a single file to a (usb key or phone) removable drive. A pull reads the file, accesses the right repository and restores (or refreshes) your safe database.**

The ***removable.drive*** folder **need not be removable**, but if you are moving from one machine to another, it helps if the path sits on a removable USB key, an external drive, or a smartphone.



# safe push --to="/path/to/removable/drive"

The first time you **`safe push`** on a machine you must provide a path to a folder on a removable drive. This is cached against a reference in the form **`username@<MACHINE_ID>`**.

Simply provide the **`--to`** option to use a different removable drive folder.



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

<span style="font-family:Papyrus; font-size:2em;">Currently safe only supports a github backend, but this will be expanded to include s3 buckets, git repositories, ssh and sftp, dropbox, google drive and even key-value stores like etcd, redis and Amazon's dynamo db.</span>



# safe pull --from="/path/to/removable/drive"

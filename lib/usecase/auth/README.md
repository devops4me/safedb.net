
# Safe Administration Commands

A safe database is a collection of books and each database instance comprises of an index file and a collection of crypt files.

You can use your safe on many machines and on many shells within a machine. All this is synchronized via a **git repository** and with a single index file that is generally kept on removable (usb key) media.

## safe branch admin commands

These commands handle **book and branch creation, instantiation and synchronization** between multiple shells.

| safe command                 | command purpose                                      | cmd summary      |
|:---------------------------- |:---------------------------------------------------- |:---------------- |
| **`safe init <BOOK_NAME>`**  | instantiate a new safe database book                 | create book      |
| **`safe login <BOOK_NAME>`** | create a new shell for instantiated book     | instantiate book |
| **`safe commit`**            | save the state of the book locally (like git commit) | save book        |
| **`safe logout`**            | delete references to this book and shell     | delete branch   |
| **`safe use <BOOK_NAME>`**   | switch shell to using this logged in book    | update branch   |
| **`safe token`**             | creates cryptographic keys for every shell   | create key       |


## safe database sync commands

The **push** and **pull** commands synchronize your safe across many machines.

- **`safe pull --from=/path/to/usb/folder`** | pull safe assets to a machine with old state
- **`safe pull`** | uses index on usb drive if known and available (else refreshes local state)
- **`safe push --to=/path/to/usb/folder`** | pushes out safe assets from a machine with new state
- **`safe push`** | pushes out using index on usb drive if known and available

You must tell the safe where your remote git repository is.

- **`safe store git.pull.url https://github.com/devops4me/example.crypt.git`**
- **`safe store git.push.url git@safedb.crypt:devops4me/example.crypt.git`**

## chicken and egg | public crypts

The safe is designed to **hold your private keys** so it would be chicken and egg if you needed a private key to access it.

The crypt files are designed to be utterly useless to those without both your usb key and your password. This is why

- **`git.pull.url`** can be publicly accessible from github **`https://github.com/...`**
- **`git.push.url`** is private **`git@<NAME>:<USER>/<REPO>`**

After you access your safe you then have the private key enabling you to push changes to your safe.

You can prevent access to your crypts by using a privately accessible git.pull.url.

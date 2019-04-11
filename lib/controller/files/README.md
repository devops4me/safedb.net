
# safe read | safe write | reading and writing files

You ingest a file with **safe file** and then **safe eject** will output that file into the present working directory.

If safe detects during an eject, that a file already exists with the same name - it backs it up with a timestamp before ejecting and clobbering the existing file.

```bash
safe open <<chapter-name>> <<verse-name>>
safe file <<keyname>> <</path/to/private-key.pem>>
safe eject <<keyname>>
safe show
```

To pull in 3 certificate oriented files for Kubernetes one could use these commands.

```bash
safe open production kubernetes
safe file kubernetes.cert ~/.kubectl/kube.prod.cert.pem
safe file kubernetes.ca.cert ~/.kubectl/kube.prod.ca.cert.pem
safe file kubernetes.key ~/.kubectl/kube.prod.key.pem
cd /tmp
safe eject
```

The safe ingests the files and spits them out whenever you so desire.
**Binary files** are supported and can be safely pulled in with <tt>safe file</tt> and ejected at any point in the future.

## remote (external) files

The **local filesystem** is the most common, but by no means the only file storage location. You can read from and write to

- a zip file **`zip://`**
- an S3 filesystem **`s3://`**
- SSH locations **`<<user>>@<<hostname>>:/path/to/file`**
- a git repository **`git@github.com`**
- a **google drive** store

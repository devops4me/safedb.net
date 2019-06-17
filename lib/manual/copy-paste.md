<tt>Copy and paste data to and from the **clipboard**</tt>.

# safe copy | safe clear | safe paste

## copy | intro

Copy into the clipboard the value held by the named line at the current book's open chapter and verse. This is more accurate and more secure than echoing the password and then performing a SELECT then COPY and then PASTE.

Use <b>safe clear</b> to wipe (overwrite) the sensitive value in the clipboard.


## paste | intro

Paste does the reverse of copy and also **auto-clears** the clipboard.

In the external application you select the text to copy, you then switch and type in something like **`safe paste @github.token`** - all verse lines will be displayed with sensitive values masked out. Note the extra line.

### Overwriting the Line's Value

If the line already exists and holds a value the paste operation will put the outgoing key/value pair into the **safe recycle bin**. This gives you a restore option.


## pre-condition - install xclip

Linux uses xclip to manage the clipboard so we need to install it before using safe's copy and paste functions.

```
sudo apt install xclip
```


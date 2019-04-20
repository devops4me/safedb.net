
# safe drag | safe drop

<tt>safe drag</tt> picks up data from one place and <tt>safe drop</tt> places that data elsewhere.

## On the same level

You can only drop data when you are at the same level as when you picked it up (although not necessarily in the same book).

### Verse Level

This example drags a key/value pair from one verse to another in the same book.

```
safe open <<chapter.x>> <<verse.x>>
safe drag <<line>>
safe open <<chapter.y>> <<verse.y>>
safe drop
```

## Different Books

You can use drag and drop to take data from one book and drop it into another. The rules about being on the same level still apply.

### Drag line to another book

Samantha is not just a cousin, she was in the same class in 2010. I want to copy her phone number from my family book to my friends book.

```
safe login friends
safe login family
safe open cousins samantha
safe drag phone.number
safe use friends
safe open class-of-2010 samantha
safe drop
safe logout --all
```

If the phone number existed it will be overwritten. If not it will be created.

## Dragging more than one

The <tt>--all</tt> switch can be used to drag a collective.

You can either drag a single line, verse or chapter, or you can drag

- every line in a verse
- every verse in a chapter
- every chapter in a book

## All siblings are invited to the wedding

This example copies all (verse) siblings to the wedding-guests chapter.

```
safe open siblings
safe drag --all
safe open wedding-guests
safe drop
```

## Renaming when you drop

What if you want to rename the line, verse or chapter being dragged and dropped. You can! As long as you are not dragging multiples (using --all).

You can use the data in one verse as a starting point for another.

```
safe open contacts
safe drag peter
safe drop paul
```

The paul verse is created with the same lines as peter has.

If a paul verse already existed the data within it is merged with priority (on conflicts) given to the (incoming) data being dropped.

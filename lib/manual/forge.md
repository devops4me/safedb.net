
# safe forge | create new passwords
@todo - change word spread to MINIMUMS
@todo - add --copy --print and --spread parameters<br/>
@todo - keeping mask, length, offset and spread in verse<br/>
@todo - validate spread drop length-offset to lower multiple of 6 and divide by 6 - spread must be equal to or less than answer

```
spread maximum = ((length-offset) - ((length-offset) % 6) ) / 6
```


**`safe forge`** creates passwords from a 90 character pool using the most robust random generation from Linux and OSx machines.

```
safe forge                # forge a password with a default strength of 2
safe forge --strengh 4    # forge passwords with a 4 out of 7 strength
safe forge --length 14    # forge a 14 character password
safe forge --mask F       # include apostrophes, at signs, hyphens and underscores
safe forge --mask 9FFDFF7 # all chars except hash, ampersand, Squiggle and apostrophe
```

## --strength -s | define strength of forged password

The strength sets an initial mask, length and offset for the password which can be individually overriden using the --mask, --length and --offset parameters.
The strength also defines **spread** which is the minimum number of special characters, upper case letters and digits that the generated credential must contain.

Strength must be a value from zero (0) to seven (7).

```
 ------------------------------------------------------------
 |            | Special          |        |        |        |
 |  Strength  | Character Mask   | Length | Offset | Spread |
 | ---------- + ---------------- + ------ + ------ + ------ |
 |     0      | 0                | 9      |  0     |  0     |
 |     1      | F                | 12     |  1     |  1     |
 |     2      | FF               | 14     |  2     |  2     |
 |     3      | FFF              | 17     |  3     |  2     |
 |     4      | FFFF             | 22     |  4     |  3     |
 |     5      | FFFFF            | 30     |  5     |  3     |
 |     6      | FFFFFF           | 43     |  6     |  4     |
 |     7      | FFFFFFF          | 64     |  7     |  4     |
 ------------------------------------------------------------
```

### Deriving the Strength

The default strength is 2 but forge derives the strength from the mask and if necessary the length provided.

Deriving the strength from the mask is about counting the number of special characters in the mask and using this formula.

```
( no.chars - (no.chars % 4) ) / 4
```

A mask of `FF5A1` has 4 + 4 + 2 + 2 + 1 = 13 characters.
Now ( 13 - ( 13 mod 4 ) ) / 4 = 3 so the strength is 3.

Deriving the strength from the length can be done using 9 with additions of the fibonnacci sequence then appropriately paired down.

## --mask -m | which special characters

```
safe forge --mask FF
safe forge --mask 300f
```
A hexadecimal mask is used to define **which of the 28 special characters** are allowed to appear in the password.

```
 --------------------------------------------------------------------------------------
 |  #  | Eight (8)         |  Four (4)       | Two (2)           | One (1)            |
 | --- + ----------------- + --------------- + ----------------- + ------------------ |
 |  1  | Apostrophe (!)    | At Sign (@)     | Hyphen (-)        | Underscore (_)     |
 |  2  | Plus Sign (+)     | Hat Symbol (^)  | Per Cent (%)      | Dollar Sign ($)    |
 |  3  | Semi-Colon (;)    | Colon (:)       | Comma (,)         | Period (.)         |
 |  4  | Equals (=)        | Fwd Slash (/)   | Squiggle (~)      | Pipe Symbol (|)    |
 |  5  | Left Soft (       | Right Soft )    | Left Square [     | Right Square ]     |
 |  6  | Left Angle <      | Right Angle >   | Left Squiggly {   | Right Squiggly }   |
 |  7  | Question Mark (?) | Hash (#)        | Ampersand (&)     | Asterix  (*)       |
--------------------------------------------------------------------------------------
```

These examples illustrate how to use the mask with the above table to add and remove special characters from the pool of 28.

- `FF` - include these 8 charaters `!@-_+^%$`
- `300f` - include these 6 characters `~|!@-_`
- `a008173` - include these 9 characters `?&=.^%$-_`
- `0` - exclude all special characters
- `fffffff` - include all 28 special characte3rs

The mask value overrides the default mask implied by the strength.

Also note that
- the mask must be a hexadecimal number (case is not important)
- the mask cannot be greater than FFFFFFF (16 x 7 - 1)
- the mask cannot be less than zero

## --length -n | set the average length

If you specify the length without an offset the generated password will be exactly that length.
It is more secure to provide an offset.

```
safe forge --length 17             # exactly 17 characters long
safe forge --length 17 --offset 3  # 14 to 20 characters long
```

Also note that
- if you just provide the strength the length and offset are derived (see table)
- the length overrides the default length implied by the strength
- the length with offset applied must be at least **6** and at most **90** characters
 

## --offset -o | set the length offset

If an attacker knows the exact length of a password it makes their job easier.
Offsets vary the length of the manufactured password so a strength 5 password by default can be 25 to 35 characters long.

```
safe forge --strength 4            # 18 to 26 characters long
safe forge --length 17             # exactly 17 characters long
safe forge --length 17 --offset 3  # 14 to 20 characters long
```

Also note that
- the offset overrides the default offset implied by the strength
- the offset cannot be more than half the length
- the offet cannot push the length below the minimum or above the maximum


## safe forge `<line>` | safe forge `<verse>`

By default the forged string is placed in the opened chapter/verse in a line called `@password`. You can optionally specify the verse or line to place the forged string. The line named **`@password`** is the default destination.

```
safe forge @new-password           # hold generated password in line @2ndpassword
safe forge v:gmail/@new.password  # specify verse and line holding the password
safe forge v:iplayer              # put password in verse iplayer line @password
safe forge c:house/wifi           # put in chapter house verse wifi line @password
```

## safe forge | prerequisites

@todo add text about linux cat /dev/urandom and other linux flavours

## Appendix A | Generating Credentials

The most powerful known technique for generating a random sequence of characters on Linux involves the <tt>urandom</tt> command.

```
cat /dev/urandom | head -c 2000 | tr -dc 'A-Za-z0-9!@$%^&*()\-_+=#{}[]:;|,.<>?/~'
head /dev/urandom | tr -dc A-Za-z0-9 | head -c 18 ; echo ''
head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 ; echo ''
head /dev/urandom | tr -dc A-Za-z0-9?@=$~%/+^.,][\{\}\<\>\&\(\)_\- | head -c 258 ; echo
export LC_CTYPE=C   # tell tr to expect binary data instead of UTF-8 characters "tr: Illegal byte sequence"
cat /dev/urandom | head -c 2000 | tr -dc 'A-Za-z0-9!@$%^&*()\-_+={}[]:;|,.<>?/~'
cat /dev/urandom | head -c 2000 | tr -dc 'A-Za-z0-9!@$%^&*()\-_+={}[]:;|,.<>?/~' | grep -F '~'
```


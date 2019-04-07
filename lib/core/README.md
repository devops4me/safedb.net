

# Cycling Book Master and Branch State

Cycle cycles state indices and content crypt files to and from master and branches.
The need to cycle content occurs during

- <tt>initialization</tt> - a new master state box is created
- <tt>login</tt> - branch state is created that mirrors master
- <tt>checkin</tt> - transfers state from branch to master
- <tt>checkout</tt> - transfers state from master to branch


## State Elements Transition Table

| Element   |  Located     | Create Usecases   | Updated by Usecases | Read by Usecases  | Derived From      |
|:------------ |:------------ |:----------------- |:------------------- |:----------------- |:----------------- |
| Key derived from human password | Master Indices File | Book Init | Every Login | Every Login | human password and pbkdf2 and bcrypt salts  |
| Strong Random Index Crypt Key | Locked with Human and Branch keys | First created during  book initialization | Updated on the very first book login after machine bootup | Read on logins and then all book query/edit use cases | random generator










== Book Login

<tt>Derive the Old</tt>

The login use case is about <tt>re-generating the key from the password text and salts<tt>
and then accessing the old human crypt key and using it to unlock and access the current strong
random content encryption key. The old ciphertext protecting the book index is also acquired
and unlocked.

<tt>Generate the New</tt>

Another strong key is acquired and used to lock the book index. This strong key is itself
locked by the newly generated key (rederived from the source (human) key and the 


Finding and rederiving the old produces the book index ciphertext which , spinning up a new one and deftly unlocking the master
database with the old and immediately locking it back up again with the new.

The login process also creates a new workspace consisting of
- a clone of the master content crypt files
- a new set of indices allowing for the acquisition of the new content key via a shell-based branch key
- a mirrored commit reference that allows commit (save) back to the master if it hasn't moved forward
- stating that subsequent commands are for this book and other branch books in play are to be set aside

The logout process destroys the breadcrumb route back to the re-acquisition of the
content encryption key via the shell key. It also deletes the branch crypts.

== Login Logout Stack Push Pop

The login/logout works like a stack push pop or like a nested structure. A login wrests
control away from the currently logged in book whilst a logout cedes control to the
book that was last in play.

<b>Login Recycles 3 things</b>

The three (3) things recycled by this login are

- the human key (sourced by putting the secret text through two key derivation functions)
- the content crypt key (sourced from a random 48 byte sequence) 
- the content ciphertext (sourced by decrypting with the old and re-encrypting with the new)

Remember that the content crypt key is itself encrypted by two key entities.

























# The open key library generates keys, it stores their salts, it produces differing
# representations of the keys (like base64 for storage and binary for encrypting).
#
# == Key Class Names their and Responsibility
#
# The 5 core key classes in the open key library are
#
# - {Key} represents keys in bits, binary and base 64 formats
# - {Key64} for converting from to and between base 64 characters
# - {Key256} uses key derivation functions to produce high entropy keys
# - {KeyIO} reads and writes key metadata (like salts) from/to persistent storage
# - {KeyCycle} for creating and locking the keys that underpin the security
#
# == The 5 Core Key Classes
#
#     Key              To initialize with a 264 binary bit string. To hold the
#                      key and represent it when requested
#                       - as a 264 bit binary bit string
#                       - as a 256 bit binary bit string
#                       - as a 256 bit raw bytes encryption key
#                       - as a YACHT64 formatted string
#
#     Key64            To map in and out of the Yacht64 character set - from and to
#                       - a binary bit string sequence
#                       - a Base64 character encoding
#                       - a UrlSafe Base64 character encoding
#                       - a Radix64 character encoding
#
#     Key256           It generates a key in 3 different and important ways. It can
#                      generate
#
#                        (a) from_password
#                        (b) from_random (or it can)
#                        (c) regenerate
#
#                      When generating from a password it takes a dictionary with
#                      a pre-tailored "section" and writes BCrypt and Pbkdf2 salts
#                      into it.
#
#                      When generating random it kicks of by creating a 55 byte
#                      random key fo BCrypt and a 64 byte random key for Pbkdf2.
#                      It then calls upon generate_from_password.
#
#                      When regenerating it queries the dictionary provided at the
#                      pre-tailored "section" for the BCrypt and Pbkdf2 salts and
#                      then uses input passwords (be they human randomly sourced)
#                      and regenerates the keys it produced at an earlier sitting.
#
#     KeyIO            KeyIO is instantiated with a folder path and a "key reference".
#                      KeyIO will then manage writing to and rereading from the structure
#                      hel inside th efile. The file is named (primarily) by the
#                      reference string.
#
#     KeyCycle         KeyLifeCycle implements the merry go round that palms off
#                      responsibility to the intra-branch cycle and then back again
#                      to ever rotary inter-branch(ary) cycle.
###########            Maybe think of a method where we pass in
###########            2 secrets - 1 human and 1 55 random bytes (branch)
###########
###########            1  another 55 random key is created (the actual encryption key)
###########            2  then the above key is encrypted TWICE (2 diff salts and keys)
###########            3  Once by key from human password
###########            4  Once by key from machine password
###########            5  then the key from 1 is returned
###########            6  caller encrypts file .................... (go 4 it)


# Generates a 256 bit symmetric encryption key derived from a random
# seed sequence of 55 bytes. These 55 bytes are then fed into the
# {from_password} key derivation function and processed in a similar
# way to if a human had generated the string.
#


# <b>Key derivation functions</b> exist to convert <b>low entropy</b> human
# created passwords into a high entropy key that is computationally difficult
# to acquire through brute force.
#
# == SafeDb's Underlying Security Strategy
#
# <b>Randomly generate a 256 bit encryption key and encrypt it</b> with a key
# derived from a human password and generated by at least two cryptographic
# workhorses known as <b>key derivation functions</b>.
#
# The encryption key (encrypted by the one derived from a human password) sits
# at the beginning of a long chain of keys and encryption - so much so that the
# crypt material being outputted for storage is all but worthless to anyone but
# its rightful owner.
#
# == Key Size vs Crack Time
#
# Cracking a 256 bit key would need roughly 2^255 iterations (half the space)
# and this is akin to the number of atoms in the known universe.
#
# <b>The human key can put security at risk.</b>
#
# The rule of thumb is that a 40 character password with a good spread of the
# roughly 90 typable characters, would produce security equivalent to that of
# an AES 256bit key. As the password size and entropy drop, so does the security,
# exponentially.
#
# As human generated passwords have a relatively small key space, key derivation
# functions must be slow to compute with any implementation.
#
# == Key Derivation Functions for Command Line Apps
#
# A command line app (with no recourse to a central server) uses a Key
# Derivation Function (like BCrypt, Aaron2 or PBKD2) in a manner different
# to that employed by server side software.
#
# - server side passwords are hashed then both salt and hash are persisted
# - command line apps do not store the key - they only store the salt
# - both throw away the original password
#
# == One Key | One branch | One Crypt
#
# Command line apps use the derived key to <b>symmetrically encrypt and decrypt</b>
# one and only one 48 character key and a new key is derived at the beginning
# of every branch.
#
# At the end of the branch <b>all material encrypted by the outgoing key</b>
# is removed. This aggressive key rotation strategy leaves no stone unturned in
# the quest for ultimate security.
#
# == SafeDb's CLI Key Derivation Architecture
#
# SafeDb never accesses another server and giving its users total control
# of their secret crypted materials. It strengthens the key derivation process
# in three important ways.
#
# - [1] it does not store the key nor does it store the password
#
# - [2] a new master key is generated for every branch only to hold the master index file
#
# - [3] it uses both <b>BCrypt</b> (Blowfish Crypt) and the indefatigable <b>PBKD2</b>

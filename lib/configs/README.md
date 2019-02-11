
# Modifying Safe's Behaviour | 4 Configuration Scopes

Safe's behaviour can (by default) be modified in a manner that is scoped in 4 ways. Configuration directives can alter behaviour within

1. a **book global** scope
2. a **machine local** scope
3. a **shell session** scope and
4. a **machine global** scope

The scoping concept is similar to Git's --local and --global but it works in a different way.


## 1. Book Global Scope

Directives issued against a safe book **"feel local"** but are global in that the behaviour persists on every machine that works with the book.

Git's --local is different because cloning the repository on another machine wipe's out the directives. With safe the directives continue to alter behaviour even when the book is cloned and/or used on another machine.


## 2. Machine Local Scope

This is similar to Git's --global directive which affects all repositories owned by a user on a given machine.

Directives with a machine local scope **can influence the behaviour** of every Safe book one logs into on a machine. Move to another machine and the behaviour becomes unstuck.

== Configuration Directive Precedence

Note the sentence **can influence behaviour** as opposed to **will influence behaviour**.

If a directive with a book global scope says "Yes" and the same directive exists but says "No" with machine local scope the "Yes" wins out.

A book global directive overrides its machine local twin.


## 3. Shell Session Scope

The self explanatory **shell session scoped** directives override their siblings be they book global or machine local.

Alas, their elevated privileges are countered by relatively short lifespans. Shell session directives only last until either a logout is issued or the shell session comes to an end.


## 4. Default | Machine Global Scope

Did you notice only **one (1) user** is affected by directives with a machine local scope as long as it isn't overriden.

Directives with a **machine global scope** are the **default** and are set during an install or upgrade.

They can potentially affect **every user and every safe book**. Even though their longevity is undisputed, their precedence is the lowest when going head to head with their 3 siblings.

## The Naked Eye

Directives with a book global scope **aren't visible to the naked eye**. They are encrypted within the master safe database and thus protected from prying eyes.

The other 3 directive types exist in plain text

- either where the gem is **installed** (machine global scope)
- or in the INI file in **.safe** off the user's home directory

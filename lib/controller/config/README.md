
# Safe | Increasing Key Derivation Function Cost

Safe uses two **key derivation functions** (**BCrypt** and **PBKDF2**) to transform the human sourced password into a key. The only role the resulting key plays is the encryption and decryption of a large **highly random computer generated key** which in turn protects the **master database**.

### Why are two (2) key derivation algorithms used?

Your credentials are still safe even in the rare case of a successful analytical attack being discovered on one of the algorithms.

## Why High Computational Costs are Desirable?

Unlike most algorithms, key derivation functions **work best when they run slowly!** This protects against brute force attacks where attackers use "rainbow tables" or try to iterate over common passwords in an attempt to rederive the key.

Your responsibility is to make **safe as slow as is tolerable** by increasing the number of iterations required to derive each key.

## Safe | Increasing the Cost of Both Key Derivation Functions

You should increase the cost of **safe's** key derivation functions until safe commands run as slow as is tolerably and no less!

```bash
safe cost bcrypt 3
safe cost pbkdf2 4
```

Both algorithms can be configured with a cost parameter from 1 to 7 inclusive. The default cost is 1 for both and is moderately secure and runs as slowly as is tolerable on an IBM ThinkPad laptop with an Intel Pentium i5 processor with 16G of RAM.

Note that PBKDF2 has no maximum. BCrypt limits the cost to 2^16.

<pre>
    -------- - ------------ - --------------- - --------------------- - ---------------- -
    |  Cost  |     BCrypt   |       BCrypt    |        PBKDF2         |     PBKDF2       |
    |        |     Cost     |    Iterations   |         Cost          |   Iterations     |
    | ------ - ------------ - --------------- - --------------------- - ---------------- |
    |    1   |     2^10     |       1,024     |      3^0 x 100,000    |       100,000    |
    |    2   |     2^11     |       2,048     |      3^1 x 100,000    |       300,000    |
    |    3   |     2^12     |       4,096     |      3^2 x 100,000    |       900,000    |
    |    4   |     2^13     |       8,192     |      3^3 x 100,000    |     2,700,000    |
    |    5   |     2^14     |      16,384     |      3^4 x 100,000    |     8,100,000    |
    |    6   |     2^15     |      32,768     |      3^5 x 100,000    |    24,300,000    |
    |    7   |     2^16     |      65,536     |      3^6 x 100,000    |    72,900,000    |
    -------- - ------------ - --------------- - --------------------- - ---------------- -
</pre>

When you increase the cost **safe will become perceivably slower**. With a cost of 7, a laptop takes many minutes but an AWS cloud compute optimized M5 server crunches through in mere seconds.

## What is Your Data Worth?

Attackers can bring a significant amount of modern data centre hardware to the table in order to access your credentials.

However, these computing resources cost money and the amount of money an attacker spends will be proportional to the perceived gains from a successfully attack. The bigger the dollar signs in their eyes, the more they will spend.

The default settings coupled with a **12 character password** takes (on average) 50 years to crack with computing resources that will cost $1,000 every single day.

### Twenty Million Dollars

If what you are protecting is worth more than **$(50 x 366 x 1,000)**, you should use an at least 16 character password and increase the computational cost parameters for both key derivation functions.


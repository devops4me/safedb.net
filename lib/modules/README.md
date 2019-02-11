

In order for data to be secured for storage or transmission, it must be transformed in such a manner that it would be difficult for an unauthorized individual to be able to discover its true meaning. To do this, certain mathematical equations are used, which are very difficult to solve unless certain strict criteria are met. The level of difficulty of solving a given equation is known as its intractability. These types of equations form the basis of cryptography.

Some of the most important are:

== The Discrete Logarithm Problem

The best way to describe this problem is first to show how its inverse concept works. The following applies to Galois fields (groups). Assume we have a prime number P (a number that is not divisible except by 1 and itself, P). This P is a large prime number of over 300 digits. Let us now assume we have two other integers, a and b. Now say we want to find the value of N, so that value is found by the following formula:

N = ab mod P, where 0 <= N <= (P · 1)

(meaning a to the power b mod P)
(learn to do powers in markdown)!


This is known as discrete exponentiation and is quite simple to compute. However, the opposite is true when we invert it. If we are given P, a, and N and are required to find b so that the equation is valid, then we face a tremendous level of difficulty.


This problem forms the basis for a number of public key infrastructure algorithms, such as Diffie-Hellman and EIGamal. This problem has been studied for many years and cryptography based on it has withstood many forms of attacks.

== The Integer Factorization Problem

This is simple in concept. Say that one takes two prime numbers, P2 and P1, which are both "large" (a relative term, the definition of which continues to move forward as computing power increases). We then multiply these two primes to produce the product, N. The difficulty arises when, being given N, we try and find the original P1 and P2. The Rivest-Shamir-Adleman public key infrastructure encryption protocol is one of many based on this problem. To simplify matters to a great degree, the N product is the public key and the P1 and P2 numbers are, together, the private key.

This problem is one of the most fundamental of all mathematical concepts. It has been studied intensely for the past 20 years and the consensus seems to be that there is some unproven or undiscovered law of mathematics that forbids any shortcuts. That said, the mere fact that it is being studied intensely leads many others to worry that, somehow, a breakthrough may be discovered.

== The Elliptic Curve Discrete Logarithm Problem

This is a new cryptographic protocol based upon a reasonably well-known mathematical problem. The properties of elliptic curves have been well known for centuries, but it is only recently that their application to the field of cryptography has been undertaken.

First, imagine a huge piece of paper on which is printed a series of vertical and horizontal lines. Each line represents an integer with the vertical lines forming x class components and horizontal lines forming the y class components. The intersection of a horizontal and vertical line gives a set of coordinates (x,y). In the highly simplified example below, we have an elliptic curve that is defined by the equation:

y2 + y = x3 · x2 (this is way too small for use in a real life application, but it will illustrate the general idea)

For the above, given a definable operator, we can determine any third point on the curve given any two other points. This definable operator forms a "group" of finite length. To add two points on an elliptic curve, we first need to understand that any straight line that passes through this curve intersects it at precisely three points. Now, say we define two of these points as u and v: we can then draw a straight line through two of these points to find another intersecting point, at w. We can then draw a vertical line through w to find the final intersecting point at x. Now, we can see that u + v = x. This rule works, when we define another imaginary point, the Origin, or O, which exists at (theoretically) extreme points on the curve. As strange as this problem may seem, it does permit for an effective encryption system, but it does have its detractors.

On the positive side, the problem appears to be quite intractable, requiring a shorter key length (thus allowing for quicker processing time) for equivalent security levels as compared to the Integer Factorization Problem and the Discrete Logarithm Problem. On the negative side, critics contend that this problem, since it has only recently begun to be implemented in cryptography, has not had the intense scrutiny of many years that is required to give it a sufficient level of trust as being secure.

This leads us to more general problem of cryptology than of the intractability of the various mathematical concepts, which is that the more time, effort, and resources that can be devoted to studying a problem, then the greater the possibility that a solution, or at least a weakness, will be found.




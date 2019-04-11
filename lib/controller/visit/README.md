#### The **safe philosophy** is to minimize human interaction with large random credential strings. Your credential-less interactions with Terraform, AWS and now website logins is not just **simple**, it is also **more secure**.

# safe visit | visit (login to) a website

**Issue <tt>safe visit</tt> and you will be logged in.**

To login to a website your verse needs to contain a <tt>signin.url</tt>, a <tt>username</tt> or <tt>email</tt> and a <tt>password</tt>.

## Technologies Used to Visit Websites

**Selinium** and the **Ruby Watir** library are used to interact with web browsers to enable hands free logins.

### How to install Watir

Use **`curl`** to pull down and place the following executable into /usr/local/bin

https://github.com/mozilla/geckodriver/releases/download/v0.24.0/geckodriver-v0.24.0-linux64.tar.gz

Now when you run the **`ruby visit.rb`** the browser should pop up and search for our search term.

### Reading Material

https://applitools.com/tutorials/watir.html#run-your-first-test
http://watir.com/guides/

http://watir.com/
https://www.rubydoc.info/gems/watir/




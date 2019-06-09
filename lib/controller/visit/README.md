#### The **safe philosophy** is to minimize human interaction with large random credential strings. Your credential-less interactions with Terraform, AWS and now website logins is not just **simple**, it is also **more secure**.

# safe visit | visit (login to) a website

**Issue <tt>safe visit</tt> and you will be logged in.**

To login to a website your verse needs to contain a <tt>signin.url</tt>, a <tt>username</tt> or <tt>email</tt> and a <tt>password</tt>.

## Technologies Used to Visit Websites

**Selinium** and the **Ruby Watir** library are used to interact with web browsers to enable hands free logins.

### How to install Watir

Use **`curl`** to pull down and place the following executable into /usr/local/bin

https://github.com/mozilla/geckodriver/releases/download/v0.24.0/geckodriver-v0.24.0-linux64.tar.gz

``` bash
curl -o /tmp/geckodriver https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
sudo unzip /tmp/terraform.zip -d /usr/local/bin
sudo chmod a+x /usr/local/bin/terraform
rm /tmp/terraform.zip
terraform --version
```

```
## Geckodriver
wget https://github.com/mozilla/geckodriver/releases/download/v0.23.0/geckodriver-v0.23.0-linux64.tar.gz
sudo sh -c 'tar -x geckodriver -zf geckodriver-v0.23.0-linux64.tar.gz -O > /usr/bin/geckodriver'
sudo chmod +x /usr/bin/geckodriver
rm geckodriver-v0.23.0-linux64.tar.gz

## Chromedriver
wget https://chromedriver.storage.googleapis.com/2.29/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
sudo chmod +x chromedriver
sudo mv chromedriver /usr/bin/
rm chromedriver_linux64.zip
```

gem install nokogiri

gem install mini_magick -v 3.5

gem install watir --no-ri --no-rdoc

gem install watir-webdriver --no-ri --no-rdoc




Now when you run the **`ruby visit.rb`** the browser should pop up and search for our search term.

### Reading Material

https://applitools.com/tutorials/watir.html#run-your-first-test
http://watir.com/guides/

http://watir.com/
https://www.rubydoc.info/gems/watir/





# safe terraform <command>

### safe terraform | introduction

This terraform use case exports the AWS IAM user access key, secret key and region key into (very safe) environment variables and then runs the specified terraform be it **plan**, **apply** or **destroy**.

The plan is to extend this command to directly cache terraform output variables.

### Passing Input Variables

The most powerful feature of **`safe terraform`** is the ability to pass safely stored input variables to terraform via environment variables. The safe exports data when the key

- **either** begins with **`tfvar.`**
- **or** begins with **`@tfvar.`** (for sensitive values)

### safe input variables examples

| **safe key**                  | **safe value**         | type      | exported env variable | usage                    |
|:----------------------------- |:---------------------- |:--------- |:--------------------- |: ----------------------- |
**tfvar.in_vpc_id**             | vpc-1234567890         | string    | TF_VAR_in_vpc_id      | var.in_vpc_id
**tfvar.in_role_arn**           | arn:aws:iam::98764 ... | string    | TF_VAR_in_role_arn    | var.in_role_arn
**@tfvar.in_db_password**       | secret-543+210=753     | string    | TF_VAR_in_db_password | var.in_db_password
**tfvar.in_ingress**            | '[ "ssh", "http" ]'    | list      | TF_VAR_in_ingress     | var.in_ingress

Mostly you pass string, number or boolean input variables to terraform. These examples also show how you can pass list and map variables to terraform.

---

## safe terraform | credential creation

The first use case is importing the IAM user credentials into safe.

    $ safe login joebloggs.com                  # open the book
    $ safe open iam dev.s3.writer               # open chapter and verse
    $ safe put @access.key ABCD1234EFGH5678     # Put IAM access key in safe
    $ safe put @secret.key xyzabcd1234efgh5678  # Put IAM secret key in safe
    $ safe put region.key eu-west-3             # infrastructure in Paris

    $ safe open iam prod.provisioner            # open chapter and verse
    $ safe put @access.key 4321DCBA8765WXYZ     # Put IAM access key in safe
    $ safe put @secret.key 5678uvwx4321abcd9876 # Put IAM secret key in safe
    $ safe put region.key eu-west-1             # infrastructure in Dublin

    $ safe logout

Take care to specify these 3 key names **@access.key**, **@secret.key**, **region.key** and note that safe's convention is to sensitively treat the value's of keys beginning with an **@** sign. **safe show** and other readers **mask out (redact)** these sensitive values.


## safe terraform | running terraform

Now and forever you can return to the chapter and verse and enjoy a secure credentials transfer where safe makes the IAM user credentials available to Terraform via environment variables. **Never do the plain text credentials touch the floor (disk).**

### Why no safe terraform init?
**safe only gets involved when credentials are involved**.
**safe** is not trying to wrap command willy nilly. safe's policy is to keep external tool interfaces as **small** as possible. **`terraform init .`** does not involve credentials so safe does not get involved.

    $ cd /path/to/terraform/dir     # go to directory holding your .tf file
    $ safe login joebloggs.com      # login to your chosen book
    $ safe open iam dev.s3.writer   # open chapter and verse holding IAM creds
    $ terraform init .              # the usual terraform init command
    $ safe terraform plan           # credentials are exported then terraform plan is run
    $ safe terraform apply          # credentials are exported then terraform apply is run
    $ safe terraform destroy        # credentials are exported then terraform destroy is run

You can even change directories and run other terraform projects against the opened IAM user. You can also open an IAM user, run commands, open another run commands and then reopen the first and run commands.

As long as you stay within your shell window - your safe login will persist. Once your branch is finished you either logout or exit the shell.

### Shortcut Alert

**safe terraform** is a shortcut for **safe terraform apply**

    $ safe terraform apply
    $ safe terraform

## safe terraform | pre-conditions

To enact a successful safe terraform call you will need

- to have created an IAM user
- to open chapter and verse which
- has these 3 keys @access.key @secret.key and region.key (at least)
- terraform installed on the machine or container


## safe terraform | benefits

The safe terraform command is both an ultra secure and extremely convenient way of launching terraform.

Your precious AWS IAM user credentials do not leave the safe and exist within (environment variable) memory only for the duration of the terraform command.

It is safe as you need neither expose your AWS credentials in plain text in **~/.aws/credentials**, nor risk them sliding into version control. It is convenient because switching IAM users and AWS regions is as easy as typing the now ubiquitous safe open command.


## quick tip | view then goto

No need to type out the safe open command everytime. Use it the very first time you create a path to chapter and verse.

    safe open <<chapter>> <<verse>>

Then use safe view and safe goto instead of safe open.

    $ safe view             # list all chapter and verses
    $ safe goto <<index>>   # use the number from safe view to open the location
    $ safe show             # look at your mini dictionary


## safe terraform | only for aws

This command currently only supports the AWS provider but will be extended to support Google's Compute Engine and more besides.


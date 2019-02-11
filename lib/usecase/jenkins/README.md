
# safe jenkins <command>


### safe jenkins post [aws|docker|git] <<jenkins-host-url>> | introduction

Use **`safe jenkins post`** to inject both your **AWS IAM User** and **docker login/password** credentials into your Jenkins 2.0 continuous integration portal reachable by the **jenkins host url** given in the 4th parameter of the safe command.

---

## safe jenkins post | prerequisite

Before you can inject credentials into jenkins using **`safe jenkins post`** you must

- be logged into your safe
- have opened the appropriate chapter/verse
- have put the required credential key/value pairs into the safe
- have the jenkins service up and running

After the post (to jenkins), your continuous integration jobs will be able to access the credential values via their IDs as stated in the below table.

---

## safe jenkins post aws | key names table

As credentials are WORO (write once, read often), safe makes the reading part very very easy (and secure) so your effort is frontloaded.

| Safe Key    | Jenkins Credential IDs | Environment Variable  | Description                                              |
|:-----------:|:----------------------:|:--------------------- |:-------------------------------------------------------- |
| @access.key | safe.aws.access.key    | AWS_ACCESS_KEY_ID     | The AWS IAM user's access key credential.                |
| @secret.key | safe.aws.secret.key    | AWS_SECRET_ACCESS_KEY | The AWS IAM user's secret key credential.                |
| region.key  | safe.aws.region.key    | AWS_REGION            | The AWS region key that your Jenkins service points to.  |

So you can see that by convention, safe expects the credential keys in the safe to be named a particular way, and likewise, you can be assured of the IDs it gives those credentials when posted to Jenkins.


## safe jenkins post | credentials lifecycle

The life of the credentials begins when you create an  IAM user and record its access and secret keys. Then

- you login to safe and store the 3 keys and their values
- safe jenkins post will read the values and post them to Jenkins
- Jenkins stores the values in conjunction with the Jenkins Credential IDs
- pipeline jobs ask Jenkins to put the Credential ID values against environment variables
- tools like Terraform and AwsCli use the environment variables to work in the cloud


## Jenkinsfile | Usage in Pipeline Jobs

Here is a pipeline declaration within a Jenkinsfile that asks Jenkins to put the credential values in its secrets store into the stated environment variables.

    environment
    {
        AWS_ACCESS_KEY_ID     = credentials( 'safe.aws.access.key' )
        AWS_SECRET_ACCESS_KEY = credentials( 'safe.aws.secret.key' )
        AWS_REGION            = credentials( 'safe.aws.region.key' )
    }

After **`safe jenkins post aws`** you can **click into the Credentials item in the Jenkins main menu** to assure yourself that the credentials have indeed been properly injected.

---

## How to Write AWS Credentials into your Safe

In order to **`safe terraform apply`** or **`safe jenkins post aws <<jenkins-host-url>>`** or `safe visit` you must first put those ubiquitous IAM programmatic user credentials into your safe.

    $ safe login joebloggs.com                  # open the book

    $ safe open iam dev.s3.reader               # open chapter and verse
    $ safe put @access.key ABCD1234EFGH5678     # Put IAM access key in safe
    $ safe put @secret.key xyzabcd1234efgh5678  # Put IAM secret key in safe
    $ safe put region.key eu-west-3             # infrastructure in Paris

    $ safe open iam canary.admin                # open chapter and verse
    $ safe put @access.key 4321DCBA8765WXYZ     # Put IAM access key in safe
    $ safe put @secret.key 5678uvwx4321abcd9876 # Put IAM secret key in safe
    $ safe put region.key eu-west-1             # infrastructure in Dublin

    $ safe logout


---


## How to write DockerHub Credentials into your Safe

#### safe jenkins post docker https://jenkins.example.com

Before you can issue a **`safe jenkins post docker http://localhost:8080`** you must insert your docker login credentials in the form of a username and @password into your safe. Remember that any key starting with the `@ sign` tells the safe to keep it a secret like when you issue a **`safe show`** command.

    $ safe login joebloggs.com        # open the book
    $ safe open docker production     # at the docker (for production) chapter and verse
    $ safe put username admin         # Put the Docker repository login username into the safe
    $ safe put @password secret12345  # Put the Docker repository login @password into the safe
    $ safe logout

When docker credentials are injected into a Jenkins service the safe will expect to find a key at the open chapter and verse called username and another one called password.

The safe promises to inject credentials with an ID of **safe.docker.login.id** so any jenkins jobs that need to use the docker login username and password must specify this ID when talking to the Jenkins credentials service.


### DockerHub Credentials Inject Response

Here is an example of posting dockerhub credentials into a Jenkins service running on the local machine.

``` bash
safe jenkins post docker http://localhost:8080
```

If successful safe provides a polite response detailing what just happened.

```
 - Jenkins Host Url : http://localhost:8080/credentials/store/system/domain/_/createCredentials
 -   Credentials ID : safe.docker.login.id
 -  Inject Username : devops4me
 - So what is this? : The docker repository login credentials in the shape of a username and password.

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   428    0     0  100   428      0  47555 --:--:-- --:--:-- --:--:-- 47555
```

---


## safe integrations | we need your help

**You can help to extend safe's integrations.**

By design - safe integrations are simple to write. They primarily integrate with producers and consumers. To deliver efficacy to devops engineers safe will endeavour to

- **send** credentials to **downstream consumers** and
- **receive** credentials from **upstream producers**

safe needs pull requests from the devops community and it promises to always strive to keep the task of writing an integration extremely simple.

### integrations | what giving takes?

Currently, writing an integration entails delivering 3 or 4 artifacts which are

- 1 simple Ruby class
- 1 README.md documenting the command structure, the prerequisites and the expected outcome
- 1 class containing unit tests
- (optionaly) an INI file if many configuration and facts are involved

Giving doesn't take much so roll up your sleeves (or frocks) and get writing.

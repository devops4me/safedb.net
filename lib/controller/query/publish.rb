#!/usr/bin/ruby
	
module SafeDb

  # The safe publish command knows how to talk to external credential consumers
  # like Kubernetes Secrets, Jenkins Credentials, Git Secrets, Terraform Secrets,
  # Docker Secrets, HashiCorp's Vault and more besides.
  #
  # Use publish to tell safe what to publish, what to publish it as and if
  # necessary where to publish it to.
  #
  # - `safe publish --docker-registry-credentials --kubernetes-secret`
  # - `safe publish --username-password --jenkins --at http://localhost:8080`
  #
  # Visit documentation at https://www.safedb.net/docs/copy-paste
  class Publish < QueryVerse

    def query_verse()


    end


  end


end

pipeline
{
    agent
    {
        kubernetes
        {
            defaultContainer 'kaniko'
            yamlFile 'kaniko.yaml'
        }
    }
    stages
    {
        stage('Build Safe Docker Image')
        {
            steps
            {
                /*
                 * Since we're in a different pod than the rest of the
                 * stages, we'll need to grab our source tree since we don't
                 * have a shared workspace with the other pod(s)..
                 */

                /*
                checkout scm
                sh 'sh -c ./scripts/build-kaniko.sh'
                 */

                checkout scm
        sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --destination registry/devops4me/safedb:latest --insecure-registry registry --insecure --skip-tls-verify'

/*
 git 'https://github.com/jenkinsci/docker-jnlp-slave.git'
        sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify --cache=true --destination=mydockerregistry:5000/myorg/myimage'
*/

            }
        }

        stage('Run the Cucumber Tests')
        {
            agent {
                docker { image 'registry/devops4me/safedb:latest' }
            }
            steps {
                sh 'cucumber-test.sh'
            }
        }

    }
}

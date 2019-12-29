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
        sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --no-push'

/*
 git 'https://github.com/jenkinsci/docker-jnlp-slave.git'
        sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify --cache=true --destination=mydockerregistry:5000/myorg/myimage'
*/

            }
        }
    }
}

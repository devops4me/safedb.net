pipeline
{
    agent none

    stages
    {

        stage('Build Safe Docker Image')
        {
            agent
            {
                kubernetes
                {
                    defaultContainer 'kaniko'
                    yamlFile 'kaniko.yaml'
                }
            }

            steps
            {
               /*
                * We checkout the git repository again because we
                * are running in a different pod setup specifically
                * to build and test the software.
                */

                checkout scm
                sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --destination 10.1.61.145:5000/devops4me/safedb:latest --insecure-registry 10.1.61.145:5000 --insecure --skip-tls-verify --cleanup'
            }
        }


        stage('Run the Cucumber Tests')
        {
            agent
            {
                kubernetes
                {
                    yamlFile 'pipeline-pod.yaml'
                }
            }
            steps
            {
                container('safetests')
                {
                    sh 'cucumber-test.sh'
                }
            }

        }


    }

}

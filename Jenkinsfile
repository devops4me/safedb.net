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
                    yamlFile 'pod-image-builder.yaml'
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
                sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --destination devops4me/safetty:latest --cleanup'
            }

        }

        stage('Run the Cucumber Tests')
        {
            agent
            {
                kubernetes
                {
                    yamlFile 'pod-image-safetty.yaml'
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

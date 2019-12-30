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
/*
You do not need to specify the default container if you wrap the commands with a container name
                    defaultContainer 'safettytests'
*/
                    yamlFile 'pod-image-safetty.yaml'
                }
            }
            steps
            {
                container('safettytests')
                {
sh 'echo $PWD'
sh 'ls -lah /'
sh 'ls -lah /home'
sh 'ls -lah /home/safeci'
sh 'ls -lah /home/safeci/code'
                    sh '/home/safeci/code/cucumber-test.sh'
                }
            }

        }

    }

}

pipeline
{
            agent
            {
                kubernetes
                {
                    defaultContainer 'kaniko'
                    yamlFile 'pod-kaniko.yaml'
                }
            }

    stages
    {

        stage('Build Safe Docker Image')
        {

            steps
            {
               /*
                * We checkout the git repository again because we
                * are running in a different pod setup specifically
                * to build and test the software.
                */

                checkout scm
		/*
                sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --destination devops4me/safetty:latest --cleanup'
		*/
                sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --destination 10.1.91.10:5000/devops4me/safetty:latest --cleanup'
            }
        }

    }

}

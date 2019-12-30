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
		/*
                sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --destination devops4me/safetty:latest --cleanup'
                sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --destination 10.1.61.145:5000/devops4me/safedb-2:latest --insecure-registry 10.1.61.145:5000 --insecure --skip-tls-verify'
                sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --destination 10.1.91.10:5000/devops4me/safetty:latest --insecure-registry 10.1.91.10:5000 --insecure --skip-tls-verify'
		*/
		sh 'echo $PWD'
		sh 'ls -lah /'
		sh 'ls -lah /kaniko'
		sh 'ls -lah /kaniko/.config'
		sh 'ls -lah /kaniko/.docker'
		sh 'cat /kaniko/.docker/.dockerconfigjson'
		sh 'cp /kaniko/.docker/.dockerconfigjson /kaniko/.docker/config.json'
		sh 'ls -lah /kaniko/.docker'
                sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --destination devops4me/safetty:latest --cleanup'

            }

        }

    }

}

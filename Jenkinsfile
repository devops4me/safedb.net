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
/*
    stages
    {
*/
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
                sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --destination 10.1.61.145:5000/devops4me/safedb:latest --insecure-registry 10.1.61.145:5000 --insecure --skip-tls-verify'

            }
        }

/*
        stage('Run the Cucumber Tests')
        {
            agent {
                docker { image 'registry/devops4me/safedb:latest' }
            }
            steps {
                sh 'cucumber-test.sh'
            }
        }
*/

/*
    }
*/
    agent
    {
        kubernetes
        {
            defaultContainer 'kaniko'
            yamlFile 'kaniko.yaml'
        }
    }

/*
    stages
    {
*/
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
                sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --destination 10.1.61.145:5000/devops4me/safedb-2:latest --insecure-registry 10.1.61.145:5000 --insecure --skip-tls-verify'

            }
        }

/*
        stage('Run the Cucumber Tests')
        {
            agent {
                docker { image 'registry/devops4me/safedb:latest' }
            }
            steps {
                sh 'cucumber-test.sh'
            }
        }
*/

/*
    }
*/

}

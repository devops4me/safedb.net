pipeline {
    stages {
        stage('Buildo Roboto') {
            agent { 
                kubernetes {
                    defaultContainer 'kaniko'
                    yamlFile 'kaniko.yaml'
                }
            }
            steps {
                /*
                 * Since we're in a different pod than the rest of the
                 * stages, we'll need to grab our source tree since we don't
                 * have a shared workspace with the other pod(s)..
                 */
                checkout scm
                sh 'sh -c ./scripts/build-kaniko.sh'
            }
        }
    }
}

pipeline
{
    agent none
    stages
    {
/*
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
                checkout scm
                sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --destination devops4me/safetty:latest --cleanup'
            }
        }
        stage('Reek Static Code Analysis')
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
                container('safettytests')
                {
                    sh 'reek lib || true'
                }
            }
        }
        stage('Cucumber Aruba Tests')
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
                container('safettytests')
                {
                    sh 'export SAFE_TTY_TOKEN=$(safe token) ; cucumber lib'
                    sh 'git status'
                }
            }
        }
*/
        stage('Release to RubyGems.org')
        {
            agent
            {
                kubernetes
                {
                    yamlFile 'pod-image-release.yaml'
                }
            }
            when {  environment name: 'GIT_BRANCH', value: 'origin/master' }
            steps
            {
                container('safedeploy')
                {
                    sh 'safe version'
                    sh 'gem bump minor --tag --push --release --file=$PWD/lib/version.rb'
                    sh 'safe version'
                }
            }
        }
    }
}

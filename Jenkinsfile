pipeline
{
    agent none
    stages
    {
/*
        stage('Maybe Skip Build')
        {
            agent any
            steps
            {
                scmSkip(deleteBuild: false, skipPattern:'.*\\[skip ci\\].*')
            }

        }
*/
/*
        stage('Build Safe Docker Image')
        {
            agent
            {
                kubernetes
                {
                    defaultContainer 'kaniko'
                    yamlFile 'pod-image-build.yaml'
                }
            }
            steps
            {
                checkout scm
                sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --destination devops4me/haven:latest --cleanup'
            }
        }
*/
/*
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
*/
        stage('Cucumber Aruba Tests')
        {
            agent
            {
                kubernetes
                {
                    yamlFile 'pod-image-test.yaml'
                }
            }
            steps
            {
                container('safehaven')
                {
                    checkout scm
                    sh 'rake install'
                    sh 'export SAFE_TTY_TOKEN=$(safe token) ; cucumber lib'
                }
            }
        }
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
                container('safehaven')
                {
                    checkout scm
                    sh 'git status'
                    sh 'git remote -v'
                    sh 'pwd'
                    sh 'ls -lah'
                    sh 'ls -lah $HOME/gitsshconfig'
                    sh 'ls -lah $HOME/gitsshkey'
                    sh 'cat $HOME/gitsshconfig/config'
                    sh 'mkdir -p $HOME/.ssh && cp $HOME/gitsshconfig/config $HOME/.ssh/config'
                    sh 'git config --global user.email apolloakora@gmail.com'
                    sh 'git config --global user.name "Apollo Akora"'
                    sh 'ssh -i $HOME/gitsshkey/safedb.code.private.key.pem -vT git@safedb.code || true'
                    sh 'git remote set-url --push origin git@safedb.code:devops4me/safedb.net.git'
                    sh 'git branch && git checkout master'
                    sh 'gem bump minor --skip-ci --tag --push --release --branch --file=$PWD/lib/version.rb'
                }
            }
        }
    }
}

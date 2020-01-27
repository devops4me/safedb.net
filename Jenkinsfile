pipeline
{
    agent none
    stages
    {
        stage('Reek Static Code Analysis')
        {
            agent
            {
                kubernetes
                {
                    yamlFile 'pod-image-validate.yaml'
                }
            }
            steps
            {
                container('safehaven')
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
                    yamlFile 'pod-image-validate.yaml'
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
            when { not { environment name: 'GIT_BRANCH', value: 'origin/master' } }
            steps
            {
                container('safehaven')
                {
                    checkout scm
                    sh 'mkdir -p $HOME/.gem && cp $HOME/gemcredentials/credentials $HOME/.gem/credentials'
                    sh 'chmod 0600 $HOME/.gem/credentials'
/*
                    sh 'mkdir -p $HOME/.ssh && cp $HOME/gitsshconfig/config $HOME/.ssh/config'
                    sh 'git config --global user.email apolloakora@gmail.com'
                    sh 'git config --global user.name "Apollo Akora"'
                    sh 'ssh -i $HOME/gitsshkey/safedb.code.private.key.pem -vT git@safedb.code || true'
                    sh 'git remote set-url --push origin git@safedb.code:devops4me/safedb.net.git'
                    sh 'git branch && git checkout master'
                    sh 'gem bump minor --release --file=$PWD/lib/version.rb'
*/
                    sh 'rake release'
                }
            }
        }
    }
}

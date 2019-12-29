
pipeline
{
    agent any

    stages
    {
        stage( 'Safe Cucumber Unit Tests' )
        {
            agent { dockerfile true }
            steps
            {
                sh 'cucumber-test.sh'
            }
        }
    }
}

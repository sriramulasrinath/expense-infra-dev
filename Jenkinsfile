pipeline{
    agent {
        label 'AGENT-1'
    }
    options{
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }
    stages{
        stage("init"){
            steps{
                sh """
                ls -ltr
                """
            }
        }
        stage("plan"){
            steps{
                sh 'echo this is plan'
            }
        }
        stage("Deploy"){
            steps{
                sh 'echo this is deploy'
            }
        }
    }
    post { 
        always { 
            echo 'I will always say Hello again!'
        }
        success { 
            echo 'I will when pipeline is success!'
        }
        failure { 
            echo 'I will when pipeline is failure!'
        }
    }
}
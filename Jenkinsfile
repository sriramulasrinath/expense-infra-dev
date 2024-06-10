pipeline{
    agent {
        label 'AGENT-1'
    }
    options{
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
        ansiColor('xterm')
    }
    stages{
        stage("init"){
            steps{
                sh """
                cd 01-VPC
                terraform init -reconfigure
                """
            }
        }
        stage("plan"){
            steps{
                sh """
                cd 01-VPC
                terraform plan
                """
            }
        }
        stage("Deploy"){
            input {
                message "Should we continue?"
                ok "Yes, we should."
            }
            steps{
                sh """
                cd 01-VPC
                terraform apply -auto-approve
                """
            }
        }
    }
    post { 
        always { 
            echo 'I will always say Hello again!'
            deleteDir()
        }
        success { 
            echo 'I will when pipeline is success!'
        }
        failure { 
            echo 'I will when pipeline is failure!'
        }
    }
}
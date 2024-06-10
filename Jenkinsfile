pipeline{
    agent {
        label 'AGENT-1'
    }
    options{
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
        ansiColor('xterm')
    }
    parameters {
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Pick something')
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
            when{
                expression{
                    params.action == "apply"
                }
            }
            steps{
                sh """
                cd 01-VPC
                terraform plan
                """
            }
        }
        stage("Deploy"){
            when{
                expression{
                    params.action == "apply"
                }
            }
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
        stage("destroy"){
            when{
                expression{
                    params.action == "destroy"
                }
            }
            steps{
                sh """
                cd 01-VPC
                terraform destroy -auto-approve
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
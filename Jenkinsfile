pipeline {

    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/build-withatul/terraform-jenkins-cicd.git'
            }
        }

        stage('AWS Authentication') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'sweety']
                ]) {
                    sh '''
                        aws sts get-caller-identity
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'sweety']
                ]) {
                    sh '''
                        terraform init -migrate-state -input=false
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                sh '''
                    terraform fmt -check
                    terraform validate
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'sweety']
                ]) {
                    sh '''
                        terraform plan -input=false
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'sweety']
                ]) {
                    sh '''
                        terraform apply -auto-approve -input=false
                    '''
                }
            }
        }

        stage('Terraform Output') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'sweety']
                ]) {
                    sh '''
                        terraform output
                    '''
                }
            }
        }
    }
}

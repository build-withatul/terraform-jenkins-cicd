pipeline {

    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        TF_IN_AUTOMATION   = 'true'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Version') {
            steps {
                sh '''
                    terraform version
                '''
            }
        }

        stage('Terraform Format Check') {
            steps {
                sh '''
                    terraform fmt -check -recursive
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'sweety']
                ]) {
                    sh '''
                        echo "yes" | terraform init -migrate-state
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                sh '''
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
                        terraform plan \
                          -input=false \
                          -out=tfplan
                    '''
                }
            }
        }

        stage('Archive Terraform Plan') {
            steps {
                archiveArtifacts artifacts: 'tfplan',
                                 fingerprint: true
            }
        }

        stage('Manual Approval') {
            steps {
                input(
                    message: 'Do you approve the Terraform deployment?',
                    ok: 'Approve & Apply'
                )
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'sweety']
                ]) {
                    sh '''
                        terraform apply \
                          -input=false \
                          -auto-approve \
                          tfplan
                    '''
                }
            }
        }
         
        stage('Terraform Output') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-credentials']
                ]) {
                    sh '''
                        terraform output
                    '''
                   }
            }
        }

    post {

        success {
            echo 'Terraform deployment completed successfully.'
        }

        failure {
            echo 'Terraform CI/CD pipeline failed.'
        }

        always {
            echo 'Terraform pipeline execution finished.'
        }
    }
}

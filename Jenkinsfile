pipeline {

    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'stage', 'prod'],
            description: 'Terraform environment'
        )

        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: false,
            description: 'Skip approval for controlled testing'
        )
    }

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
                sh 'terraform version'
            }
        }

        stage('Terraform Format') {
            steps {
                sh 'terraform fmt -check -recursive'
            }
        }

        stage('Checkov Security Scan') {
            steps {
                sh '''
                    echo "Running Checkov Terraform security scan..."
                    /var/lib/jenkins/checkov-venv/bin/checkov \
                      -d . \
                      --framework terraform \
                      --quiet
                '''
            }
        }

        stage('Trivy') {
            steps {
                sh '''
                    trivy config \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      .
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding',
                         credentialsId: 'terraform-aws']
                    ]) {
                        sh 'terraform init -input=false'
                    }
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding',
                         credentialsId: 'terraform-aws']
                    ]) {
                        sh '''
                            terraform plan \
                              -input=false \
                              -out=tfplan
                        '''
                    }
                }
            }
        }

        stage('Archive Plan') {
            steps {
                archiveArtifacts(
                    artifacts: "environments/${params.ENVIRONMENT}/tfplan",
                    fingerprint: true
                )
            }
        }

        stage('Approval') {
            when {
                expression {
                    return !params.AUTO_APPROVE
                }
            }

            steps {
                script {

                    if (params.ENVIRONMENT == 'prod') {

                        input(
                            message: 'FINAL APPROVAL: Deploy to PRODUCTION?',
                            ok: 'Deploy Production'
                        )

                    } else {

                        input(
                            message: "Approve deployment to ${params.ENVIRONMENT}?",
                            ok: "Deploy ${params.ENVIRONMENT}"
                        )
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding',
                         credentialsId: 'terraform-aws']
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
        }

        stage('Terraform Output') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform output'
                }
            }
        }
    }

    post {

        success {
            echo "Terraform deployment successful."
        }

        failure {
            echo "Terraform deployment FAILED."
        }

        always {
            echo "Terraform pipeline completed."
        }
    }
}

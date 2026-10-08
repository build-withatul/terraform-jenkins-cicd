pipeline {

    agent any

    options {
        disableConcurrentBuilds()

        timestamps()

        timeout(
            time: 45,
            unit: 'MINUTES'
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
                sh '''
                    terraform version
                '''
            }
        }

        stage('Terraform Format') {
            steps {
                sh '''
                    terraform fmt -check -recursive
                '''
            }
        }

        stage('DEV - Init') {
            steps {
                dir('environments/dev') {
                    sh '''
                        terraform init -reconfigure
                    '''
                }
            }
        }

        stage('DEV - Validate') {
            steps {
                dir('environments/dev') {
                    sh '''
                        terraform validate
                    '''
                }
            }
        }

        stage('DEV - Security Scan') {
            steps {
                dir('environments/dev') {
                    sh '''
                        checkov \
                          -d . \
                          --framework terraform \
                          --quiet

                        trivy config \
                          --severity HIGH,CRITICAL \
                          --exit-code 1 \
                          .
                    '''
                }
            }
        }

        stage('DEV - Plan') {
            steps {
                dir('environments/dev') {
                    sh '''
                        terraform plan \
                          -input=false \
                          -var-file=terraform.tfvars \
                          -out=tfplan
                    '''
                }
            }
        }

        stage('DEV - Approval') {
            steps {
                input(
                    message: 'Approve DEV deployment?',
                    ok: 'Deploy DEV'
                )
            }
        }

        stage('DEV - Apply') {
            steps {
                dir('environments/dev') {
                    sh '''
                        terraform apply \
                          -input=false \
                          -auto-approve \
                          tfplan
                    '''
                }
            }
        }

        stage('STAGE - Init') {
            steps {
                dir('environments/stage') {
                    sh '''
                        terraform init -reconfigure
                    '''
                }
            }
        }

        stage('STAGE - Plan') {
            steps {
                dir('environments/stage') {
                    sh '''
                        terraform plan \
                          -input=false \
                          -var-file=terraform.tfvars \
                          -out=tfplan
                    '''
                }
            }
        }

        stage('STAGE - Approval') {
            steps {
                input(
                    message: 'Approve STAGE deployment?',
                    ok: 'Deploy STAGE'
                )
            }
        }

        stage('STAGE - Apply') {
            steps {
                dir('environments/stage') {
                    sh '''
                        terraform apply \
                          -input=false \
                          -auto-approve \
                          tfplan
                    '''
                }
            }
        }

        stage('PROD - Init') {
            steps {
                dir('environments/prod') {
                    sh '''
                        terraform init -reconfigure
                    '''
                }
            }
        }

        stage('PROD - Plan') {
            steps {
                dir('environments/prod') {
                    sh '''
                        terraform plan \
                          -input=false \
                          -var-file=terraform.tfvars \
                          -out=tfplan
                    '''
                }
            }
        }

        stage('PROD - Final Approval') {
            steps {
                input(
                    message: 'FINAL APPROVAL: Deploy to PRODUCTION?',
                    ok: 'Deploy PRODUCTION'
                )
            }
        }

        stage('PROD - Apply') {
            steps {
                dir('environments/prod') {
                    sh '''
                        terraform apply \
                          -input=false \
                          -auto-approve \
                          tfplan
                    '''
                }
            }
        }

        stage('Terraform Outputs') {
            steps {
                dir('environments/prod') {
                    sh '''
                        terraform output
                    '''
                }
            }
        }
    }

    post {

        success {
            echo 'DEV → STAGE → PROD deployment completed successfully.'
        }

        failure {
            echo 'Terraform promotion pipeline failed.'
        }

        always {
            echo 'Terraform enterprise pipeline finished.'
        }
    }
}

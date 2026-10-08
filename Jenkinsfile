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

        stage('Terraform Format') {
            steps {
                sh '''
                    terraform fmt -check -recursive
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                dir('environments/dev') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding',
                         credentialsId: 'sweety']
                    ]) {
                        sh '''
                            terraform init -input=false
                        '''
                       }
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('environments/dev') {
                    sh '''
                        terraform validate
                    '''
                }
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

        stage('Trivy IaC Scan') {
            steps {
                sh '''
                    trivy config \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      .
                ''' 
            }
        }

        stage('DEV - Init') {
            steps {
                dir('environments/dev') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding',
                         credentialsId: 'sweety']
                    ]) {
                        sh 'terraform init -input=false'
                    }
                }
            }
        }

        stage('DEV - Validate') {
            steps {
                dir('environments/dev') {
                    sh 'terraform validate'
                }
            }
        }

        stage('DEV Apply') {
            steps {
                dir('environments/dev') {
                    sh '''
                        echo "Current directory:"
                        pwd

                        echo "Files:"
                        ls -lah

                        echo "Checking plan:"
                        ls -lh dev.tfplan

                        terraform apply -input=false -auto-approve dev.tfplan
                    '''
                }
            }
        }
        stage('STAGE - Deploy') {
            steps {
                input(
                    message: 'Deploy Terraform to STAGE?',
                    ok: 'Deploy STAGE'
                )

                dir('environments/stage') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding',
                         credentialsId: 'sweety']
                    ]) {
                        sh '''
                            terraform init -input=false
                            terraform plan -input=false -out=stage.tfplan
                            terraform apply -input=false -auto-approve stage.tfplan
                        '''
                    }
                }
            }
        }

        stage('PROD - Approval') {
            steps {
                input(
                    message: 'FINAL APPROVAL: Deploy Terraform to PRODUCTION?',
                    ok: 'Deploy PROD'
                )
            }
        }

        stage('PROD - Deploy') {
            steps {
                dir('environments/prod') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding',
                         credentialsId: 'sweety']
                    ]) {
                        sh '''
                            terraform init -input=false
                            terraform plan -input=false -out=prod.tfplan
                            terraform apply -input=false -auto-approve prod.tfplan
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts(
                artifacts: '**/*.tfplan',
                allowEmptyArchive: true,
                fingerprint: true
            )
        }

        success {
            echo 'Terraform pipeline completed successfully.'
        }

        failure {
            echo 'Terraform pipeline failed.'
        }
    } 
}

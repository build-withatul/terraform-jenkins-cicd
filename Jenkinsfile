```groovy
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
                    echo "Running Trivy IaC security scan..."

                    trivy config \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      .
                '''
            }
        }

        // =========================
        // DEV
        // =========================

        stage('DEV - Init') {
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

        stage('DEV - Validate') {
            steps {
                dir('environments/dev') {
                    sh '''
                        terraform validate
                    '''
                }
            }
        }

        stage('DEV - Plan') {
            steps {
                dir('environments/dev') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding',
                         credentialsId: 'sweety']
                    ]) {
                        sh '''
                            echo "Creating DEV Terraform plan..."

                            terraform plan \
                              -input=false \
                              -out=dev.tfplan

                            echo "DEV plan created:"
                            ls -lh dev.tfplan
                        '''
                    }
                }
            }
        }

        stage('DEV - Approval') {
            steps {
                input(
                    message: 'Deploy Terraform to DEV?',
                    ok: 'Deploy DEV'
                )
            }
        }

        stage('DEV - Apply') {
            steps {
                dir('environments/dev') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding',
                         credentialsId: 'sweety']
                    ]) {
                        sh '''
                            echo "Current directory:"
                            pwd

                            echo "DEV plan file:"
                            ls -lh dev.tfplan

                            terraform apply \
                              -input=false \
                              -auto-approve \
                              dev.tfplan
                        '''
                    }
                }
            }
        }

        // =========================
        // STAGE
        // =========================

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
                            echo "Initializing STAGE..."

                            terraform init -input=false

                            echo "Creating STAGE plan..."

                            terraform plan \
                              -input=false \
                              -out=stage.tfplan

                            echo "STAGE plan created:"
                            ls -lh stage.tfplan

                            echo "Applying STAGE..."

                            terraform apply \
                              -input=false \
                              -auto-approve \
                              stage.tfplan
                        '''
                    }
                }
            }
        }

        // =========================
        // PROD APPROVAL
        // =========================

        stage('PROD - Approval') {
            steps {
                input(
                    message: 'FINAL APPROVAL: Deploy Terraform to PRODUCTION?',
                    ok: 'Deploy PROD'
                )
            }
        }

        // =========================
        // PROD
        // =========================

        stage('PROD - Deploy') {
            steps {
                dir('environments/prod') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding',
                         credentialsId: 'sweety']
                    ]) {
                        sh '''
                            echo "Initializing PROD..."

                            terraform init -input=false

                            echo "Creating PROD plan..."

                            terraform plan \
                              -input=false \
                              -out=prod.tfplan

                            echo "PROD plan created:"
                            ls -lh prod.tfplan

                            echo "Applying PROD..."

                            terraform apply \
                              -input=false \
                              -auto-approve \
                              prod.tfplan
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
```

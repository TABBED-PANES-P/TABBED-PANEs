pipeline {
    agent { label 'Clean_Code' }

    tools {
        maven 'maven3'
        terraform 'terraform1'
    }

    environment {
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_AUTH_TOKEN = credentials('last')  // SonarQube token as Jenkins credential
        AWS_ACCESS_KEY_ID = credentials('idnum01')  // Jenkins Credentials for AWS Access Key
        AWS_SECRET_ACCESS_KEY = credentials('idnum01')  // Jenkins Credentials for AWS Secret Key
        DB_PASSWORD = credentials('db_password')  // Jenkins Credentials for Database Password
        S3_BUCKET_NAME = 'your-s3-bucket-name'  // Set your S3 bucket name or make it dynamic
        AWS_AMI_ID = 'ami-12345678'  // Update with the correct AMI ID
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'https://github.com/TABBED-PANES-P/TABBED-PANEs.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    try {
                        sh '''
                            terraform init
                        '''
                    } catch (Exception e) {
                        echo "Terraform Init failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        throw e  // Re-throw the exception after logging it
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    try {
                        sh """
                            terraform plan -out=tfplan \
                            -var="db_password=${DB_PASSWORD}" \
                            -var="s3_bucket_name=${S3_BUCKET_NAME}" \
                            -var="aws_ami_id=${AWS_AMI_ID}"
                        """
                    } catch (Exception e) {
                        echo "Terraform Plan failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        throw e  // Re-throw the exception after logging it
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: 'Do you approve applying Terraform changes?', ok: 'Yes'
                script {
                    try {
                        sh '''
                            terraform apply -auto-approve tfplan \
                            -var="db_password=${DB_PASSWORD}" \
                            -var="instance_type=${INSTANCE_TYPE}" \
                            -var="db_username=${DB_USERNAME}" \
                            -var="s3_bucket_name=${S3_BUCKET_NAME}" \
                            -var="aws_ami_id=${AWS_AMI_ID}"
                        '''
                    } catch (Exception e) {
                        echo "Terraform Apply failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        throw e  // Re-throw the exception after logging it
                    }
                }
            }
        }

        stage('Provision RDS') {
            steps {
                input message: 'Do you approve applying RDS changes?', ok: 'Yes'
                script {
                    try {
                        sh """
                            terraform apply -auto-approve rdsplan \
                            -var="db_password=${DB_PASSWORD}" \
                            -var="s3_bucket_name=${S3_BUCKET_NAME}" \
                            -var="aws_ami_id=${AWS_AMI_ID}"
                        """
                    } catch (Exception e) {
                        echo "Provision RDS failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        throw e  // Re-throw the exception after logging it
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean workspace to remove any temporary files
            cleanWs()
        }
    }
}

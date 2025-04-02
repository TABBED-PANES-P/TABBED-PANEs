pipeline {
    agent { label 'Clean_Code' }

    tools {
        maven 'maven3'
        terraform 'terraform1'
    }

    environment {
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_AUTH_TOKEN = credentials('last')  // SonarQube token as Jenkins credential
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')  // Jenkins Credentials for AWS Access Key
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')  // Jenkins Credentials for AWS Secret Key
        DB_PASSWORD = credentials('db_password_cred')  // Jenkins Credentials for Database Password
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

        stage('Code Coverage') {
            steps {
                sh 'mvn verify'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                    mvn sonar:sonar \
                    -Dsonar.projectKey=sample_project222 \
                    -Dsonar.host.url=$SONAR_HOST_URL \
                    -Dsonar.login=$SONAR_AUTH_TOKEN \
                    -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                    """
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    // AWS Credentials are automatically available as environment variables
                    sh '''
                        terraform init
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    // Run Terraform Plan with the provided terraform.tfvars file
                    sh """
                        terraform plan -out=tfplan \
                        -var="db_password=${DB_PASSWORD}" \
                        -var="s3_bucket_name=${S3_BUCKET_NAME}" \
                        -var="aws_ami_id=${AWS_AMI_ID}"
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: 'Do you approve applying Terraform changes?', ok: 'Yes'
                script {
                    // Apply the plan if the input is approved
                    sh """
                        terraform apply -auto-approve tfplan \
                        -var="db_password=${DB_PASSWORD}" \
                        -var="s3_bucket_name=${S3_BUCKET_NAME}" \
                        -var="aws_ami_id=${AWS_AMI_ID}"
                    """
                }
            }
        }

        stage('Provision RDS') {
            steps {
                input message: 'Do you approve applying RDS changes?', ok: 'Yes'
                script {
                    // Apply specific Terraform plan for RDS provisioning
                    sh """
                        terraform apply -auto-approve rdsplan \
                        -var="db_password=${DB_PASSWORD}" \
                        -var="s3_bucket_name=${S3_BUCKET_NAME}" \
                        -var="aws_ami_id=${AWS_AMI_ID}"
                    """
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

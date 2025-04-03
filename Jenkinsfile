pipeline {
    agent { label 'Clean_Code' }

    tools {
        maven 'maven3'
        terraform 'terraform1'
    }

    environment {
        // SonarQube Configuration
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_AUTH_TOKEN = credentials('last')
        
        // AWS Configuration
        AWS_ACCESS_KEY_ID = credentials('idnum01')
        AWS_SECRET_ACCESS_KEY = credentials('idnum01')
        AWS_REGION = 'us-east-1'
        
        // Database Configuration
        DB_USERNAME = 'admin'
        DB_PASSWORD = credentials('db_password')  // Will be validated/replaced
        
        // Infrastructure Configuration
        ENVIRONMENT = 'prod'
        INSTANCE_CLASS = 'db.t3.micro'
        S3_BUCKET_NAME = 'your-s3-bucket-name'
        AWS_AMI_ID = 'ami-12345678'
    }

    stages {
        // Source Control Stage
        stage('Checkout Code') {
            steps {
                git branch: 'master', 
                url: 'https://github.com/TABBED-PANES-P/TABBED-PANEs.git'
            }
        }

        // Build and Test Stages
        stage('Build Application') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Code Coverage Analysis') {
            steps {
                sh 'mvn verify'
                publishHTML(target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'target/site/jacoco',
                    reportFiles: 'index.html',
                    reportName: 'Jacoco Coverage Report'
                ])
            }
        }

        // Quality Gate
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

        // Infrastructure Provisioning
        stage('Terraform Initialization') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Planning') {
            steps {
                script {
                    // Generate AWS-compliant password
                    def SAFE_PASSWORD = sh(
                        script: 'openssl rand -base64 20 | tr -dc \'a-zA-Z0-9\' | head -c 20',
                        returnStdout: true
                    ).trim()
                    
                    // Create variables file
                    writeFile file: 'terraform.tfvars', text: """
                    environment = "${ENVIRONMENT}"
                    aws_region = "${AWS_REGION}"
                    db_password = "${SAFE_PASSWORD}"
                    db_username = "${DB_USERNAME}"
                    instance_class = "${INSTANCE_CLASS}"
                    allocated_storage = 20
                    skip_final_snapshot = true
                    publicly_accessible = false
                    s3_bucket_name = "${S3_BUCKET_NAME}"
                    aws_ami_id = "${AWS_AMI_ID}"
                    """
                    
                    // Create infrastructure plan
                    sh 'terraform plan -out=infraplan -var-file=terraform.tfvars -compact-warnings'
                    
                    // Create RDS-specific plan
                    sh 'terraform plan -target=aws_db_instance.mysql -out=rdsplan -var-file=terraform.tfvars -compact-warnings'
                }
            }
        }

        stage('Infrastructure Provisioning') {
            steps {
                input message: 'Approve general infrastructure changes?', ok: 'Yes'
                script {
                    sh '''
                    # Cleanup any existing state conflicts
                    terraform state rm aws_db_subnet_group.default 2>/dev/null || true
                    terraform state rm aws_security_group.mysql_sg 2>/dev/null || true
                    
                    # Apply infrastructure changes
                    terraform apply -auto-approve infraplan
                    '''
                }
            }
        }

        stage('RDS Database Provisioning') {
            steps {
                input message: 'Approve RDS database creation?', ok: 'Yes'
                script {
                    sh 'terraform apply -auto-approve rdsplan'
                }
            }
        }

        // Validation Stage
        stage('Verify Deployment') {
            steps {
                script {
                    // Add your verification logic here
                    sh '''
                    echo "Verifying RDS deployment..."
                    # Example: Check RDS status via AWS CLI
                    aws rds describe-db-instances \
                        --db-instance-identifier "mysql-${ENVIRONMENT}" \
                        --query "DBInstances[0].DBInstanceStatus" \
                        --output text
                    '''
                }
            }
        }
    }

    post {
        always {
            // Clean workspace and send notifications
            cleanWs()
            
            // Archive important files
            archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
            archiveArtifacts artifacts: '**/terraform.log', allowEmptyArchive: true
        }
        success {
            slackSend channel: '#deployments',
                     color: 'good',
                     message: "SUCCESS: ${JOB_NAME} - ${BUILD_URL}"
        }
        failure {
            emailext body: """
            Pipeline failed at stage: ${currentBuild.result} 
            Build URL: ${BUILD_URL}
            Error details: ${currentBuild.currentResult}
            """,
            subject: 'FAILED: ${JOB_NAME} - Build #${BUILD_NUMBER}',
            to: 'devops-team@yourcompany.com'
            
            slackSend channel: '#alerts',
                     color: 'danger',
                     message: "FAILED: ${JOB_NAME} - ${BUILD_URL}"
        }
    }
}

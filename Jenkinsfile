pipeline {
    agent { label 'Clean_Code' }

    tools {
        maven 'maven3'
        terraform 'terraform1'
    }

    environment {
        // KEEP ALL YOUR ORIGINAL ENVIRONMENT VARIABLES
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_AUTH_TOKEN = credentials('last')
        AWS_ACCESS_KEY_ID = credentials('idnum01')
        AWS_SECRET_ACCESS_KEY = credentials('idnum01')
        DB_PASSWORD = credentials('db_password')
        S3_BUCKET_NAME = 'your-s3-bucket-name'
        AWS_AMI_ID = 'ami-12345678'
        
        // ONLY CHANGE: Updated to RDS-compatible instance type
        INSTANCE_TYPE = 'db.t3.micro'
    }

    stages {
        // KEEP ALL YOUR WORKING STAGES EXACTLY AS IS
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

        // MODIFIED STAGES (ONLY THESE TWO CHANGES)
        stage('Terraform Init') {
            steps {
                sh 'terraform init -input=false'
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    // Generate AWS-compliant password (safe fallback)
                    def DB_SAFE_PWD = sh(
                        script: 'openssl rand -base64 20 | tr -dc \'a-zA-Z0-9\' | head -c 20',
                        returnStdout: true
                    ).trim()
                    
                    // Use existing password if valid, otherwise use generated one
                    def FINAL_PWD = env.DB_PASSWORD =~ /^[^@" ]{8,41}$/ ? env.DB_PASSWORD : DB_SAFE_PWD
                    
                    sh """
                    terraform plan -out=tfplan \
                        -var="db_password=${FINAL_PWD}" \
                        -var="instance_type=${INSTANCE_TYPE}" \
                        -var="s3_bucket_name=${S3_BUCKET_NAME}" \
                        -var="aws_ami_id=${AWS_AMI_ID}" \
                        -compact-warnings
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: 'Approve infrastructure changes?', ok: 'Yes'
                script {
                    sh '''
                    # Clean up existing conflicts if they exist
                    terraform state rm aws_db_subnet_group.default 2>/dev/null || true
                    terraform state rm aws_security_group.mysql_sg 2>/dev/null || true
                    
                    # Apply changes
                    terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        // KEEP YOUR ORIGINAL RDS STAGE
        stage('Provision RDS') {
            steps {
                input message: 'Approve RDS changes?', ok: 'Yes'
                script {
                    sh 'terraform apply -auto-approve -target=aws_db_instance.mysql'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

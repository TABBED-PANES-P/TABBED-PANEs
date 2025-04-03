pipeline {
    agent { label 'Clean_Code' }

    tools {
        maven 'maven3'
        terraform 'terraform1'
    }

    environment {
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_AUTH_TOKEN = credentials('last')
        AWS_ACCESS_KEY_ID = credentials('idnum01')
        AWS_SECRET_ACCESS_KEY = credentials('idnum01')
        DB_PASSWORD = credentials('db_password')
        S3_BUCKET_NAME = 'your-s3-bucket-name'
        AWS_AMI_ID = 'ami-12345678'
        INSTANCE_TYPE = 'db.t3.micro' // Changed to RDS-compatible type
         UNIQUE_SUFFIX = "${BUILD_ID}"
    }

    stages {
        /* PRESERVE ALL YOUR WORKING STAGES EXACTLY AS YOU HAD THEM */
        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'https://github.com/TABBED-PANES-P/TABBED-PANEs.git'
            }
        }

        stage('Build') { steps { sh 'mvn clean compile' } }
        stage('Test') { steps { sh 'mvn test' } }
        stage('Code Coverage') { steps { sh 'mvn verify' } }
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

        /* FIXED TERRAFORM STAGES (MINIMAL CHANGES) */
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    // Generate guaranteed-valid password
                    def SAFE_PWD = sh(script: 'openssl rand -base64 20 | tr -dc \'a-zA-Z0-9\' | head -c 20', returnStdout: true).trim()
                    
                    writeFile file: 'terraform.tfvars', text: """
                    db_password = "${SAFE_PWD}"
                    instance_type = "${INSTANCE_TYPE}"
                    s3_bucket_name = "${S3_BUCKET_NAME}"
                    aws_ami_id = "${AWS_AMI_ID}"
                    """
                    
                    sh 'terraform plan -out=tfplan -var-file=terraform.tfvars'
                }
            }
        }

        stage('Terraform Apply') {
    steps {
        input message: 'Approve infrastructure changes?', ok: 'Yes'
        script {
            sh '''
            # First import any existing resources to state
            terraform import aws_db_subnet_group.default mysql-db-subnet-group-prod 2>/dev/null || true
            terraform import aws_security_group.mysql_sg $(aws ec2 describe-security-groups \
                --filters Name=group-name,Values=mysql-sg-prod \
                --query "SecurityGroups[0].GroupId" \
                --output text) 2>/dev/null || true
            
            # Then apply changes
            terraform apply -auto-approve -target=aws_db_subnet_group.default -target=aws_security_group.mysql_sg
            terraform apply -auto-approve
            '''
        }
    }
}

        /* PRESERVE YOUR RDS STAGE */
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

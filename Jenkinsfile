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
        INSTANCE_TYPE = 't2.micro'  // Define an instance type for your EC2 or RDS
        DB_USERNAME = 'admin'  // Set a default username for DB
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
                    // Initialize Terraform
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
  steps {
    script {
      // Generate a compliant password if not provided
      def DB_PASSWORD_COMPLIANT = env.DB_PASSWORD ?: 
        sh(script: 'openssl rand -base64 20 | tr -dc \'a-zA-Z0-9\' | head -c 20', returnStdout: true).trim()
      
      writeFile file: 'terraform.tfvars', text: """
      environment = "${ENVIRONMENT}"
      aws_region = "${AWS_REGION}"
      db_password = "${DB_PASSWORD_COMPLIANT}"
      db_username = "${DB_USERNAME}"
      instance_class = "${INSTANCE_CLASS}"
      allocated_storage = 20
      skip_final_snapshot = true
      publicly_accessible = false
      """
      
      sh 'terraform plan -out=tfplan -var-file=terraform.tfvars -compact-warnings'
    }
  }
}

stage('Terraform Apply') {
  steps {
    input message: 'Approve Terraform changes?', ok: 'Yes'
    script {
      sh '''
      # Cleanup any existing state conflicts
      terraform state rm aws_db_subnet_group.default 2>/dev/null || true
      terraform state rm aws_security_group.mysql_sg 2>/dev/null || true
      
      # Apply changes
      terraform apply -auto-approve -compact-warnings tfplan
      '''
    }
  }
}

        stage('Provision RDS') {
            steps {
                input message: 'Do you approve applying RDS changes?', ok: 'Yes'
                script {
                    // Apply specific Terraform plan for RDS provisioning
                    sh """
                    terraform apply -auto-approve rdsplan -var-file=terraform.tfvars
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

pipeline {
    agent { label 'Clean_Code' }

    tools {
        maven 'maven3'
        terraform 'terraform1'
    }

    environment {
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_AUTH_TOKEN = credentials('last')
        // Add default values for Terraform variables
        TF_VAR_region = "us-west-2"
        TF_VAR_instance_type = "t2.micro"
        TF_VAR_db_username = "admin"
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

        stage('Prepare Terraform') {
            steps {
                script {
                    // Create terraform.tfvars if it doesn't exist
                    if (!fileExists('terraform.tfvars')) {
                        writeFile file: 'terraform.tfvars', text: """
                        region        = "${env.TF_VAR_region}"
                        instance_type = "${env.TF_VAR_instance_type}"
                        db_username   = "${env.TF_VAR_db_username}"
                        """
                    }
                    
                    // For sensitive values, use withCredentials
                    withCredentials([string(credentialsId: 'db_password', variable: 'DB_PASSWORD')]) {
                        sh '''
                        echo "db_password = \"${DB_PASSWORD}\"" >> terraform.tfvars
                        '''
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'idnum01']]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        terraform init
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'idnum01']]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        terraform plan -out=tfplan -var-file=terraform.tfvars
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'idnum01']]) {
                    input message: 'Do you approve applying Terraform changes?', ok: 'Yes'
                    sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        terraform apply -auto-approve tfplan
                    '''
                }
            }
        }
    }
}

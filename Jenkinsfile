pipeline {
    agent { label 'Clean_Code' }

    tools {
        maven 'maven3'
        terraform 'terraform1'
    }

    environment {
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_AUTH_TOKEN = credentials('last')  // SonarQube token as Jenkins credential
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
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'idnum01']]) {
                    script {
                        // AWS Credentials will be available automatically as environment variables
                        sh '''
                            terraform init
                        '''
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'idnum01']]) {
                    script {
                        // Run Terraform Plan with the provided terraform.tfvars file
                        sh '''
                            terraform plan -out=tfplan -var-file=terraform.tfvars
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'idnum01']]) {
                    input message: 'Do you approve applying Terraform changes?', ok: 'Yes'
                    script {
                        // Apply the plan if the input is approved
                        sh '''
                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }

        stage('Provision RDS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'idnum01']]) {
                    input message: 'Do you approve applying RDS changes?', ok: 'Yes'
                    script {
                        // Apply specific Terraform plan for RDS provisioning
                        sh '''
                            terraform apply -auto-approve rdsplan
                        '''
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

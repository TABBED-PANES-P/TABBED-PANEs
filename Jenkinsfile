pipeline {
    agent any
    tools {
        maven 'maven3'  // Ensure Maven is correctly configured
    }

    environment {
        SONAR_HOST_URL = 'http://localhost:9000'  // Update to your SonarQube server URL
        SONAR_AUTH_TOKEN = credentials('sidow')  // Ensure the correct credentials ID is used
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "Checking out code from GitHub repository..."
                git branch: 'master', url: 'https://github.com/TABBED-PANES-P/TABBED-PANEs.git'
            }
        }

        stage('Build') {
            steps {
                echo "Building the project with Maven..."
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                echo "Running tests with Maven..."
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo "Starting SonarQube analysis..."
                script {
                    // Debugging SonarQube configuration
                    echo "SONAR_HOST_URL: $SONAR_HOST_URL"
                    echo "SONAR_AUTH_TOKEN: $SONAR_AUTH_TOKEN"
                    echo "Running Maven SonarQube analysis..."
                }
                sh """
                mvn sonar:sonar \
                -Dsonar.projectKey=sample_project \
                -Dsonar.host.url=$SONAR_HOST_URL \
                -Dsonar.login=$SONAR_AUTH_TOKEN
                """
            }
        }
    }
}

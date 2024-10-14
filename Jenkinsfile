pipeline {
    agent any
    environment {
        DOCKER_COMPOSE_PATH = '.docker/docker-compose.yml'
    }
    stages {
        stage('Build Docker Images') {
            steps {
                // Execute the 'build' target in your Makefile
                sh 'make build'
            }
        }
        stage('Start Services') {
            steps {
                // Execute the 'up' target in your Makefile
                sh 'make up'
            }
        }
        stage('Run Database Migrations') {
            steps {
                // Execute the 'migrate' target in your Makefile
                sh 'make migrate'
            }
        }
    }
    post {
        always {
            // Ensure services are stopped even if there's an error
            sh 'make down'
        }
    }
}

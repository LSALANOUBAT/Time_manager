pipeline {
    agent any
    environment {
        DOCKER_COMPOSE_PATH = '.docker/docker-compose.yml'
    }
    stages {
        stage('Build Docker Images') {
            steps {
                sh 'make build'
            }
        }
        stage('Start Services') {
            steps {
                sh 'make up'
            }
        }
        stage('Run Database Migrations') {
            steps {
                sh 'make migrate'
            }
        }
    }
    post {
        // No actions needed in 'always' block since services remain running
    }
}

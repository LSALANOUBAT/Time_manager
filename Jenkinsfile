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
        stage('Prune Docker') {
            steps {
                sh 'make down'
                sh '''
                    docker system prune -af
                    docker volume prune -f
                    docker builder prune -af
                '''
            }
        }
    }
}

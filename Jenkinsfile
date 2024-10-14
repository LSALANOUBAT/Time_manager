pipeline {
    agent any
    environment {
        DOCKER_COMPOSE_PATH = '.docker/docker-compose.yml'
    }
    stages {
        stage('Start Services') {
            steps {
                sh 'make up'
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

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
    }
    post {
        always {
            sh 'make down'
        }
    }
}

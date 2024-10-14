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
            // Clean up services
            sh 'make down'
            // Optionally, you can add Docker cache cleanup here
            sh '''
                docker system prune -af
                docker volume prune -f
                docker builder prune -af
            '''
        }
    }
}

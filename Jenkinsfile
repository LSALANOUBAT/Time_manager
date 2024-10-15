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
        // stage('migration') {
        //     steps {
        //         sh 'make migrate'
        //     }
        // } 
    }
    post {
        always {
            sh 'make down'
        }
    }
}

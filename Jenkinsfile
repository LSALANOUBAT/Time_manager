pipeline {
    agent any
    environment {
        DOCKER_COMPOSE_PATH = '.docker/docker-compose.prod.yml'
    }
    stages {
        stage('Stop Existing Services') {
            steps {
                sh 'make down' // This will stop any running services before starting the new build
            }
        }
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
    // post {
    //     always {
    //         sh 'make down'
    //     }
    // }
}

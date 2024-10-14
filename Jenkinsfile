pipeline {
    agent any
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
        always {
            steps {
                // Clean up services
                sh 'make down'
                
                // Clean up Docker cache
                sh '''
                   docker system prune -af
                   docker volume prune -f
                   docker builder prune -af
                '''
            }
        }
    }
}

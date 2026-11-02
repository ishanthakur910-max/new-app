
pipeline {
    agent any

    options {
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate Docker Compose') {
            steps {
                sh 'docker compose config -q'
            }
        }

        stage('Build Docker Images') {
            steps {
                sh 'docker compose build'
            }
        }

        stage('Deploy Application') {
            steps {
                sh 'docker compose up -d --remove-orphans'
            }
        }

        stage('Verify Containers') {
            steps {
                sh 'docker compose ps'
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    for i in $(seq 1 12); do
                        if curl -fsS http://localhost/ > /dev/null; then
                            echo "TaskFlow is running successfully!"
                            exit 0
                        fi
                        echo "Waiting for application..."
                        sleep 5
                    done

                    echo "Application health check failed!"
                    docker compose logs --tail=50
                    exit 1
                '''
            }
        }
    }

    post {
        success {
            echo 'TaskFlow deployment completed successfully!'
        }

        failure {
            echo 'TaskFlow pipeline failed. Check the console output.'
        }
    }
}

pipeline {
  agent any
  environment {
    APP_HOST = 'YOUR_APP_EC2_PUBLIC_IP'
    APP_USER = 'ubuntu'
    APP_DIR = '/opt/taskflow'
    SSH_CREDENTIALS_ID = 'taskflow-deploy-key'
  }
  options { timestamps(); disableConcurrentBuilds() }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Validate Compose') { steps { sh 'docker compose config -q' } }
    stage('Build Images') { steps { sh 'docker compose build' } }
    stage('Deploy') {
      steps {
        sshagent(credentials: [SSH_CREDENTIALS_ID]) {
          sh '''
            ssh -o StrictHostKeyChecking=accept-new ${APP_USER}@${APP_HOST} "sudo mkdir -p ${APP_DIR} && sudo chown ${APP_USER}:${APP_USER} ${APP_DIR}"
            rsync -az --delete --exclude='.git' --exclude='.env' -e "ssh -o StrictHostKeyChecking=accept-new" ./ ${APP_USER}@${APP_HOST}:${APP_DIR}/
            ssh -o StrictHostKeyChecking=accept-new ${APP_USER}@${APP_HOST} "cd ${APP_DIR} && docker compose up -d --build"
          '''
        }
      }
    }
    stage('Health Check') {
      steps { sh 'sleep 8; curl --fail --retry 5 --retry-delay 3 http://${APP_HOST}/api/health' }
    }
  }
  post { always { echo 'TaskFlow pipeline finished.' } }
}

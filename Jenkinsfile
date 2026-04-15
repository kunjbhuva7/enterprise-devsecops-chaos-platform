pipeline {
    agent any

    environment {
        IMAGE_NAME = "kunj22/chaos-devsecops"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_USER = "kunj22"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                python3 -m venv venv
                . venv/bin/activate
                pip install --upgrade pip
                pip install -r app/requirements.txt
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                . venv/bin/activate
                export PYTHONPATH=$WORKSPACE
                pytest tests/
                '''
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh '''
                trivy fs .
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $IMAGE_NAME:$IMAGE_TAG -f docker/Dockerfile .
                '''
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )]) {
                    sh '''
                    echo $PASSWORD | docker login -u $USERNAME --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                docker push $IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                sed "s|IMAGE_TAG|$IMAGE_NAME:$IMAGE_TAG|g" k8s/deployment.yaml | kubectl apply --validate=false -f -
                kubectl apply --validate=false -f k8s/service.yaml
                '''
            }
        }

        stage('Chaos Test') {
            steps {
                sh '''
                chmod +x chaos/pod-delete.sh
                bash chaos/pod-delete.sh
                '''
            }
        }
    }

    post {
        success {
            echo "🚀 DevSecOps Pipeline completed successfully!"
        }

        failure {
            echo "❌ Pipeline failed. Check logs."
        }

        always {
            echo "Pipeline execution finished."
        }
    }
}
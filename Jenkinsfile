pipeline {
    agent any

    environment {
        IMAGE_NAME = "mujtaba110/devproject:latest"
        AWS_REGION = "eu-north-1"
        CLUSTER_NAME = "devproject-cluster"

    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    echo "🔨 Building Docker image..."
                    docker.build("${IMAGE_NAME}", ".")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "📤 Pushing image to Docker Hub..."
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-token', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker push ${IMAGE_NAME}
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    script {
                        echo "🚀 Deploying to Kubernetes..."
                        sh '''
                            aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}
                            kubectl apply -f ./k8s/
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline executed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs for details."
        }
    }
}

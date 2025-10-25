pipeline{
    agent any

    stages{
        stage('Build'){
            steps{
                script{
                    docker.build("mujtaba110/devproject:latest", ".")
                }
            }
        }
        stage('Push to Docker Hub'){
            steps{
                withCredentials([usernamePassword(credentialsId: 'docker-hub-token', usernameVariable: 'Docker_Token',passwordVariable:'DOCKER_PASS' )]){
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push mujtaba110/devproject:latest
                    """
                }
            }
        }
        stage('Deploy to kubernetes'){
            steps{
                sh 'kubectl apply -f ./k8s/'
            }
        }
    }
}
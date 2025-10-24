pipeline{
    agent any

    stages{
        stage('Checkout'){
            steps{
                git 'https://github.com/alimujtaba123/devproject.git'
            }
        }
        stage('Build'){
            steps{
                script{
                    docker.build("mujtaba110/devproject:latest", "./docker")
                }
            }
        }
        stage('Push to Docker Hub'){
            steps{
                withCredentials([string(credentialsId: 'docker-hub-token', variable: 'Docker_Token' )]){
                    sh 'echo $DOCKER_TOKEN | docker login -u mujtaba110 --password-stdin'
                    sh 'docker push mujtaba110/devproject:latest'
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
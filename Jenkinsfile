pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'jimmba/flask-app'
        IMAGE_TAG = 'latest'
        APP_PATH = './task5-application/app'
        CHART_PATH = './task5-application/flask-app-chart' //! check path
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // stage('Build Docker Image') {
        //     steps {
        //         script {
        //             sh "docker build -t $DOCKER_IMAGE:$IMAGE_TAG $APP_PATH"
        //         }
        //     }
        // }

        // stage('Push Docker Image') {
        //     steps {
        //         withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
        //             sh '''
        //                 echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
        //                 docker push $DOCKER_IMAGE:$IMAGE_TAG
        //             '''
        //         }
        //     }
        // }

        stage('Deploy to Kubernetes via Helm') {
            steps {
                sh """
                    helm upgrade --install flask-app $CHART_PATH \
                    --namespace flask-app --create-namespace \
                    --kubeconfig /home/ubuntu/config \
                    --set image.repository=$DOCKER_IMAGE \
                    --set image.tag=$IMAGE_TAG
                """
            }
        }
    }

    post {
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Deployment failed."
        }
    }
}

pipeline {
  agent {
    kubernetes {
      label 'default'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  containers:
    - name: jnlp
      image: jenkins/inbound-agent:latest
      args: ['\$(JENKINS_SECRET)', '\$(JENKINS_NAME)']
    - name: tools
      image: jimmba/jenkins-agent:latest
      command:
        - cat
      tty: true
      volumeMounts:
        - name: docker-socket
          mountPath: /var/run/docker.sock
  volumes:
    - name: docker-socket
      hostPath:
        path: /var/run/docker.sock
  restartPolicy: Never
"""
    }
  }

  environment {
    DOCKER_IMAGE = 'jimmba/flask-app'
    IMAGE_TAG = 'latest'
    APP_PATH = './task5-application/app'
    CHART_PATH = './task5-application/flask-app-chart'
    SONAR_PROJECT_KEY = 'Jimmba_rsschool-devops-course-tasks'
    SONAR_ORGANIZATION = 'jimmba'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Run Unit Tests') {
      steps {
        container('tools') {
          sh """
            pip install -r $APP_PATH/requirements.txt
            pytest $APP_PATH
          """
        }
      }
    }

    stage('SonarCloud Analysis') {
      steps {
        container('tools') {
          withCredentials([
            string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN'),
          ]) {
            sh """
              sonar-scanner \
                -Dsonar.projectKey=${env.SONAR_PROJECT_KEY} \
                -Dsonar.organization=${env.SONAR_ORGANIZATION} \
                -Dsonar.sources=$APP_PATH \
                -Dsonar.login=$SONAR_TOKEN \
                -Dsonar.host.url=https://sonarcloud.io
            """
          }
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        container('tools') {
          sh "docker build -t $DOCKER_IMAGE:$IMAGE_TAG $APP_PATH"
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        container('tools') {
          withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh '''
              echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
              docker push $DOCKER_IMAGE:$IMAGE_TAG
            '''
          }
        }
      }
    }

    stage('Deploy to Kubernetes via Helm') {
      steps {
        container('tools') {
          sh """
            helm upgrade --install flask-app $CHART_PATH \
            --namespace flask-app --create-namespace \
            --set image.repository=$DOCKER_IMAGE \
            --set image.tag=$IMAGE_TAG
          """
        }
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

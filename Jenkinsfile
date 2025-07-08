pipeline {
    agent {
        docker {
            image 'maven:3.9.6-eclipse-temurin-17-alpine'
            args '-v /root/.m2:/root/.m2'
        }
    }

    environment {
        DOCKER_IMAGE = "iamdhikka/spring-boot-unit-test-rest-controller:${BUILD_NUMBER}"
        DOCKER_HUB_CREDENTIALS = "dockerhub-credentials"
        TELEGRAM_BOT_TOKEN = credentials('telegram-bot-token')
        TELEGRAM_CHAT_ID = credentials('telegram-chat-id')
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'master', url: 'https://github.com/iamdhikka/spring-boot-unit-test-rest-controller.git'
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_IMAGE}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry([credentialsId: "${DOCKER_HUB_CREDENTIALS}", url: '']) {
                    script {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Deploy to Cloud Run via Terraform') {
            steps {
                dir('terraform') {
                    sh '''
                        terraform init
                        terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Notify via Telegram') {
            steps {
                sh '''
                    curl -s -X POST https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage \
                    -d chat_id=${TELEGRAM_CHAT_ID} \
                    -d text="✅ Build #${BUILD_NUMBER} berhasil! Aplikasi sudah dideploy ke Cloud Run."
                '''
            }
        }
    }

    post {
        failure {
            sh '''
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage \
                -d chat_id=${TELEGRAM_CHAT_ID} \
                -d text="❌ Build #${BUILD_NUMBER} gagal!"
            '''
        }
    }
}

pipeline {
    agent any

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

        stage('Debug Workspace') {
            steps {
                sh 'ls -la'
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh '''
                    chmod +x mvnw
                    ./mvnw test
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        chmod +x mvnw
                        ./mvnw sonar:sonar
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', "${DOCKER_HUB_CREDENTIALS}") {
                        def image = docker.image("${DOCKER_IMAGE}")
                        image.push()
                    }
                }
            }
        }

        stage('Deploy to Cloud Run via Terraform') {
            steps {
                withCredentials([file(credentialsId: 'gcp-sa-json', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    dir('terraform') {
                        sh '''
                            terraform --version
                            terraform init
                            terraform apply -auto-approve
                        '''
                    }
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

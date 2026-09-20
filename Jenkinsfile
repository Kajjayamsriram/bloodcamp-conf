pipeline {
    agent all
    tools { scannerHome = "mysonar"}
    environment{
        AWS_REGION = 'us-east-1'
        ECR_URI = "${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
        ECR_APP_REPO = "blood-app"
        ECR_DB_REPO = "blood-db"
        IMAGE_TAG  = "${BUILD_NUMBER}"
        //pass using parameters => ACCOUNT_ID
    }
    stages {
        stage("cleanWs"){
            steps{
                cleanWs()
            }
        }
        stage ("checkout") {
            steps{
                git "https://github.com/Kajjayamsriram/bloodbank_terraform.git"
            }
        }
        stage("CQA") {
            steps{
                withSonarQubeEnv("sonar-server"){
                    sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=bank"
                }
            }
        }
        stage("QG") {
            steps{
                waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
            }
        }
        stage ("buildImage"){
            steps{
                sh "docker build -t ${ECR_URI}/${ECR_APP_REPO}:${IMAGE_TAG} ."
                sh "docker build -t ${ECR_URI}/${ECR_DB_REPO}:${IMAGE_TAG} database"

            }
        }
        stage ("Image scan"){
            steps{
                 sh "trivy image --severity CRITICAL --exit-code 0 ${ECR_URI}/${ECR_APP_REPO}:${IMAGE_TAG}"
                 sh "trivy image --severity CRITICAL --exit-code 0 ${ECR_URI}/${ECR_DB_REPO}:${IMAGE_TAG}"
            }
        }
        stage ("Ecr login"){
            steps{
                sh '''
                aws ecr get-login-password --region $AWS_REGION \
                | docker login --username AWS --password-stdin ${AWS_URI}
                '''
            }
            //added ecr:PutImage policy soon to ec2 instance_profile for push perms
        }
        stage("push to ecr"){
            steps{
                sh "docker push ${ECR_URI}/${ECR_APP_REPO}:${IMAGE_TAG}"
                sh "docker push ${ECR_URI}/${ECR_DB_REPO}:${IMAGE_TAG}"
            }
        }
        stage("update manifests"){
            steps{
                withCredentials([
                    string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')
                ]){
                    sh '''
                    git clone https://github.com/Kajjayamsriram/bloodcamp-conf.git
                    cd bloodcamp-conf/manifests
                    sed -i "s|image:.*|image: ${ECR_URI}/${ECR_APP_REPO}:${IMAGE_TAG}|" deploy.yaml
                    sed -i "s|image:.*|image: ${ECR_URI}/${ECR_DB_REPO}:${IMAGE_TAG}|" stateful.yaml

                    git config user.name "jenkins"
                    git config user.email "jenkins@example.com"
                    git add deploy.yaml stateful.yaml

                    git commit -m "updated ecr image ${IMAGE_TAG}" || true
                    git push origin main
                    '''
                }
            }
        }
    }
    post{
        always{
            sh "docker logout ${ECR_URI} || true"
        }
    }
}
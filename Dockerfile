pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="696686959144"
        AWS_DEFAULT_REGION="us-east-1" 
        IMAGE_REPO_NAME="jenkins-pipeline-imagepush"
        IMAGE_TAG="latest-ecrimage"
        REPOSITORY_URI = "${696686959144}.dkr.ecr.${us-east-1}.amazonaws.com/${jenkins-pipeline-imagepush}"
    }
   
    stages {
        
         stage('Logging into AWS ECR') {
            steps {
                script {
                sh "aws ecr get-login-password --region ${us-east-1} | docker login --username AWS --password-stdin ${696686959144}.dkr.ecr.${us-east-1}.amazonaws.com"
                }
                 
            }
        }
        
        stage('Cloning Git') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '', url: 'https://github.com/toshallab/jenkins-pipeline-imagepush.git']]])     
            }
        }
  
    // Building Docker images
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build "${jenkins-pipeline-imagepush}:${latest-ecrimage}"
        }
      }
    }
   
    // Uploading Docker images into AWS ECR
    stage('Pushing to ECR') {
     steps{  
         script {
                sh "docker tag ${jenkins-pipeline-imagepush}:${latest-ecrimage} ${REPOSITORY_URI}:$latest-ecrimage"
                sh "docker push ${696686959144}.dkr.ecr.${us-east-1}.amazonaws.com/${jenkins-pipeline-imagepush}:${latest-ecrimage}"
         }
        }
      }
    }
}

properties([[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', numToKeepStr: '3']]])
@Library('github.com/releaseworks/jenkinslib') _
node{
    def mvn_home
    def docker
    def imageName
    def lastSuccessfulBuildID
    def PUBLIC_DNS
    def EC2_INSTANCE_ID

    //get last successful build number so that we can terminate
    //the docker container running for the image associated with that build tag
    script{
        script{
            def build = currentBuild.previousBuild
            while (build != null) {
                if (build.result != "FAILURE")
                {
                    lastSuccessfulBuildID = build.id as Integer
                    break
                }
                build = build.previousBuild
            }
        }
    }
    stage('Initialize')
    {
        docker = tool 'docker'
        mvn_home = tool 'maven'
        imageName="abninder/hello-world-image"
        env.PATH = "${docker}/bin:${mvn_home}/bin:${env.PATH}"
    }

    //check out deployment project
    stage('SCM Checkout'){
        git 'https://github.com/abnindergill/deployment.git'
    }

    //rebuild and package the deployment project
    stage('Compile-Package'){
        sh "${mvn_home}/bin/mvn package"
    }

    //build the docker image tagging it with the jenkins build number
    stage('Build image'){
        sh "docker build -t ${imageName}:${BUILD_NUMBER} ${WORKSPACE} "
    }

    //login into docker hub and push the built image to docker hub with image tag
    stage('Push image')
    {
        withCredentials([string(credentialsId: 'dockerLog', variable: 'DockerHubLogin')]) {
             sh "docker login -u abninder -p ${DockerHubLogin}"
        } 
        sh "docker push ${imageName}:${BUILD_NUMBER}"
    }

    stage('start/check ec2 instance'){

        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'aws-key', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            AWS("--region=us-east-1 s3 ls")

            sh "chmod 777 ${WORKSPACE}/target/scripts/*.sh"
            sh "source ${WORKSPACE}/target/scripts/ec2-create-instance.sh"
            PUBLIC_DNS=${EC2_HOST_NAME}
            EC2_INSTANCE_ID=${INSTANCE_ID}
        }

    }

    //deploy to amazon ec2 instance and start up the container there
    stage('Deploy to ec2'){
        sh "chmod 777 ${WORKSPACE}/target/scripts/*.sh"
        sh "${WORKSPACE}/target/api/ec2-deployment.sh ${WORKSPACE} ${imageName} ${lastSuccessfulBuildID} ${BUILD_NUMBER} ${PUBLIC_DNS}"
    }
}
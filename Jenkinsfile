properties([[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', numToKeepStr: '3']]])

node{
    def mvn_home
    def docker
    def imageName
    def lastSuccessfulBuildID
    def publicDns;

    environment {
        ec2_pem_key_path = "/Users/abninder/aws_credentials/HelloWorld.pem"
    }

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

    stage('prepare ec2 instance'){
        sh "chmod 777 ${WORKSPACE}/target/scripts/*.sh"
        sh "${WORKSPACE}/target/scripts/prepareEC2Instance.sh ${env.ec2_pem_key_path}"
        //sh echo ec2 instance: ${publicDns}
    }

    //stage ('deploy to ec2') {
        //sh "chmod 777 ${WORKSPACE}/target/scripts/ec2-deployment.sh ${WORKSPACE} ${imageName} ${lastSuccessfulBuildID} ${BUILD_NUMBER} ${publicDns} ${env.ec2_pem_key_path}"
    //}
}
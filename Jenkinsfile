properties([[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', numToKeepStr: '3']]])

node{
    def mvn_home
    def docker
    def imageName

    stage('Initialize')
    {
        docker = tool 'docker'
        mvn_home = tool 'maven'
        imageName="abninder/test-image-new"
        env.PATH = "${docker}/bin:${mvn_home}/bin:${env.PATH}"
    }
   
    stage('SCM Checkout'){
        git 'https://github.com/abnindergill/deployment.git'
    }
    
    stage('Compile-Package'){
        sh "${mvn_home}/bin/mvn package"
    }

    stage('clean-up'){
        //tidy up by removing all stopped containers
        sh 'docker container prune -f'
    }

    stage('Build image'){
        sh "docker build -t ${imageName} . "
    }

    stage('Push image')
    {
        withCredentials([string(credentialsId: 'dockerLog', variable: 'DockerHubLogin')]) {
             sh "docker login -u abninder -p ${DockerHubLogin}"
        } 
        sh "docker push ${imageName}"
    }

    stage('Deploy to ec2'){
        def stopScript = "${WORKSPACE}/target/api/docker-stop.sh"
        def scriptsPath = "${WORKSPACE}/target/api/*.sh"
        def ec2ScriptDestinationFolder = "/home/ec2-user/scripts"
        def permKey = "/Users/abninder/aws_credentials/docker-app.pem"
        def ec2Instance = " ec2-user@ec2-35-171-176-196.compute-1.amazonaws.com"

        sh "chmod 777 ${scriptsPath}"
        sh "scp -i ${permKey} ${scriptsPath} ${ec2Instance}:${ec2ScriptDestinationFolder}"

        sh "ssh -i ${permKey} ${ec2Instance} ${ec2ScriptDestinationFolder} docker-stop.sh ${imageName}"
        sh "ssh -i ${permKey} ${ec2Instance} ${ec2ScriptDestinationFolder} docker-fetch-image.sh ${imageName}"

        def dockerRun = "sudo docker run -p 8082:8085 -e LISTEN_PORT=8085 ${imageName}"
        sh "ssh -i ${permKey} ${ec2Instance} ${dockerRun}"
    }
}
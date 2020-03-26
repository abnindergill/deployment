properties([[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', numToKeepStr: '3']]])

node{
    def mvn_home
    def docker

    stage('Initialize')
    {
        docker = tool 'docker'
        mvn_home = tool 'maven'
        env.PATH = "${docker}/bin:${mvn_home}/bin:${env.PATH}"
    }
   
    stage('SCM Checkout'){
        git 'https://github.com/abnindergill/deployment.git'
    }
    
    stage('Compile-Package'){
        sh "${mvn_home}/bin/mvn package"
    }

    stage('Build image'){
        sh ' docker build -t abninder/test-image . '
    }

    stage('Push image')
    {
        withCredentials([string(credentialsId: 'dockerLog', variable: 'DockerHubLogin')]) {
             sh "docker login -u abninder -p ${DockerHubLogin}"
        } 
        sh 'docker push abninder/test-image'
    }
    
    stage('Deploy application')
    {
         //kill existing container for this image if running before deploying new one
         sh '$WORKSPACE/target/api/docker-stop.sh abninder/test-image'

         //remove all exited containers
         sh 'docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs docker rm'

         //start the new container
         sh 'docker run -p 8082:8085 -e "LISTEN_PORT=8085" abninder/test-image'
    }
}
node{
    def customImage
    def mvn_home
    def containerID
  
    stage('Initialize')
    {
        def dockerHome = tool 'docker'
        mvn_home = tool 'maven'
        env.PATH = "${dockerHome}/bin:${mvn_home}/bin:${env.PATH}"
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

    /*
    stage('Push image')
    {
        withCredentials([string(credentialsId: 'dockerLog', variable: 'DockerHubLogin')]) {
             sh "docker login -u abninder -p ${DockerHubLogin}"
        } 
        sh 'docker push abninder/test-image'
    }
    */
    
    stage('Delpoy application')
    {
         containerID = sh 'docker ps -aqf name=test-image:latest'
         echo 'container id is' + $containerID
         sh 'docker run -p 8082:8085 -e "LISTEN_PORT=8085" abninder/test-image'
    }
}

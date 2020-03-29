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
        //kill existing container for this image if its running before building new one
        //sh 'chmod 777 $WORKSPACE/target/api/docker-stop.sh'
       //
        // sh "$WORKSPACE/target/api/docker-stop.sh ${imageName}"

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


  //  stage('Deploy and start application')
 //   {
   //      //start the container based on the new image
   //      sh "docker run -p 8082:8085 -e LISTEN_PORT=8085 ${imageName}"
  //  }

    stage('Deploy to ec2'){
        sshagent(['ec2-instance']) {
            //def stopCommand= "$WORKSPACE/target/api/docker-stop.sh ${imageName}"

            //sh 'chmod 777 $WORKSPACE/target/api/docker-stop.sh'
            //sh "ssh -o StrictHostKeyChecking=no ec2-user@35.171.176.196 ${stopCommand}"
            def dockerRun = "sudo docker run -p 8082:8085 -e LISTEN_PORT=8085 ${imageName}"
            sh "ssh -o StrictHostKeyChecking=no ec2-user@35.171.176.196 ${dockerRun}"
        }
    }
}
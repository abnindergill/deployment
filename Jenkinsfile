properties([[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', numToKeepStr: '3']]])

node{
    def mvn_home
    def docker
    def imageName
    def lastSuccessfulBuildID=0

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
        sh "docker build -t ${imageName}:${BUILD_NUMBER} ${WORKSPACE} "
    }

    stage('Push image')
    {
        withCredentials([string(credentialsId: 'dockerLog', variable: 'DockerHubLogin')]) {
             sh "docker login -u abninder -p ${DockerHubLogin}"
        } 
        sh "docker push ${imageName}:${BUILD_NUMBER}"
    }

    stage('Deploy to ec2'){
        sh "chmod 777 ${WORKSPACE}/target/api/*.sh"
        sh "${WORKSPACE}/target/api/ec2-deployment.sh ${WORKSPACE} ${imageName} ${lastSuccessfulBuildID} ${BUILD_NUMBER}"
    }
}
// This Jenkinsfile is for Eureka microservice


pipeline {
    agent {
        label 'k8s-slave'
    }
    stages {
        stage ('Build') {
            // This step will take care of building the application
            steps {
                echo "Building the Eureka Application"
                //mvn command 
                sh 'mvn clean package -DskipTests=true'
            }
        }
    }
}
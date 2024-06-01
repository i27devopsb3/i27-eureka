// This Jenkinsfile is for Eureka microservice


pipeline {
    agent {
        label 'k8s-slave'
    }
    tools {
        maven 'Maven-3.8.8'
        jdk 'JDK-17'
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
properties([ parameters([
  string( name: 'AWS_ACCESS_KEY_ID', defaultValue: ''),
  string( name: 'AWS_SECRET_ACCESS_KEY', defaultValue: ''),
  string( name: 'AWS_REGION', defaultValue: 'us-east-1'),
]), pipelineTriggers([]) ])
// Environment Variables.
env.access_key = AWS_ACCESS_KEY_ID
env.secret_key = AWS_SECRET_ACCESS_KEY
env.region = AWS_REGION
pipeline {
    agent any
    tools {
        terraform 'terraform'
    }
    stages {
        stage('Git Checkout'){
            steps{
                git branch: 'main',  url: 'https://github.com/hypunit/09062023.git'
            }
        }
        stage ('Terraform Init'){
            steps {
                sh "export TF_VAR_region='${env.aws_region}' && export TF_VAR_access_key='${env.access_key}' && export TF_VAR_secret_key='${env.secret_key}' && terraform init"
            }
        }
        stage ('Terraform Plan'){
            steps {
                sh "export TF_VAR_region='${env.aws_region}' && export TF_VAR_access_key='${env.access_key}' && export TF_VAR_secret_key='${env.secret_key}' && terraform plan -out tfplan" 
            }
        }
        stage('Approval') {
        steps {
        script {
          def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
        }
      }
    }
        stage ('Terraform Apply'){
            steps {
                sh "export TF_VAR_region='${env.aws_region}' && export TF_VAR_access_key='${env.access_key}' && export TF_VAR_secret_key='${env.secret_key}' && terraform apply -input=false tfplan"
            }
        }
    }
}

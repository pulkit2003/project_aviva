pipeline {
    agent any
 
    environment {
        AWS_REGION = 'ap-south-1'
    }
 
    stages {
        stage('Checkout') {
            steps {
                echo "Checking out code from GitHub..."
                // Jenkins job will set the repo URL – this just checks out that repo
                checkout scm
            }
        }
 
        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    sh '''
                      echo "Running terraform init..."
                      terraform init -input=false
 
                      echo "Running terraform fmt & validate..."
                      terraform fmt -check
                      terraform validate
 
                      echo "Running terraform apply..."
                      terraform apply -auto-approve
                    '''
                }
            }
        }
 
        stage('Sync Website to S3') {
            steps {
                dir('website') {
                    sh '''
                      echo "Getting S3 bucket name from terraform output..."
                      BUCKET_NAME=$(cd ../terraform && terraform output -raw static_site_bucket_name)
                      echo "Bucket name is: $BUCKET_NAME"
 
                      echo "Syncing website/ folder to S3..."
                      aws s3 sync . s3://$BUCKET_NAME --delete
                    '''
                }
            }
        }
 
        stage('Show Website URL') {
            steps {
                dir('terraform') {
                    sh '''
                      echo "Website URL:"
                      terraform output website_url
                    '''
                }
            }
        }
    }
 
    post {
        failure {
            echo "Pipeline failed ❌ – check the console log above."
        }
        success {
            echo "Pipeline completed ✅ – website should be updated."
        }
    }
}

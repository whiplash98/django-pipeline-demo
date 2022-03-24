pipeline {
   agent any
   
   environment {
      // AWS_CREDENTIALS environment variables that points to the ID
      // of the AWS Credentials saved in Jenkins
      AWS_CREDENTIALS = 'jenkins_user'
      // The region in which our CodeDeploy application and S3 Bucket are
      AWS_REGION = 'us-east-2'
      // This is the name of our CodeDeploy application
      CODEDEPLOY_APP = 'tutorial_application'
      // This is the name of the deployment group for our 
      // CodeDeploy application
      CODEDEPLOY_DEPLOYGROUP = 'tutorial_application_group'
      // This is the S3 bucket that we will be uploading our
      // releases to
      S3_BUCKET = 'tutorial-application-bucket'
      // This is what we want to name our release. For simplicity, 
      // I am keeping it as artifact.zip, but you could do something
      // that includes the Jenkins build number or the Git commit hash
      ARTIFACT = 'artifact.zip'
   }

   stages {
      // The first stage
      // First, we are going to make sure pip is up to date.
      // Then we are going to create a python virtual environment
      // in the current working directory. And then we are going
      // to activate the virtual environment.
      stage('Setting up virtual environment') {
         steps {
            echo 'Making sure that pip is up to date'
            sh 'python3 -m pip install --upgrade pip'
            echo 'Creating a virtual evironment'
            sh 'python3 -m venv .'
            echo 'Activating the virtual environment'
            sh '. bin/activate'
         }
      }
      
      // The build stage
      // Here we are installing the project dependencies from
      // requirements.txt via pip
      stage('Build') {
         steps {
            echo 'Installing depdendencies from requirements.txt'
            sh 'python3 -m pip install -r requirements.txt'
         }
      }
      
      // The test stage
      // Here we are running our tests with pytest and exporting 
      // the results with junit-xml to ./reports/test_report.xml
      stage('Test') {
         steps {
            echo 'Running tests via pytest'
            sh 'python3 -m pytest --junit-xml=./reports/test_report.xml'
         }
      }
      
      // The release stage
      // Here we are zipping up the project into a zipped file
      // that is named according to our ARTIFACT environment variable
      // After the file has been zipped, we are uploading it to your S3 bucket
      // that was declared in the S3_BUCKET environment variable
      stage('Release') {
         steps {
            echo "Zipping the release to ${ARTIFACT}"
            sh 'zip -r ${ARTIFACT} *'
            echo "Uploading the release to S3 bucket ${S3_BUCKET}"
            withAWS(credentials: "${AWS_CREDENTIALS}", region: "${AWS_REGION}") {
               echo 'Uploading to S3...'
               s3Upload(acl: 'Private', bucket: "${S3_BUCKET}", file: "${ARTIFACT}")
            }
         }
      }
      
      // The deploy stage
      // Here we are letting creating a deployment in CodeDeploy.
      // applicationName: this is the name of our CodeDepoy application
      // deploymentGroupName: this is the name of our deployment group
      // s3Bucket: this is the name of our S3 bucket has holds our releases
      // s3Key: this is the name of our release
      // s3BundleType: this is the file type of our release
      // waitForCompletion: this is if we want our Jenkins pipeline
      //       to wait for CodeDeploy to finish deploying the app
      stage('Deploy') {
         steps {
            withAWS(credentials: "${AWS_CREDENTIALS}", region: "${AWS_REGION}") {
               createDeployment(
                  applicationName: "${CODEDEPLOY_APP}",
                  deploymentGroupName: "${CODEDEPLOY_DEPLOYGROUP}",
                  s3Bucket: "${S3_BUCKET}",
                  s3Key: "${ARTIFACT}",
                  s3BundleType: 'zip',
                  waitForCompletion: true
               )
            }
         }
      }
   }

   // Here are actions that occur AFTER the pipeline runs
   post {
      // always is for code that you want to run
      // after EVERY pipeline run
      always {
         // publish our test reports with junit
         junit 'reports/*.xml'
         // Clean the workspace.
         // This deletes everything in the workspace
         cleanWs()
      }
   }
}

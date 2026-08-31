# Troubleshooting Guide

# Enterprise Java DevOps CI/CD Pipeline

This document contains common issues and troubleshooting steps for the Enterprise Java DevOps CI/CD Pipeline.

The pipeline includes GitHub, Jenkins, Maven, SonarQube, Amazon S3, Apache Tomcat, AWS EC2, and separate Testing and Production environments.

---

## 1. GitHub Checkout Failure

### Problem

Jenkins is unable to clone or checkout the GitHub repository.

### Check

Verify the repository URL:

    https://github.com/<GITHUB-USERNAME>/enterprise-java-devops-cicd.git

Verify the branch:

    main

Check the Jenkins Console Output for Git errors.

### Possible Causes

- Incorrect repository URL
- Incorrect branch name
- Git is not installed on Jenkins
- Network connectivity issue
- Repository access issue

### Solution

Verify Git installation:

    git --version

Verify the repository manually:

    git clone https://github.com/<GITHUB-USERNAME>/enterprise-java-devops-cicd.git

Verify the Jenkins Pipeline SCM configuration.

---

## 2. Java Not Found

### Problem

Jenkins cannot find Java.

Typical error:

    java: command not found

### Check

Run:

    java -version

### Solution

Install Java if required:

    sudo apt update

    sudo apt install -y openjdk-17-jdk

Verify:

    java -version

Make sure the Java environment is available to Jenkins.

---

## 3. Maven Not Found

### Problem

The Jenkins pipeline fails during the Maven Build stage.

Typical error:

    mvn: command not found

### Check

Run:

    mvn -version

### Solution

Install Maven if required:

    sudo apt update

    sudo apt install -y maven

Verify:

    mvn -version

The Jenkins server must be able to execute the `mvn` command.

---

## 4. Maven Build Failure

### Problem

The Maven Build stage fails.

### Check

Run the build manually from the project directory:

    mvn clean compile

Check the Console Output for compilation errors.

### Possible Causes

- Java compilation error
- Incorrect `pom.xml`
- Missing dependency
- Incorrect Java version
- Application source code problem

### Solution

Verify:

    pom.xml

Verify:

    java -version

Verify:

    mvn -version

Run:

    mvn clean compile

Fix the application or Maven configuration based on the reported error.

---

## 5. SonarQube Connection Failure

### Problem

Jenkins cannot connect to SonarQube.

### Check

Verify SonarQube service:

    sudo systemctl status sonarqube

Verify SonarQube from the Jenkins server:

    curl http://<SONARQUBE-PRIVATE-IP>:9000

### Possible Causes

- SonarQube service is stopped
- Incorrect SonarQube URL
- Security Group does not allow port 9000
- Network connectivity issue
- Incorrect Jenkins SonarQube configuration

### Solution

Start SonarQube if required:

    sudo systemctl start sonarqube

Verify port 9000 is reachable from Jenkins.

Check the Jenkins SonarQube configuration.

---

## 6. SonarQube Authentication Failure

### Problem

SonarQube analysis fails because authentication is rejected.

### Check

Verify the Jenkins credential:

    sonarqube-token

Make sure the token is valid.

### Possible Causes

- Incorrect token
- Expired token
- Wrong credential ID
- Token is not being passed to Maven

### Solution

Generate a new SonarQube token if necessary.

Update the Jenkins credential:

    sonarqube-token

Do not place the token directly inside the Jenkinsfile.

---

## 7. SonarQube Project Not Found

### Problem

SonarQube analysis is not associated with the expected project.

### Check

Verify:

    sonar.projectKey=java-web-app

Verify that the SonarQube project exists.

Project name:

    java-web-app

Project key:

    java-web-app

### Solution

Make sure the Jenkins pipeline and SonarQube project use the same project key.

---

## 8. Quality Gate Timeout

### Problem

The pipeline remains waiting at the Quality Gate stage.

### Possible Causes

- SonarQube analysis is still processing
- SonarQube webhook is not configured
- Jenkins cannot receive the webhook
- Security Group blocks Jenkins access
- Incorrect webhook URL

### Check

Verify the SonarQube webhook:

    /sonarqube-webhook/

Example:

    http://<JENKINS-PRIVATE-IP>:8080/sonarqube-webhook/

Verify Jenkins is running:

    sudo systemctl status jenkins

Verify Jenkins port:

    8080

---

## 9. SonarQube Webhook Failure

### Problem

SonarQube completes analysis but Jenkins does not receive the Quality Gate result.

### Check

In SonarQube, verify the webhook configuration.

Webhook URL:

    http://<JENKINS-PRIVATE-IP>:8080/sonarqube-webhook/

Check the webhook delivery status.

### Possible Causes

- Incorrect Jenkins private IP
- Incorrect webhook URL
- Jenkins port 8080 blocked
- Jenkins is unavailable
- Security Group configuration issue

### Solution

Verify Jenkins accessibility from the SonarQube server.

Verify the Security Group rule:

    SonarQube → Jenkins :8080

---

## 10. Quality Gate Failed

### Problem

The SonarQube Quality Gate fails and Jenkins stops the pipeline.

### Expected Behavior

This is not necessarily a Jenkins error.

The pipeline is designed to stop when the Quality Gate fails.

Flow:

    SonarQube Analysis
            |
            v
       Quality Gate
            |
            +---- FAIL ----> Pipeline Stops

### Solution

Open the SonarQube project and review the reported issues.

Fix the application code if required.

Run the Jenkins pipeline again after resolving the Quality Gate issues.

---

## 11. WAR File Not Generated

### Problem

The WAR file is missing after Maven packaging.

Expected file:

    target/java-web-app.war

### Check

Run:

    mvn package -DskipTests

Then:

    ls -lh target/

### Possible Causes

- Incorrect Maven packaging configuration
- Incorrect `artifactId`
- Build failure
- Incorrect project structure

### Solution

Verify the `pom.xml`.

Make sure the packaging is:

    <packaging>war</packaging>

Verify the expected artifact name:

    java-web-app.war

---

## 12. Amazon S3 Access Denied

### Problem

Jenkins cannot upload the WAR file to S3.

Typical error:

    AccessDenied

### Check

Run from Jenkins:

    aws sts get-caller-identity

Then:

    aws s3 ls

### Possible Causes

- IAM role is not attached
- IAM permissions are insufficient
- Incorrect S3 bucket name
- Incorrect AWS region
- Bucket policy restriction

### Solution

Verify the IAM role attached to the Jenkins EC2 instance.

Verify that the role has the required S3 permissions.

Check the bucket name:

    sam-java-cicd-artifacts-2026

---

## 13. S3 Bucket Not Found

### Problem

Jenkins cannot find the configured S3 bucket.

### Check

Run:

    aws s3 ls

Verify the bucket name in the Jenkinsfile.

Expected bucket:

    sam-java-cicd-artifacts-2026

### Possible Causes

- Incorrect bucket name
- Wrong AWS region
- Bucket does not exist
- AWS credentials or IAM role issue

### Solution

Verify the bucket in Amazon S3.

Verify the AWS region:

    ap-south-1

---

## 14. WAR Upload to S3 Fails

### Problem

The Upload Artifact to S3 stage fails.

### Check

Verify the WAR exists:

    ls -lh target/java-web-app.war

Test the upload manually:

    aws s3 cp target/java-web-app.war s3://sam-java-cicd-artifacts-2026/artifacts/java-web-app/test/java-web-app.war

### Possible Causes

- WAR file does not exist
- S3 access denied
- Incorrect bucket name
- IAM permission issue
- AWS CLI configuration problem

---

## 15. Testing Deployment Failure

### Problem

The Deploy to Testing Environment stage fails.

### Check

Verify Testing Tomcat:

    sudo systemctl status tomcat

Verify the Testing server is reachable:

    curl http://<TESTING-PRIVATE-IP>:8080

### Possible Causes

- Tomcat is stopped
- Security Group blocks port 8080
- Incorrect Tomcat credentials
- Tomcat Manager is not configured
- Incorrect Testing private IP
- WAR file download failed

### Solution

Verify:

    tomcat-testing

Jenkins credential.

Verify the Testing Tomcat Manager configuration.

Verify Jenkins can reach the Testing server on port 8080.

---

## 16. Testing Tomcat Manager Authentication Failure

### Problem

The WAR deployment returns an authentication error.

### Possible Causes

- Incorrect username
- Incorrect password
- Incorrect Jenkins credential
- Tomcat Manager user not configured correctly

### Solution

Verify the Jenkins credential:

    tomcat-testing

Verify the Tomcat Manager user configuration.

Do not store the Tomcat password inside the Jenkinsfile.

---

## 17. Testing Application Not Opening

### Problem

The WAR deployment succeeds but the application is not accessible.

Expected URL:

    http://<TESTING-PUBLIC-IP>:8080/java-web-app/

### Check

Verify Tomcat:

    sudo systemctl status tomcat

Verify deployed application:

    /java-web-app

Check Tomcat logs.

Example:

    sudo journalctl -u tomcat

### Possible Causes

- Application deployment failed
- Incorrect context path
- Tomcat startup issue
- Security Group issue
- Application configuration problem

---

## 18. Production Approval Not Appearing

### Problem

The pipeline does not display the manual approval step.

### Check

Verify that the Testing deployment completed successfully.

Expected order:

    Testing Deployment
          |
          v
    Production Approval
          |
          v
    Production Deployment

If Testing fails, the Production Approval stage will not be reached.

---

## 19. Production Deployment Failure

### Problem

The Deploy to Production Environment stage fails.

### Check

Verify Production Tomcat:

    sudo systemctl status tomcat

Verify connectivity:

    curl http://<PRODUCTION-PRIVATE-IP>:8080

Verify the Jenkins credential:

    tomcat-production

### Possible Causes

- Production Tomcat is stopped
- Incorrect credentials
- Security Group issue
- Incorrect Production private IP
- Tomcat Manager configuration issue
- S3 artifact download failure

---

## 20. Production Application Not Opening

### Problem

The WAR deployment completes but the Production application cannot be opened.

Expected URL:

    http://<PRODUCTION-PUBLIC-IP>:8080/java-web-app/

### Check

Verify Tomcat:

    sudo systemctl status tomcat

Verify application deployment:

    /java-web-app

Check Tomcat logs:

    sudo journalctl -u tomcat

Verify Security Group rules.

---

## 21. Jenkins Cannot Reach Testing Server

### Problem

Jenkins cannot communicate with the Testing Tomcat server.

### Check

From Jenkins:

    curl http://<TESTING-PRIVATE-IP>:8080

### Possible Causes

- Testing Security Group does not allow Jenkins
- Incorrect private IP
- Tomcat is not running
- Network configuration issue

### Solution

Allow the required traffic:

    Jenkins Security Group
            |
            +---- TCP 8080 ----> Testing Security Group

---

## 22. Jenkins Cannot Reach Production Server

### Problem

Jenkins cannot communicate with the Production Tomcat server.

### Check

From Jenkins:

    curl http://<PRODUCTION-PRIVATE-IP>:8080

### Solution

Verify:

    Jenkins Security Group
            |
            +---- TCP 8080 ----> Production Security Group

Also verify that Tomcat is running on the Production server.

---

## 23. SonarQube Cannot Reach Jenkins

### Problem

The Quality Gate webhook cannot reach Jenkins.

### Check

From SonarQube:

    curl http://<JENKINS-PRIVATE-IP>:8080

### Required Communication

    SonarQube Security Group
            |
            +---- TCP 8080 ----> Jenkins Security Group

---

## 24. Jenkins Pipeline Fails at AWS CLI Command

### Problem

An AWS CLI command fails inside Jenkins.

### Check

Verify:

    aws --version

Verify AWS identity:

    aws sts get-caller-identity

Verify S3:

    aws s3 ls

### Possible Causes

- AWS CLI not installed
- IAM role missing
- IAM permission issue
- Incorrect region
- Incorrect bucket name

---

## 25. Jenkins Workspace Issues

### Problem

Old files in the Jenkins workspace cause unexpected behavior.

### Check

Review the Jenkins workspace.

The WAR file should normally be generated at:

    target/java-web-app.war

### Solution

The pipeline uses:

    rm -f "$WAR_FILE"

before downloading the artifact from S3 during deployment.

This helps ensure the deployment uses the artifact retrieved from S3.

---

## 26. Artifact Missing from S3

### Problem

The deployment stage cannot find the WAR artifact.

### Check

Verify the expected S3 path:

    artifacts/java-web-app/<BUILD_NUMBER>/java-web-app.war

List the artifact:

    aws s3 ls s3://sam-java-cicd-artifacts-2026/artifacts/java-web-app/<BUILD_NUMBER>/

### Possible Causes

- Upload stage failed
- Incorrect build number
- Incorrect S3 path
- Incorrect bucket name
- IAM permission issue

---

## 27. Wrong Artifact Deployed

### Problem

An unexpected WAR version is deployed.

### Check

Verify the Jenkins build number.

Expected artifact structure:

    artifacts/
    └── java-web-app/
        └── <BUILD_NUMBER>/
            └── java-web-app.war

The Testing and Production stages should retrieve the artifact associated with the current Jenkins build.

---

## 28. Private IP Connectivity Issue

### Problem

Jenkins cannot reach another EC2 instance using its private IP.

### Check

Verify the private IP addresses of the EC2 instances.

Verify that all servers are inside the appropriate network.

Verify Security Group rules.

### Required Communication

    Jenkins → SonarQube :9000

    Jenkins → Testing :8080

    Jenkins → Production :8080

    SonarQube → Jenkins :8080

---

# General Troubleshooting Checklist

When the pipeline fails, follow this order:

1. Check Jenkins Console Output.
2. Identify the failed stage.
3. Verify the server involved in that stage.
4. Check the service status.
5. Check network connectivity.
6. Check Security Group rules.
7. Check credentials.
8. Check IAM permissions.
9. Check configuration.
10. Run the failing command manually when possible.

---

# Service Status Commands

## Jenkins

    sudo systemctl status jenkins

## SonarQube

    sudo systemctl status sonarqube

## Tomcat

    sudo systemctl status tomcat

---

# Connectivity Checks

## Check Jenkins

    curl http://<JENKINS-PRIVATE-IP>:8080

## Check SonarQube

    curl http://<SONARQUBE-PRIVATE-IP>:9000

## Check Testing Tomcat

    curl http://<TESTING-PRIVATE-IP>:8080

## Check Production Tomcat

    curl http://<PRODUCTION-PRIVATE-IP>:8080

---

# AWS Checks

Check AWS identity:

    aws sts get-caller-identity

List S3 buckets:

    aws s3 ls

List project artifacts:

    aws s3 ls s3://sam-java-cicd-artifacts-2026/artifacts/java-web-app/

---

# Important Security Rules

Never commit the following to GitHub:

- AWS Access Keys
- AWS Secret Keys
- SonarQube Tokens
- Tomcat Passwords
- SSH Private Keys
- `.pem` files
- Jenkins Secrets
- Any other sensitive credentials

Use:

    Jenkins Credentials

for application credentials.

Use:

    IAM Role

for Jenkins AWS access.

---

# Final Troubleshooting Flow

Pipeline Failure
      |
      v
Check Jenkins Console
      |
      v
Identify Failed Stage
      |
      v
Check Configuration
      |
      v
Check Credentials
      |
      v
Check Network
      |
      v
Check Security Groups
      |
      v
Check Server Service
      |
      v
Check Logs
      |
      v
Fix Issue
      |
      v
Run Pipeline Again

---

# Conclusion

Most CI/CD failures can be traced to one of the following areas:

- Source Code
- Java
- Maven
- Jenkins
- SonarQube
- Quality Gate
- Webhook
- AWS IAM
- Amazon S3
- Security Groups
- Network Connectivity
- Tomcat
- Jenkins Credentials
- Application Configuration

The recommended troubleshooting approach is to identify the failed pipeline stage first and then verify the component responsible for that stage.

**Identify → Check → Fix → Rebuild → Verify**
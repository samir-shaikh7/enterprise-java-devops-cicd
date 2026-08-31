# Deployment Guide

## Enterprise Java DevOps CI/CD Pipeline

This document explains the deployment process used in the Enterprise Java DevOps CI/CD Pipeline.

The application is built using Maven, analyzed using SonarQube, packaged as a WAR file, stored in Amazon S3, and deployed to separate Testing and Production Apache Tomcat environments.

---

## Deployment Architecture

GitHub
   |
   v
Jenkins
   |
   +----> Maven Build
   |
   +----> SonarQube Analysis
   |
   +----> Quality Gate
   |
   v
WAR Packaging
   |
   v
Amazon S3
   |
   v
Testing Tomcat
   |
   v
Manual Production Approval
   |
   v
Production Tomcat

---

## Prerequisites

Before starting the deployment, the following components should be available:

- AWS Account
- Four EC2 instances
- Ubuntu Linux
- Java
- Maven
- Git
- Jenkins
- SonarQube
- Apache Tomcat
- Amazon S3 Bucket
- IAM Role for Jenkins
- GitHub Repository

---

## EC2 Infrastructure

The project uses four EC2 instances:

| Server | Purpose | Service |
|---|---|---|
| Jenkins Server | CI/CD automation | Jenkins |
| SonarQube Server | Code quality analysis | SonarQube |
| Testing Server | Testing deployment | Apache Tomcat |
| Production Server | Production deployment | Apache Tomcat |

---

## Security Groups

Security Groups are configured to allow the required communication between the servers.

Jenkins Server
   |
   +---- TCP 9000 ----> SonarQube Server
   |
   +---- TCP 8080 ----> Testing Server
   |
   +---- TCP 8080 ----> Production Server

SonarQube Server
   |
   +---- TCP 8080 ----> Jenkins Server

Only the required ports and communication paths should be allowed.

---

## Step 1 — Prepare Jenkins Server

Connect to the Jenkins EC2 instance.

Update the package repository:

    sudo apt update

Install required packages if they are not already installed:

    sudo apt install -y git curl unzip

Verify Git:

    git --version

Verify Java:

    java -version

Verify Maven:

    mvn -version

Verify AWS CLI:

    aws --version

---

## Step 2 — Prepare SonarQube Server

Connect to the SonarQube EC2 instance.

Verify Java:

    java -version

Check the SonarQube service:

    sudo systemctl status sonarqube

Open SonarQube in the browser:

    http://<SONARQUBE-PUBLIC-IP>:9000

---

## Step 3 — Prepare Testing Tomcat Server

Connect to the Testing EC2 instance.

Verify Java:

    java -version

Check Tomcat:

    sudo systemctl status tomcat

Open the Testing Tomcat server:

    http://<TESTING-PUBLIC-IP>:8080

The application will be deployed using the context path:

    /java-web-app

---

## Step 4 — Prepare Production Tomcat Server

Connect to the Production EC2 instance.

Verify Java:

    java -version

Check Tomcat:

    sudo systemctl status tomcat

Open the Production Tomcat server:

    http://<PRODUCTION-PUBLIC-IP>:8080

The application will be deployed using the context path:

    /java-web-app

---

## Step 5 — Create Amazon S3 Bucket

Create an Amazon S3 bucket for storing WAR artifacts.

Example bucket name:

    sam-java-cicd-artifacts-2026

The S3 bucket acts as the centralized artifact repository for the CI/CD pipeline.

---

## Step 6 — Configure IAM Role for Jenkins

Attach an IAM role to the Jenkins EC2 instance.

The role should provide the required permissions for Jenkins to access the project S3 bucket.

The Jenkins server uses the IAM role instead of storing AWS access keys inside the Jenkinsfile.

Verify the AWS identity:

    aws sts get-caller-identity

Verify S3 access:

    aws s3 ls

---

## Step 7 — Prepare the Java Web Application

The application is a Maven-based Java Web Application.

Project structure:

enterprise-java-devops-cicd/
│
├── pom.xml
├── Jenkinsfile
├── README.md
├── architecture.md
│
└── src/
    └── main/
        ├── java/
        └── webapp/
            ├── WEB-INF/
            │   └── web.xml
            ├── css/
            ├── js/
            └── index.jsp

The application is packaged as a WAR file.

Expected artifact:

    target/java-web-app.war

---

## Step 8 — Push Application to GitHub

Initialize Git:

    git init

Add the GitHub repository:

    git remote add origin https://github.com/<GITHUB-USERNAME>/enterprise-java-devops-cicd.git

Verify the remote:

    git remote -v

Add project files:

    git add .

Commit the project:

    git commit -m "Initial Enterprise Java DevOps CI/CD project"

Set the main branch:

    git branch -M main

Push the project:

    git push -u origin main

---

## Step 9 — Configure SonarQube

Open SonarQube:

    http://<SONARQUBE-PUBLIC-IP>:9000

Create a SonarQube project.

Project Name:

    java-web-app

Project Key:

    java-web-app

Generate a SonarQube authentication token.

Store the token securely in Jenkins Credentials.

Do not commit the token to GitHub.

---

## Step 10 — Configure SonarQube Quality Gate

Configure the required Quality Gate in SonarQube.

The Jenkins pipeline waits for the Quality Gate result.

SonarQube Analysis
        |
        v
Quality Gate
        |
     +--+--+
     |     |
    PASS  FAIL
     |     |
     v     v
 Continue Stop Pipeline

The pipeline continues only when the Quality Gate passes.

---

## Step 11 — Configure SonarQube Webhook

Configure a webhook in SonarQube pointing to Jenkins.

Webhook endpoint:

    http://<JENKINS-PRIVATE-IP>:8080/sonarqube-webhook/

The webhook allows SonarQube to send the Quality Gate result back to Jenkins.

---

## Step 12 — Configure Jenkins Pipeline Job

Open Jenkins:

    http://<JENKINS-PUBLIC-IP>:8080

Create a Pipeline job.

Recommended job name:

    enterprise-java-devops-cicd

Configure the pipeline:

    Definition:
    Pipeline script from SCM

    SCM:
    Git

    Repository:
    https://github.com/<GITHUB-USERNAME>/enterprise-java-devops-cicd.git

    Branch:
    */main

    Script Path:
    Jenkinsfile

The Jenkins job retrieves the Jenkinsfile directly from GitHub.

---

## Step 13 — Configure Jenkins Credentials

Create the following credentials.

### SonarQube Token

Credential ID:

    sonarqube-token

Credential Type:

    Secret Text

Value:

    <SONARQUBE-TOKEN>

---

### Testing Tomcat Credentials

Credential ID:

    tomcat-testing

Credential Type:

    Username with password

Use the Testing Tomcat Manager username and password.

---

### Production Tomcat Credentials

Credential ID:

    tomcat-production

Credential Type:

    Username with password

Use the Production Tomcat Manager username and password.

---

## Step 14 — Jenkins Pipeline

The Jenkinsfile contains the complete CI/CD workflow.

Pipeline stages:

Source Code Checkout
        |
        v
Maven Build
        |
        v
Code Quality Analysis
        |
        v
Quality Gate Validation
        |
        v
WAR Artifact Packaging
        |
        v
Upload Artifact to S3
        |
        v
Deploy to Testing Environment
        |
        v
Production Deployment Approval
        |
        v
Deploy to Production Environment

---

## Step 15 — Source Code Checkout

Jenkins checks out the source code from GitHub.

The source code is copied into the Jenkins workspace.

The pipeline uses the main branch.

---

## Step 16 — Maven Build

Jenkins executes:

    mvn clean compile

Maven compiles the Java source code.

If compilation succeeds, the pipeline continues to SonarQube analysis.

---

## Step 17 — SonarQube Analysis

Jenkins performs SonarQube static code analysis.

The application source code is analyzed for code quality issues.

The pipeline then waits for the SonarQube Quality Gate result.

---

## Step 18 — Quality Gate Validation

Jenkins waits for the Quality Gate result.

Quality Gate
     |
     +---- PASSED ----> Continue
     |
     +---- FAILED ----> Stop Pipeline

A failed Quality Gate prevents the pipeline from continuing to WAR packaging.

---

## Step 19 — Package WAR

After the Quality Gate passes, Maven packages the application.

Command:

    mvn package -DskipTests

Generated WAR file:

    target/java-web-app.war

Verify the artifact:

    ls -lh target/java-web-app.war

---

## Step 20 — Upload WAR to Amazon S3

Jenkins uploads the generated WAR file to the S3 bucket.

Example:

    aws s3 cp target/java-web-app.war s3://sam-java-cicd-artifacts-2026/artifacts/java-web-app/<BUILD_NUMBER>/java-web-app.war

The artifact is stored using the Jenkins build number.

Example:

artifacts/
└── java-web-app/
    ├── 1/
    │   └── java-web-app.war
    ├── 2/
    │   └── java-web-app.war
    └── 3/
        └── java-web-app.war

---

## Step 21 — Deploy to Testing

Jenkins downloads the WAR artifact from Amazon S3.

Example:

    aws s3 cp s3://sam-java-cicd-artifacts-2026/artifacts/java-web-app/<BUILD_NUMBER>/java-web-app.war target/java-web-app.war

The WAR file is then deployed to the Testing Tomcat server through the Tomcat Manager API.

Application context:

    /java-web-app

---

## Step 22 — Verify Testing Deployment

Open the Testing application:

    http://<TESTING-PUBLIC-IP>:8080/java-web-app/

Verify that the Java Web Application is available.

The Testing deployment must complete successfully before Production approval.

---

## Step 23 — Production Deployment Approval

After Testing deployment, Jenkins pauses at the manual approval stage.

The Jenkins pipeline displays an approval prompt.

Example:

    Deploy the approved artifact to Production?

Select:

    Deploy to Production

to continue.

If the deployment is aborted, the Production deployment does not happen.

---

## Step 24 — Deploy to Production

After approval, Jenkins retrieves the same WAR artifact from Amazon S3.

Amazon S3
    |
    v
Same java-web-app.war
    |
    v
Production Tomcat

The artifact is deployed through the Tomcat Manager API.

Application context:

    /java-web-app

No second Maven build is performed for Production.

---

## Step 25 — Verify Production Deployment

Open the Production application:

    http://<PRODUCTION-PUBLIC-IP>:8080/java-web-app/

Verify that the Java Web Application is available.

---

# Build Once → Store → Deploy

The application is built once.

Maven
  |
  v
java-web-app.war
  |
  v
Amazon S3
  |
  +------------+
  |            |
  v            v
Testing    Production

The same WAR artifact is used for Testing and Production.

Production does not perform another Maven build.

---

# Artifact Versioning

Each Jenkins build creates an artifact path based on the Jenkins build number.

Example:

    artifacts/java-web-app/1/java-web-app.war

    artifacts/java-web-app/2/java-web-app.war

    artifacts/java-web-app/3/java-web-app.war

This allows different builds to be stored separately in Amazon S3.

---

# Deployment Verification

After the pipeline completes successfully, verify the following.

## Jenkins

Pipeline status:

    SUCCESS

## SonarQube

Quality Gate:

    PASSED

## Amazon S3

Verify that the WAR artifact exists:

    artifacts/java-web-app/<BUILD_NUMBER>/java-web-app.war

## Testing

Verify the application:

    /java-web-app

on the Testing Tomcat server.

## Production

Verify the application:

    /java-web-app

on the Production Tomcat server.

---

# Troubleshooting

If the pipeline fails, check the Jenkins Console Output.

Common areas to verify:

- GitHub repository URL
- Git branch
- Java installation
- Maven installation
- SonarQube configuration
- SonarQube token
- SonarQube Quality Gate
- SonarQube webhook
- Jenkins credentials
- AWS IAM permissions
- S3 bucket name
- Testing Tomcat credentials
- Production Tomcat credentials
- Security Group rules
- Tomcat Manager configuration
- Private IP addresses
- Application context path

---

# Security Checklist

Before pushing the project to GitHub, verify that the repository does not contain:

- AWS Access Keys
- AWS Secret Keys
- Passwords
- SonarQube Tokens
- Private SSH Keys
- .pem files
- Jenkins secrets
- Tomcat passwords
- Other sensitive credentials

Use Jenkins Credentials and AWS IAM roles for sensitive authentication.

---

# Final Deployment Architecture

GitHub
   |
   v
Jenkins EC2 Server
   |
   +-------------------+
   |                   |
   v                   v
Maven Build       SonarQube
   |              Analysis
   |                   |
   |              Quality Gate
   |                   |
   +---------+---------+
             |
             v
      WAR Artifact
             |
             v
        Amazon S3
      Artifact Store
             |
             v
      Testing Tomcat
             |
             v
   Manual Production
       Approval
             |
             v
    Production Tomcat
             |
             v
      Live Application

---

# Final Deployment Flow

GitHub
   |
   v
Source Code Checkout
   |
   v
Maven Build
   |
   v
SonarQube Analysis
   |
   v
Quality Gate Validation
   |
   v
WAR Artifact Packaging
   |
   v
Amazon S3
   |
   v
Testing Environment
   |
   v
Production Approval
   |
   v
Production Environment
   |
   v
Live Application

---

# Conclusion

This deployment guide demonstrates the complete deployment process for the Enterprise Java DevOps CI/CD Pipeline.

The application moves through the following DevOps workflow:

**GitHub → Jenkins → Maven → SonarQube → Quality Gate → WAR → Amazon S3 → Testing → Manual Approval → Production**

The project demonstrates practical DevOps concepts including CI/CD automation, source code management, build automation, code quality analysis, Quality Gates, artifact management, Amazon S3 storage, multi-environment deployment, manual production approval, Jenkins automation, AWS infrastructure, Linux administration, and Apache Tomcat deployment.

The project follows the DevOps principle:

**Build Once → Store Artifact → Deploy the Same Artifact**
# Enterprise Java DevOps CI/CD Pipeline

A complete DevOps CI/CD project for a Maven-based Java Web Application using Jenkins, Maven, SonarQube, Amazon S3, Apache Tomcat, GitHub, AWS EC2, Linux, Shell Scripting, and manual production approval.

## Project Overview

This project implements an end-to-end DevOps CI/CD pipeline for a Java Web Application packaged as a WAR file.

The application source code is maintained in GitHub and automatically processed through Jenkins.

The pipeline performs:

- Source code checkout from GitHub
- Maven build and compilation
- SonarQube static code analysis
- SonarQube Quality Gate validation
- WAR artifact packaging
- Upload of the WAR artifact to Amazon S3
- Deployment to Testing Tomcat
- Manual approval before Production
- Deployment of the same artifact to Production Tomcat

The project follows the DevOps principle:

**Build Once → Store Artifact → Deploy the Same Artifact**

---

## CI/CD Architecture

                         GitHub
                            |
                            v
                    +---------------+
                    |    Jenkins    |
                    |   EC2 Server  |
                    +-------+-------+
                            |
              +-------------+-------------+
              |                           |
              v                           v
        Maven Build                  SonarQube
              |                      Analysis
              |                           |
              |                      Quality Gate
              |                           |
              +-------------+-------------+
                            |
                            v
                     WAR Packaging
                            |
                            v
                    +---------------+
                    |   Amazon S3   |
                    | Artifact Store|
                    +-------+-------+
                            |
                            v
                 +-------------------+
                 | Testing Tomcat    |
                 |    EC2 Server     |
                 +---------+---------+
                           |
                           v
                  Manual Production
                      Approval
                           |
                           v
                 +-------------------+
                 | Production Tomcat|
                 |    EC2 Server     |
                 +---------+---------+
                           |
                           v
                    Live Application

---

## Complete CI/CD Flow

Developer
    |
    v
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
    +---- FAIL ----> Pipeline Stops
    |
    v
WAR Artifact Packaging
    |
    v
Upload Artifact to Amazon S3
    |
    v
Deploy to Testing Environment
    |
    v
Manual Production Approval
    |
    +---- ABORT ----> Production Deployment Stops
    |
    v
Deploy to Production Environment
    |
    v
CI/CD Pipeline SUCCESS

---

## Pipeline Stages

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

## AWS Infrastructure

The project uses four Amazon EC2 instances.

| Server | Purpose | Service |
|---|---|---|
| Jenkins-Server | CI/CD automation | Jenkins |
| SonarQube-Server | Code quality analysis | SonarQube |
| Testing-Server | Application testing | Apache Tomcat |
| Production-Server | Production application | Apache Tomcat |

Amazon S3 is used as the centralized artifact storage location.

---

## Technology Stack

- AWS EC2
- Amazon S3
- Ubuntu Linux
- Git
- GitHub
- Jenkins
- Jenkins Declarative Pipeline
- Java
- Maven
- SonarQube
- Apache Tomcat
- WAR
- Shell Scripting
- cURL
- CI/CD

---

## Application Details

| Property | Value |
|---|---|
| Application Type | Java Web Application |
| Build Tool | Maven |
| Packaging | WAR |
| Group ID | `in.sam` |
| Artifact ID | `java-web-app` |
| Version | `8.3.3-SNAPSHOT` |
| Final WAR | `java-web-app.war` |
| Local Artifact | `target/java-web-app.war` |
| Application Context | `/java-web-app` |

---

## Pipeline Process

### 1. Source Code Checkout

Jenkins checks out the application source code from the GitHub repository.

GitHub
   |
   v
Jenkins Workspace

The pipeline uses the `main` branch.

---

### 2. Maven Build

Maven compiles the Java source code.

Command:

    mvn clean compile

This stage verifies that the Java application can be successfully compiled.

---

### 3. SonarQube Code Quality Analysis

The application source code is analyzed using SonarQube.

The SonarQube project is:

    java-web-app

Jenkins sends the analysis to the SonarQube server using the configured SonarQube integration and authentication token.

---

### 4. Quality Gate Validation

After SonarQube analysis, Jenkins waits for the Quality Gate result.

SonarQube Analysis
        |
        v
Quality Gate
        |
        +---- FAIL ----> Pipeline Stops
        |
        v
      PASS
        |
        v
Continue Pipeline

The pipeline continues only when the configured Quality Gate passes.

---

### 5. WAR Artifact Packaging

Maven packages the Java Web Application into a WAR file.

Command:

    mvn package -DskipTests

Generated artifact:

    target/java-web-app.war

The WAR file is the deployable application artifact.

---

### 6. Upload Artifact to Amazon S3

After successful packaging, Jenkins uploads the WAR file to Amazon S3.

target/java-web-app.war
          |
          v
      Amazon S3
          |
          v
artifacts/
└── java-web-app/
    └── <BUILD_NUMBER>/
        └── java-web-app.war

Amazon S3 acts as the centralized artifact repository for the CI/CD pipeline.

---

### 7. Deploy to Testing Environment

Jenkins retrieves the WAR artifact from Amazon S3 and deploys it to the Testing Tomcat server through the Tomcat Manager API.

Amazon S3
    |
    v
java-web-app.war
    |
    v
Testing Tomcat
    |
    v
/java-web-app

The Testing environment is used as the first deployment environment before Production.

---

### 8. Production Deployment Approval

After successful Testing deployment, Jenkins pauses the pipeline and waits for manual approval.

Testing Deployment
        |
        v
Production Approval
        |
        +---- ABORT ----> Stop Production Deployment
        |
        v
      APPROVE
        |
        v
Production Deployment

Production deployment proceeds only after explicit manual approval.

---

### 9. Deploy to Production Environment

After approval, Jenkins retrieves the same WAR artifact from Amazon S3 and deploys it to the Production Tomcat server.

Amazon S3
    |
    v
Same WAR Artifact
    |
    v
Production Tomcat
    |
    v
/java-web-app

The application is not rebuilt separately for Production.

---

## Build Once, Deploy the Same Artifact

One of the main DevOps concepts demonstrated in this project is artifact promotion.

                  Maven
                    |
                    v
             java-web-app.war
                    |
                    v
               Amazon S3
                /      \
               /        \
              v          v
          Testing    Production

The application is built once.

The generated WAR artifact is stored in Amazon S3.

The same artifact is then deployed to Testing and, after manual approval, to Production.

This provides consistency between environments and avoids rebuilding the application separately for Production.

---

## Artifact Management

Amazon S3 is used as the centralized artifact storage system.

Each Jenkins build stores the WAR artifact using the Jenkins build number.

Example:

artifacts/
└── java-web-app/
    ├── 1/
    │   └── java-web-app.war
    ├── 2/
    │   └── java-web-app.war
    └── 3/
        └── java-web-app.war

This creates a clear relationship between:

Jenkins Build
      |
      v
WAR Artifact
      |
      v
Amazon S3

The artifact can then be retrieved for deployment.

---

## Server Communication

### Jenkins → SonarQube

Jenkins-Server
      |
      | HTTP :9000
      v
SonarQube-Server

### SonarQube → Jenkins

SonarQube sends the Quality Gate result back to Jenkins through a webhook.

SonarQube
    |
    | Webhook
    v
Jenkins-Server

Webhook endpoint:

    /sonarqube-webhook/

Example:

    http://<JENKINS-PRIVATE-IP>:8080/sonarqube-webhook/

### Jenkins → Amazon S3

Jenkins
   |
   | AWS CLI
   v
IAM Role
   |
   v
Amazon S3

The Jenkins EC2 instance uses an IAM role for S3 access instead of storing AWS access keys inside the Jenkinsfile.

### Jenkins → Testing Tomcat

Jenkins-Server
      |
      | HTTP :8080
      v
Testing-Server

### Jenkins → Production Tomcat

Jenkins-Server
      |
      | HTTP :8080
      v
Production-Server

Private IP based communication is used between the AWS servers.

---

## Ports

| Service | Port |
|---|---:|
| Jenkins | 8080 |
| SonarQube | 9000 |
| Testing Tomcat | 8080 |
| Production Tomcat | 8080 |

---

## SonarQube Quality Gate

SonarQube is integrated into the Jenkins pipeline for static code analysis.

The pipeline waits for the SonarQube Quality Gate result before continuing.

Code
  |
  v
SonarQube Analysis
  |
  v
Quality Gate
  |
  +---- FAIL ----> Pipeline Stops
  |
  v
 PASS
  |
  v
Continue

This provides a quality control point before artifact packaging and deployment.

---

## Testing Environment

The application is deployed to the Testing Tomcat server after the WAR artifact is stored in Amazon S3.

Amazon S3
    |
    v
java-web-app.war
    |
    v
Testing Tomcat
    |
    v
/java-web-app

The Testing environment provides a separate deployment environment before Production release.

---

## Production Environment

Production deployment is protected by a manual approval stage.

S3 Artifact
     |
     v
Testing Deployment
     |
     v
Production Approval
     |
     v
Production Deployment
     |
     v
Production Tomcat

Only the approved artifact from Amazon S3 is deployed to Production.

---

## Security

Sensitive credentials are not stored directly inside the Jenkinsfile.

Jenkins Credentials are used for:

- SonarQube authentication
- Testing Tomcat authentication
- Production Tomcat authentication

Credential IDs used by the pipeline:

    sonarqube-token
    tomcat-testing
    tomcat-production

AWS S3 access is handled through the IAM role attached to the Jenkins EC2 instance.

Passwords, tokens, private keys, AWS access keys, and other secrets should never be committed to GitHub.

---

## Jenkins Credentials

Jenkins
   |
   +-- Credentials
         |
         +-- sonarqube-token
         |
         +-- tomcat-testing
         |
         +-- tomcat-production

---

## Jenkins Pipeline

The pipeline is implemented using a Jenkins Declarative Pipeline.

The main stages are:

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

## Jenkinsfile

The complete CI/CD automation is defined in:

    Jenkinsfile

The Jenkins job loads the pipeline directly from the GitHub repository.

---

## GitHub Repository Structure

enterprise-java-devops-cicd/
│
├── README.md
├── Jenkinsfile
├── pom.xml
├── architecture.md
│
├── docs/
│   ├── deployment-guide.md
│   ├── troubleshooting.md
│   │
│   └── screenshots/
│       ├── 01-aws-ec2-infrastructure.png
│       ├── 02-security-groups.png
│       ├── 03-github-source-repository
│       ├── 04-maven-pom.png
│       ├── 05-jenkins-dashboard.png
│       ├── 06-jenkins-pipeline-configuration.png
│       ├── 07-jenkins-credentials.png
│       ├── 08-sonarqube-project.png
│       ├── 09-sonarqube-webhook.png
│       ├── 10-pipeline-stage-view.png
│       ├── 11-source-code-checkout.png
│       ├── 12-maven-build.png
│       ├── 13-sonarqube-analysis.png
│       ├── 14-quality-gate-validation.png
│       ├── 15-war-artifact-packaging.png
│       ├── 16-s3-artifact.png
│       ├── 17-testing-deployment.png
│       ├── 18-testing-tomcat.png
│       ├── 19-testing-website.png
│       ├── 20-production-approval.png
│       ├── 21-production-deployment.png
│       ├── 22-production-tomcat.png
│       ├── 23-production-website.png
│       ├── 24-final-pipeline.png
│       └── 25-testing-production-comparison.png
│
├── scripts/
    ├── jenkins-setup.sh
    ├── sonarqube-setup.sh
    └── tomcat-setup.sh

---

## Screenshots

The `screenshots/` directory contains evidence of the complete DevOps implementation.

The screenshots demonstrate:

- AWS EC2 infrastructure
- Security Groups
- GitHub source repository
- Maven configuration
- Jenkins credentials
- SonarQube project
- SonarQube webhook
- Jenkins pipeline execution
- Source code checkout
- Maven build
- SonarQube analysis
- Quality Gate validation
- WAR artifact packaging
- Amazon S3 artifact
- Testing deployment
- Testing Tomcat
- Testing application
- Production approval
- Production deployment
- Production Tomcat
- Production application
- Final successful pipeline
- Testing and Production application comparison

---

## DevOps Concepts Demonstrated

- Continuous Integration
- Continuous Delivery
- Jenkins Declarative Pipeline
- Git and GitHub
- Maven Build Automation
- SonarQube Static Code Analysis
- SonarQube Quality Gates
- WAR Artifact Generation
- Amazon S3 Artifact Storage
- Artifact Versioning
- Build Once, Deploy the Same Artifact
- Apache Tomcat Deployment
- Testing and Production Environments
- Manual Production Approval
- Jenkins Credentials
- AWS IAM Roles
- AWS EC2
- Linux Server Administration
- Shell Scripting
- cURL
- CI/CD Automation

---

## Project Highlights

### Multi-Server Architecture

The CI/CD environment is separated into dedicated AWS EC2 servers.

                    AWS
                     |
       +-------------+-------------+
       |             |             |
       v             v             v
    Jenkins      SonarQube      Tomcat
       |             |          Servers
       |             |          /      \
       |             |         v        v
       |             |      Testing  Production
       |             |
       +-------------+
              |
              v
          Amazon S3
        Artifact Store

---

### Quality Control

The application source code is analyzed using SonarQube before the WAR artifact is packaged.

Maven Build
    |
    v
SonarQube Analysis
    |
    v
Quality Gate
    |
    +---- FAIL ----> Pipeline Stops
    |
    v
Package WAR

---

### Centralized Artifact Storage

Amazon S3 acts as the artifact repository.

Maven
  |
  v
WAR Artifact
  |
  v
Amazon S3

The artifact is stored independently from the Jenkins workspace.

---

### Artifact Promotion

The same artifact is used for Testing and Production.

                java-web-app.war
                       |
                       v
                  Amazon S3
                   /      \
                  /        \
                 v          v
             Testing    Production

This demonstrates artifact-based deployment instead of rebuilding the application for each environment.

---

### Production Protection

Production deployment requires explicit manual approval.

Testing
   |
   v
Manual Approval
   |
   +---- Abort ----> Stop
   |
   v
Production

This provides a controlled release process between Testing and Production.

---

## Final Pipeline Result

The completed pipeline successfully demonstrates:

Source Code Checkout              ✓
Maven Build                       ✓
Code Quality Analysis             ✓
Quality Gate Validation            ✓
WAR Artifact Packaging              ✓
Upload Artifact to S3               ✓
Deploy to Testing Environment       ✓
Production Deployment Approval      ✓
Deploy to Production Environment    ✓

Final Jenkins result:

    Finished: SUCCESS

---

## End-to-End DevOps Workflow

Source Code
     |
     v
GitHub
     |
     v
Jenkins
     |
     v
Maven Build
     |
     v
SonarQube Analysis
     |
     v
Quality Gate
     |
     v
WAR Package
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
     |
     v
Live Application

---

## Why This Project Is a DevOps Project

This project demonstrates the complete software delivery lifecycle from source code to production deployment.

It combines:

Source Control
      +
Build Automation
      +
Code Quality
      +
Artifact Management
      +
Deployment Automation
      +
Environment Promotion
      +
Release Approval

The project therefore demonstrates practical DevOps concepts rather than being limited to a single AWS service or Jenkins configuration.

---

## Conclusion

This project demonstrates an enterprise-style DevOps CI/CD workflow for a Java Web Application running on AWS.

The complete delivery process is automated from source code checkout to production deployment:

GitHub
   |
   v
Jenkins
   |
   v
Maven Build
   |
   v
SonarQube
   |
   v
Quality Gate
   |
   v
WAR Artifact
   |
   v
Amazon S3
   |
   v
Testing Tomcat
   |
   v
Manual Approval
   |
   v
Production Tomcat
   |
   v
Live Application

The project provides practical experience with AWS EC2, Amazon S3, Linux, Git, GitHub, Jenkins, Maven, SonarQube, Apache Tomcat, CI/CD automation, Quality Gates, artifact management, deployment automation, environment promotion, and production release management.

The project follows the DevOps delivery model:

**Code → Build → Analyze → Validate → Package → Store → Deploy → Approve → Release**

---

## Author

**Samir Shaikh**

AWS Cloud & DevOps Engineer

AWS | Linux | Jenkins | Docker | Kubernetes | Terraform | Git | CI/CD
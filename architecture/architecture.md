# Enterprise Java DevOps CI/CD Architecture

## Overview

This project implements an enterprise-style DevOps CI/CD pipeline for a Maven-based Java Web Application.

The pipeline uses GitHub for source code management, Jenkins for CI/CD automation, Maven for application build and packaging, SonarQube for code quality analysis, Amazon S3 for artifact storage, and Apache Tomcat for Testing and Production deployments.

The architecture follows the DevOps principle:

**Build Once → Store Artifact → Deploy the Same Artifact**

---

## Complete CI/CD Architecture

GitHub
   |
   v
Jenkins EC2 Server
   |
   +--------------------+
   |                    |
   v                    v
Maven Build        SonarQube Server
   |                    |
   |                    v
   |              Code Analysis
   |                    |
   |              Quality Gate
   |                    |
   +---------+----------+
             |
             v
       WAR Packaging
             |
             v
      Amazon S3
    Artifact Storage
             |
             v
    Testing Tomcat
       EC2 Server
             |
             v
   Manual Production
       Approval
             |
             v
   Production Tomcat
       EC2 Server
             |
             v
      Live Application

---

## CI/CD Pipeline Flow

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
Production Deployment Approval
   |
   +---- ABORT ----> Production Deployment Stops
   |
   v
Deploy to Production Environment
   |
   v
Application Live

---

## Pipeline Stages

1. Source Code Checkout
2. Maven Build
3. Code Quality Analysis
4. Quality Gate Validation
5. WAR Artifact Packaging
6. Upload Artifact to S3
7. Deploy to Testing Environment
8. Production Deployment Approval
9. Deploy to Production Environment

---

## 1. Source Code Checkout

Jenkins retrieves the Java Web Application source code from the GitHub repository.

GitHub
   |
   v
Jenkins Workspace

The pipeline uses the main branch of the repository.

---

## 2. Maven Build

Maven compiles the Java source code.

Java Source Code
       |
       v
     Maven
       |
       v
Compiled Application

Command:

    mvn clean compile

This stage verifies that the Java application can be successfully compiled.

---

## 3. SonarQube Code Quality Analysis

Jenkins sends the application source code to SonarQube for static code analysis.

Jenkins
   |
   v
SonarQube
   |
   v
Code Quality Analysis

SonarQube Project:

    java-web-app

The analysis helps identify code quality issues before the application is packaged and deployed.

---

## 4. Quality Gate Validation

After SonarQube analysis, Jenkins waits for the Quality Gate result.

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

## 5. WAR Artifact Packaging

Maven packages the Java Web Application into a WAR file.

Java Application
       |
       v
     Maven
       |
       v
java-web-app.war

Command:

    mvn package -DskipTests

Generated artifact:

    target/java-web-app.war

The WAR file is the deployable application artifact.

---

## 6. Upload Artifact to Amazon S3

After successful WAR packaging, Jenkins uploads the artifact to Amazon S3.

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

Amazon S3 acts as the centralized artifact storage location.

---

## 7. Deploy to Testing Environment

Jenkins downloads the WAR artifact from Amazon S3 and deploys it to the Testing Tomcat server.

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

The deployment is performed through the Apache Tomcat Manager API.

---

## 8. Production Deployment Approval

After successful Testing deployment, Jenkins pauses the pipeline and waits for manual approval.

Testing Deployment
        |
        v
Production Approval
        |
     +--+--+
     |     |
 APPROVE  ABORT
     |     |
     v     v
Production Pipeline
Deployment  Stops

Production deployment proceeds only after explicit approval.

---

## 9. Deploy to Production Environment

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

# Build Once → Store → Deploy

The project follows the DevOps artifact promotion model.

Maven Build
     |
     v
java-web-app.war
     |
     v
Amazon S3
    / \
   /   \
  v     v
Testing Production

The application is built once.

The generated WAR artifact is stored in Amazon S3.

The same artifact is used for Testing and Production deployment.

This helps maintain consistency between environments.

---

# Artifact Lifecycle

Source Code
     |
     v
GitHub
     |
     v
Jenkins
     |
     v
Maven
     |
     v
WAR Artifact
     |
     v
Amazon S3
     |
     +-------------+
     |             |
     v             v
 Testing      Production

---

# AWS Infrastructure

The project uses four Amazon EC2 instances.

AWS
 |
 +-- Jenkins Server
 |      |
 |      +-- Jenkins
 |
 +-- SonarQube Server
 |      |
 |      +-- SonarQube
 |
 +-- Testing Server
 |      |
 |      +-- Apache Tomcat
 |
 +-- Production Server
        |
        +-- Apache Tomcat

Amazon S3 is used separately as the centralized artifact storage service.

---

# Server Communication

## Jenkins to SonarQube

Jenkins EC2 Server
        |
        | TCP 9000
        v
SonarQube EC2 Server

Jenkins communicates with SonarQube for code quality analysis.

---

## SonarQube to Jenkins

SonarQube
    |
    | Webhook
    v
Jenkins

Webhook endpoint:

    /sonarqube-webhook/

Example:

    http://<JENKINS-PRIVATE-IP>:8080/sonarqube-webhook/

The webhook allows Jenkins to receive the Quality Gate result from SonarQube.

---

## Jenkins to Amazon S3

Jenkins EC2 Server
        |
        | AWS CLI
        v
IAM Role
        |
        v
Amazon S3

The Jenkins EC2 instance uses an IAM role for S3 access.

AWS access keys are not stored inside the Jenkinsfile.

---

## Jenkins to Testing Tomcat

Jenkins EC2 Server
        |
        | TCP 8080
        v
Testing EC2 Server
        |
        v
Apache Tomcat

---

## Jenkins to Production Tomcat

Jenkins EC2 Server
        |
        | TCP 8080
        v
Production EC2 Server
        |
        v
Apache Tomcat

Private IP based communication is used between the AWS servers.

---

# Port Architecture

| Component | Port | Purpose |
|---|---:|---|
| Jenkins | 8080 | Jenkins Web Interface and Pipeline |
| SonarQube | 9000 | SonarQube Web Interface and Analysis |
| Testing Tomcat | 8080 | Testing Application |
| Production Tomcat | 8080 | Production Application |

---

# Security Group Communication

The EC2 instances communicate through controlled Security Group rules.

Jenkins Security Group
        |
        +------ TCP 9000 ------> SonarQube Security Group
        |
        +------ TCP 8080 ------> Testing Security Group
        |
        +------ TCP 8080 ------> Production Security Group

SonarQube also communicates back to Jenkins for the Quality Gate webhook.

SonarQube Security Group
        |
        +------ TCP 8080 ------> Jenkins Security Group

Only required communication paths should be allowed.

---

# IAM and Amazon S3 Access

The Jenkins EC2 instance uses an IAM role to communicate with Amazon S3.

Jenkins EC2
     |
     v
Attached IAM Role
     |
     v
IAM Permissions
     |
     v
Amazon S3

The IAM role provides Jenkins with the required S3 permissions without storing AWS access keys in the project.

---

# Jenkins Credential Architecture

Jenkins Credentials are used for services that require authentication.

Jenkins
   |
   +-- sonarqube-token
   |
   +-- tomcat-testing
   |
   +-- tomcat-production

The credentials are referenced by their credential IDs inside the Jenkinsfile.

Passwords and tokens are not hard-coded into the repository.

---

# SonarQube Integration

Jenkins Pipeline
       |
       v
SonarQube Analysis
       |
       v
Quality Gate
       |
       v
Webhook
       |
       v
Jenkins

Jenkins waits for the Quality Gate result before continuing the pipeline.

---

# Testing Deployment Architecture

Amazon S3
    |
    v
java-web-app.war
    |
    v
Jenkins
    |
    v
Tomcat Manager API
    |
    v
Testing Tomcat
    |
    v
Java Web Application

---

# Production Deployment Architecture

Amazon S3
    |
    v
java-web-app.war
    |
    v
Jenkins
    |
    v
Manual Production Approval
    |
    v
Tomcat Manager API
    |
    v
Production Tomcat
    |
    v
Java Web Application

---

# Environment Promotion

The project contains separate Testing and Production environments.

Amazon S3
    |
    v
WAR Artifact
    |
    v
Testing Environment
    |
    v
Manual Approval
    |
    v
Production Environment

The Production environment receives the same approved WAR artifact stored in Amazon S3.

---

# Complete Deployment Workflow

Developer
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
    |
    v
Live Application

---

# DevOps Concepts Demonstrated

This architecture demonstrates:

- Source Code Management
- Continuous Integration
- Continuous Delivery
- Build Automation
- Code Quality Analysis
- SonarQube Quality Gates
- WAR Artifact Generation
- Artifact Management
- Amazon S3 Artifact Storage
- Artifact Versioning
- Build Once, Deploy the Same Artifact
- Multi-Environment Deployment
- Testing Environment
- Production Environment
- Manual Production Approval
- Deployment Automation
- Jenkins Pipeline Automation
- AWS EC2 Infrastructure
- IAM Role-Based Access
- Linux Server Administration
- Apache Tomcat Deployment
- GitHub Integration
- Shell Scripting
- cURL

---

# Final Architecture

                              GitHub
                                 |
                                 v
                    +-----------------------+
                    |       Jenkins         |
                    |      EC2 Server       |
                    +-----------+-----------+
                                |
              +-----------------+-----------------+
              |                                   |
              v                                   v
        +-----------+                       +-------------+
        |   Maven   |                       |  SonarQube  |
        |   Build   |                       |   Server    |
        +-----+-----+                       +------+------+
              |                                    |
              |                              Quality Gate
              |                                    |
              +----------------+-------------------+
                               |
                               v
                       WAR Artifact
                               |
                               v
                    +-------------------+
                    |    Amazon S3      |
                    | Artifact Storage  |
                    +---------+---------+
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
                    | Production Tomcat |
                    |    EC2 Server     |
                    +---------+---------+
                              |
                              v
                       Live Application

---

# Final Result

The architecture provides a complete DevOps delivery workflow:

CODE
  |
  v
BUILD
  |
  v
ANALYZE
  |
  v
VALIDATE
  |
  v
PACKAGE
  |
  v
STORE
  |
  v
DEPLOY TO TESTING
  |
  v
APPROVE
  |
  v
DEPLOY TO PRODUCTION
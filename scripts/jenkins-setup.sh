#!/bin/bash

# ============================================================
# Jenkins Server Setup
# Enterprise Java DevOps CI/CD Project
# ============================================================

set -e

echo "=========================================="
echo " Starting Jenkins Server Setup"
echo "=========================================="

# ------------------------------------------------------------
# 1. Update System Packages
# ------------------------------------------------------------

echo "[1/7] Updating system packages..."

sudo apt update
sudo apt upgrade -y


# ------------------------------------------------------------
# 2. Install Java
# ------------------------------------------------------------

echo "[2/7] Installing Java..."

sudo apt install openjdk-21-jdk -y

echo "Java version:"
java -version


# ------------------------------------------------------------
# 3. Install Required Utilities
# ------------------------------------------------------------

echo "[3/7] Installing required utilities..."

sudo apt install -y \
    git \
    curl \
    unzip


# ------------------------------------------------------------
# 4. Add Jenkins Repository
# ------------------------------------------------------------

echo "[4/7] Adding Jenkins repository..."

sudo mkdir -p /etc/apt/keyrings

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
| sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null


# ------------------------------------------------------------
# 5. Install Jenkins
# ------------------------------------------------------------

echo "[5/7] Installing Jenkins..."

sudo apt update

sudo apt install jenkins -y


# ------------------------------------------------------------
# 6. Start Jenkins
# ------------------------------------------------------------

echo "[6/7] Starting Jenkins service..."

sudo systemctl enable jenkins
sudo systemctl start jenkins


# ------------------------------------------------------------
# 7. Verify Installation
# ------------------------------------------------------------

echo "[7/7] Verifying Jenkins installation..."

sudo systemctl status jenkins --no-pager

echo ""
echo "=========================================="
echo " Jenkins Setup Completed"
echo "=========================================="

echo ""
echo "Jenkins URL:"
echo "http://<JENKINS-PUBLIC-IP>:8080"

echo ""
echo "Initial Jenkins Administrator Password:"
echo ""

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo ""
echo "=========================================="
echo " Next Steps"
echo "=========================================="
echo "1. Open Jenkins in your browser."
echo "2. Enter the initial administrator password."
echo "3. Install the suggested Jenkins plugins."
echo "4. Create the Jenkins administrator account."
echo "5. Configure Maven."
echo "6. Configure SonarQube."
echo "7. Add Jenkins Credentials."
echo "8. Configure the Pipeline job."
echo "=========================================="
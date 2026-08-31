#!/bin/bash

# ============================================================
# Apache Tomcat Server Setup
# Enterprise Java DevOps CI/CD Project
# ============================================================

set -e

echo "=========================================="
echo " Starting Tomcat Server Setup"
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
# 3. Create Tomcat User
# ------------------------------------------------------------

echo "[3/7] Creating Tomcat user..."

if ! id "tomcat" >/dev/null 2>&1; then
    sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat
fi


# ------------------------------------------------------------
# 4. Download and Install Tomcat
# ------------------------------------------------------------

echo "[4/7] Downloading Apache Tomcat..."

TOMCAT_VERSION="10.1.46"
TOMCAT_TAR="apache-tomcat-${TOMCAT_VERSION}.tar.gz"
TOMCAT_URL="https://dlcdn.apache.org/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/${TOMCAT_TAR}"

cd /tmp

if [ ! -f "$TOMCAT_TAR" ]; then
    wget "$TOMCAT_URL"
fi

sudo mkdir -p /opt/tomcat

sudo tar -xzf "$TOMCAT_TAR" \
    -C /opt/tomcat \
    --strip-components=1

sudo chown -R tomcat:tomcat /opt/tomcat

sudo chmod +x /opt/tomcat/bin/*.sh


# ------------------------------------------------------------
# 5. Create Tomcat Systemd Service
# ------------------------------------------------------------

echo "[5/7] Creating Tomcat systemd service..."

JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"

sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]

Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=${JAVA_HOME}"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF


# ------------------------------------------------------------
# 6. Start Tomcat
# ------------------------------------------------------------

echo "[6/7] Starting Tomcat..."

sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat


# ------------------------------------------------------------
# 7. Verify Installation
# ------------------------------------------------------------

echo "[7/7] Verifying Tomcat..."

sleep 5

sudo systemctl status tomcat


echo ""
echo "=========================================="
echo " Tomcat Setup Completed"
echo "=========================================="

echo ""
echo "Tomcat URL:"
echo "http://<SERVER-PUBLIC-IP>:8080"

echo ""
echo "Tomcat Installation:"
echo "/opt/tomcat"

echo ""
echo "=========================================="
echo " Next Steps"
echo "=========================================="
echo "1. Configure Tomcat Manager."
echo "2. Create the Tomcat Manager user."
echo "3. Configure manager application access."
echo "4. Verify port 8080 in the Security Group."
echo "5. Test the Tomcat server from Jenkins."
echo "6. Configure Jenkins Tomcat credentials."
echo "=========================================="
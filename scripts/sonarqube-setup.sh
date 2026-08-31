#!/bin/bash

# ============================================================
# SonarQube Server Setup
# Enterprise Java DevOps CI/CD Project
# ============================================================

set -e

echo "=========================================="
echo " Starting SonarQube Server Setup"
echo "=========================================="

# ------------------------------------------------------------
# 1. Update System Packages
# ------------------------------------------------------------

echo "[1/8] Updating system packages..."

sudo apt update
sudo apt upgrade -y


# ------------------------------------------------------------
# 2. Install Java
# ------------------------------------------------------------

echo "[2/8] Installing Java..."

sudo apt install openjdk-21-jdk -y

echo "Java version:"
java -version


# ------------------------------------------------------------
# 3. Create SonarQube User
# ------------------------------------------------------------

echo "[3/8] Creating SonarQube user..."

if ! id "sonarqube" >/dev/null 2>&1; then
    sudo useradd -m -s /bin/bash sonarqube
fi


# ------------------------------------------------------------
# 4. Install Required Packages
# ------------------------------------------------------------

echo "[4/8] Installing required packages..."

sudo apt install -y \
    unzip \
    wget \
    curl


# ------------------------------------------------------------
# 5. Download SonarQube
# ------------------------------------------------------------

echo "[5/8] Downloading SonarQube..."

SONAR_VERSION="25.12.0.112802"
SONAR_ZIP="sonarqube-${SONAR_VERSION}.zip"
SONAR_URL="https://binaries.sonarsource.com/Distribution/sonarqube/${SONAR_ZIP}"

cd /tmp

if [ ! -f "$SONAR_ZIP" ]; then
    wget "$SONAR_URL"
fi

sudo unzip -q "$SONAR_ZIP" -d /opt/

sudo mv "/opt/sonarqube-${SONAR_VERSION}" /opt/sonarqube

sudo chown -R sonarqube:sonarqube /opt/sonarqube


# ------------------------------------------------------------
# 6. Configure SonarQube Service
# ------------------------------------------------------------

echo "[6/8] Creating SonarQube systemd service..."

sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<'EOF'
[Unit]
Description=SonarQube Service
After=network.target

[Service]
Type=forking

User=sonarqube
Group=sonarqube

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

Restart=always

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF


# ------------------------------------------------------------
# 7. Start SonarQube
# ------------------------------------------------------------

echo "[7/8] Starting SonarQube..."

sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube


# ------------------------------------------------------------
# 8. Verify Installation
# ------------------------------------------------------------

echo "[8/8] Verifying SonarQube..."

sleep 10

sudo systemctl status sonarqube --no-pager


echo ""
echo "=========================================="
echo " SonarQube Setup Completed"
echo "=========================================="

echo ""
echo "SonarQube URL:"
echo "http://<SONARQUBE-PUBLIC-IP>:9000"

echo ""
echo "Default Login:"
echo "Username: admin"
echo "Password: admin"

echo ""
echo "Important:"
echo "Change the default admin password after first login."

echo ""
echo "=========================================="
echo " Next Steps"
echo "=========================================="
echo "1. Open SonarQube in your browser."
echo "2. Login using the admin account."
echo "3. Change the default password."
echo "4. Create the java-web-app project."
echo "5. Generate a SonarQube authentication token."
echo "6. Add the token to Jenkins Credentials."
echo "7. Configure the SonarQube Quality Gate."
echo "8. Configure the SonarQube webhook."
echo "=========================================="
#!/bin/bash

set -e

# ============================================================
# SonarQube Server Installation
# Ubuntu EC2
# ============================================================

SONAR_VERSION="26.9.0.129388"
SONAR_USER="sonarqube"
SONAR_HOME="/opt/sonarqube"
SONAR_ZIP="sonarqube-${SONAR_VERSION}.zip"
SONAR_URL="https://binaries.sonarsource.com/Distribution/sonarqube/${SONAR_ZIP}"

echo "=========================================="
echo " SonarQube Installation Started"
echo "=========================================="

# ------------------------------------------------------------
# 1. Install Required Packages
# ------------------------------------------------------------

echo "[1/9] Installing required packages..."

sudo apt update

sudo apt install -y \
    openjdk-21-jdk \
    unzip \
    wget \
    curl

echo ""
echo "Java version:"
java -version


# ------------------------------------------------------------
# 2. Create SonarQube User
# ------------------------------------------------------------

echo ""
echo "[2/9] Creating SonarQube user..."

if ! id "$SONAR_USER" >/dev/null 2>&1; then

    sudo useradd \
        --system \
        --home "$SONAR_HOME" \
        --shell /bin/bash \
        "$SONAR_USER"

    echo "SonarQube user created."

else

    echo "SonarQube user already exists."

fi


# ------------------------------------------------------------
# 3. Download SonarQube
# ------------------------------------------------------------

echo ""
echo "[3/9] Downloading SonarQube ${SONAR_VERSION}..."

cd /tmp

rm -f "$SONAR_ZIP"

wget \
    --show-progress \
    -O "$SONAR_ZIP" \
    "$SONAR_URL"


# ------------------------------------------------------------
# 4. Verify Download
# ------------------------------------------------------------

echo ""
echo "[4/9] Verifying downloaded file..."

if [ ! -s "$SONAR_ZIP" ]; then
    echo "ERROR: SonarQube ZIP download failed."
    exit 1
fi

echo "Download successful."

ls -lh "$SONAR_ZIP"


# ------------------------------------------------------------
# 5. Extract SonarQube
# ------------------------------------------------------------

echo ""
echo "[5/9] Installing SonarQube..."

sudo rm -rf "$SONAR_HOME"
sudo rm -rf "/opt/sonarqube-${SONAR_VERSION}"

sudo unzip -q "$SONAR_ZIP" -d /opt/

sudo mv \
    "/opt/sonarqube-${SONAR_VERSION}" \
    "$SONAR_HOME"


# ------------------------------------------------------------
# 6. Configure Permissions
# ------------------------------------------------------------

echo ""
echo "[6/9] Configuring permissions..."

sudo chown -R \
    "$SONAR_USER:$SONAR_USER" \
    "$SONAR_HOME"

sudo chmod +x \
    "$SONAR_HOME/bin/linux-x86-64/sonar.sh"


# ------------------------------------------------------------
# 7. Create systemd Service
# ------------------------------------------------------------

echo ""
echo "[7/9] Creating SonarQube systemd service..."

sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOF

[Unit]
Description=SonarQube Service
After=network.target

[Service]
Type=forking

User=$SONAR_USER
Group=$SONAR_USER

ExecStart=$SONAR_HOME/bin/linux-x86-64/sonar.sh start
ExecStop=$SONAR_HOME/bin/linux-x86-64/sonar.sh stop

Restart=on-failure
RestartSec=10

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target

EOF


# ------------------------------------------------------------
# 8. Start SonarQube
# ------------------------------------------------------------

echo ""
echo "[8/9] Starting SonarQube..."

sudo systemctl daemon-reload

sudo systemctl enable sonarqube

sudo systemctl start sonarqube


# ------------------------------------------------------------
# 9. Wait and Verify
# ------------------------------------------------------------

echo ""
echo "[9/9] Waiting for SonarQube..."

for i in {1..18}
do

    echo "Checking SonarQube... ($i/18)"

    if curl -sf \
        http://localhost:9000/api/system/status \
        | grep -q '"status":"UP"'
    then

        echo ""
        echo "=========================================="
        echo " SonarQube is UP!"
        echo "=========================================="

        break

    fi

    sleep 10

done


echo ""
echo "=========================================="
echo " Final Verification"
echo "=========================================="

echo ""
echo "Service Status:"
sudo systemctl --no-pager status sonarqube || true

echo ""
echo "Port 9000:"
sudo ss -lntp | grep ':9000' || true

echo ""
echo "SonarQube Health:"
curl -s http://localhost:9000/api/system/status || true

echo ""
echo "=========================================="
echo " Installation Completed"
echo "=========================================="

echo ""
echo "Open SonarQube:"
echo ""
echo "http://<EC2-PUBLIC-IP>:9000"

echo ""
echo "Default Login:"
echo "Username: admin"
echo "Password: admin"

echo ""
echo "Next Steps:"
echo "1. Open port 9000 in AWS Security Group."
echo "2. Open SonarQube in browser."
echo "3. Login with admin/admin."
echo "4. Change the default password."
echo "5. Create your project."
echo "6. Generate SonarQube token."
echo "7. Add token to Jenkins Credentials."
echo "8. Configure SonarQube in Jenkins."
echo "9. Configure Quality Gate."
echo "10. Configure SonarQube Webhook."

echo ""
echo "=========================================="

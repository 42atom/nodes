#!/bin/bash
apt install unzip
apt install ufw

# snell v3
wget https://github.com/icpz/open-snell/releases/download/v3.0.1/snell-server-linux-amd64.zip

unzip ./snell-server-linux-amd64.zip

# 定义文件路径
CONFIG_FILE="./snell-server.conf"

# 写入内容到文件
cat > "$CONFIG_FILE" <<EOL
[snell-server]
listen = 0.0.0.0:45857
psk = 9Wn8e0WW0Vso2hntTOkxkqDBk6S5Mxa
obfs = http
ipv6 = false
EOL

# 显示提示信息
echo "Configuration file '$CONFIG_FILE' created successfully."

ufw allow 45857

# 定义变量
SERVICE_FILE="/lib/systemd/system/snell.service"
SNELL_SERVER_SRC="./snell-server"
SNELL_SERVER_BIN="/usr/local/bin/snell-server"
SNELL_CONFIG_SRC="./snell-server.conf"
SNELL_CONFIG_DEST="/etc/snell-server.conf"

# 创建 snell.service 文件
echo "Creating $SERVICE_FILE..."
sudo bash -c "cat > $SERVICE_FILE" << 'EOF'
[Unit]
Description=Snell Proxy Service
After=network.target

[Service]
Type=simple
User=nobody
Group=nogroup
ExecStart=/usr/local/bin/snell-server -c /etc/snell-server.conf
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 重新加载系统守护程序
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# 移动 snell-server 到 /usr/local/bin/ 并添加可执行权限
echo "Moving snell-server to $SNELL_SERVER_BIN..."
sudo mv $SNELL_SERVER_SRC $SNELL_SERVER_BIN
sudo chmod +x $SNELL_SERVER_BIN

# 移动 snell-server.conf 到 /etc/
echo "Moving snell-server.conf to $SNELL_CONFIG_DEST..."
sudo mv $SNELL_CONFIG_SRC $SNELL_CONFIG_DEST

# 启用服务自动启动
echo "Enabling snell.service..."
sudo systemctl enable snell.service

# 启动 snell 服务
echo "Starting snell.service..."
sudo systemctl start snell.service

# 验证服务成功启动
echo "Checking snell.service status..."
sudo systemctl status snell.service

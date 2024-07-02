#!/bin/bash

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

#!/bin/bash
set -e

echo "=== Cài đặt các gói phụ thuộc và thêm khóa GPG chính thức của Docker ==="
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "=== Thêm nguồn apt của Docker ==="
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu resolute stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "=== Cập nhật apt và cài đặt Docker + Docker Compose ==="
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== Thêm user hiện tại vào group docker ==="
sudo usermod -aG docker $USER

echo "=== Xác minh cài đặt ==="
docker --version
docker compose version

echo "=== HOÀN THÀNH ==="

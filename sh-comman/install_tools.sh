#!/bin/bash
set -e

echo "=== [1/6] Cập nhật danh sách gói hệ thống ==="
sudo apt update

echo "=== [2/6] Cài đặt OpenJDK 17 và cấu hình JAVA_HOME ==="
sudo apt install -y openjdk-17-jdk openjdk-17-jre
# Cấu hình JAVA_HOME vào ~/.bashrc
if ! grep -q "JAVA_HOME" ~/.bashrc; then
  echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
  echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
  echo "Đã thêm JAVA_HOME và PATH vào ~/.bashrc"
else
  echo "JAVA_HOME đã tồn tại trong ~/.bashrc"
fi

echo "=== [3/6] Cài đặt Maven và cấu hình MAVEN_HOME ==="
sudo apt install -y maven
# Cấu hình MAVEN_HOME vào ~/.bashrc
if ! grep -q "MAVEN_HOME" ~/.bashrc; then
  echo 'export MAVEN_HOME=/usr/share/maven' >> ~/.bashrc
  echo 'export PATH=$MAVEN_HOME/bin:$PATH' >> ~/.bashrc
  echo "Đã thêm MAVEN_HOME và PATH vào ~/.bashrc"
else
  echo "MAVEN_HOME đã tồn tại trong ~/.bashrc"
fi

echo "=== [4/6] Cài đặt Node.js 22 LTS ==="
sudo apt install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update
sudo apt install -y nodejs

echo "=== [5/6] Cài đặt PostgreSQL 17 ==="
sudo apt install -y postgresql-common
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
sudo apt update
sudo apt install -y postgresql-17 postgresql-client-17

echo "=== Cấu hình mật khẩu PostgreSQL ==="
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '12345';"

echo "=== [6/6] Cài đặt Docker & Docker Compose ==="
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu resolute stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Thêm user vào group docker
sudo usermod -aG docker $USER

echo "=== XÁC MINH CÀI ĐẶT ==="
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
export MAVEN_HOME=/usr/share/maven
export PATH=$MAVEN_HOME/bin:$PATH

echo "Java version:"
java -version || true
echo "Maven version:"
mvn -version || true
echo "Node.js version:"
node -v || true
echo "npm version:"
npm -v || true
echo "PostgreSQL version:"
psql --version || true

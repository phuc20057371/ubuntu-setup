# Kế hoạch Cài đặt Công cụ Phát triển (Development Tools Installation Plan)

Kế hoạch này chi tiết các bước cài đặt và cấu hình Java 17, Maven, Node.js 22 LTS, PostgreSQL 17, cùng với Docker và Docker Compose trên hệ điều hành Ubuntu 26.04 LTS của bạn.

---

## 📋 Danh sách các công cụ cần cài đặt

| Công cụ | Phiên bản | Cấu hình bổ sung | Phương thức cài đặt |
| :--- | :--- | :--- | :--- |
| **Java** | 17 LTS (OpenJDK) | Thiết lập `JAVA_HOME` & `PATH` | APT (Ubuntu Universe) |
| **Maven** | Bản mới nhất (3.9.x) | Thiết lập `MAVEN_HOME` & `PATH` | APT (Ubuntu Universe) |
| **Node.js & npm**| 22.x LTS | Trình quản lý gói npm đi kèm | NodeSource Repository |
| **PostgreSQL** | 17 | Đặt mật khẩu user `postgres` thành `12345` | PGDG (Official PostgreSQL Repo) |
| **Docker & Compose**| Bản mới nhất | Thêm user vào group `docker` để chạy không cần sudo | Kho lưu trữ chính thức của Docker |

---

## 🛠️ Chi tiết các bước thực hiện

### Bước 1: Cập nhật hệ thống
Đảm bảo danh sách gói của hệ thống được cập nhật mới nhất.
```bash
sudo apt update && sudo apt upgrade -y
```

### Bước 2: Cài đặt Java 17 LTS & Cấu hình `JAVA_HOME`
1. Cài đặt OpenJDK 17:
   ```bash
   sudo apt install -y openjdk-17-jdk openjdk-17-jre
   ```
2. Thêm các biến môi trường vào `~/.bashrc` để tự động kích hoạt khi mở terminal mới:
   ```bash
   # Kiểm tra và thêm JAVA_HOME
   if ! grep -q "JAVA_HOME" ~/.bashrc; then
     echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
     echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
   fi
   ```

### Bước 3: Cài đặt Maven & Cấu hình `MAVEN_HOME`
1. Cài đặt Apache Maven:
   ```bash
   sudo apt install -y maven
   ```
2. Thêm biến môi trường `MAVEN_HOME` vào `~/.bashrc`:
   ```bash
   # Kiểm tra và thêm MAVEN_HOME
   if ! grep -q "MAVEN_HOME" ~/.bashrc; then
     echo 'export MAVEN_HOME=/usr/share/maven' >> ~/.bashrc
     echo 'export PATH=$MAVEN_HOME/bin:$PATH' >> ~/.bashrc
   fi
   ```

### Bước 4: Cài đặt Node.js 22 LTS & npm
Chúng ta sẽ sử dụng kho lưu trữ chính thức của **NodeSource** để cài đặt phiên bản Node.js 22 LTS ổn định và an toàn:
1. Cài đặt các gói phụ thuộc và thêm khóa GPG của NodeSource:
   ```bash
   sudo apt install -y ca-certificates curl gnupg
   sudo mkdir -p /etc/apt/keyrings
   curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
   ```
2. Thêm kho lưu trữ Node.js 22:
   ```bash
   echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
   ```
3. Cập nhật APT và cài đặt Node.js:
   ```bash
   sudo apt update && sudo apt install -y nodejs
   ```

### Bước 5: Cài đặt PostgreSQL 17 & Cấu hình Mật khẩu
Vì kho lưu trữ mặc định của Ubuntu 26.04 cung cấp PostgreSQL 18, chúng ta sẽ thêm kho lưu trữ chính thức của PostgreSQL (**PGDG**) để cài đặt đúng phiên bản 17 theo yêu cầu:
1. Cài đặt gói `postgresql-common` và chạy script tự động cấu hình kho lưu trữ:
   ```bash
   sudo apt install -y postgresql-common
   sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
   ```
2. Cập nhật APT và cài đặt PostgreSQL 17:
   ```bash
   sudo apt update && sudo apt install -y postgresql-17 postgresql-client-17
   ```
3. Đặt mật khẩu cho tài khoản `postgres` thành `12345`:
   ```bash
   sudo -u postgres psql -c "ALTER USER postgres PASSWORD '12345';"
   ```

### Bước 6: Cài đặt Docker & Docker Compose
1. Cài đặt các gói phụ thuộc và thêm khóa GPG chính thức của Docker:
   ```bash
   sudo apt install -y ca-certificates curl gnupg
   sudo install -m 0755 -d /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
   sudo chmod a+r /etc/apt/keyrings/docker.gpg
   ```
2. Thêm nguồn apt của Docker:
   ```bash
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
     $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
     sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```
3. Cập nhật apt và cài đặt Docker cùng các plugin (bao gồm Docker Compose):
   ```bash
   sudo apt update
   sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```
4. Thêm user hiện tại vào group `docker` để chạy Docker không cần sudo:
   ```bash
   sudo usermod -aG docker $USER
   ```

---

## 🚦 Kiểm tra sau cài đặt (Verification)
Sau khi cài đặt xong, chúng ta sẽ chạy các lệnh sau để kiểm tra:
* **Java**: `java -version` và `echo $JAVA_HOME`
* **Maven**: `mvn -version` và `echo $MAVEN_HOME`
* **Node.js & npm**: `node -v` và `npm -v`
* **PostgreSQL**: `psql --version` và kiểm tra đăng nhập bằng mật khẩu `12345`
* **Docker & Compose**: `docker --version` và `docker compose version`

---

> [!IMPORTANT]
> Sau khi cấu hình các biến môi trường (`JAVA_HOME`, `MAVEN_HOME`) vào `~/.bashrc`, bạn cần chạy lệnh `source ~/.bashrc` hoặc mở một Terminal mới để các cấu hình này có hiệu lực.

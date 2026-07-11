# KẾ HOẠCH SETUP HỆ THỐNG TOÀN DIỆN (COMPREHENSIVE SYSTEM SETUP PLAN)

Kế hoạch này tổng hợp toàn bộ các bước thiết lập và cấu hình hệ thống trên Ubuntu 26.04 LTS, bao gồm hai giai đoạn chính:
1. **Giai đoạn 1**: Gỡ bỏ hoàn toàn Snap (`snapd`) và cài đặt các giải pháp thay thế sạch hơn (**Flatpak** & **Firefox .deb chính thức**).
2. **Giai đoạn 2**: Cài đặt các công cụ phát triển phần mềm cơ bản (**Java 17 OpenJDK**, **Maven**, **Node.js 22 LTS**, **PostgreSQL 17**, và **Docker & Docker Compose**).

---

## 🛠️ PHẦN 1: GỠ BỎ SNAP & CẤU HÌNH THAY THẾ (Flatpak + Firefox .deb)

Để tối ưu hóa hiệu năng hệ thống và tránh các lỗi liên quan đến Snap, chúng ta tiến hành gỡ bỏ hoàn toàn hệ thống Snap và thay thế bằng các gói `.deb` và Flatpak.

### Bước 1.1: Sao lưu cấu hình Firefox hiện tại (Quan trọng)
Sao lưu bookmark, mật khẩu và dữ liệu cá nhân từ thư mục Snap của Firefox:
```bash
mkdir -p ~/Backup/firefox-profile
cp -r ~/snap/firefox/common/.mozilla/firefox/* ~/Backup/firefox-profile/
```

### Bước 1.2: Gỡ bỏ lần lượt tất cả các gói Snap
Gỡ bỏ các ứng dụng trước, sau đó gỡ các gói nền và cuối cùng là `snapd` để tránh xung đột phụ thuộc:
```bash
sudo snap remove --purge firefox
sudo snap remove --purge snap-store
sudo snap remove --purge desktop-security-center
sudo snap remove --purge firmware-updater
sudo snap remove --purge prompting-client
sudo snap remove --purge snapd-desktop-integration
sudo snap remove --purge gnome-46-2404
sudo snap remove --purge mesa-2404
sudo snap remove --purge gtk-common-themes
sudo snap remove --purge bare
sudo snap remove --purge core24
sudo snap remove --purge snapd
```

### Bước 1.3: Dừng dịch vụ và gỡ bỏ hoàn toàn snapd
1. Dừng và vô hiệu hóa các dịch vụ hệ thống của Snap:
   ```bash
   sudo systemctl stop snapd.service snapd.socket snapd.seeded.service
   sudo systemctl disable snapd.service snapd.socket snapd.seeded.service
   ```
2. Gỡ cài đặt triệt để gói `snapd` cùng cấu hình liên quan:
   ```bash
   sudo apt-get purge -y snapd
   ```
3. Xóa hoàn toàn các thư mục rác còn sót lại:
   ```bash
   sudo rm -rf /var/cache/snapd/
   sudo rm -rf /var/snap/
   sudo rm -rf /var/lib/snapd/
   rm -rf ~/snap
   ```

### Bước 1.4: Chặn Snap tự động cài đặt lại trong tương lai
Tạo file `/etc/apt/preferences.d/nosnap.pref` để ngăn chặn Ubuntu tự động cài đặt lại snapd khi cài đặt các ứng dụng qua `apt`:
```text
Package: snapd
Pin: release a=*
Pin-Priority: -10
```

### Bước 1.5: Cài đặt Firefox chính thức từ Mozilla PPA (bản .deb)
1. Thêm khóa PPA chính thức từ Mozilla:
   ```bash
   sudo install -d /etc/apt/keyrings
   wget -q https://packages.mozilla.org/apt/keyrings/packages.mozilla.org.asc -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
   ```
2. Thêm kho lưu trữ (repository) của Mozilla:
   ```bash
   echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
   ```
3. Thiết lập độ ưu tiên của Mozilla PPA để hệ thống chọn bản `.deb` thay vì bản giả lập của Ubuntu:
   Tạo file `/etc/apt/preferences.d/mozilla` với nội dung:
   ```text
   Package: *
   Pin: origin packages.mozilla.org
   Pin-Priority: 1000
   ```
4. Cập nhật danh sách gói và cài đặt Firefox:
   ```bash
   sudo apt-get update && sudo apt-get install -y firefox
   ```

### Bước 1.6: Cài đặt Flatpak và Flathub
Flatpak là trình quản lý ứng dụng dạng sandbox sạch sẽ, thay thế tối ưu cho Snap Store:
1. Cài đặt Flatpak:
   ```bash
   sudo apt-get install -y flatpak
   ```
2. Thêm kho ứng dụng Flathub:
   ```bash
   flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
   ```

---

## 💻 PHẦN 2: CÀI ĐẶT CÁC CÔNG CỤ PHÁT TRIỂN (Development Tools)

Sau khi dọn dẹp hệ thống, tiến hành cài đặt các công cụ phát triển phần mềm cần thiết.

### Bước 2.1: Cập nhật hệ thống
```bash
sudo apt update && sudo apt upgrade -y
```

### Bước 2.2: Cài đặt Java 17 LTS & Cấu hình `JAVA_HOME`
1. Cài đặt OpenJDK 17:
   ```bash
   sudo apt install -y openjdk-17-jdk openjdk-17-jre
   ```
2. Cấu hình biến môi trường trong `~/.bashrc`:
   ```bash
   if ! grep -q "JAVA_HOME" ~/.bashrc; then
     echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
     echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
   fi
   ```

### Bước 2.3: Cài đặt Apache Maven & Cấu hình `MAVEN_HOME`
1. Cài đặt Maven:
   ```bash
   sudo apt install -y maven
   ```
2. Cấu hình biến môi trường trong `~/.bashrc`:
   ```bash
   if ! grep -q "MAVEN_HOME" ~/.bashrc; then
     echo 'export MAVEN_HOME=/usr/share/maven' >> ~/.bashrc
     echo 'export PATH=$MAVEN_HOME/bin:$PATH' >> ~/.bashrc
   fi
   ```

### Bước 2.4: Cài đặt Node.js 22 LTS & npm
Sử dụng repository chính thức của **NodeSource** để có phiên bản 22.x LTS ổn định:
1. Cài đặt các gói phụ thuộc và thêm khóa GPG của NodeSource:
   ```bash
   sudo apt install -y ca-certificates curl gnupg
   sudo mkdir -p /etc/apt/keyrings
   curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
   ```
2. Thêm kho lưu trữ Node.js 22:
   ```bash
   echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null
   ```
3. Cập nhật danh sách gói và cài đặt Node.js:
   ```bash
   sudo apt update && sudo apt install -y nodejs
   ```

### Bước 2.5: Cài đặt PostgreSQL 17 & Cấu hình Mật khẩu
Sử dụng kho lưu trữ chính thức từ PostgreSQL (**PGDG**) để cài đặt đúng phiên bản 17:
1. Cài đặt gói hỗ trợ và thiết lập kho lưu trữ tự động:
   ```bash
   sudo apt install -y postgresql-common
   sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
   ```
2. Cập nhật danh sách gói và cài đặt PostgreSQL 17 cùng Client:
   ```bash
   sudo apt update && sudo apt install -y postgresql-17 postgresql-client-17
   ```
3. Thiết lập mật khẩu cho tài khoản quản trị mặc định `postgres` thành `12345`:
   ```bash
   sudo -u postgres psql -c "ALTER USER postgres PASSWORD '12345';"
   ```

### Bước 2.6: Cài đặt Docker Engine & Docker Compose
1. Cài đặt các gói phụ thuộc và thêm khóa GPG của Docker:
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
3. Cập nhật danh sách gói và cài đặt Docker Engine cùng Docker Compose plugin:
   ```bash
   sudo apt update
   sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```
4. Thêm tài khoản người dùng hiện tại vào nhóm `docker` để chạy Docker không cần lệnh `sudo`:
   ```bash
   sudo usermod -aG docker $USER
   ```

---

## 🚦 KIỂM TRA & KÍCH HOẠT HỆ THỐNG

### Bước 3.1: Kích hoạt các biến môi trường mới
Chạy lệnh sau hoặc mở một phiên Terminal mới để áp dụng các cấu hình môi trường vừa thiết lập:
```bash
source ~/.bashrc
```

### Bước 3.2: Lệnh kiểm tra phiên bản hoạt động
* **Java**: `java -version` và kiểm tra biến môi trường `echo $JAVA_HOME`
* **Maven**: `mvn -version` và kiểm tra biến môi trường `echo $MAVEN_HOME`
* **Node.js & npm**: `node -v` và `npm -v`
* **PostgreSQL**: `psql --version` (thử đăng nhập bằng: `psql -U postgres -h localhost`)
* **Docker & Compose**: `docker --version` và `docker compose version`

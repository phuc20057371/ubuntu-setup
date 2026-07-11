# Kế hoạch gỡ bỏ hoàn toàn Snap khỏi Ubuntu 26.04

Kế hoạch này sẽ hướng dẫn bạn gỡ bỏ hoàn toàn hệ thống Snap (`snapd`) cùng tất cả các ứng dụng Snap đang chạy (như Firefox, App Store), dọn dẹp các thư mục rác, thiết lập quy tắc chặn cài đặt lại và cài đặt các giải pháp thay thế như **Flatpak** và **Firefox (bản .deb chính thức từ Mozilla)**.

---

## 📋 Danh sách các Snap hiện có trên hệ thống của bạn:
Qua kiểm tra, hệ thống đang chạy các gói Snap sau:
* **Ứng dụng:** `firefox`, `snap-store`, `desktop-security-center`, `firmware-updater`, `prompting-client`, `snapd-desktop-integration`
* **Runtimes & Bases:** `gnome-46-2404`, `mesa-2404`, `gtk-common-themes`, `bare`, `core24`, `snapd`

---

## 🛠️ Các bước thực hiện chi tiết

### Bước 1: Sao lưu cấu hình Firefox (Quan trọng)
Vì Firefox đang chạy dưới dạng Snap, dữ liệu cá nhân của bạn (bookmarks, mật khẩu, lịch sử) nằm trong thư mục Snap. Hãy sao lưu chúng trước khi xóa:
```bash
mkdir -p ~/Backup/firefox-profile
cp -r ~/snap/firefox/common/.mozilla/firefox/* ~/Backup/firefox-profile/
```

### Bước 2: Gỡ bỏ lần lượt tất cả các Snap
Ta cần gỡ bỏ các ứng dụng trước, sau đó gỡ các gói nền và cuối cùng là `snapd` để tránh lỗi phụ thuộc:
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

### Bước 3: Dọn dẹp dịch vụ và gỡ bỏ hoàn toàn snapd
1. Dừng và vô hiệu hóa các dịch vụ hệ thống của Snap:
   ```bash
   sudo systemctl stop snapd.service snapd.socket snapd.seeded.service
   sudo systemctl disable snapd.service snapd.socket snapd.seeded.service
   ```
2. Gỡ cài đặt triệt để gói `snapd` và cấu hình liên quan:
   ```bash
   sudo apt-get purge -y snapd
   ```
3. Xóa các thư mục rác còn sót lại:
   ```bash
   sudo rm -rf /var/cache/snapd/
   sudo rm -rf /var/snap/
   sudo rm -rf /var/lib/snapd/
   rm -rf ~/snap
   ```

### Bước 4: Chặn Snap tự động cài đặt lại trong tương lai
Ubuntu có cơ chế tự động cài đặt lại Snap khi bạn chạy lệnh cài một số ứng dụng bằng `apt` (ví dụ: `apt install firefox`). Ta sẽ tạo một file cấu hình Apt Preference để chặn đứng hành vi này.

Tạo file `/etc/apt/preferences.d/nosnap.pref` với nội dung sau:
```text
Package: snapd
Pin: release a=*
Pin-Priority: -10
```

### Bước 5: Cài đặt Firefox chính thức từ Mozilla PPA (Thay thế Firefox Snap)
Vì Ubuntu mặc định không có gói `.deb` cho Firefox, chúng ta cần thêm PPA chính thức từ Mozilla để cài đặt:
1. Thêm khóa PPA:
   ```bash
   sudo install -d /etc/apt/keyrings
   wget -q https://packages.mozilla.org/apt/keyrings/packages.mozilla.org.asc -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
   ```
2. Thêm kho lưu trữ của Mozilla vào danh sách nguồn cấp:
   ```bash
   echo "Debian Source: https://packages.mozilla.org/apt" | sudo tee /etc/apt/sources.list.d/mozilla.list
   echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
   ```
3. Ưu tiên cài đặt từ Mozilla PPA hơn cấu hình mặc định của Ubuntu:
   Tạo file `/etc/apt/preferences.d/mozilla` với nội dung:
   ```text
   Package: *
   Pin: origin packages.mozilla.org
   Pin-Priority: 1000
   ```
4. Cập nhật danh sách gói và cài đặt Firefox tiếng Việt (hoặc bản mặc định):
   ```bash
   sudo apt-get update && sudo apt-get install -y firefox
   ```

### Bước 6: Cài đặt Flatpak và Flathub (Trình quản lý App thay thế Snap Store)
Flatpak là giải pháp thay thế tuyệt vời, nhẹ nhàng và an toàn hơn Snap.
1. Cài đặt Flatpak:
   ```bash
   sudo apt-get install -y flatpak
   ```
2. Thêm kho ứng dụng Flathub:
   ```bash
   flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
   ```

---

> [!IMPORTANT]
> Việc gỡ bỏ Snap sẽ khiến một số ứng dụng mặc định của Ubuntu (như Desktop Security Center hay Firmware Updater) không thể hoạt động. Nếu bạn đồng ý với kế hoạch này, hãy xác nhận bằng cách bấm nút **Proceed** hoặc phản hồi trong ô chat để tôi bắt đầu thực hiện tự động.

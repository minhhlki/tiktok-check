# 🚀 HƯỚNG DẪN CÀI ĐẶT TRÊN VPS UBUNTU (GOOGLE CLOUD)

Hướng dẫn chi tiết từ A-Z để chạy TikTok Statistics Analyzer trên VPS Ubuntu mới.

---

## 📋 YÊU CẦU

- VPS Ubuntu 20.04 hoặc 22.04 (Google Cloud Platform)
- Quyền root hoặc sudo
- Kết nối internet

---

## 🔧 BƯỚC 1: KẾT NỐI VÀ CẬP NHẬT HỆ THỐNG

### 1.1. Kết nối SSH vào VPS

```bash
# Từ máy local, kết nối SSH
ssh username@your-vps-ip

# Hoặc từ Google Cloud Console, click "SSH" button
```

### 1.2. Cập nhật hệ thống

```bash
# Update danh sách package
sudo apt update

# Upgrade các package hiện có
sudo apt upgrade -y

# Cài đặt các công cụ cơ bản
sudo apt install -y wget curl git vim software-properties-common
```

---

## 🐍 BƯỚC 2: CÀI ĐẶT PYTHON 3.8+

### 2.1. Kiểm tra phiên bản Python

```bash
python3 --version
```

**Nếu Python >= 3.8:** Bỏ qua bước 2.2, chuyển sang 2.3

**Nếu Python < 3.8 hoặc chưa có:** Tiếp tục bước 2.2

### 2.2. Cài đặt Python 3.11 (nếu cần)

```bash
# Thêm repository
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update

# Cài Python 3.11
sudo apt install -y python3.11 python3.11-venv python3.11-dev

# Set Python 3.11 làm mặc định (optional)
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
```

### 2.3. Cài đặt pip

```bash
# Cài pip
sudo apt install -y python3-pip

# Upgrade pip
python3 -m pip install --upgrade pip

# Kiểm tra
pip3 --version
```

---

## 📦 BƯỚC 3: CÀI ĐẶT DEPENDENCIES HỆ THỐNG

### 3.1. Cài đặt các thư viện cần thiết cho Playwright

```bash
# Cài đặt dependencies cho Chromium browser
sudo apt install -y \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    libatspi2.0-0 \
    libxshmfence1
```

---

## 📥 BƯỚC 4: CLONE REPOSITORY TỪ GITHUB

### 4.1. Clone code

```bash
# Di chuyển về thư mục home
cd ~

# Clone repository
git clone https://github.com/minhhlki/tiktok-check.git

# Di chuyển vào thư mục project
cd tiktok-check

# Kiểm tra files
ls -la
```

Bạn sẽ thấy các file:
- `tiktok_counter.py`
- `tiktok_counter_improved.py`
- `requirements.txt`
- `README.md`
- etc.

---

## 🎯 BƯỚC 5: CÀI ĐẶT PYTHON PACKAGES

### 5.1. Tạo virtual environment (recommended)

```bash
# Tạo venv
python3 -m venv venv

# Kích hoạt venv
source venv/bin/activate

# Sau khi activate, prompt sẽ có (venv) ở đầu
```

### 5.2. Cài đặt packages

```bash
# Cài playwright
pip install playwright

# Hoặc từ requirements.txt
pip install -r requirements.txt

# Kiểm tra
pip list | grep playwright
```

---

## 🌐 BƯỚC 6: CÀI ĐẶT PLAYWRIGHT BROWSERS

### 6.1. Cài Chromium browser

```bash
# Cài browser cho Playwright
playwright install chromium

# Cài thêm dependencies (nếu cần)
playwright install-deps chromium
```

**Lưu ý:** Bước này sẽ download ~200MB, có thể mất vài phút.

---

## ✅ BƯỚC 7: CHẠY THỬ TOOL

### 7.1. Test với phiên bản improved

```bash
# Chạy với URL test
python tiktok_counter_improved.py https://www.tiktok.com/@tiktok --save

# Hoặc không save file
python tiktok_counter_improved.py https://www.tiktok.com/@tiktok
```

### 7.2. Kiểm tra kết quả

Nếu thành công, bạn sẽ thấy:
```
╔══════════════════════════════════════════╗
║  TIKTOK CHANNEL VIEWS COUNTER IMPROVED   ║
║         Phiên bản: 1.0.2                 ║
╚══════════════════════════════════════════╝

🚀 Bắt đầu scrape kênh: https://www.tiktok.com/@tiktok
🖥️ Chế độ headless: True
[HH:MM:SS] Đang truy cập: https://...
[HH:MM:SS] Đang tải danh sách video...
...
```

---

## 🔥 BƯỚC 8: SỬ DỤNG TOOL

### 8.1. Các lệnh cơ bản

```bash
# Phân tích kênh và lưu JSON + CSV
python tiktok_counter.py https://www.tiktok.com/@username --save-json --save-csv

# Load nhiều video hơn
python tiktok_counter.py https://www.tiktok.com/@username --max-scrolls 50

# Sử dụng version improved (chính xác hơn)
python tiktok_counter_improved.py https://www.tiktok.com/@username --save
```

### 8.2. Xem file kết quả

```bash
# List files
ls -lh *.json *.csv

# Xem nội dung JSON
cat tiktok_stats_*.json

# Download file về máy local (từ máy local)
scp username@vps-ip:~/tiktok-check/*.json ./
scp username@vps-ip:~/tiktok-check/*.csv ./
```

---

## 📊 BƯỚC 9: CHẠY TOOL ĐỊNH KỲ (OPTIONAL)

### 9.1. Tạo script tự động

```bash
# Tạo script
nano run_tiktok_check.sh
```

Nội dung file:
```bash
#!/bin/bash
cd ~/tiktok-check
source venv/bin/activate

# Thay @username bằng kênh bạn muốn check
python tiktok_counter.py https://www.tiktok.com/@username --save-json --save-csv

# Gửi file qua email hoặc upload lên storage (optional)
# Ví dụ: gsutil cp *.json gs://your-bucket/
```

### 9.2. Cho phép execute

```bash
chmod +x run_tiktok_check.sh
```

### 9.3. Setup Cron job (chạy tự động)

```bash
# Mở crontab
crontab -e

# Thêm dòng này để chạy mỗi ngày lúc 2 giờ sáng
0 2 * * * /home/username/tiktok-check/run_tiktok_check.sh >> /home/username/tiktok-check/cron.log 2>&1
```

---

## 🛡️ BƯỚC 10: BẢO MẬT & TỐI ƯU (IMPORTANT!)

### 10.1. Cấu hình Firewall

```bash
# Cho phép SSH
sudo ufw allow ssh

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

### 10.2. Tắt browser sau khi xong (tránh memory leak)

Tool đã tự động close browser, nhưng nên check:

```bash
# Check process
ps aux | grep chromium

# Kill nếu có process treo
pkill -f chromium
```

### 10.3. Giới hạn tài nguyên (optional)

```bash
# Tạo file limits
sudo nano /etc/security/limits.conf

# Thêm dòng này (thay username)
username soft nofile 4096
username hard nofile 8192
```

---

## ⚠️ TROUBLESHOOTING

### Lỗi 1: "Could not find browser"

```bash
# Cài lại browser
playwright install chromium
playwright install-deps chromium
```

### Lỗi 2: "Permission denied"

```bash
# Fix quyền cho thư mục
sudo chown -R $USER:$USER ~/tiktok-check
chmod -R 755 ~/tiktok-check
```

### Lỗi 3: "Memory error" hoặc "Process killed"

VPS có RAM thấp, cần:
```bash
# Tạo swap file (2GB)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Permanent swap
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Lỗi 4: "Timeout" khi scrape

```bash
# Tăng timeout trong code (line ~97 trong tiktok_counter.py)
# Hoặc dùng VPN/Proxy
```

### Lỗi 5: "Encoding error" với tiếng Việt

```bash
# Set locale
sudo apt install -y language-pack-vi
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

---

## 🎯 CHECKLIST HOÀN THÀNH

- [ ] Cập nhật hệ thống Ubuntu
- [ ] Cài đặt Python 3.8+
- [ ] Cài đặt pip
- [ ] Cài đặt dependencies hệ thống
- [ ] Clone repository từ GitHub
- [ ] Tạo virtual environment
- [ ] Cài playwright package
- [ ] Cài playwright browsers
- [ ] Test chạy tool thành công
- [ ] Setup firewall
- [ ] (Optional) Setup cron job

---

## 📞 QUICK COMMANDS - COPY & PASTE

### Cài đặt nhanh (all-in-one):

```bash
# 1. Update system
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl git vim python3 python3-pip python3-venv

# 2. Clone repo
cd ~ && git clone https://github.com/minhhlki/tiktok-check.git
cd tiktok-check

# 3. Setup venv
python3 -m venv venv
source venv/bin/activate

# 4. Install packages
pip install --upgrade pip
pip install playwright

# 5. Install browsers
playwright install chromium
playwright install-deps chromium

# 6. Test run
python tiktok_counter_improved.py https://www.tiktok.com/@tiktok
```

### Chạy lại sau khi reboot:

```bash
cd ~/tiktok-check
source venv/bin/activate
python tiktok_counter.py https://www.tiktok.com/@username --save-json
```

---

## 💡 TIPS & TRICKS

### 1. Chạy trong background (không bị ngắt khi logout)

```bash
# Sử dụng nohup
nohup python tiktok_counter.py https://www.tiktok.com/@username --save-json > output.log 2>&1 &

# Hoặc dùng screen
sudo apt install screen
screen -S tiktok
python tiktok_counter.py https://www.tiktok.com/@username --save-json
# Ctrl+A+D để detach
# screen -r tiktok để attach lại
```

### 2. Monitor resource usage

```bash
# RAM usage
free -h

# CPU & processes
htop

# Disk space
df -h
```

### 3. Xem log real-time

```bash
tail -f output.log
```

### 4. Backup dữ liệu

```bash
# Tạo thư mục backup
mkdir -p ~/tiktok-check/backups

# Copy JSON files
cp *.json backups/

# Hoặc upload lên Google Cloud Storage
gsutil cp *.json gs://your-bucket/tiktok-stats/
```

---

## 🌐 GOOGLE CLOUD SPECIFIC

### Mở port (nếu cần web UI sau này)

```bash
# Từ GCP Console > VPC Network > Firewall rules
# Create rule:
# - Name: allow-http
# - Targets: All instances
# - Source IP ranges: 0.0.0.0/0
# - Protocols/ports: tcp:80,443
```

### Tăng disk space (nếu thiếu)

```bash
# Check disk
df -h

# Từ GCP Console > Compute Engine > Disks
# Click vào disk > Edit > Tăng size
# Sau đó resize partition:
sudo growpart /dev/sda 1
sudo resize2fs /dev/sda1
```

---

## 📚 TÀI LIỆU THAM KHẢO

- GitHub Repository: https://github.com/minhhlki/tiktok-check
- Playwright Docs: https://playwright.dev/python/
- Ubuntu Server Guide: https://ubuntu.com/server/docs

---

**🎉 HOÀN THÀNH! Bạn đã sẵn sàng chạy TikTok Statistics Analyzer trên VPS!**

Nếu gặp vấn đề, check phần Troubleshooting hoặc xem logs để debug.

Good luck! 🚀


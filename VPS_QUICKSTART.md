# ⚡ VPS UBUNTU QUICKSTART

Hướng dẫn cài đặt nhanh TikTok Statistics Analyzer trên VPS Ubuntu mới.

---

## 🎯 CÁCH 1: TỰ ĐỘNG (KHUYÊN DÙNG)

### Chỉ cần 3 lệnh:

```bash
# 1. Clone repository
git clone https://github.com/minhhlki/tiktok-check.git
cd tiktok-check

# 2. Chạy script tự động
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh

# 3. Chạy tool
source venv/bin/activate
python tiktok_counter_improved.py https://www.tiktok.com/@username --save
```

**Xong!** 🎉

---

## 🔧 CÁCH 2: THỦ CÔNG (TỪNG BƯỚC)

### Bước 1: Cài đặt môi trường

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Cài tools cần thiết
sudo apt install -y git python3 python3-pip python3-venv

# Clone repository
cd ~
git clone https://github.com/minhhlki/tiktok-check.git
cd tiktok-check
```

### Bước 2: Setup Python environment

```bash
# Tạo virtual environment
python3 -m venv venv

# Kích hoạt venv
source venv/bin/activate

# Cài packages
pip install --upgrade pip
pip install playwright
```

### Bước 3: Cài Playwright browser

```bash
# Cài Chromium
playwright install chromium

# Cài dependencies
playwright install-deps chromium
```

### Bước 4: Chạy tool

```bash
# Test
python tiktok_counter_improved.py https://www.tiktok.com/@tiktok

# Chạy thật với save file
python tiktok_counter_improved.py https://www.tiktok.com/@username --save
```

---

## 📱 SỬ DỤNG

### Lệnh cơ bản:

```bash
# Kích hoạt venv (luôn chạy lệnh này trước)
cd ~/tiktok-check
source venv/bin/activate

# Chạy phiên bản improved (chính xác hơn)
python tiktok_counter_improved.py https://www.tiktok.com/@username --save

# Chạy phiên bản thường với nhiều options
python tiktok_counter.py https://www.tiktok.com/@username --save-json --save-csv --max-scrolls 30
```

### Sử dụng helper scripts:

```bash
# Nếu đã chạy setup_ubuntu.sh, dùng scripts này:
./run_tiktok_improved.sh https://www.tiktok.com/@username --save
./run_tiktok.sh https://www.tiktok.com/@username --save-json --save-csv
```

---

## 📥 DOWNLOAD KẾT QUẢ

### Cách 1: Dùng SCP (từ máy local)

```bash
# Download JSON
scp username@vps-ip:~/tiktok-check/*.json ./

# Download CSV
scp username@vps-ip:~/tiktok-check/*.csv ./

# Download tất cả
scp username@vps-ip:~/tiktok-check/*.{json,csv} ./
```

### Cách 2: Dùng Google Cloud Console

1. Vào Compute Engine > VM instances
2. Click SSH bên cạnh instance
3. Click settings (⚙️) > Download file
4. Nhập path: `/home/username/tiktok-check/tiktok_stats_*.json`

### Cách 3: Upload lên Google Cloud Storage

```bash
# Cài gsutil (nếu chưa có)
sudo apt install google-cloud-sdk

# Upload
gsutil cp ~/tiktok-check/*.json gs://your-bucket/
gsutil cp ~/tiktok-check/*.csv gs://your-bucket/
```

---

## 🔄 CHẠY LẠI SAU KHI REBOOT

```bash
# Di chuyển vào thư mục
cd ~/tiktok-check

# Kích hoạt venv
source venv/bin/activate

# Chạy tool
python tiktok_counter_improved.py https://www.tiktok.com/@username --save
```

**Lưu ý:** Phải chạy `source venv/bin/activate` mỗi khi mở terminal mới!

---

## 🤖 CHẠY TỰ ĐỘNG ĐỊNH KỲ

### Tạo cron job:

```bash
# 1. Tạo script
nano ~/tiktok-check/auto_run.sh
```

Nội dung:
```bash
#!/bin/bash
cd ~/tiktok-check
source venv/bin/activate
python tiktok_counter_improved.py https://www.tiktok.com/@YOUR_CHANNEL --save >> ~/tiktok-check/auto.log 2>&1
```

```bash
# 2. Cho phép execute
chmod +x ~/tiktok-check/auto_run.sh

# 3. Setup cron (chạy mỗi ngày lúc 3h sáng)
crontab -e
```

Thêm dòng:
```
0 3 * * * /home/username/tiktok-check/auto_run.sh
```

---

## ⚠️ LỖI THƯỜNG GẶP

### Lỗi: Command not found

**Nguyên nhân:** Chưa activate venv

**Giải pháp:**
```bash
source venv/bin/activate
```

### Lỗi: Could not find browser

**Giải pháp:**
```bash
playwright install chromium
playwright install-deps chromium
```

### Lỗi: Permission denied

**Giải pháp:**
```bash
chmod +x setup_ubuntu.sh
# Hoặc
sudo chown -R $USER:$USER ~/tiktok-check
```

### Lỗi: Out of memory

**Giải pháp:** Tạo swap file
```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

## 📚 TÀI LIỆU CHI TIẾT

- **SETUP_VPS_UBUNTU.md** - Hướng dẫn chi tiết từng bước
- **README.md** - Tài liệu đầy đủ về tool
- **FIX_VIEW_ACCURACY.md** - Giải thích về độ chính xác
- **HUONG_DAN.txt** - Hướng dẫn tiếng Việt

---

## 🆘 HỖ TRỢ

**GitHub Issues:** https://github.com/minhhlki/tiktok-check/issues

**Các lệnh hữu ích:**

```bash
# Check RAM
free -h

# Check disk space
df -h

# Check processes
ps aux | grep python

# View logs
tail -f auto.log

# Kill process
pkill -f tiktok_counter
```

---

## ✅ CHECKLIST

- [ ] Clone repository từ GitHub
- [ ] Chạy `setup_ubuntu.sh` hoặc cài thủ công
- [ ] Test chạy tool thành công
- [ ] Biết cách activate venv
- [ ] Biết cách download kết quả
- [ ] (Optional) Setup cron job

**Hoàn thành checklist này là xong!** 🚀

---

**Made with ❤️ for TikTok Analytics**


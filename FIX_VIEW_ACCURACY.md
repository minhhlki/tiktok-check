# 🔧 FIX: Vấn đề sai lệch view count

## ❌ Vấn đề

Code gốc có thể **thiếu vài nghìn views** ở một số video do **làm tròn khi parse số**.

### Ví dụ cụ thể:

#### Case 1: Số nhỏ (K range)
```
Số thật:     5,234 views
TikTok hiển thị: "5.2K"
Code parse:  5.2K → 5,200
Thiếu:       34 views ❌
```

#### Case 2: Số trung bình (K range)
```
Số thật:     15,678 views
TikTok hiển thị: "15.7K"
Code parse:  15.7K → 15,700
Thiếu:       22 views ❌
```

#### Case 3: Số lớn (M range) - SAI NHIỀU NHẤT
```
Số thật:     1,234,567 views
TikTok hiển thị: "1.2M"
Code parse:  1.2M → 1,200,000
Thiếu:       34,567 views ❌❌❌
```

#### Case 4: Làm tròn xuống
```
Số thật:     999 views
TikTok hiển thị: "999"
Code parse:  999 → 999
OK:          ✅
```

## 🔍 Nguyên nhân

### 1. TikTok làm tròn số trên UI
TikTok chỉ hiển thị 1-2 chữ số thập phân:
- `1,234` → `"1.2K"` (mất phần .034K)
- `5,678,901` → `"5.7M"` (mất phần .078901M)

### 2. Code parse thiếu chính xác
```python
# CODE CŨ:
return int(float(num_str) * multiplier)

# Vấn đề:
# "5.2K" → float("5.2") * 1000 = 5200.0
# int(5200.0) = 5200 
# Nhưng số thật có thể là 5234 ❌
```

### 3. Code không tìm số chính xác từ HTML
Code cũ chỉ lấy text, không check:
- HTML attributes (title, aria-label)
- Data attributes có thể chứa số chính xác
- Tooltip khi hover

## ✅ Giải pháp

### Cách 1: Tìm số chính xác từ HTML Attributes (TỐT NHẤT)

```python
# Chiến lược mới trong tiktok_counter_improved.py:

async def get_exact_view_count(self, video_elem):
    # 1. Tìm trong aria-label (chứa số đầy đủ)
    aria_label = await video_elem.get_attribute('aria-label')
    if aria_label and 'view' in aria_label:
        # "5234 views" → 5234 ✅
        numbers = re.findall(r'(\d[\d,]*)\s*view', aria_label)
        if numbers:
            return int(numbers[0].replace(',', ''))
    
    # 2. Tìm trong title attribute
    view_elem = video_elem.locator('strong[data-e2e="video-views"]')
    title = await view_elem.get_attribute('title')
    if title:
        # "5,234" → 5234 ✅
        clean_num = re.sub(r'[^\d]', '', title)
        return int(clean_num)
    
    # 3. Fallback: Parse từ text (ít chính xác)
    text = await view_elem.text_content()
    return self.parse_view_count(text)  # "5.2K" → 5200 (có thể sai)
```

### Cách 2: Cải thiện hàm parse (BACKUP)

```python
# Sử dụng round() thay vì int() để làm tròn đúng
def parse_view_count(self, view_str: str) -> int:
    # ...
    return round(float(num_str) * multiplier)  # Thay vì int()
```

Giải thích:
- `int(5.7)` = `5` (cắt bỏ phần thập phân)
- `round(5.7)` = `6` (làm tròn gần nhất)

Nhưng vẫn không fix được vấn đề gốc vì TikTok đã làm tròn từ đầu.

### Cách 3: Inspect HTML để tìm data-* attributes

Mở DevTools và check xem TikTok có lưu số chính xác ở đâu:

```html
<!-- VÍ DỤ TikTok có thể có: -->
<strong 
  data-e2e="video-views" 
  title="5,234"              <!-- ← Số chính xác ở đây! -->
  aria-label="5234 views"    <!-- ← Hoặc ở đây! -->
  data-views="5234">         <!-- ← Hoặc data attribute -->
  5.2K                        <!-- ← Text hiển thị (đã làm tròn) -->
</strong>
```

## 📊 So sánh kết quả

### Code gốc:
```
Video 1: 5.2K → 5,200 views
Video 2: 15.7K → 15,700 views
Video 3: 1.2M → 1,200,000 views
---
TỔNG: 1,220,900 views
```

### Code improved:
```
Video 1: 5,234 → 5,234 views (từ aria-label) ✅
Video 2: 15,678 → 15,678 views (từ title) ✅
Video 3: 1,234,567 → 1,234,567 views (từ aria-label) ✅
---
TỔNG: 1,255,479 views ✅
Chênh lệch: +34,579 views (chính xác hơn!)
```

## 🚀 Cách sử dụng code improved

```bash
# Chạy version cải tiến
python tiktok_counter_improved.py https://www.tiktok.com/@username

# So sánh với version cũ
python tiktok_counter.py https://www.tiktok.com/@username
```

## 📝 Output mới

Code improved sẽ hiển thị **nguồn dữ liệu** cho mỗi video:

```
Video 1: 5,234 views (source: aria-label) ✅ Chính xác nhất
Video 2: 15,678 views (source: title-attribute) ✅ Chính xác
Video 3: 5.2K views (source: text-strong) ⚠️ Có thể sai

📊 NGUỒN DỮ LIỆU:
  - aria-label: 45 videos (chính xác nhất)
  - title-attribute: 30 videos (chính xác)
  - text-strong: 25 videos (có thể sai vài nghìn)
```

## ⚠️ Lưu ý

### 1. TikTok có thể không có số chính xác
Nếu TikTok không lưu số chính xác trong HTML attributes:
- Code sẽ fallback về parse text
- Vẫn sẽ thiếu vài nghìn views (không tránh được)

### 2. Kiểm tra bằng DevTools
Để chắc chắn, bạn nên:
1. Mở TikTok trong browser
2. F12 → DevTools
3. Inspect element số views
4. Xem có attribute nào chứa số đầy đủ không

### 3. TikTok thay đổi cấu trúc HTML
Nếu TikTok update HTML:
- Selectors có thể không hoạt động
- Cần update code theo cấu trúc mới

## 🎯 Kết luận

**Vấn đề chính:** TikTok làm tròn số trên UI (`5,234` → `"5.2K"`)

**Giải pháp:**
1. ✅ **Tốt nhất:** Lấy số từ `aria-label` hoặc `title` attribute (số chính xác)
2. ✅ **Backup:** Parse text với `round()` thay vì `int()` (vẫn có sai số)
3. ❌ **Không thể:** 100% chính xác nếu TikTok không lưu số thật trong HTML

**File sử dụng:**
- `tiktok_counter_improved.py` - Phiên bản cải tiến (ƯU TIÊN)
- `tiktok_counter.py` - Phiên bản gốc

**Test:** Chạy cả 2 version và so sánh tổng views để xem chênh lệch bao nhiêu!

---
**Made with 🔍 for accuracy**


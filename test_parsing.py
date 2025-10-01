#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test script để so sánh độ chính xác của parse_view_count
"""
import sys
import io

# Fix encoding for Windows console
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

def parse_view_count_OLD(view_str: str) -> int:
    """Phiên bản CŨ - có thể sai"""
    import re
    if not view_str:
        return 0
        
    view_str = view_str.strip().upper()
    
    multipliers = {
        'K': 1000,
        'M': 1000000,
        'B': 1000000000
    }
    
    for suffix, multiplier in multipliers.items():
        if suffix in view_str:
            try:
                num_str = view_str.replace(suffix, '').strip()
                return int(float(num_str) * multiplier)  # Dùng int() - CẮT BỎ
            except:
                continue
    
    try:
        clean_str = re.sub(r'[^\d]', '', view_str)
        return int(clean_str) if clean_str else 0
    except:
        return 0

def parse_view_count_NEW(view_str: str) -> int:
    """Phiên bản MỚI - cải thiện"""
    import re
    if not view_str:
        return 0
        
    view_str = view_str.strip().upper()
    
    multipliers = {
        'K': 1000,
        'M': 1000000,
        'B': 1000000000
    }
    
    for suffix, multiplier in multipliers.items():
        if suffix in view_str:
            try:
                num_str = view_str.replace(suffix, '').strip()
                return round(float(num_str) * multiplier)  # Dùng round() - LÀM TRÒN
            except:
                continue
    
    try:
        clean_str = re.sub(r'[^\d]', '', view_str)
        return int(clean_str) if clean_str else 0
    except:
        return 0

# Test cases
test_cases = [
    # (view_text, số_thật_có_thể, ghi_chú)
    ("5.2K", 5200, "TikTok làm tròn từ ~5200"),
    ("5.2K", 5234, "TikTok làm tròn từ 5234"),
    ("15.7K", 15700, "TikTok làm tròn từ ~15700"),
    ("15.7K", 15678, "TikTok làm tròn từ 15678"),
    ("1.2M", 1200000, "TikTok làm tròn từ ~1200000"),
    ("1.2M", 1234567, "TikTok làm tròn từ 1234567"),
    ("999", 999, "Số nhỏ - không làm tròn"),
    ("1.5K", 1500, "1500 chính xác"),
    ("1.5K", 1523, "TikTok làm tròn từ 1523"),
    ("2.8M", 2800000, "2.8M chính xác"),
    ("2.8M", 2834567, "TikTok làm tròn từ 2834567"),
    ("100K", 100000, "100K chính xác"),
    ("100K", 100234, "TikTok làm tròn từ 100234"),
]

print("="*80)
print("TEST SO SANH DO CHINH XAC PARSE VIEW COUNT")
print("="*80)

total_error_old = 0
total_error_new = 0

for view_text, real_number, note in test_cases:
    parsed_old = parse_view_count_OLD(view_text)
    parsed_new = parse_view_count_NEW(view_text)
    
    error_old = abs(parsed_old - real_number)
    error_new = abs(parsed_new - real_number)
    
    total_error_old += error_old
    total_error_new += error_new
    
    print(f"\nTest: {view_text} ({note})")
    print(f"  So that (gia dinh): {real_number:,}")
    print(f"  OLD parse: {parsed_old:,} -> Sai lech: {error_old:,} {'[SAI]' if error_old > 0 else '[OK]'}")
    print(f"  NEW parse: {parsed_new:,} -> Sai lech: {error_new:,} {'[SAI]' if error_new > 0 else '[OK]'}")
    
    if error_old != error_new:
        if error_new < error_old:
            print(f"  [+] NEW tot hon {error_old - error_new:,} views")
        else:
            print(f"  [-] OLD tot hon {error_new - error_old:,} views")

print("\n" + "="*80)
print("TONG KET:")
print("="*80)
print(f"Tong sai lech OLD: {total_error_old:,} views")
print(f"Tong sai lech NEW: {total_error_new:,} views")
diff = total_error_old - total_error_new
if diff > 0:
    print(f"[OK] NEW tot hon OLD: {diff:,} views")
elif diff < 0:
    print(f"[!] OLD tot hon NEW: {abs(diff):,} views")
else:
    print(f"[=] Ca 2 nhu nhau")

print("\n" + "="*80)
print("LUU Y QUAN TRONG:")
print("="*80)
print("""
1. Parse tu text (ca OLD va NEW) KHONG THE 100% chinh xac
   vi TikTok da lam tron so tren UI!

2. Giai phap TOT NHAT: Lay so tu HTML attributes
   - aria-label: "5234 views" -> 5234 [OK]
   - title: "5,234" -> 5234 [OK]
   - text: "5.2K" -> 5200 [SAI] (thieu 34 views)

3. File tiktok_counter_improved.py da implement cach tot nhat!

4. Chay improved version de co do chinh xac cao nhat.
""")


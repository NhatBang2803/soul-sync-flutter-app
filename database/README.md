# Soul Sync Database - Setup Guide

## 📋 Tổng Quan

Database schema của Soul Sync đã được tái tổ chức và format lại thành 8 file SQL có cấu trúc rõ ràng, dễ bảo trì và mở rộng.

## 🗂️ Cấu Trúc Files

| File | Mục đích | Thứ tự |
|------|----------|--------|
| `p01_initialize_database.sql` | Reset và khởi tạo database | 1️⃣ |
| `p02_create_schema.sql` | Tạo tables và indexes | 2️⃣ |
| `p03_create_views.sql` | Tạo views cho truy vấn | 3️⃣ |
| `p04_create_functions.sql` | Tạo functions và RPC | 4️⃣ |
| `p05_configure_security.sql` | Cấu hình RLS và permissions | 5️⃣ |
| `p06_seed_default_data.sql` | Insert dữ liệu mặc định | 6️⃣ |
| `p07_import_sample_data.sql` | Import dữ liệu mẫu | 7️⃣ |
| `p08_finalize_setup.sql` | Hoàn thiện và validation | 8️⃣ |

## 🚀 Hướng Dẫn Setup

### 1. Setup Từ Đầu (Fresh Install)

```bash
# Chạy tuần tự các file theo thứ tự:
psql -d your_database -f p01_initialize_database.sql
psql -d your_database -f p02_create_schema.sql  
psql -d your_database -f p03_create_views.sql
psql -d your_database -f p04_create_functions.sql
psql -d your_database -f p05_configure_security.sql
psql -d your_database -f p06_seed_default_data.sql
psql -d your_database -f p07_import_sample_data.sql
psql -d your_database -f p08_finalize_setup.sql
```

### 2. Setup Nhanh (Một Lệnh)

```bash
# Chạy tất cả files cùng lúc
for file in p{01..08}_*.sql; do
    echo "Executing $file..."
    psql -d your_database -f "$file"
done
```

### 3. Setup Từng Phần (Partial Setup)

```bash
# Chỉ tạo schema mà không import data
psql -d your_database -f p01_initialize_database.sql
psql -d your_database -f p02_create_schema.sql  
psql -d your_database -f p03_create_views.sql
psql -d your_database -f p04_create_functions.sql
psql -d your_database -f p05_configure_security.sql
psql -d your_database -f p06_seed_default_data.sql
# Bỏ qua p07 và p08 nếu không cần sample data
```

## ⚙️ Cấu Hình Security Mode

### Development Mode (Mặc định)
- RLS disabled cho tất cả tables
- Không cần authentication
- Phù hợp cho: phát triển local, testing

### Production Mode  
- RLS enabled với policies
- Cần Supabase Auth hoặc tương tự
- Để kích hoạt: Sửa file `p05_configure_security.sql`

```sql
-- Comment MODE A (Development)
-- Uncomment MODE B (Production)
```

## 📊 Kiểm Tra Database Health

```sql
-- Xem tổng quan database
SELECT * FROM view_database_health;

-- Kiểm tra functions
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'public';

-- Test một vài functions
SELECT * FROM fn_get_random_songs(5);
SELECT * FROM fn_get_weekly_song_rankings('pop');
```

## 🔧 Bảo Trì Database

```sql
-- Update statistics và cache
SELECT fn_update_cache_statistics();

-- Cleanup dữ liệu cũ (>365 ngày)
SELECT fn_cleanup_old_listening_history(365);

-- Analyze performance
ANALYZE;
```

## 📁 So Sánh Với Cấu Trúc Cũ

### Trước (Files cũ):
- ❌ `fix_ranking_rpc.sql` - Riêng lẻ, không có thứ tự
- ❌ `p1-schema.sql` - Tên không rõ ràng
- ❌ `p2-permission.sql` - Trộn lẫn logic
- ❌ `p3-backup.sql` - File quá lớn (1700+ dòng)
- ❌ `p4-migrations.sql` - Không có cấu trúc

### Sau (Files mới):
- ✅ Naming convention rõ ràng: `p{01..08}_tên_rõ_ràng.sql`
- ✅ Tách biệt concerns: Schema, Views, Functions, Security
- ✅ Comments và documentation đầy đủ
- ✅ Thứ tự thực thi được đảm bảo
- ✅ Validation và error handling
- ✅ Maintenance functions

## 🎯 Lợi Ích Của Cấu Trúc Mới

1. **Dễ bảo trì**: Mỗi file có một nhiệm vụ cụ thể
2. **Dễ debug**: Lỗi xuất hiện ở file nào thì sửa file đó
3. **Dễ mở rộng**: Thêm features mới vào đúng file
4. **Dễ rollback**: Có thể rollback từng phần
5. **Dễ review**: Code review từng file thay vì 1 file khổng lồ
6. **An toàn**: Validation ở mỗi bước

## ⚠️ Lưu Ý Quan Trọng

1. **Backup trước khi chạy**: `p01_initialize_database.sql` sẽ XÓA toàn bộ schema hiện tại
2. **Chạy đúng thứ tự**: Các file phụ thuộc lẫn nhau
3. **Check kết quả**: Mỗi file có thông báo status cuối
4. **Mode Development**: RLS disabled by default, thích hợp cho dev
5. **Sample data**: File `p07` chỉ có một phần data mẫu

## 🚧 Migration Từ Cấu Trúc Cũ

```bash
# 1. Backup dữ liệu hiện tại
pg_dump your_database > backup_$(date +%Y%m%d).sql

# 2. Chạy setup mới
./run_all_setup.sh

# 3. Import lại data nếu cần
psql -d your_database -f backup_$(date +%Y%m%d).sql
```

## 📞 Hỗ Trợ

- Nếu gặp lỗi ở file nào, check log output của file đó
- Mọi file đều có validation và error messages
- Check `view_database_health` để xem tổng quan

---

*Tạo bởi: Hyan Nguyen - 2025-12-27*
*Version: 2.0 - Refactored & Optimized*
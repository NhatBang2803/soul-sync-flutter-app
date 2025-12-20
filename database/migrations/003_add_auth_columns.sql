-- =====================================================
-- Soul Sync Database - ADD AUTH COLUMNS MIGRATION
-- Chạy script này trên database HIỆN TẠI để thêm columns mới
-- KHÔNG XOÁ dữ liệu
-- =====================================================

-- Thêm cột password_hash (NULL cho OAuth users)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS password_hash TEXT;

-- Thêm cột auth_method với default là 'local'
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS auth_method VARCHAR(20) DEFAULT 'local' NOT NULL;

-- Cập nhật các user hiện có không có auth_method
UPDATE users 
SET auth_method = 'local' 
WHERE auth_method IS NULL;

SELECT 'Migration completed successfully!' as status;

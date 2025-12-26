-- =====================================================
-- Soul Sync Database - P01: DATABASE INITIALIZATION
-- Mục đích: Reset và khởi tạo database từ đầu
-- Thứ tự chạy: 1 (chạy đầu tiên)
-- CẢNH BÁO: Script này sẽ XÓA TOÀN BỘ database hiện tại!
-- Ngày tạo: 2025-12-27
-- =====================================================

-- =====================
-- PHẦN 1: RESET SCHEMA HOÀN TOÀN
-- =====================
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- =====================
-- PHẦN 2: CẤU HÌNH PERMISSIONS CƠ BẢN
-- =====================
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
GRANT ALL ON SCHEMA public TO anon;
GRANT ALL ON SCHEMA public TO authenticated;
GRANT ALL ON SCHEMA public TO service_role;

-- =====================
-- PHẦN 3: THÔNG BÁO HOÀN THÀNH
-- =====================
SELECT 'P01: Database initialized successfully! Run p02_create_schema.sql next.' as status;
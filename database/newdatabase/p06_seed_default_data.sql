-- =====================================================
-- Soul Sync Database - P06: SEED DEFAULT DATA
-- Mục đích: Tạo dữ liệu mặc định (genres, admin user)
-- Thứ tự chạy: 6 (sau p05_configure_security.sql)
-- Ngày tạo: 2025-12-27
-- =====================================================

-- =====================
-- PHẦN 1: SEED DEFAULT GENRES
-- =====================

INSERT INTO genres (name, display_name, color) VALUES
    ('ballad', 'Ballad', '#3B82F6'),
    ('rap', 'Rap/Hip-hop', '#EF4444'),
    ('pop', 'Pop', '#EC4899'),
    ('rock', 'Rock', '#8B5CF6'),
    ('edm', 'EDM', '#10B981'),
    ('rnb', 'R&B', '#F59E0B'),
    ('indie', 'Indie', '#6366F1'),
    ('acoustic', 'Acoustic', '#84CC16'),
    ('jazz', 'Jazz', '#F97316'),
    ('classical', 'Classical', '#0EA5E9'),
    ('folk', 'Folk', '#059669'),
    ('country', 'Country', '#D97706'),
    ('blues', 'Blues', '#1E40AF'),
    ('reggae', 'Reggae', '#DC2626'),
    ('electronic', 'Electronic', '#7C3AED')
ON CONFLICT (name) DO NOTHING;

-- =====================
-- PHẦN 2: SEED ADMIN USER (OPTIONAL)
-- Uncomment nếu cần tạo admin user mặc định
-- =====================

/*
INSERT INTO users (
    id, 
    email, 
    username, 
    display_name, 
    auth_method,
    created_at,
    updated_at
) VALUES (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'admin@soulsync.com',
    'admin',
    'Soul Sync Admin',
    'local',
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;
*/

-- =====================
-- PHẦN 3: SEED SAMPLE PODCAST CATEGORIES (OPTIONAL)
-- Uncomment nếu cần tạo podcast categories mặc định
-- =====================

/*
-- Tạo sample podcasts để test
INSERT INTO podcasts (title, host_name, description, category) VALUES
    ('Tech Talk Daily', 'John Doe', 'Daily discussions about technology trends', 'Technology'),
    ('Health & Wellness', 'Jane Smith', 'Tips for healthy living', 'Health'),
    ('Business Insights', 'Mike Johnson', 'Weekly business analysis and insights', 'Business'),
    ('Comedy Hour', 'Sarah Wilson', 'Stand-up comedy and funny stories', 'Comedy'),
    ('Music Matters', 'David Brown', 'Interviews with musicians and music industry insights', 'Music')
ON CONFLICT DO NOTHING;
*/

-- =====================
-- PHẦN 4: DATABASE STATISTICS
-- =====================

-- Hiển thị thống kê database sau khi seed
SELECT 
    'Tables' as type,
    COUNT(*) as count 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
UNION ALL
SELECT 
    'Views' as type,
    COUNT(*) as count 
FROM information_schema.views 
WHERE table_schema = 'public'
UNION ALL
SELECT 
    'Functions' as type,
    COUNT(*) as count 
FROM information_schema.routines 
WHERE routine_schema = 'public'
UNION ALL
SELECT 
    'Indexes' as type,
    COUNT(*) as count 
FROM pg_indexes 
WHERE schemaname = 'public'
UNION ALL
SELECT 
    'Genres' as type,
    COUNT(*) as count 
FROM genres;

-- =====================
-- PHẦN 5: THÔNG BÁO HOÀN THÀNH
-- =====================
SELECT 'P06: Default data seeded successfully! Run p07_import_sample_data.sql next if you have sample data.' as status;
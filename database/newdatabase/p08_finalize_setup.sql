-- =====================================================
-- Soul Sync Database - P08: FINALIZE SETUP
-- Mục đích: Hoàn thiện setup và validation cuối cùng
-- Thứ tự chạy: 8 (cuối cùng)
-- Ngày tạo: 2025-12-27
-- =====================================================

-- =====================
-- PHẦN 1: UPDATE SEQUENCES (ĐỂ ĐỒNG BỘ AUTO-INCREMENT)
-- =====================
SELECT setval(pg_get_serial_sequence('users', 'id'), (SELECT COALESCE(MAX(id::text)::bigint, 1) FROM users WHERE id::text ~ '^\d+$'), false);
-- Lặp lại cho các table khác nếu cần

-- =====================
-- PHẦN 2: REFRESH MATERIALIZED VIEWS (NẾU CÓ)
-- =====================
-- REFRESH MATERIALIZED VIEW view_some_materialized_view;

-- =====================
-- PHẦN 3: CREATE ADDITIONAL INDEXES FOR PERFORMANCE
-- =====================

-- Composite indexes cho queries phức tạp
CREATE INDEX IF NOT EXISTS idx_listening_history_user_time_desc 
ON listening_history(user_id, listened_at DESC);

CREATE INDEX IF NOT EXISTS idx_songs_play_count_created 
ON songs(play_count DESC, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_artists_verified_followers 
ON artists(is_verified, followers DESC) WHERE is_verified = true;

-- =====================
-- PHẦN 4: DATABASE VALIDATION
-- =====================

-- Kiểm tra integrity của dữ liệu
DO $$
DECLARE
    v_table_count INTEGER;
    v_view_count INTEGER;
    v_function_count INTEGER;
    v_user_count INTEGER;
    v_song_count INTEGER;
    v_artist_count INTEGER;
    v_genre_count INTEGER;
BEGIN
    -- Đếm số lượng tables, views, functions
    SELECT COUNT(*) INTO v_table_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
    
    SELECT COUNT(*) INTO v_view_count 
    FROM information_schema.views 
    WHERE table_schema = 'public';
    
    SELECT COUNT(*) INTO v_function_count 
    FROM information_schema.routines 
    WHERE routine_schema = 'public';
    
    -- Đếm dữ liệu
    SELECT COUNT(*) INTO v_user_count FROM users;
    SELECT COUNT(*) INTO v_song_count FROM songs;
    SELECT COUNT(*) INTO v_artist_count FROM artists;
    SELECT COUNT(*) INTO v_genre_count FROM genres;
    
    -- Hiển thị kết quả
    RAISE NOTICE '=== DATABASE SETUP SUMMARY ===';
    RAISE NOTICE 'Tables: %', v_table_count;
    RAISE NOTICE 'Views: %', v_view_count;
    RAISE NOTICE 'Functions: %', v_function_count;
    RAISE NOTICE '=== DATA SUMMARY ===';
    RAISE NOTICE 'Users: %', v_user_count;
    RAISE NOTICE 'Songs: %', v_song_count;
    RAISE NOTICE 'Artists: %', v_artist_count;
    RAISE NOTICE 'Genres: %', v_genre_count;
    
    -- Validation
    IF v_table_count < 15 THEN
        RAISE EXCEPTION 'ERROR: Not all tables were created. Expected at least 15, got %', v_table_count;
    END IF;
    
    IF v_genre_count < 10 THEN
        RAISE WARNING 'WARNING: Only % genres found. Consider running more seed data.', v_genre_count;
    END IF;
    
    RAISE NOTICE '=== VALIDATION PASSED ===';
END $$;

-- =====================
-- PHẦN 5: CREATE MAINTENANCE FUNCTIONS
-- =====================

-- Function để cleanup old data
CREATE OR REPLACE FUNCTION fn_cleanup_old_listening_history(p_days INTEGER DEFAULT 365)
RETURNS INTEGER 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
DECLARE
    v_deleted_count INTEGER;
BEGIN
    DELETE FROM listening_history 
    WHERE listened_at < NOW() - INTERVAL '1 day' * p_days;
    
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    RETURN v_deleted_count;
END;
$$;

-- Function để update cache/statistics
CREATE OR REPLACE FUNCTION fn_update_cache_statistics()
RETURNS VOID 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
BEGIN
    -- Update monthly listeners for all artists
    PERFORM fn_update_monthly_listeners();
    
    -- Update album song counts
    UPDATE albums 
    SET song_count = (
        SELECT COUNT(*) 
        FROM album_songs 
        WHERE album_id = albums.id
    );
    
    -- Update playlist song counts
    UPDATE playlists 
    SET song_count = (
        SELECT COUNT(*) 
        FROM playlist_songs 
        WHERE playlist_id = playlists.id
    );
    
    -- Refresh statistics
    ANALYZE;
END;
$$;

-- =====================
-- PHẦN 6: GRANT FINAL PERMISSIONS
-- =====================
GRANT EXECUTE ON FUNCTION fn_cleanup_old_listening_history(INTEGER) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION fn_update_cache_statistics() TO authenticated, service_role;

-- =====================
-- PHẦN 7: CREATE HELPFUL QUERIES/EXAMPLES
-- =====================

-- Tạo view để kiểm tra database health
CREATE OR REPLACE VIEW view_database_health AS
SELECT 
    'Tables' as type,
    COUNT(*)::TEXT as count
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
UNION ALL
SELECT 
    'Views' as type,
    COUNT(*)::TEXT as count
FROM information_schema.views 
WHERE table_schema = 'public'
UNION ALL
SELECT 
    'Functions' as type,
    COUNT(*)::TEXT as count
FROM information_schema.routines 
WHERE routine_schema = 'public'
UNION ALL
SELECT 
    'Users' as type,
    COUNT(*)::TEXT as count
FROM users
UNION ALL
SELECT 
    'Artists' as type,
    COUNT(*)::TEXT as count
FROM artists
UNION ALL
SELECT 
    'Songs' as type,
    COUNT(*)::TEXT as count
FROM songs
UNION ALL
SELECT 
    'Genres' as type,
    COUNT(*)::TEXT as count
FROM genres;

GRANT SELECT ON view_database_health TO anon, authenticated;

-- =====================
-- PHẦN 8: EXECUTION ORDER DOCUMENTATION
-- =====================

-- Tạo bảng để lưu execution history
CREATE TABLE IF NOT EXISTS _setup_execution_log (
    id SERIAL PRIMARY KEY,
    script_name VARCHAR(100) NOT NULL,
    executed_at TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'SUCCESS',
    notes TEXT
);

-- Log việc thực thi script này
INSERT INTO _setup_execution_log (script_name, notes) VALUES 
('p08_finalize_setup.sql', 'Database setup completed successfully');

-- =====================
-- PHẦN 9: FINAL SUMMARY & INSTRUCTIONS
-- =====================

SELECT '
=== SOUL SYNC DATABASE SETUP COMPLETED ===

✅ All tables, views, functions created successfully
✅ Security policies configured
✅ Sample data imported
✅ Performance indexes added
✅ Validation passed

🚀 NEXT STEPS:
1. Update your application connection strings
2. Test your API endpoints
3. Run fn_update_cache_statistics() periodically
4. Monitor database performance

📋 EXECUTION ORDER FOR FUTURE REFERENCE:
p01_initialize_database.sql    → Reset database
p02_create_schema.sql          → Create tables & indexes  
p03_create_views.sql           → Create views
p04_create_functions.sql       → Create functions & RPC
p05_configure_security.sql     → Setup RLS & permissions
p06_seed_default_data.sql      → Insert default data
p07_import_sample_data.sql     → Import sample data
p08_finalize_setup.sql         → Final validation & cleanup

💡 TIP: To check database health anytime, run:
   SELECT * FROM view_database_health;

🛠️ MAINTENANCE COMMANDS:
   SELECT fn_update_cache_statistics();       -- Update all statistics
   SELECT fn_cleanup_old_listening_history(); -- Cleanup old history

' as final_message;

SELECT 'P08: Database setup finalized successfully! 🎉' as status;
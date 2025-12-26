-- =====================================================
-- Soul Sync Database - P03: CREATE VIEWS
-- Mục đích: Tạo các Views để truy vấn dữ liệu dễ dàng
-- Thứ tự chạy: 3 (sau p02_create_schema.sql)
-- Ngày tạo: 2025-12-27
-- =====================================================

-- =====================
-- PHẦN 1: BASIC AGGREGATED VIEWS
-- =====================

-- Songs with artists aggregated
CREATE VIEW view_songs_with_artists AS
SELECT 
    s.id,
    s.title,
    s.duration,
    s.audio_url,
    s.cover_url,
    s.play_count,
    s.album_id,
    s.created_at,
    STRING_AGG(a.name, ', ' ORDER BY sa.position) as artist_name,
    ARRAY_AGG(a.id ORDER BY sa.position) as artist_ids,
    ARRAY_AGG(a.name ORDER BY sa.position) as artist_names
FROM songs s
LEFT JOIN song_artists sa ON s.id = sa.song_id
LEFT JOIN artists a ON sa.artist_id = a.id
GROUP BY s.id;

-- Albums with artists aggregated
CREATE VIEW view_albums_with_artists AS
SELECT 
    al.id,
    al.name,
    al.cover_url,
    al.release_year,
    al.song_count,
    al.listen_count,
    al.is_public,
    al.created_at,
    al.updated_at,
    STRING_AGG(a.name, ', ') as artist_name,
    ARRAY_AGG(a.id) as artist_ids,
    ARRAY_AGG(a.name) as artist_names
FROM albums al
LEFT JOIN album_artists aa ON al.id = aa.album_id
LEFT JOIN artists a ON aa.artist_id = a.id
GROUP BY al.id;

-- =====================
-- PHẦN 2: RANKING VIEWS
-- =====================

-- Weekly song rankings by genre
CREATE VIEW view_weekly_song_rankings AS
SELECT 
    s.id,
    s.title,
    s.cover_url,
    s.duration,
    s.audio_url,
    s.play_count,
    s.album_id,
    g.id as genre_id,
    g.name as genre_name,
    g.display_name as genre_display_name,
    g.color as genre_color,
    COALESCE(COUNT(lh.id), 0) as weekly_plays,
    RANK() OVER (PARTITION BY g.id ORDER BY COUNT(lh.id) DESC, s.play_count DESC) as rank
FROM songs s
INNER JOIN song_genres sg ON s.id = sg.song_id
INNER JOIN genres g ON sg.genre_id = g.id
LEFT JOIN listening_history lh ON s.id = lh.song_id 
    AND lh.listened_at > NOW() - INTERVAL '7 days'
GROUP BY s.id, g.id
HAVING COALESCE(COUNT(lh.id), 0) > 0
ORDER BY g.id, rank;

-- Weekly artist rankings
CREATE VIEW view_weekly_artist_rankings AS
SELECT 
    a.id,
    a.name,
    a.image_url,
    a.bio,
    a.followers,
    a.monthly_listeners,
    a.is_verified,
    a.created_at,
    COUNT(lh.id) as weekly_plays,
    COUNT(DISTINCT lh.user_id) as weekly_listeners,
    COUNT(DISTINCT lh.song_id) as songs_played,
    RANK() OVER (ORDER BY COUNT(lh.id) DESC) as rank
FROM artists a
INNER JOIN song_artists sa ON a.id = sa.artist_id
INNER JOIN listening_history lh ON sa.song_id = lh.song_id
WHERE lh.listened_at > NOW() - INTERVAL '7 days'
GROUP BY a.id
ORDER BY rank;

-- =====================
-- PHẦN 3: NEW RELEASES VIEWS
-- =====================

-- New song releases (last 7 days)
CREATE VIEW view_new_song_releases AS
SELECT 
    s.id,
    s.title,
    s.duration,
    s.audio_url,
    s.cover_url,
    s.play_count,
    s.album_id,
    s.created_at,
    STRING_AGG(DISTINCT a.name, ', ') as artist_name,
    ARRAY_AGG(DISTINCT a.id) as artist_ids,
    ARRAY_AGG(DISTINCT a.name) as artist_names
FROM songs s
LEFT JOIN song_artists sa ON s.id = sa.song_id
LEFT JOIN artists a ON sa.artist_id = a.id
WHERE s.created_at > NOW() - INTERVAL '7 days'
GROUP BY s.id
ORDER BY s.created_at DESC;

-- =====================
-- PHẦN 4: PODCAST VIEWS
-- =====================

-- Podcast library with episode stats
CREATE VIEW view_podcast_library AS
SELECT 
    p.id,
    p.title,
    p.host_name,
    p.image_url,
    p.description,
    p.category,
    p.created_at,
    COUNT(pe.id) as episode_count,
    COALESCE(SUM(pe.duration), 0) as total_duration_seconds,
    COALESCE(SUM(pe.play_count), 0) as total_plays,
    MAX(pe.published_at) as last_updated
FROM podcasts p
LEFT JOIN podcast_episodes pe ON p.id = pe.podcast_id
GROUP BY p.id;

-- Podcast new releases (episodes in last 7 days)
CREATE VIEW view_podcast_new_releases AS
SELECT 
    pe.id,
    pe.podcast_id,
    pe.title,
    pe.description,
    pe.audio_url,
    pe.duration,
    pe.play_count,
    pe.published_at,
    p.title as podcast_title,
    p.host_name,
    p.image_url as podcast_image
FROM podcast_episodes pe
INNER JOIN podcasts p ON pe.podcast_id = p.id
WHERE pe.published_at >= NOW() - INTERVAL '7 days'
ORDER BY pe.published_at DESC;

-- Podcast episode rankings
CREATE VIEW view_podcast_episode_rankings AS
SELECT 
    pe.id,
    pe.podcast_id,
    pe.title,
    pe.description,
    pe.audio_url,
    pe.duration,
    pe.play_count,
    pe.published_at,
    p.title as podcast_title,
    p.host_name,
    p.image_url as podcast_image,
    RANK() OVER (ORDER BY pe.play_count DESC) as rank
FROM podcast_episodes pe
INNER JOIN podcasts p ON pe.podcast_id = p.id
WHERE pe.play_count > 0
ORDER BY pe.play_count DESC
LIMIT 20;

-- Episodes with podcast info (for detailed display)
CREATE VIEW view_podcast_episodes_full AS
SELECT 
    pe.id,
    pe.podcast_id,
    pe.title,
    pe.description,
    pe.audio_url,
    pe.duration,
    pe.play_count,
    pe.published_at,
    pe.created_at,
    p.title as podcast_title,
    p.host_name,
    p.image_url as podcast_image,
    p.category
FROM podcast_episodes pe
INNER JOIN podcasts p ON pe.podcast_id = p.id
ORDER BY pe.published_at DESC;

-- =====================
-- PHẦN 5: THÔNG BÁO HOÀN THÀNH
-- =====================
SELECT 'P03: Views created successfully! Run p04_create_functions.sql next.' as status;
-- =====================================================
-- TEST: Weekly Artist Rankings View
-- Chạy từng query riêng để kiểm tra
-- =====================================================

-- =====================
-- 1. KIỂM TRA LISTENING_HISTORY TRONG 7 NGÀY GẦN ĐÂY
-- =====================
SELECT 
  'Listening History (7 days)' as test,
  COUNT(*) as total_plays,
  COUNT(DISTINCT user_id) as unique_users,
  COUNT(DISTINCT song_id) as unique_songs
FROM listening_history
WHERE listened_at > NOW() - INTERVAL '7 days';

-- =====================
-- 2. XEM CHI TIẾT LISTENING_HISTORY GẦN ĐÂY (10 records mới nhất)
-- =====================
SELECT 
  lh.id,
  lh.user_id,
  lh.song_id,
  s.title as song_title,
  lh.listened_at,
  lh.duration_played
FROM listening_history lh
LEFT JOIN songs s ON lh.song_id = s.id
WHERE lh.listened_at > NOW() - INTERVAL '7 days'
ORDER BY lh.listened_at DESC
LIMIT 10;

-- =====================
-- 3. TEST: LƯỢT NGHE THEO NGHỆ SĨ (KHÔNG DÙNG VIEW)
-- =====================
SELECT 
  a.id as artist_id,
  a.name as artist_name,
  a.image_url,
  COUNT(lh.id) as play_count,
  COUNT(DISTINCT lh.user_id) as unique_listeners,
  RANK() OVER (ORDER BY COUNT(lh.id) DESC) as rank
FROM artists a
LEFT JOIN song_artists sa ON a.id = sa.artist_id
LEFT JOIN listening_history lh ON sa.song_id = lh.song_id 
  AND lh.listened_at > NOW() - INTERVAL '7 days'
GROUP BY a.id
HAVING COUNT(lh.id) > 0  -- Chỉ lấy những nghệ sĩ có lượt nghe
ORDER BY play_count DESC
LIMIT 10;

-- =====================
-- 4. TEST: VIEW WEEKLY_ARTIST_RANKINGS
-- =====================
SELECT 
  id,
  name,
  image_url,
  weekly_plays,
  rank
FROM weekly_artist_rankings
WHERE weekly_plays > 0
ORDER BY rank
LIMIT 10;

-- =====================
-- 5. KIỂM TRA SONG_ARTISTS (LIÊN KẾT BÀI HÁT - NGHỆ SĨ)
-- =====================
SELECT 
  'Song-Artist Links' as test,
  COUNT(*) as total_links,
  COUNT(DISTINCT song_id) as unique_songs,
  COUNT(DISTINCT artist_id) as unique_artists
FROM song_artists;

-- =====================
-- 6. KIỂM TRA BÀI HÁT NÀO ĐƯỢC NGHE NHIỀU NHẤT TRONG TUẦN
-- =====================
SELECT 
  s.id,
  s.title,
  STRING_AGG(a.name, ', ') as artists,
  COUNT(lh.id) as weekly_plays
FROM songs s
LEFT JOIN song_artists sa ON s.id = sa.song_id
LEFT JOIN artists a ON sa.artist_id = a.id
LEFT JOIN listening_history lh ON s.id = lh.song_id 
  AND lh.listened_at > NOW() - INTERVAL '7 days'
GROUP BY s.id
HAVING COUNT(lh.id) > 0
ORDER BY weekly_plays DESC
LIMIT 10;

-- =====================
-- 7. KIỂM TRA VIEW ĐÃ TỒN TẠI CHƯA
-- =====================
SELECT 
  table_name as view_name
FROM information_schema.views
WHERE table_schema = 'public' 
  AND table_name = 'weekly_artist_rankings';

-- =====================
-- 8. LẤY CẤU TRÚC CỦA VIEW HIỆN TẠI
-- =====================
SELECT 
  column_name,
  data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'weekly_artist_rankings'
ORDER BY ordinal_position;

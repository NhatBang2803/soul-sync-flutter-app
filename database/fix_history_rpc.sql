-- =====================================================
-- FIX: get_recently_played_unique_songs RPC function
-- Mục đích: Sửa lỗi không lấy được lịch sử nghe nhạc
-- Ngày: 2025-12-27
-- Version: 2 (Fix type mismatch error)
-- =====================================================

-- Drop function cũ để tạo lại
DROP FUNCTION IF EXISTS get_recently_played_unique_songs(UUID, INTEGER);

-- Tạo function mới với query tối ưu hơn
CREATE OR REPLACE FUNCTION get_recently_played_unique_songs(
  p_user_id UUID,
  p_limit INTEGER DEFAULT 5
)
RETURNS TABLE (
  id UUID,
  title TEXT,
  duration INTEGER,
  audio_url TEXT,
  cover_url TEXT,
  play_count INTEGER,
  artist_name TEXT,
  artist_ids UUID[],
  artist_names TEXT[]
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.title::TEXT,
    s.duration,
    s.audio_url,
    s.cover_url,
    s.play_count,
    s.artist_name,
    s.artist_ids,
    s.artist_names::TEXT[] -- Cast VARCHAR[] to TEXT[]
  FROM (
    -- Lấy thời gian nghe gần nhất của mỗi bài hát cho user này
    SELECT lh.song_id, MAX(lh.listened_at) as last_listened
    FROM listening_history lh
    WHERE lh.user_id = p_user_id
    GROUP BY lh.song_id
    ORDER BY last_listened DESC
    LIMIT p_limit
  ) recent
  JOIN songs_with_artists s ON recent.song_id = s.id
  ORDER BY recent.last_listened DESC;
END;
$$;

-- Cấp quyền execute
GRANT EXECUTE ON FUNCTION get_recently_played_unique_songs(UUID, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_recently_played_unique_songs(UUID, INTEGER) TO anon;

-- Verification query (Optional - just to check if it runs)
-- SELECT * FROM get_recently_played_unique_songs('USER_UUID_HERE', 5);

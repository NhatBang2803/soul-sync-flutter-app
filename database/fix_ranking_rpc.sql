-- =====================================================
-- FIX: get_weekly_song_rankings RPC function
-- Mục đích: Tính toán bảng xếp hạng global, bypass RLS
-- =====================================================

CREATE OR REPLACE FUNCTION get_weekly_song_rankings(genre_filter text)
RETURNS TABLE (
  id uuid,
  title text,
  cover_url text,
  duration int,
  audio_url text,
  play_count int,
  genre_id uuid,
  genre_name text,
  genre_display_name text,
  genre_color text,
  weekly_plays bigint,
  rank bigint
) 
LANGUAGE sql
SECURITY DEFINER -- Quan trọng: Chạy với quyền superuser để thấy toàn bộ listening_history
SET search_path = public
AS $$
  WITH song_weekly_plays AS (
    SELECT 
      s.id as song_id,
      COUNT(lh.id) as weekly_plays
    FROM songs s
    INNER JOIN listening_history lh ON s.id = lh.song_id
    WHERE lh.listened_at > NOW() - INTERVAL '7 days'
    GROUP BY s.id
  )
  SELECT 
    s.id,
    s.title,
    s.cover_url,
    s.duration,
    s.audio_url,
    s.play_count,
    g.id as genre_id,
    g.name as genre_name,
    g.display_name as genre_display_name,
    g.color as genre_color,
    COALESCE(swp.weekly_plays, 0) as weekly_plays,
    RANK() OVER (ORDER BY COALESCE(swp.weekly_plays, 0) DESC, s.play_count DESC) as rank
  FROM songs s
  JOIN song_genres sg ON s.id = sg.song_id
  JOIN genres g ON sg.genre_id = g.id
  LEFT JOIN song_weekly_plays swp ON s.id = swp.song_id
  WHERE 
    COALESCE(swp.weekly_plays, 0) > 0 
    AND g.name = genre_filter
  ORDER BY rank
  LIMIT 10;
$$;

GRANT EXECUTE ON FUNCTION get_weekly_song_rankings(text) TO anon, authenticated;

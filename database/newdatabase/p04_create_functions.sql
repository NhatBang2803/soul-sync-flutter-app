-- =====================================================
-- Soul Sync Database - P04: CREATE FUNCTIONS
-- Mục đích: Tạo các Functions và RPC cho business logic
-- Thứ tự chạy: 4 (sau p03_create_views.sql)
-- Ngày tạo: 2025-12-27
-- =====================================================

-- =====================
-- PHẦN 1: BASIC HELPER FUNCTIONS
-- =====================

-- Increment song play count
CREATE OR REPLACE FUNCTION fn_increment_song_play_count(p_song_id UUID)
RETURNS VOID 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
BEGIN
    UPDATE songs 
    SET play_count = play_count + 1 
    WHERE id = p_song_id;
END;
$$;

-- Increment podcast episode play count
CREATE OR REPLACE FUNCTION fn_increment_podcast_play_count(p_episode_id UUID)
RETURNS VOID 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
BEGIN
    UPDATE podcast_episodes 
    SET play_count = COALESCE(play_count, 0) + 1
    WHERE id = p_episode_id;
END;
$$;

-- Increment artist followers count
CREATE OR REPLACE FUNCTION fn_increment_artist_followers(p_artist_id UUID)
RETURNS VOID 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
BEGIN
    UPDATE artists 
    SET followers = followers + 1 
    WHERE id = p_artist_id;
END;
$$;

-- =====================
-- PHẦN 2: HISTORY RECORDING FUNCTIONS
-- =====================

-- Record listening history for songs
CREATE OR REPLACE FUNCTION fn_record_song_listening(
    p_user_id UUID,
    p_song_id UUID,
    p_duration_played INTEGER DEFAULT 0,
    p_completed BOOLEAN DEFAULT FALSE
)
RETURNS UUID 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
DECLARE
    v_new_id UUID;
BEGIN
    -- Insert listening history record
    INSERT INTO listening_history (user_id, song_id, duration_played, completed)
    VALUES (p_user_id, p_song_id, p_duration_played, p_completed)
    RETURNING id INTO v_new_id;
    
    -- Increment play count
    PERFORM fn_increment_song_play_count(p_song_id);
    
    RETURN v_new_id;
END;
$$;

-- Record listening history for podcast episodes
CREATE OR REPLACE FUNCTION fn_record_podcast_listening(
    p_user_id UUID,
    p_episode_id UUID,
    p_duration_played INTEGER DEFAULT 0,
    p_completed BOOLEAN DEFAULT FALSE
)
RETURNS UUID 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
DECLARE
    v_new_id UUID;
BEGIN
    -- Insert podcast listening history record
    INSERT INTO podcast_listening_history (user_id, episode_id, duration_played, completed)
    VALUES (p_user_id, p_episode_id, p_duration_played, p_completed)
    RETURNING id INTO v_new_id;
    
    -- Increment play count
    PERFORM fn_increment_podcast_play_count(p_episode_id);
    
    RETURN v_new_id;
END;
$$;

-- =====================
-- PHẦN 3: DATA RETRIEVAL FUNCTIONS
-- =====================

-- Get random songs
CREATE OR REPLACE FUNCTION fn_get_random_songs(p_limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
    id UUID,
    title VARCHAR,
    duration INTEGER,
    audio_url TEXT,
    cover_url TEXT,
    album_id UUID,
    artist_name TEXT,
    artist_ids UUID[],
    artist_names VARCHAR[]
) 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.title,
        s.duration,
        s.audio_url,
        s.cover_url,
        s.album_id,
        STRING_AGG(a.name, ', ' ORDER BY sa.position)::VARCHAR as artist_name,
        ARRAY_AGG(a.id ORDER BY sa.position) as artist_ids,
        ARRAY_AGG(a.name ORDER BY sa.position)::VARCHAR[] as artist_names
    FROM songs s
    LEFT JOIN song_artists sa ON s.id = sa.song_id
    LEFT JOIN artists a ON sa.artist_id = a.id
    WHERE s.audio_url IS NOT NULL
    GROUP BY s.id
    ORDER BY RANDOM()
    LIMIT p_limit_count;
END;
$$;

-- Get recently played unique songs
CREATE OR REPLACE FUNCTION fn_get_recently_played_unique_songs(
    p_user_id UUID,
    p_limit INTEGER DEFAULT 5
)
RETURNS TABLE (
    id UUID,
    title VARCHAR,
    duration INTEGER,
    audio_url TEXT,
    cover_url TEXT,
    play_count INTEGER,
    album_id UUID,
    artist_name TEXT,
    artist_ids UUID[],
    artist_names VARCHAR[]
) 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    WITH ranked_songs AS (
        SELECT 
            s.id,
            s.title,
            s.duration,
            s.audio_url,
            s.cover_url,
            s.play_count,
            s.album_id,
            s.artist_name,
            s.artist_ids,
            s.artist_names,
            ROW_NUMBER() OVER (PARTITION BY s.id ORDER BY lh.listened_at DESC) as rn
        FROM listening_history lh
        INNER JOIN view_songs_with_artists s ON lh.song_id = s.id
        WHERE lh.user_id = p_user_id
    )
    SELECT 
        ranked_songs.id,
        ranked_songs.title,
        ranked_songs.duration,
        ranked_songs.audio_url,
        ranked_songs.cover_url,
        ranked_songs.play_count,
        ranked_songs.album_id,
        ranked_songs.artist_name,
        ranked_songs.artist_ids,
        ranked_songs.artist_names
    FROM ranked_songs
    WHERE rn = 1
    ORDER BY (
        SELECT MAX(listened_at) 
        FROM listening_history 
        WHERE song_id = ranked_songs.id AND user_id = p_user_id
    ) DESC
    LIMIT p_limit;
END;
$$;

-- =====================
-- PHẦN 4: RANKING & RECOMMENDATION FUNCTIONS
-- =====================

-- Get weekly song rankings by genre
CREATE OR REPLACE FUNCTION fn_get_weekly_song_rankings(p_genre_filter TEXT)
RETURNS TABLE (
    id UUID,
    title TEXT,
    cover_url TEXT,
    duration INTEGER,
    audio_url TEXT,
    play_count INTEGER,
    album_id UUID,
    genre_id UUID,
    genre_name TEXT,
    genre_display_name TEXT,
    genre_color TEXT,
    weekly_plays BIGINT,
    rank BIGINT
) 
LANGUAGE sql
SECURITY DEFINER
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
        s.album_id,
        g.id as genre_id,
        g.name as genre_name,
        g.display_name as genre_display_name,
        g.color as genre_color,
        COALESCE(swp.weekly_plays, 0) as weekly_plays,
        RANK() OVER (ORDER BY COALESCE(swp.weekly_plays, 0) DESC, s.play_count DESC) as rank
    FROM songs s
    INNER JOIN song_genres sg ON s.id = sg.song_id
    INNER JOIN genres g ON sg.genre_id = g.id
    LEFT JOIN song_weekly_plays swp ON s.id = swp.song_id
    WHERE 
        COALESCE(swp.weekly_plays, 0) > 0 
        AND g.name = p_genre_filter
    ORDER BY rank
    LIMIT 10;
$$;

-- Get weekly artist rankings
CREATE OR REPLACE FUNCTION fn_get_weekly_artist_ranking(p_limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
    id UUID,
    name VARCHAR,
    image_url TEXT,
    bio TEXT,
    followers INTEGER,
    monthly_listeners BIGINT,
    is_verified BOOLEAN,
    weekly_plays BIGINT,
    weekly_listeners BIGINT,
    songs_played BIGINT,
    rank BIGINT
) 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    WITH weekly_data AS (
        -- Tính weekly plays từ 7 ngày gần đây
        SELECT 
            a.id as artist_id,
            a.name,
            a.image_url,
            a.bio,
            a.followers,
            a.is_verified,
            COUNT(lh.id) as weekly_plays,
            COUNT(DISTINCT lh.user_id) as weekly_listeners,
            COUNT(DISTINCT lh.song_id) as songs_played
        FROM artists a
        INNER JOIN song_artists sa ON a.id = sa.artist_id
        INNER JOIN listening_history lh ON sa.song_id = lh.song_id
        WHERE lh.listened_at > NOW() - INTERVAL '7 days'
        GROUP BY a.id
    ),
    monthly_data AS (
        -- Tính monthly plays từ 30 ngày gần đây
        SELECT 
            sa.artist_id,
            COUNT(lh.id) as monthly_plays
        FROM song_artists sa
        INNER JOIN listening_history lh ON sa.song_id = lh.song_id
        WHERE lh.listened_at > NOW() - INTERVAL '30 days'
        GROUP BY sa.artist_id
    )
    SELECT 
        w.artist_id as id,
        w.name,
        w.image_url,
        w.bio,
        w.followers,
        COALESCE(m.monthly_plays, 0) as monthly_listeners,
        w.is_verified,
        w.weekly_plays,
        w.weekly_listeners,
        w.songs_played,
        RANK() OVER (ORDER BY w.weekly_plays DESC) as rank
    FROM weekly_data w
    LEFT JOIN monthly_data m ON w.artist_id = m.artist_id
    ORDER BY w.weekly_plays DESC
    LIMIT p_limit_count;
END;
$$;

-- Get artist with stats
CREATE OR REPLACE FUNCTION fn_get_artist_with_stats(p_artist_id UUID)
RETURNS TABLE (
    id UUID,
    name VARCHAR,
    image_url TEXT,
    bio TEXT,
    followers INTEGER,
    monthly_listeners BIGINT,
    is_verified BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
) 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.name,
        a.image_url,
        a.bio,
        a.followers,
        COALESCE(
            (
                SELECT COUNT(lh.id)
                FROM song_artists sa
                INNER JOIN listening_history lh ON sa.song_id = lh.song_id
                WHERE sa.artist_id = a.id
                    AND lh.listened_at > NOW() - INTERVAL '30 days'
            ), 0
        ) as monthly_listeners,
        a.is_verified,
        a.created_at,
        a.updated_at
    FROM artists a
    WHERE a.id = p_artist_id;
END;
$$;

-- Get recommended songs
CREATE OR REPLACE FUNCTION fn_get_recommended_songs(
    p_user_id UUID,
    p_genre_limit INTEGER DEFAULT 5,
    p_songs_per_genre INTEGER DEFAULT 2
)
RETURNS TABLE (
    id UUID,
    title VARCHAR,
    duration INTEGER,
    audio_url TEXT,
    cover_url TEXT,
    album_name VARCHAR,
    album_id UUID,
    artist_name TEXT,
    artist_names TEXT[],
    artist_ids UUID[],
    genre_id UUID,
    genre_name VARCHAR,
    play_count INTEGER
) 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    WITH recent_genres AS (
        -- Lấy 5 thể loại đã nghe gần nhất
        SELECT DISTINCT sg.genre_id
        FROM listening_history lh
        INNER JOIN song_genres sg ON lh.song_id = sg.song_id
        WHERE lh.user_id = p_user_id
            AND lh.listened_at > NOW() - INTERVAL '30 days'
        ORDER BY sg.genre_id
        LIMIT p_genre_limit
    ),
    ranked_songs AS (
        -- Lấy bài hát theo thể loại, rank theo play_count
        SELECT 
            s.id,
            s.title,
            s.duration,
            s.audio_url,
            s.cover_url,
            a.name as album_name,
            s.album_id,
            sg.genre_id,
            g.name as genre_name,
            s.play_count,
            ROW_NUMBER() OVER (PARTITION BY sg.genre_id ORDER BY s.play_count DESC, RANDOM()) as rn
        FROM songs s
        INNER JOIN song_genres sg ON s.id = sg.song_id
        INNER JOIN genres g ON sg.genre_id = g.id
        LEFT JOIN albums a ON s.album_id = a.id
        WHERE sg.genre_id IN (SELECT genre_id FROM recent_genres)
            -- Loại trừ các bài đã nghe trong 7 ngày gần đây
            AND s.id NOT IN (
                SELECT lh2.song_id 
                FROM listening_history lh2 
                WHERE lh2.user_id = p_user_id 
                    AND lh2.listened_at > NOW() - INTERVAL '7 days'
            )
    )
    SELECT 
        rs.id,
        rs.title,
        rs.duration,
        rs.audio_url,
        rs.cover_url,
        rs.album_name,
        rs.album_id,
        STRING_AGG(DISTINCT art.name, ', ')::TEXT as artist_name,
        ARRAY_AGG(DISTINCT art.name)::TEXT[] as artist_names,
        ARRAY_AGG(DISTINCT art.id)::UUID[] as artist_ids,
        rs.genre_id,
        rs.genre_name,
        rs.play_count
    FROM ranked_songs rs
    LEFT JOIN song_artists sa ON rs.id = sa.song_id
    LEFT JOIN artists art ON sa.artist_id = art.id
    WHERE rs.rn <= p_songs_per_genre
    GROUP BY rs.id, rs.title, rs.duration, rs.audio_url, rs.cover_url, 
             rs.album_name, rs.album_id, rs.genre_id, rs.genre_name, rs.play_count
    ORDER BY rs.genre_id, rs.rn;
END;
$$;

-- =====================
-- PHẦN 5: MAINTENANCE FUNCTIONS
-- =====================

-- Update monthly listeners for all artists
CREATE OR REPLACE FUNCTION fn_update_monthly_listeners()
RETURNS VOID 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
BEGIN
    UPDATE artists a
    SET monthly_listeners = (
        SELECT COUNT(DISTINCT lh.user_id)
        FROM song_artists sa
        JOIN listening_history lh ON sa.song_id = lh.song_id
        WHERE sa.artist_id = a.id
        AND lh.listened_at > NOW() - INTERVAL '30 days'
    );
END;
$$;

-- =====================
-- PHẦN 6: GRANT PERMISSIONS
-- =====================
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated, service_role;

-- =====================
-- PHẦN 7: THÔNG BÁO HOÀN THÀNH
-- =====================
SELECT 'P04: Functions created successfully! Run p05_configure_security.sql next.' as status;
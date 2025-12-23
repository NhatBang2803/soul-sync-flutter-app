import { supabase } from '@/lib/supabase'
import type { Artist, Genre, Album, Song, Playlist, User, Podcast, PodcastEpisode } from '@/schemas'

// ============ ARTISTS ============
export const artistService = {
    async getAll() {
        const { data, error } = await supabase
            .from('artists')
            .select('*')
            .order('name')
        if (error) throw error
        return data as Artist[]
    },

    async getById(id: string) {
        const { data, error } = await supabase
            .from('artists')
            .select('*')
            .eq('id', id)
            .single()
        if (error) throw error
        return data as Artist
    },

    async create(artist: Omit<Artist, 'id' | 'created_at'>) {
        const { data, error } = await supabase
            .from('artists')
            .insert(artist)
            .select()
            .single()
        if (error) throw error
        return data as Artist
    },

    async update(id: string, artist: Partial<Artist>) {
        const { data, error } = await supabase
            .from('artists')
            .update(artist)
            .eq('id', id)
            .select()
            .single()
        if (error) throw error
        return data as Artist
    },

    async delete(id: string) {
        const { error } = await supabase.from('artists').delete().eq('id', id)
        if (error) throw error
    },
}

// ============ GENRES ============
export const genreService = {
    async getAll() {
        const { data, error } = await supabase
            .from('genres')
            .select('*')
            .order('name')
        if (error) throw error
        return data as Genre[]
    },

    async getById(id: string) {
        const { data, error } = await supabase
            .from('genres')
            .select('*')
            .eq('id', id)
            .single()
        if (error) throw error
        return data as Genre
    },

    async create(genre: Omit<Genre, 'id' | 'created_at'>) {
        const { data, error } = await supabase
            .from('genres')
            .insert(genre)
            .select()
            .single()
        if (error) throw error
        return data as Genre
    },

    async update(id: string, genre: Partial<Genre>) {
        const { data, error } = await supabase
            .from('genres')
            .update(genre)
            .eq('id', id)
            .select()
            .single()
        if (error) throw error
        return data as Genre
    },

    async delete(id: string) {
        const { error } = await supabase.from('genres').delete().eq('id', id)
        if (error) throw error
    },
}

// ============ ALBUMS ============
export const albumService = {
    async getAll() {
        const { data, error } = await supabase
            .from('albums')
            .select('*')
            .order('name')
        if (error) throw error
        return data as Album[]
    },

    async getById(id: string) {
        const { data, error } = await supabase
            .from('albums')
            .select('*')
            .eq('id', id)
            .single()
        if (error) throw error
        return data as Album
    },

    async create(album: Omit<Album, 'id' | 'created_at'>) {
        const { data, error } = await supabase
            .from('albums')
            .insert(album)
            .select()
            .single()
        if (error) throw error
        return data as Album
    },

    async update(id: string, album: Partial<Album>) {
        const { data, error } = await supabase
            .from('albums')
            .update(album)
            .eq('id', id)
            .select()
            .single()
        if (error) throw error
        return data as Album
    },

    async delete(id: string) {
        const { error } = await supabase.from('albums').delete().eq('id', id)
        if (error) throw error
    },

    async getArtists(albumId: string) {
        const { data, error } = await supabase
            .from('album_artists')
            .select('artist_id, artists(*)')
            .eq('album_id', albumId)
        if (error) throw error
        return data
    },

    async setArtists(albumId: string, artistIds: string[]) {
        // Remove existing
        await supabase.from('album_artists').delete().eq('album_id', albumId)
        // Add new
        if (artistIds.length > 0) {
            const { error } = await supabase.from('album_artists').insert(
                artistIds.map((artistId) => ({ album_id: albumId, artist_id: artistId }))
            )
            if (error) throw error
        }
    },

    async updateSongCount(albumId: string) {
        const { count, error } = await supabase
            .from('album_songs')
            .select('*', { count: 'exact', head: true })
            .eq('album_id', albumId)
        if (error) throw error
        await supabase.from('albums').update({ song_count: count || 0 }).eq('id', albumId)
    },

    async syncArtistsFromSongs(albumId: string) {
        // Get all songs in this album
        const { data: albumSongs, error: songsError } = await supabase
            .from('album_songs')
            .select('song_id')
            .eq('album_id', albumId)
        if (songsError) throw songsError

        if (!albumSongs || albumSongs.length === 0) return

        // Get all artists from these songs
        const songIds = albumSongs.map(s => s.song_id)
        const { data: songArtists, error: artistsError } = await supabase
            .from('song_artists')
            .select('artist_id')
            .in('song_id', songIds)
        if (artistsError) throw artistsError

        if (!songArtists || songArtists.length === 0) return

        // Collect unique artist IDs
        const uniqueArtistIds = [...new Set(songArtists.map(sa => sa.artist_id))]

        // Get existing album artists
        const { data: existingArtists } = await supabase
            .from('album_artists')
            .select('artist_id')
            .eq('album_id', albumId)

        const existingIds = new Set(existingArtists?.map(a => a.artist_id) || [])

        // Add only new artists (avoid duplicates)
        const newArtistIds = uniqueArtistIds.filter(id => !existingIds.has(id))

        if (newArtistIds.length > 0) {
            await supabase.from('album_artists').insert(
                newArtistIds.map(artistId => ({ album_id: albumId, artist_id: artistId }))
            )
        }
    },
}

// ============ SONGS ============
export const songService = {
    async getAll() {
        const { data, error } = await supabase
            .from('songs')
            .select('*')
            .order('title')
        if (error) throw error
        return data as Song[]
    },

    async getById(id: string) {
        const { data, error } = await supabase
            .from('songs')
            .select('*')
            .eq('id', id)
            .single()
        if (error) throw error
        return data as Song
    },

    async create(song: Omit<Song, 'id' | 'created_at'>) {
        const { data, error } = await supabase
            .from('songs')
            .insert(song)
            .select()
            .single()
        if (error) throw error
        return data as Song
    },

    async update(id: string, song: Partial<Song>) {
        const { data, error } = await supabase
            .from('songs')
            .update(song)
            .eq('id', id)
            .select()
            .single()
        if (error) throw error
        return data as Song
    },

    async delete(id: string) {
        const { error } = await supabase.from('songs').delete().eq('id', id)
        if (error) throw error
    },

    async getArtists(songId: string) {
        const { data, error } = await supabase
            .from('song_artists')
            .select('artist_id, artists(*)')
            .eq('song_id', songId)
        if (error) throw error
        return data
    },

    async setArtists(songId: string, artistIds: string[]) {
        await supabase.from('song_artists').delete().eq('song_id', songId)
        if (artistIds.length > 0) {
            const { error } = await supabase.from('song_artists').insert(
                artistIds.map((artistId) => ({ song_id: songId, artist_id: artistId }))
            )
            if (error) throw error
        }
    },

    async getGenres(songId: string) {
        const { data, error } = await supabase
            .from('song_genres')
            .select('genre_id, genres(*)')
            .eq('song_id', songId)
        if (error) throw error
        return data
    },

    async setGenres(songId: string, genreIds: string[]) {
        await supabase.from('song_genres').delete().eq('song_id', songId)
        if (genreIds.length > 0) {
            const { error } = await supabase.from('song_genres').insert(
                genreIds.map((genreId) => ({ song_id: songId, genre_id: genreId }))
            )
            if (error) throw error
        }
    },

    async setAlbum(songId: string, albumId: string, trackNumber: number = 1) {
        // Remove existing album links for this song
        await supabase.from('album_songs').delete().eq('song_id', songId)
        // Add new link
        const { error } = await supabase.from('album_songs').insert({
            song_id: songId,
            album_id: albumId,
            track_number: trackNumber,
        })
        if (error) throw error
        // Update album song count
        await albumService.updateSongCount(albumId)
        // Auto-sync album artists from all songs in this album
        await albumService.syncArtistsFromSongs(albumId)
    },

    async getAlbum(songId: string) {
        const { data, error } = await supabase
            .from('album_songs')
            .select('album_id, albums(*)')
            .eq('song_id', songId)
            .maybeSingle()
        if (error) throw error
        return data
    },
}

// ============ PLAYLISTS ============
export const playlistService = {
    async getAll() {
        const { data, error } = await supabase
            .from('playlists')
            .select('*')
            .order('name')
        if (error) throw error
        return data as Playlist[]
    },

    async getById(id: string) {
        const { data, error } = await supabase
            .from('playlists')
            .select('*')
            .eq('id', id)
            .single()
        if (error) throw error
        return data as Playlist
    },

    async create(playlist: Omit<Playlist, 'id' | 'created_at'>) {
        const { data, error } = await supabase
            .from('playlists')
            .insert(playlist)
            .select()
            .single()
        if (error) throw error
        return data as Playlist
    },

    async update(id: string, playlist: Partial<Playlist>) {
        const { data, error } = await supabase
            .from('playlists')
            .update(playlist)
            .eq('id', id)
            .select()
            .single()
        if (error) throw error
        return data as Playlist
    },

    async delete(id: string) {
        const { error } = await supabase.from('playlists').delete().eq('id', id)
        if (error) throw error
    },

    async getSongs(playlistId: string) {
        const { data, error } = await supabase
            .from('playlist_songs')
            .select('song_id, position, songs(*)')
            .eq('playlist_id', playlistId)
            .order('position')
        if (error) throw error
        return data
    },

    async addSong(playlistId: string, songId: string, position: number) {
        const { error } = await supabase
            .from('playlist_songs')
            .insert({ playlist_id: playlistId, song_id: songId, position })
        if (error) throw error
    },

    async removeSong(playlistId: string, songId: string) {
        const { error } = await supabase
            .from('playlist_songs')
            .delete()
            .eq('playlist_id', playlistId)
            .eq('song_id', songId)
        if (error) throw error
    },
}

// ============ USERS ============
export const userService = {
    async getAll() {
        const { data, error } = await supabase
            .from('users')
            .select('*')
            .order('created_at', { ascending: false })
        if (error) throw error
        return data as User[]
    },

    async getById(id: string) {
        const { data, error } = await supabase
            .from('users')
            .select('*')
            .eq('id', id)
            .single()
        if (error) throw error
        return data as User
    },

    async create(user: Omit<User, 'id' | 'created_at'>) {
        const { data, error } = await supabase
            .from('users')
            .insert(user)
            .select()
            .single()
        if (error) throw error
        return data as User
    },

    async update(id: string, user: Partial<User>) {
        const { data, error } = await supabase
            .from('users')
            .update(user)
            .eq('id', id)
            .select()
            .single()
        if (error) throw error
        return data as User
    },

    async delete(id: string) {
        const { error } = await supabase.from('users').delete().eq('id', id)
        if (error) throw error
    },
}

// ============ STATS ============
export const statsService = {
    async getDashboardStats() {
        const [artists, genres, albums, songs, playlists, users, podcasts] = await Promise.all([
            supabase.from('artists').select('id', { count: 'exact', head: true }),
            supabase.from('genres').select('id', { count: 'exact', head: true }),
            supabase.from('albums').select('id', { count: 'exact', head: true }),
            supabase.from('songs').select('id', { count: 'exact', head: true }),
            supabase.from('playlists').select('id', { count: 'exact', head: true }),
            supabase.from('users').select('id', { count: 'exact', head: true }),
            supabase.from('podcasts').select('id', { count: 'exact', head: true }),
        ])

        return {
            artists: artists.count || 0,
            genres: genres.count || 0,
            albums: albums.count || 0,
            songs: songs.count || 0,
            playlists: playlists.count || 0,
            users: users.count || 0,
            podcasts: podcasts.count || 0,
        }
    },
}

// ============ PODCASTS ============
export const podcastService = {
    async getAll() {
        const { data, error } = await supabase
            .from('podcasts')
            .select('*')
            .order('title')
        if (error) throw error
        return data as Podcast[]
    },

    async getById(id: string) {
        const { data, error } = await supabase
            .from('podcasts')
            .select('*')
            .eq('id', id)
            .single()
        if (error) throw error
        return data as Podcast
    },

    async create(podcast: Omit<Podcast, 'id' | 'created_at' | 'updated_at'>) {
        const { data, error } = await supabase
            .from('podcasts')
            .insert(podcast)
            .select()
            .single()
        if (error) throw error
        return data as Podcast
    },

    async update(id: string, podcast: Partial<Podcast>) {
        const { data, error } = await supabase
            .from('podcasts')
            .update({ ...podcast, updated_at: new Date().toISOString() })
            .eq('id', id)
            .select()
            .single()
        if (error) throw error
        return data as Podcast
    },

    async delete(id: string) {
        const { error } = await supabase.from('podcasts').delete().eq('id', id)
        if (error) throw error
    },

    async getEpisodes(podcastId: string) {
        const { data, error } = await supabase
            .from('podcast_episodes')
            .select('*')
            .eq('podcast_id', podcastId)
            .order('published_at', { ascending: false })
        if (error) throw error
        return data as PodcastEpisode[]
    },

    async getEpisodeCount(podcastId: string) {
        const { count, error } = await supabase
            .from('podcast_episodes')
            .select('*', { count: 'exact', head: true })
            .eq('podcast_id', podcastId)
        if (error) throw error
        return count || 0
    },
}

// ============ PODCAST EPISODES ============
export const podcastEpisodeService = {
    async getAll() {
        const { data, error } = await supabase
            .from('podcast_episodes')
            .select('*, podcasts(title)')
            .order('published_at', { ascending: false })
        if (error) throw error
        return data as (PodcastEpisode & { podcasts: { title: string } })[]
    },

    async getById(id: string) {
        const { data, error } = await supabase
            .from('podcast_episodes')
            .select('*')
            .eq('id', id)
            .single()
        if (error) throw error
        return data as PodcastEpisode
    },

    async create(episode: Omit<PodcastEpisode, 'id' | 'created_at' | 'play_count'>) {
        const { data, error } = await supabase
            .from('podcast_episodes')
            .insert({
                ...episode,
                published_at: episode.published_at || new Date().toISOString(),
            })
            .select()
            .single()
        if (error) throw error
        return data as PodcastEpisode
    },

    async update(id: string, episode: Partial<PodcastEpisode>) {
        const { data, error } = await supabase
            .from('podcast_episodes')
            .update(episode)
            .eq('id', id)
            .select()
            .single()
        if (error) throw error
        return data as PodcastEpisode
    },

    async delete(id: string) {
        const { error } = await supabase.from('podcast_episodes').delete().eq('id', id)
        if (error) throw error
    },
}

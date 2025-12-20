import { supabase } from '@/lib/supabase'
import type { Artist, Genre, Album, Song, Playlist, User } from '@/schemas'

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
        const [artists, genres, albums, songs, playlists, users] = await Promise.all([
            supabase.from('artists').select('id', { count: 'exact', head: true }),
            supabase.from('genres').select('id', { count: 'exact', head: true }),
            supabase.from('albums').select('id', { count: 'exact', head: true }),
            supabase.from('songs').select('id', { count: 'exact', head: true }),
            supabase.from('playlists').select('id', { count: 'exact', head: true }),
            supabase.from('users').select('id', { count: 'exact', head: true }),
        ])

        return {
            artists: artists.count || 0,
            genres: genres.count || 0,
            albums: albums.count || 0,
            songs: songs.count || 0,
            playlists: playlists.count || 0,
            users: users.count || 0,
        }
    },
}

import { z } from 'zod'

// Artist Schema
export const artistSchema = z.object({
    id: z.string().uuid().optional(),
    name: z.string().min(1, 'Tên nghệ sĩ không được để trống'),
    image_url: z.string().url().optional().nullable(),
    followers: z.number().int().min(0).default(0),
    monthly_listeners: z.number().int().min(0).default(0),
    is_verified: z.boolean().default(false),
    bio: z.string().optional().nullable(),
    created_at: z.string().optional(),
})

export type Artist = z.infer<typeof artistSchema>

// Genre Schema
export const genreSchema = z.object({
    id: z.string().uuid().optional(),
    name: z.string().min(1, 'Mã thể loại không được để trống'),
    display_name: z.string().min(1, 'Tên hiển thị không được để trống'),
    color: z.string().regex(/^#([0-9a-fA-F]{3}){1,2}$/, 'Màu không hợp lệ').optional(),
    created_at: z.string().optional(),
})

export type Genre = z.infer<typeof genreSchema>

// Album Schema
export const albumSchema = z.object({
    id: z.string().uuid().optional(),
    name: z.string().min(1, 'Tên album không được để trống'),
    cover_url: z.string().url().optional().nullable(),
    release_year: z.number().int().min(1900).max(new Date().getFullYear() + 1).optional(),
    song_count: z.number().int().min(0).default(0),
    listen_count: z.number().int().min(0).default(0),
    is_public: z.boolean().default(true),
    created_at: z.string().optional(),
})

export type Album = z.infer<typeof albumSchema>

// Song Schema
export const songSchema = z.object({
    id: z.string().uuid().optional(),
    title: z.string().min(1, 'Tên bài hát không được để trống'),
    audio_url: z.string().url('URL audio không hợp lệ'),
    cover_url: z.string().url().optional().nullable(),
    duration: z.number().int().min(0).default(0),
    play_count: z.number().int().min(0).default(0),
    created_at: z.string().optional(),
})

export type Song = z.infer<typeof songSchema>

// Playlist Schema
export const playlistSchema = z.object({
    id: z.string().uuid().optional(),
    name: z.string().min(1, 'Tên playlist không được để trống'),
    description: z.string().optional().nullable(),
    cover_url: z.string().url().optional().nullable(),
    owner_id: z.string().uuid().optional().nullable(),
    is_public: z.boolean().default(true),
    song_count: z.number().int().min(0).default(0),
    listen_count: z.number().int().min(0).default(0),
    created_at: z.string().optional(),
})

export type Playlist = z.infer<typeof playlistSchema>

// User Schema
export const userSchema = z.object({
    id: z.string().uuid().optional(),
    email: z.string().email().optional().nullable(),
    username: z.string().optional().nullable(),
    display_name: z.string().optional().nullable(),
    avatar_url: z.string().url().optional().nullable(),
    password_hash: z.string().optional().nullable(),
    auth_method: z.enum(['local', 'google']).default('local'),
    created_at: z.string().optional(),
})

export type User = z.infer<typeof userSchema>

// Podcast Schema
export const podcastSchema = z.object({
    id: z.string().uuid().optional(),
    title: z.string().min(1, 'Tên podcast không được để trống'),
    host_name: z.string().min(1, 'Tên host không được để trống'),
    description: z.string().optional().nullable(),
    image_url: z.string().url().optional().nullable(),
    category: z.string().default('General'),
    created_at: z.string().optional(),
    updated_at: z.string().optional(),
})

export type Podcast = z.infer<typeof podcastSchema>

// Podcast Episode Schema
export const podcastEpisodeSchema = z.object({
    id: z.string().uuid().optional(),
    podcast_id: z.string().uuid(),
    title: z.string().min(1, 'Tiêu đề tập không được để trống'),
    description: z.string().optional().nullable(),
    audio_url: z.string().url('URL audio không hợp lệ'),
    duration: z.number().int().min(0).default(0),
    play_count: z.number().int().min(0).default(0),
    published_at: z.string().optional(),
    created_at: z.string().optional(),
})

export type PodcastEpisode = z.infer<typeof podcastEpisodeSchema>

import { Song, Playlist, Album, Artist } from '../types/music';

export const mockSongs: Song[] = [
  {
    id: '1',
    title: 'Midnight Dreams',
    artist: 'Luna Echo',
    album: 'Neon Nights',
    duration: 245,
    coverUrl: 'https://images.unsplash.com/photo-1616663395403-2e0052b8e595?w=400',
    isLiked: true,
  },
  {
    id: '2',
    title: 'Electric Soul',
    artist: 'The Waves',
    album: 'Modern Classics',
    duration: 198,
    coverUrl: 'https://images.unsplash.com/photo-1603850121303-d4ade9e5ba65?w=400',
    isLiked: false,
  },
  {
    id: '3',
    title: 'Urban Sunrise',
    artist: 'DJ Nova',
    album: 'City Sounds',
    duration: 312,
    coverUrl: 'https://images.unsplash.com/photo-1642177451842-31bcbb88bc9f?w=400',
    isLiked: true,
  },
  {
    id: '4',
    title: 'Rhythm & Flow',
    artist: 'Beat Masters',
    album: 'Pure Energy',
    duration: 267,
    coverUrl: 'https://images.unsplash.com/photo-1524368535928-5b5e00ddc76b?w=400',
    isLiked: false,
  },
  {
    id: '5',
    title: 'Stellar Vibes',
    artist: 'Luna Echo',
    album: 'Cosmic Journey',
    duration: 289,
    coverUrl: 'https://images.unsplash.com/photo-1649956736509-f359d191bbcb?w=400',
    isLiked: true,
  },
];

export const mockPlaylists: Playlist[] = [
  {
    id: 'p1',
    name: 'Chill Vibes',
    description: 'Thư giãn cùng những giai điệu êm dịu',
    coverUrl: 'https://images.unsplash.com/photo-1616663395403-2e0052b8e595?w=400',
    songCount: 42,
  },
  {
    id: 'p2',
    name: 'Workout Mix',
    description: 'Năng lượng tối đa cho buổi tập',
    coverUrl: 'https://images.unsplash.com/photo-1524368535928-5b5e00ddc76b?w=400',
    songCount: 38,
  },
  {
    id: 'p3',
    name: 'Night Drive',
    description: 'Âm nhạc cho những chuyến đi đêm',
    coverUrl: 'https://images.unsplash.com/photo-1642177451842-31bcbb88bc9f?w=400',
    songCount: 25,
  },
  {
    id: 'p4',
    name: 'Focus Flow',
    description: 'Tập trung làm việc hiệu quả',
    coverUrl: 'https://images.unsplash.com/photo-1603850121303-d4ade9e5ba65?w=400',
    songCount: 56,
  },
];

export const mockAlbums: Album[] = [
  {
    id: 'a1',
    name: 'Neon Nights',
    artist: 'Luna Echo',
    coverUrl: 'https://images.unsplash.com/photo-1616663395403-2e0052b8e595?w=400',
    year: 2024,
    songCount: 12,
  },
  {
    id: 'a2',
    name: 'Modern Classics',
    artist: 'The Waves',
    coverUrl: 'https://images.unsplash.com/photo-1603850121303-d4ade9e5ba65?w=400',
    year: 2023,
    songCount: 10,
  },
  {
    id: 'a3',
    name: 'City Sounds',
    artist: 'DJ Nova',
    coverUrl: 'https://images.unsplash.com/photo-1642177451842-31bcbb88bc9f?w=400',
    year: 2024,
    songCount: 15,
  },
];

export const mockArtists: Artist[] = [
  {
    id: 'ar1',
    name: 'Luna Echo',
    imageUrl: 'https://images.unsplash.com/photo-1724333192036-304fa9af2423?w=400',
    followers: '2.4M',
  },
  {
    id: 'ar2',
    name: 'The Waves',
    imageUrl: 'https://images.unsplash.com/photo-1524368535928-5b5e00ddc76b?w=400',
    followers: '1.8M',
  },
  {
    id: 'ar3',
    name: 'DJ Nova',
    imageUrl: 'https://images.unsplash.com/photo-1642177451842-31bcbb88bc9f?w=400',
    followers: '3.2M',
  },
  {
    id: 'ar4',
    name: 'Beat Masters',
    imageUrl: 'https://images.unsplash.com/photo-1649956736509-f359d191bbcb?w=400',
    followers: '1.5M',
  },
];

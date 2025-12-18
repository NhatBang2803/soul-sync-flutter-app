export interface Song {
  id: string;
  title: string;
  artist: string;
  album: string;
  duration: number; // in seconds
  coverUrl: string;
  isLiked?: boolean;
}

export interface Playlist {
  id: string;
  name: string;
  description: string;
  coverUrl: string;
  songCount: number;
}

export interface Album {
  id: string;
  name: string;
  artist: string;
  coverUrl: string;
  year: number;
  songCount: number;
}

export interface Artist {
  id: string;
  name: string;
  imageUrl: string;
  followers: string;
}

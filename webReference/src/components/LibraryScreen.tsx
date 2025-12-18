import { useState } from 'react';
import { Plus, Music2, ListMusic, Heart } from 'lucide-react';
import { PlaylistCard } from './PlaylistCard';
import { AlbumCard } from './AlbumCard';
import { SongItem } from './SongItem';
import { mockPlaylists, mockAlbums, mockSongs } from '../data/mockData';

interface LibraryScreenProps {
  onSongPlay: (songId: string) => void;
}

export function LibraryScreen({ onSongPlay }: LibraryScreenProps) {
  const [activeFilter, setActiveFilter] = useState<'all' | 'playlists' | 'albums' | 'liked'>('all');

  const likedSongs = mockSongs.filter(song => song.isLiked);

  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      {/* Header */}
      <div className="bg-zinc-900 px-4 pt-6 pb-4">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-white text-2xl">Thư viện của bạn</h1>
          <button className="text-zinc-400 hover:text-white">
            <Plus className="w-6 h-6" />
          </button>
        </div>

        {/* Filter Pills */}
        <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
          <button
            onClick={() => setActiveFilter('all')}
            className={`px-4 py-2 rounded-full whitespace-nowrap transition-colors ${
              activeFilter === 'all'
                ? 'bg-green-500 text-black'
                : 'bg-zinc-800 text-white hover:bg-zinc-700'
            }`}
          >
            Tất cả
          </button>
          <button
            onClick={() => setActiveFilter('playlists')}
            className={`px-4 py-2 rounded-full whitespace-nowrap transition-colors ${
              activeFilter === 'playlists'
                ? 'bg-green-500 text-black'
                : 'bg-zinc-800 text-white hover:bg-zinc-700'
            }`}
          >
            Playlist
          </button>
          <button
            onClick={() => setActiveFilter('albums')}
            className={`px-4 py-2 rounded-full whitespace-nowrap transition-colors ${
              activeFilter === 'albums'
                ? 'bg-green-500 text-black'
                : 'bg-zinc-800 text-white hover:bg-zinc-700'
            }`}
          >
            Album
          </button>
          <button
            onClick={() => setActiveFilter('liked')}
            className={`px-4 py-2 rounded-full whitespace-nowrap transition-colors ${
              activeFilter === 'liked'
                ? 'bg-green-500 text-black'
                : 'bg-zinc-800 text-white hover:bg-zinc-700'
            }`}
          >
            Đã thích
          </button>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto pb-32">
        {(activeFilter === 'all' || activeFilter === 'liked') && (
          <div className="px-4 py-4">
            <div className="flex items-center gap-4 bg-gradient-to-br from-purple-800 to-purple-900 rounded-lg p-4 mb-6">
              <div className="w-16 h-16 bg-gradient-to-br from-purple-400 to-blue-500 rounded flex items-center justify-center flex-shrink-0">
                <Heart className="w-8 h-8 text-white fill-white" />
              </div>
              <div>
                <h3 className="text-white">Bài hát đã thích</h3>
                <p className="text-purple-200 text-sm">{likedSongs.length} bài hát</p>
              </div>
            </div>
          </div>
        )}

        {(activeFilter === 'all' || activeFilter === 'playlists') && (
          <div className="px-4 py-4">
            <div className="flex items-center gap-2 mb-4">
              <ListMusic className="w-5 h-5 text-zinc-400" />
              <h2 className="text-white text-lg">Playlist của tôi</h2>
            </div>
            <div className="grid grid-cols-2 gap-4">
              {mockPlaylists.map((playlist) => (
                <PlaylistCard key={playlist.id} playlist={playlist} />
              ))}
            </div>
          </div>
        )}

        {(activeFilter === 'all' || activeFilter === 'albums') && (
          <div className="px-4 py-4">
            <div className="flex items-center gap-2 mb-4">
              <Music2 className="w-5 h-5 text-zinc-400" />
              <h2 className="text-white text-lg">Album đã lưu</h2>
            </div>
            <div className="grid grid-cols-2 gap-4">
              {mockAlbums.map((album) => (
                <AlbumCard key={album.id} album={album} />
              ))}
            </div>
          </div>
        )}

        {activeFilter === 'liked' && (
          <div className="px-4 py-4">
            <h2 className="text-white text-lg mb-4">Tất cả bài hát đã thích</h2>
            <div className="space-y-1">
              {likedSongs.map((song) => (
                <SongItem
                  key={song.id}
                  song={song}
                  onPlay={() => onSongPlay(song.id)}
                />
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

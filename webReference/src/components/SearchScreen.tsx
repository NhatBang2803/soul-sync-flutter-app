import { useState } from 'react';
import { Search, X } from 'lucide-react';
import { SongItem } from './SongItem';
import { AlbumCard } from './AlbumCard';
import { ArtistCard } from './ArtistCard';
import { mockSongs, mockAlbums, mockArtists } from '../data/mockData';

interface SearchScreenProps {
  onSongPlay: (songId: string) => void;
  onBack: () => void;
}

export function SearchScreen({ onSongPlay, onBack }: SearchScreenProps) {
  const [searchQuery, setSearchQuery] = useState('');

  const filteredSongs = searchQuery
    ? mockSongs.filter(song =>
        song.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        song.artist.toLowerCase().includes(searchQuery.toLowerCase())
      )
    : [];

  const filteredAlbums = searchQuery
    ? mockAlbums.filter(album =>
        album.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        album.artist.toLowerCase().includes(searchQuery.toLowerCase())
      )
    : [];

  const filteredArtists = searchQuery
    ? mockArtists.filter(artist =>
        artist.name.toLowerCase().includes(searchQuery.toLowerCase())
      )
    : [];

  const hasResults = filteredSongs.length > 0 || filteredAlbums.length > 0 || filteredArtists.length > 0;

  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      {/* Search Header */}
      <div className="bg-zinc-900 px-4 pt-6 pb-4">
        <div className="flex items-center gap-3 bg-zinc-800 rounded-full px-4 py-3">
          <Search className="w-5 h-5 text-zinc-400" />
          <input
            type="text"
            placeholder="Bạn muốn nghe gì?"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="flex-1 bg-transparent text-white placeholder-zinc-400 outline-none"
            autoFocus
          />
          {searchQuery && (
            <button onClick={() => setSearchQuery('')}>
              <X className="w-5 h-5 text-zinc-400" />
            </button>
          )}
        </div>
      </div>

      {/* Search Results or Browse */}
      <div className="flex-1 overflow-y-auto pb-32">
        {!searchQuery ? (
          // Browse Categories
          <div className="px-4 py-6">
            <h2 className="text-white text-xl mb-4">Duyệt tìm</h2>
            <div className="grid grid-cols-2 gap-3">
              {[
                { name: 'Podcast', color: 'bg-green-700', emoji: '🎙️' },
                { name: 'Nhạc sống', color: 'bg-purple-700', emoji: '🎸' },
                { name: 'Nhạc được tạo cho bạn', color: 'bg-blue-700', emoji: '🎵' },
                { name: 'Bảng xếp hạng', color: 'bg-red-700', emoji: '📊' },
                { name: 'Nhạc mới phát hành', color: 'bg-pink-700', emoji: '🆕' },
                { name: 'Nhạc Việt', color: 'bg-orange-700', emoji: '🇻🇳' },
              ].map((category) => (
                <div
                  key={category.name}
                  className={`${category.color} rounded-lg p-4 h-24 flex flex-col justify-between cursor-pointer hover:scale-105 transition-transform`}
                >
                  <span className="text-white">{category.name}</span>
                  <span className="text-3xl self-end">{category.emoji}</span>
                </div>
              ))}
            </div>
          </div>
        ) : hasResults ? (
          // Search Results
          <div>
            {filteredSongs.length > 0 && (
              <div className="px-4 py-6">
                <h2 className="text-white text-xl mb-4">Bài hát</h2>
                <div className="space-y-1">
                  {filteredSongs.map((song) => (
                    <SongItem
                      key={song.id}
                      song={song}
                      onPlay={() => onSongPlay(song.id)}
                    />
                  ))}
                </div>
              </div>
            )}

            {filteredAlbums.length > 0 && (
              <div className="px-4 py-6">
                <h2 className="text-white text-xl mb-4">Album</h2>
                <div className="grid grid-cols-2 gap-4">
                  {filteredAlbums.map((album) => (
                    <AlbumCard key={album.id} album={album} />
                  ))}
                </div>
              </div>
            )}

            {filteredArtists.length > 0 && (
              <div className="px-4 py-6">
                <h2 className="text-white text-xl mb-4">Nghệ sĩ</h2>
                <div className="grid grid-cols-2 gap-4">
                  {filteredArtists.map((artist) => (
                    <ArtistCard key={artist.id} artist={artist} />
                  ))}
                </div>
              </div>
            )}
          </div>
        ) : (
          // No Results
          <div className="flex flex-col items-center justify-center h-full text-center px-4">
            <Search className="w-16 h-16 text-zinc-600 mb-4" />
            <h3 className="text-white text-xl mb-2">Không tìm thấy kết quả</h3>
            <p className="text-zinc-400">
              Hãy thử tìm kiếm với từ khóa khác
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

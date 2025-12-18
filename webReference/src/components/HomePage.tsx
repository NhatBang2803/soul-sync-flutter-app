import { Search } from 'lucide-react';
import { PlaylistCard } from './PlaylistCard';
import { AlbumCard } from './AlbumCard';
import { ArtistCard } from './ArtistCard';
import { mockPlaylists, mockAlbums, mockArtists } from '../data/mockData';

interface HomePageProps {
  onPlaylistClick: (id: string) => void;
  onSearchFocus: () => void;
}

export function HomePage({ onPlaylistClick, onSearchFocus }: HomePageProps) {
  const currentHour = new Date().getHours();
  const greeting = currentHour < 12 ? 'Chào buổi sáng' : currentHour < 18 ? 'Chào buổi chiều' : 'Chào buổi tối';

  return (
    <div className="flex-1 overflow-y-auto pb-32">
      {/* Header */}
      <div className="bg-gradient-to-b from-zinc-800 to-zinc-900 px-4 pt-6 pb-4">
        <h1 className="text-white text-2xl mb-4">{greeting}</h1>
        
        {/* Search Bar */}
        <div 
          onClick={onSearchFocus}
          className="flex items-center gap-3 bg-white rounded-full px-4 py-3 cursor-pointer"
        >
          <Search className="w-5 h-5 text-zinc-900" />
          <span className="text-zinc-500">Bạn muốn nghe gì?</span>
        </div>
      </div>

      {/* Recently Played */}
      <div className="px-4 py-6">
        <h2 className="text-white text-xl mb-4">Phát gần đây</h2>
        <div className="grid grid-cols-2 gap-3">
          {mockPlaylists.slice(0, 4).map((playlist) => (
            <div
              key={playlist.id}
              onClick={() => onPlaylistClick(playlist.id)}
              className="flex items-center gap-3 bg-zinc-800/50 hover:bg-zinc-800 rounded cursor-pointer overflow-hidden"
            >
              <img 
                src={playlist.coverUrl} 
                alt={playlist.name}
                className="w-16 h-16 object-cover"
              />
              <span className="text-white text-sm truncate">{playlist.name}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Playlists */}
      <div className="px-4 py-6">
        <h2 className="text-white text-xl mb-4">Playlist đề xuất</h2>
        <div className="grid grid-cols-2 gap-4">
          {mockPlaylists.map((playlist) => (
            <PlaylistCard 
              key={playlist.id} 
              playlist={playlist}
              onClick={() => onPlaylistClick(playlist.id)}
            />
          ))}
        </div>
      </div>

      {/* Albums */}
      <div className="px-4 py-6">
        <h2 className="text-white text-xl mb-4">Album mới phát hành</h2>
        <div className="grid grid-cols-2 gap-4">
          {mockAlbums.map((album) => (
            <AlbumCard key={album.id} album={album} />
          ))}
        </div>
      </div>

      {/* Artists */}
      <div className="px-4 py-6">
        <h2 className="text-white text-xl mb-4">Nghệ sĩ nổi bật</h2>
        <div className="grid grid-cols-2 gap-4">
          {mockArtists.map((artist) => (
            <ArtistCard key={artist.id} artist={artist} />
          ))}
        </div>
      </div>
    </div>
  );
}

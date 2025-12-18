import { Playlist } from '../types/music';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface PlaylistCardProps {
  playlist: Playlist;
  onClick?: () => void;
}

export function PlaylistCard({ playlist, onClick }: PlaylistCardProps) {
  return (
    <div 
      className="bg-zinc-800/50 hover:bg-zinc-800 rounded-lg p-4 cursor-pointer transition-all duration-200 group"
      onClick={onClick}
    >
      <div className="relative mb-4 aspect-square rounded-md overflow-hidden shadow-lg">
        <ImageWithFallback
          src={playlist.coverUrl}
          alt={playlist.name}
          className="w-full h-full object-cover"
        />
      </div>
      <h3 className="text-white mb-1 truncate">{playlist.name}</h3>
      <p className="text-zinc-400 text-sm truncate">{playlist.description}</p>
      <p className="text-zinc-500 text-xs mt-1">{playlist.songCount} bài hát</p>
    </div>
  );
}

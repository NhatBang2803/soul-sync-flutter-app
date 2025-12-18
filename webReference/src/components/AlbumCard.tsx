import { Album } from '../types/music';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface AlbumCardProps {
  album: Album;
  onClick?: () => void;
}

export function AlbumCard({ album, onClick }: AlbumCardProps) {
  return (
    <div 
      className="bg-zinc-800/50 hover:bg-zinc-800 rounded-lg p-4 cursor-pointer transition-all duration-200"
      onClick={onClick}
    >
      <div className="relative mb-4 aspect-square rounded-md overflow-hidden shadow-lg">
        <ImageWithFallback
          src={album.coverUrl}
          alt={album.name}
          className="w-full h-full object-cover"
        />
      </div>
      <h3 className="text-white mb-1 truncate">{album.name}</h3>
      <p className="text-zinc-400 text-sm truncate">{album.artist}</p>
      <p className="text-zinc-500 text-xs mt-1">{album.year} • {album.songCount} bài hát</p>
    </div>
  );
}

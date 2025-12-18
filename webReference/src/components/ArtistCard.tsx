import { Artist } from '../types/music';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface ArtistCardProps {
  artist: Artist;
  onClick?: () => void;
}

export function ArtistCard({ artist, onClick }: ArtistCardProps) {
  return (
    <div 
      className="bg-zinc-800/50 hover:bg-zinc-800 rounded-lg p-4 cursor-pointer transition-all duration-200"
      onClick={onClick}
    >
      <div className="relative mb-4 aspect-square rounded-full overflow-hidden shadow-lg">
        <ImageWithFallback
          src={artist.imageUrl}
          alt={artist.name}
          className="w-full h-full object-cover"
        />
      </div>
      <h3 className="text-white mb-1 truncate text-center">{artist.name}</h3>
      <p className="text-zinc-400 text-sm text-center">Nghệ sĩ</p>
      <p className="text-zinc-500 text-xs text-center mt-1">{artist.followers} người theo dõi</p>
    </div>
  );
}

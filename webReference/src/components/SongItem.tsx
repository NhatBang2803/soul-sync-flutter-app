import { Song } from '../types/music';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { Heart, MoreVertical, Play } from 'lucide-react';

interface SongItemProps {
  song: Song;
  onPlay?: () => void;
  onLike?: () => void;
  showCover?: boolean;
}

export function SongItem({ song, onPlay, onLike, showCover = true }: SongItemProps) {
  const formatDuration = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <div className="flex items-center gap-3 p-2 rounded-lg hover:bg-zinc-800/50 group cursor-pointer">
      {showCover && (
        <div className="relative w-12 h-12 flex-shrink-0">
          <ImageWithFallback
            src={song.coverUrl}
            alt={song.album}
            className="w-full h-full object-cover rounded"
          />
          <div 
            onClick={onPlay}
            className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center"
          >
            <Play className="w-5 h-5 text-white fill-white" />
          </div>
        </div>
      )}
      
      <div className="flex-1 min-w-0">
        <h4 className="text-white truncate">{song.title}</h4>
        <p className="text-zinc-400 text-sm truncate">{song.artist}</p>
      </div>
      
      <button
        onClick={(e) => {
          e.stopPropagation();
          onLike?.();
        }}
        className="opacity-0 group-hover:opacity-100 transition-opacity"
      >
        <Heart 
          className={`w-5 h-5 ${song.isLiked ? 'text-green-500 fill-green-500' : 'text-zinc-400'}`}
        />
      </button>
      
      <span className="text-zinc-400 text-sm">{formatDuration(song.duration)}</span>
      
      <button className="opacity-0 group-hover:opacity-100 transition-opacity">
        <MoreVertical className="w-5 h-5 text-zinc-400" />
      </button>
    </div>
  );
}

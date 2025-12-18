import { Song } from '../types/music';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { Heart, Play, Pause, SkipForward } from 'lucide-react';

interface MiniPlayerProps {
  song: Song;
  isPlaying: boolean;
  onPlayPause: () => void;
  onNext: () => void;
  onExpand: () => void;
  onLike: () => void;
}

export function MiniPlayer({ song, isPlaying, onPlayPause, onNext, onExpand, onLike }: MiniPlayerProps) {
  return (
    <div className="fixed bottom-16 left-0 right-0 bg-zinc-900 border-t border-zinc-800 p-3">
      <div className="flex items-center gap-3">
        <div 
          className="w-12 h-12 flex-shrink-0 cursor-pointer"
          onClick={onExpand}
        >
          <ImageWithFallback
            src={song.coverUrl}
            alt={song.album}
            className="w-full h-full object-cover rounded"
          />
        </div>
        
        <div className="flex-1 min-w-0" onClick={onExpand}>
          <h4 className="text-white text-sm truncate">{song.title}</h4>
          <p className="text-zinc-400 text-xs truncate">{song.artist}</p>
        </div>
        
        <button
          onClick={(e) => {
            e.stopPropagation();
            onLike();
          }}
        >
          <Heart 
            className={`w-5 h-5 ${song.isLiked ? 'text-green-500 fill-green-500' : 'text-zinc-400'}`}
          />
        </button>
        
        <button 
          onClick={onPlayPause}
          className="w-8 h-8 bg-white rounded-full flex items-center justify-center hover:scale-105 transition-transform"
        >
          {isPlaying ? (
            <Pause className="w-4 h-4 text-black fill-black" />
          ) : (
            <Play className="w-4 h-4 text-black fill-black ml-0.5" />
          )}
        </button>
        
        <button onClick={onNext}>
          <SkipForward className="w-5 h-5 text-zinc-400" />
        </button>
      </div>
    </div>
  );
}

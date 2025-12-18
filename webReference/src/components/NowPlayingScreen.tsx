import { useState, useEffect } from 'react';
import { ChevronDown, Heart, MoreVertical, Shuffle, SkipBack, Play, Pause, SkipForward, Repeat } from 'lucide-react';
import { Song } from '../types/music';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface NowPlayingScreenProps {
  song: Song;
  isPlaying: boolean;
  onPlayPause: () => void;
  onNext: () => void;
  onPrevious: () => void;
  onClose: () => void;
  onLike: () => void;
}

export function NowPlayingScreen({
  song,
  isPlaying,
  onPlayPause,
  onNext,
  onPrevious,
  onClose,
  onLike,
}: NowPlayingScreenProps) {
  const [progress, setProgress] = useState(0);
  const [currentTime, setCurrentTime] = useState(0);
  const [isShuffled, setIsShuffled] = useState(false);
  const [repeatMode, setRepeatMode] = useState<'off' | 'all' | 'one'>('off');

  useEffect(() => {
    if (isPlaying) {
      const interval = setInterval(() => {
        setCurrentTime((prev) => {
          if (prev >= song.duration) {
            return 0;
          }
          return prev + 1;
        });
        setProgress((prev) => {
          if (prev >= 100) {
            return 0;
          }
          return (prev + (100 / song.duration));
        });
      }, 1000);

      return () => clearInterval(interval);
    }
  }, [isPlaying, song.duration]);

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const handleProgressClick = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const percentage = (x / rect.width) * 100;
    setProgress(percentage);
    setCurrentTime((percentage / 100) * song.duration);
  };

  const handleRepeatToggle = () => {
    setRepeatMode((prev) => {
      if (prev === 'off') return 'all';
      if (prev === 'all') return 'one';
      return 'off';
    });
  };

  return (
    <div className="fixed inset-0 bg-gradient-to-b from-zinc-800 via-zinc-900 to-black z-50 flex flex-col">
      {/* Header */}
      <div className="flex items-center justify-between px-4 pt-6 pb-4">
        <button onClick={onClose}>
          <ChevronDown className="w-7 h-7 text-white" />
        </button>
        <div className="text-center flex-1">
          <p className="text-white text-xs">ĐANG PHÁT TỪ PLAYLIST</p>
          <p className="text-white text-sm">Daily Mix</p>
        </div>
        <button>
          <MoreVertical className="w-6 h-6 text-white" />
        </button>
      </div>

      {/* Album Art */}
      <div className="flex-1 flex items-center justify-center px-6 py-8">
        <div className="w-full max-w-md aspect-square rounded-lg overflow-hidden shadow-2xl">
          <ImageWithFallback
            src={song.coverUrl}
            alt={song.album}
            className="w-full h-full object-cover"
          />
        </div>
      </div>

      {/* Song Info */}
      <div className="px-6 py-4">
        <div className="flex items-start justify-between mb-2">
          <div className="flex-1">
            <h1 className="text-white text-2xl mb-2">{song.title}</h1>
            <p className="text-zinc-400">{song.artist}</p>
          </div>
          <button onClick={onLike}>
            <Heart 
              className={`w-7 h-7 ${song.isLiked ? 'text-green-500 fill-green-500' : 'text-zinc-400'}`}
            />
          </button>
        </div>
      </div>

      {/* Progress Bar */}
      <div className="px-6 py-2">
        <div 
          className="h-1 bg-zinc-700 rounded-full cursor-pointer group"
          onClick={handleProgressClick}
        >
          <div 
            className="h-full bg-white rounded-full relative"
            style={{ width: `${progress}%` }}
          >
            <div className="absolute right-0 top-1/2 -translate-y-1/2 w-3 h-3 bg-white rounded-full opacity-0 group-hover:opacity-100 transition-opacity" />
          </div>
        </div>
        <div className="flex justify-between mt-2 text-xs text-zinc-400">
          <span>{formatTime(currentTime)}</span>
          <span>{formatTime(song.duration)}</span>
        </div>
      </div>

      {/* Controls */}
      <div className="px-6 py-6 pb-8">
        <div className="flex items-center justify-between mb-6">
          <button
            onClick={() => setIsShuffled(!isShuffled)}
            className={isShuffled ? 'text-green-500' : 'text-zinc-400'}
          >
            <Shuffle className="w-5 h-5" />
          </button>
          <button onClick={onPrevious}>
            <SkipBack className="w-8 h-8 text-zinc-400 fill-zinc-400" />
          </button>
          <button
            onClick={onPlayPause}
            className="w-16 h-16 bg-white rounded-full flex items-center justify-center hover:scale-105 transition-transform"
          >
            {isPlaying ? (
              <Pause className="w-8 h-8 text-black fill-black" />
            ) : (
              <Play className="w-8 h-8 text-black fill-black ml-1" />
            )}
          </button>
          <button onClick={onNext}>
            <SkipForward className="w-8 h-8 text-zinc-400 fill-zinc-400" />
          </button>
          <button
            onClick={handleRepeatToggle}
            className={repeatMode !== 'off' ? 'text-green-500' : 'text-zinc-400'}
          >
            <div className="relative">
              <Repeat className="w-5 h-5" />
              {repeatMode === 'one' && (
                <span className="absolute -top-1 -right-1 text-[10px]">1</span>
              )}
            </div>
          </button>
        </div>
      </div>
    </div>
  );
}

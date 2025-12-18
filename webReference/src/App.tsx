import { useState } from 'react';
import { HomePage } from './components/HomePage';
import { SearchScreen } from './components/SearchScreen';
import { LibraryScreen } from './components/LibraryScreen';
import { NowPlayingScreen } from './components/NowPlayingScreen';
import { ProfileScreen } from './components/ProfileScreen';
import { MiniPlayer } from './components/MiniPlayer';
import { BottomNav } from './components/BottomNav';
import { mockSongs } from './data/mockData';

type Tab = 'home' | 'search' | 'library' | 'profile';

export default function App() {
  const [activeTab, setActiveTab] = useState<Tab>('home');
  const [currentSongIndex, setCurrentSongIndex] = useState(0);
  const [isPlaying, setIsPlaying] = useState(false);
  const [showNowPlaying, setShowNowPlaying] = useState(false);
  const [songs, setSongs] = useState(mockSongs);

  const currentSong = songs[currentSongIndex];

  const handlePlayPause = () => {
    setIsPlaying(!isPlaying);
  };

  const handleNext = () => {
    setCurrentSongIndex((prev) => (prev + 1) % songs.length);
    setIsPlaying(true);
  };

  const handlePrevious = () => {
    setCurrentSongIndex((prev) => (prev - 1 + songs.length) % songs.length);
    setIsPlaying(true);
  };

  const handleSongPlay = (songId: string) => {
    const index = songs.findIndex(song => song.id === songId);
    if (index !== -1) {
      setCurrentSongIndex(index);
      setIsPlaying(true);
      setShowNowPlaying(true);
    }
  };

  const handleLike = () => {
    setSongs(prevSongs =>
      prevSongs.map((song, idx) =>
        idx === currentSongIndex
          ? { ...song, isLiked: !song.isLiked }
          : song
      )
    );
  };

  const handleSearchFocus = () => {
    setActiveTab('search');
  };

  const handlePlaylistClick = (playlistId: string) => {
    // In a real app, this would load the playlist songs
    setCurrentSongIndex(0);
    setIsPlaying(true);
  };

  return (
    <div className="h-screen bg-black flex flex-col max-w-md mx-auto relative overflow-hidden">
      {/* Main Content */}
      {activeTab === 'home' && (
        <HomePage 
          onPlaylistClick={handlePlaylistClick}
          onSearchFocus={handleSearchFocus}
        />
      )}
      {activeTab === 'search' && (
        <SearchScreen 
          onSongPlay={handleSongPlay}
          onBack={() => setActiveTab('home')}
        />
      )}
      {activeTab === 'library' && (
        <LibraryScreen onSongPlay={handleSongPlay} />
      )}
      {activeTab === 'profile' && <ProfileScreen />}

      {/* Mini Player */}
      {!showNowPlaying && currentSong && (
        <MiniPlayer
          song={currentSong}
          isPlaying={isPlaying}
          onPlayPause={handlePlayPause}
          onNext={handleNext}
          onExpand={() => setShowNowPlaying(true)}
          onLike={handleLike}
        />
      )}

      {/* Bottom Navigation */}
      <BottomNav activeTab={activeTab} onTabChange={setActiveTab} />

      {/* Now Playing Screen */}
      {showNowPlaying && (
        <NowPlayingScreen
          song={currentSong}
          isPlaying={isPlaying}
          onPlayPause={handlePlayPause}
          onNext={handleNext}
          onPrevious={handlePrevious}
          onClose={() => setShowNowPlaying(false)}
          onLike={handleLike}
        />
      )}
    </div>
  );
}

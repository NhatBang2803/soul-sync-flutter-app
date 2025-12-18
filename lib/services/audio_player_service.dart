import 'package:just_audio/just_audio.dart';

/// Service để quản lý audio player
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  
  // Current playlist
  List<Map<String, dynamic>> _playlist = [];
  int _currentIndex = 0;

  // Getters
  AudioPlayer get player => _player;
  List<Map<String, dynamic>> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  Map<String, dynamic>? get currentSong => 
      _playlist.isEmpty ? null : _playlist[_currentIndex];

  // Stream getters
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;

  /// Play a song from URL
  Future<void> playSong(Map<String, dynamic> song) async {
    try {
      // Dừng player trước khi load URL mới
      await _player.stop();
      
      // Lấy URL từ audio_url hoặc audioUrl (camelCase) hoặc fileUrl (Firebase)
      // Hỗ trợ cả snake_case và camelCase
      final audioUrl = song['audio_url'] ?? song['audioUrl'] ?? song['fileUrl'];
      
      print('🔍 Looking for audio URL in song data...');
      print('📋 Song keys: ${song.keys.toList()}');
      print('🎵 Found audioUrl: $audioUrl');
      
      if (audioUrl != null && audioUrl.toString().startsWith('http')) {
        print('🎵 Playing from URL: $audioUrl');
        
        // Set audio source với các options
        await _player.setAudioSource(
          AudioSource.uri(
            Uri.parse(audioUrl),
            headers: {
              'User-Agent': 'MusicApp/1.0',
            },
          ),
        );
        await _player.play();
        print('✅ Audio started playing successfully');
      } else {
        // Demo: Phát một URL mẫu (cần thay bằng URL thật)
        print('⚠️ Song URL not available: ${song['title'] ?? song['songName']}');
        print('📋 Full song data: $song');
        // Demo URL (thay bằng URL thật)
        await _player.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
        await _player.play();
      }
    } catch (e) {
      print('❌ Error playing song: $e');
      // Thử phát fallback URL nếu lỗi
      try {
        print('🔄 Trying fallback URL...');
        await _player.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
        await _player.play();
      } catch (fallbackError) {
        print('❌ Fallback also failed: $fallbackError');
      }
    }
  }

  /// Set playlist and play from index
  Future<void> setPlaylist(List<Map<String, dynamic>> songs, int startIndex) async {
    _playlist = songs;
    _currentIndex = startIndex;
    await playSong(_playlist[_currentIndex]);
  }

  /// Play/Pause toggle
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  /// Play next song
  Future<void> playNext() async {
    if (_playlist.isEmpty) return;
    
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    await playSong(_playlist[_currentIndex]);
  }

  /// Play previous song
  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;
    
    _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    await playSong(_playlist[_currentIndex]);
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Stop and clear
  Future<void> stop() async {
    await _player.stop();
    _playlist.clear();
    _currentIndex = 0;
  }

  /// Dispose
  void dispose() {
    _player.dispose();
  }

  /// Format duration to mm:ss
  String formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

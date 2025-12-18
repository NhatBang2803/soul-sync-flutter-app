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
      // Nếu có URL thật từ Firebase Storage
      if (song['fileUrl'] != null && song['fileUrl'].toString().startsWith('http')) {
        await _player.setUrl(song['fileUrl']);
        await _player.play();
      } else {
        // Demo: Phát một URL mẫu (cần thay bằng URL thật)
        // Hoặc hiển thị thông báo
        print('⚠️ Song URL not available: ${song['songName']}');
        // Demo URL (thay bằng URL thật từ Firebase Storage)
        await _player.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
        await _player.play();
      }
    } catch (e) {
      print('❌ Error playing song: $e');
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

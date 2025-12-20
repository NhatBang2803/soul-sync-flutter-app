import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'queue_service.dart';

/// Service để quản lý phát nhạc
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  AudioPlayerService._internal() {
    _audioPlayer = AudioPlayer();
    _setupPlayerListeners();
  }

  late final AudioPlayer _audioPlayer;
  final QueueService _queueService = QueueService();
  final List<Map<String, dynamic>> _playlist = [];
  int _currentIndex = 0;

  // Sleep timer
  Timer? _sleepTimer;
  Duration? _sleepDuration;
  DateTime? _sleepStartTime;

  // Streams
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;

  // Current state
  bool get isPlaying => _audioPlayer.playing;
  Duration get position => _audioPlayer.position;
  Duration get duration => _audioPlayer.duration ?? Duration.zero;
  Map<String, dynamic>? get currentSong =>
      _playlist.isNotEmpty && _currentIndex < _playlist.length
      ? _playlist[_currentIndex]
      : null;
  int get currentIndex => _currentIndex;
  List<Map<String, dynamic>> get playlist => List.unmodifiable(_playlist);

  // Sleep timer getters
  Duration? get remainingSleepTime {
    if (_sleepTimer == null ||
        _sleepStartTime == null ||
        _sleepDuration == null) {
      return null;
    }
    final elapsed = DateTime.now().difference(_sleepStartTime!);
    final remaining = _sleepDuration! - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get hasSleepTimer => _sleepTimer != null;

  void _setupPlayerListeners() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onSongCompleted();
      }
    });
  }

  void _onSongCompleted() {
    if (_playlist.isEmpty) return;

    final repeatMode = _queueService.repeatMode;

    switch (repeatMode) {
      case RepeatMode.one:
        // Lặp lại bài hiện tại
        seek(Duration.zero);
        play();
        break;

      case RepeatMode.queue:
        // Lặp toàn bộ hàng đợi - quay về đầu nếu hết
        _currentIndex = (_currentIndex + 1) % _playlist.length;
        _loadAndPlay(_playlist[_currentIndex]);
        break;

      case RepeatMode.off:
        // Chỉ chuyển bài nếu còn bài tiếp theo, dừng nếu hết
        if (_currentIndex < _playlist.length - 1) {
          _currentIndex++;
          _loadAndPlay(_playlist[_currentIndex]);
        }
        // Nếu hết danh sách thì dừng (không làm gì thêm)
        break;
    }
  }

  // ==================== PLAYBACK CONTROL ====================

  /// Set playlist and start playing
  Future<void> setPlaylist(
    List<Map<String, dynamic>> songs, [
    int startIndex = 0,
  ]) async {
    _playlist.clear();
    _playlist.addAll(songs);
    _currentIndex = startIndex.clamp(0, songs.length - 1);

    if (_playlist.isNotEmpty) {
      await _loadAndPlay(_playlist[_currentIndex]);
    }
  }

  /// Play a single song
  Future<void> playSong(Map<String, dynamic> song) async {
    _playlist.clear();
    _playlist.add(song);
    _currentIndex = 0;
    await _loadAndPlay(song);
  }

  Future<void> _loadAndPlay(Map<String, dynamic> song) async {
    try {
      String? audioUrl = song['audioUrl'] as String?;

      // Handle demo/fallback URLs
      if (audioUrl == null || audioUrl.isEmpty) {
        audioUrl = _getDemoUrl();
      }

      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      print('Error loading audio: $e');
      // Try with demo URL on error
      try {
        await _audioPlayer.setUrl(_getDemoUrl());
        await _audioPlayer.play();
      } catch (e2) {
        print('Error loading demo audio: $e2');
      }
    }
  }

  String _getDemoUrl() {
    return 'https://res.cloudinary.com/demo/video/upload/v1689187345/samples/dance2.mp3';
  }

  /// Play
  Future<void> play() async {
    await _audioPlayer.play();
  }

  /// Pause
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Stop
  Future<void> stop() async {
    await _audioPlayer.stop();
    cancelSleepTimer();
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Play next song
  Future<void> next() async {
    if (_playlist.isEmpty) return;

    _currentIndex = (_currentIndex + 1) % _playlist.length;
    await _loadAndPlay(_playlist[_currentIndex]);
  }

  /// Play previous song
  Future<void> previous() async {
    if (_playlist.isEmpty) return;

    // If more than 3 seconds into song, restart it
    if (_audioPlayer.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    await _loadAndPlay(_playlist[_currentIndex]);
  }

  /// Skip to specific index in playlist
  Future<void> skipToIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      await _loadAndPlay(_playlist[_currentIndex]);
    }
  }

  // ==================== SLEEP TIMER ====================

  /// Set sleep timer (stops playback after duration)
  void setSleepTimer(Duration duration) {
    cancelSleepTimer();

    _sleepDuration = duration;
    _sleepStartTime = DateTime.now();

    _sleepTimer = Timer(duration, () {
      _onSleepTimerComplete();
    });
  }

  /// Cancel sleep timer
  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepDuration = null;
    _sleepStartTime = null;
  }

  void _onSleepTimerComplete() {
    // Fade out and pause
    _audioPlayer.pause();
    cancelSleepTimer();
  }

  // ==================== UTILITIES ====================

  /// Format duration to mm:ss string
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Dispose player
  Future<void> dispose() async {
    cancelSleepTimer();
    await _audioPlayer.dispose();
  }
}

import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'queue_service.dart';
import 'supabase_service.dart';
import 'auth_service.dart';
import '../models/song.dart';

/// Service để quản lý phát nhạc
/// Uses QueueService as single source of truth for queue state
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  AudioPlayerService._internal() {
    _audioPlayer = AudioPlayer();
    _setupPlayerListeners();
  }

  late final AudioPlayer _audioPlayer;
  final QueueService _queueService = QueueService();
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();

  // Track which song was last recorded to avoid duplicates
  String? _lastRecordedSongId;

  // Sleep timer
  Timer? _sleepTimer;
  Duration? _sleepDuration;
  DateTime? _sleepStartTime;

  // Streams
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;


  // Current state - delegate to QueueService
  bool get isPlaying => _audioPlayer.playing;
  Duration get position => _audioPlayer.position;
  Duration get duration => _audioPlayer.duration ?? Duration.zero;

  /// Get current song from QueueService (Map format for UI)
  Map<String, dynamic>? get currentSong => _queueService.currentSongMap;

  /// Get current index from QueueService
  int get currentIndex => _queueService.currentIndex;

  /// Get playlist from QueueService
  List<Map<String, dynamic>> get playlist => _queueService.toPlayerFormat();

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

  /// Handle song completion - delegate to QueueService for next song logic
  Future<void> _onSongCompleted() async {
    final nextSong = await _queueService.handleSongCompleted();

    if (nextSong != null) {
      await _loadAndPlay(nextSong.toPlayerFormat());
    }
    // If null, playback stops (already handled by just_audio)
  }

  // ==================== PLAYBACK CONTROL ====================

  /// Set playlist and start playing
  /// This syncs with QueueService
  Future<void> setPlaylist(
    List<Map<String, dynamic>> songs, [
    int startIndex = 0,
  ]) async {
    // Convert to Song models and update QueueService
    final songModels = songs
        .map((json) => Song.fromPlayerFormat(json))
        .toList();

    _queueService.replaceQueue(songModels, startIndex: startIndex);

    // Start playing current song
    final current = _queueService.currentSongMap;
    if (current != null) {
      await _loadAndPlay(current);
    }
  }

  /// Play a single song (adds to queue and plays)
  Future<void> playSong(Map<String, dynamic> song) async {
    await setPlaylist([song], 0);
  }

  Future<void> _loadAndPlay(Map<String, dynamic> song) async {
    try {
      String? audioUrl = song['audioUrl'] as String?;
      final songId = song['id'] as String?;

      // Handle demo/fallback URLs
      if (audioUrl == null || audioUrl.isEmpty) {
        audioUrl = _getDemoUrl();
      }

      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();

      // Record listening history and increment play count
      if (songId != null && songId != _lastRecordedSongId) {
        _lastRecordedSongId = songId;
        _recordListeningAsync(songId);
      }
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

  /// Record listening history asynchronously (don't block playback)
  void _recordListeningAsync(String songId) {
    Future(() async {
      try {
        final userId = _authService.currentUserId;
        await _supabaseService.recordListening(
          userId: userId,
          songId: songId,
          durationPlayed: 0,
          completed: false,
        );
        print('Recorded listening for song: $songId');
      } catch (e) {
        print('Error recording listening: $e');
      }
    });
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

  /// Play next song - delegate to QueueService
  Future<void> next() async {
    final nextSong = _queueService.moveToNext();
    if (nextSong != null) {
      await _loadAndPlay(nextSong.toPlayerFormat());
    }
  }

  /// Play previous song - delegate to QueueService
  Future<void> previous() async {
    // If more than 3 seconds into song, restart it
    if (_audioPlayer.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    final prevSong = _queueService.moveToPrevious();
    if (prevSong != null) {
      await _loadAndPlay(prevSong.toPlayerFormat());
    }
  }

  /// Skip to specific index in playlist
  Future<void> skipToIndex(int index) async {
    _queueService.jumpToIndex(index);
    final song = _queueService.currentSongMap;
    if (song != null) {
      await _loadAndPlay(song);
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

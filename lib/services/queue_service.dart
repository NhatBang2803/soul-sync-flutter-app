import 'dart:async';
import 'dart:math';
import '../models/song.dart';
import 'supabase_service.dart';

/// Repeat modes for playback
enum RepeatMode {
  off, // No repeat - stop when queue ends (or fetch random if shuffle)
  one, // Repeat single song
  queue, // Repeat entire queue
}

/// Service để quản lý hàng đợi phát nhạc
/// This is the SINGLE SOURCE OF TRUTH for queue state
class QueueService {
  static final QueueService _instance = QueueService._internal();
  factory QueueService() => _instance;
  QueueService._internal();

  final SupabaseService _supabaseService = SupabaseService();
  final Random _random = Random();

  // Queue state
  List<Song> _queue = [];
  List<Song> _originalQueue = []; // For shuffle restore
  int _currentIndex = 0;
  bool _isShuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;

  // Stream controller for queue changes
  final _queueChangeController = StreamController<void>.broadcast();
  Stream<void> get onQueueChanged => _queueChangeController.stream;

  // Played history for shuffle (to avoid repeating recently played)
  final Set<String> _playedIds = {};

  // Getters
  List<Song> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  Song? get currentSong => _queue.isNotEmpty && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;
  bool get isShuffleEnabled => _isShuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;
  bool get isEmpty => _queue.isEmpty;
  int get length => _queue.length;
  bool get hasNext =>
      _currentIndex < _queue.length - 1 || _repeatMode != RepeatMode.off;
  bool get hasPrevious => _currentIndex > 0;

  /// Get current song in player format (Map)
  Map<String, dynamic>? get currentSongMap => currentSong?.toPlayerFormat();

  void _notifyChange() {
    _queueChangeController.add(null);
  }

  // ==================== QUEUE MANAGEMENT ====================

  /// Replace entire queue with new songs (when playing album/playlist)
  void replaceQueue(List<Song> songs, {int startIndex = 0}) {
    _queue = List.from(songs);
    _originalQueue = List.from(songs);
    _currentIndex = startIndex.clamp(
      0,
      songs.isNotEmpty ? songs.length - 1 : 0,
    );
    _playedIds.clear();

    if (_isShuffleEnabled && songs.isNotEmpty) {
      _shuffleQueue(keepCurrent: true);
    }

    _markCurrentAsPlayed();
    _notifyChange();
  }

  /// Add a song to the end of the queue
  void addToQueue(Song song) {
    _queue.add(song);
    _originalQueue.add(song);
    _notifyChange();
  }

  /// Add a song to play next (after current)
  void addToPlayNext(Song song) {
    final insertIndex = _currentIndex + 1;
    if (insertIndex <= _queue.length) {
      _queue.insert(insertIndex, song);
      _originalQueue.insert(insertIndex, song);
    } else {
      addToQueue(song);
    }
    _notifyChange();
  }

  /// Remove a song from queue by index
  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;

    final removedSong = _queue[index];
    _queue.removeAt(index);
    _originalQueue.remove(removedSong);

    // Adjust current index if needed
    if (index < _currentIndex) {
      _currentIndex--;
    } else if (index == _currentIndex && _currentIndex >= _queue.length) {
      _currentIndex = _queue.length > 0 ? _queue.length - 1 : 0;
    }
    _notifyChange();
  }

  /// Remove a specific song from queue
  void removeSong(Song song) {
    final index = _queue.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      removeFromQueue(index);
    }
  }

  /// Clear the entire queue
  void clearQueue() {
    _queue.clear();
    _originalQueue.clear();
    _currentIndex = 0;
    _playedIds.clear();
    _notifyChange();
  }

  /// Move song from one position to another
  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _queue.length) return;
    if (newIndex < 0 || newIndex >= _queue.length) return;

    final song = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, song);

    // Adjust current index
    if (oldIndex == _currentIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }
    _notifyChange();
  }

  // ==================== MAIN PLAYBACK LOGIC ====================

  /// Handle when a song completes playing
  /// Returns the next song to play, or null if playback should stop
  Future<Song?> handleSongCompleted() async {
    if (_queue.isEmpty) return null;

    // Repeat One: always return current song
    if (_repeatMode == RepeatMode.one) {
      return currentSong;
    }

    final isLastSong = _currentIndex >= _queue.length - 1;

    if (!_isShuffleEnabled) {
      // ========== NO SHUFFLE ==========
      if (!isLastSong) {
        // Not last song: move to next
        _currentIndex++;
        _markCurrentAsPlayed();
        _notifyChange();
        return currentSong;
      }

      // Last song
      if (_repeatMode == RepeatMode.queue) {
        // Loop back to first song
        _currentIndex = 0;
        _markCurrentAsPlayed();
        _notifyChange();
        return currentSong;
      } else {
        // RepeatMode.off: Stop playback
        return null;
      }
    } else {
      // ========== SHUFFLE ENABLED ==========
      // Check if all songs have been played
      final allPlayed = _queue.every((s) => _playedIds.contains(s.id));

      if (!allPlayed) {
        // Pick random unplayed song
        final unplayedIndices = <int>[];
        for (int i = 0; i < _queue.length; i++) {
          if (!_playedIds.contains(_queue[i].id)) {
            unplayedIndices.add(i);
          }
        }
        _currentIndex =
            unplayedIndices[_random.nextInt(unplayedIndices.length)];
        _markCurrentAsPlayed();
        _notifyChange();
        return currentSong;
      }

      // All songs played
      if (_repeatMode == RepeatMode.queue) {
        // Reshuffle and start over
        _playedIds.clear();
        _shuffleQueue(keepCurrent: false);
        _currentIndex = 0;
        _markCurrentAsPlayed();
        _notifyChange();
        return currentSong;
      } else {
        // RepeatMode.off with shuffle: fetch random songs from DB
        await _fetchAndReplaceWithRandomSongs();
        if (_queue.isNotEmpty) {
          _currentIndex = 0;
          _markCurrentAsPlayed();
          _notifyChange();
          return currentSong;
        }
        return null;
      }
    }
  }

  /// Move to next song (manual skip)
  Song? moveToNext() {
    if (_queue.isEmpty) return null;

    if (_repeatMode == RepeatMode.one) {
      // Even in repeat one, manual skip should move to next
      _currentIndex = (_currentIndex + 1) % _queue.length;
    } else if (_isShuffleEnabled) {
      // Pick random different song
      if (_queue.length > 1) {
        int newIndex;
        do {
          newIndex = _random.nextInt(_queue.length);
        } while (newIndex == _currentIndex);
        _currentIndex = newIndex;
      }
    } else {
      _currentIndex = (_currentIndex + 1) % _queue.length;
    }

    _markCurrentAsPlayed();
    _notifyChange();
    return currentSong;
  }

  /// Move to previous song
  Song? moveToPrevious() {
    if (_queue.isEmpty) return null;

    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _queue.length - 1;
    }

    _notifyChange();
    return currentSong;
  }

  /// Jump to specific index
  void jumpToIndex(int index) {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      _markCurrentAsPlayed();
      _notifyChange();
    }
  }

  /// Jump to specific song
  void jumpToSong(Song song) {
    final index = _queue.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      jumpToIndex(index);
    }
  }

  // ==================== SHUFFLE ====================

  /// Toggle shuffle mode
  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;

    if (_isShuffleEnabled) {
      _shuffleQueue(keepCurrent: true);
    } else {
      _restoreOriginalOrder();
    }
    _notifyChange();
  }

  /// Set shuffle mode
  void setShuffle(bool enabled) {
    if (_isShuffleEnabled != enabled) {
      toggleShuffle();
    }
  }

  void _shuffleQueue({bool keepCurrent = true}) {
    if (_queue.length <= 1) return;

    final current = currentSong;
    _queue.shuffle(_random);

    if (keepCurrent && current != null) {
      // Move current song to the front
      final currentIdx = _queue.indexWhere((s) => s.id == current.id);
      if (currentIdx != -1 && currentIdx != 0) {
        _queue.removeAt(currentIdx);
        _queue.insert(0, current);
      }
      _currentIndex = 0;
    }

    _playedIds.clear();
    _markCurrentAsPlayed();
  }

  void _restoreOriginalOrder() {
    final current = currentSong;
    _queue = List.from(_originalQueue);

    if (current != null) {
      _currentIndex = _queue.indexWhere((s) => s.id == current.id);
      if (_currentIndex == -1) _currentIndex = 0;
    }
  }

  // ==================== REPEAT MODE ====================

  /// Set repeat mode
  void setRepeatMode(RepeatMode mode) {
    _repeatMode = mode;
    _notifyChange();
  }

  /// Cycle through repeat modes
  void cycleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.queue;
        break;
      case RepeatMode.queue:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    _notifyChange();
  }

  // ==================== HELPERS ====================

  void _markCurrentAsPlayed() {
    if (currentSong != null) {
      _playedIds.add(currentSong!.id);
    }
  }

  /// Fetch random songs from database and REPLACE the queue
  Future<void> _fetchAndReplaceWithRandomSongs() async {
    try {
      final randomSongs = await _supabaseService.getRandomSongs(5);
      final newSongs = randomSongs.map((json) => Song.fromJson(json)).toList();

      if (newSongs.isNotEmpty) {
        _queue = newSongs;
        _originalQueue = List.from(newSongs);
        _currentIndex = 0;
        _playedIds.clear();
      }
    } catch (e) {
      print('Error fetching random songs: $e');
    }
  }

  /// Convert queue to player format for AudioPlayerService
  List<Map<String, dynamic>> toPlayerFormat() {
    return _queue.map((s) => s.toPlayerFormat()).toList();
  }

  /// Dispose resources
  void dispose() {
    _queueChangeController.close();
  }
}

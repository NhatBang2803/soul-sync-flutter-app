import 'dart:math';
import '../models/song.dart';
import 'supabase_service.dart';

/// Repeat modes for playback
enum RepeatMode {
  off,    // No repeat - fetch random songs when queue ends
  one,    // Repeat single song
  queue,  // Repeat entire queue
}

/// Service để quản lý hàng đợi phát nhạc
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
  bool get hasNext => _currentIndex < _queue.length - 1 || _repeatMode != RepeatMode.off;
  bool get hasPrevious => _currentIndex > 0;

  // ==================== QUEUE MANAGEMENT ====================

  /// Replace entire queue with new songs (when playing album/playlist)
  void replaceQueue(List<Song> songs, {int startIndex = 0}) {
    _queue = List.from(songs);
    _originalQueue = List.from(songs);
    _currentIndex = startIndex.clamp(0, songs.length - 1);
    _playedIds.clear();
    
    if (_isShuffleEnabled && songs.isNotEmpty) {
      _shuffleQueue(keepCurrent: true);
    }
    
    _markCurrentAsPlayed();
  }

  /// Add a song to the end of the queue
  void addToQueue(Song song) {
    _queue.add(song);
    _originalQueue.add(song);
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
      _currentIndex = _queue.length - 1;
    }
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
  }

  // ==================== PLAYBACK NAVIGATION ====================

  /// Get next song based on repeat mode and shuffle
  Future<Song?> getNextSong() async {
    if (_queue.isEmpty) return null;

    switch (_repeatMode) {
      case RepeatMode.one:
        // Stay on current song
        return currentSong;

      case RepeatMode.queue:
        // Move to next, loop back to start if at end
        if (_isShuffleEnabled) {
          return _getNextShuffled(allowLoop: true);
        }
        _currentIndex = (_currentIndex + 1) % _queue.length;
        _markCurrentAsPlayed();
        return currentSong;

      case RepeatMode.off:
        // Move to next, fetch random songs if at end
        if (_isShuffleEnabled) {
          return _getNextShuffled(allowLoop: false);
        }
        
        if (_currentIndex < _queue.length - 1) {
          _currentIndex++;
          _markCurrentAsPlayed();
          return currentSong;
        } else {
          // End of queue - fetch random songs
          await _fetchRandomSongs();
          if (_queue.isNotEmpty && _currentIndex < _queue.length - 1) {
            _currentIndex++;
            _markCurrentAsPlayed();
            return currentSong;
          }
          return null;
        }
    }
  }

  /// Get previous song
  Song? getPreviousSong() {
    if (_queue.isEmpty) return null;

    if (_repeatMode == RepeatMode.one) {
      return currentSong;
    }

    if (_currentIndex > 0) {
      _currentIndex--;
    } else if (_repeatMode == RepeatMode.queue) {
      _currentIndex = _queue.length - 1;
    }

    return currentSong;
  }

  /// Jump to specific index
  void jumpToIndex(int index) {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      _markCurrentAsPlayed();
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
      final currentIndex = _queue.indexWhere((s) => s.id == current.id);
      if (currentIndex != -1 && currentIndex != 0) {
        _queue.removeAt(currentIndex);
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

  Song? _getNextShuffled({required bool allowLoop}) {
    // Find songs not played yet
    final unplayed = <int>[];
    for (int i = 0; i < _queue.length; i++) {
      if (!_playedIds.contains(_queue[i].id)) {
        unplayed.add(i);
      }
    }

    if (unplayed.isEmpty) {
      if (allowLoop) {
        // Reset and start over
        _playedIds.clear();
        _currentIndex = _random.nextInt(_queue.length);
        _markCurrentAsPlayed();
        return currentSong;
      }
      return null;
    }

    // Pick random unplayed song
    _currentIndex = unplayed[_random.nextInt(unplayed.length)];
    _markCurrentAsPlayed();
    return currentSong;
  }

  // ==================== REPEAT MODE ====================

  /// Set repeat mode
  void setRepeatMode(RepeatMode mode) {
    _repeatMode = mode;
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
  }

  // ==================== HELPERS ====================

  void _markCurrentAsPlayed() {
    if (currentSong != null) {
      _playedIds.add(currentSong!.id);
    }
  }

  /// Fetch random songs from database and add to queue
  Future<void> _fetchRandomSongs() async {
    try {
      final randomSongs = await _supabaseService.getRandomSongs(10);
      final newSongs = randomSongs.map((json) => Song.fromJson(json)).toList();
      
      for (final song in newSongs) {
        if (!_queue.any((s) => s.id == song.id)) {
          _queue.add(song);
          _originalQueue.add(song);
        }
      }
    } catch (e) {
      print('Error fetching random songs: $e');
    }
  }

  /// Convert queue to player format for AudioPlayerService
  List<Map<String, dynamic>> toPlayerFormat() {
    return _queue.map((s) => s.toPlayerFormat()).toList();
  }
}

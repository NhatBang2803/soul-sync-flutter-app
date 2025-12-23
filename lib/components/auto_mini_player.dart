import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';
import '../services/queue_service.dart';
import '../now_playing_page.dart';
import 'mini_player.dart';

/// Auto Mini Player that automatically listens to AudioPlayerService
/// and shows/hides based on whether there's a song playing
class AutoMiniPlayer extends StatefulWidget {
  const AutoMiniPlayer({super.key});

  @override
  State<AutoMiniPlayer> createState() => _AutoMiniPlayerState();
}

class _AutoMiniPlayerState extends State<AutoMiniPlayer> {
  final AudioPlayerService _audioService = AudioPlayerService();
  final QueueService _queueService = QueueService();

  bool _isPlaying = false;
  StreamSubscription? _playingSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _queueSubscription;

  @override
  void initState() {
    super.initState();
    _initListeners();
  }

  void _initListeners() {
    _playingSubscription = _audioService.playingStream.listen((playing) {
      if (mounted) {
        setState(() => _isPlaying = playing);
      }
    });

    _playerStateSubscription = _audioService.playerStateStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });

    _queueSubscription = _queueService.onQueueChanged.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _playingSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _queueSubscription?.cancel();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_audioService.currentSong == null &&
        _queueService.currentSong != null) {
      final playlist = _queueService.toPlayerFormat();
      await _audioService.setPlaylist(playlist, _queueService.currentIndex);
    }
    await _audioService.togglePlayPause();
  }

  void _expandPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NowPlayingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSong =
        _audioService.currentSong ?? _queueService.currentSongMap;

    if (currentSong == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: MiniPlayerDynamic(
        song: currentSong,
        isPlaying: _isPlaying,
        onPlayPause: _togglePlayPause,
        onExpand: _expandPlayer,
      ),
    );
  }
}

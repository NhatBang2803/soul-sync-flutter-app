import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'services/audio_player_service.dart';
import 'services/queue_service.dart';
import 'core/core.dart';
import 'components/queue_panel.dart';
import 'components/sleep_timer_dialog.dart';

class NowPlayingPage extends StatefulWidget {
  final VoidCallback? onClose;
  
  const NowPlayingPage({super.key, this.onClose});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  final QueueService _queueService = QueueService();

  late StreamSubscription<PlayerState> _playerStateSubscription;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<Duration?> _durationSubscription;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Map<String, dynamic>? _currentSong;

  @override
  void initState() {
    super.initState();
    _initPlayerState();
    _setupListeners();
  }

  void _initPlayerState() {
    _currentSong = _audioPlayerService.currentSong;
    _isPlaying = _audioPlayerService.isPlaying;
    _position = _audioPlayerService.position;
    _duration = _audioPlayerService.duration;
  }

  void _setupListeners() {
    _playerStateSubscription = _audioPlayerService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _currentSong = _audioPlayerService.currentSong;
        });
      }
    });

    _positionSubscription = _audioPlayerService.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    _durationSubscription = _audioPlayerService.durationStream.listen((duration) {
      if (mounted) {
        setState(() => _duration = duration ?? Duration.zero);
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    super.dispose();
  }

  void _openQueue() async {
    final result = await showQueuePanel(context);
    if (result == true && mounted) {
      // Song was selected from queue, update UI
      setState(() {
        _currentSong = _audioPlayerService.currentSong;
      });
    }
  }

  void _openSleepTimer() {
    showSleepTimerDialog(
      context,
      currentTimer: _audioPlayerService.remainingSleepTime,
      onTimerSet: (duration) {
        if (duration != null) {
          _audioPlayerService.setSleepTimer(duration);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hẹn giờ ngủ: ${_formatDuration(duration)}'),
              backgroundColor: AppColors.primary,
            ),
          );
        } else {
          _audioPlayerService.cancelSleepTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã hủy hẹn giờ ngủ'),
              backgroundColor: AppColors.surface,
            ),
          );
        }
        setState(() {});
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '$minutes phút';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? '$hours giờ $mins phút' : '$hours giờ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = _currentSong?['coverUrl'] as String?;
    final songName = _currentSong?['songName'] ?? 'Unknown Song';
    final artistName = _currentSong?['artistName'] ?? 'Unknown Artist';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Spacer(),
                    _buildAlbumArt(coverUrl),
                    const SizedBox(height: 32),
                    _buildSongInfo(songName, artistName),
                    const SizedBox(height: 24),
                    _buildProgressBar(),
                    const SizedBox(height: 24),
                    _buildControls(),
                    const Spacer(),
                    _buildBottomActions(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 32),
            color: AppColors.textPrimary,
            onPressed: () {
              if (widget.onClose != null) {
                widget.onClose!();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          Column(
            children: [
              const Text(
                'ĐANG PHÁT',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _currentSong?['albumName'] ?? 'Album',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: AppColors.textPrimary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(String? coverUrl) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: coverUrl != null && coverUrl.isNotEmpty
            ? Image.network(
                coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultArt(),
              )
            : _buildDefaultArt(),
      ),
    );
  }

  Widget _buildDefaultArt() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note, size: 80, color: Colors.white70),
      ),
    );
  }

  Widget _buildSongInfo(String songName, String artistName) {
    return Column(
      children: [
        Text(
          songName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          artistName,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final maxDuration = _duration.inMilliseconds > 0 
        ? _duration.inMilliseconds.toDouble() 
        : 100.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surface,
            thumbColor: AppColors.primary,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            trackHeight: 4,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: _position.inMilliseconds.toDouble().clamp(0, maxDuration),
            min: 0,
            max: maxDuration,
            onChanged: (value) {
              _audioPlayerService.seek(Duration(milliseconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AudioPlayerService.formatDuration(_position),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                AudioPlayerService.formatDuration(_duration),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    final repeatMode = _queueService.repeatMode;
    final isShuffleEnabled = _queueService.isShuffleEnabled;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle
        IconButton(
          icon: Icon(
            Icons.shuffle,
            color: isShuffleEnabled ? AppColors.primary : AppColors.textSecondary,
          ),
          iconSize: 24,
          onPressed: () {
            setState(() {
              _queueService.toggleShuffle();
            });
          },
        ),
        // Previous
        IconButton(
          icon: const Icon(Icons.skip_previous),
          color: AppColors.textPrimary,
          iconSize: 40,
          onPressed: () => _audioPlayerService.previous(),
        ),
        // Play/Pause
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            color: Colors.white,
            iconSize: 36,
            onPressed: () => _audioPlayerService.togglePlayPause(),
          ),
        ),
        // Next
        IconButton(
          icon: const Icon(Icons.skip_next),
          color: AppColors.textPrimary,
          iconSize: 40,
          onPressed: () => _audioPlayerService.next(),
        ),
        // Repeat
        IconButton(
          icon: Icon(_getRepeatIcon(repeatMode)),
          color: repeatMode != RepeatMode.off 
              ? AppColors.primary 
              : AppColors.textSecondary,
          iconSize: 24,
          onPressed: () {
            setState(() {
              _queueService.cycleRepeatMode();
            });
          },
        ),
      ],
    );
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.one:
        return Icons.repeat_one;
      case RepeatMode.queue:
      case RepeatMode.off:
        return Icons.repeat;
    }
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Like
          IconButton(
            icon: const Icon(Icons.favorite_border),
            color: AppColors.textSecondary,
            onPressed: () {},
          ),
          // Queue
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.queue_music),
                if (_queueService.length > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_queueService.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            color: AppColors.textSecondary,
            onPressed: _openQueue,
          ),
          // Sleep timer
          IconButton(
            icon: Icon(
              Icons.bedtime,
              color: _audioPlayerService.hasSleepTimer 
                  ? AppColors.primary 
                  : AppColors.textSecondary,
            ),
            onPressed: _openSleepTimer,
          ),
          // Share
          IconButton(
            icon: const Icon(Icons.share_outlined),
            color: AppColors.textSecondary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

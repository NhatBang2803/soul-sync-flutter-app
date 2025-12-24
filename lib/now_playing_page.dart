import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'services/audio_player_service.dart';
import 'services/queue_service.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'core/core.dart';
import 'components/queue_panel.dart';
import 'components/sleep_timer_dialog.dart';
import 'components/add_to_playlist_dialog.dart';
import 'pages/podcast_page.dart';
import 'pages/artist_page.dart';
import 'models/song.dart';

class NowPlayingPage extends StatefulWidget {
  final VoidCallback? onClose;

  const NowPlayingPage({super.key, this.onClose});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with TickerProviderStateMixin {
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  final QueueService _queueService = QueueService();
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();

  late StreamSubscription<PlayerState> _playerStateSubscription;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<Duration?> _durationSubscription;

  // Gradient animation controllers
  late AnimationController _gradientController;
  late AnimationController _pulseController;
  Timer? _pulseTimer;
  final Random _random = Random();

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Map<String, dynamic>? _currentSong;
  bool _isLiked = false;
  bool _isSaved = false; // For podcast save status

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initPlayerState();
    _setupListeners();
    _checkIfLikedOrSaved();
  }

  void _initAnimations() {
    // Main gradient color cycling (slow, continuous)
    _gradientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Pulse animation for "beat" effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: 0.3, // Start at base level
    );
  }

  void _startPulseSimulation() {
    _pulseTimer?.cancel();
    // Simulate audio reactivity with random pulses
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (_isPlaying && mounted) {
        // Random intensity to simulate audio levels
        final intensity = 0.3 + _random.nextDouble() * 0.7;
        _pulseController.animateTo(
          intensity,
          duration: const Duration(milliseconds: 100),
        );
        Future.delayed(const Duration(milliseconds: 80), () {
          if (mounted) {
            _pulseController.animateTo(
              0.3,
              duration: const Duration(milliseconds: 150),
            );
          }
        });
      }
    });
  }

  void _stopPulseSimulation() {
    _pulseTimer?.cancel();
    _pulseController.animateTo(
      0.3,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _initPlayerState() {
    _currentSong = _audioPlayerService.currentSong;
    _isPlaying = _audioPlayerService.isPlaying;
    _position = _audioPlayerService.position;
    _duration = _audioPlayerService.duration;
    if (_isPlaying) {
      _startPulseSimulation();
    }
  }

  void _setupListeners() {
    _playerStateSubscription = _audioPlayerService.playerStateStream.listen((
      state,
    ) {
      if (mounted) {
        final newSong = _audioPlayerService.currentSong;
        final songChanged = _currentSong?['id'] != newSong?['id'];
        final wasPlaying = _isPlaying;
        setState(() {
          _isPlaying = state.playing;
          _currentSong = newSong;
        });
        // Start/stop pulse animation based on playing state
        if (state.playing && !wasPlaying) {
          _startPulseSimulation();
        } else if (!state.playing && wasPlaying) {
          _stopPulseSimulation();
        }
        // Re-check like/save status when song changes
        if (songChanged) {
          _checkIfLikedOrSaved();
        }
      }
    });

    _positionSubscription = _audioPlayerService.positionStream.listen((
      position,
    ) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    _durationSubscription = _audioPlayerService.durationStream.listen((
      duration,
    ) {
      if (mounted) {
        setState(() => _duration = duration ?? Duration.zero);
      }
    });
  }

  /// Check if song is liked or podcast is saved
  Future<void> _checkIfLikedOrSaved() async {
    final userId = _authService.currentUserId;
    if (userId == null || _currentSong == null) return;

    final isPodcast = _currentSong?['isPodcast'] == true;

    try {
      if (isPodcast) {
        final podcastId = _currentSong?['podcastId'];
        if (podcastId != null) {
          final saved = await _supabaseService.isPodcastSaved(
            userId,
            podcastId,
          );
          if (mounted) {
            setState(() => _isSaved = saved);
          }
        }
      } else {
        final songId = _currentSong?['id'];
        if (songId != null) {
          final liked = await _supabaseService.isSongLiked(userId, songId);
          if (mounted) {
            setState(() => _isLiked = liked);
          }
        }
      }
    } catch (e) {
      // Ignore error
    }
  }

  /// Toggle like for song
  Future<void> _toggleLike() async {
    final userId = _authService.currentUserId;
    final songId = _currentSong?['id'];
    if (userId == null || songId == null) return;

    try {
      if (_isLiked) {
        await _supabaseService.unlikeSong(userId, songId);
      } else {
        await _supabaseService.likeSong(userId, songId);
      }
      if (mounted) {
        setState(() => _isLiked = !_isLiked);
      }
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  /// Toggle save for podcast
  Future<void> _toggleSave() async {
    final userId = _authService.currentUserId;
    final podcastId = _currentSong?['podcastId'];
    if (userId == null || podcastId == null) return;

    try {
      if (_isSaved) {
        await _supabaseService.unsavePodcast(userId, podcastId);
      } else {
        await _supabaseService.savePodcast(userId, podcastId);
      }
      if (mounted) {
        setState(() => _isSaved = !_isSaved);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSaved ? 'Đã lưu podcast' : 'Đã bỏ lưu podcast'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    _gradientController.dispose();
    _pulseController.dispose();
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
          // Artists dropdown for songs, hidden for podcasts
          if (_currentSong?['isPodcast'] != true)
            _buildArtistsDropdownButton()
          else
            const SizedBox(width: 48), // Placeholder for podcast
        ],
      ),
    );
  }

  Widget _buildAlbumArt(String? coverUrl) {
    return AnimatedBuilder(
      animation: Listenable.merge([_gradientController, _pulseController]),
      builder: (context, child) {
        // Calculate gradient colors based on animation
        final colorProgress = _gradientController.value;
        final pulseIntensity = _pulseController.value;

        // Gradient colors: green -> blue -> purple -> green
        final Color color1;
        final Color color2;
        final Color color3;

        if (colorProgress < 0.33) {
          // Green to Blue
          final t = colorProgress / 0.33;
          color1 = Color.lerp(
            const Color(0xFF23DD5B),
            const Color(0xFF00C9FF),
            t,
          )!;
          color2 = Color.lerp(
            const Color(0xFF00C9FF),
            const Color(0xFF8B5CF6),
            t,
          )!;
          color3 = Color.lerp(
            const Color(0xFF8B5CF6),
            const Color(0xFF23DD5B),
            t,
          )!;
        } else if (colorProgress < 0.66) {
          // Blue to Purple
          final t = (colorProgress - 0.33) / 0.33;
          color1 = Color.lerp(
            const Color(0xFF00C9FF),
            const Color(0xFF8B5CF6),
            t,
          )!;
          color2 = Color.lerp(
            const Color(0xFF8B5CF6),
            const Color(0xFF23DD5B),
            t,
          )!;
          color3 = Color.lerp(
            const Color(0xFF23DD5B),
            const Color(0xFF00C9FF),
            t,
          )!;
        } else {
          // Purple to Green
          final t = (colorProgress - 0.66) / 0.34;
          color1 = Color.lerp(
            const Color(0xFF8B5CF6),
            const Color(0xFF23DD5B),
            t,
          )!;
          color2 = Color.lerp(
            const Color(0xFF23DD5B),
            const Color(0xFF00C9FF),
            t,
          )!;
          color3 = Color.lerp(
            const Color(0xFF00C9FF),
            const Color(0xFF8B5CF6),
            t,
          )!;
        }

        // Apply pulse to blur and opacity
        final blurAmount = 30.0 + (pulseIntensity * 40.0);
        final glowOpacity = 0.3 + (pulseIntensity * 0.4);

        return Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated gradient glow behind the image
              Container(
                width: 280 + (pulseIntensity * 20),
                height: 280 + (pulseIntensity * 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: RadialGradient(
                    colors: [
                      color1.withOpacity(glowOpacity),
                      color2.withOpacity(glowOpacity * 0.7),
                      color3.withOpacity(glowOpacity * 0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color1.withOpacity(glowOpacity),
                      blurRadius: blurAmount,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: color2.withOpacity(glowOpacity * 0.5),
                      blurRadius: blurAmount * 1.5,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              // Album art image
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
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
              ),
            ],
          ),
        );
      },
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
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
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
            color: isShuffleEnabled
                ? AppColors.primary
                : AppColors.textSecondary,
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
    final isPodcast = _currentSong?['isPodcast'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Like (for songs) or Save (for podcasts)
          isPodcast
              ? IconButton(
                  icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
                  color: _isSaved ? AppColors.primary : AppColors.textSecondary,
                  onPressed: _toggleSave,
                  tooltip: _isSaved ? 'Bỏ lưu podcast' : 'Lưu podcast',
                )
              : IconButton(
                  icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
                  color: _isLiked ? Colors.red : AppColors.textSecondary,
                  onPressed: _toggleLike,
                  tooltip: _isLiked ? 'Bỏ thích' : 'Thích',
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
          // Add to Playlist (for songs) or View Podcast (for podcasts)
          isPodcast
              ? IconButton(
                  icon: const Icon(Icons.podcasts),
                  color: AppColors.textSecondary,
                  tooltip: 'Xem podcast',
                  onPressed: () {
                    final podcastId = _currentSong?['podcastId'];
                    if (podcastId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PodcastPage(podcastId: podcastId),
                        ),
                      );
                    }
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.playlist_add),
                  color: AppColors.textSecondary,
                  tooltip: 'Thêm vào playlist',
                  onPressed: () => _showAddToPlaylistDialog(),
                ),
        ],
      ),
    );
  }

  /// Widget hiển thị dropdown danh sách nghệ sĩ khi ấn vào icon user
  Widget _buildArtistsDropdownButton() {
    final artistNames = _currentSong?['artistNames'] as List?;
    final artistIds = _currentSong?['artistIds'] as List?;

    return PopupMenuButton<int>(
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.people, color: AppColors.textPrimary, size: 24),
      ),
      tooltip: 'Xem nghệ sĩ',
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 48),
      onSelected: (index) async {
        if (artistNames == null || index >= artistNames.length) return;

        final name = artistNames[index]?.toString() ?? '';
        String? artistId;

        // Try to get ID from artistIds list
        if (artistIds != null && index < artistIds.length) {
          artistId = artistIds[index]?.toString();
        }

        // If no ID, try to find artist by name
        if (artistId == null || artistId.isEmpty) {
          try {
            final artists = await _supabaseService.searchArtists(
              name,
              limit: 1,
            );
            if (artists.isNotEmpty) {
              artistId = artists[0]['id']?.toString();
            }
          } catch (e) {
            print('Error finding artist by name: $e');
          }
        }

        if (artistId != null && artistId.isNotEmpty && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArtistPage(artistId: artistId!),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không tìm thấy nghệ sĩ "$name"'),
              backgroundColor: Colors.orange[700],
            ),
          );
        }
      },
      itemBuilder: (context) {
        if (artistNames == null || artistNames.isEmpty) {
          return [
            const PopupMenuItem<int>(
              enabled: false,
              child: Text(
                'Không có thông tin nghệ sĩ',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ];
        }

        return List.generate(artistNames.length, (index) {
          final name = artistNames[index]?.toString() ?? 'Unknown';
          // Get artistId if available for fetching image
          final artistId = (artistIds != null && index < artistIds.length)
              ? artistIds[index]?.toString()
              : null;

          return PopupMenuItem<int>(
            value: index,
            enabled: true,
            child: _ArtistMenuItem(
              name: name,
              artistId: artistId,
              supabaseService: _supabaseService,
            ),
          );
        });
      },
    );
  }

  /// Hiển thị dialog thêm bài hát vào playlist
  void _showAddToPlaylistDialog() {
    if (_currentSong == null) return;

    final songId = _currentSong!['id']?.toString() ?? '';
    final songTitle = _currentSong!['songName'] ?? _currentSong!['title'] ?? '';

    // Create Song model for queue operations
    final song = Song.fromPlayerFormat(_currentSong!);

    AddToPlaylistDialog.show(context, songId, songTitle, song: song);
  }
}

/// Widget hiển thị từng item nghệ sĩ trong dropdown, fetch ảnh từ database
class _ArtistMenuItem extends StatelessWidget {
  final String name;
  final String? artistId;
  final SupabaseService supabaseService;

  const _ArtistMenuItem({
    required this.name,
    this.artistId,
    required this.supabaseService,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      // Fetch artist image from database
      future: _fetchArtistImage(),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data;

        return Row(
          children: [
            // Artist avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        );
      },
    );
  }

  Future<String?> _fetchArtistImage() async {
    // First try to get by ID
    if (artistId != null && artistId!.isNotEmpty) {
      try {
        final artist = await supabaseService.getArtistById(artistId!);
        return artist?['image_url']?.toString();
      } catch (e) {
        // Fallback to search by name
      }
    }

    // Search by name
    try {
      final artists = await supabaseService.searchArtists(name, limit: 1);
      if (artists.isNotEmpty) {
        return artists[0]['image_url']?.toString();
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

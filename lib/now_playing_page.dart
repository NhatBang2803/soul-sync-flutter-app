import 'package:flutter/material.dart';
import 'services/audio_player_service.dart';
import 'dart:async';

class NowPlayingPage extends StatefulWidget {
  final VoidCallback? onClose;
  
  const NowPlayingPage({super.key, this.onClose});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  final AudioPlayerService _audioService = AudioPlayerService();
  bool isLiked = false;
  bool isRepeat = false;
  bool isShuffle = false;
  
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  
  late StreamSubscription _positionSubscription;
  late StreamSubscription _durationSubscription;
  late StreamSubscription _playingSubscription;

  @override
  void initState() {
    super.initState();
    _initAudioListeners();
  }

  void _initAudioListeners() {
    _positionSubscription = _audioService.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    _durationSubscription = _audioService.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() => _duration = duration);
      }
    });

    _playingSubscription = _audioService.playingStream.listen((playing) {
      if (mounted) {
        setState(() => _isPlaying = playing);
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _playingSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Song data retrieved directly from _audioService.currentSong where needed
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildAlbumArt(),
                    const SizedBox(height: 30),
                    _buildSongInfo(),
                    const SizedBox(height: 20),
                    _buildProgressBar(),
                    const SizedBox(height: 30),
                    _buildControls(),
                    const SizedBox(height: 20),
                    _buildBottomActions(),
                    const SizedBox(height: 30),
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
            icon: const Icon(Icons.keyboard_arrow_down),
            color: Colors.white,
            iconSize: 32,
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
              Text(
                'ĐANG PHÁT TỪ PLAYLIST',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Nhạc yêu thích',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
            iconSize: 28,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt() {
    final song = _audioService.currentSong;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      width: double.infinity,
      height: MediaQuery.of(context).size.width - 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF23DD5B).withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: song != null && song['coverUrl'] != null
            ? Image.network(
                song['coverUrl'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultCover();
                },
              )
            : _buildDefaultCover(),
      ),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple[900]!,
            Colors.pink[700]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.music_note,
          size: 100,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSongInfo() {
    final song = _audioService.currentSong;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song?['songName'] ?? 'Unknown Song',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  song?['artistName'] ?? 'Unknown Artist',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? const Color(0xFF23DD5B) : Colors.white,
              size: 32,
            ),
            onPressed: () {
              setState(() {
                isLiked = !isLiked;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _duration.inMilliseconds > 0 
        ? _position.inMilliseconds / _duration.inMilliseconds 
        : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: const Color(0xFF23DD5B),
              inactiveTrackColor: Colors.grey[800],
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF23DD5B).withOpacity(0.2),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (value) {
                final newPosition = Duration(
                  milliseconds: (_duration.inMilliseconds * value).toInt(),
                );
                _audioService.seek(newPosition);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _audioService.formatDuration(_position),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                Text(
                  _audioService.formatDuration(_duration),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              isShuffle ? Icons.shuffle_on_outlined : Icons.shuffle,
              color: isShuffle ? const Color(0xFF23DD5B) : Colors.white,
            ),
            iconSize: 28,
            onPressed: () {
              setState(() {
                isShuffle = !isShuffle;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.skip_previous),
            color: Colors.white,
            iconSize: 40,
            onPressed: () async {
              await _audioService.playPrevious();
            },
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF23DD5B), Color(0xFF1DB954)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF23DD5B).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              iconSize: 36,
              onPressed: () async {
                await _audioService.togglePlayPause();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            color: Colors.white,
            iconSize: 40,
            onPressed: () async {
              await _audioService.playNext();
            },
          ),
          IconButton(
            icon: Icon(
              isRepeat ? Icons.repeat_one : Icons.repeat,
              color: isRepeat ? const Color(0xFF23DD5B) : Colors.white,
            ),
            iconSize: 28,
            onPressed: () {
              setState(() {
                isRepeat = !isRepeat;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.devices_outlined),
            color: Colors.white,
            iconSize: 26,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            color: Colors.white,
            iconSize: 26,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.queue_music),
            color: Colors.white,
            iconSize: 26,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

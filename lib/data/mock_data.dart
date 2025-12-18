import '../models/song.dart';
import '../models/playlist.dart';
import '../models/album.dart';
import '../models/artist.dart';

class MockData {
  static final List<Song> songs = [
    Song(
      id: '1',
      title: 'Ai cũng phải bắt đầu từ đâu đó',
      artist: 'HIEUTHUHAI',
      album: 'Trại sáng tác 2024',
      duration: 245,
      coverUrl: 'assets/images/image11.png',
      isLiked: true,
    ),
    Song(
      id: '2',
      title: 'ẾCH NGOÀI ĐÁY GIẾNG',
      artist: 'Phương Mỹ Chi',
      album: 'Single',
      duration: 198,
      coverUrl: 'assets/images/image3.png',
      isLiked: false,
    ),
    Song(
      id: '3',
      title: 'Ngân nga',
      artist: 'HIEUTHUHAI',
      album: 'Trại sáng tác',
      duration: 312,
      coverUrl: 'assets/images/image11.png',
      isLiked: true,
    ),
    Song(
      id: '4',
      title: 'Mưa tháng sáu',
      artist: 'Sơn Tùng M-TP',
      album: 'M-TP',
      duration: 267,
      coverUrl: 'assets/images/image6.png',
      isLiked: false,
    ),
    Song(
      id: '5',
      title: 'Em của ngày hôm qua',
      artist: 'Sơn Tùng M-TP',
      album: 'M-TP',
      duration: 289,
      coverUrl: 'assets/images/image7.png',
      isLiked: true,
    ),
    Song(
      id: '6',
      title: 'Lạc trôi',
      artist: 'Sơn Tùng M-TP',
      album: 'M-TP',
      duration: 215,
      coverUrl: 'assets/images/image8.png',
      isLiked: false,
    ),
  ];

  static final List<Playlist> playlists = [
    Playlist(
      id: 'p1',
      name: 'EM XINH SAY HI 2025',
      description: 'Những ca khúc hot nhất từ chương trình',
      coverUrl: 'assets/images/image9.png',
      songCount: 42,
    ),
    Playlist(
      id: 'p2',
      name: 'ANH TRAI SAY HI 2025',
      description: 'Playlist chill cho ngày mới',
      coverUrl: 'assets/images/image10.png',
      songCount: 38,
    ),
    Playlist(
      id: 'p3',
      name: 'V-Pop Top Hits',
      description: 'Top các bài hát V-Pop hot nhất',
      coverUrl: 'assets/images/image11.png',
      songCount: 25,
    ),
    Playlist(
      id: 'p4',
      name: 'Nhạc yêu thích',
      description: 'Những bài hát bạn đã thích',
      coverUrl: 'assets/images/image12.png',
      songCount: 56,
    ),
  ];

  static final List<Album> albums = [
    Album(
      id: 'a1',
      name: 'Trải sáng tác 2024',
      artist: 'HIEUTHUHAI',
      coverUrl: 'assets/images/image11.png',
      year: 2024,
      songCount: 12,
    ),
    Album(
      id: 'a2',
      name: 'M-TP',
      artist: 'Sơn Tùng M-TP',
      coverUrl: 'assets/images/image6.png',
      year: 2023,
      songCount: 10,
    ),
    Album(
      id: 'a3',
      name: 'Nhạc V-Pop',
      artist: 'Various Artists',
      coverUrl: 'assets/images/image7.png',
      year: 2024,
      songCount: 15,
    ),
  ];

  static final List<Artist> artists = [
    Artist(
      id: 'ar1',
      name: 'HIEUTHUHAI',
      imageUrl: 'assets/images/ellipse1.png',
      followers: '2.4M',
    ),
    Artist(
      id: 'ar2',
      name: 'Sơn Tùng M-TP',
      imageUrl: 'assets/images/ellipse2.png',
      followers: '1.8M',
    ),
    Artist(
      id: 'ar3',
      name: 'Phương Mỹ Chi',
      imageUrl: 'assets/images/ellipse3.png',
      followers: '3.2M',
    ),
  ];
}

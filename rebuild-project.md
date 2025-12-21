# Kế hoạch Tái cấu trúc & Refactoring Dự án

## 1. Phân tích Codebase (21/12/2025)

### Các file có kích thước lớn (>500 dòng)
Dưới đây là các file cần được xem xét để tách nhỏ và tối ưu hóa:

1.  **`lib/home_page.dart` (1136 dòng)**
    *   **Vấn đề**: Chứa quá nhiều logic quản lý trạng thái (`_loadData`), và các hàm xây dựng giao diện con cục bộ (`_buildQuickAccessAlbumItem`, `_buildArtistRankingItem`, `_buildNewReleaseItem`...) bị lặp lại logic ở nhiều nơi khác.
    *   **Gợi ý sửa đổi**: 
        *   Tách các widget con ra thành các component riêng biệt trong thư mục `lib/components/`.
        *   Chuyển logic tải dữ liệu (Supabase services) sang một ViewModel hoặc Provider để tách biệt UI và Logic.

2.  **`lib/main.dart` (891 dòng)**
    *   **Vấn đề**: Chứa toàn bộ giao diện màn hình đăng nhập `LoginScreen` (từ dòng 114 đến 654) và widget `MiniPlayerDynamic` (từ dòng 772 trở đi). File `main.dart` chỉ nên dùng để khởi tạo ứng dụng.
    *   **Gợi ý sửa đổi**: 
        *   Tách `LoginScreen` ra file `lib/pages/auth/login_screen.dart` và hợp nhất với `lib/pages/auth/login_page.dart` hiện có.
        *   Di chuyển `MiniPlayerDynamic` vào `lib/components/mini_player.dart` và hợp nhất logic.

3.  **`lib/search_page.dart` (861 dòng)**
    *   **Vấn đề**: Lặp lại code xây dựng các item bài hát, nghệ sĩ giống hệt trang Home. Logic tạo danh sách gợi ý (suggestions) quá dài dòng.
    *   **Gợi ý sửa đổi**: Sử dụng các component chung như `SongListTile`, `ArtistCard`, `AlbumCard` thay vì viết lại từng hàm `_build...`.

4.  **`lib/pages/artist_page.dart` (812 dòng)**
    *   **Vấn đề**: Tương tự như Home và Search, chứa logic hiển thị danh sách bài hát và album trùng lặp.
    *   **Gợi ý sửa đổi**: Áp dụng tái sử dụng component.

5.  **`lib/profile_page.dart` (724 dòng)**
    *   **Vấn đề**: Code UI và logic xử lý sự kiện đang trộn lẫn, khó bảo trì.

6.  **`lib/services/supabase_service.dart` (652 dòng)**
    *   **Vấn đề**: "God object" - Một service xử lý tất cả mọi thứ từ Bài hát, Nghệ sĩ, Album, Playlist đến User.
    *   **Gợi ý sửa đổi**: Chia nhỏ thành các Repository riêng biệt: `SongRepository`, `PlaylistRepository`, `UserRepository`, `ArtistRepository`.

---

## 2. Các cơ hội Refactor (Tái cấu trúc)

### 1. Thành phần Authentication (Xác thực)
*   **Hiện trạng**: `lib/main.dart` đang chứa class `LoginScreen`, trong khi đó `lib/pages/auth/login_page.dart` cũng tồn tại nhưng không được `main.dart` sử dụng.
*   **Đề xuất**:
    *   Tách `LoginScreen` khỏi `main.dart`.
    *   Hợp nhất code, giữ lại giao diện đẹp của `LoginScreen` (trong `main.dart`) nhưng tổ chức file vào đúng chỗ `lib/pages/auth/`.
    *   Cập nhật `AuthWrapper` để code gọn gàng hơn.

### 2. Các UI Component tái sử dụng (Reusable Widgets)
Nhiều widget đang được viết cứng (hardcoded) trong các file Page. Cần tách chúng ra để dùng chung:

*   **`SongListTile`** (Item bài hát):
    *   Đã có file `lib/core/widgets/song_list_tile.dart`.
    *   **Hành động**: Kiểm tra và nâng cấp widget này để đáp ứng đủ nhu cầu của trang Home, Search, Artist, Album, sau đó thay thế toàn bộ các hàm `_buildSongItem`.
*   **`ArtistCard`** (Thẻ nghệ sĩ):
    *   Dùng để hiển thị Avatar tròn + Tên nghệ sĩ.
    *   **Hành động**: Tạo mới component `lib/components/artist_card.dart` để dùng cho Home (list ngang) và Search (list ngang).
*   **`AlbumCard`** (Thẻ Album):
    *   Dùng để hiển thị Album cover vuông + Tên.
    *   **Hành động**: Tạo mới component `lib/components/album_card.dart` để dùng cho Home (Quick Access & New Releases), Search, và Artist Page.
*   **`MiniPlayer`**:
    *   Hợp nhất `lib/components/mini_player.dart` và `MiniPlayerDynamic` (trong `main.dart`).
    *   Đảm bảo widget này nhận vào `Song` model chuẩn thay vì `Map<String, dynamic>` để tránh lỗi runtime.

### 3. Làm gọn tầng Service
*   **Hiện trạng**: `SupabaseService` đang trả về dữ liệu dạng thô `List<Map<String, dynamic>>`. Điều này khiến UI phải liên tục gọi `Song.fromJson(...)`, gây lặp code và dễ lỗi.
*   **Đề xuất**: Chuyển đổi dữ liệu (Parsing) ngay trong Service. Service nên trả về `List<Song>`, `List<Artist>` trực tiếp.

---

## 3. Danh sách Nhiệm vụ (Checklist)

### Giai đoạn 1: Tách Component & Dọn dẹp sơ bộ ✅ HOÀN THÀNH
- [x] Tách `LoginScreen` từ `main.dart` sang `lib/pages/auth/login_screen.dart`. *(main.dart: 891 → 229 dòng)*
- [x] Hợp nhất `MiniPlayerDynamic` vào `lib/components/mini_player.dart`. *(241 dòng, hỗ trợ cả Song model và Map)*
- [x] Tạo widget mới `lib/components/artist_card.dart`. *(184 dòng, bao gồm ArtistCard và ArtistCardList)*
- [x] Tạo widget mới `lib/components/album_card.dart`. *(291 dòng, bao gồm AlbumCard, QuickAccessAlbumCard, QuickAccessAlbumGrid)*
- [x] Cập nhật `SongListTile` để linh hoạt hơn. *(Đã có sẵn tại lib/core/widgets/song_list_tile.dart)*

### Giai đoạn 2: Refactor các màn hình chính ✅ HOÀN THÀNH
- [x] Refactor `home_page.dart`: Sử dụng `QuickAccessAlbumGrid`, `ArtistCard`. *(1136 → 952 dòng, giảm 184 dòng)*
- [x] Refactor `search_page.dart`: Sử dụng `ArtistCard`. *(861 → 840 dòng, giảm 21 dòng)*
- [x] Refactor `main.dart`: Xóa code thừa LoginScreen và MiniPlayerDynamic. *(891 → 229 dòng, giảm 662 dòng)*

### Giai đoạn 3: Refactor Service & Model (Đề xuất cho tương lai)
- [ ] Cập nhật `SupabaseService` để trả về dữ liệu dạng Model thay vì Map.
- [ ] (Tùy chọn) Chia nhỏ `SupabaseService` nếu file vẫn còn quá lớn.

---

## Kết quả Refactoring

| File | Trước | Sau | Giảm |
|------|-------|-----|------|
| `main.dart` | 891 | 229 | **-662 dòng** |
| `home_page.dart` | 1136 | 952 | **-184 dòng** |
| `search_page.dart` | 861 | 840 | **-21 dòng** |
| **Tổng giảm** | | | **-867 dòng** |

### Components mới được tạo:
- `lib/pages/auth/login_screen.dart` (548 dòng)
- `lib/components/artist_card.dart` (184 dòng)
- `lib/components/album_card.dart` (291 dòng)
- `lib/components/mini_player.dart` (241 dòng - đã cập nhật)


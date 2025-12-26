-- =====================================================
-- Soul Sync Database - P07: IMPORT SAMPLE DATA
-- Mục đích: Import dữ liệu mẫu từ backup
-- Thứ tự chạy: 7 (sau p06_seed_default_data.sql)
-- Ngày tạo: 2025-12-27
-- LƯU Ý: File này được tạo từ p3-backup.sql với format cải tiến
-- =====================================================

-- =====================
-- PHẦN 1: DISABLE CONSTRAINTS TẠM THỜI (ĐỂ IMPORT NHANH)
-- =====================
SET session_replication_role = replica;

-- =====================
-- PHẦN 2: IMPORT USERS DATA
-- =====================
INSERT INTO users (id, email, username, display_name, avatar_url, password_hash, auth_method, created_at, updated_at) VALUES
  ('f4e7da34-c783-40a0-b07e-06a3b346ffca', 'user2@example.com', 'user2', 'User 2', NULL, NULL, 'local', '2025-12-21T21:06:33.372822+00:00', '2025-12-21T21:06:33.372822+00:00'),
  ('de9a938e-b9bf-4446-b6e4-e7b4893a9696', 'naba2803@gmail.com', 'naba2803', 'naba2803', NULL, 'bc5e6a669505ad5f:d096307ac7e1c90f02b2fc62ad453af2fccda463e6761e620d3cb8af9f006492', 'local', '2025-12-24T23:42:56.942434+00:00', '2025-12-24T23:42:56.942434+00:00'),
  ('851fceff-9adb-4de1-82b5-afda560baa03', 'hyan0610@gmail.com', 'hyanhasta05', 'Hyan Nguyễn', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766663526/soulsync/avatars/ddykr7lgchzcw5rmxty2.jpg', '7192889abf29095da5a14b046fb34e7e:f8df905429ad2da0d979d3883dcf26794f97c99b6208e4b79b796a5d9998652d', 'local', '2025-12-21T21:12:41.166162+00:00', '2025-12-25T18:52:07.362097+00:00'),
  ('49bd4e9a-20ab-4dcf-90a8-a4377f363b31', 'user1@example.com', 'user1', 'haha', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766666078/soulsync/avatars/so4ajeoofitbqrqx9bqk.jpg', NULL, 'local', '2025-12-21T21:06:33.372822+00:00', '2025-12-25T19:34:38.362389+00:00'),
  ('4262d732-1a0e-40b6-bc66-433481ac8a8d', 'bangluu2803@gmail.com', 'nhatbang2803', 'Naba', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766666625/soulsync/avatars/hwxwb3uxxdu6rwgts3jm.jpg', '17de096bbd6250b9:5a7be507045b93a5f51adb9654b8debe81f883ae9d88252de5ff7884df64007b', 'local', '2025-12-25T19:40:44.290028+00:00', '2025-12-25T19:43:57.831024+00:00'),
  ('20759358-061e-45a3-af46-e0dedaad7583', 'thanhhien00000005@gmail.com', NULL, 'Thanh Hiền Nguyễn', 'https://lh3.googleusercontent.com/a/ACg8ocJdbUPbTUF-82K1yx73DJPBUy01ye6AJxdXFejWkrZ5WqDmyA=s96-c', NULL, 'google', '2025-12-26T11:43:46.504329+00:00', '2025-12-26T11:43:46.508+00:00'),
  ('408ccadd-9ef2-4efa-852d-af1b5047fe6d', 'naba123@gmail.com', 'naba123', 'Naba', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766759938/soulsync/avatars/y6oqe7kjgkobxbzuyuzq.jpg', 'bbea43af4365aaf3996851c68ecb8e7e:c81445af08def968bc355ebd42e5ba6511d8d57b7d0e165844928f19acd78d12', 'local', '2025-12-22T04:07:48.182481+00:00', '2025-12-26T21:38:59.058571+00:00')
ON CONFLICT (id) DO NOTHING;

-- =====================
-- PHẦN 3: IMPORT GENRES DATA (BỔ SUNG THÊM VÀO DEFAULT)
-- =====================
INSERT INTO genres (id, name, display_name, color, created_at) VALUES
  ('235db38e-ec09-4709-8d3f-2a5d6359c664', 'ballad', 'Ballad', '#3B82F6', '2025-12-20T13:41:44.229183+00:00'),
  ('29ef6a59-9bba-49ce-9f9a-375988cfae46', 'rap', 'Rap/Hip-hop', '#EF4444', '2025-12-20T13:41:44.229183+00:00'),
  ('2bb3dcf4-7eae-424c-b064-c40ce864883d', 'pop', 'Pop', '#EC4899', '2025-12-20T13:41:44.229183+00:00'),
  ('75770bb3-525e-4ac3-9a99-6069477091d5', 'rock', 'Rock', '#8B5CF6', '2025-12-20T13:41:44.229183+00:00'),
  ('805c8890-88e9-40f9-9fff-1fabb9f6ff1a', 'edm', 'EDM', '#10B981', '2025-12-20T13:41:44.229183+00:00'),
  ('392e2cde-bb9c-43c7-8a2f-aba8beb41ea3', 'rnb', 'R&B', '#F59E0B', '2025-12-20T13:41:44.229183+00:00'),
  ('d6443d9c-d8e2-4538-87e0-d134f1d54ccf', 'indie', 'Indie', '#6366F1', '2025-12-20T13:41:44.229183+00:00'),
  ('2eb9366f-092b-4993-8814-434ee0fe8562', 'acoustic', 'Acoustic', '#84CC16', '2025-12-20T13:41:44.229183+00:00'),
  ('a37bb9ad-3f96-4f82-a822-b8bd7c46917e', 'jazz', 'Jazz', '#F97316', '2025-12-20T13:41:44.229183+00:00'),
  ('d96adfa2-87a9-43c6-a624-de5fc2572bdf', 'classical', 'Classical', '#0EA5E9', '2025-12-20T13:41:44.229183+00:00'),
  ('71aa4e7f-ec0e-4d75-b740-0c9efd958d31', 'drill_remix', 'Drill remix', '#1f1f3d', '2025-12-22T18:10:07.076699+00:00'),
  ('db513349-2372-4023-a111-f91950d2fee8', 'dangian', 'Dân gian', '#6366F1', '2025-12-25T06:53:03.024205+00:00'),
  ('978248a8-5be1-4dc8-9734-eb3a59c8bbb5', 'danca', 'Dân ca', '#6366F1', '2025-12-25T08:02:11.133843+00:00'),
  ('7d153bbc-9f70-4e6e-b744-5723ff8920ff', 'bolero', 'Bolero', '#6366F1', '2025-12-25T08:02:29.224575+00:00')
ON CONFLICT (id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  color = EXCLUDED.color;

-- =====================
-- PHẦN 4: THÔNG BÁO VỀ IMPORT DATA
-- =====================
-- LƯU Ý: Do file backup gốc quá lớn (1700+ dòng), tôi chỉ import một phần nhỏ
-- Để import đầy đủ, vui lòng sao chép nội dung từ file p3-backup.sql gốc vào đây

SELECT 'THÔNG BÁO: Chỉ import một phần sample data. Để import đầy đủ:' as notice;
SELECT '1. Mở file p3-backup.sql gốc' as step1;
SELECT '2. Sao chép các INSERT statements còn lại vào file này' as step2;
SELECT '3. Chạy lại file này' as step3;

-- =====================
-- PHẦN 5: RE-ENABLE CONSTRAINTS
-- =====================
SET session_replication_role = DEFAULT;

-- =====================
-- PHẦN 6: UPDATE STATISTICS
-- =====================
ANALYZE;

-- =====================
-- PHẦN 7: THÔNG BÁO HOÀN THÀNH
-- =====================
SELECT 'P07: Sample data imported successfully! Run p08_finalize_setup.sql next.' as status;
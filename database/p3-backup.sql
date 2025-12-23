-- =====================================================
-- Soul Sync Database - FILE 4: BACKUP DATA
-- Mục đích: Seed data / Restore data
-- Thứ tự chạy: 4 (sau file1.sql và file2.sql)
-- QUAN TRỌNG: Chạy SAU khi đã tạo schema (file1.sql)
-- Generated at: 2025-12-23T17:19:50.363Z
-- =====================================================

-- =====================
-- THỨ TỰ INSERT (theo foreign key dependencies):
-- 1. users (không phụ thuộc)
-- 2. artists (không phụ thuộc)
-- 3. genres (không phụ thuộc)
-- 4. albums (không phụ thuộc)
-- 5. songs (không phụ thuộc)
-- 6. playlists (phụ thuộc users)
-- 7. song_artists (phụ thuộc songs, artists)
-- 8. album_artists (phụ thuộc albums, artists)
-- 9. album_songs (phụ thuộc albums, songs)
-- 10. song_genres (phụ thuộc songs, genres)
-- =====================

-- users
INSERT INTO users (id, email, username, display_name, avatar_url, password_hash, auth_method, created_at, updated_at) VALUES
  ('49bd4e9a-20ab-4dcf-90a8-a4377f363b31', 'user1@example.com', 'user1', 'User 1', NULL, NULL, 'local', '2025-12-21T21:06:33.372822+00:00', '2025-12-21T21:06:33.372822+00:00'),
  ('f4e7da34-c783-40a0-b07e-06a3b346ffca', 'user2@example.com', 'user2', 'User 2', NULL, NULL, 'local', '2025-12-21T21:06:33.372822+00:00', '2025-12-21T21:06:33.372822+00:00'),
  ('408ccadd-9ef2-4efa-852d-af1b5047fe6d', 'naba123@gmail.com', 'naba123', 'naba123', NULL, 'bbea43af4365aaf3996851c68ecb8e7e:c81445af08def968bc355ebd42e5ba6511d8d57b7d0e165844928f19acd78d12', 'local', '2025-12-22T04:07:48.182481+00:00', '2025-12-22T04:07:48.182946+00:00'),
  ('851fceff-9adb-4de1-82b5-afda560baa03', 'hyan0610@gmail.com', 'hyanhasta05', 'Hyan Nguyễn', NULL, '7192889abf29095da5a14b046fb34e7e:f8df905429ad2da0d979d3883dcf26794f97c99b6208e4b79b796a5d9998652d', 'local', '2025-12-21T21:12:41.166162+00:00', '2025-12-21T21:12:41.166162+00:00')
ON CONFLICT DO NOTHING;

-- artists
INSERT INTO artists (id, name, image_url, followers, monthly_listeners, is_verified, bio, created_at, updated_at) VALUES
  ('e06ae9ac-0929-404f-b540-fc2ebb2f9001', 'JSol', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766242555/dkjlfrmzd7nxdsm4c9fa.webp', 213402, 91231, TRUE, '', '2025-12-20T14:56:08.358652+00:00', '2025-12-20T14:56:08.358652+00:00'),
  ('2c47faab-e3ca-4ef7-aa89-57f1c0a095fe', 'Chillies', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766254322/teri0wheklrrhwsfpy05.jpg', 1231230, 12312310, TRUE, '', '2025-12-20T18:12:06.4382+00:00', '2025-12-20T18:12:06.4382+00:00'),
  ('a5555555-5555-5555-5555-555555555555', 'Hoàng Thùy Linh', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766260973/tj8mnxit90ljq1doe3eu.jpg', 1800000, 950000, TRUE, '', '2025-12-20T13:41:44.229183+00:00', '2025-12-20T13:41:44.229183+00:00'),
  ('a2222222-2222-2222-2222-222222222222', 'Sơn Tùng M-TP', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261011/tirllf2ecbigl7pxgga5.jpg', 5500000, 3200000, TRUE, '', '2025-12-20T13:41:44.229183+00:00', '2025-12-20T13:41:44.229183+00:00'),
  ('2a181377-7eb1-4a43-bc8c-a676b8aaca48', 'Amee', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261147/zbdrniwd5igzwtproqmg.jpg', 32101, 461021, TRUE, '', '2025-12-20T20:05:59.793755+00:00', '2025-12-20T20:05:59.793755+00:00'),
  ('a3333333-3333-3333-3333-333333333333', 'Phương Mỹ Chi', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766314699/ryzlctuznhvnd61dbxuc.jpg', 1200000, 800000, TRUE, '', '2025-12-20T13:41:44.229183+00:00', '2025-12-20T13:41:44.229183+00:00'),
  ('789e67f2-34c5-425b-8bc7-23ccbc6316d3', 'DTAP', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766316254/aspqt3gsuyywzxpi6p9m.jpg', 2123049, 8126140, TRUE, '', '2025-12-21T11:24:18.523179+00:00', '2025-12-21T11:24:18.523179+00:00'),
  ('67694317-ee44-4b05-9a61-ea2e4c52ed9c', 'JustaTee', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766317661/j7hb3vyhimhezl6cdxuc.jpg', 3286310, 9712360, TRUE, '', '2025-12-21T11:47:53.590054+00:00', '2025-12-21T11:47:53.590054+00:00'),
  ('71afa9dd-3d6a-4cd0-8c74-f3e4002d2c99', 'TLinh', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766317746/jxxbslrhv2ujhb2fk0ms.jpg', 9179080, 4521901, TRUE, '', '2025-12-21T11:49:24.709751+00:00', '2025-12-21T11:49:24.709751+00:00'),
  ('663b117b-a52f-4571-9efc-1a69729e6119', 'Low G', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261105/nbhgdsqewyhrxsvhx4s6.jpg', 12301124, 12306341, TRUE, '', '2025-12-20T20:05:16.507647+00:00', '2025-12-20T20:05:16.507647+00:00'),
  ('9700cee4-270d-4bea-9dd2-3e97b142b89a', 'Quang Hùng Master D', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766314978/eksnexpnovdtrfikaume.jpg', 123981124, 123456789, TRUE, '', '2025-12-20T14:32:05.475267+00:00', '2025-12-20T14:32:05.475267+00:00'),
  ('a4444444-4444-4444-4444-444444444444', 'Đen Vâu', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261030/altcyftpqedn0qalzkxq.jpg', 3200001, 2100000, TRUE, '', '2025-12-20T13:41:44.229183+00:00', '2025-12-20T13:41:44.229183+00:00'),
  ('a1111111-1111-1111-1111-111111111111', 'HIEUTHUHAI', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766260956/a8xzrfiyrr9pgnbussru.jpg', 2400001, 1800000, TRUE, '', '2025-12-20T13:41:44.229183+00:00', '2025-12-20T13:41:44.229183+00:00'),
  ('9121618a-9da5-4713-b130-fbd9a0bae4a3', 'Bray', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261048/rjwtiakhpcvfg0pjwtxk.jpg', 1230414, 12310122, TRUE, '', '2025-12-20T20:04:23.091332+00:00', '2025-12-20T20:04:23.091332+00:00'),
  ('bfaff4c5-6251-4d3a-a33b-45b085d6a08a', 'Ngân Lâm', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766423435/teoia2sxudku70kqrqdg.jpg', 0, 0, FALSE, '', '2025-12-22T17:10:39.521444+00:00', '2025-12-22T17:10:39.521444+00:00'),
  ('602d1cd8-f87e-4bdf-bcf7-86019f4eb0d4', 'Orio', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766426954/bbik4fdypm4zv39twxq4.jpg', 999999, 0, FALSE, '', '2025-12-22T18:09:21.780777+00:00', '2025-12-22T18:09:21.780777+00:00'),
  ('604fd2f8-04c7-4c3f-9864-7527e22580ab', 'Cristn1', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766428751/ejzwo7z8jbul7qbzsxnz.jpg', 99999, 0, FALSE, '', '2025-12-22T18:39:23.044634+00:00', '2025-12-22T18:39:23.044634+00:00'),
  ('860414cb-9d0b-4e0e-836b-542bdde341fe', 'Htingale X Ryuuko Remix', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766428824/fgjhkn04slcggbqz8c8b.jpg', 999999, 0, FALSE, '', '2025-12-22T18:40:34.379614+00:00', '2025-12-22T18:40:34.379614+00:00'),
  ('040e1d87-ef9a-463c-a746-5b6a0140c912', 'Kuyo', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766426921/bukoxu3qwpjxctnanuq0.jpg', 1000000, 0, FALSE, '', '2025-12-22T18:08:54.505708+00:00', '2025-12-22T18:08:54.505708+00:00')
ON CONFLICT DO NOTHING;

-- genres
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
  ('71aa4e7f-ec0e-4d75-b740-0c9efd958d31', 'drill_remix', 'Drill remix', '#1f1f3d', '2025-12-22T18:10:07.076699+00:00')
ON CONFLICT DO NOTHING;

-- albums
INSERT INTO albums (id, name, cover_url, release_year, song_count, listen_count, is_public, created_at, updated_at) VALUES
  ('53cbb2f9-f2f4-46e5-ad09-2dd4e48884e5', '[Đĩa đơn] - Đừng Làm Trái Tim Anh Đau', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261255/lx7ltctesij4dswxf50r.jpg', 2025, 1, 0, TRUE, '2025-12-20T20:50:34.610053+00:00', '2025-12-20T20:50:34.610053+00:00'),
  ('61ae6a4d-6657-4c25-bb6b-efb4399f8a67', '[Đĩa đơn] - Chúng Ta Của Hiện Tại', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261277/wd3vwvtidbtqtyr56tsy.jpg', 2025, 1, 0, TRUE, '2025-12-20T20:50:47.310487+00:00', '2025-12-20T20:50:47.310487+00:00'),
  ('d04c7738-c95a-439b-985b-18a3155e5027', '[Đĩa đơn] - Do For Love', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261383/qgeld8jsugpfbnlrdver.jpg', 2025, 1, 0, TRUE, '2025-12-20T20:51:27.973136+00:00', '2025-12-20T20:51:27.973136+00:00'),
  ('b1111111-1111-1111-1111-111111111111', 'Ai Cũng Phải Bắt Đầu Từ Đâu Đó', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261740/ejbikfllycbvxvk6q98k.jpg', 2024, 4, 0, TRUE, '2025-12-20T13:41:44.229183+00:00', '2025-12-20T13:41:44.229183+00:00'),
  ('ee050eeb-6475-4e4c-803a-f49312282f91', '[Đĩa đơn] - Thủy triều', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766315008/f27qm48k5vb6azjahr7u.jpg', 2025, 1, 0, TRUE, '2025-12-21T11:04:07.704896+00:00', '2025-12-21T11:04:07.704896+00:00'),
  ('d1000c1b-8ecf-4924-b5a1-94f8ae644ff2', 'Vũ Trụ Cò Bay', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766316545/xmm84fbnnz09rm8yhllf.jpg', 2025, 1, 0, TRUE, '2025-12-21T11:29:10.250771+00:00', '2025-12-21T11:29:10.250771+00:00'),
  ('5835eb3f-fe10-415d-a9f7-38a9a7c14784', 'L2K', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766317702/rpatwdjcjadk49wzwq6z.jpg', 2025, 5, 0, TRUE, '2025-12-21T11:48:36.023642+00:00', '2025-12-21T11:48:36.023642+00:00'),
  ('3e07f537-6b54-4ee9-9534-e79ecb82b6bc', 'Qua Khung Cửa Sổ', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766315325/o4fwpevcoqvzktafrd5d.jpg', 2021, 2, 0, TRUE, '2025-12-21T11:09:24.753704+00:00', '2025-12-21T11:09:24.753704+00:00'),
  ('9e7233f9-2bba-47b8-8d5a-33ab4a8904c7', 'Cho Bảo', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766315077/bty4dd2j82xv9857ovuq.jpg', 2025, 1, 0, TRUE, '2025-12-21T11:04:40.780812+00:00', '2025-12-21T11:04:40.780812+00:00'),
  ('8c7b674e-63e4-4fc1-a9ca-caba5c8af887', '[Đĩa đơn] - Lưu Quang Ký (流光记)', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766423486/mqqi9txtxhiluuvekegi.jpg', 2025, 1, 0, TRUE, '2025-12-22T17:11:30.62777+00:00', '2025-12-22T17:11:30.62777+00:00'),
  ('09964f24-c5a5-4ad1-b3c3-071669f809e0', 'Trái tim cô đơn', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766427224/w4qmvr2u7ljdr8nqn1g9.jpg', 2025, 5, 0, TRUE, '2025-12-22T18:13:46.943358+00:00', '2025-12-22T18:13:46.943358+00:00'),
  ('1508ff05-6c8d-4a2e-919a-340b5c243766', 'Lại nhớ em', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766428916/j5vvrln0ymjim3jx8f3w.jpg', 2025, 3, 0, TRUE, '2025-12-22T18:41:58.352988+00:00', '2025-12-22T18:41:58.352988+00:00'),
  ('dcb81438-1b12-43f3-b340-17950c8a78d5', 'Tình ơi là tình', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766427186/slbrkcqrgpdodf2x76nt.jpg', 2025, 4, 0, TRUE, '2025-12-22T18:13:09.454305+00:00', '2025-12-22T18:13:09.454305+00:00')
ON CONFLICT DO NOTHING;

-- songs
INSERT INTO songs (id, title, duration, audio_url, cover_url, play_count, created_at) VALUES
  ('c3333333-3333-3333-3333-333333333333', 'Đừng Làm Trái Tim Anh Đau', 279, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261228/e9tbwdfunsjjmonk6xun.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261255/lx7ltctesij4dswxf50r.jpg', 864112006, '2025-10-21T13:41:44.229183+00:00'),
  ('cba1fe39-a6cd-4e11-8de9-f6dd040c8525', 'Mộng Yu Drill', 206, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766427102/tl5ikvbzck15uahpjrsh.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766427117/bnh1qc9wnicthi7ttvmj.jpg', 3, '2024-01-01T00:00:00+00:00'),
  ('0cea8264-8f13-4973-b354-44e32948d338', 'Cho em an toàn', 232, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261556/xabc29mpjhz0sjxy9bwb.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261567/ixa8atsz2wgt1dbh8o2b.jpg', 37566040, '2025-12-20T20:13:06.609057+00:00'),
  ('9729b8a9-00c3-4bc4-840e-69781b96a160', 'Exit Sign', 202, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261646/shhzzmjprfrdt645bfp0.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261667/exxur4ryv9twyfmbotu1.jpg', 9283130, '2025-12-20T20:14:32.903381+00:00'),
  ('1899deb4-67a4-474b-b9b9-5038a784849e', 'Mama Boy Drill', 236, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766427250/zxpsbge4mmvlzid4jv4t.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766427289/ygvitetuxtsekwibyzbg.jpg', 3, '2024-01-01T00:00:00+00:00'),
  ('53da82be-8e91-44a8-a21d-80a52e3a0ae1', 'Mascara', 300, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766315613/ncpeukcael3uvr1t6d5g.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766315666/yprdq6fwhnoure7ghszx.jpg', 1208317, '2025-12-21T11:14:35.445328+00:00'),
  ('5dab6c55-9023-4fc0-ac3a-cb39b83460ed', 'Vùng Ký Ức', 328, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766315477/hlcwqhgbg2do6xeteau4.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766315540/ioshsirnz19zwdzq0lsy.jpg', 69521013, '2025-12-21T11:12:29.568158+00:00'),
  ('b49e3fa7-4993-4693-be76-1cb4c00c9d79', 'Nhiều Hơn', 186, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766317927/wv8xziurezwoniyvuicr.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766317926/gvyffaer9tnkam2zergq.jpg', 1978129, '2025-12-21T11:52:15.488457+00:00'),
  ('98842d70-046c-4c9e-aa1d-f07f728b6142', 'Vùng An Toàn', 266, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261429/zfzy3oagf3e3lklisqll.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261447/h1gbu8wznvxwc3tap9ps.jpg', 234810, '2025-12-20T20:10:53.218462+00:00'),
  ('e273a4ef-9589-4b62-a3ee-386319dfc06a', 'Em Đừng Khóc', 283, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766254519/ukxfrmros0cxilpfgrbi.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766254556/ewrvl3ptebi4pxqvjnir.webp', 1270454, '2025-12-20T18:16:17.901016+00:00'),
  ('4a9b4812-f97b-44df-b8ae-b7b8d10ed081', 'Lưu Quang Ký (流光记)', 285, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766423485/s5e25h7sp0eirkoyptvs.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766423486/mqqi9txtxhiluuvekegi.jpg', 6, '2025-12-22T17:11:30.386004+00:00'),
  ('34507f51-cb9b-4a4a-a568-bae3f6248a3d', 'Đừng Để Tiền Rời', 179, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766318089/vp3xmddngmlfn1yqmpk9.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766318116/w90ryy5bbsqk5tw506jp.jpg', 1290895, '2025-12-21T11:55:27.05361+00:00'),
  ('bb71b6a4-4039-4e2e-ae35-26d3a29da29e', 'Siêu Sao', 172, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766317871/auinmidd83227h6rdl0v.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766317864/znimocaihud8cq3jfafv.jpg', 10891231, '2025-12-21T11:51:32.814471+00:00'),
  ('42894706-bfb5-47b7-9f50-f03d190c82d5', 'IN LOVE', 201, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766318038/r09fg2uwuvgyqv54cney.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766318060/lqiiwvavoqnxj35n1xeg.jpg', 90213022, '2025-12-21T11:54:31.415717+00:00'),
  ('dfb0c4a0-d021-4286-b157-819177e2dd13', 'NO LOVE NO LIFE', 172, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261690/hcm98wcuv2qlckzw3wzh.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261716/x7qf54zqjrod8yhvsap1.jpg', 98671234, '2025-12-20T20:15:21.611044+00:00'),
  ('eb0828f7-7979-4518-bb3e-f83d1c000cda', 'Không thể say', 261, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261498/ekmlkoptnlrtxmilqjwj.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261505/gi7qdcm3ayztrxn0t8fc.jpg', 58149131, '2025-12-20T20:11:50.018868+00:00'),
  ('34576c5b-a198-4dc3-8f15-e74f66b3c303', 'Chúng Ta Của Hiện Tại', 302, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261276/knao56rjmzcwzxd3ltpq.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261277/wd3vwvtidbtqtyr56tsy.jpg', 583470816, '2025-12-20T20:08:47.011606+00:00'),
  ('4ae76cf9-cc59-4cc4-9398-32d7c6f21add', 'Thủy triều', 186, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766241199/eflddfiibsqtuauvbjnr.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766315008/f27qm48k5vb6azjahr7u.jpg', 29183125, '2025-12-20T14:32:39.370734+00:00'),
  ('5a817062-ce41-41ee-b2ea-c9d4a816dd05', 'Do For Love', 207, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261361/lqvokjo7liio3eosagmr.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261383/qgeld8jsugpfbnlrdver.jpg', 23480335, '2025-12-20T20:09:51.101515+00:00'),
  ('af2cc869-07a3-4adc-9f1b-c9a04db91ffe', 'Bóng Phù Hoa', 275, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766316315/iyx3yzshusswmty6focc.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766316512/eem3lk9xzffetcnx2pvh.jpg', 498123204, '2025-12-21T11:28:46.906455+00:00'),
  ('a7a66cf4-619d-4659-84db-f568a715fe30', 'LOVE GAME', 200, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766317972/ffnalurwhnp8hkoad6g7.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766317973/tryq4w49ib6ktg6ppwmk.jpg', 51123013, '2025-12-21T11:53:03.507143+00:00'),
  ('f23cd0aa-d7c0-4d75-afb3-f1848ad4b5b2', 'Cà phê drill', 216, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766427426/sz2nv7rlsnpuogqmi5ht.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766427461/bmtc6svukjboavu29u5c.jpg', 2, '2024-01-01T00:00:00+00:00'),
  ('a2dba7a1-2b14-4a14-9e79-2aa033c5cc7b', 'Tình yêu màu nắng drill', 214, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766427501/vrq76homd5685hqq7pm9.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766427534/inqtukvat47a04htiei4.jpg', 1, '2024-01-01T00:00:00+00:00'),
  ('0a439be7-40fa-4d26-8c2b-2c324f4b5f44', 'Chăm hoa drill', 202, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766427707/bjvdkojxsxrb8vc3lhdw.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766427716/pexnojx1padksa2hzv7e.jpg', 3, '2024-01-01T00:00:00+00:00'),
  ('d56aa327-094e-43cf-9430-3bc20efaaee1', 'Trời giấu trời mang đi drill', 176, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766427577/gpcqqam4ahcjyffvv3ll.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766427602/hri9qa4qarfcaaojgfvv.jpg', 1, '2024-01-01T00:00:00+00:00'),
  ('b0fb0d52-b26a-42a1-b4a6-6610965994ca', 'Tình yêu ngủ quên drill', 135, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766428952/kiiidtxih02fwptypqzp.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766428993/wksxe5kyfoiiuthswji4.jpg', 1, '2024-01-01T00:00:00+00:00'),
  ('79f45f36-f5ee-48a0-b020-dfa2720270d1', 'Tháng năm drill', 200, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766429015/ozvsoas4nrinohlbi3cr.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766429040/tjnoajrjilgojb2kbe3b.jpg', 2, '2024-01-01T00:00:00+00:00'),
  ('aa5398e1-7917-4770-bd08-1b4503480d31', 'Đừng làm trái tim anh đau drill', 264, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766427631/b2bd6m3ijnp8w2jpv40l.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766427656/qeiucrjhfnqjptppezzv.jpg', 2, '2024-01-01T00:00:00+00:00'),
  ('09342748-02bf-4c98-94f3-660768f3bfbc', 'Anh là ai drill', 232, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766427845/igip2gxf06yjh7nx4a2e.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766427869/md1iza0djj7gkdjkmkkk.jpg', 3, '2024-01-01T00:00:00+00:00'),
  ('bd8c8df2-e99a-4eed-9b65-048a01a5baf9', 'Cuộc gọi lúc nữa đêm drill', 167, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766427324/fpscn3bb9c0czv9rrlyb.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766427351/vrmi20y4dymuwy7ty0l6.jpg', 1, '2024-01-01T00:00:00+00:00'),
  ('cbafab8b-47c5-4c28-8302-9a8bec5092b9', 'Tâm trí lang thang drill', 218, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766429198/nqujou6vtlmbfulaob7i.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766429223/wfljwxvzrf9tvtw2mnje.jpg', 2, '2024-01-01T00:00:00+00:00'),
  ('bd2506e8-26aa-4f75-94f7-7d5f298da1a1', 'Em còn nhớ anh không drill', 148, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766429095/wonnpi1enfvq7qtzsseo.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766429100/eyrp9ldwlavpsv832dws.jpg', 7, '2024-01-01T00:00:00+00:00')
ON CONFLICT DO NOTHING;

-- playlists
INSERT INTO playlists (id, owner_id, name, description, cover_url, is_public, song_count, listen_count, created_at, updated_at) VALUES
  ('901f90ac-e5b7-4641-bd04-71b24f06641c', '851fceff-9adb-4de1-82b5-afda560baa03', 'Vibe coding time', NULL, NULL, TRUE, 1, 0, '2025-12-22T11:02:29.220357+00:00', '2025-12-22T11:02:29.220357+00:00'),
  ('0c72b5b8-11cc-4ea6-be8a-e2e088130648', '851fceff-9adb-4de1-82b5-afda560baa03', 'Tình yêu rất drill', NULL, NULL, TRUE, 13, 0, '2025-12-22T18:49:35.250134+00:00', '2025-12-22T18:49:35.250134+00:00')
ON CONFLICT DO NOTHING;

-- song_artists
INSERT INTO song_artists (id, song_id, artist_id, role, position) VALUES
  ('d41bf3f6-b31d-4aa5-80c9-d56388232e1c', 'c3333333-3333-3333-3333-333333333333', 'a2222222-2222-2222-2222-222222222222', 'main', 0),
  ('e8f05abc-8f82-450a-9301-bf0f7d0047b5', '34576c5b-a198-4dc3-8f15-e74f66b3c303', 'a2222222-2222-2222-2222-222222222222', 'main', 0),
  ('1f2ea4ef-4a87-4cc4-bebf-00b4ee7109d1', '5a817062-ce41-41ee-b2ea-c9d4a816dd05', '2a181377-7eb1-4a43-bc8c-a676b8aaca48', 'main', 0),
  ('e115b6ab-e479-4732-9a4a-843429555527', '5a817062-ce41-41ee-b2ea-c9d4a816dd05', '9121618a-9da5-4713-b130-fbd9a0bae4a3', 'main', 0),
  ('967281a0-7fc2-4ad1-9b5f-b4e8dd7ad0d3', 'dfb0c4a0-d021-4286-b157-819177e2dd13', 'a1111111-1111-1111-1111-111111111111', 'main', 0),
  ('5986225a-e247-49d9-9357-a3cae0b8e594', '0cea8264-8f13-4973-b354-44e32948d338', 'a1111111-1111-1111-1111-111111111111', 'main', 0),
  ('27e80814-d393-41e3-8db4-1859875b20a2', '9729b8a9-00c3-4bc4-840e-69781b96a160', 'a1111111-1111-1111-1111-111111111111', 'main', 0),
  ('c51988fe-8554-4557-8bab-2105d692cd4c', 'eb0828f7-7979-4518-bb3e-f83d1c000cda', 'a1111111-1111-1111-1111-111111111111', 'main', 0),
  ('d80f1494-54b1-458f-ac68-025b45e6a3c9', '4ae76cf9-cc59-4cc4-9398-32d7c6f21add', '9700cee4-270d-4bea-9dd2-3e97b142b89a', 'main', 0),
  ('cb53e7d8-979a-4abb-8726-020740426f85', '53da82be-8e91-44a8-a21d-80a52e3a0ae1', '2c47faab-e3ca-4ef7-aa89-57f1c0a095fe', 'main', 0),
  ('6e003dd6-1c5e-4ead-8ee6-c3e8912673dc', 'e273a4ef-9589-4b62-a3ee-386319dfc06a', '2c47faab-e3ca-4ef7-aa89-57f1c0a095fe', 'main', 0),
  ('406385f5-8e4d-4286-bc41-911c5134ca72', 'bb71b6a4-4039-4e2e-ae35-26d3a29da29e', '663b117b-a52f-4571-9efc-1a69729e6119', 'main', 0),
  ('62b1bc8b-595b-43a2-978d-cb7b16999102', 'b49e3fa7-4993-4693-be76-1cb4c00c9d79', '663b117b-a52f-4571-9efc-1a69729e6119', 'main', 0),
  ('f13d5a14-f4ca-4c1f-b4ef-e5dc811f29dc', 'a7a66cf4-619d-4659-84db-f568a715fe30', '663b117b-a52f-4571-9efc-1a69729e6119', 'main', 0),
  ('50b2ba5c-1551-44a9-b08d-da59d6de201f', 'a7a66cf4-619d-4659-84db-f568a715fe30', '71afa9dd-3d6a-4cd0-8c74-f3e4002d2c99', 'main', 0),
  ('b8205d0b-bbaa-4781-b2f1-593e2e139a26', '42894706-bfb5-47b7-9f50-f03d190c82d5', '663b117b-a52f-4571-9efc-1a69729e6119', 'main', 0),
  ('f326e079-66fb-42ef-b4b1-72eaae22f272', '42894706-bfb5-47b7-9f50-f03d190c82d5', '67694317-ee44-4b05-9a61-ea2e4c52ed9c', 'main', 0),
  ('daa2f2fa-e8b6-4d3e-a1b6-29e0e2e4e000', 'af2cc869-07a3-4adc-9f1b-c9a04db91ffe', '789e67f2-34c5-425b-8bc7-23ccbc6316d3', 'main', 0),
  ('70fc0d02-4f6c-4f08-867a-8ef786d0afcc', 'af2cc869-07a3-4adc-9f1b-c9a04db91ffe', 'a3333333-3333-3333-3333-333333333333', 'main', 0),
  ('07750567-1a89-4e24-9ea3-de254c6b80f9', '34507f51-cb9b-4a4a-a568-bae3f6248a3d', '663b117b-a52f-4571-9efc-1a69729e6119', 'main', 0),
  ('a29e88c3-7fee-43e8-ade5-ac274b2f8735', '5dab6c55-9023-4fc0-ac3a-cb39b83460ed', '2c47faab-e3ca-4ef7-aa89-57f1c0a095fe', 'main', 0),
  ('a029e70c-9f6c-4f29-86db-dd35d5be5a2f', '98842d70-046c-4c9e-aa1d-f07f728b6142', '9121618a-9da5-4713-b130-fbd9a0bae4a3', 'main', 0),
  ('c282c0db-33a5-4675-b0c6-d2bd7ba7b0cf', '4a9b4812-f97b-44df-b8ae-b7b8d10ed081', 'bfaff4c5-6251-4d3a-a33b-45b085d6a08a', 'main', 0),
  ('b0a896a3-5140-4686-94b5-66ba8e382a46', 'cba1fe39-a6cd-4e11-8de9-f6dd040c8525', '602d1cd8-f87e-4bdf-bcf7-86019f4eb0d4', 'main', 0),
  ('12c3ece9-2de8-4b55-ae58-01962d64722e', '1899deb4-67a4-474b-b9b9-5038a784849e', '602d1cd8-f87e-4bdf-bcf7-86019f4eb0d4', 'main', 0),
  ('59a326c0-1f6e-414e-b490-b185014cf39a', 'bd8c8df2-e99a-4eed-9b65-048a01a5baf9', '602d1cd8-f87e-4bdf-bcf7-86019f4eb0d4', 'main', 0),
  ('654655de-b297-46f5-9daa-4e21891dc181', 'f23cd0aa-d7c0-4d75-afb3-f1848ad4b5b2', '602d1cd8-f87e-4bdf-bcf7-86019f4eb0d4', 'main', 0),
  ('c87176fb-dfc7-4953-b224-e09743e3ba9d', 'a2dba7a1-2b14-4a14-9e79-2aa033c5cc7b', '040e1d87-ef9a-463c-a746-5b6a0140c912', 'main', 0),
  ('7670228c-b306-4a3b-b2b9-bfef1b8f0c85', 'd56aa327-094e-43cf-9430-3bc20efaaee1', '040e1d87-ef9a-463c-a746-5b6a0140c912', 'main', 0),
  ('cbebe3d8-b8ad-418f-ad2f-52edd4732b38', 'aa5398e1-7917-4770-bd08-1b4503480d31', '040e1d87-ef9a-463c-a746-5b6a0140c912', 'main', 0),
  ('a7cb6b95-14e9-4117-a760-7b32cd4bccb3', '0a439be7-40fa-4d26-8c2b-2c324f4b5f44', '040e1d87-ef9a-463c-a746-5b6a0140c912', 'main', 0),
  ('f61bf81c-ab53-443e-8cb9-5db8b43edb2b', '09342748-02bf-4c98-94f3-660768f3bfbc', '040e1d87-ef9a-463c-a746-5b6a0140c912', 'main', 0),
  ('882865a3-d0c4-4cdd-ad7e-c2dd88c20bd4', 'b0fb0d52-b26a-42a1-b4a6-6610965994ca', '604fd2f8-04c7-4c3f-9864-7527e22580ab', 'main', 0),
  ('7b52c9cf-46e9-45b4-9657-81d818a276ea', '79f45f36-f5ee-48a0-b020-dfa2720270d1', '604fd2f8-04c7-4c3f-9864-7527e22580ab', 'main', 0),
  ('f3c8f7d4-90e2-4625-bcc0-a55af22dd951', 'bd2506e8-26aa-4f75-94f7-7d5f298da1a1', '860414cb-9d0b-4e0e-836b-542bdde341fe', 'main', 0),
  ('5d2e51d3-520c-4676-a814-cd529e1ad3b0', 'cbafab8b-47c5-4c28-8302-9a8bec5092b9', '602d1cd8-f87e-4bdf-bcf7-86019f4eb0d4', 'main', 0)
ON CONFLICT DO NOTHING;

-- album_artists
INSERT INTO album_artists (id, album_id, artist_id) VALUES
  ('705c2e32-bda1-43bd-b07a-c1dbf9952b44', 'b1111111-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111'),
  ('d48255ac-3fb8-4cd6-a8a2-19b80293baa5', '53cbb2f9-f2f4-46e5-ad09-2dd4e48884e5', 'a2222222-2222-2222-2222-222222222222'),
  ('c864f43f-6e45-403f-aa9e-3b932eaa29a8', '61ae6a4d-6657-4c25-bb6b-efb4399f8a67', 'a2222222-2222-2222-2222-222222222222'),
  ('46b8df8b-23c0-45cb-bbbd-075b57832318', 'd04c7738-c95a-439b-985b-18a3155e5027', '2a181377-7eb1-4a43-bc8c-a676b8aaca48'),
  ('20b69710-1541-4d5b-8274-c202235aeeed', 'd04c7738-c95a-439b-985b-18a3155e5027', '9121618a-9da5-4713-b130-fbd9a0bae4a3'),
  ('a93436e7-5515-48de-b719-f3c1f7f23866', 'ee050eeb-6475-4e4c-803a-f49312282f91', '9700cee4-270d-4bea-9dd2-3e97b142b89a'),
  ('28c319e7-078f-4ca4-a178-29d11ed8146c', 'd1000c1b-8ecf-4924-b5a1-94f8ae644ff2', '789e67f2-34c5-425b-8bc7-23ccbc6316d3'),
  ('bd64d5cb-1d93-4a28-8786-8a08309a8c31', 'd1000c1b-8ecf-4924-b5a1-94f8ae644ff2', 'a3333333-3333-3333-3333-333333333333'),
  ('9ea9915a-bbfd-4e6e-be35-3b67b49280b5', '5835eb3f-fe10-415d-a9f7-38a9a7c14784', '663b117b-a52f-4571-9efc-1a69729e6119'),
  ('51b6b9e8-a29b-4efa-93be-aa0043da841e', '5835eb3f-fe10-415d-a9f7-38a9a7c14784', '71afa9dd-3d6a-4cd0-8c74-f3e4002d2c99'),
  ('9b3b893e-37d7-44bc-8c99-526768e243fb', '5835eb3f-fe10-415d-a9f7-38a9a7c14784', '67694317-ee44-4b05-9a61-ea2e4c52ed9c'),
  ('635866ec-4505-4d99-aa57-4659f107564a', '3e07f537-6b54-4ee9-9534-e79ecb82b6bc', '2c47faab-e3ca-4ef7-aa89-57f1c0a095fe'),
  ('5536954e-49a9-4928-8e67-015ce56abd8a', '9e7233f9-2bba-47b8-8d5a-33ab4a8904c7', '9121618a-9da5-4713-b130-fbd9a0bae4a3'),
  ('b73e5203-5d1e-477a-bb7b-1c81de95ca0b', '8c7b674e-63e4-4fc1-a9ca-caba5c8af887', 'bfaff4c5-6251-4d3a-a33b-45b085d6a08a'),
  ('765c1680-7cac-402d-b38e-d6600d9f2651', 'dcb81438-1b12-43f3-b340-17950c8a78d5', '602d1cd8-f87e-4bdf-bcf7-86019f4eb0d4'),
  ('ddec4c6e-deea-4975-a32c-65cb0c3d8121', '09964f24-c5a5-4ad1-b3c3-071669f809e0', '040e1d87-ef9a-463c-a746-5b6a0140c912'),
  ('67ddeaea-92c9-4c65-9dac-e9813b16e75a', '1508ff05-6c8d-4a2e-919a-340b5c243766', '604fd2f8-04c7-4c3f-9864-7527e22580ab'),
  ('242004c8-8000-4497-ba88-327345a4c54f', '1508ff05-6c8d-4a2e-919a-340b5c243766', '860414cb-9d0b-4e0e-836b-542bdde341fe')
ON CONFLICT DO NOTHING;

-- album_songs
INSERT INTO album_songs (id, album_id, song_id, track_number) VALUES
  ('4a32c204-470c-4b98-b14e-fcc20fc06b40', '53cbb2f9-f2f4-46e5-ad09-2dd4e48884e5', 'c3333333-3333-3333-3333-333333333333', 1),
  ('8b09379a-62d9-4863-b1c8-4d17d5edf0e3', '61ae6a4d-6657-4c25-bb6b-efb4399f8a67', '34576c5b-a198-4dc3-8f15-e74f66b3c303', 1),
  ('0ece097a-0a35-4369-a453-35d765489a71', 'd04c7738-c95a-439b-985b-18a3155e5027', '5a817062-ce41-41ee-b2ea-c9d4a816dd05', 1),
  ('15a42abc-b429-4465-bd7d-b36de82104a1', 'b1111111-1111-1111-1111-111111111111', 'dfb0c4a0-d021-4286-b157-819177e2dd13', 1),
  ('ac03bb78-e45a-4af8-aa1f-d90412c43545', 'b1111111-1111-1111-1111-111111111111', '0cea8264-8f13-4973-b354-44e32948d338', 1),
  ('80f7d381-5c5d-4731-bde2-45f01a1900b3', 'b1111111-1111-1111-1111-111111111111', '9729b8a9-00c3-4bc4-840e-69781b96a160', 1),
  ('6ab1eda4-98b1-4533-bec7-068403458eda', 'b1111111-1111-1111-1111-111111111111', 'eb0828f7-7979-4518-bb3e-f83d1c000cda', 1),
  ('a183e85a-db94-405d-b157-9279fdb83996', 'ee050eeb-6475-4e4c-803a-f49312282f91', '4ae76cf9-cc59-4cc4-9398-32d7c6f21add', 1),
  ('e4c1507e-56b1-4f0b-9d8e-8be22e21e688', '3e07f537-6b54-4ee9-9534-e79ecb82b6bc', '53da82be-8e91-44a8-a21d-80a52e3a0ae1', 1),
  ('69e12763-7e9b-42b6-be48-b7df816d815e', '5835eb3f-fe10-415d-a9f7-38a9a7c14784', 'bb71b6a4-4039-4e2e-ae35-26d3a29da29e', 1),
  ('d6170e02-6ca5-41d6-a6ad-dcf147ad9e3a', '5835eb3f-fe10-415d-a9f7-38a9a7c14784', 'b49e3fa7-4993-4693-be76-1cb4c00c9d79', 1),
  ('b285c3be-996c-43c1-ab2d-b3013a0fbc15', '5835eb3f-fe10-415d-a9f7-38a9a7c14784', 'a7a66cf4-619d-4659-84db-f568a715fe30', 1),
  ('9144848d-94a5-40a1-a0d6-74c5016df0bc', '5835eb3f-fe10-415d-a9f7-38a9a7c14784', '42894706-bfb5-47b7-9f50-f03d190c82d5', 1),
  ('7ec4478c-c3f7-4ba0-a212-304ea25e6d47', 'd1000c1b-8ecf-4924-b5a1-94f8ae644ff2', 'af2cc869-07a3-4adc-9f1b-c9a04db91ffe', 1),
  ('b04b7fe2-8b86-4f3b-9725-7a24653d5200', '5835eb3f-fe10-415d-a9f7-38a9a7c14784', '34507f51-cb9b-4a4a-a568-bae3f6248a3d', 1),
  ('ae15b415-2b0d-41d1-8969-2bda2fda061b', '3e07f537-6b54-4ee9-9534-e79ecb82b6bc', '5dab6c55-9023-4fc0-ac3a-cb39b83460ed', 1),
  ('d006948a-c1a3-42c6-985c-61e4c0ea3456', '9e7233f9-2bba-47b8-8d5a-33ab4a8904c7', '98842d70-046c-4c9e-aa1d-f07f728b6142', 1),
  ('93bb8bc0-df2d-480e-b3bd-88bd285fa160', '8c7b674e-63e4-4fc1-a9ca-caba5c8af887', '4a9b4812-f97b-44df-b8ae-b7b8d10ed081', 1),
  ('122b5690-4265-475a-af5c-9b740700c06e', 'dcb81438-1b12-43f3-b340-17950c8a78d5', '1899deb4-67a4-474b-b9b9-5038a784849e', 1),
  ('e3f820bf-0662-4c0f-9a1e-8465e7bfd597', 'dcb81438-1b12-43f3-b340-17950c8a78d5', 'bd8c8df2-e99a-4eed-9b65-048a01a5baf9', 1),
  ('4cada8e1-63b4-4227-84d2-5c10fc9cccb7', 'dcb81438-1b12-43f3-b340-17950c8a78d5', 'f23cd0aa-d7c0-4d75-afb3-f1848ad4b5b2', 1),
  ('51c63ea4-71b4-4390-914c-670af02ec681', '09964f24-c5a5-4ad1-b3c3-071669f809e0', 'a2dba7a1-2b14-4a14-9e79-2aa033c5cc7b', 1),
  ('b926653e-75a2-4b32-97dc-402d6914168f', '09964f24-c5a5-4ad1-b3c3-071669f809e0', 'd56aa327-094e-43cf-9430-3bc20efaaee1', 1),
  ('eb9b1151-08ab-4bdb-ab83-2177127380a9', '09964f24-c5a5-4ad1-b3c3-071669f809e0', 'aa5398e1-7917-4770-bd08-1b4503480d31', 1),
  ('9bb143f6-8d3c-4c4e-9a77-f55db5031c33', '09964f24-c5a5-4ad1-b3c3-071669f809e0', '0a439be7-40fa-4d26-8c2b-2c324f4b5f44', 1),
  ('0b9c015f-f8cd-4dd9-bca6-295c3265f624', '09964f24-c5a5-4ad1-b3c3-071669f809e0', '09342748-02bf-4c98-94f3-660768f3bfbc', 1),
  ('ce3e7588-06f5-4daa-875b-bf34d57657e7', '1508ff05-6c8d-4a2e-919a-340b5c243766', 'b0fb0d52-b26a-42a1-b4a6-6610965994ca', 1),
  ('add5cb94-f365-495d-8df2-1e8dda76b940', '1508ff05-6c8d-4a2e-919a-340b5c243766', '79f45f36-f5ee-48a0-b020-dfa2720270d1', 1),
  ('77a9a37e-c241-4629-9960-34770180b378', '1508ff05-6c8d-4a2e-919a-340b5c243766', 'bd2506e8-26aa-4f75-94f7-7d5f298da1a1', 1),
  ('0f269063-14f7-4fa2-8f45-883aae293538', 'dcb81438-1b12-43f3-b340-17950c8a78d5', 'cbafab8b-47c5-4c28-8302-9a8bec5092b9', 1)
ON CONFLICT DO NOTHING;

-- song_genres
INSERT INTO song_genres (song_id, genre_id) VALUES
  ('c3333333-3333-3333-3333-333333333333', '235db38e-ec09-4709-8d3f-2a5d6359c664'),
  ('34576c5b-a198-4dc3-8f15-e74f66b3c303', '235db38e-ec09-4709-8d3f-2a5d6359c664'),
  ('34576c5b-a198-4dc3-8f15-e74f66b3c303', 'd96adfa2-87a9-43c6-a624-de5fc2572bdf'),
  ('5a817062-ce41-41ee-b2ea-c9d4a816dd05', '2bb3dcf4-7eae-424c-b064-c40ce864883d'),
  ('dfb0c4a0-d021-4286-b157-819177e2dd13', '235db38e-ec09-4709-8d3f-2a5d6359c664'),
  ('dfb0c4a0-d021-4286-b157-819177e2dd13', 'd6443d9c-d8e2-4538-87e0-d134f1d54ccf'),
  ('dfb0c4a0-d021-4286-b157-819177e2dd13', '2bb3dcf4-7eae-424c-b064-c40ce864883d'),
  ('0cea8264-8f13-4973-b354-44e32948d338', '235db38e-ec09-4709-8d3f-2a5d6359c664'),
  ('0cea8264-8f13-4973-b354-44e32948d338', 'd6443d9c-d8e2-4538-87e0-d134f1d54ccf'),
  ('9729b8a9-00c3-4bc4-840e-69781b96a160', '235db38e-ec09-4709-8d3f-2a5d6359c664'),
  ('9729b8a9-00c3-4bc4-840e-69781b96a160', 'd6443d9c-d8e2-4538-87e0-d134f1d54ccf'),
  ('eb0828f7-7979-4518-bb3e-f83d1c000cda', '235db38e-ec09-4709-8d3f-2a5d6359c664'),
  ('eb0828f7-7979-4518-bb3e-f83d1c000cda', 'd6443d9c-d8e2-4538-87e0-d134f1d54ccf'),
  ('eb0828f7-7979-4518-bb3e-f83d1c000cda', '2bb3dcf4-7eae-424c-b064-c40ce864883d'),
  ('4ae76cf9-cc59-4cc4-9398-32d7c6f21add', '2bb3dcf4-7eae-424c-b064-c40ce864883d'),
  ('4ae76cf9-cc59-4cc4-9398-32d7c6f21add', 'd6443d9c-d8e2-4538-87e0-d134f1d54ccf'),
  ('53da82be-8e91-44a8-a21d-80a52e3a0ae1', '2bb3dcf4-7eae-424c-b064-c40ce864883d'),
  ('53da82be-8e91-44a8-a21d-80a52e3a0ae1', 'd6443d9c-d8e2-4538-87e0-d134f1d54ccf'),
  ('e273a4ef-9589-4b62-a3ee-386319dfc06a', 'd6443d9c-d8e2-4538-87e0-d134f1d54ccf'),
  ('e273a4ef-9589-4b62-a3ee-386319dfc06a', '75770bb3-525e-4ac3-9a99-6069477091d5'),
  ('bb71b6a4-4039-4e2e-ae35-26d3a29da29e', '29ef6a59-9bba-49ce-9f9a-375988cfae46'),
  ('b49e3fa7-4993-4693-be76-1cb4c00c9d79', '29ef6a59-9bba-49ce-9f9a-375988cfae46'),
  ('a7a66cf4-619d-4659-84db-f568a715fe30', '29ef6a59-9bba-49ce-9f9a-375988cfae46'),
  ('42894706-bfb5-47b7-9f50-f03d190c82d5', 'd96adfa2-87a9-43c6-a624-de5fc2572bdf'),
  ('42894706-bfb5-47b7-9f50-f03d190c82d5', 'd6443d9c-d8e2-4538-87e0-d134f1d54ccf'),
  ('42894706-bfb5-47b7-9f50-f03d190c82d5', '29ef6a59-9bba-49ce-9f9a-375988cfae46'),
  ('af2cc869-07a3-4adc-9f1b-c9a04db91ffe', '2bb3dcf4-7eae-424c-b064-c40ce864883d'),
  ('af2cc869-07a3-4adc-9f1b-c9a04db91ffe', 'd96adfa2-87a9-43c6-a624-de5fc2572bdf'),
  ('34507f51-cb9b-4a4a-a568-bae3f6248a3d', '29ef6a59-9bba-49ce-9f9a-375988cfae46'),
  ('5dab6c55-9023-4fc0-ac3a-cb39b83460ed', '75770bb3-525e-4ac3-9a99-6069477091d5'),
  ('5dab6c55-9023-4fc0-ac3a-cb39b83460ed', 'd6443d9c-d8e2-4538-87e0-d134f1d54ccf'),
  ('98842d70-046c-4c9e-aa1d-f07f728b6142', '235db38e-ec09-4709-8d3f-2a5d6359c664'),
  ('98842d70-046c-4c9e-aa1d-f07f728b6142', 'd6443d9c-d8e2-4538-87e0-d134f1d54ccf'),
  ('4a9b4812-f97b-44df-b8ae-b7b8d10ed081', '235db38e-ec09-4709-8d3f-2a5d6359c664'),
  ('cba1fe39-a6cd-4e11-8de9-f6dd040c8525', '71aa4e7f-ec0e-4d75-b740-0c9efd958d31'),
  ('1899deb4-67a4-474b-b9b9-5038a784849e', '71aa4e7f-ec0e-4d75-b740-0c9efd958d31'),
  ('bd8c8df2-e99a-4eed-9b65-048a01a5baf9', '71aa4e7f-ec0e-4d75-b740-0c9efd958d31'),
  ('f23cd0aa-d7c0-4d75-afb3-f1848ad4b5b2', '71aa4e7f-ec0e-4d75-b740-0c9efd958d31'),
  ('a2dba7a1-2b14-4a14-9e79-2aa033c5cc7b', '71aa4e7f-ec0e-4d75-b740-0c9efd958d31'),
  ('d56aa327-094e-43cf-9430-3bc20efaaee1', '71aa4e7f-ec0e-4d75-b740-0c9efd958d31'),
  ('aa5398e1-7917-4770-bd08-1b4503480d31', '71aa4e7f-ec0e-4d75-b740-0c9efd958d31'),
  ('0a439be7-40fa-4d26-8c2b-2c324f4b5f44', '71aa4e7f-ec0e-4d75-b740-0c9efd958d31'),
  ('09342748-02bf-4c98-94f3-660768f3bfbc', '71aa4e7f-ec0e-4d75-b740-0c9efd958d31'),
  ('b0fb0d52-b26a-42a1-b4a6-6610965994ca', '71aa4e7f-ec0e-4d75-b740-0c9efd958d31'),
  ('79f45f36-f5ee-48a0-b020-dfa2720270d1', '71aa4e7f-ec0e-4d75-b740-0c9efd958d31'),
  ('bd2506e8-26aa-4f75-94f7-7d5f298da1a1', '71aa4e7f-ec0e-4d75-b740-0c9efd958d31'),
  ('cbafab8b-47c5-4c28-8302-9a8bec5092b9', '71aa4e7f-ec0e-4d75-b740-0c9efd958d31')
ON CONFLICT DO NOTHING;

-- playlist_songs
INSERT INTO playlist_songs (id, playlist_id, song_id, position, added_at) VALUES
  ('282c030c-b93b-44a8-b6c8-fddaa1f3ec38', '901f90ac-e5b7-4641-bd04-71b24f06641c', '42894706-bfb5-47b7-9f50-f03d190c82d5', 0, '2025-12-22T11:02:29.590892+00:00'),
  ('096860d8-f315-49a5-8d8c-2f37b363c714', '0c72b5b8-11cc-4ea6-be8a-e2e088130648', '09342748-02bf-4c98-94f3-660768f3bfbc', 0, '2025-12-22T18:49:35.612153+00:00'),
  ('9cf4edde-d746-4cc1-bdb1-f2063d25d272', '0c72b5b8-11cc-4ea6-be8a-e2e088130648', '0a439be7-40fa-4d26-8c2b-2c324f4b5f44', 1, '2025-12-22T18:49:42.568362+00:00'),
  ('76f25e93-7fb4-49f3-9b3e-705e1c06b22e', '0c72b5b8-11cc-4ea6-be8a-e2e088130648', '1899deb4-67a4-474b-b9b9-5038a784849e', 2, '2025-12-22T18:49:47.092495+00:00'),
  ('490bd67e-9848-4bb4-a0c2-3af0c76d0e69', '0c72b5b8-11cc-4ea6-be8a-e2e088130648', '79f45f36-f5ee-48a0-b020-dfa2720270d1', 3, '2025-12-22T18:49:50.754241+00:00'),
  ('3f62d7d7-ce39-4f88-82af-b7d86ee5583c', '0c72b5b8-11cc-4ea6-be8a-e2e088130648', 'a2dba7a1-2b14-4a14-9e79-2aa033c5cc7b', 4, '2025-12-22T18:49:54.535483+00:00'),
  ('45577578-4780-4885-a698-a270cdc3c713', '0c72b5b8-11cc-4ea6-be8a-e2e088130648', 'aa5398e1-7917-4770-bd08-1b4503480d31', 5, '2025-12-22T18:49:57.623018+00:00'),
  ('3d2a4788-417b-4388-8b3f-93f38ba66a1d', '0c72b5b8-11cc-4ea6-be8a-e2e088130648', 'b0fb0d52-b26a-42a1-b4a6-6610965994ca', 6, '2025-12-22T18:50:00.364119+00:00'),
  ('7c84d9e9-ab98-41be-8da6-0f05541c8e11', '0c72b5b8-11cc-4ea6-be8a-e2e088130648', 'bd2506e8-26aa-4f75-94f7-7d5f298da1a1', 7, '2025-12-22T18:50:03.958888+00:00'),
  ('e0289a8d-c44a-448a-930f-1d4f0aeacd57', '0c72b5b8-11cc-4ea6-be8a-e2e088130648', 'bd8c8df2-e99a-4eed-9b65-048a01a5baf9', 8, '2025-12-22T18:50:09.53954+00:00'),
  ('8c1c1199-47dc-46d5-b7ed-9e8dace618b0', '0c72b5b8-11cc-4ea6-be8a-e2e088130648', 'cba1fe39-a6cd-4e11-8de9-f6dd040c8525', 9, '2025-12-22T18:50:14.811136+00:00'),
  ('5fddf216-9024-4f0d-bdba-76f5999972bb', '0c72b5b8-11cc-4ea6-be8a-e2e088130648', 'cbafab8b-47c5-4c28-8302-9a8bec5092b9', 10, '2025-12-22T18:50:30.488499+00:00'),
  ('1d1ea815-c00b-4078-a814-1b09514dcaeb', '0c72b5b8-11cc-4ea6-be8a-e2e088130648', 'd56aa327-094e-43cf-9430-3bc20efaaee1', 11, '2025-12-22T18:50:34.534341+00:00'),
  ('ea874df0-ba6b-4efc-b793-0d16cde00d02', '0c72b5b8-11cc-4ea6-be8a-e2e088130648', 'f23cd0aa-d7c0-4d75-afb3-f1848ad4b5b2', 12, '2025-12-22T18:50:37.86405+00:00')
ON CONFLICT DO NOTHING;

-- user_liked_songs
INSERT INTO user_liked_songs (id, user_id, song_id, liked_at) VALUES
  ('105675b3-7591-441f-8050-f1153fa38b79', '851fceff-9adb-4de1-82b5-afda560baa03', '42894706-bfb5-47b7-9f50-f03d190c82d5', '2025-12-22T10:25:50.019169+00:00'),
  ('0d7cdda0-3bdf-4933-b08a-118710e4f877', '851fceff-9adb-4de1-82b5-afda560baa03', '5a817062-ce41-41ee-b2ea-c9d4a816dd05', '2025-12-22T10:28:14.789361+00:00'),
  ('e9cc43ee-6db8-4dce-936e-e6e941a4cbff', '851fceff-9adb-4de1-82b5-afda560baa03', '4ae76cf9-cc59-4cc4-9398-32d7c6f21add', '2025-12-22T10:33:07.071404+00:00'),
  ('81940e56-8cc9-4364-b0cd-dca7c3692555', '851fceff-9adb-4de1-82b5-afda560baa03', '34576c5b-a198-4dc3-8f15-e74f66b3c303', '2025-12-22T11:23:40.803764+00:00'),
  ('fe5fb83f-894f-4c19-8d8a-78998f271dac', '851fceff-9adb-4de1-82b5-afda560baa03', 'b49e3fa7-4993-4693-be76-1cb4c00c9d79', '2025-12-22T11:53:47.832204+00:00'),
  ('efdc6512-a56c-4377-ad45-a6a4db54cd05', '851fceff-9adb-4de1-82b5-afda560baa03', '4a9b4812-f97b-44df-b8ae-b7b8d10ed081', '2025-12-22T17:14:22.401186+00:00'),
  ('488076d0-18d3-485e-9861-604466980e2b', '851fceff-9adb-4de1-82b5-afda560baa03', 'f23cd0aa-d7c0-4d75-afb3-f1848ad4b5b2', '2025-12-22T18:51:04.842044+00:00'),
  ('fb0058eb-d212-41a0-8958-790f67a81531', '851fceff-9adb-4de1-82b5-afda560baa03', 'bd8c8df2-e99a-4eed-9b65-048a01a5baf9', '2025-12-23T13:57:05.745586+00:00')
ON CONFLICT DO NOTHING;

-- user_liked_albums
INSERT INTO user_liked_albums (id, user_id, album_id, liked_at) VALUES
  ('af720cf3-9dc8-4743-a760-b9b1da0d94c5', '851fceff-9adb-4de1-82b5-afda560baa03', '9e7233f9-2bba-47b8-8d5a-33ab4a8904c7', '2025-12-22T17:27:38.414945+00:00'),
  ('f01adb57-89d2-4183-82aa-e2d9f2c34dac', '851fceff-9adb-4de1-82b5-afda560baa03', 'ee050eeb-6475-4e4c-803a-f49312282f91', '2025-12-22T17:33:03.00904+00:00')
ON CONFLICT DO NOTHING;

-- user_follows
INSERT INTO user_follows (id, user_id, artist_id, followed_at) VALUES
  ('e8759828-eaf4-42e1-91d9-f2ab8e2092fa', '851fceff-9adb-4de1-82b5-afda560baa03', '663b117b-a52f-4571-9efc-1a69729e6119', '2025-12-21T21:42:17.656574+00:00'),
  ('6ff7cb2a-dfdd-4cad-8582-2d0726a37bef', '851fceff-9adb-4de1-82b5-afda560baa03', '9700cee4-270d-4bea-9dd2-3e97b142b89a', '2025-12-22T10:30:57.053994+00:00'),
  ('9384015a-1e70-4890-a4f7-5c7c53375e25', '851fceff-9adb-4de1-82b5-afda560baa03', 'a4444444-4444-4444-4444-444444444444', '2025-12-22T10:31:10.703885+00:00'),
  ('0865f61e-c1b0-47f5-b489-6839f28d85b9', '851fceff-9adb-4de1-82b5-afda560baa03', '9121618a-9da5-4713-b130-fbd9a0bae4a3', '2025-12-22T11:05:50.618512+00:00'),
  ('d5619bcf-ff1f-47a3-a9d0-002372c0c4ed', '49bd4e9a-20ab-4dcf-90a8-a4377f363b31', 'a1111111-1111-1111-1111-111111111111', '2025-12-22T11:40:07.454756+00:00'),
  ('3a556a2b-9485-40a6-b83a-fc6b14a155b2', '49bd4e9a-20ab-4dcf-90a8-a4377f363b31', '9121618a-9da5-4713-b130-fbd9a0bae4a3', '2025-12-22T11:40:13.568902+00:00'),
  ('08851c5a-7633-49b8-a4b8-e0715799a60c', '851fceff-9adb-4de1-82b5-afda560baa03', '040e1d87-ef9a-463c-a746-5b6a0140c912', '2025-12-22T18:51:40.902521+00:00')
ON CONFLICT DO NOTHING;

-- listening_history
INSERT INTO listening_history (id, user_id, song_id, listened_at, duration_played, completed) VALUES
  ('1e3d2624-cd30-43a0-a3fd-35f382e6c494', '851fceff-9adb-4de1-82b5-afda560baa03', 'e273a4ef-9589-4b62-a3ee-386319dfc06a', '2025-12-21T21:37:08.852392+00:00', 0, FALSE),
  ('354e972c-2986-457e-a33f-643c50cea075', '851fceff-9adb-4de1-82b5-afda560baa03', '42894706-bfb5-47b7-9f50-f03d190c82d5', '2025-12-21T21:37:53.275693+00:00', 0, FALSE),
  ('937429ef-cb3a-428a-b6a6-d6f04978ae04', '851fceff-9adb-4de1-82b5-afda560baa03', '42894706-bfb5-47b7-9f50-f03d190c82d5', '2025-12-21T21:40:17.059917+00:00', 0, FALSE),
  ('fa371fff-978a-49b0-a0ee-ecdabdb15809', '851fceff-9adb-4de1-82b5-afda560baa03', '34576c5b-a198-4dc3-8f15-e74f66b3c303', '2025-12-21T21:43:00.586989+00:00', 0, FALSE),
  ('6393b27d-887a-4c17-9bfd-16abe23e806b', '851fceff-9adb-4de1-82b5-afda560baa03', 'af2cc869-07a3-4adc-9f1b-c9a04db91ffe', '2025-12-21T21:48:02.89767+00:00', 0, FALSE),
  ('2dea6ef1-7cb4-411f-a77f-5171c564d479', '851fceff-9adb-4de1-82b5-afda560baa03', 'af2cc869-07a3-4adc-9f1b-c9a04db91ffe', '2025-12-22T10:07:17.296935+00:00', 0, FALSE),
  ('da890358-ddf1-4abb-9acd-971d8c1c1a28', '851fceff-9adb-4de1-82b5-afda560baa03', '34576c5b-a198-4dc3-8f15-e74f66b3c303', '2025-12-22T10:07:26.485974+00:00', 0, FALSE),
  ('652b391f-b065-47b5-8cc3-e301000841e8', '851fceff-9adb-4de1-82b5-afda560baa03', '42894706-bfb5-47b7-9f50-f03d190c82d5', '2025-12-22T10:07:32.076691+00:00', 0, FALSE),
  ('195d6ea9-0d0c-40fc-b69d-5da5f00633fd', '851fceff-9adb-4de1-82b5-afda560baa03', '5a817062-ce41-41ee-b2ea-c9d4a816dd05', '2025-12-22T10:28:14.174937+00:00', 0, FALSE),
  ('a39dc485-ff56-462c-b828-6503ba63d79b', '851fceff-9adb-4de1-82b5-afda560baa03', '4ae76cf9-cc59-4cc4-9398-32d7c6f21add', '2025-12-22T10:32:57.434279+00:00', 0, FALSE),
  ('212c7fcf-0de7-4bec-8e9a-8dc221590241', '851fceff-9adb-4de1-82b5-afda560baa03', '4ae76cf9-cc59-4cc4-9398-32d7c6f21add', '2025-12-19T21:21:25.81893+00:00', 186, TRUE),
  ('a9a9ac7a-3c66-4413-832c-004b1c86464c', '851fceff-9adb-4de1-82b5-afda560baa03', '5a817062-ce41-41ee-b2ea-c9d4a816dd05', '2025-12-19T21:17:25.81893+00:00', 207, TRUE),
  ('736cf403-a416-4bd5-84fb-fa7ff9447a22', '851fceff-9adb-4de1-82b5-afda560baa03', '42894706-bfb5-47b7-9f50-f03d190c82d5', '2025-12-19T20:56:25.81893+00:00', 201, TRUE),
  ('d4b38a60-bbb3-4893-b45c-0427a14711a0', '851fceff-9adb-4de1-82b5-afda560baa03', '34576c5b-a198-4dc3-8f15-e74f66b3c303', '2025-12-19T20:56:25.81893+00:00', 302, TRUE),
  ('6b410844-046d-47cf-9983-2020a9c57351', '851fceff-9adb-4de1-82b5-afda560baa03', 'af2cc869-07a3-4adc-9f1b-c9a04db91ffe', '2025-12-19T20:56:25.81893+00:00', 275, TRUE),
  ('f6aafc55-4a2e-4287-a400-4fa0e7eaea8c', '851fceff-9adb-4de1-82b5-afda560baa03', 'e273a4ef-9589-4b62-a3ee-386319dfc06a', '2025-12-13T01:19:25.81893+00:00', 283, TRUE),
  ('21641264-4e90-4022-851f-07643ceb5d18', '851fceff-9adb-4de1-82b5-afda560baa03', 'c3333333-3333-3333-3333-333333333333', '2025-12-13T01:04:25.81893+00:00', 279, TRUE),
  ('4c6f42c8-30b6-4c1a-960d-da9918c63eb8', '851fceff-9adb-4de1-82b5-afda560baa03', 'dfb0c4a0-d021-4286-b157-819177e2dd13', '2025-12-13T00:34:25.81893+00:00', 172, TRUE),
  ('ee23ec72-84f9-456b-98e8-4face0abeb0f', '851fceff-9adb-4de1-82b5-afda560baa03', '53da82be-8e91-44a8-a21d-80a52e3a0ae1', '2025-12-13T00:19:25.81893+00:00', 300, TRUE),
  ('1b7cffa3-9d1f-4c9e-b926-1e6a1af56adf', '851fceff-9adb-4de1-82b5-afda560baa03', '5dab6c55-9023-4fc0-ac3a-cb39b83460ed', '2025-12-12T23:49:25.81893+00:00', 328, TRUE),
  ('4e8085fa-077a-4659-b71a-48fa5449c561', '851fceff-9adb-4de1-82b5-afda560baa03', 'dfb0c4a0-d021-4286-b157-819177e2dd13', '2025-12-22T10:50:12.322699+00:00', 0, FALSE),
  ('76b250d4-8ffa-4f0a-a9e0-94d3f2cfb284', '851fceff-9adb-4de1-82b5-afda560baa03', 'b49e3fa7-4993-4693-be76-1cb4c00c9d79', '2025-12-22T10:59:23.640053+00:00', 0, FALSE),
  ('88d6a7d0-d2c7-4495-bb09-1e8f81f0dc5e', '851fceff-9adb-4de1-82b5-afda560baa03', 'bb71b6a4-4039-4e2e-ae35-26d3a29da29e', '2025-12-22T11:02:30.106909+00:00', 0, FALSE),
  ('0681e9d3-7247-4160-a50d-e690634beccc', '851fceff-9adb-4de1-82b5-afda560baa03', '42894706-bfb5-47b7-9f50-f03d190c82d5', '2025-12-22T11:03:18.489184+00:00', 0, FALSE),
  ('f502209b-6766-46c6-9338-5141f20e665a', '851fceff-9adb-4de1-82b5-afda560baa03', 'b49e3fa7-4993-4693-be76-1cb4c00c9d79', '2025-12-22T11:09:08.697582+00:00', 0, FALSE),
  ('ef7e7437-95e9-42ad-896b-c2d7b131047f', '851fceff-9adb-4de1-82b5-afda560baa03', 'b49e3fa7-4993-4693-be76-1cb4c00c9d79', '2025-12-22T11:13:57.783743+00:00', 0, FALSE),
  ('e4c4a39b-d591-47be-9bf0-bcb47e0b39f2', '851fceff-9adb-4de1-82b5-afda560baa03', '5a817062-ce41-41ee-b2ea-c9d4a816dd05', '2025-12-22T11:17:12.012888+00:00', 0, FALSE),
  ('7038b5a3-e017-4cfa-9408-22f364e5a288', '851fceff-9adb-4de1-82b5-afda560baa03', '42894706-bfb5-47b7-9f50-f03d190c82d5', '2025-12-22T11:17:49.538286+00:00', 0, FALSE),
  ('d0df1f6e-1d4c-41a4-8f6f-834960dfbee4', '851fceff-9adb-4de1-82b5-afda560baa03', 'b49e3fa7-4993-4693-be76-1cb4c00c9d79', '2025-12-22T11:17:52.190863+00:00', 0, FALSE),
  ('d7428bcf-7498-4315-87ca-9dc864a94e99', '851fceff-9adb-4de1-82b5-afda560baa03', 'eb0828f7-7979-4518-bb3e-f83d1c000cda', '2025-12-22T11:20:29.682951+00:00', 0, FALSE),
  ('e5553e05-6649-48a0-ba15-fc95f9b6fb88', '851fceff-9adb-4de1-82b5-afda560baa03', '34576c5b-a198-4dc3-8f15-e74f66b3c303', '2025-12-22T11:21:04.027169+00:00', 0, FALSE),
  ('0063e1ca-b119-48ed-b0ec-cfbfebb13c52', '851fceff-9adb-4de1-82b5-afda560baa03', 'b49e3fa7-4993-4693-be76-1cb4c00c9d79', '2025-12-22T11:26:48.72463+00:00', 0, FALSE),
  ('541773c4-27e8-4986-9098-f0fecfbad40d', '851fceff-9adb-4de1-82b5-afda560baa03', '4ae76cf9-cc59-4cc4-9398-32d7c6f21add', '2025-12-22T11:28:42.202214+00:00', 0, FALSE),
  ('74ba79db-d34f-45c9-a98a-681d335d9ca6', '851fceff-9adb-4de1-82b5-afda560baa03', '5a817062-ce41-41ee-b2ea-c9d4a816dd05', '2025-12-22T11:31:40.499425+00:00', 0, FALSE),
  ('2af565c1-c914-4b0e-80ac-88e54cf84993', '851fceff-9adb-4de1-82b5-afda560baa03', 'af2cc869-07a3-4adc-9f1b-c9a04db91ffe', '2025-12-22T11:34:43.140632+00:00', 0, FALSE),
  ('e58f0f3e-b3f0-4603-9c49-a1dc867f2e70', '851fceff-9adb-4de1-82b5-afda560baa03', 'b49e3fa7-4993-4693-be76-1cb4c00c9d79', '2025-12-22T11:48:33.523305+00:00', 0, FALSE),
  ('a41bba02-6f6b-412d-8159-1edee2644c2f', '851fceff-9adb-4de1-82b5-afda560baa03', 'b49e3fa7-4993-4693-be76-1cb4c00c9d79', '2025-12-22T11:54:09.821942+00:00', 0, FALSE),
  ('8425cf51-c2a2-47a8-9849-b1bc12be76e4', '851fceff-9adb-4de1-82b5-afda560baa03', '4a9b4812-f97b-44df-b8ae-b7b8d10ed081', '2025-12-22T17:11:53.342918+00:00', 0, FALSE),
  ('aedaf455-47b2-4fbd-8c8b-6b5895a39f5f', '851fceff-9adb-4de1-82b5-afda560baa03', 'a7a66cf4-619d-4659-84db-f568a715fe30', '2025-12-22T17:20:45.398856+00:00', 0, FALSE),
  ('6bda693c-9798-4a1d-a54b-7e619d88cb5d', '851fceff-9adb-4de1-82b5-afda560baa03', '4a9b4812-f97b-44df-b8ae-b7b8d10ed081', '2025-12-22T17:23:35.026172+00:00', 0, FALSE),
  ('f07229fb-6cf4-4e79-9e6e-ad9e792c2b8d', '851fceff-9adb-4de1-82b5-afda560baa03', '4a9b4812-f97b-44df-b8ae-b7b8d10ed081', '2025-12-22T17:53:50.21954+00:00', 0, FALSE),
  ('efa5cff9-9f41-405a-b223-21cd5f57581a', '851fceff-9adb-4de1-82b5-afda560baa03', 'cbafab8b-47c5-4c28-8302-9a8bec5092b9', '2025-12-22T18:50:18.839547+00:00', 0, FALSE),
  ('34be2d9c-8732-4882-8e5d-cb6380c02eb8', '851fceff-9adb-4de1-82b5-afda560baa03', 'f23cd0aa-d7c0-4d75-afb3-f1848ad4b5b2', '2025-12-22T18:50:55.801334+00:00', 0, FALSE),
  ('1fb73cfb-5143-4513-b647-14d9032f1ef8', '851fceff-9adb-4de1-82b5-afda560baa03', 'aa5398e1-7917-4770-bd08-1b4503480d31', '2025-12-22T18:54:32.93963+00:00', 0, FALSE),
  ('87097539-bddc-4e8e-9298-be6a403bce64', '851fceff-9adb-4de1-82b5-afda560baa03', 'b0fb0d52-b26a-42a1-b4a6-6610965994ca', '2025-12-22T18:58:56.803342+00:00', 0, FALSE),
  ('6f5b3a2c-2056-4bc1-ba63-d387c31ae34f', '851fceff-9adb-4de1-82b5-afda560baa03', 'cba1fe39-a6cd-4e11-8de9-f6dd040c8525', '2025-12-22T19:01:13.202107+00:00', 0, FALSE),
  ('d6c2621c-fbab-43da-a7d8-68bab1adbb0c', '851fceff-9adb-4de1-82b5-afda560baa03', 'bd2506e8-26aa-4f75-94f7-7d5f298da1a1', '2025-12-22T19:04:39.281387+00:00', 0, FALSE),
  ('9ea9502b-33ca-42eb-b7a2-5d71a27674b6', '851fceff-9adb-4de1-82b5-afda560baa03', '79f45f36-f5ee-48a0-b020-dfa2720270d1', '2025-12-22T19:07:07.971007+00:00', 0, FALSE),
  ('de6c7262-ce29-4384-ad2b-aabea14c731e', '851fceff-9adb-4de1-82b5-afda560baa03', '0a439be7-40fa-4d26-8c2b-2c324f4b5f44', '2025-12-22T19:10:28.58187+00:00', 0, FALSE),
  ('1b84fd42-1f03-46f5-a64f-6f8940a685e3', '851fceff-9adb-4de1-82b5-afda560baa03', '09342748-02bf-4c98-94f3-660768f3bfbc', '2025-12-22T19:13:51.138439+00:00', 0, FALSE),
  ('9fe71b62-d508-4454-8be5-3e257521d42f', '851fceff-9adb-4de1-82b5-afda560baa03', '1899deb4-67a4-474b-b9b9-5038a784849e', '2025-12-22T19:14:05.70213+00:00', 0, FALSE),
  ('780ddfc4-e795-4d9d-a32d-fc8f12dd80f4', '851fceff-9adb-4de1-82b5-afda560baa03', 'f23cd0aa-d7c0-4d75-afb3-f1848ad4b5b2', '2025-12-22T19:15:35.038791+00:00', 0, FALSE),
  ('07c5a673-d7f9-461f-8113-1ecfa289f66c', '851fceff-9adb-4de1-82b5-afda560baa03', '09342748-02bf-4c98-94f3-660768f3bfbc', '2025-12-22T19:15:42.049233+00:00', 0, FALSE),
  ('e8d0d317-1270-4305-b201-b1c4fb6a0826', '851fceff-9adb-4de1-82b5-afda560baa03', 'cba1fe39-a6cd-4e11-8de9-f6dd040c8525', '2025-12-22T19:15:48.109044+00:00', 0, FALSE),
  ('831235c5-4f4b-48c1-9010-226ffed3da53', '851fceff-9adb-4de1-82b5-afda560baa03', '0a439be7-40fa-4d26-8c2b-2c324f4b5f44', '2025-12-22T19:15:57.783318+00:00', 0, FALSE),
  ('e724006c-adb0-4934-8c60-bd001e492df9', '851fceff-9adb-4de1-82b5-afda560baa03', 'cba1fe39-a6cd-4e11-8de9-f6dd040c8525', '2025-12-22T19:16:04.033005+00:00', 0, FALSE),
  ('4ed59591-6247-4af5-967e-94858051a72e', '851fceff-9adb-4de1-82b5-afda560baa03', 'a2dba7a1-2b14-4a14-9e79-2aa033c5cc7b', '2025-12-22T19:16:11.113994+00:00', 0, FALSE),
  ('008d1447-2b87-4384-a829-34f17b84dc33', '851fceff-9adb-4de1-82b5-afda560baa03', '0a439be7-40fa-4d26-8c2b-2c324f4b5f44', '2025-12-22T19:19:45.302544+00:00', 0, FALSE),
  ('b5e8aa18-1dc1-4091-9f12-691bc7f1a1b7', '851fceff-9adb-4de1-82b5-afda560baa03', 'd56aa327-094e-43cf-9430-3bc20efaaee1', '2025-12-22T19:23:08.043066+00:00', 0, FALSE),
  ('1ecd61fe-ea84-4f4b-bde9-4100f65afa4a', '851fceff-9adb-4de1-82b5-afda560baa03', '1899deb4-67a4-474b-b9b9-5038a784849e', '2025-12-22T19:26:07.826837+00:00', 0, FALSE),
  ('83d754d6-9498-4276-b3eb-c509dc58020a', '851fceff-9adb-4de1-82b5-afda560baa03', 'bd2506e8-26aa-4f75-94f7-7d5f298da1a1', '2025-12-22T19:30:02.727709+00:00', 0, FALSE),
  ('2a1ca313-7223-4423-a4ff-e45b07992c4f', '851fceff-9adb-4de1-82b5-afda560baa03', '79f45f36-f5ee-48a0-b020-dfa2720270d1', '2025-12-22T19:32:29.989387+00:00', 0, FALSE),
  ('dea12964-38f8-4498-89f2-210efd4858dc', '851fceff-9adb-4de1-82b5-afda560baa03', 'aa5398e1-7917-4770-bd08-1b4503480d31', '2025-12-22T19:35:51.552264+00:00', 0, FALSE),
  ('d27d6b62-351a-4e1f-95e0-6859f4e08953', '851fceff-9adb-4de1-82b5-afda560baa03', '4a9b4812-f97b-44df-b8ae-b7b8d10ed081', '2025-12-23T13:54:09.025227+00:00', 0, FALSE),
  ('3a70a0ab-3834-4b17-b9c7-9522ac3c16f1', '851fceff-9adb-4de1-82b5-afda560baa03', '1899deb4-67a4-474b-b9b9-5038a784849e', '2025-12-23T13:54:24.747543+00:00', 0, FALSE),
  ('97215e0a-5383-4f28-b0f9-72ef66ca62e3', '851fceff-9adb-4de1-82b5-afda560baa03', '09342748-02bf-4c98-94f3-660768f3bfbc', '2025-12-23T13:56:13.453491+00:00', 0, FALSE),
  ('a79b7a13-6449-4a9c-a673-d630bb84413e', '851fceff-9adb-4de1-82b5-afda560baa03', 'bd8c8df2-e99a-4eed-9b65-048a01a5baf9', '2025-12-23T13:56:36.513495+00:00', 0, FALSE),
  ('b41aaaa7-852f-4478-965d-2e03b0ee9f57', '851fceff-9adb-4de1-82b5-afda560baa03', 'b49e3fa7-4993-4693-be76-1cb4c00c9d79', '2025-12-23T13:58:12.924316+00:00', 0, FALSE),
  ('a501f5a2-5ccf-4488-9652-aff480386f3a', '851fceff-9adb-4de1-82b5-afda560baa03', '5dab6c55-9023-4fc0-ac3a-cb39b83460ed', '2025-12-23T14:02:14.855611+00:00', 0, FALSE),
  ('1d6034f7-6369-4cf5-a532-2b8588380334', '851fceff-9adb-4de1-82b5-afda560baa03', '42894706-bfb5-47b7-9f50-f03d190c82d5', '2025-12-23T14:09:27.566897+00:00', 0, FALSE),
  ('2ff2920b-643f-45d9-bdef-1fb52791df35', '851fceff-9adb-4de1-82b5-afda560baa03', 'b49e3fa7-4993-4693-be76-1cb4c00c9d79', '2025-12-23T14:12:46.986359+00:00', 0, FALSE),
  ('6418ce95-d757-4e6e-8f9d-0e91dbf47464', '851fceff-9adb-4de1-82b5-afda560baa03', 'cbafab8b-47c5-4c28-8302-9a8bec5092b9', '2025-12-23T15:28:51.112702+00:00', 0, FALSE),
  ('bf36d0e0-b673-4132-93b5-812b49ccd840', '851fceff-9adb-4de1-82b5-afda560baa03', 'dfb0c4a0-d021-4286-b157-819177e2dd13', '2025-12-23T15:29:45.021381+00:00', 0, FALSE),
  ('58fa9233-875b-4d88-a0e9-72f755a532b4', '851fceff-9adb-4de1-82b5-afda560baa03', '42894706-bfb5-47b7-9f50-f03d190c82d5', '2025-12-23T16:10:38.442472+00:00', 0, FALSE),
  ('2a87ad7e-e388-44b6-87a9-f62d0ca301e5', '851fceff-9adb-4de1-82b5-afda560baa03', '34507f51-cb9b-4a4a-a568-bae3f6248a3d', '2025-12-23T16:10:52.985509+00:00', 0, FALSE),
  ('79ee23bc-3505-4cd8-85bc-5bc4ff5408a2', '851fceff-9adb-4de1-82b5-afda560baa03', '4a9b4812-f97b-44df-b8ae-b7b8d10ed081', '2025-12-23T16:11:16.531947+00:00', 0, FALSE),
  ('467a3923-ca90-4b99-937d-3d293c16f454', '851fceff-9adb-4de1-82b5-afda560baa03', '34507f51-cb9b-4a4a-a568-bae3f6248a3d', '2025-12-23T16:16:24.375538+00:00', 0, FALSE),
  ('6692a457-3be7-49ad-85b2-58c5e3fa568c', '851fceff-9adb-4de1-82b5-afda560baa03', '4a9b4812-f97b-44df-b8ae-b7b8d10ed081', '2025-12-23T16:16:42.032016+00:00', 0, FALSE),
  ('e056556a-903d-4540-b939-9700c4513436', '851fceff-9adb-4de1-82b5-afda560baa03', 'bd2506e8-26aa-4f75-94f7-7d5f298da1a1', '2025-12-23T16:16:49.663765+00:00', 0, FALSE),
  ('b858e085-4bcc-47cb-8556-1c301c62e4ae', '851fceff-9adb-4de1-82b5-afda560baa03', 'bd2506e8-26aa-4f75-94f7-7d5f298da1a1', '2025-12-23T16:18:31.565432+00:00', 0, FALSE),
  ('25d62505-bd94-4cae-a651-b6b1f11580d0', '851fceff-9adb-4de1-82b5-afda560baa03', '34507f51-cb9b-4a4a-a568-bae3f6248a3d', '2025-12-23T16:20:05.886945+00:00', 0, FALSE),
  ('66a428e8-229c-435d-b827-31c1af0360c5', '851fceff-9adb-4de1-82b5-afda560baa03', 'bd2506e8-26aa-4f75-94f7-7d5f298da1a1', '2025-12-23T16:20:13.52069+00:00', 0, FALSE),
  ('ba890c23-7e9b-4c8a-b7a1-e701fb514925', '851fceff-9adb-4de1-82b5-afda560baa03', '34507f51-cb9b-4a4a-a568-bae3f6248a3d', '2025-12-23T16:27:08.278392+00:00', 0, FALSE),
  ('11b0163f-03da-452b-9a7e-9e34f992a777', '851fceff-9adb-4de1-82b5-afda560baa03', 'bd2506e8-26aa-4f75-94f7-7d5f298da1a1', '2025-12-23T16:28:00.701362+00:00', 0, FALSE),
  ('83467434-876e-4632-8b8c-53e6119ba8d5', '851fceff-9adb-4de1-82b5-afda560baa03', '42894706-bfb5-47b7-9f50-f03d190c82d5', '2025-12-23T16:29:47.946948+00:00', 0, FALSE),
  ('a2d10bd9-337b-402f-b74e-b053fc75bf13', '851fceff-9adb-4de1-82b5-afda560baa03', 'dfb0c4a0-d021-4286-b157-819177e2dd13', '2025-12-23T16:33:09.430112+00:00', 0, FALSE),
  ('eaeb0a2a-d1ab-4256-95cf-0126ce03063c', '851fceff-9adb-4de1-82b5-afda560baa03', '42894706-bfb5-47b7-9f50-f03d190c82d5', '2025-12-23T16:44:34.576565+00:00', 0, FALSE),
  ('f9034a4d-4017-41c1-887d-744efe9e3072', '851fceff-9adb-4de1-82b5-afda560baa03', 'bd2506e8-26aa-4f75-94f7-7d5f298da1a1', '2025-12-23T16:47:56.221897+00:00', 0, FALSE),
  ('d19a58ce-2028-4aa3-b3f1-032715d1ece8', '851fceff-9adb-4de1-82b5-afda560baa03', '34507f51-cb9b-4a4a-a568-bae3f6248a3d', '2025-12-23T16:50:25.478839+00:00', 0, FALSE),
  ('3dc04e62-b016-492d-9e1a-62d384b1680b', '851fceff-9adb-4de1-82b5-afda560baa03', '42894706-bfb5-47b7-9f50-f03d190c82d5', '2025-12-23T16:50:28.807071+00:00', 0, FALSE),
  ('07eadb31-56e1-48b9-98b7-e7caaeb5eafe', '851fceff-9adb-4de1-82b5-afda560baa03', 'dfb0c4a0-d021-4286-b157-819177e2dd13', '2025-12-23T16:53:50.823447+00:00', 0, FALSE)
ON CONFLICT DO NOTHING;


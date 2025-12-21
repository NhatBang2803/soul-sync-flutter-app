-- =====================================================
-- Soul Sync Database - FILE 4: BACKUP DATA
-- Mục đích: Seed data / Restore data
-- Thứ tự chạy: 4 (sau file1.sql và file2.sql)
-- QUAN TRỌNG: Chạy SAU khi đã tạo schema (file1.sql)
-- Generated at: 2025-12-21T15:25:53.350Z
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
INSERT INTO users (id, email, username, display_name, auth_method, created_at, updated_at) VALUES
  ('49bd4e9a-20ab-4dcf-90a8-a4377f363b31', 'user1@example.com', 'user1', 'User 1', 'local', NOW(), NOW()),
  ('f4e7da34-c783-40a0-b07e-06a3b346ffca', 'user2@example.com', 'user2', 'User 2', 'local', NOW(), NOW())
ON CONFLICT DO NOTHING;

-- artists
INSERT INTO artists (id, name, image_url, followers, monthly_listeners, is_verified, bio, created_at, updated_at) VALUES
  ('e06ae9ac-0929-404f-b540-fc2ebb2f9001', 'JSol', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766242555/dkjlfrmzd7nxdsm4c9fa.webp', 213402, 91231, TRUE, '', '2025-12-20T14:56:08.358652+00:00', '2025-12-20T14:56:08.358652+00:00'),
  ('2c47faab-e3ca-4ef7-aa89-57f1c0a095fe', 'Chillies', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766254322/teri0wheklrrhwsfpy05.jpg', 1231230, 12312310, TRUE, '', '2025-12-20T18:12:06.4382+00:00', '2025-12-20T18:12:06.4382+00:00'),
  ('a1111111-1111-1111-1111-111111111111', 'HIEUTHUHAI', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766260956/a8xzrfiyrr9pgnbussru.jpg', 2400000, 1800000, TRUE, '', '2025-12-20T13:41:44.229183+00:00', '2025-12-20T13:41:44.229183+00:00'),
  ('a5555555-5555-5555-5555-555555555555', 'Hoàng Thùy Linh', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766260973/tj8mnxit90ljq1doe3eu.jpg', 1800000, 950000, TRUE, '', '2025-12-20T13:41:44.229183+00:00', '2025-12-20T13:41:44.229183+00:00'),
  ('a2222222-2222-2222-2222-222222222222', 'Sơn Tùng M-TP', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261011/tirllf2ecbigl7pxgga5.jpg', 5500000, 3200000, TRUE, '', '2025-12-20T13:41:44.229183+00:00', '2025-12-20T13:41:44.229183+00:00'),
  ('a4444444-4444-4444-4444-444444444444', 'Đen Vâu', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261030/altcyftpqedn0qalzkxq.jpg', 3200000, 2100000, TRUE, '', '2025-12-20T13:41:44.229183+00:00', '2025-12-20T13:41:44.229183+00:00'),
  ('9121618a-9da5-4713-b130-fbd9a0bae4a3', 'Bray', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261048/rjwtiakhpcvfg0pjwtxk.jpg', 1230412, 12310122, TRUE, '', '2025-12-20T20:04:23.091332+00:00', '2025-12-20T20:04:23.091332+00:00'),
  ('663b117b-a52f-4571-9efc-1a69729e6119', 'Low G', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261105/nbhgdsqewyhrxsvhx4s6.jpg', 12301123, 12306341, TRUE, '', '2025-12-20T20:05:16.507647+00:00', '2025-12-20T20:05:16.507647+00:00'),
  ('2a181377-7eb1-4a43-bc8c-a676b8aaca48', 'Amee', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261147/zbdrniwd5igzwtproqmg.jpg', 32101, 461021, TRUE, '', '2025-12-20T20:05:59.793755+00:00', '2025-12-20T20:05:59.793755+00:00'),
  ('a3333333-3333-3333-3333-333333333333', 'Phương Mỹ Chi', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766314699/ryzlctuznhvnd61dbxuc.jpg', 1200000, 800000, TRUE, '', '2025-12-20T13:41:44.229183+00:00', '2025-12-20T13:41:44.229183+00:00'),
  ('9700cee4-270d-4bea-9dd2-3e97b142b89a', 'Quang Hùng Master D', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766314978/eksnexpnovdtrfikaume.jpg', 123981123, 123456789, TRUE, '', '2025-12-20T14:32:05.475267+00:00', '2025-12-20T14:32:05.475267+00:00'),
  ('789e67f2-34c5-425b-8bc7-23ccbc6316d3', 'DTAP', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766316254/aspqt3gsuyywzxpi6p9m.jpg', 2123049, 8126140, TRUE, '', '2025-12-21T11:24:18.523179+00:00', '2025-12-21T11:24:18.523179+00:00'),
  ('67694317-ee44-4b05-9a61-ea2e4c52ed9c', 'JustaTee', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766317661/j7hb3vyhimhezl6cdxuc.jpg', 3286310, 9712360, TRUE, '', '2025-12-21T11:47:53.590054+00:00', '2025-12-21T11:47:53.590054+00:00'),
  ('71afa9dd-3d6a-4cd0-8c74-f3e4002d2c99', 'TLinh', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766317746/jxxbslrhv2ujhb2fk0ms.jpg', 9179080, 4521901, TRUE, '', '2025-12-21T11:49:24.709751+00:00', '2025-12-21T11:49:24.709751+00:00')
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
  ('d96adfa2-87a9-43c6-a624-de5fc2572bdf', 'classical', 'Classical', '#0EA5E9', '2025-12-20T13:41:44.229183+00:00')
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
  ('9e7233f9-2bba-47b8-8d5a-33ab4a8904c7', 'Cho Bảo', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766315077/bty4dd2j82xv9857ovuq.jpg', 2025, 1, 0, TRUE, '2025-12-21T11:04:40.780812+00:00', '2025-12-21T11:04:40.780812+00:00')
ON CONFLICT DO NOTHING;

-- songs
INSERT INTO songs (id, title, duration, audio_url, cover_url, play_count, created_at) VALUES
  ('e273a4ef-9589-4b62-a3ee-386319dfc06a', 'Em Đừng Khóc', 283, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766254519/ukxfrmros0cxilpfgrbi.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766254556/ewrvl3ptebi4pxqvjnir.webp', 1270453, '2025-12-20T18:16:17.901016+00:00'),
  ('c3333333-3333-3333-3333-333333333333', 'Đừng Làm Trái Tim Anh Đau', 279, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261228/e9tbwdfunsjjmonk6xun.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261255/lx7ltctesij4dswxf50r.jpg', 864112006, '2025-10-21T13:41:44.229183+00:00'),
  ('34576c5b-a198-4dc3-8f15-e74f66b3c303', 'Chúng Ta Của Hiện Tại', 302, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261276/knao56rjmzcwzxd3ltpq.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261277/wd3vwvtidbtqtyr56tsy.jpg', 583470813, '2025-12-20T20:08:47.011606+00:00'),
  ('5a817062-ce41-41ee-b2ea-c9d4a816dd05', 'Do For Love', 207, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261361/lqvokjo7liio3eosagmr.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261383/qgeld8jsugpfbnlrdver.jpg', 23480332, '2025-12-20T20:09:51.101515+00:00'),
  ('dfb0c4a0-d021-4286-b157-819177e2dd13', 'NO LOVE NO LIFE', 172, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261690/hcm98wcuv2qlckzw3wzh.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261716/x7qf54zqjrod8yhvsap1.jpg', 98671230, '2025-12-20T20:15:21.611044+00:00'),
  ('0cea8264-8f13-4973-b354-44e32948d338', 'Cho em an toàn', 232, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261556/xabc29mpjhz0sjxy9bwb.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261567/ixa8atsz2wgt1dbh8o2b.jpg', 37566040, '2025-12-20T20:13:06.609057+00:00'),
  ('9729b8a9-00c3-4bc4-840e-69781b96a160', 'Exit Sign', 202, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261646/shhzzmjprfrdt645bfp0.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261667/exxur4ryv9twyfmbotu1.jpg', 9283130, '2025-12-20T20:14:32.903381+00:00'),
  ('eb0828f7-7979-4518-bb3e-f83d1c000cda', 'Không thể say', 261, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261498/ekmlkoptnlrtxmilqjwj.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261505/gi7qdcm3ayztrxn0t8fc.jpg', 58149130, '2025-12-20T20:11:50.018868+00:00'),
  ('4ae76cf9-cc59-4cc4-9398-32d7c6f21add', 'Thủy triều', 186, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766241199/eflddfiibsqtuauvbjnr.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766315008/f27qm48k5vb6azjahr7u.jpg', 29183123, '2025-12-20T14:32:39.370734+00:00'),
  ('53da82be-8e91-44a8-a21d-80a52e3a0ae1', 'Mascara', 300, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766315613/ncpeukcael3uvr1t6d5g.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766315666/yprdq6fwhnoure7ghszx.jpg', 1208317, '2025-12-21T11:14:35.445328+00:00'),
  ('bb71b6a4-4039-4e2e-ae35-26d3a29da29e', 'Siêu Sao', 172, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766317871/auinmidd83227h6rdl0v.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766317864/znimocaihud8cq3jfafv.jpg', 10891230, '2025-12-21T11:51:32.814471+00:00'),
  ('b49e3fa7-4993-4693-be76-1cb4c00c9d79', 'Nhiều Hơn', 186, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766317927/wv8xziurezwoniyvuicr.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766317926/gvyffaer9tnkam2zergq.jpg', 1978120, '2025-12-21T11:52:15.488457+00:00'),
  ('a7a66cf4-619d-4659-84db-f568a715fe30', 'LOVE GAME', 200, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766317972/ffnalurwhnp8hkoad6g7.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766317973/tryq4w49ib6ktg6ppwmk.jpg', 51123012, '2025-12-21T11:53:03.507143+00:00'),
  ('42894706-bfb5-47b7-9f50-f03d190c82d5', 'IN LOVE', 201, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766318038/r09fg2uwuvgyqv54cney.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766318060/lqiiwvavoqnxj35n1xeg.jpg', 90213012, '2025-12-21T11:54:31.415717+00:00'),
  ('af2cc869-07a3-4adc-9f1b-c9a04db91ffe', 'Bóng Phù Hoa', 275, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766316315/iyx3yzshusswmty6focc.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766316512/eem3lk9xzffetcnx2pvh.jpg', 498123201, '2025-12-21T11:28:46.906455+00:00'),
  ('34507f51-cb9b-4a4a-a568-bae3f6248a3d', 'Đừng Để Tiền Rời', 179, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766318089/vp3xmddngmlfn1yqmpk9.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766318116/w90ryy5bbsqk5tw506jp.jpg', 1290890, '2025-12-21T11:55:27.05361+00:00'),
  ('5dab6c55-9023-4fc0-ac3a-cb39b83460ed', 'Vùng Ký Ức', 328, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766315477/hlcwqhgbg2do6xeteau4.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766315540/ioshsirnz19zwdzq0lsy.jpg', 69521012, '2025-12-21T11:12:29.568158+00:00'),
  ('98842d70-046c-4c9e-aa1d-f07f728b6142', 'Vùng An Toàn', 266, 'https://res.cloudinary.com/dyyefsed9/video/upload/v1766261429/zfzy3oagf3e3lklisqll.mp3', 'https://res.cloudinary.com/dyyefsed9/image/upload/v1766261447/h1gbu8wznvxwc3tap9ps.jpg', 234810, '2025-12-20T20:10:53.218462+00:00')
ON CONFLICT DO NOTHING;

-- playlists
INSERT INTO playlists (id, owner_id, name, description, cover_url, is_public, song_count, listen_count, created_at, updated_at) VALUES
  ('5ea99301-48c6-4a66-8a89-0824e1633c9b', '49bd4e9a-20ab-4dcf-90a8-a4377f363b31', 'vibe coding', NULL, NULL, TRUE, 4, 0, '2025-12-20T14:15:29.431844+00:00', '2025-12-20T14:15:29.431844+00:00'),
  ('c0f61d28-e4ff-4995-a7a8-8e16b00c779b', 'f4e7da34-c783-40a0-b07e-06a3b346ffca', 'Study with me', NULL, NULL, FALSE, 2, 0, '2025-12-20T18:22:03.265575+00:00', '2025-12-20T18:22:03.265575+00:00'),
  ('4a30f3d0-6820-40a9-b4ba-4b6baceecd28', 'f4e7da34-c783-40a0-b07e-06a3b346ffca', 'sugoi', NULL, NULL, TRUE, 2, 0, '2025-12-20T17:56:06.508361+00:00', '2025-12-20T17:56:06.508361+00:00'),
  ('13cb5998-57c3-4f46-a968-548eae66df1c', 'f4e7da34-c783-40a0-b07e-06a3b346ffca', 'morning', NULL, NULL, TRUE, 4, 0, '2025-12-21T02:11:51.109849+00:00', '2025-12-21T02:11:51.109849+00:00')
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
  ('a029e70c-9f6c-4f29-86db-dd35d5be5a2f', '98842d70-046c-4c9e-aa1d-f07f728b6142', '9121618a-9da5-4713-b130-fbd9a0bae4a3', 'main', 0)
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
  ('5536954e-49a9-4928-8e67-015ce56abd8a', '9e7233f9-2bba-47b8-8d5a-33ab4a8904c7', '9121618a-9da5-4713-b130-fbd9a0bae4a3')
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
  ('d006948a-c1a3-42c6-985c-61e4c0ea3456', '9e7233f9-2bba-47b8-8d5a-33ab4a8904c7', '98842d70-046c-4c9e-aa1d-f07f728b6142', 1)
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
  ('98842d70-046c-4c9e-aa1d-f07f728b6142', 'd6443d9c-d8e2-4538-87e0-d134f1d54ccf')
ON CONFLICT DO NOTHING;


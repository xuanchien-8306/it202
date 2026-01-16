/* =========================================================
   MINI SOCIAL NETWORK (Database Centric)
   Focus: Trigger + Transaction + Stored Procedure (MySQL)
   ========================================================= */

/* ========== 0) TẠO DATABASE ========== */
DROP DATABASE IF EXISTS MiniSocialNetworkDB;
CREATE DATABASE MiniSocialNetworkDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE MiniSocialNetworkDB;

/* =========================================================
   1) TABLES (theo SRS) + cột thống kê phục vụ Trigger nghiệm thu
   ========================================================= */

/* ========== 1.1) USERS ========== */
CREATE TABLE users (
  user_id        INT AUTO_INCREMENT PRIMARY KEY,
  username       VARCHAR(50)  NOT NULL UNIQUE,
  password       VARCHAR(255) NOT NULL,                 -- password đã mã hóa (demo dùng SHA2)
  email          VARCHAR(100) NOT NULL UNIQUE,
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

  -- Cột thống kê (để Trigger tự động cập nhật theo tiêu chí nghiệm thu)
  total_posts    INT NOT NULL DEFAULT 0,
  total_comments INT NOT NULL DEFAULT 0
) ENGINE=InnoDB;

/* ========== 1.2) POSTS ========== */
CREATE TABLE posts (
  post_id      INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT       NOT NULL,
  content      TEXT      NOT NULL,
  created_at   DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,

  -- Cột thống kê (Trigger sẽ tăng/giảm khi like/comment)
  like_count    INT NOT NULL DEFAULT 0,
  comment_count INT NOT NULL DEFAULT 0,

  CONSTRAINT fk_posts_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

/* ========== 1.3) COMMENTS ========== */
CREATE TABLE comments (
  comment_id  INT AUTO_INCREMENT PRIMARY KEY,
  post_id     INT      NOT NULL,
  user_id     INT      NOT NULL,
  content     TEXT     NOT NULL,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_comments_post
    FOREIGN KEY (post_id) REFERENCES posts(post_id)
    ON DELETE CASCADE,

  CONSTRAINT fk_comments_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

/* ========== 1.4) LIKES (PK ghép để ngăn like trùng) ========== */
CREATE TABLE likes (
  user_id     INT      NOT NULL,
  post_id     INT      NOT NULL,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, post_id),

  CONSTRAINT fk_likes_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE,

  CONSTRAINT fk_likes_post
    FOREIGN KEY (post_id) REFERENCES posts(post_id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

/* ========== 1.5) FRIENDS (self N-N qua bảng trung gian) ========== */
CREATE TABLE friends (
  user_id     INT       NOT NULL,
  friend_id   INT       NOT NULL,
  status      VARCHAR(20) NOT NULL DEFAULT 'pending',  -- pending | accepted
  created_at  DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (user_id, friend_id),

  CONSTRAINT fk_friends_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE,

  CONSTRAINT fk_friends_friend
    FOREIGN KEY (friend_id) REFERENCES users(user_id)
    ON DELETE CASCADE,

  CONSTRAINT chk_friends_status
    CHECK (status IN ('pending', 'accepted')),

  -- Chặn tự kết bạn với chính mình
  CONSTRAINT chk_no_self_friend
    CHECK (user_id <> friend_id)
) ENGINE=InnoDB;

/* =========================================================
   2) TABLE LOG (để đúng yêu cầu Trigger ghi log khi đăng bài)
   ========================================================= */
CREATE TABLE post_logs (
  log_id     INT AUTO_INCREMENT PRIMARY KEY,
  post_id    INT NOT NULL,
  user_id    INT NOT NULL,
  action     VARCHAR(20) NOT NULL,            -- INSERT/UPDATE/DELETE (ở đây dùng INSERT)
  note       VARCHAR(255),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX (post_id),
  INDEX (user_id)
) ENGINE=InnoDB;

/* =========================================================
   3) INDEX / FULLTEXT (theo SRS: tìm bài theo từ khóa)
   ========================================================= */

/* Index hỗ trợ truy vấn phổ biến */
CREATE INDEX idx_posts_user_created     ON posts(user_id, created_at);
CREATE INDEX idx_comments_post_created  ON comments(post_id, created_at);
CREATE INDEX idx_friends_friend_status  ON friends(friend_id, status);

/* Full-Text Search cho posts.content (MySQL InnoDB hỗ trợ FULLTEXT) */
ALTER TABLE posts ADD FULLTEXT INDEX ft_posts_content (content);

/* =========================================================
   4) TRANSACTION (theo SRS: chuyển tiền) - tạo thêm bảng ví
   ========================================================= */

/* Ví của user: mỗi user có 1 wallet */
CREATE TABLE wallets (
  user_id  INT PRIMARY KEY,
  balance  DECIMAL(12,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_wallets_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

/* Log chuyển tiền */
CREATE TABLE money_transfers (
  transfer_id  INT AUTO_INCREMENT PRIMARY KEY,
  from_user_id INT NOT NULL,
  to_user_id   INT NOT NULL,
  amount       DECIMAL(12,2) NOT NULL,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_mt_from
    FOREIGN KEY (from_user_id) REFERENCES users(user_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_mt_to
    FOREIGN KEY (to_user_id) REFERENCES users(user_id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

/* =========================================================
   5) TRIGGERS (theo SRS)
   - Posts: kiểm tra + ghi log + cập nhật total_posts
   - Likes: chặn like chính mình + cập nhật like_count
   - Comments: cập nhật comment_count + total_comments
   - Friends: chặn trùng/logic + đồng bộ khi accepted
   ========================================================= */

DELIMITER //

/* ---------- 5.1) POSTS: BEFORE INSERT (validate) ---------- */
CREATE TRIGGER trg_posts_before_insert
BEFORE INSERT ON posts
FOR EACH ROW
BEGIN
  -- Chặn content rỗng/space (dễ hiểu cho bài)
  IF NEW.content IS NULL OR LENGTH(TRIM(NEW.content)) = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Post content cannot be empty.';
  END IF;

  -- Chặn user_id không hợp lệ (dù FK đã chặn, nhưng trigger cho rõ nghiệp vụ)
  IF NEW.user_id IS NULL OR NEW.user_id <= 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Invalid user_id for post.';
  END IF;
END//
/* ---------- 5.2) POSTS: AFTER INSERT (log + tăng total_posts) ---------- */
CREATE TRIGGER trg_posts_after_insert
AFTER INSERT ON posts
FOR EACH ROW
BEGIN
  -- Tăng tổng số bài viết của user
  UPDATE users
  SET total_posts = total_posts + 1
  WHERE user_id = NEW.user_id;

  -- Ghi log đăng bài
  INSERT INTO post_logs(post_id, user_id, action, note)
  VALUES (NEW.post_id, NEW.user_id, 'INSERT', 'User created a new post');
END//

/* ---------- 5.3) POSTS: AFTER DELETE (giảm total_posts) ---------- */
CREATE TRIGGER trg_posts_after_delete
AFTER DELETE ON posts
FOR EACH ROW
BEGIN
  -- Khi xóa post, giảm total_posts (FK CASCADE sẽ xóa comment/like tự động)
  UPDATE users
  SET total_posts = CASE WHEN total_posts > 0 THEN total_posts - 1 ELSE 0 END
  WHERE user_id = OLD.user_id;
END//

/* ---------- 5.4) COMMENTS: BEFORE INSERT (validate) ---------- */
CREATE TRIGGER trg_comments_before_insert
BEFORE INSERT ON comments
FOR EACH ROW
BEGIN
  IF NEW.content IS NULL OR LENGTH(TRIM(NEW.content)) = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Comment content cannot be empty.';
  END IF;
END//

/* ---------- 5.5) COMMENTS: AFTER INSERT (tăng comment_count + total_comments) ---------- */
CREATE TRIGGER trg_comments_after_insert
AFTER INSERT ON comments
FOR EACH ROW
BEGIN
  UPDATE posts
  SET comment_count = comment_count + 1
  WHERE post_id = NEW.post_id;

  UPDATE users
  SET total_comments = total_comments + 1
  WHERE user_id = NEW.user_id;
END//

/* ---------- 5.6) COMMENTS: AFTER DELETE (giảm comment_count + total_comments) ---------- */
CREATE TRIGGER trg_comments_after_delete
AFTER DELETE ON comments
FOR EACH ROW
BEGIN
  UPDATE posts
  SET comment_count = CASE WHEN comment_count > 0 THEN comment_count - 1 ELSE 0 END
  WHERE post_id = OLD.post_id;

  UPDATE users
  SET total_comments = CASE WHEN total_comments > 0 THEN total_comments - 1 ELSE 0 END
  WHERE user_id = OLD.user_id;
END//

/* ---------- 5.7) LIKES: BEFORE INSERT (chặn like chính mình) ---------- */
CREATE TRIGGER trg_likes_before_insert
BEFORE INSERT ON likes
FOR EACH ROW
BEGIN
  DECLARE v_author INT;

  -- Lấy tác giả bài viết
  SELECT user_id INTO v_author
  FROM posts
  WHERE post_id = NEW.post_id;

  -- Nếu không có post -> báo lỗi rõ ràng
  IF v_author IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Post does not exist.';
  END IF;

  -- Chặn like bài của chính mình
  IF NEW.user_id = v_author THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'User cannot like their own post.';
  END IF;
END//

/* ---------- 5.8) LIKES: AFTER INSERT (tăng like_count) ---------- */
CREATE TRIGGER trg_likes_after_insert
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
  UPDATE posts
  SET like_count = like_count + 1
  WHERE post_id = NEW.post_id;
END//

/* ---------- 5.9) LIKES: AFTER DELETE (giảm like_count) ---------- */
CREATE TRIGGER trg_likes_after_delete
AFTER DELETE ON likes
FOR EACH ROW
BEGIN
  UPDATE posts
  SET like_count = CASE WHEN like_count > 0 THEN like_count - 1 ELSE 0 END
  WHERE post_id = OLD.post_id;
END//

/* ---------- 5.10) FRIENDS: BEFORE INSERT (chặn trùng + chặn gửi ngược chiều đã tồn tại) ---------- */
CREATE TRIGGER trg_friends_before_insert
BEFORE INSERT ON friends
FOR EACH ROW
BEGIN
  DECLARE v_exists INT DEFAULT 0;

  -- Chặn gửi trùng (cùng chiều)
  SELECT COUNT(*) INTO v_exists
  FROM friends
  WHERE user_id = NEW.user_id AND friend_id = NEW.friend_id;

  IF v_exists > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Friend request already exists.';
  END IF;

  -- Chặn trường hợp đã có request chiều ngược (friend_id -> user_id)
  SELECT COUNT(*) INTO v_exists
  FROM friends
  WHERE user_id = NEW.friend_id AND friend_id = NEW.user_id;

  IF v_exists > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Reverse friend request already exists.';
  END IF;
END//

/* ---------- 5.11) FRIENDS: AFTER UPDATE (pending -> accepted) đồng bộ 2 chiều ---------- */
CREATE TRIGGER trg_friends_after_update
AFTER UPDATE ON friends
FOR EACH ROW
BEGIN
  -- Khi chuyển pending -> accepted thì tạo bản ghi đối xứng (accepted) nếu chưa có
  IF OLD.status = 'pending' AND NEW.status = 'accepted' THEN
    INSERT IGNORE INTO friends(user_id, friend_id, status, created_at)
    VALUES (NEW.friend_id, NEW.user_id, 'accepted', NOW());
  END IF;
END//

DELIMITER ;

/* =========================================================
   6) STORED PROCEDURES + TRANSACTIONS (theo SRS)
   ========================================================= */

DELIMITER //

/* ---------- 6.1) F01: Đăng ký thành viên (Transaction) ---------- */
CREATE PROCEDURE sp_RegisterUser(
  IN p_username VARCHAR(50),
  IN p_email    VARCHAR(100),
  IN p_password VARCHAR(255),
  OUT p_user_id INT
)
BEGIN
  DECLARE v_cnt INT DEFAULT 0;

  START TRANSACTION;

  -- 1) Check trùng username/email
  SELECT COUNT(*) INTO v_cnt
  FROM users
  WHERE username = p_username OR email = p_email;

  IF v_cnt > 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Username or Email already exists.';
  END IF;

  -- 2) Insert user (demo mã hóa SHA2; thực tế dùng bcrypt ở app layer)
  INSERT INTO users(username, email, password)
  VALUES (p_username, p_email, SHA2(p_password, 256));

  SET p_user_id = LAST_INSERT_ID();

  -- 3) Tạo ví mặc định cho user (để dùng chuyển tiền)
  INSERT INTO wallets(user_id, balance)
  VALUES (p_user_id, 0);

  COMMIT;
END//

/* ---------- 6.2) F02: Đăng bài viết (trả về post_id) ---------- */
CREATE PROCEDURE sp_CreatePost(
  IN  p_user_id INT,
  IN  p_content TEXT,
  OUT p_post_id INT
)
BEGIN
  -- Trigger sẽ validate content và tự log + tăng total_posts
  INSERT INTO posts(user_id, content)
  VALUES (p_user_id, p_content);

  SET p_post_id = LAST_INSERT_ID();
END//

/* ---------- 6.3) F03: Like bài viết ---------- */
CREATE PROCEDURE sp_LikePost(
  IN p_user_id INT,
  IN p_post_id INT
)
BEGIN
  -- PK (user_id, post_id) sẽ chặn like trùng
  -- Trigger BEFORE INSERT sẽ chặn like chính mình
  INSERT INTO likes(user_id, post_id)
  VALUES (p_user_id, p_post_id);
END//

/* ---------- 6.4) F03: Unlike bài viết ---------- */
CREATE PROCEDURE sp_UnlikePost(
  IN p_user_id INT,
  IN p_post_id INT
)
BEGIN
  DELETE FROM likes
  WHERE user_id = p_user_id AND post_id = p_post_id;
END//

/* ---------- 6.5) F04: Gửi lời mời kết bạn ---------- */
CREATE PROCEDURE sp_SendFriendRequest(
  IN p_user_id   INT,
  IN p_friend_id INT
)
BEGIN
  -- Trigger BEFORE INSERT sẽ chặn trùng/đảo chiều + CHECK chặn tự kết bạn
  INSERT INTO friends(user_id, friend_id, status)
  VALUES (p_user_id, p_friend_id, 'pending');
END//

/* ---------- 6.6) F05: Hủy lời mời kết bạn (chỉ khi pending) ---------- */
CREATE PROCEDURE sp_CancelFriendRequest(
  IN p_user_id   INT,
  IN p_friend_id INT
)
BEGIN
  DELETE FROM friends
  WHERE user_id = p_user_id AND friend_id = p_friend_id AND status = 'pending';
END//

/* ---------- 6.7) F06: Chấp nhận lời mời kết bạn ---------- */
CREATE PROCEDURE sp_AcceptFriendRequest(
  IN p_user_id   INT,   -- người nhận
  IN p_friend_id INT    -- người gửi
)
BEGIN
  -- Bản ghi request: (friend_id -> user_id) là pending
  UPDATE friends
  SET status = 'accepted'
  WHERE user_id = p_friend_id AND friend_id = p_user_id AND status = 'pending';

  -- Trigger AFTER UPDATE sẽ tự tạo bản ghi đối xứng accepted
END//

/* ---------- 6.8) F07: View trang cá nhân (public) ---------- */
CREATE OR REPLACE VIEW vw_public_users AS
SELECT user_id, username, created_at
FROM users;

/* ---------- 6.9) F08: Tìm bài theo từ khóa (Full-Text) ---------- */
CREATE PROCEDURE sp_SearchPosts(
  IN p_keyword VARCHAR(200)
)
BEGIN
  -- Fulltext tìm kiếm nhanh theo nội dung
  SELECT post_id, user_id, content, created_at, like_count, comment_count
  FROM posts
  WHERE MATCH(content) AGAINST(p_keyword IN NATURAL LANGUAGE MODE)
  ORDER BY created_at DESC;
END//

/* ---------- 6.10) F09: Báo cáo hoạt động user ---------- */
CREATE PROCEDURE sp_UserActivityReport(
  IN p_user_id INT
)
BEGIN
  SELECT
    u.user_id,
    u.username,
    u.total_posts,
    u.total_comments,
    (SELECT COUNT(*) FROM likes l WHERE l.user_id = p_user_id) AS total_likes_done,
    (SELECT COUNT(*) FROM posts p WHERE p.user_id = p_user_id) AS posts_check,
    (SELECT COUNT(*) FROM comments c WHERE c.user_id = p_user_id) AS comments_check
  FROM users u
  WHERE u.user_id = p_user_id;
END//

/* ---------- 6.11) F10: Gợi ý kết bạn (mutual friends) ---------- */
CREATE PROCEDURE sp_SuggestFriends(
  IN p_user_id INT
)
BEGIN
  /*
    Gợi ý bạn bè dựa trên "bạn của bạn":
    - Lấy danh sách bạn đã accepted của p_user_id
    - Tìm bạn của những người đó (accepted)
    - Loại trừ: chính mình, người đã là bạn, người đang pending
  */

  SELECT DISTINCT f2.friend_id AS suggested_user_id
  FROM friends f1
  JOIN friends f2
    ON f1.friend_id = f2.user_id
  WHERE f1.user_id = p_user_id
    AND f1.status = 'accepted'
    AND f2.status = 'accepted'
    AND f2.friend_id <> p_user_id
    AND f2.friend_id NOT IN (
      SELECT friend_id FROM friends WHERE user_id = p_user_id
      UNION
      SELECT user_id FROM friends WHERE friend_id = p_user_id
    );
END//

/* ---------- 6.12) F11: Xóa bài viết (Transaction) ----------
   Lưu ý: FK ON DELETE CASCADE đã tự xóa comments/likes.
   Nhưng dùng Transaction để đúng yêu cầu "All or Nothing" + dễ chấm.
----------------------------------------------------------- */
CREATE PROCEDURE sp_DeletePost(
  IN p_post_id INT
)
BEGIN
  START TRANSACTION;

  -- Nếu muốn kiểm tra tồn tại trước khi xóa
  IF NOT EXISTS (SELECT 1 FROM posts WHERE post_id = p_post_id) THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Post not found.';
  END IF;

  -- Xóa post (cascade sẽ xóa likes/comments liên quan)
  DELETE FROM posts WHERE post_id = p_post_id;

  COMMIT;
END//

/* ---------- 6.13) F12: Xóa tài khoản user (Transaction) ----------
   FK CASCADE sẽ tự dọn: posts/comments/likes/friends/wallets
----------------------------------------------------------- */
CREATE PROCEDURE sp_DeleteUser(
  IN p_user_id INT
)
BEGIN
  START TRANSACTION;

  IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = p_user_id) THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'User not found.';
  END IF;

  DELETE FROM users WHERE user_id = p_user_id;

  COMMIT;
END//

/* ---------- 6.14) F13: Cập nhật thông tin user (Transaction) ---------- */
CREATE PROCEDURE sp_UpdateUser(
  IN p_user_id   INT,
  IN p_username  VARCHAR(50),
  IN p_email     VARCHAR(100)
)
BEGIN
  DECLARE v_cnt INT DEFAULT 0;

  START TRANSACTION;

  -- Check user tồn tại
  IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = p_user_id) THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'User not found.';
  END IF;

  -- Check trùng username/email với user khác
  SELECT COUNT(*) INTO v_cnt
  FROM users
  WHERE (username = p_username OR email = p_email)
    AND user_id <> p_user_id;

  IF v_cnt > 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Username or Email already taken by another user.';
  END IF;

  UPDATE users
  SET username = p_username,
      email = p_email
  WHERE user_id = p_user_id;

  COMMIT;
END//

/* ---------- 6.15) F14: Quản lý trạng thái bạn bè (Transaction) ----------
   Ví dụ: đổi status (chỉ cho pending->accepted), hoặc hủy nếu pending
----------------------------------------------------------- */
CREATE PROCEDURE sp_UpdateFriendStatus(
  IN p_user_id   INT,
  IN p_friend_id INT,
  IN p_status    VARCHAR(20)
)
BEGIN
  START TRANSACTION;

  IF p_status NOT IN ('pending', 'accepted') THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Invalid status.';
  END IF;

  UPDATE friends
  SET status = p_status
  WHERE user_id = p_user_id AND friend_id = p_friend_id;

  COMMIT;
END//

/* ---------- 6.16) Transaction: Chuyển tiền (ACID - All or Nothing) ---------- */
CREATE PROCEDURE sp_TransferMoney(
  IN p_from_user INT,
  IN p_to_user   INT,
  IN p_amount    DECIMAL(12,2)
)
BEGIN
  DECLARE v_from_balance DECIMAL(12,2);

  -- Validate cơ bản
  IF p_amount <= 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Transfer amount must be > 0.';
  END IF;

  IF p_from_user = p_to_user THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Cannot transfer to the same user.';
  END IF;

  START TRANSACTION;

  -- Khóa dòng số dư người gửi để tránh race condition
  SELECT balance INTO v_from_balance
  FROM wallets
  WHERE user_id = p_from_user
  FOR UPDATE;

  IF v_from_balance IS NULL THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Sender wallet not found.';
  END IF;

  -- Khóa dòng người nhận
  IF NOT EXISTS (SELECT 1 FROM wallets WHERE user_id = p_to_user FOR UPDATE) THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Receiver wallet not found.';
  END IF;

  -- Check đủ tiền
  IF v_from_balance < p_amount THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Insufficient balance.';
  END IF;

  -- Trừ tiền người gửi
  UPDATE wallets
  SET balance = balance - p_amount
  WHERE user_id = p_from_user;

  -- Cộng tiền người nhận
  UPDATE wallets
  SET balance = balance + p_amount
  WHERE user_id = p_to_user;

  -- Ghi log chuyển tiền
  INSERT INTO money_transfers(from_user_id, to_user_id, amount)
  VALUES (p_from_user, p_to_user, p_amount);

  COMMIT;
END//

DELIMITER ;

/* =========================================================
   7) DỮ LIỆU MẪU (tuỳ chọn) để test nhanh
   ========================================================= */
-- CALL sp_RegisterUser('alice', 'alice@gmail.com', '123456', @uid1);
-- CALL sp_RegisterUser('bob',   'bob@gmail.com',   '123456', @uid2);
-- SELECT @uid1 AS alice_id, @uid2 AS bob_id;

-- CALL sp_CreatePost(@uid1, 'Hello world from Alice', @p1);
-- SELECT @p1 AS post_id;

-- CALL sp_LikePost(@uid2, @p1);
-- SELECT * FROM posts WHERE post_id = @p1;  -- like_count tăng

-- CALL sp_SendFriendRequest(@uid1, @uid2);
-- CALL sp_AcceptFriendRequest(@uid2, @uid1);
-- SELECT * FROM friends;

-- UPDATE wallets SET balance = 1000 WHERE user_id = @uid1;
-- CALL sp_TransferMoney(@uid1, @uid2, 200);
-- SELECT * FROM wallets;
-- SELECT * FROM money_transfers;

/* =========================================================
   FULL CODE - SOCIAL NETWORK MINI PROJECT (BÀI 1 -> 14)
   (KHÔNG DÙNG CHARACTER SET / COLLATE, KHÔNG DÙNG SIGNAL)
   ========================================================= */

DROP DATABASE IF EXISTS social_network_lab;
CREATE DATABASE social_network_lab;
USE social_network_lab;

/* =========================
   I) TABLES
   ========================= */

CREATE TABLE Users (
  user_id    INT AUTO_INCREMENT PRIMARY KEY,
  username   VARCHAR(50)  NOT NULL UNIQUE,
  password   VARCHAR(255) NOT NULL,
  email      VARCHAR(100) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Posts (
  post_id    INT AUTO_INCREMENT PRIMARY KEY,
  user_id    INT NOT NULL,
  content    TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Comments (
  comment_id INT AUTO_INCREMENT PRIMARY KEY,
  post_id    INT NOT NULL,
  user_id    INT NOT NULL,
  content    TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_id) REFERENCES Posts(post_id),
  FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Friends (
  user_id   INT NOT NULL,
  friend_id INT NOT NULL,
  status    VARCHAR(20) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, friend_id),
  FOREIGN KEY (user_id) REFERENCES Users(user_id),
  FOREIGN KEY (friend_id) REFERENCES Users(user_id)
  -- Nếu bạn chưa học CHECK thì không thêm CHECK ở đây
);

CREATE TABLE Likes (
  user_id INT NOT NULL,
  post_id INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, post_id),
  FOREIGN KEY (user_id) REFERENCES Users(user_id),
  FOREIGN KEY (post_id) REFERENCES Posts(post_id)
);

/* =========================
   II) DATA MẪU (đủ để test)
   ========================= */
INSERT INTO Users(username, password, email) VALUES
('an','123','an@gmail.com'),
('binh','123','binh@gmail.com'),
('chi','123','chi@gmail.com'),
('duy','123','duy@gmail.com'),
('huyen','123','huyen@gmail.com'),
('dung','123','dung@gmail.com');

INSERT INTO Posts(user_id, content, created_at) VALUES
(1,'Hello everyone, I am learning database', NOW() - INTERVAL 1 DAY),
(2,'I love MySQL view and index', NOW() - INTERVAL 2 DAY),
(1,'Stored procedure is useful for database', NOW() - INTERVAL 5 DAY),
(3,'Today I practice SQL and database', NOW() - INTERVAL 6 DAY),
(4,'This post is older than 7 days', NOW() - INTERVAL 10 DAY);

INSERT INTO Comments(post_id, user_id, content, created_at) VALUES
(1,2,'Nice!', NOW() - INTERVAL 1 DAY),
(1,3,'Good luck!', NOW() - INTERVAL 1 DAY),
(2,1,'Agree', NOW() - INTERVAL 2 DAY),
(3,5,'SP is great', NOW() - INTERVAL 5 DAY);

INSERT INTO Likes(user_id, post_id, created_at) VALUES
(2,1,NOW() - INTERVAL 1 DAY),
(3,1,NOW() - INTERVAL 1 DAY),
(4,1,NOW() - INTERVAL 1 DAY),
(1,2,NOW() - INTERVAL 2 DAY),
(3,2,NOW() - INTERVAL 2 DAY),
(5,3,NOW() - INTERVAL 5 DAY);

/* =========================================================
   III) MỨC TRUNG BÌNH (BÀI 1-3)
   ========================================================= */

-- Bài 1: Thêm user + hiển thị
INSERT INTO Users(username, password, email)
VALUES ('nam','123','nam@gmail.com');

SELECT * FROM Users ORDER BY user_id;

-- Bài 2: VIEW public users
DROP VIEW IF EXISTS vw_public_users;
CREATE VIEW vw_public_users AS
SELECT user_id, username, created_at
FROM Users;

SELECT * FROM vw_public_users;  -- công khai
SELECT * FROM Users;            -- đầy đủ (có password/email)

-- Bài 3: INDEX username (UNIQUE thường đã có index, nhưng tạo theo yêu cầu bài)
CREATE INDEX idx_users_username ON Users(username);

-- test tìm theo username
EXPLAIN SELECT * FROM Users WHERE username = 'an';


/* =========================================================
   IV) MỨC KHÁ (BÀI 4-7)
   ========================================================= */

-- Bài 4: Procedure đăng bài có check user tồn tại
DROP PROCEDURE IF EXISTS sp_create_post;
DELIMITER //

CREATE PROCEDURE sp_create_post(
  IN p_user_id INT,
  IN p_content TEXT
)
BEGIN
  IF EXISTS (SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
    INSERT INTO Posts(user_id, content) VALUES (p_user_id, p_content);
    SELECT 'Tạo bài viết thành công' AS message;
  ELSE
    SELECT 'User không tồn tại - không thể đăng bài' AS message;
  END IF;
END//

DELIMITER ;

CALL sp_create_post(1, 'New post by user 1');
CALL sp_create_post(999, 'Should fail');

-- Bài 5: View recent posts 7 ngày gần nhất
DROP VIEW IF EXISTS vw_recent_posts;
CREATE VIEW vw_recent_posts AS
SELECT p.post_id, p.user_id, u.username, p.content, p.created_at
FROM Posts p
JOIN Users u ON u.user_id = p.user_id
WHERE p.created_at >= NOW() - INTERVAL 7 DAY;

SELECT * FROM vw_recent_posts ORDER BY created_at DESC;

-- Bài 6: Index tối ưu query bài viết của 1 user theo thời gian
CREATE INDEX idx_posts_user_id ON Posts(user_id);
CREATE INDEX idx_posts_user_created ON Posts(user_id, created_at);

EXPLAIN
SELECT post_id, content, created_at
FROM Posts
WHERE user_id = 1
ORDER BY created_at DESC;

-- Bài 7: Procedure đếm số bài viết của user
DROP PROCEDURE IF EXISTS sp_count_posts;
DELIMITER //

CREATE PROCEDURE sp_count_posts(
  IN  p_user_id INT,
  OUT p_total INT
)
BEGIN
  SELECT COUNT(*)
  INTO p_total
  FROM Posts
  WHERE user_id = p_user_id;
END//

DELIMITER ;

SET @total_posts = 0;
CALL sp_count_posts(1, @total_posts);
SELECT @total_posts AS total_posts_user_1;


/* =========================================================
   V) MỨC GIỎI (BÀI 8-11)
   ========================================================= */

-- Bài 8: View WITH CHECK OPTION (ví dụ: active user = tạo trong 30 ngày gần đây)
DROP VIEW IF EXISTS vw_active_users;
CREATE VIEW vw_active_users AS
SELECT user_id, username, email, created_at
FROM Users
WHERE created_at >= NOW() - INTERVAL 30 DAY
WITH CHECK OPTION;

-- test insert/update qua view (nếu created_at vi phạm điều kiện thì bị từ chối)
-- (created_at có default CURRENT_TIMESTAMP nên thường pass)
INSERT INTO vw_active_users(username, password, email)
VALUES ('active_user_1','123','active1@gmail.com');

SELECT * FROM vw_active_users;

-- Bài 9: Procedure gửi lời mời kết bạn (không cho kết bạn với chính mình)
DROP PROCEDURE IF EXISTS sp_add_friend;
DELIMITER //

CREATE PROCEDURE sp_add_friend(
  IN p_user_id INT,
  IN p_friend_id INT
)
BEGIN
  IF p_user_id = p_friend_id THEN
    SELECT 'Không thể kết bạn với chính mình' AS message;

  ELSEIF NOT EXISTS (SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
    SELECT 'User gửi không tồn tại' AS message;

  ELSEIF NOT EXISTS (SELECT 1 FROM Users WHERE user_id = p_friend_id) THEN
    SELECT 'User nhận không tồn tại' AS message;

  ELSEIF EXISTS (SELECT 1 FROM Friends WHERE user_id = p_user_id AND friend_id = p_friend_id) THEN
    SELECT 'Đã tồn tại quan hệ/ lời mời trước đó' AS message;

  ELSE
    INSERT INTO Friends(user_id, friend_id, status) VALUES (p_user_id, p_friend_id, 'pending');
    SELECT 'Gửi lời mời kết bạn thành công' AS message;
  END IF;
END//

DELIMITER ;

CALL sp_add_friend(1,2);
CALL sp_add_friend(1,1);

-- Bài 10: Procedure gợi ý bạn bè (IN user_id, INOUT limit) + WHILE
-- Gợi ý đơn giản: các user khác chưa có quan hệ friend trực tiếp với p_user_id
DROP PROCEDURE IF EXISTS sp_suggest_friends;
DELIMITER //

CREATE PROCEDURE sp_suggest_friends(
  IN    p_user_id INT,
  INOUT p_limit INT
)
BEGIN
  DECLARE v_count INT DEFAULT 0;

  IF p_limit IS NULL OR p_limit <= 0 THEN
    SET p_limit = 5;
  END IF;

  -- trả về danh sách gợi ý (tối đa p_limit)
  SELECT u.user_id, u.username, u.created_at
  FROM Users u
  WHERE u.user_id <> p_user_id
    AND NOT EXISTS (
      SELECT 1 FROM Friends f
      WHERE (f.user_id = p_user_id AND f.friend_id = u.user_id)
         OR (f.user_id = u.user_id AND f.friend_id = p_user_id)
    )
  ORDER BY u.user_id
  LIMIT p_limit;

  -- ví dụ dùng WHILE: chỉ để minh hoạ “đã xử lý bao nhiêu lần”
  -- (không bắt buộc, nhưng bài yêu cầu có WHILE)
  WHILE v_count < p_limit DO
    SET v_count = v_count + 1;
  END WHILE;

  -- sau khi chạy xong, cập nhật lại p_limit (ví dụ: trả về đúng số vòng)
  SET p_limit = v_count;
END//

DELIMITER ;

SET @lim = 3;
CALL sp_suggest_friends(1, @lim);
SELECT @lim AS limit_after_proc;

-- Bài 11: Top 5 bài viết nhiều like nhất + View + Index Likes.post_id
CREATE INDEX idx_likes_post_id ON Likes(post_id);

DROP VIEW IF EXISTS vw_top_posts;
CREATE VIEW vw_top_posts AS
SELECT p.post_id, p.user_id, p.content, COUNT(l.user_id) AS like_count
FROM Posts p
LEFT JOIN Likes l ON l.post_id = p.post_id
GROUP BY p.post_id, p.user_id, p.content
ORDER BY like_count DESC, p.post_id DESC
LIMIT 5;

SELECT * FROM vw_top_posts;


/* =========================================================
   VI) MỨC XUẤT SẮC (BÀI 12-14)
   ========================================================= */

-- Bài 12.1: Procedure thêm comment (DECLARE + IF/ELSE)
DROP PROCEDURE IF EXISTS sp_add_comment;
DELIMITER //

CREATE PROCEDURE sp_add_comment(
  IN p_user_id INT,
  IN p_post_id INT,
  IN p_content TEXT
)
BEGIN
  DECLARE v_user_exists INT DEFAULT 0;
  DECLARE v_post_exists INT DEFAULT 0;

  SELECT COUNT(*) INTO v_user_exists FROM Users WHERE user_id = p_user_id;
  SELECT COUNT(*) INTO v_post_exists FROM Posts WHERE post_id = p_post_id;

  IF v_user_exists = 0 THEN
    SELECT 'User không tồn tại' AS message;

  ELSEIF v_post_exists = 0 THEN
    SELECT 'Post không tồn tại' AS message;

  ELSE
    INSERT INTO Comments(post_id, user_id, content) VALUES (p_post_id, p_user_id, p_content);
    SELECT 'Thêm bình luận thành công' AS message;
  END IF;
END//

DELIMITER ;

CALL sp_add_comment(2, 1, 'Comment mới vào post 1');
CALL sp_add_comment(999, 1, 'Should fail');

-- Bài 12.2: View hiển thị comment theo post
DROP VIEW IF EXISTS vw_post_comments;
CREATE VIEW vw_post_comments AS
SELECT
  c.post_id,
  c.content AS comment_content,
  u.username AS commenter,
  c.created_at
FROM Comments c
JOIN Users u ON u.user_id = c.user_id;

SELECT * FROM vw_post_comments WHERE post_id = 1 ORDER BY created_at DESC;


-- Bài 13.1: Procedure like post (không cho like trùng)
DROP PROCEDURE IF EXISTS sp_like_post;
DELIMITER //

CREATE PROCEDURE sp_like_post(
  IN p_user_id INT,
  IN p_post_id INT
)
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
    SELECT 'User không tồn tại' AS message;

  ELSEIF NOT EXISTS (SELECT 1 FROM Posts WHERE post_id = p_post_id) THEN
    SELECT 'Post không tồn tại' AS message;

  ELSEIF EXISTS (SELECT 1 FROM Likes WHERE user_id = p_user_id AND post_id = p_post_id) THEN
    SELECT 'Bạn đã like bài này rồi (không cho trùng)' AS message;

  ELSE
    INSERT INTO Likes(user_id, post_id) VALUES (p_user_id, p_post_id);
    SELECT 'Like thành công' AS message;
  END IF;
END//

DELIMITER ;

CALL sp_like_post(2, 1);  -- đã like rồi -> báo trùng
CALL sp_like_post(2, 3);  -- like mới

-- Bài 13.2: View thống kê like theo post
DROP VIEW IF EXISTS vw_post_likes;
CREATE VIEW vw_post_likes AS
SELECT
  post_id,
  COUNT(*) AS total_likes
FROM Likes
GROUP BY post_id;

SELECT * FROM vw_post_likes ORDER BY total_likes DESC;


-- Bài 14: Procedure search user/post theo option
DROP PROCEDURE IF EXISTS sp_search_social;
DELIMITER //

CREATE PROCEDURE sp_search_social(
  IN p_option INT,
  IN p_keyword VARCHAR(100)
)
BEGIN
  IF p_option = 1 THEN
    -- tìm user theo username
    SELECT user_id, username, created_at
    FROM Users
    WHERE username LIKE CONCAT('%', p_keyword, '%')
    ORDER BY user_id DESC;

  ELSEIF p_option = 2 THEN
    -- tìm post theo content
    SELECT post_id, user_id, content, created_at
    FROM Posts
    WHERE content LIKE CONCAT('%', p_keyword, '%')
    ORDER BY created_at DESC, post_id DESC;

  ELSE
    SELECT 'Option không hợp lệ (1: user, 2: post)' AS message;
  END IF;
END//

DELIMITER ;

-- CALL theo yêu cầu đề
CALL sp_search_social(1, 'an');
CALL sp_search_social(2, 'database');
CALL sp_search_social(999, 'test');

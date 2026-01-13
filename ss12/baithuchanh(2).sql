
DROP DATABASE IF EXISTS social_mini;
CREATE DATABASE social_mini;
USE social_mini;

/* =========================
   I) TABLES
   ========================= */

CREATE TABLE Users (
  user_id    INT AUTO_INCREMENT PRIMARY KEY,
  username   VARCHAR(50) NOT NULL UNIQUE,
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
  PRIMARY KEY (user_id, friend_id),
  FOREIGN KEY (user_id) REFERENCES Users(user_id),
  FOREIGN KEY (friend_id) REFERENCES Users(user_id)
  -- NOTE: nếu bạn chưa học CHECK thì bỏ kiểm tra status ở mức table
);

CREATE TABLE Likes (
  user_id INT NOT NULL,
  post_id INT NOT NULL,
  PRIMARY KEY (user_id, post_id),
  FOREIGN KEY (user_id) REFERENCES Users(user_id),
  FOREIGN KEY (post_id) REFERENCES Posts(post_id)
);

/* =========================
   II) DATA MẪU
   ========================= */
INSERT INTO Users(username, password, email) VALUES
('an','123','an@gmail.com'),
('binh','123','binh@gmail.com'),
('huyen','123','huyen@gmail.com'),
('dung','123','dung@gmail.com');

INSERT INTO Posts(user_id, content, created_at) VALUES
(1,'Hello everyone, learning database today', NOW() - INTERVAL 1 DAY),
(2,'MySQL view and index are useful', NOW() - INTERVAL 3 DAY),
(1,'I love database and stored procedure', NOW() - INTERVAL 8 DAY),
(3,'Today I practice SQL', NOW());

INSERT INTO Comments(post_id, user_id, content) VALUES
(1,2,'Good luck!'),
(1,3,'Nice post'),
(2,1,'Agree');

INSERT INTO Likes(user_id, post_id) VALUES
(2,1),(3,1),(4,1),
(1,2),(3,2),
(2,4);

/* =========================================================
   III) MỨC TRUNG BÌNH
   ========================================================= */

-- Bài 1: thêm user + hiển thị user
INSERT INTO Users(username, password, email)
VALUES ('nam','123','nam@gmail.com');

SELECT user_id, username, email, created_at
FROM Users
ORDER BY user_id;

-- Bài 2: VIEW public
DROP VIEW IF EXISTS vw_public_users;
CREATE VIEW vw_public_users AS
SELECT user_id, username, created_at
FROM Users;

SELECT * FROM vw_public_users;
SELECT * FROM Users;  

-- Bài 3: INDEX tìm theo username
-- (UNIQUE(username) thường đã tạo index, nhưng bạn cứ tạo thêm theo bài nếu hệ thống cho phép)
CREATE INDEX idx_users_username ON Users(username);

EXPLAIN SELECT * FROM Users WHERE username = 'an';


/* =========================================================
   IV) MỨC KHÁ
   ========================================================= */

-- Bài 4: Procedure đăng bài (không dùng SIGNAL nếu bạn chưa học)
DROP PROCEDURE IF EXISTS sp_create_post;
DELIMITER //

CREATE PROCEDURE sp_create_post(
  IN p_user_id INT,
  IN p_content TEXT
)
BEGIN
  IF EXISTS (SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
    INSERT INTO Posts(user_id, content) VALUES (p_user_id, p_content);
  ELSE
    -- Trả về thông báo dạng SELECT (thay cho SIGNAL)
    SELECT 'User không tồn tại' AS message;
  END IF;
END//

DELIMITER ;

CALL sp_create_post(1, 'New post by user 1');
CALL sp_create_post(999, 'Should show error message');

-- Bài 5: View news feed 7 ngày gần nhất
DROP VIEW IF EXISTS vw_recent_posts;
CREATE VIEW vw_recent_posts AS
SELECT p.post_id, p.user_id, u.username, p.content, p.created_at
FROM Posts p
JOIN Users u ON u.user_id = p.user_id
WHERE p.created_at >= NOW() - INTERVAL 7 DAY;

SELECT * FROM vw_recent_posts ORDER BY created_at DESC;

-- Bài 6: Index tối ưu query bài viết của user
CREATE INDEX idx_posts_user_id ON Posts(user_id);
CREATE INDEX idx_posts_user_created ON Posts(user_id, created_at);

EXPLAIN
SELECT post_id, content, created_at
FROM Posts
WHERE user_id = 1
ORDER BY created_at DESC;

-- Bài 7: Procedure đếm số bài viết
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

SET @total = 0;
CALL sp_count_posts(1, @total);
SELECT @total AS total_posts_user_1;


/* =========================================================
   V) THÊM (NẾU BẠN MUỐN) - TOP 5 BÀI NHIỀU LIKE
   ========================================================= */

CREATE INDEX idx_likes_post_id ON Likes(post_id);

DROP VIEW IF EXISTS vw_top_posts;
CREATE VIEW vw_top_posts AS
SELECT p.post_id, p.content, COUNT(l.user_id) AS like_count
FROM Posts p
LEFT JOIN Likes l ON l.post_id = p.post_id
GROUP BY p.post_id, p.content
ORDER BY like_count DESC, p.post_id DESC
LIMIT 5;

SELECT * FROM vw_top_posts;

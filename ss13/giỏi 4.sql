use socialtriggerdb;

CREATE TABLE post_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    old_content TEXT,
    new_content TEXT,
    changed_at DATETIME,
    changed_by_user_id INT,
    CONSTRAINT fk_history_post
        FOREIGN KEY (post_id)
        REFERENCES posts(post_id)
        ON DELETE CASCADE
);

-- User
INSERT INTO users (username, email) VALUES ('kien', 'kien@gmail.com');

-- Post
ALTER TABLE users
ADD total_posts INT DEFAULT 0;
INSERT INTO posts (user_id, content)
VALUES (1, 'Nội dung ban đầu');

-- Like (giả sử đã có trigger like_count từ bài trước)
INSERT INTO likes (user_id, post_id)
VALUES (1, 1);

DELIMITER $$

CREATE TRIGGER tg_LogPostHistory
BEFORE UPDATE ON posts
FOR EACH ROW
BEGIN
    IF OLD.content <> NEW.content THEN
        INSERT INTO post_history (
            post_id,
            old_content,
            new_content,
            changed_at,
            changed_by_user_id
        )
        VALUES (
            OLD.post_id,
            OLD.content,
            NEW.content,
            NOW(),
            OLD.user_id
        );
    END IF;
END$$

DELIMITER ;

UPDATE posts
SET content = 'Nội dung đã chỉnh sửa lần 1'
WHERE post_id = 1;

UPDATE posts
SET content = 'Nội dung đã chỉnh sửa lần 2'
WHERE post_id = 1;

SELECT 
    history_id,
    post_id,
    old_content,
    new_content,
    changed_at,
    changed_by_user_id
FROM post_history
WHERE post_id = 1
ORDER BY changed_at;

SELECT like_count
FROM posts
WHERE post_id = 1;


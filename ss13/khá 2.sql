use socialtriggerdb;

CREATE TABLE likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    post_id INT,
    liked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_likes_users
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_likes_posts
        FOREIGN KEY (post_id)
        REFERENCES posts(post_id)
        ON DELETE CASCADE
);

INSERT INTO likes (user_id, post_id, liked_at) VALUES
(2, 1, '2025-01-10 11:00:00'),
(3, 1, '2025-01-10 13:00:00'),
(1, 3, '2025-01-11 10:00:00'),
(3, 4, '2025-01-12 16:00:00');

delimiter $$
create trigger tg_AfterInsert_Likes
after insert on likes
for each row
begin 
	update posts
    set like_count = like_count + 1
    where post_id = new.post_id;
end $$
delimiter ;

delimiter $$
create trigger tg_AfterDelete_Likes
after delete on likes
for each row
begin
	update posts
    set like_count = like_count - 1
    where post_id = old.post_id;
end $$
delimiter ;

CREATE VIEW user_statistics AS
SELECT
    u.user_id,
    u.username,
    u.post_count,
    COALESCE(SUM(p.like_count), 0) AS total_likes
FROM users u
LEFT JOIN posts p
    ON u.user_id = p.user_id
GROUP BY
    u.user_id,
    u.username,
    u.post_count;
INSERT INTO likes (user_id, post_id, liked_at)
VALUES (2, 4, NOW());

SELECT * FROM posts WHERE post_id = 4;

SELECT * FROM user_statistics;

DELETE FROM likes
WHERE user_id = 2 AND post_id = 4;

SELECT * FROM user_statistics;
	
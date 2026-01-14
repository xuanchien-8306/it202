DROP DATABASE IF EXISTS SocialTriggerDB;
CREATE DATABASE SocialTriggerDB;
USE SocialTriggerDB;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at DATE,
    follower_count INT DEFAULT 0,
    post_count INT DEFAULT 0
);

CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content TEXT,
    created_at DATETIME,
    like_count INT DEFAULT 0,
    CONSTRAINT fk_posts_users
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

INSERT INTO users (username, email, created_at) VALUES
('alice', 'alice@example.com', '2025-01-01'),
('bob', 'bob@example.com', '2025-01-02'),
('charlie', 'charlie@example.com', '2025-01-03');

delimiter $$
create trigger tg_AfterInsert_Posts
after insert on posts for each row
begin
	update users
	set post_count = post_count + 1
    where user_id = new.user_id;
end $$
delimiter ;

delimiter $$
create trigger tg_AfterDelete_Posts
after delete on posts for each row
begin
	update users 
    set post_count = post_count - 1
    where user_id = old.user_id;
end	$$
delimiter ;

INSERT INTO posts (user_id, content, created_at) VALUES
(1, 'Hello world from Alice!', '2025-01-10 10:00:00'),
(1, 'Second post by Alice', '2025-01-10 12:00:00'),
(2, 'Bob first post', '2025-01-11 09:00:00'),
(3, 'Charlie sharing thoughts', '2025-01-12 15:00:00');

SELECT * FROM users;

delete from posts where post_id = 2;

SELECT * FROM users;

-- Tạo database
DROP DATABASE IF EXISTS SocialNetworkDB;
CREATE DATABASE SocialNetworkDB;
USE SocialNetworkDB;

-- Bảng users
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    total_posts INT DEFAULT 0
);

-- Bảng posts
CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_posts_users
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- Bảng post_audits
CREATE TABLE post_audits (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    old_content TEXT,
    new_content TEXT,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- task 1:
drop trigger tg_CheckPostContent;
delimiter $$
create trigger tg_CheckPostContent 
before insert on posts
for each row
begin
	if new.content is null or trim(new.content) = '' then
		signal sqlstate '45000'
        set message_text = 'Nội dung bài viết không được để trống!';
        end if;	
end $$
delimiter ;

INSERT INTO users (username, email)
VALUES ('thắng', 'thang@example.com');


INSERT INTO posts (user_id, content)
VALUES (1, 'Bài viết đầu tiên');

INSERT INTO posts (user_id, content)
VALUES (1, '   ');

-- task 2:
drop  trigger tg_UpdatePostCountAfterInsert;
delimiter $$
create trigger tg_UpdatePostCountAfterInsert
after insert on posts
for each row
begin
	update users
    set total_posts  = total_posts  + 1
    where user_id = new.user_id;
end $$
delimiter ;

-- task 3:
delimiter $$
create trigger tg_LogPostChanges
after update on posts
for each row
begin
	if OLD.content <> NEW.content then
		insert into post_audits(post_id, old_content, new_content, changed_at) value
			(old.post_id, old.content, new.content, now());
		end if;
end $$
delimiter ; 

UPDATE post_audits
SET new_content = 'Nội dung đã chỉnh sửa'
WHERE post_id = 1;
SELECT * FROM post_audits;

insert into post_audits(post_id, old_content,new_content) value
(1, 'sfafe', 'ágagf');

-- task 4:
DELIMITER $$

CREATE TRIGGER tg_UpdatePostCountAfterDelete
AFTER DELETE ON posts
FOR EACH ROW
BEGIN
    UPDATE users
    SET total_posts = total_posts - 1
    WHERE user_id = OLD.user_id;
END$$

DELIMITER ;

DELETE FROM posts
WHERE post_id = 1;
SELECT total_posts FROM users WHERE user_id = 1;

DROP TRIGGER IF EXISTS tg_CheckPostContent;
DROP TRIGGER IF EXISTS tg_UpdatePostCountAfterInsert;
DROP TRIGGER IF EXISTS tg_LogPostChanges;
DROP TRIGGER IF EXISTS tg_UpdatePostCountAfterDelete;



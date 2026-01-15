create database btth_ss14;
use btth_ss14;

-- 1. Tạo bảng Users (Người dùng)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    total_posts INT DEFAULT 0
);

-- 2. Tạo bảng Posts (Bài viết)
CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 3. Tạo dữ liệu mẫu
INSERT INTO users (username, total_posts) VALUES ('nguyen_van_a', 0);
INSERT INTO users (username, total_posts) VALUES ('le_thi_b', 0);

delimiter // 
create procedure sp_create_post (p_user_id int,p_content text) 
begin 
	start transaction;
	set autocommit = 0;

    select username into @check_user from users where user_id = p_user_id;
    if (@check_user is null or trim(@check_user) = '') then
		signal sqlstate '45000'
        set message_text = 'id không tồn tại';
        rollback;
    end if;

	if (p_content is null or trim(p_content) = ' ') then
		signal sqlstate '45000'
        set message_text = 'Nội dung bài viết không được để trống';
        rollback;
    end if;

        insert into posts (user_id, content)
        values (p_user_id, p_content);

        update users
        set total_posts = total_posts + 1
        where user_id = p_user_id;

    commit;
end // 
delimiter ;

call sp_create_post(999,'ok ngae');
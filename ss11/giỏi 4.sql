use social_network_pro;

delimiter $$
create procedure CreatePostWithValidation (in p_user_id int, in p_content text, out result_message varchar(255))
begin 
	if char_length(p_content) < 5 then
		set result_message = 'Nội dung quá ngắn';
	else 
		insert into posts(user_id, content, created_at)
        value (p_user_id, p_content, now());
        set result_message = 'Thêm bài viết thành công';
	end if;
end $$
delimiter ;

call CreatePostWithValidation(1, 'Hi', @result);
select @result as result_message;

call CreatePostWithValidation(1, 'Bài viết hợp lệ', @result);
select @result as result_message;

select post_id, user_id, content, created_at
from posts
where user_id = 1
order by created_at desc;

drop procedure if exists CreatePostWithValidation;

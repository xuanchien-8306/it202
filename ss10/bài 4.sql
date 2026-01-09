use social_network_pro;

-- 2
explain analyze
select post_id, content, created_at
from posts
where user_id = 1 and created_at between '2026-01-01' AND '2026-12-31';
-- -> Filter: (posts.created_at between '2026-01-01' and '2026-12-31')  (cost=1.65 rows=9) (actual time=0.0463..0.0698 rows=9 loops=1)
--      -> Index lookup on posts using posts_fk_users (user_id=1)  (cost=1.65 rows=9) (actual time=0.0401..0.0604 rows=9 loops...
-- chỉ mục phức hợp
create index idx_created_at_user_id
on posts(created_at, user_id);

-- kiểm tra
explain analyze
select post_id, content, created_at
from posts
where user_id = 1 and created_at between '2026-01-01' AND '2026-12-31';
-- -> Filter: (posts.created_at between '2026-01-01' and '2026-12-31')  (cost=1.65 rows=9) (actual time=0.0358..0.0677 rows=9 loops=1)
-- -> Index lookup on posts using posts_fk_users (user_id=1)  (cost=1.65 rows=9) (actual time=0.0324..0.0594 rows=9 loops...

-- ============ 3 ==============
select user_id, username, email
from users
where email = 'an@gmail.com';

explain analyze
select user_id, username, email
from users
where email = 'an@gmail.com';
-- -> Rows fetched before execution  (cost=0..0 rows=1) (actual time=800e-6..900e-6 rows=1 loops=1)
 
create unique index idx_email
on users(email);	

explain analyze 	
select user_id, username, email
from users
where email = 'an@gmail.com';
-- -> Rows fetched before execution  (cost=0..0 rows=1) (actual time=500e-6..600e-6 rows=1 loops=1)
 
-- ============= 4 ==============
drop index idx_created_at_user_id on posts ;
drop index idx_email on users;
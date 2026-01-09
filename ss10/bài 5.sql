use social_network_pro;
-- tạo chỉ mục có tên idx_hometown
create index idx_hometown on users(hometown);

-- 3: truy vấn
explain analyze
select * 
from users u 
join posts p
	on u.user_id = p.user_id
where hometown = 'Hà Nội'
order by u.username desc
limit 10;
-- -> Limit: 10 row(s)  (cost=12.3 rows=10) (actual time=0.289..0.321 rows=10 loops=1)
--      -> Nested loop inner join  (cost=12.3 rows=48.8) (actual time=0.287..0.319 rows=10 loops=1)
--          -> Sort: u.username DESC  (cost=1.45 rows=8) (actual time=0.123..0...


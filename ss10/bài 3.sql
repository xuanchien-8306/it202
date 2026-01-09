use social_network_pro;
-- 2
EXPLAIN ANALYZE 
SELECT * FROM social_network_pro.users;
-- -> Table scan on users  (cost=2.85 rows=26) (actual time=0.041..0.078 rows=26 loops=1)
 
-- 3
create index idx_hometown on users(hometown);

-- 4
-- -> Table scan on users  (cost=2.85 rows=26) (actual time=0.0498..0.091 rows=26 loops=1)

-- 5
drop index idx_hometown on users;
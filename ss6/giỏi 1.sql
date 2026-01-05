USE ss_06;

-- TRUY VẤN: TÍNH DOANH THU & SỐ ĐƠN THEO NGÀY	
-- CHỈ LẤY CÁC ĐƠN HÀNG ĐÃ HOÀN THÀNH

SELECT
    order_date,                       -- Ngày đặt hàng
    SUM(total_amount) AS total_revenue, -- Tổng doanh thu theo ngày
    COUNT(order_id) AS total_orders    -- Số lượng đơn hàng theo ngày
FROM orders
WHERE status = 'completed'             -- Chỉ lấy đơn hàng hoàn thành
GROUP BY order_date                    -- Nhóm theo ngày
HAVING SUM(total_amount) > 1000000    -- Chỉ hiển thị ngày có doanh thu > 10.000.000
ORDER BY order_date;                   -- Sắp xếp theo ngày tăng dần

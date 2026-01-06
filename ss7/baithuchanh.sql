/* =========================================================
   FILE: ecommerce_subquery_answers.sql
   CHỦ ĐỀ: THƯƠNG MẠI ĐIỆN TỬ - TRUY VẤN LỒNG (SUBQUERY)
   YÊU CẦU:
   - Chỉ sử dụng SELECT + Subquery (KHÔNG JOIN)
   - Không thay đổi cấu trúc CSDL
   - Không dùng IFNULL()  (dùng COALESCE nếu cần)
   ========================================================= */

USE ecommerce_db;

-- =========================================================
-- 1) Sản phẩm có giá cao hơn mặt bằng chung (price > AVG(price))
-- =========================================================
SELECT
  sp.product_id,
  sp.product_name,
  sp.category,
  sp.price
FROM SAN_PHAM sp
WHERE sp.price > (SELECT AVG(price) FROM SAN_PHAM);

-- =========================================================
-- 2) Sản phẩm có số lượng bán ra thấp hơn mức trung bình
--    total_sold(sp) < AVG(total_sold(all products))
-- =========================================================
SELECT
  sp.product_id,
  sp.product_name,
  sp.category,
  COALESCE((
    SELECT SUM(ct.quantity)
    FROM CHI_TIET_DON_HANG ct
    WHERE ct.product_id = sp.product_id
  ), 0) AS total_sold
FROM SAN_PHAM sp
WHERE COALESCE((
    SELECT SUM(ct.quantity)
    FROM CHI_TIET_DON_HANG ct
    WHERE ct.product_id = sp.product_id
  ), 0) < (
    SELECT AVG(
      COALESCE((
        SELECT SUM(ct2.quantity)
        FROM CHI_TIET_DON_HANG ct2
        WHERE ct2.product_id = sp2.product_id
      ), 0)
    )
    FROM SAN_PHAM sp2
  );

-- =========================================================
-- 3) Khách hàng có tổng chi tiêu cao hơn mức trung bình
--    total_spent(kh) > AVG(total_spent(all customers))
-- =========================================================
SELECT
  kh.customer_id,
  kh.customer_name,
  kh.city,
  COALESCE((
    SELECT SUM(
      ct.quantity * (
        SELECT sp.price
        FROM SAN_PHAM sp
        WHERE sp.product_id = ct.product_id
      )
    )
    FROM CHI_TIET_DON_HANG ct
    WHERE ct.order_id IN (
      SELECT dh.order_id
      FROM DON_HANG dh
      WHERE dh.customer_id = kh.customer_id
    )
  ), 0) AS total_spent
FROM KHACH_HANG kh
WHERE COALESCE((
    SELECT SUM(
      ct.quantity * (
        SELECT sp.price
        FROM SAN_PHAM sp
        WHERE sp.product_id = ct.product_id
      )
    )
    FROM CHI_TIET_DON_HANG ct
    WHERE ct.order_id IN (
      SELECT dh.order_id
      FROM DON_HANG dh
      WHERE dh.customer_id = kh.customer_id
    )
  ), 0) > (
    SELECT AVG(
      COALESCE((
        SELECT SUM(
          ct2.quantity * (
            SELECT sp2.price
            FROM SAN_PHAM sp2
            WHERE sp2.product_id = ct2.product_id
          )
        )
        FROM CHI_TIET_DON_HANG ct2
        WHERE ct2.order_id IN (
          SELECT dh2.order_id
          FROM DON_HANG dh2
          WHERE dh2.customer_id = kh2.customer_id
        )
      ), 0)
    )
    FROM KHACH_HANG kh2
  );

-- =========================================================
-- 4) Khách hàng chỉ mua các sản phẩm có giá cao
--    "Giá cao" = price > AVG(price) toàn hệ thống
--    Logic: KH không có bất kỳ dòng mua nào với price <= AVG(price)
-- =========================================================
SELECT
  kh.customer_id,
  kh.customer_name,
  kh.city
FROM KHACH_HANG kh
WHERE NOT EXISTS (
  SELECT 1
  FROM CHI_TIET_DON_HANG ct
  WHERE ct.order_id IN (
    SELECT dh.order_id
    FROM DON_HANG dh
    WHERE dh.customer_id = kh.customer_id
  )
  AND (
    SELECT sp.price
    FROM SAN_PHAM sp
    WHERE sp.product_id = ct.product_id
  ) <= (SELECT AVG(price) FROM SAN_PHAM)
);

-- =========================================================
-- 5) Đơn hàng có tổng số lượng sản phẩm > mức trung bình
--    total_quantity(order) > AVG(total_quantity(all orders))
-- =========================================================
SELECT
  dh.order_id,
  dh.customer_id,
  dh.order_date,
  COALESCE((
    SELECT SUM(ct.quantity)
    FROM CHI_TIET_DON_HANG ct
    WHERE ct.order_id = dh.order_id
  ), 0) AS total_quantity
FROM DON_HANG dh
WHERE COALESCE((
    SELECT SUM(ct.quantity)
    FROM CHI_TIET_DON_HANG ct
    WHERE ct.order_id = dh.order_id
  ), 0) > (
    SELECT AVG(
      COALESCE((
        SELECT SUM(ct2.quantity)
        FROM CHI_TIET_DON_HANG ct2
        WHERE ct2.order_id = dh2.order_id
      ), 0)
    )
    FROM DON_HANG dh2
  );

-- =========================================================
-- 6) Đơn hàng lớn nhất trong nhóm đơn hàng có quy mô trên trung bình
--    - Nhóm trên TB: total_quantity(order) > AVG(total_quantity(all orders))
--    - Lấy MAX total_quantity trong nhóm đó
-- =========================================================
SELECT
  dh.order_id,
  dh.customer_id,
  dh.order_date,
  COALESCE((
    SELECT SUM(ct.quantity)
    FROM CHI_TIET_DON_HANG ct
    WHERE ct.order_id = dh.order_id
  ), 0) AS total_quantity
FROM DON_HANG dh
WHERE COALESCE((
    SELECT SUM(ct.quantity)
    FROM CHI_TIET_DON_HANG ct
    WHERE ct.order_id = dh.order_id
  ), 0) = (
    SELECT MAX(
      COALESCE((
        SELECT SUM(ct3.quantity)
        FROM CHI_TIET_DON_HANG ct3
        WHERE ct3.order_id = dh3.order_id
      ), 0)
    )
    FROM DON_HANG dh3
    WHERE COALESCE((
      SELECT SUM(ct4.quantity)
      FROM CHI_TIET_DON_HANG ct4
      WHERE ct4.order_id = dh3.order_id
    ), 0) > (
      SELECT AVG(
        COALESCE((
          SELECT SUM(ct5.quantity)
          FROM CHI_TIET_DON_HANG ct5
          WHERE ct5.order_id = dh5.order_id
        ), 0)
      )
      FROM DON_HANG dh5
    )
  );

-- =========================================================
-- 7) Mỗi danh mục: sản phẩm có doanh thu cao nhất
--    revenue(product) = SUM(quantity * price)
--    Chọn revenue = MAX(revenue) trong cùng category
-- =========================================================
SELECT
  sp.product_id,
  sp.product_name,
  sp.category,
  COALESCE((
    SELECT SUM(
      ct.quantity * (
        SELECT sp_in.price
        FROM SAN_PHAM sp_in
        WHERE sp_in.product_id = ct.product_id
      )
    )
    FROM CHI_TIET_DON_HANG ct
    WHERE ct.product_id = sp.product_id
  ), 0) AS revenue
FROM SAN_PHAM sp
WHERE COALESCE((
    SELECT SUM(
      ct.quantity * (
        SELECT sp_in.price
        FROM SAN_PHAM sp_in
        WHERE sp_in.product_id = ct.product_id
      )
    )
    FROM CHI_TIET_DON_HANG ct
    WHERE ct.product_id = sp.product_id
  ), 0) = (
    SELECT MAX(
      COALESCE((
        SELECT SUM(
          ct2.quantity * (
            SELECT sp2_in.price
            FROM SAN_PHAM sp2_in
            WHERE sp2_in.product_id = ct2.product_id
          )
        )
        FROM CHI_TIET_DON_HANG ct2
        WHERE ct2.product_id = sp2.product_id
      ), 0)
    )
    FROM SAN_PHAM sp2
    WHERE sp2.category = sp.category
  )
ORDER BY sp.category, revenue DESC;

-- =========================================================
-- 8) Phân tích truy vấn Subquery nhiều cấp: có nên thay bằng JOIN?
--    (Ghi chú trong comment, không phải câu lệnh bắt buộc)
-- =========================================================
/*
PHÂN TÍCH NGẮN:

- Subquery nhiều cấp (đặc biệt correlated subquery) rất hợp để diễn đạt tư duy:
  + Tính KPI cho từng đối tượng (SP/KH/Đơn)
  + So sánh với chuẩn hệ thống (AVG/MAX) ngay trong điều kiện
  => Dễ bám sát yêu cầu học và yêu cầu đề bài.

- Nhược điểm:
  + Correlated subquery thường bị tính lặp lại theo từng dòng => chậm khi dữ liệu lớn.
  + JOIN + GROUP BY/CTE (derived table) thường tối ưu hơn vì tổng hợp 1 lần.

KẾT LUẬN:
- Làm bài học: subquery là đúng chuẩn yêu cầu.
- Làm thực tế: thường viết lại bằng JOIN để tối ưu hiệu năng và dễ bảo trì.
*/

/* =========================
   KẾT THÚC FILE
   ========================= */

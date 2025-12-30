/* =========================================================
   PHẦN 1 – TẠO CƠ SỞ DỮ LIỆU
   ========================================================= */

-- Xóa CSDL nếu đã tồn tại (tránh lỗi khi chạy lại)
DROP DATABASE IF EXISTS course_registration;

-- Tạo CSDL mới
CREATE DATABASE course_registration;

-- Sử dụng CSDL vừa tạo
USE course_registration;


/* =========================================================
   PHẦN 2 – TẠO BẢNG THEO LƯỢC ĐỒ QUAN HỆ
   (Định kiểu dữ liệu + ràng buộc)
   ========================================================= */

CREATE TABLE SinhVien (
    -- Mã sinh viên: số nguyên, tự tăng
    student_id INT AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    
    -- Giới tính: chỉ cho phép M hoặc F
    gender CHAR(1),
    email VARCHAR(100),
	phone char(10)	,
    -- Khóa chính
    CONSTRAINT pk_sinhvien PRIMARY KEY (student_id),

    -- Email không được trùng
    CONSTRAINT uq_sinhvien_email UNIQUE (email),

    -- Ràng buộc kiểm tra giới tính
    CONSTRAINT ck_sinhvien_gender CHECK (gender IN ('M', 'F'))
);

CREATE TABLE MonHoc (
    course_id INT,
    course_name VARCHAR(100) NOT NULL,
    credits INT,

    -- Khóa chính
    CONSTRAINT pk_monhoc PRIMARY KEY (course_id)
);

CREATE TABLE DangKy (
    registration_id INT AUTO_INCREMENT,
    
    -- Mã sinh viên (khóa ngoại)
    student_id INT NOT NULL,

    -- Mã môn học (khóa ngoại)
    course_id INT NOT NULL,

    -- Học kỳ (ví dụ: 2024HK1)
    semester VARCHAR(10),

    -- Ngày đăng ký
    registration_date DATE NOT NULL,

    -- Khóa chính
    CONSTRAINT pk_dangky PRIMARY KEY (registration_id),

    -- Khóa ngoại tới SinhVien
    CONSTRAINT fk_dangky_sinhvien
        FOREIGN KEY (student_id)
        REFERENCES SinhVien(student_id),

    -- Khóa ngoại tới MonHoc
    CONSTRAINT fk_dangky_monhoc
        FOREIGN KEY (course_id)
        REFERENCES MonHoc(course_id)
);
-- =================================================
-- Thêm dữ liệu
-- =================================================
INSERT INTO SinhVien (student_id, full_name, date_of_birth, gender, email, phone)
VALUES
(1, 'Nguyen Van An',   '2002-01-10', 'M', 'an@gmail.com',   '0900000001'),
(2, 'Tran Thi Binh',   '2001-03-15', 'F', 'binh@gmail.com', '0900000002'),
(3, 'Le Van Cuong',    '2002-05-20', 'M', 'cuong@gmail.com','0900000003'),
(4, 'Pham Thi Dao',    '2003-07-12', 'F', 'dao@gmail.com',  '0900000004'),
(5, 'Hoang Van Em',    '2001-09-01', 'M', 'em@gmail.com',   '0900000005'),
(6, 'Vu Thi Hoa',      '2002-11-18', 'F', 'hoa@gmail.com',  '0900000006'),
(7, 'Do Van Khanh',    '2003-02-25', 'M', 'khanh@gmail.com','0900000007'),
(8, 'Bui Thi Lan',     '2002-04-30', 'F', 'lan@gmail.com',  '0900000008'),
(9, 'Dang Van Minh',   '2001-06-08', 'M', 'minh@gmail.com', '0900000009'),
(10,'Nguyen Thi Nhung','2003-08-14', 'F', 'nhung@gmail.com','0900000010');

INSERT INTO MonHoc (course_id, course_name, credits)
VALUES
(1, 'Co so du lieu',        3),
(2, 'Lap trinh C',          4),
(3, 'Lap trinh Java',       4),
(4, 'Lap trinh Web',        3),
(5, 'Cau truc du lieu',     4),
(6, 'He dieu hanh',         3),
(7, 'Mang may tinh',        3),
(8, 'Tri tue nhan tao',     3),
(9, 'Phan tich he thong',   3),
(10,'An toan thong tin',    3);

INSERT INTO DangKy (registration_id, student_id, course_id, semester, registration_date)
VALUES
(1,  1,  1,  '2024HK1', '2024-01-10'),
(2,  2,  2,  '2024HK1', '2024-01-11'),
(3,  3,  3,  '2024HK1', '2024-01-12'),
(4,  4,  4,  '2024HK1', '2024-01-13'),
(5,  5,  5,  '2024HK1', '2024-01-14'),
(6,  6,  6,  '2024HK2', '2024-06-10'),
(7,  7,  7,  '2024HK2', '2024-06-11'),
(8,  8,  8,  '2024HK2', '2024-06-12'),
(9,  9,  9,  '2024HK2', '2024-06-13'),
(10, 10, 10, '2024HK2', '2024-06-14');

-- =================================================
-- xem dữ liệu bằng select
-- =================================================
SELECT student_id, full_name FROM SinhVien;

SELECT course_name, credits FROM MonHoc;

SELECT student_id, course_id FROM DangKy;

-- =================================================
-- cập nhật dữ liệu
-- =================================================
UPDATE SinhVien
SET email = 'newemail@gmail.com' WHERE student_id = 1;

UPDATE MonHoc
SET credits = 4 WHERE course_id = 2;

UPDATE DangKy
SET semester = '2024HK2' WHERE registration_id = 3;

-- =================================================
-- Xoá dữ liệu
-- =================================================

DELETE FROM DangKy WHERE registration_id = 3;

DELETE FROM DangKy WHERE student_id = 1;

DELETE FROM SinhVien WHERE student_id = 1;

DELETE FROM DangKy WHERE student_id = 1;

/* =========================================================
   PHẦN 4 – KIỂM TRA CẤU TRÚC BẢNG
   ========================================================= */

-- Kiểm tra cấu trúc bảng SinhVien
DESCRIBE SinhVien;

-- Kiểm tra cấu trúc bảng MonHoc
DESCRIBE MonHoc;

-- Kiểm tra cấu trúc bảng DangKy
DESCRIBE DangKy;


/* =========================================================
   KẾT THÚC FILE
   ========================================================= */

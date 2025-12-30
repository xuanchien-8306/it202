CREATE DATABASE QuanLyDangKy;
USE QuanLyDangKy;


CREATE TABLE SinhVien (
    student_id CHAR(10) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Nam','Nu') NOT NULL,
    email VARCHAR(100) UNIQUE
);

CREATE TABLE MonHoc (
    subject_id CHAR(10) PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL,
    credits INT NOT NULL CHECK (credits > 0),
    description VARCHAR(255)
);

CREATE TABLE DangKy (
    student_id CHAR(10),
    subject_id CHAR(10),
    semester VARCHAR(10) NOT NULL,
    register_date DATE NOT NULL,
    PRIMARY KEY (student_id, subject_id),
    FOREIGN KEY (student_id) REFERENCES SinhVien(student_id),
    FOREIGN KEY (subject_id) REFERENCES MonHoc(subject_id)
);

ALTER TABLE SinhVien
ADD phone CHAR(10);
-- Lưu số điện thoại sinh viên

ALTER TABLE SinhVien
ADD CONSTRAINT uq_email UNIQUE (email);
-- Đảm bảo email không trùng

ALTER TABLE DangKy
MODIFY semester VARCHAR(20);
-- Cho phép lưu học kỳ chi tiết hơn

ALTER TABLE MonHoc
DROP COLUMN description;
-- Cột mô tả không cần thiết trong quản lý đăng ký

-- Kiểm tra
DESCRIBE SinhVien;
DESCRIBE MonHoc;
DESCRIBE DangKy;

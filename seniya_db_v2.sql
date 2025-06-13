CREATE DATABASE IF NOT EXISTS `seniya_db`
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `seniya_db`;

-- 사용자 권한
CREATE TABLE IF NOT EXISTS `roles` (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(255) NOT NULL UNIQUE
) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

INSERT INTO roles VALUES (1, "ADMIN");
INSERT INTO roles VALUES (2, "USER");
INSERT INTO roles VALUES (3, "TRAINER");

-- 사용자
CREATE TABLE IF NOT EXISTS `users` (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    role_id INT NOT NULL,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    Foreign Key (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
)CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 결제 내역 테이블
CREATE TABLE IF NOT EXISTS payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    method ENUM('CARD', 'BANK_TRANSFER', 'KAKAO_PAY', 'NAVER_PAY', 'TOSS') NOT NULL,
    status ENUM('PENDING', 'SUCCESS', 'FAILED', 'CANCELLED') DEFAULT 'PENDING',
    coupon_count INT NOT NULL DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
)CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 수강권
CREATE TABLE IF NOT EXISTS passes (
    pass_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    payment_id INT NOT NULL,
    coupon_type ENUM('REGULAR', 'EVENT'),
    -- 발급일 및 만료일
    issued_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME,
    used BOOLEAN DEFAULT FALSE,
    -- 사용 여부 (해당 값이 TRUE가 될 때마다 users.class_ticket이 감소되는 트리거 설정)
    used_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (payment_id) REFERENCES payments (payment_id) ON DELETE CASCADE
) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

DELIMITER $$
CREATE TRIGGER reduce_class_ticket
AFTER UPDATE ON passes
FOR EACH ROW
BEGIN
    IF OLD.used = FALSE AND NEW.used = TRUE THEN
        UPDATE users
        SET class_ticket = class_ticket - 1
        WHERE user_id = NEW.user_id;
    END IF;
END $$

DELIMITER ;

-- payment 승인 후 자동으로 pass 생성
DELIMITER $$
CREATE TRIGGER create_passes_after_payment_success
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
    DECLARE i INT DEFAULT 0;
    
    IF OLD.status != 'SUCCESS' AND NEW.status = 'SUCCESS' THEN
    
    WHILE i < NEW.coupon_count DO
            INSERT INTO passes (
                user_id,
                payment_id,
                coupon_type,
                issued_at,
                expires_at,
                used
            )
            VALUES (
                NEW.user_id,
                NEW.payment_id,
                'REGULAR',
                NOW(),
                DATE_ADD(NOW(), INTERVAL 30 DAY),
                FALSE
            );
            SET i = i + 1;
        END WHILE;
        END IF;
	END $$
    
DELIMITER ;

-- 트레이너 권한 신청
CREATE TABLE IF NOT EXISTS `trainer_applications` (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    applied_date DATE,
    approval_status ENUM('APPROVE', 'REJECT', 'PENDING', 'QUIT') DEFAULT 'PENDING',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

SELECT * from trainer_applications;

-- 트레이너 프로필
CREATE TABLE IF NOT EXISTS `trainer_profiles` (
    trainer_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    specialty ENUM('SLEEP', 'REHABILITATION', 'EXERCISE', 'PSYCHOLOGY') NOT NULL,
    certificate TEXT,
    certification_date DATE,
    experience_years INT,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    Foreign Key (user_id) REFERENCES users (user_id) ON DELETE CASCADE
) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 질병
CREATE TABLE IF NOT EXISTS `diseases` (
    disease_id INT PRIMARY KEY AUTO_INCREMENT,
    disease_name VARCHAR(100) NOT NULL,
    disease_date DATE NOT NULL,
    disease_status ENUM('ACTIVE', 'RECOVERED', 'CHRONIC') NOT NULL
) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 복용중인 약
CREATE TABLE IF NOT EXISTS `medications` (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    disease_id INT,
    medication_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (disease_id) REFERENCES diseases (disease_id)
) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 알러지
CREATE TABLE IF NOT EXISTS `allergies` (
    allergy_id INT AUTO_INCREMENT PRIMARY KEY,
    allergy_name VARCHAR(100) NOT NULL,
    reaction VARCHAR(100) NOT NULL
) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 건강기록
CREATE TABLE IF NOT EXISTS `health_data` (
    health_data_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    height FLOAT NOT NULL,
    weight FLOAT NOT NULL,
    body_fat_percentage FLOAT,
    blood_pressure ENUM('LOW', 'NORMAL', 'HIGH'),
    disease_id INT,
    medication_id INT,
    allergy_id INT,
    smoking BOOLEAN NOT NULL DEFAULT FALSE,
    drinking BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (disease_id) REFERENCES diseases (disease_id),
    FOREIGN KEY (medication_id) REFERENCES medications (medication_id),
    FOREIGN KEY (allergy_id) REFERENCES allergies (allergy_id)
) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 문의
CREATE TABLE IF NOT EXISTS `inquiries` (
    inquiry_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    trainer_id INT,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    response TEXT,
    responsed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_privated BOOLEAN DEFAULT false,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (trainer_id) REFERENCES trainer_profiles (trainer_id)
) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 게시글
CREATE TABLE IF NOT EXISTS `posts` (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 문의 답변
CREATE TABLE IF NOT EXISTS `comments` (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    Foreign Key (post_id) REFERENCES posts (post_id),
    Foreign Key (user_id) REFERENCES users (user_id)
) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 수업 개설
CREATE TABLE IF NOT EXISTS `courses` (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    trainer_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    course_date DATETIME NOT NULL ,
    course_start_time TIME NOT NULL,
    course_end_time TIME NOT NULL,
    course_room VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    category ENUM('SLEEP', 'REHABILITATION', 'EXERCISE', 'PSYCHOLOGY') NOT NULL,
    FOREIGN KEY (trainer_id) REFERENCES trainer_profiles (trainer_id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 회원의 수업 신청
CREATE TABLE IF NOT EXISTS `participations` (
    participation_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses (course_id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS upload_files (
	id BIGINT AUTO_INCREMENT PRIMARY KEY,
    original_name VARCHAR(255) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(100),
    file_size BIGINT NOT NULL,
    target_id BIGINT NOT NULL,
    target_type ENUM('PROFILE', 'POST', 'NOTICE') NOT NULL,
    INDEX idx_target (target_type, target_id)
) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 공지사항
create table if not exists `notices` (
    notice_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    foreign key(user_id) references users (user_id) ON DELETE CASCADE
)CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

SHOW TABLES;

select * from users;

select * from inquiries;
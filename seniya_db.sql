CREATE DATABASE IF NOT EXISTS `seniya_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
;

USE `seniya_db`;

### 시니야 헬스케어 통합 관리 시스템 ###
# : 고령자 건강관리 및 트레이너 기반 교육 서비스 플랫폼 (LMS: Learning Management System)

# Seniya 플랫폼은 고령자를 위한 건강관리 통합 LMS로
# , 트레이너가 제공하는 수업과 건강 정보를 기반으로 개인 맞춤형 학습 및 관리를 지원하는 서비스

-- 사용자
CREATE TABLE IF NOT EXISTS `users` (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    role_id INT NOT NULL,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    # 사용자 연락처 추가
    phone VARCHAR(20) NOT NULL UNIQUE,
    # 필드 설명 필요 (수강권 - 수정 필요 / 정규화) + 구구절절 필요
    -- class_ticket INT NOT NULL DEFAULT 0, 
    # 사용자가 개설된 수업을 보고 신청할 때 사용하는 쿠폰
    # EX) 2025.6.12 수면치료 1번 강의장 - 트레이너 전창현
    #           신청 -> 쿠폰 1개 차감
    # ** 수업 종류에 관계없이 사용 가능 **
    # ** 결제 시스템 도입 **
    # ** 회원만 사용 가능 **
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, # 수정되지않는 데이터
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    Foreign Key (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
)CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
-- --------------------------------------------------------------------
# payments 결제 내역 테이블

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL, -- 결제 금액
    method ENUM('CARD', 'BANK_TRANSFER', 'KAKAO_PAY', 'NAVER_PAY', 'TOSS') NOT NULL, -- 결제 방법
    status ENUM('PENDING', 'SUCCESS', 'FAILED', 'CANCELLED') DEFAULT 'PENDING',
    coupon_count INT NOT NULL DEFAULT 1, -- 구매한 수강권 수량 (1개 이상 반드시 구매)
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, -- 결제 시 생성
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 결제 상태 변경 시 생성
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

# 1) users ↔ payments   1:N (한 명의 사용자 → 여러 결제)
# 2) payments ↔ user_class_passes   1:N (한 결제 → 여러 수강권)
# 3) users ↔ user_class_passes   1:N (한 사용자 → 여러 수강권)
-- --------------------------------------------------------------------
CREATE TABLE passes (
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
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- ---------------------------------------------
DELIMITER $$

CREATE TRIGGER reduce_class_ticket
AFTER UPDATE ON user_class_passes
FOR EACH ROW
BEGIN
    IF OLD.used = FALSE AND NEW.used = TRUE THEN
        UPDATE users
        SET class_ticket = class_ticket - 1
        WHERE user_id = NEW.user_id;
    END IF;
END $$

DELIMITER ;
-- ---------------------------------------------

# 사용자 권한
CREATE TABLE IF NOT EXISTS `roles` (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(255) NOT NULL UNIQUE
) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 트레이너 권한 신청
CREATE TABLE IF NOT EXISTS `trainer_applications` (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    apply_date DATE,
    approval_status ENUM('APPROVE', 'REJECT', 'PENDING', 'QUIT') DEFAULT 'PENDING',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE

# 퇴사자의 경우
) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci

-- 트레이너 프로필
CREATE TABLE IF NOT EXISTS `trainer_profiles` (
    trainer_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    specialty ENUM(
        'SLEEP',
        'REHABILITATION',
        'EXERCISE',
        'PSYCHOLOGY'
    ) NOT NULL,
    -- 수면, 재활, 운동, 심리
    certificate TEXT,
    certification_date DATE, -- 자격증 취득일
    experience_years INT, -- 경력(연차) 추가
    profile_image VARCHAR(255),
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    Foreign Key (user_id) REFERENCES users (user_id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 질병
CREATE TABLE IF NOT EXISTS `diseases` (
    disease_id INT PRIMARY KEY AUTO_INCREMENT,
    disease_name VARCHAR(100) NOT NULL,
    disease_date DATE NOT NULL,
    disease_status ENUM(
        'ACTIVE',
        'RECOVERED',
        'CHRONIC'
    ) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 복용중인 약
CREATE TABLE IF NOT EXISTS `medications` (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    disease_id INT,
    medication_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (disease_id) REFERENCES diseases (disease_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 알러지
CREATE TABLE IF NOT EXISTS `allergies` (
    allergy_id INT AUTO_INCREMENT PRIMARY KEY,
    allergy_name VARCHAR(100) NOT NULL,
    reaction VARCHAR(100) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
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
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 문의
CREATE TABLE IF NOT EXISTS `inquiries` (
    inquiry_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    trainer_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    response TEXT,
    # 수정 일시
    responsed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
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
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

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
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 수업 개설
CREATE TABLE IF NOT EXISTS `class_open_applications` (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    trainer_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    class_date DATETIME NOT NULL,
    class_start_time TIME NOT NULL,
    class_end_time TIME NOT NULL,
    approval_status ENUM(
        'APPROVE',
        'REJECT',
        'PENDING'
    ) DEFAULT 'PENDING',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    category ENUM(
        'SLEEP',
        'REHABILITATION',
        'EXERCISE',
        'PSYCHOLOGY'
    ) NOT NULL,
    FOREIGN KEY (trainer_id) REFERENCES trainer_profiles (trainer_id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 학원 전체 시간표
CREATE TABLE IF NOT EXISTS `timetables` (
    timetable_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    classroom VARCHAR(100) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (application_id) REFERENCES class_open_applications (application_id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 회원의 수업 신청
CREATE TABLE IF NOT EXISTS `class_applications` (
    class_application_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    application_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (application_id) REFERENCES class_open_applications (application_id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

SHOW TABLES;
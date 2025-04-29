CREATE DATABASE IF NOT EXISTS `seniya_db`;

USE `seniya_db`;

-- 유저
CREATE TABLE IF NOT EXISTS `users` (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    name VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role ENUM('trainer', 'user', 'admin') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS `trainer_applications` (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    apply_date DATE,
    approval_status ENUM('approve', 'reject', 'hold') DEFAULT 'hold',
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS `trainer_profiles` (
    trainer_profile_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    specialty ENUM(
        'sleep',
        'rehabilitation',
        'exercise',
        'psychology'
    ) NOT NULL, -- 수면, 재활, 운동, 심리
    certificate VARCHAR(1000),
    profile_image VARCHAR(255),
    description VARCHAR(1000),
    Foreign Key (user_id) REFERENCES users (user_id)
);

-- 건강
CREATE TABLE IF NOT EXISTS `health_data` (
    health_data_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    height FLOAT NOT NULL,
    weight FLOAT NOT NULL,
    body_fat_percentage FLOAT,
    blood_pressure ENUM('Low', 'Normal', 'High'),
    disease_id INT,
    medication_id INT,
    allergy_id INT,
    smoking BOOLEAN NOT NULL,
    drinking BOOLEAN NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (disease_id) REFERENCES diseases (disease_id),
    FOREIGN KEY (medication_id) REFERENCES medications (medication_id),
    FOREIGN KEY (allergy_id) REFERENCES allergies (allergy_id)
);

CREATE TABLE IF NOT EXISTS `diseases` (
    disease_id INT PRIMARY KEY AUTO_INCREMENT,
    disease_name VARCHAR(100) NOT NULL,
    disease_date DATE NOT NULL,
    disease_status ENUM(
        'Active',
        'Recovered',
        'Chronic'
    ) NOT NULL
);

CREATE TABLE IF NOT EXISTS `medications` (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    disease_id INT,
    medication_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (disease_id) REFERENCES diseases (disease_id)
);

CREATE TABLE IF NOT EXISTS `allergies` (
    allergy_id INT AUTO_INCREMENT PRIMARY KEY,
    allergy_name VARCHAR(100) NOT NULL,
    reaction VARCHAR(100) NOT NULL
);

-- 수업
CREATE TABLE IF NOT EXISTS `cares` (
    care_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    trainer_profile_id INT NOT NULL,
    attendance_rate FLOAT NOT NULL DEFAULT 0,
    care_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (trainer_profile_id) REFERENCES trainer_profiles (trainer_profile_id)
);

CREATE TABLE IF NOT EXISTS `care_categories` (
    care_category_id INT PRIMARY KEY AUTO_INCREMENT,
    care_sort VARCHAR(100) NOT NULL,
    care_description VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS `care_details` (
    care_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    care_id INT NOT NULL,
    care_category_id INT NOT NULL,
    attendance BOOLEAN DEFAULT false NOT NULL,
    day_of_week ENUM(
        'mon',
        'tue',
        'wed',
        'thu',
        'fri'
    ) NOT NULL,
    class_hour TIME NOT NULL,
    class_start_time DATETIME NOT NULL,
    class_end_time DATETIME NOT NULL,
    Foreign Key (care_id) REFERENCES cares (care_id),
    Foreign Key (care_category_id) REFERENCES care_categories (care_category_id)
);

-- 게시글
CREATE TABLE IF NOT EXISTS `inquiries` (
    inquiry_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    trainer_profile_id INT NOT NULL,
    inquiry_content VARCHAR(1000) NOT NULL,
    inquiry_response VARCHAR(1000) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    responsed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (trainer_profile_id) REFERENCES trainer_profiles (trainer_profile_id)
);

CREATE TABLE IF NOT EXISTS `posts` (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    post_content VARCHAR(1000) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
);
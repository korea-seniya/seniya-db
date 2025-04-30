INSERT INTO users (username, password, name, email, role)
VALUES
('user1', 'pass123', '홍길동', 'user1@example.com', 'USER'),
('user2', 'pass123', '김민수', 'user2@example.com', 'USER'),
('trainer1', 'pass123', '이영희', 'trainer1@example.com', 'TRAINER'),
('trainer2', 'pass123', '박지훈', 'trainer2@example.com', 'TRAINER'),
('admin1', 'pass123', '관리자', 'admin1@example.com', 'ADMIN');

INSERT INTO trainer_applications (user_id, apply_date, approval_status)
VALUES
(3, '2024-04-01', 'APPROVE'),
(4, '2024-04-05', 'APPROVE');

INSERT INTO trainer_profiles (user_id, specialty, certificate, profile_image, description)
VALUES
(3, 'EXERCISE', '자격증 A', 'profile1.jpg', '운동 전문가입니다.'),
(4, 'PSYCHOLOGY', '자격증 B', 'profile2.jpg', '심리 상담 전문가입니다.');

INSERT INTO diseases (disease_name, disease_date, disease_status)
VALUES
('고혈압', '2023-01-01', 'CHRONIC'),
('당뇨', '2022-06-15', 'CHRONIC'),
('감기', '2024-03-20', 'RECOVERED');

INSERT INTO medications (disease_id, medication_name)
VALUES
(1, '고혈압약 A'),
(2, '당뇨약 B');

INSERT INTO allergies (allergy_name, reaction)
VALUES
('땅콩', '호흡곤란'),
('꽃가루', '기침');

INSERT INTO health_data (
    user_id, height, weight, body_fat_percentage, blood_pressure,
    disease_id, medication_id, allergy_id, smoking, drinking
)
VALUES
(1, 170.5, 65.2, 20.5, 'NORMAL', 1, 1, 1, FALSE, TRUE),
(2, 165.0, 55.0, 22.0, 'HIGH', 2, 2, 2, TRUE, FALSE);

INSERT INTO care_categories (care_sort, care_description)
VALUES
('스트레칭', '기초 유연성 수업'),
('집중력 향상', '두뇌활동 개선 수업'),
('근력 강화', '고령자 근육 운동');

INSERT INTO cares (user_id, trainer_profile_id, attendance_rate, care_name)
VALUES
(1, 1, 85.0, '스트레칭 1반'),
(2, 2, 90.0, '심리 회복 수업');

INSERT INTO care_details (
    care_id, care_category_id, attendance, day_of_week,
    class_hour, class_start_time, class_end_time
)
VALUES
(1, 1, TRUE, 'MON', '01:00:00', '2025-04-01 10:00:00', '2025-04-01 11:00:00'),
(1, 3, TRUE, 'WED', '01:00:00', '2025-04-03 10:00:00', '2025-04-03 11:00:00'),
(2, 2, TRUE, 'FRI', '01:30:00', '2025-04-04 14:00:00', '2025-04-04 15:30:00');

INSERT INTO inquiries (user_id, trainer_profile_id, inquiry_content, inquiry_response)
VALUES
(1, 1, '스트레칭 수업은 몇 시에 시작하나요?', '오전 10시에 시작합니다.'),
(2, 2, '상담은 온라인도 되나요?', '가능합니다.');

INSERT INTO posts (user_id, title, post_content)
VALUES
(1, '건강관리 팁 공유합니다', '매일 걷기 운동이 좋습니다.'),
(2, '수업 후기입니다', '트레이너 선생님 정말 친절하세요.'),
(3, '트레이너 Q&A', '운동 전 스트레칭 방법 알려주세요.');

select * from trainer_applications;
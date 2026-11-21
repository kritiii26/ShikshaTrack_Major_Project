-- ============================================================================
-- SHIKSHATRACK - SAMPLE DATA SEED SCRIPT (DML)
-- ============================================================================
-- Subject: Data Engineering (DE) - Section D & E
-- System: AI-Powered Smart Attendance & School Management System
-- Setting: Government Higher Secondary School, Sehore, Madhya Pradesh
-- Purpose: Populates realistic, coherent Indian rural school data across all
--          core normalized entities to validate queries and constraints.
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. INSTITUTIONAL DATA: SCHOOLS
-- ============================================================================
INSERT INTO schools (id, name, code, address, "contactEmail", "contactPhone", "createdAt", "updatedAt")
VALUES (
    'a0000000-0000-0000-0000-000000000001',
    'Government Higher Secondary School, Sehore',
    'GHSS-001',
    'Rural Education Zone, Block 4, Sehore District, Madhya Pradesh - 466001',
    'admin@shikshatrack.in',
    '+91-9876543210',
    '2026-06-01 08:00:00',
    '2026-06-01 08:00:00'
);

-- ============================================================================
-- 2. USERS: ADMINISTRATOR, TEACHERS & PARENTS
-- ============================================================================
-- Passwords are bcrypt hashes for 'admin123' and 'teacher123'
INSERT INTO users (id, name, email, "passwordHash", role, "schoolId", active, "createdAt", "updatedAt")
VALUES
(
    'b0000000-0000-0000-0000-000000000001',
    'Dr. Harish Chandra (Principal)',
    'admin@shikshatrack.in',
    '$2a$10$wE96c0FvK2oF3zM9FZZOeeT9o9p/cZ08G5kZ8.l7JjO4vF4m2qG9e',
    'ADMIN',
    'a0000000-0000-0000-0000-000000000001',
    true,
    '2026-06-01 08:30:00',
    '2026-06-01 08:30:00'
),
(
    'b0000000-0000-0000-0000-000000000002',
    'Ramesh Kumar (Math Teacher)',
    'ramesh.teacher@shikshatrack.in',
    '$2a$10$wE96c0FvK2oF3zM9FZZOeeT9o9p/cZ08G5kZ8.l7JjO4vF4m2qG9e',
    'TEACHER',
    'a0000000-0000-0000-0000-000000000001',
    true,
    '2026-06-01 09:00:00',
    '2026-06-01 09:00:00'
),
(
    'b0000000-0000-0000-0000-000000000003',
    'Sunita Sharma (Science Teacher)',
    'sunita.sharma@shikshatrack.in',
    '$2a$10$wE96c0FvK2oF3zM9FZZOeeT9o9p/cZ08G5kZ8.l7JjO4vF4m2qG9e',
    'TEACHER',
    'a0000000-0000-0000-0000-000000000001',
    true,
    '2026-06-01 09:15:00',
    '2026-06-01 09:15:00'
),
(
    'b0000000-0000-0000-0000-000000000004',
    'Vikram Patel (Social Studies Teacher)',
    'vikram.patel@shikshatrack.in',
    '$2a$10$wE96c0FvK2oF3zM9FZZOeeT9o9p/cZ08G5kZ8.l7JjO4vF4m2qG9e',
    'TEACHER',
    'a0000000-0000-0000-0000-000000000001',
    true,
    '2026-06-01 09:30:00',
    '2026-06-01 09:30:00'
),
(
    'b0000000-0000-0000-0000-000000000005',
    'Rajesh Sharma (Parent)',
    'rajesh.parent@shikshatrack.in',
    '$2a$10$wE96c0FvK2oF3zM9FZZOeeT9o9p/cZ08G5kZ8.l7JjO4vF4m2qG9e',
    'PARENT',
    'a0000000-0000-0000-0000-000000000001',
    true,
    '2026-06-10 10:00:00',
    '2026-06-10 10:00:00'
);

-- ============================================================================
-- 3. ACADEMIC CLASSES
-- ============================================================================
INSERT INTO classes (id, name, section, "academicYear", "schoolId", "createdAt", "updatedAt")
VALUES
(
    'c0000000-0000-0000-0000-000000000001',
    'Class 8',
    'A',
    '2026-2027',
    'a0000000-0000-0000-0000-000000000001',
    '2026-06-01 10:00:00',
    '2026-06-01 10:00:00'
),
(
    'c0000000-0000-0000-0000-000000000002',
    'Class 8',
    'B',
    '2026-2027',
    'a0000000-0000-0000-0000-000000000001',
    '2026-06-01 10:00:00',
    '2026-06-01 10:00:00'
),
(
    'c0000000-0000-0000-0000-000000000003',
    'Class 9',
    'A',
    '2026-2027',
    'a0000000-0000-0000-0000-000000000001',
    '2026-06-01 10:00:00',
    '2026-06-01 10:00:00'
);

-- ============================================================================
-- 4. TEACHER ASSIGNMENTS (M:N RESOLUTION)
-- ============================================================================
INSERT INTO teacher_assignments (id, "teacherId", "classId", "isClassTeacher", "assignedAt")
VALUES
('t0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', true, '2026-06-02 09:00:00'),
('t0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', false, '2026-06-02 09:00:00'),
('t0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000002', true, '2026-06-02 09:00:00'),
('t0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000003', true, '2026-06-02 09:00:00');

-- ============================================================================
-- 5. STUDENTS REGISTRY
-- ============================================================================
INSERT INTO students (id, name, "admissionNumber", "rollNumber", "classId", "schoolId", "qrToken", "dateOfBirth", gender, "guardianName", "guardianPhone", active)
VALUES
-- Class 8-A Students
('d0000000-0000-0000-0000-000000000001', 'Aarav Sharma', 'ST-2026-001', '1', 'c0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'QR-AARAV-001', '2012-05-15', 'Male', 'Rajesh Sharma', '+91-9876500001', true),
('d0000000-0000-0000-0000-000000000002', 'Diya Patel', 'ST-2026-002', '2', 'c0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'QR-DIYA-002', '2012-08-22', 'Female', 'Mahesh Patel', '+91-9876500002', true),
('d0000000-0000-0000-0000-000000000003', 'Rohan Verma', 'ST-2026-003', '3', 'c0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'QR-ROHAN-003', '2012-03-10', 'Male', 'Sunil Verma', '+91-9876500003', true),
('d0000000-0000-0000-0000-000000000004', 'Ananya Gupta', 'ST-2026-004', '4', 'c0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'QR-ANANYA-004', '2012-11-04', 'Female', 'Deepak Gupta', '+91-9876500004', true),
('d0000000-0000-0000-0000-000000000005', 'Kabir Singh', 'ST-2026-005', '5', 'c0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'QR-KABIR-005', '2012-01-30', 'Male', 'Gurpreet Singh', '+91-9876500005', true),

-- Class 8-B Students
('d0000000-0000-0000-0000-000000000006', 'Meera Joshi', 'ST-2026-006', '1', 'c0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'QR-MEERA-006', '2012-07-19', 'Female', 'Prakash Joshi', '+91-9876500006', true),
('d0000000-0000-0000-0000-000000000007', 'Aditya Yadav', 'ST-2026-007', '2', 'c0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'QR-ADITYA-007', '2012-09-12', 'Male', 'Ram Yadav', '+91-9876500007', true),
('d0000000-0000-0000-0000-000000000008', 'Priya Nair', 'ST-2026-008', '3', 'c0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'QR-PRIYA-008', '2012-04-05', 'Female', 'Suresh Nair', '+91-9876500008', true),

-- Class 9-A Students
('d0000000-0000-0000-0000-000000000009', 'Yash Choudhary', 'ST-2026-009', '1', 'c0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'QR-YASH-009', '2011-06-14', 'Male', 'Dinesh Choudhary', '+91-9876500009', true),
('d0000000-0000-0000-0000-000000000010', 'Sneha Kulkarni', 'ST-2026-010', '2', 'c0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'QR-SNEHA-010', '2011-12-25', 'Female', 'Vijay Kulkarni', '+91-9876500010', true),
('d0000000-0000-0000-0000-000000000011', 'Amit Mishra', 'ST-2026-011', '3', 'c0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'QR-AMIT-011', '2011-02-18', 'Male', 'Brijesh Mishra', '+91-9876500011', true),
('d0000000-0000-0000-0000-000000000012', 'Pooja Sen', 'ST-2026-012', '4', 'c0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'QR-POOJA-012', '2011-10-09', 'Female', 'Kishore Sen', '+91-9876500012', true);

-- ============================================================================
-- 6. PARENTS & PARENT-STUDENT LINKAGES
-- ============================================================================
INSERT INTO parents (id, "schoolId", "userId", "guardianName", relationship, phone, address, occupation, status)
VALUES (
    'e0000000-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000001',
    'b0000000-0000-0000-0000-000000000005',
    'Rajesh Sharma',
    'FATHER',
    '+91-9876500001',
    'Gram Panchayat Road, Village Borda, Sehore',
    'Farmer / Cultivator',
    'ACTIVE'
);

INSERT INTO parent_students (id, "parentId", "studentId", relationship, "isPrimaryContact", "canPickup")
VALUES (
    'ps000000-0000-0000-0000-000000000001',
    'e0000000-0000-0000-0000-000000000001',
    'd0000000-0000-0000-0000-000000000001',
    'FATHER',
    true,
    true
);

-- ============================================================================
-- 7. ATTENDANCE SESSIONS & ATTENDANCE RECORDS
-- ============================================================================
-- Session 1: Class 8-A on 2026-11-17 (Closed)
INSERT INTO attendance_sessions (id, "classId", "teacherId", "sessionDate", status, notes, "createdAt", "closedAt")
VALUES ('f0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000002', '2026-11-17 08:30:00', 'CLOSED', 'Morning regular session', '2026-11-17 08:30:00', '2026-11-17 09:15:00');

-- Session 2: Class 8-A on 2026-11-18 (Closed)
INSERT INTO attendance_sessions (id, "classId", "teacherId", "sessionDate", status, notes, "createdAt", "closedAt")
VALUES ('f0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000002', '2026-11-18 08:30:00', 'CLOSED', 'Morning regular session', '2026-11-18 08:30:00', '2026-11-18 09:10:00');

-- Session 3: Class 8-A on 2026-11-19 (Closed - Today's MDM count)
INSERT INTO attendance_sessions (id, "classId", "teacherId", "sessionDate", status, notes, "createdAt", "closedAt")
VALUES ('f0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000002', '2026-11-19 08:30:00', 'CLOSED', 'Morning regular session', '2026-11-19 08:30:00', '2026-11-19 09:05:00');

-- Session 4: Class 8-B on 2026-11-19 (Closed)
INSERT INTO attendance_sessions (id, "classId", "teacherId", "sessionDate", status, notes, "createdAt", "closedAt")
VALUES ('f0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000003', '2026-11-19 08:30:00', 'CLOSED', 'Class 8B Roll Call', '2026-11-19 08:30:00', '2026-11-19 09:12:00');

-- Session 5: Class 9-A on 2026-11-19 (Closed)
INSERT INTO attendance_sessions (id, "classId", "teacherId", "sessionDate", status, notes, "createdAt", "closedAt")
VALUES ('f0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000004', '2026-11-19 08:30:00', 'CLOSED', 'Class 9A Roll Call', '2026-11-19 08:30:00', '2026-11-19 09:08:00');

-- Attendance Records for Session 1 (Class 8-A, Nov 17)
INSERT INTO attendance_records (id, "sessionId", "studentId", status, method, "markedAt", remarks)
VALUES
('ar000001-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 'PRESENT', 'QR', '2026-11-17 08:35:10', 'Scanned at main gate'),
('ar000001-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 'PRESENT', 'QR', '2026-11-17 08:36:22', 'Scanned at main gate'),
('ar000001-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000003', 'ABSENT', 'MANUAL', '2026-11-17 09:00:00', 'Unexcused absence'),
('ar000001-0000-0000-0000-000000000004', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000004', 'PRESENT', 'QR', '2026-11-17 08:40:05', 'On time'),
('ar000001-0000-0000-0000-000000000005', 'f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000005', 'LATE', 'MANUAL', '2026-11-17 08:55:12', 'Village bus delayed');

-- Attendance Records for Session 2 (Class 8-A, Nov 18)
INSERT INTO attendance_records (id, "sessionId", "studentId", status, method, "markedAt", remarks)
VALUES
('ar000002-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', 'PRESENT', 'QR', '2026-11-18 08:34:45', 'On time'),
('ar000002-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000002', 'PRESENT', 'QR', '2026-11-18 08:35:12', 'On time'),
('ar000002-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'ABSENT', 'MANUAL', '2026-11-18 09:00:00', 'Consecutive absence 2'),
('ar000002-0000-0000-0000-000000000004', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000004', 'PRESENT', 'QR', '2026-11-18 08:37:00', 'On time'),
('ar000002-0000-0000-0000-000000000005', 'f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000005', 'PRESENT', 'OFFLINE_SYNC', '2026-11-18 08:42:30', 'Synced from PWA cache');

-- Attendance Records for Session 3 (Class 8-A, Nov 19 - Today)
INSERT INTO attendance_records (id, "sessionId", "studentId", status, method, "markedAt", remarks)
VALUES
('ar000003-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000001', 'PRESENT', 'QR', '2026-11-19 08:32:10', 'Scanned via camera'),
('ar000003-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000002', 'PRESENT', 'QR', '2026-11-19 08:33:50', 'Scanned via camera'),
('ar000003-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000003', 'ABSENT', 'MANUAL', '2026-11-19 09:00:00', 'Consecutive absence 3 - Truancy Alert'),
('ar000003-0000-0000-0000-000000000004', 'f0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000004', 'PRESENT', 'QR', '2026-11-19 08:36:15', 'Scanned via camera'),
('ar000003-0000-0000-0000-000000000005', 'f0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000005', 'PRESENT', 'QR', '2026-11-19 08:39:20', 'Scanned via camera');

-- Attendance Records for Session 4 (Class 8-B, Nov 19 - Today)
INSERT INTO attendance_records (id, "sessionId", "studentId", status, method, "markedAt", remarks)
VALUES
('ar000004-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000006', 'PRESENT', 'QR', '2026-11-19 08:35:00', 'Present'),
('ar000004-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000007', 'ABSENT', 'MANUAL', '2026-11-19 09:00:00', 'Absent'),
('ar000004-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000008', 'PRESENT', 'QR', '2026-11-19 08:41:00', 'Present');

-- Attendance Records for Session 5 (Class 9-A, Nov 19 - Today)
INSERT INTO attendance_records (id, "sessionId", "studentId", status, method, "markedAt", remarks)
VALUES
('ar000005-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000005', 'd0000000-0000-0000-0000-000000000009', 'PRESENT', 'QR', '2026-11-19 08:31:00', 'Present'),
('ar000005-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000005', 'd0000000-0000-0000-0000-000000000010', 'PRESENT', 'QR', '2026-11-19 08:33:00', 'Present'),
('ar000005-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000005', 'd0000000-0000-0000-0000-000000000011', 'LATE', 'MANUAL', '2026-11-19 08:52:00', 'Tardy 15m'),
('ar000005-0000-0000-0000-000000000004', 'f0000000-0000-0000-0000-000000000005', 'd0000000-0000-0000-0000-000000000012', 'PRESENT', 'QR', '2026-11-19 08:38:00', 'Present');

-- ============================================================================
-- 8. TIMETABLE SCHEDULE ENTRIES
-- ============================================================================
INSERT INTO timetable_entries (id, "schoolId", "classId", "teacherId", subject, "dayOfWeek", "startTime", "endTime", "roomNumber", "academicYear")
VALUES
('tt000001-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000002', 'Mathematics', 'MONDAY', '09:00', '09:45', 'Room 101', '2026-2027'),
('tt000001-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000003', 'Science', 'MONDAY', '09:45', '10:30', 'Room 101', '2026-2027'),
('tt000001-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000004', 'Social Science', 'MONDAY', '10:45', '11:30', 'Room 101', '2026-2027');

-- ============================================================================
-- 9. EXAMINATIONS, SUBJECTS & STUDENT MARKS
-- ============================================================================
-- Examination: Term 1 Midterm Assessment 2026
INSERT INTO examinations (id, "schoolId", name, "examType", "academicYear", "classId", "startDate", "endDate", description)
VALUES (
    'ex000001-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000001',
    'Term 1 Midterm Assessment 2026',
    'MIDTERM',
    '2026-2027',
    'c0000000-0000-0000-0000-000000000001',
    '2026-10-10 09:00:00',
    '2026-10-15 13:00:00',
    'Quarterly evaluation for Class 8-A'
);

-- Exam Subjects: Mathematics & Science
INSERT INTO exam_subjects (id, "examinationId", subject, "maxMarks", "passMarks", "examDate")
VALUES
('es000001-0000-0000-0000-000000000001', 'ex000001-0000-0000-0000-000000000001', 'Mathematics', 100, 33, '2026-10-10 09:00:00'),
('es000001-0000-0000-0000-000000000002', 'ex000001-0000-0000-0000-000000000001', 'Science', 100, 33, '2026-10-12 09:00:00');

-- Exam Marks for Class 8-A Students
INSERT INTO exam_marks (id, "examSubjectId", "studentId", "marksObtained", remarks)
VALUES
-- Mathematics Marks
('em000001-0000-0000-0000-000000000001', 'es000001-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 94.5, 'Outstanding problem solving'),
('em000001-0000-0000-0000-000000000002', 'es000001-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 88.0, 'Very Good'),
('em000001-0000-0000-0000-000000000003', 'es000001-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000003', 28.5, 'Failed - Needs remedial guidance'),
('em000001-0000-0000-0000-000000000004', 'es000001-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000004', 91.0, 'Excellent'),
('em000001-0000-0000-0000-000000000005', 'es000001-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000005', 72.0, 'Good comprehension'),

-- Science Marks
('em000002-0000-0000-0000-000000000001', 'es000001-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', 91.0, 'Distinction'),
('em000002-0000-0000-0000-000000000002', 'es000001-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000002', 85.5, 'Very Good'),
('em000002-0000-0000-0000-000000000003', 'es000001-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 31.0, 'Below passing mark'),
('em000002-0000-0000-0000-000000000004', 'es000001-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000004', 89.0, 'Very Good'),
('em000002-0000-0000-0000-000000000005', 'es000001-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000005', 68.5, 'Satisfactory');

-- ============================================================================
-- 10. FEE STRUCTURES, STUDENT FEES & INSTALLMENTS
-- ============================================================================
-- Annual Tuition Fee Template
INSERT INTO fee_structures (id, "schoolId", "classId", name, "academicYear", category, "totalAmount", frequency, description)
VALUES (
    'fs000001-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'Annual Composite Tuition Fee 2026-2027',
    '2026-2027',
    'TUITION',
    4500.00,
    'ANNUAL',
    'Covers laboratory, library, and instructional expenses'
);

-- Student Fee Accounts for Aarav Sharma (Partial Payment) and Diya Patel (Paid)
INSERT INTO student_fees (id, "schoolId", "studentId", "feeStructureId", "academicYear", "originalAmount", "discountAmount", "scholarshipAmount", "netAmount", "paidAmount", "balanceAmount", status)
VALUES
(
    'sf000001-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000001',
    'd0000000-0000-0000-0000-000000000001',
    'fs000001-0000-0000-0000-000000000001',
    '2026-2027',
    4500.00,
    500.00,
    0.00,
    4000.00,
    2000.00,
    2000.00,
    'PARTIAL'
),
(
    'sf000001-0000-0000-0000-000000000002',
    'a0000000-0000-0000-0000-000000000001',
    'd0000000-0000-0000-0000-000000000002',
    'fs000001-0000-0000-0000-000000000001',
    '2026-2027',
    4500.00,
    0.00,
    0.00,
    4500.00,
    4500.00,
    0.00,
    'PAID'
),
(
    'sf000001-0000-0000-0000-000000000003',
    'a0000000-0000-0000-0000-000000000001',
    'd0000000-0000-0000-0000-000000000003',
    'fs000001-0000-0000-0000-000000000001',
    '2026-2027',
    4500.00,
    0.00,
    0.00,
    4500.00,
    0.00,
    4500.00,
    'OVERDUE'
);

-- Fee Installments for Aarav Sharma (Term 1: 2000 Paid, Term 2: 2000 Pending)
INSERT INTO fee_installments (id, "studentFeeId", "installmentNumber", title, amount, "dueDate", "paidAmount", "balanceAmount", status, "paidAt")
VALUES
(
    'fi000001-0000-0000-0000-000000000001',
    'sf000001-0000-0000-0000-000000000001',
    1,
    'Term 1 Tuition Installment',
    2000.00,
    '2026-07-31 23:59:59',
    2000.00,
    0.00,
    'PAID',
    '2026-07-20 11:30:00'
),
(
    'fi000001-0000-0000-0000-000000000002',
    'sf000001-0000-0000-0000-000000000001',
    2,
    'Term 2 Tuition Installment',
    2000.00,
    '2026-11-30 23:59:59',
    0.00,
    2000.00,
    'PENDING',
    NULL
);

-- Fee Payment Receipt for Aarav Sharma
INSERT INTO fee_payments (id, "schoolId", "studentFeeId", "studentId", "receiptNumber", "amountPaid", "paymentMethod", "transactionReference", remarks, "paymentDate", "recordedById")
VALUES (
    'fp000001-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000001',
    'sf000001-0000-0000-0000-000000000001',
    'd0000000-0000-0000-0000-000000000001',
    'RCP-2026-0001',
    2000.00,
    'UPI',
    'UPI/20260720/99887711',
    'Term 1 Full Payment via PhonePe',
    '2026-07-20 11:30:00',
    'b0000000-0000-0000-0000-000000000001'
);

-- Payment Allocation
INSERT INTO payment_allocations (id, "feePaymentId", "feeInstallmentId", "allocatedAmount", "createdAt")
VALUES (
    'pa000001-0000-0000-0000-000000000001',
    'fp000001-0000-0000-0000-000000000001',
    'fi000001-0000-0000-0000-000000000001',
    2000.00,
    '2026-07-20 11:30:00'
);

-- ============================================================================
-- 11. STUDENT LEAVES & DECISIONS
-- ============================================================================
INSERT INTO student_leaves (id, "schoolId", "studentId", "classId", "appliedById", "leaveType", "startDate", "endDate", "totalDays", reason, status, "reviewRemarks", "reviewedAt", "reviewedById")
VALUES (
    'sl000001-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000001',
    'd0000000-0000-0000-0000-000000000002',
    'c0000000-0000-0000-0000-000000000001',
    'b0000000-0000-0000-0000-000000000005',
    'SICK',
    '2026-11-20 00:00:00',
    '2026-11-21 23:59:59',
    2,
    'Viral fever and doctor-recommended rest',
    'APPROVED',
    'Medical prescription verified. Leave granted.',
    '2026-11-19 14:00:00',
    'b0000000-0000-0000-0000-000000000002'
);

INSERT INTO student_leave_decisions (id, "leaveId", "reviewerId", action, remarks, "decidedAt")
VALUES (
    'sld00001-0000-0000-0000-000000000001',
    'sl000001-0000-0000-0000-000000000001',
    'b0000000-0000-0000-0000-000000000002',
    'APPROVED',
    'Approved by Class Teacher Ramesh Kumar',
    '2026-11-19 14:00:00'
);

-- ============================================================================
-- 12. AUDIT LOG RECORD
-- ============================================================================
INSERT INTO audit_logs (id, "actorId", action, "entityType", "entityId", "previousValue", "newValue", reason, "createdAt")
VALUES (
    'al000001-0000-0000-0000-000000000001',
    'b0000000-0000-0000-0000-000000000002',
    'ATTENDANCE_CORRECTED',
    'AttendanceRecord',
    'ar000001-0000-0000-0000-000000000005',
    '{"status": "ABSENT"}',
    '{"status": "LATE", "remarks": "Village bus delayed"}',
    'Student arrived 20 minutes late due to district bus breakdown',
    '2026-11-17 09:20:00'
);

-- ============================================================================
-- 13. SCHOOL ANNOUNCEMENT & READ LOG
-- ============================================================================
INSERT INTO school_announcements (id, "schoolId", title, content, category, priority, "targetAudience", "authorId", "isPublished", "publishedAt")
VALUES (
    'sa000001-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000001',
    'District Mid-Day Meal Nutrition Audit',
    'District education officers will visit on Friday for physical ration verification. Ensure attendance logs are submitted by 10 AM.',
    'GENERAL',
    'HIGH',
    'TEACHERS',
    'b0000000-0000-0000-0000-000000000001',
    true,
    '2026-11-18 10:00:00'
);

INSERT INTO announcement_reads (id, "announcementId", "userId", "readAt")
VALUES (
    'ar_read01-0000-0000-0000-000000000001',
    'sa000001-0000-0000-0000-000000000001',
    'b0000000-0000-0000-0000-000000000002',
    '2026-11-18 10:15:00'
);

COMMIT;

-- ============================================================================
-- SAMPLE DATA POPULATION COMPLETE
-- ============================================================================

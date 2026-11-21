-- ============================================================================
-- SHIKSHATRACK - 14 PROJECT-SPECIFIC SQL QUERIES & OPERATIONS
-- ============================================================================
-- Subject: Data Engineering (DE) - Section E
-- System: AI-Powered Smart Attendance & School Management System
-- Database Engine: PostgreSQL 18
-- Concepts Demonstrated:
--   1. INSERT, UPDATE, DELETE (Data Manipulation Language)
--   2. SELECT with complex filtering and multi-column sorting
--   3. Aggregate Functions (COUNT, SUM, AVG, MIN, MAX, ROUND)
--   4. GROUP BY with HAVING clause for statutory threshold filtering
--   5. Multi-Table INNER JOINs and LEFT JOINs with COALESCE
--   6. Subqueries (scalar, correlated, and NOT EXISTS / NOT IN)
--   7. Common Table Expressions (CTEs) for multi-stage computation
--   8. Window Functions (DENSE_RANK, LAG) for analytics and truancy
-- ============================================================================

\echo '========================================================================'
\echo 'SHIKSHATRACK DATA ENGINEERING: 14 PROJECT-SPECIFIC BUSINESS QUERIES'
\echo '========================================================================'

-- ----------------------------------------------------------------------------
-- QUERY 1: INSERT OPERATION (Real-Time Cryptographic QR Attendance Check-In)
-- Business Use Case: When a student presents their ID card to the teacher's
-- camera viewfinder, the backend resolves the QR token to the student ID
-- and inserts a verified 'PRESENT' record for today's active session.
-- ----------------------------------------------------------------------------
\echo '\n--- [QUERY 1]: Real-Time Cryptographic QR Code Attendance Mark Insertion ---'

INSERT INTO attendance_records (
    id,
    "sessionId",
    "studentId",
    status,
    method,
    "markedAt",
    remarks
)
VALUES (
    gen_random_uuid(),
    'f0000000-0000-0000-0000-000000000003', -- Class 8-A Session (Nov 19)
    'd0000000-0000-0000-0000-000000000001', -- Aarav Sharma
    'PRESENT',
    'QR',
    CURRENT_TIMESTAMP,
    'Scanned at classroom door via mobile camera'
)
ON CONFLICT ("sessionId", "studentId") 
DO UPDATE SET 
    status = EXCLUDED.status,
    method = EXCLUDED.method,
    "markedAt" = EXCLUDED."markedAt",
    remarks = EXCLUDED.remarks
RETURNING id, "sessionId", "studentId", status, method, "markedAt";

-- ----------------------------------------------------------------------------
-- QUERY 2: UPDATE OPERATION (Administrative Attendance Correction with Reason)
-- Business Use Case: A teacher mistakenly marks a student absent who arrived late
-- due to district transport failure. Principal/Teacher updates status to 'LATE'.
-- ----------------------------------------------------------------------------
\echo '\n--- [QUERY 2]: Administrative Attendance Status Correction ---'

UPDATE attendance_records
SET 
    status = 'LATE',
    remarks = 'Arrived 20 mins late due to rural road repair; verified by principal',
    "updatedAt" = CURRENT_TIMESTAMP
WHERE 
    "sessionId" = 'f0000000-0000-0000-0000-000000000001'
    AND "studentId" = 'd0000000-0000-0000-0000-000000000005'
RETURNING id, "sessionId", "studentId", status, remarks, "updatedAt";

-- ----------------------------------------------------------------------------
-- QUERY 3: DELETE OPERATION (Revocation of Temporary Schedule Entry)
-- Business Use Case: Cancel an invalid or temporary substitute timetable period.
-- ----------------------------------------------------------------------------
\echo '\n--- [QUERY 3]: Transactional Deletion of Cancelled Timetable Period ---'

DELETE FROM timetable_entries
WHERE 
    "classId" = 'c0000000-0000-0000-0000-000000000001'
    AND "dayOfWeek" = 'MONDAY'
    AND "startTime" = '10:45'
RETURNING id, subject, "dayOfWeek", "startTime", "endTime";

-- ----------------------------------------------------------------------------
-- QUERY 4: SELECT WITH FILTERING & SORTING (Active Class Roster with Contacts)
-- Business Use Case: Generate daily physical attendance sheet sorted by roll no.
-- ----------------------------------------------------------------------------
\echo '\n--- [QUERY 4]: Class Roster with Guardian Contact Details Sorted by Roll No ---'

SELECT 
    s."rollNumber" AS "Roll",
    s."admissionNumber" AS "Admission No",
    s.name AS "Student Name",
    s.gender AS "Gender",
    s."guardianName" AS "Guardian Name",
    s."guardianPhone" AS "Emergency Contact"
FROM students s
WHERE 
    s."classId" = 'c0000000-0000-0000-0000-000000000001'
    AND s.active = true
ORDER BY CAST(s."rollNumber" AS INT) ASC;

-- ----------------------------------------------------------------------------
-- QUERY 5: AGGREGATE FUNCTIONS (Institutional Examination Performance Summary)
-- Business Use Case: Comprehensive exam metrics: Total assessed, pass rate, 
-- average marks, highest, and lowest scores per subject.
-- ----------------------------------------------------------------------------
\echo '\n--- [QUERY 5]: Examination Subject Performance Aggregates (COUNT, AVG, MIN, MAX) ---'

SELECT 
    es.subject AS "Subject",
    es."maxMarks" AS "Max Marks",
    COUNT(em.id) AS "Students Evaluated",
    ROUND(AVG(em."marksObtained")::numeric, 2) AS "Average Marks",
    MIN(em."marksObtained") AS "Lowest Score",
    MAX(em."marksObtained") AS "Highest Score",
    COUNT(CASE WHEN em."marksObtained" >= es."passMarks" THEN 1 END) AS "Passed Count",
    ROUND((COUNT(CASE WHEN em."marksObtained" >= es."passMarks" THEN 1 END)::numeric / COUNT(em.id) * 100), 1) AS "Pass %"
FROM exam_subjects es
INNER JOIN exam_marks em ON es.id = em."examSubjectId"
WHERE es."examinationId" = 'ex000001-0000-0000-0000-000000000001'
GROUP BY es.id, es.subject, es."maxMarks"
ORDER BY es.subject ASC;

-- ----------------------------------------------------------------------------
-- QUERY 6: GROUP BY & HAVING (Classes Below Statutory 75% Attendance Threshold)
-- Business Use Case: Under the Right to Education (RTE) Act, schools must track
-- cohorts failing the mandatory 75% minimum attendance benchmark.
-- ----------------------------------------------------------------------------
\echo '\n--- [QUERY 6]: Classes Falling Below Statutory 75% Attendance Benchmark ---'

SELECT 
    c.name || ' - ' || c.section AS "Class Section",
    c."academicYear" AS "Session",
    COUNT(ar.id) AS "Total Marks Recorded",
    COUNT(CASE WHEN ar.status IN ('PRESENT', 'LATE') THEN 1 END) AS "Attended Count",
    COUNT(CASE WHEN ar.status = 'ABSENT' THEN 1 END) AS "Absent Count",
    ROUND((COUNT(CASE WHEN ar.status IN ('PRESENT', 'LATE') THEN 1 END)::numeric / COUNT(ar.id) * 100), 2) AS "Attendance Rate %"
FROM classes c
INNER JOIN attendance_sessions ses ON c.id = ses."classId"
INNER JOIN attendance_records ar ON ses.id = ar."sessionId"
GROUP BY c.id, c.name, c.section, c."academicYear"
HAVING ROUND((COUNT(CASE WHEN ar.status IN ('PRESENT', 'LATE') THEN 1 END)::numeric / COUNT(ar.id) * 100), 2) < 75.00
ORDER BY "Attendance Rate %" ASC;

-- ----------------------------------------------------------------------------
-- QUERY 7: MULTI-TABLE INNER JOIN (Daily Classroom Attendance Register)
-- Business Use Case: Full operational roll linking student, class, session, 
-- recording teacher, and verification method.
-- ----------------------------------------------------------------------------
\echo '\n--- [QUERY 7]: Multi-Table INNER JOIN Classroom Attendance Ledger ---'

SELECT 
    DATE(ses."sessionDate") AS "Date",
    c.name || ' - ' || c.section AS "Class",
    s."rollNumber" AS "Roll",
    s.name AS "Student Name",
    ar.status AS "Status",
    ar.method AS "Verification Method",
    TO_CHAR(ar."markedAt", 'HH24:MI:SS') AS "Time Marked",
    u.name AS "Recording Teacher"
FROM attendance_records ar
INNER JOIN students s ON ar."studentId" = s.id
INNER JOIN attendance_sessions ses ON ar."sessionId" = ses.id
INNER JOIN classes c ON ses."classId" = c.id
INNER JOIN users u ON ses."teacherId" = u.id
WHERE 
    DATE(ses."sessionDate") = '2026-11-19'
    AND c.id = 'c0000000-0000-0000-0000-000000000001'
ORDER BY CAST(s."rollNumber" AS INT) ASC;

-- ----------------------------------------------------------------------------
-- QUERY 8: MULTI-TABLE LEFT JOIN (Comprehensive Student 360° Profile)
-- Business Use Case: Consolidated dashboard view for student progress meetings:
-- Demographics, primary guardian, fee arrears balance, and attendance rate.
-- ----------------------------------------------------------------------------
\echo '\n--- [QUERY 8]: Multi-Table LEFT JOIN Student 360 Degree Administrative Profile ---'

SELECT 
    s."admissionNumber" AS "Admission No",
    s.name AS "Student Name",
    c.name || '-' || c.section AS "Class",
    COALESCE(p."guardianName", s."guardianName", 'N/A') AS "Primary Guardian",
    COALESCE(p.phone, s."guardianPhone", 'N/A') AS "Contact No",
    COALESCE(SUM(sf."balanceAmount"), 0.00) AS "Total Fee Balance (Rs)",
    ROUND(
        (COUNT(CASE WHEN ar.status IN ('PRESENT', 'LATE') THEN 1 END)::numeric / 
         NULLIF(COUNT(ar.id), 0) * 100), 1
    ) AS "Cumulative Attendance %"
FROM students s
INNER JOIN classes c ON s."classId" = c.id
LEFT JOIN parent_students ps ON s.id = ps."studentId" AND ps."isPrimaryContact" = true
LEFT JOIN parents p ON ps."parentId" = p.id
LEFT JOIN student_fees sf ON s.id = sf."studentId"
LEFT JOIN attendance_records ar ON s.id = ar."studentId"
WHERE s."classId" = 'c0000000-0000-0000-0000-000000000001'
GROUP BY s.id, s."admissionNumber", s.name, c.name, c.section, p."guardianName", s."guardianName", p.phone, s."guardianPhone"
ORDER BY CAST(s."rollNumber" AS INT) ASC;

-- ----------------------------------------------------------------------------
-- QUERY 9: SUBQUERY IN WHERE CLAUSE (Punctuality Honors List - 100% Attendance)
-- Business Use Case: Identify exemplary students with zero recorded absences 
-- and zero late marks throughout the academic term.
-- ----------------------------------------------------------------------------
\echo '\n--- [QUERY 9]: Punctuality Honors List (Subquery with NOT IN) ---'

SELECT 
    s."admissionNumber" AS "Admission No",
    s.name AS "Student Name",
    c.name || ' - ' || c.section AS "Class",
    COUNT(ar.id) AS "Total Sessions Attended"
FROM students s
INNER JOIN classes c ON s."classId" = c.id
INNER JOIN attendance_records ar ON s.id = ar."studentId"
WHERE 
    s.active = true
    AND s.id NOT IN (
        -- Subquery: Select any student who has at least one ABSENT or LATE record
        SELECT DISTINCT ar_bad."studentId"
        FROM attendance_records ar_bad
        WHERE ar_bad.status IN ('ABSENT', 'LATE')
    )
GROUP BY s.id, s."admissionNumber", s.name, c.name, c.section
ORDER BY s.name ASC;

-- ----------------------------------------------------------------------------
-- QUERY 10: COMMON TABLE EXPRESSION (CTE) (Mid-Day Meal Physical Headcount)
-- Business Use Case: District Education Officer needs daily verified physical 
-- headcount to allocate Mid-Day Meal grain rations (100g wheat/rice per child).
-- ----------------------------------------------------------------------------
\echo '\n--- [QUERY 10]: Mid-Day Meal (MDM) Statutory Ration Headcount (CTE) ---'

WITH DailyPresentRoster AS (
    SELECT 
        c.id AS class_id,
        c.name || ' - ' || c.section AS class_name,
        COUNT(DISTINCT s.id) AS enrolled_count,
        COUNT(DISTINCT CASE WHEN ar.status = 'PRESENT' THEN ar."studentId" END) AS present_count,
        COUNT(DISTINCT CASE WHEN ar.status = 'LATE' THEN ar."studentId" END) AS late_count
    FROM classes c
    INNER JOIN students s ON c.id = s."classId"
    LEFT JOIN attendance_sessions ses ON c.id = ses."classId" AND DATE(ses."sessionDate") = '2026-11-19'
    LEFT JOIN attendance_records ar ON ses.id = ar."sessionId" AND s.id = ar."studentId"
    WHERE c."schoolId" = 'a0000000-0000-0000-0000-000000000001'
    GROUP BY c.id, c.name, c.section
)
SELECT 
    class_name AS "Class Cohort",
    enrolled_count AS "Enrolled Strength",
    (present_count + late_count) AS "Meal Eligible Headcount",
    ROUND(((present_count + late_count)::numeric / enrolled_count * 100), 1) AS "Participation %",
    ((present_count + late_count) * 0.100) AS "Daily Grain Quota (Kg Wheat/Rice)",
    ((present_count + late_count) * 5.45) AS "Cooking Conversion Subsidy (Rs)"
FROM DailyPresentRoster
ORDER BY class_name ASC;

-- ----------------------------------------------------------------------------
-- QUERY 11: WINDOW FUNCTION - DENSE_RANK (Class Subject Merit Leaderboard)
-- Business Use Case: Generate rank list of top academic performers per subject
-- without row-skipping in case of ties.
-- ----------------------------------------------------------------------------
\echo '\n--- [QUERY 11]: Subject Merit Leaderboard using DENSE_RANK() Window Function ---'

SELECT 
    es.subject AS "Subject",
    DENSE_RANK() OVER (
        PARTITION BY es.subject 
        ORDER BY em."marksObtained" DESC
    ) AS "Rank",
    s.name AS "Student Name",
    s."admissionNumber" AS "Admission No",
    em."marksObtained" AS "Score",
    es."maxMarks" AS "Out Of",
    ROUND((em."marksObtained" / es."maxMarks" * 100)::numeric, 1) AS "Percentage %",
    em.remarks AS "Teacher Remarks"
FROM exam_marks em
INNER JOIN exam_subjects es ON em."examSubjectId" = es.id
INNER JOIN students s ON em."studentId" = s.id
WHERE es."examinationId" = 'ex000001-0000-0000-0000-000000000001'
ORDER BY es.subject ASC, "Rank" ASC;

-- ----------------------------------------------------------------------------
-- QUERY 12: FINANCIAL RECONCILIATION AGGREGATION (Fee Collection by Class)
-- Business Use Case: Financial oversight report detailing gross fee assessment,
-- concessions, net receivable, total collections, and outstanding dues.
-- ----------------------------------------------------------------------------
\echo '\n--- [QUERY 12]: Financial Ledger Reconciliation & Balance Summary ---'

SELECT 
    c.name || ' - ' || c.section AS "Class Section",
    COUNT(sf.id) AS "Assessed Accounts",
    TO_CHAR(SUM(sf."originalAmount"), 'FM9,99,990.00') AS "Gross Assessed (Rs)",
    TO_CHAR(SUM(sf."discountAmount"), 'FM9,99,990.00') AS "Concessions (Rs)",
    TO_CHAR(SUM(sf."netAmount"), 'FM9,99,990.00') AS "Net Receivable (Rs)",
    TO_CHAR(SUM(sf."paidAmount"), 'FM9,99,990.00') AS "Collected to Date (Rs)",
    TO_CHAR(SUM(sf."balanceAmount"), 'FM9,99,990.00') AS "Outstanding Balance (Rs)",
    ROUND((SUM(sf."paidAmount")::numeric / NULLIF(SUM(sf."netAmount"), 0) * 100), 1) AS "Recovery Efficiency %"
FROM student_fees sf
INNER JOIN students s ON sf."studentId" = s.id
INNER JOIN classes c ON s."classId" = c.id
WHERE sf."academicYear" = '2026-2027'
GROUP BY c.id, c.name, c.section
ORDER BY c.name ASC;

-- ----------------------------------------------------------------------------
-- QUERY 13: AUDIT TRAIL QUERY (Audit Log Security Inspection)
-- Business Use Case: Scrutinize administrative modifications to attendance marks
-- to maintain regulatory compliance and prevent unauthorized tampering.
-- ----------------------------------------------------------------------------
\echo '\n--- [QUERY 13]: Audit Log Security Inspection of Manual Attendance Modifications ---'

SELECT 
    al."createdAt" AS "Timestamp",
    u.name AS "Actor Name",
    u.role AS "Actor Role",
    al.action AS "Action Executed",
    al."entityType" AS "Target Entity",
    al."previousValue" AS "Previous State",
    al."newValue" AS "Updated State",
    al.reason AS "Justification Provided"
FROM audit_logs al
LEFT JOIN users u ON al."actorId" = u.id
ORDER BY al."createdAt" DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- QUERY 14: ADVANCED WINDOW FUNCTION (Truancy Detection - 3 Consecutive Absences)
-- Business Use Case: Detect chronic absenteeism early using the LAG() window
-- function to detect students absent across consecutive school calendar days.
-- ----------------------------------------------------------------------------
\echo '\n--- [QUERY 14]: Truancy Detection Engine (LAG Window Function for Consecutive Absences) ---'

WITH ChronologicalAttendance AS (
    SELECT 
        s.id AS student_id,
        s.name AS student_name,
        c.name || ' - ' || c.section AS class_name,
        DATE(ses."sessionDate") AS session_date,
        ar.status AS current_status,
        LAG(ar.status, 1) OVER (
            PARTITION BY s.id 
            ORDER BY ses."sessionDate" ASC
        ) AS prev_status_1,
        LAG(ar.status, 2) OVER (
            PARTITION BY s.id 
            ORDER BY ses."sessionDate" ASC
        ) AS prev_status_2
    FROM attendance_records ar
    INNER JOIN attendance_sessions ses ON ar."sessionId" = ses.id
    INNER JOIN students s ON ar."studentId" = s.id
    INNER JOIN classes c ON s."classId" = c.id
)
SELECT 
    student_name AS "At-Risk Student",
    class_name AS "Class",
    session_date AS "Latest Absence Date",
    current_status AS "Day 3 Status",
    prev_status_1 AS "Day 2 Status",
    prev_status_2 AS "Day 1 Status",
    'CRITICAL: 3 Consecutive Absences - Truancy Intervention Required' AS "Alert Severity"
FROM ChronologicalAttendance
WHERE 
    current_status = 'ABSENT' 
    AND prev_status_1 = 'ABSENT' 
    AND prev_status_2 = 'ABSENT';

\echo '\n========================================================================'
\echo 'END OF SHIKSHATRACK DATA ENGINEERING QUERY SUITE (14/14 EXECUTED)'
\echo '========================================================================'

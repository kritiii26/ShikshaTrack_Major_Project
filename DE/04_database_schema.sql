-- ============================================================================
-- SHIKSHATRACK - POSTGRESQL 18 PRODUCTION DATABASE SCHEMA (DDL)
-- ============================================================================
-- Subject: Data Engineering (DE) - Section D
-- System: AI-Powered Smart Attendance & School Management System
-- Schema Target: PostgreSQL 14 / 15 / 16 / 17 / 18
-- Normalization Form: Third Normal Form (3NF) / Boyce-Codd Normal Form (BCNF)
-- Total Entities: 39 Tables
-- ============================================================================

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

-- Enable UUID Extension if not already active
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. DROP EXISTING OBJECTS (CLEAN RE-RUN CAPABILITY)
-- ============================================================================
DROP TABLE IF EXISTS financial_year_archives CASCADE;
DROP TABLE IF EXISTS academic_intervention_notes CASCADE;
DROP TABLE IF EXISTS academic_interventions CASCADE;
DROP TABLE IF EXISTS certificate_verification_logs CASCADE;
DROP TABLE IF EXISTS issued_certificates CASCADE;
DROP TABLE IF EXISTS certificate_templates CASCADE;
DROP TABLE IF EXISTS document_versions CASCADE;
DROP TABLE IF EXISTS student_documents CASCADE;
DROP TABLE IF EXISTS sync_operations CASCADE;
DROP TABLE IF EXISTS communication_messages CASCADE;
DROP TABLE IF EXISTS announcement_reads CASCADE;
DROP TABLE IF EXISTS school_announcements CASCADE;
DROP TABLE IF EXISTS parent_students CASCADE;
DROP TABLE IF EXISTS parents CASCADE;
DROP TABLE IF EXISTS payment_reversals CASCADE;
DROP TABLE IF EXISTS fee_discounts CASCADE;
DROP TABLE IF EXISTS payment_allocations CASCADE;
DROP TABLE IF EXISTS fee_payments CASCADE;
DROP TABLE IF EXISTS fee_installments CASCADE;
DROP TABLE IF EXISTS student_fees CASCADE;
DROP TABLE IF EXISTS fee_structures CASCADE;
DROP TABLE IF EXISTS incident_action_history CASCADE;
DROP TABLE IF EXISTS student_incidents CASCADE;
DROP TABLE IF EXISTS student_leave_decisions CASCADE;
DROP TABLE IF EXISTS student_leaves CASCADE;
DROP TABLE IF EXISTS exam_marks CASCADE;
DROP TABLE IF EXISTS exam_subjects CASCADE;
DROP TABLE IF EXISTS examinations CASCADE;
DROP TABLE IF EXISTS academic_events CASCADE;
DROP TABLE IF EXISTS timetable_entries CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS attendance_records CASCADE;
DROP TABLE IF EXISTS attendance_sessions CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS teacher_assignments CASCADE;
DROP TABLE IF EXISTS classes CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS schools CASCADE;

-- Drop Custom Enums
DROP TYPE IF EXISTS "Role" CASCADE;
DROP TYPE IF EXISTS "NotificationCategory" CASCADE;
DROP TYPE IF EXISTS "SessionStatus" CASCADE;
DROP TYPE IF EXISTS "AttendanceStatus" CASCADE;
DROP TYPE IF EXISTS "AttendanceMethod" CASCADE;
DROP TYPE IF EXISTS "DayOfWeek" CASCADE;
DROP TYPE IF EXISTS "AcademicEventType" CASCADE;
DROP TYPE IF EXISTS "ExamType" CASCADE;
DROP TYPE IF EXISTS "LeaveType" CASCADE;
DROP TYPE IF EXISTS "LeaveStatus" CASCADE;
DROP TYPE IF EXISTS "IncidentCategory" CASCADE;
DROP TYPE IF EXISTS "IncidentSeverity" CASCADE;
DROP TYPE IF EXISTS "IncidentStatus" CASCADE;
DROP TYPE IF EXISTS "FeeCategory" CASCADE;
DROP TYPE IF EXISTS "PaymentMethod" CASCADE;
DROP TYPE IF EXISTS "PaymentStatus" CASCADE;
DROP TYPE IF EXISTS "DiscountType" CASCADE;
DROP TYPE IF EXISTS "GuardianRelationship" CASCADE;
DROP TYPE IF EXISTS "ParentAccountStatus" CASCADE;
DROP TYPE IF EXISTS "AnnouncementCategory" CASCADE;
DROP TYPE IF EXISTS "AudienceType" CASCADE;
DROP TYPE IF EXISTS "MessageCategory" CASCADE;
DROP TYPE IF EXISTS "SyncOperationStatus" CASCADE;
DROP TYPE IF EXISTS "DocumentCategory" CASCADE;
DROP TYPE IF EXISTS "DocumentVerificationStatus" CASCADE;
DROP TYPE IF EXISTS "CertificateType" CASCADE;
DROP TYPE IF EXISTS "CertificateStatus" CASCADE;
DROP TYPE IF EXISTS "InterventionType" CASCADE;
DROP TYPE IF EXISTS "InterventionSeverity" CASCADE;
DROP TYPE IF EXISTS "InterventionStatus" CASCADE;

-- ============================================================================
-- 2. ENUMERATED TYPES (ENUMS)
-- ============================================================================
CREATE TYPE "Role" AS ENUM ('ADMIN', 'TEACHER', 'PARENT');
CREATE TYPE "NotificationCategory" AS ENUM ('INFO', 'WARNING', 'URGENT', 'SUCCESS');
CREATE TYPE "SessionStatus" AS ENUM ('OPEN', 'CLOSED');
CREATE TYPE "AttendanceStatus" AS ENUM ('PRESENT', 'ABSENT', 'LATE');
CREATE TYPE "AttendanceMethod" AS ENUM ('QR', 'MANUAL', 'OFFLINE_SYNC');
CREATE TYPE "DayOfWeek" AS ENUM ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY');
CREATE TYPE "AcademicEventType" AS ENUM ('HOLIDAY', 'EXAM', 'EVENT', 'ACADEMIC');
CREATE TYPE "ExamType" AS ENUM ('UNIT_TEST', 'MIDTERM', 'FINAL', 'PRACTICAL', 'ASSESSMENT');
CREATE TYPE "LeaveType" AS ENUM ('SICK', 'FAMILY', 'PERSONAL', 'EMERGENCY', 'OTHER');
CREATE TYPE "LeaveStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED');
CREATE TYPE "IncidentCategory" AS ENUM ('BEHAVIOUR', 'ATTENDANCE', 'ACADEMIC', 'SAFETY', 'OTHER');
CREATE TYPE "IncidentSeverity" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');
CREATE TYPE "IncidentStatus" AS ENUM ('REPORTED', 'UNDER_INVESTIGATION', 'RESOLVED', 'CLOSED');
CREATE TYPE "FeeCategory" AS ENUM ('TUITION', 'TRANSPORT', 'EXAMINATION', 'LIBRARY', 'DEVELOPMENT', 'OTHER');
CREATE TYPE "PaymentMethod" AS ENUM ('CASH', 'BANK_TRANSFER', 'UPI', 'CHEQUE', 'OTHER');
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'PARTIAL', 'PAID', 'OVERDUE');
CREATE TYPE "DiscountType" AS ENUM ('PERCENTAGE', 'FIXED_AMOUNT');
CREATE TYPE "GuardianRelationship" AS ENUM ('FATHER', 'MOTHER', 'GUARDIAN', 'OTHER');
CREATE TYPE "ParentAccountStatus" AS ENUM ('ACTIVE', 'INVITED', 'INACTIVE');
CREATE TYPE "AnnouncementCategory" AS ENUM ('GENERAL', 'ACADEMIC', 'ATTENDANCE', 'FEES', 'EVENTS', 'URGENT');
CREATE TYPE "AudienceType" AS ENUM ('ALL', 'PARENTS', 'TEACHERS', 'CLASS');
CREATE TYPE "MessageCategory" AS ENUM ('GENERAL', 'ACADEMIC', 'ATTENDANCE', 'FEES', 'URGENT');
CREATE TYPE "SyncOperationStatus" AS ENUM ('PENDING', 'SYNCING', 'SYNCED', 'FAILED', 'CONFLICT');
CREATE TYPE "DocumentCategory" AS ENUM ('BIRTH_CERTIFICATE', 'TRANSFER_CERTIFICATE', 'IDENTITY_PROOF', 'ADDRESS_PROOF', 'ACADEMIC_RECORD', 'MEDICAL_RECORD', 'OTHER');
CREATE TYPE "DocumentVerificationStatus" AS ENUM ('PENDING', 'VERIFIED', 'REJECTED', 'EXPIRED');
CREATE TYPE "CertificateType" AS ENUM ('BONAFIDE', 'TRANSFER', 'CHARACTER', 'STUDY', 'FEE_CLEARANCE', 'ACHIEVEMENT', 'OTHER');
CREATE TYPE "CertificateStatus" AS ENUM ('ACTIVE', 'REVOKED', 'EXPIRED');
CREATE TYPE "InterventionType" AS ENUM ('ACADEMIC_DEFICIT', 'EXAM_DECLINE', 'ATTENDANCE_CORRELATION', 'BEHAVIORAL', 'SUBJECT_SPECIFIC', 'OTHER');
CREATE TYPE "InterventionSeverity" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');
CREATE TYPE "InterventionStatus" AS ENUM ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'ESCALATED', 'CANCELLED');

-- ============================================================================
-- 3. CORE INSTITUTIONAL SCHEMA (SCHOOLS, USERS, CLASSES, ASSIGNMENTS)
-- ============================================================================

-- Table: schools
CREATE TABLE schools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    address TEXT NOT NULL,
    "contactEmail" VARCHAR(255),
    "contactPhone" VARCHAR(50),
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    "passwordHash" VARCHAR(255) NOT NULL,
    role "Role" NOT NULL DEFAULT 'TEACHER',
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    active BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_users_school ON users("schoolId");
CREATE INDEX idx_users_email ON users(email);

-- Table: classes
CREATE TABLE classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    section VARCHAR(20) NOT NULL,
    "academicYear" VARCHAR(50) NOT NULL,
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_class_school_name_sec_year UNIQUE ("schoolId", name, section, "academicYear")
);
CREATE INDEX idx_classes_school ON classes("schoolId");

-- Table: teacher_assignments (M:N Associative Junction Table)
CREATE TABLE teacher_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "teacherId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    "classId" UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    "isClassTeacher" BOOLEAN NOT NULL DEFAULT false,
    "assignedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_teacher_class UNIQUE ("teacherId", "classId")
);
CREATE INDEX idx_ta_teacher ON teacher_assignments("teacherId");
CREATE INDEX idx_ta_class ON teacher_assignments("classId");

-- ============================================================================
-- 4. STUDENT REGISTRY & DEMOGRAPHICS
-- ============================================================================

-- Table: students
CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    "admissionNumber" VARCHAR(100) NOT NULL,
    "rollNumber" VARCHAR(50),
    "classId" UUID NOT NULL REFERENCES classes(id) ON DELETE RESTRICT,
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "qrToken" VARCHAR(255) NOT NULL UNIQUE DEFAULT gen_random_uuid()::text,
    "dateOfBirth" TIMESTAMP,
    gender VARCHAR(50),
    "guardianName" VARCHAR(255),
    "guardianPhone" VARCHAR(50),
    active BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_student_school_admission UNIQUE ("schoolId", "admissionNumber")
);
CREATE INDEX idx_students_class ON students("classId");
CREATE INDEX idx_students_qr ON students("qrToken");
CREATE INDEX idx_students_school ON students("schoolId");

-- Table: parents
CREATE TABLE parents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "userId" UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    "guardianName" VARCHAR(255) NOT NULL,
    relationship "GuardianRelationship" NOT NULL DEFAULT 'GUARDIAN',
    phone VARCHAR(50) NOT NULL,
    "alternatePhone" VARCHAR(50),
    address TEXT,
    occupation VARCHAR(255),
    "idProofNumber" VARCHAR(100),
    status "ParentAccountStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_parents_school ON parents("schoolId");
CREATE INDEX idx_parents_phone ON parents(phone);

-- Table: parent_students (M:N Associative Junction Table)
CREATE TABLE parent_students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "parentId" UUID NOT NULL REFERENCES parents(id) ON DELETE CASCADE,
    "studentId" UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    relationship "GuardianRelationship" NOT NULL DEFAULT 'GUARDIAN',
    "isPrimaryContact" BOOLEAN NOT NULL DEFAULT true,
    "canPickup" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_parent_student UNIQUE ("parentId", "studentId")
);
CREATE INDEX idx_ps_parent ON parent_students("parentId");
CREATE INDEX idx_ps_student ON parent_students("studentId");

-- ============================================================================
-- 5. ATTENDANCE SUBSYSTEM & TIMETABLE
-- ============================================================================

-- Table: attendance_sessions
CREATE TABLE attendance_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "classId" UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    "teacherId" UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    "sessionDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status "SessionStatus" NOT NULL DEFAULT 'OPEN',
    notes TEXT,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "closedAt" TIMESTAMP
);
CREATE INDEX idx_sessions_class_date ON attendance_sessions("classId", "sessionDate");

-- Table: attendance_records
CREATE TABLE attendance_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "sessionId" UUID NOT NULL REFERENCES attendance_sessions(id) ON DELETE CASCADE,
    "studentId" UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    status "AttendanceStatus" NOT NULL,
    method "AttendanceMethod" NOT NULL DEFAULT 'MANUAL',
    "markedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remarks TEXT,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_session_student UNIQUE ("sessionId", "studentId")
);
CREATE INDEX idx_att_student_date ON attendance_records("studentId", "markedAt");
CREATE INDEX idx_att_status ON attendance_records(status);

-- Table: audit_logs
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "actorId" UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    "entityType" VARCHAR(100) NOT NULL,
    "entityId" VARCHAR(255) NOT NULL,
    "previousValue" TEXT,
    "newValue" TEXT,
    reason TEXT,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_audit_entity ON audit_logs("entityType", "entityId");
CREATE INDEX idx_audit_actor ON audit_logs("actorId");

-- Table: notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "userId" UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    category "NotificationCategory" NOT NULL DEFAULT 'INFO',
    type VARCHAR(100) NOT NULL,
    "entityType" VARCHAR(100),
    "entityId" VARCHAR(255),
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "readAt" TIMESTAMP,
    metadata JSONB,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_notif_user_read ON notifications("schoolId", "userId", "isRead");
CREATE INDEX idx_notif_created ON notifications("schoolId", "createdAt");

-- Table: timetable_entries
CREATE TABLE timetable_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "classId" UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    "teacherId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject VARCHAR(100) NOT NULL,
    "dayOfWeek" "DayOfWeek" NOT NULL,
    "startTime" VARCHAR(10) NOT NULL,
    "endTime" VARCHAR(10) NOT NULL,
    "roomNumber" VARCHAR(50),
    "academicYear" VARCHAR(50),
    notes TEXT,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_tt_class_day ON timetable_entries("schoolId", "classId", "dayOfWeek");
CREATE INDEX idx_tt_teacher_day ON timetable_entries("schoolId", "teacherId", "dayOfWeek");

-- Table: academic_events
CREATE TABLE academic_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type "AcademicEventType" NOT NULL DEFAULT 'EVENT',
    "startDate" TIMESTAMP NOT NULL,
    "endDate" TIMESTAMP NOT NULL,
    "isHoliday" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_events_dates ON academic_events("schoolId", "startDate", "endDate");

-- ============================================================================
-- 6. EXAMINATIONS & EVALUATIONS
-- ============================================================================

-- Table: examinations
CREATE TABLE examinations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    "examType" "ExamType" NOT NULL DEFAULT 'MIDTERM',
    "academicYear" VARCHAR(50) NOT NULL,
    "classId" UUID REFERENCES classes(id) ON DELETE CASCADE,
    "startDate" TIMESTAMP NOT NULL,
    "endDate" TIMESTAMP NOT NULL,
    description TEXT,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_exams_academic ON examinations("schoolId", "academicYear");

-- Table: exam_subjects
CREATE TABLE exam_subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "examinationId" UUID NOT NULL REFERENCES examinations(id) ON DELETE CASCADE,
    subject VARCHAR(100) NOT NULL,
    "maxMarks" DOUBLE PRECISION NOT NULL DEFAULT 100,
    "passMarks" DOUBLE PRECISION NOT NULL DEFAULT 33,
    "examDate" TIMESTAMP,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_exam_subject UNIQUE ("examinationId", subject),
    CONSTRAINT chk_exam_marks_valid CHECK ("passMarks" <= "maxMarks" AND "maxMarks" > 0)
);

-- Table: exam_marks
CREATE TABLE exam_marks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "examSubjectId" UUID NOT NULL REFERENCES exam_subjects(id) ON DELETE CASCADE,
    "studentId" UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    "marksObtained" DOUBLE PRECISION NOT NULL,
    remarks TEXT,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_subject_student_mark UNIQUE ("examSubjectId", "studentId"),
    CONSTRAINT chk_marks_obtained_positive CHECK ("marksObtained" >= 0)
);
CREATE INDEX idx_marks_student ON exam_marks("studentId");

-- ============================================================================
-- 7. STUDENT WELFARE, LEAVES & INCIDENTS
-- ============================================================================

-- Table: student_leaves
CREATE TABLE student_leaves (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "studentId" UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    "classId" UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    "appliedById" UUID REFERENCES users(id) ON DELETE SET NULL,
    "leaveType" "LeaveType" NOT NULL DEFAULT 'SICK',
    "startDate" TIMESTAMP NOT NULL,
    "endDate" TIMESTAMP NOT NULL,
    "totalDays" INT NOT NULL DEFAULT 1,
    reason TEXT NOT NULL,
    "documentUrl" TEXT,
    status "LeaveStatus" NOT NULL DEFAULT 'PENDING',
    "reviewRemarks" TEXT,
    "reviewedAt" TIMESTAMP,
    "reviewedById" UUID REFERENCES users(id) ON DELETE SET NULL,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_leave_dates CHECK ("startDate" <= "endDate")
);
CREATE INDEX idx_leaves_status ON student_leaves("schoolId", status);
CREATE INDEX idx_leaves_student ON student_leaves("studentId", "startDate", "endDate");

-- Table: student_leave_decisions (1:1 with student_leaves)
CREATE TABLE student_leave_decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "leaveId" UUID NOT NULL UNIQUE REFERENCES student_leaves(id) ON DELETE CASCADE,
    "reviewerId" UUID REFERENCES users(id) ON DELETE SET NULL,
    action "LeaveStatus" NOT NULL DEFAULT 'APPROVED',
    remarks TEXT NOT NULL,
    "decidedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: student_incidents
CREATE TABLE student_incidents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "studentId" UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    "classId" UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    "reportedById" UUID REFERENCES users(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    "incidentDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    category "IncidentCategory" NOT NULL DEFAULT 'BEHAVIOUR',
    severity "IncidentSeverity" NOT NULL DEFAULT 'MEDIUM',
    status "IncidentStatus" NOT NULL DEFAULT 'REPORTED',
    "actionTaken" TEXT,
    "resolutionNotes" TEXT,
    "isPrivate" BOOLEAN NOT NULL DEFAULT false,
    "resolvedAt" TIMESTAMP,
    "resolvedById" UUID REFERENCES users(id) ON DELETE SET NULL,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_incidents_severity ON student_incidents("schoolId", category, severity);
CREATE INDEX idx_incidents_student ON student_incidents("studentId", "incidentDate");

-- Table: incident_action_history
CREATE TABLE incident_action_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "incidentId" UUID NOT NULL REFERENCES student_incidents(id) ON DELETE CASCADE,
    "actorId" UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    notes TEXT,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_iah_incident ON incident_action_history("incidentId");

-- ============================================================================
-- 8. FEE & FINANCIAL ACCOUNTING LEDGER
-- ============================================================================

-- Table: fee_structures
CREATE TABLE fee_structures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "classId" UUID REFERENCES classes(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    "academicYear" VARCHAR(50) NOT NULL,
    category "FeeCategory" NOT NULL DEFAULT 'TUITION',
    "totalAmount" DOUBLE PRECISION NOT NULL,
    "isOptional" BOOLEAN NOT NULL DEFAULT false,
    frequency VARCHAR(50) NOT NULL DEFAULT 'ANNUAL',
    description TEXT,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_fee_total_positive CHECK ("totalAmount" >= 0)
);
CREATE INDEX idx_fs_academic ON fee_structures("schoolId", "academicYear");

-- Table: student_fees
CREATE TABLE student_fees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "studentId" UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    "feeStructureId" UUID NOT NULL REFERENCES fee_structures(id) ON DELETE CASCADE,
    "academicYear" VARCHAR(50) NOT NULL,
    "originalAmount" DOUBLE PRECISION NOT NULL,
    "discountAmount" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "scholarshipAmount" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "netAmount" DOUBLE PRECISION NOT NULL,
    "paidAmount" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "balanceAmount" DOUBLE PRECISION NOT NULL,
    status "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    remarks TEXT,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_student_fee_struct UNIQUE ("studentId", "feeStructureId"),
    CONSTRAINT chk_net_amount CHECK ("netAmount" >= 0 AND "balanceAmount" >= 0)
);
CREATE INDEX idx_sf_status ON student_fees("schoolId", status);

-- Table: fee_installments
CREATE TABLE fee_installments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "studentFeeId" UUID NOT NULL REFERENCES student_fees(id) ON DELETE CASCADE,
    "installmentNumber" INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    amount DOUBLE PRECISION NOT NULL,
    "dueDate" TIMESTAMP NOT NULL,
    "paidAmount" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "balanceAmount" DOUBLE PRECISION NOT NULL,
    status "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "paidAt" TIMESTAMP,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_fee_inst_num UNIQUE ("studentFeeId", "installmentNumber")
);
CREATE INDEX idx_fi_due ON fee_installments("studentFeeId", "dueDate");

-- Table: fee_payments
CREATE TABLE fee_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "studentFeeId" UUID NOT NULL REFERENCES student_fees(id) ON DELETE CASCADE,
    "studentId" UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    "receiptNumber" VARCHAR(100) NOT NULL UNIQUE,
    "amountPaid" DOUBLE PRECISION NOT NULL,
    "paymentMethod" "PaymentMethod" NOT NULL DEFAULT 'CASH',
    "transactionReference" VARCHAR(255),
    remarks TEXT,
    "paymentDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "recordedById" UUID REFERENCES users(id) ON DELETE SET NULL,
    "isReversed" BOOLEAN NOT NULL DEFAULT false,
    "reversedAt" TIMESTAMP,
    "reversedById" UUID REFERENCES users(id) ON DELETE SET NULL,
    "reversalReason" TEXT,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_amount_paid_positive CHECK ("amountPaid" > 0)
);
CREATE INDEX idx_fp_receipt ON fee_payments("receiptNumber");
CREATE INDEX idx_fp_date ON fee_payments("schoolId", "paymentDate");

-- Table: payment_allocations (M:N Associative Junction Table)
CREATE TABLE payment_allocations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "feePaymentId" UUID NOT NULL REFERENCES fee_payments(id) ON DELETE CASCADE,
    "feeInstallmentId" UUID NOT NULL REFERENCES fee_installments(id) ON DELETE CASCADE,
    "allocatedAmount" DOUBLE PRECISION NOT NULL,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_alloc_positive CHECK ("allocatedAmount" > 0)
);
CREATE INDEX idx_pa_payment ON payment_allocations("feePaymentId");
CREATE INDEX idx_pa_installment ON payment_allocations("feeInstallmentId");

-- Table: fee_discounts
CREATE TABLE fee_discounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "studentFeeId" UUID NOT NULL REFERENCES student_fees(id) ON DELETE CASCADE,
    "discountType" "DiscountType" NOT NULL DEFAULT 'FIXED_AMOUNT',
    value DOUBLE PRECISION NOT NULL,
    amount DOUBLE PRECISION NOT NULL,
    reason TEXT NOT NULL,
    "approvedById" UUID REFERENCES users(id) ON DELETE SET NULL,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: payment_reversals (1:1 with fee_payments)
CREATE TABLE payment_reversals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "feePaymentId" UUID NOT NULL UNIQUE REFERENCES fee_payments(id) ON DELETE CASCADE,
    "approvedById" UUID REFERENCES users(id) ON DELETE SET NULL,
    reason TEXT NOT NULL,
    "reversedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 9. COMMUNICATIONS, ANNOUNCEMENTS & OFFLINE SYNC
-- ============================================================================

-- Table: school_announcements
CREATE TABLE school_announcements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    category "AnnouncementCategory" NOT NULL DEFAULT 'GENERAL',
    priority VARCHAR(50) NOT NULL DEFAULT 'NORMAL',
    "targetAudience" "AudienceType" NOT NULL DEFAULT 'ALL',
    "classId" UUID REFERENCES classes(id) ON DELETE SET NULL,
    "authorId" UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    "isPublished" BOOLEAN NOT NULL DEFAULT true,
    "publishedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "scheduledFor" TIMESTAMP,
    "attachmentUrl" TEXT,
    "expiresAt" TIMESTAMP,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_announcements_audience ON school_announcements("schoolId", "targetAudience");

-- Table: announcement_reads (M:N Associative Junction Table)
CREATE TABLE announcement_reads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "announcementId" UUID NOT NULL REFERENCES school_announcements(id) ON DELETE CASCADE,
    "userId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    "readAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_announcement_user UNIQUE ("announcementId", "userId")
);

-- Table: communication_messages
CREATE TABLE communication_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "threadId" VARCHAR(100),
    "senderId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    "receiverId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    "studentId" UUID REFERENCES students(id) ON DELETE SET NULL,
    subject VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    category "MessageCategory" NOT NULL DEFAULT 'GENERAL',
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "readAt" TIMESTAMP,
    "attachmentUrl" TEXT,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_comm_receiver ON communication_messages("schoolId", "receiverId", "isRead");

-- Table: sync_operations
CREATE TABLE sync_operations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "teacherId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    "operationId" VARCHAR(255) NOT NULL UNIQUE,
    "studentId" UUID REFERENCES students(id) ON DELETE SET NULL,
    status "SyncOperationStatus" NOT NULL DEFAULT 'PENDING',
    action VARCHAR(100) NOT NULL DEFAULT 'MARK_ATTENDANCE',
    payload JSONB NOT NULL,
    "retryCount" INT NOT NULL DEFAULT 0,
    "lastError" TEXT,
    "conflictData" JSONB,
    "resolvedAt" TIMESTAMP,
    "resolvedById" UUID REFERENCES users(id) ON DELETE SET NULL,
    "processedAt" TIMESTAMP,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_sync_ops ON sync_operations("schoolId", status);

-- ============================================================================
-- 10. STUDENT DOCUMENTS & CERTIFICATES
-- ============================================================================

-- Table: student_documents
CREATE TABLE student_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "studentId" UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category "DocumentCategory" NOT NULL DEFAULT 'OTHER',
    status "DocumentVerificationStatus" NOT NULL DEFAULT 'PENDING',
    "currentVersion" INT NOT NULL DEFAULT 1,
    "filePath" TEXT NOT NULL,
    "fileName" VARCHAR(255) NOT NULL,
    "fileSize" INT NOT NULL,
    "mimeType" VARCHAR(100) NOT NULL,
    "fileHash" VARCHAR(255),
    "issueDate" TIMESTAMP,
    "expiryDate" TIMESTAMP,
    "verifiedAt" TIMESTAMP,
    "verifiedById" UUID REFERENCES users(id) ON DELETE SET NULL,
    "verificationNotes" TEXT,
    "uploadedById" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_docs_student ON student_documents("schoolId", "studentId");

-- Table: document_versions
CREATE TABLE document_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "documentId" UUID NOT NULL REFERENCES student_documents(id) ON DELETE CASCADE,
    "versionNumber" INT NOT NULL,
    "filePath" TEXT NOT NULL,
    "fileName" VARCHAR(255) NOT NULL,
    "fileSize" INT NOT NULL,
    "mimeType" VARCHAR(100) NOT NULL,
    "fileHash" VARCHAR(255),
    "changeReason" TEXT,
    "uploadedById" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_doc_version UNIQUE ("documentId", "versionNumber")
);

-- Table: certificate_templates
CREATE TABLE certificate_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type "CertificateType" NOT NULL DEFAULT 'BONAFIDE',
    title VARCHAR(255) NOT NULL,
    "headerText" TEXT,
    "bodyTemplate" TEXT NOT NULL,
    "footerText" TEXT,
    "signatoryTitle" VARCHAR(255) NOT NULL DEFAULT 'Principal / Head of Institution',
    "signatoryName" VARCHAR(255),
    "watermarkText" VARCHAR(255),
    "validityMonths" INT,
    active BOOLEAN NOT NULL DEFAULT true,
    "createdById" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_school_cert_name UNIQUE ("schoolId", name)
);

-- Table: issued_certificates
CREATE TABLE issued_certificates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "studentId" UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    "templateId" UUID REFERENCES certificate_templates(id) ON DELETE SET NULL,
    "certificateNumber" VARCHAR(100) NOT NULL UNIQUE,
    "verificationToken" VARCHAR(255) NOT NULL UNIQUE DEFAULT gen_random_uuid()::text,
    type "CertificateType" NOT NULL,
    title VARCHAR(255) NOT NULL,
    "studentSnapshot" JSONB NOT NULL,
    "certificateData" JSONB NOT NULL,
    "signatoryTitle" VARCHAR(255) NOT NULL DEFAULT 'Principal / Head of Institution',
    "signatoryName" VARCHAR(255),
    "issueDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiryDate" TIMESTAMP,
    status "CertificateStatus" NOT NULL DEFAULT 'ACTIVE',
    "issuedById" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    "revokedAt" TIMESTAMP,
    "revokedById" UUID REFERENCES users(id) ON DELETE SET NULL,
    "revocationReason" TEXT,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_certs_token ON issued_certificates("verificationToken");
CREATE INDEX idx_certs_student ON issued_certificates("schoolId", "studentId");

-- Table: certificate_verification_logs
CREATE TABLE certificate_verification_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "certificateId" UUID NOT NULL REFERENCES issued_certificates(id) ON DELETE CASCADE,
    "ipAddress" VARCHAR(100),
    "userAgent" TEXT,
    "verifiedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "queryToken" VARCHAR(255),
    "isValid" BOOLEAN NOT NULL DEFAULT true
);
CREATE INDEX idx_cvl_cert ON certificate_verification_logs("certificateId");

-- ============================================================================
-- 11. ACADEMIC INTERVENTIONS & FINANCIAL ARCHIVES
-- ============================================================================

-- Table: academic_interventions
CREATE TABLE academic_interventions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "studentId" UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    "teacherId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    "assignedToId" UUID REFERENCES users(id) ON DELETE SET NULL,
    type "InterventionType" NOT NULL DEFAULT 'ACADEMIC_DEFICIT',
    severity "InterventionSeverity" NOT NULL DEFAULT 'MEDIUM',
    status "InterventionStatus" NOT NULL DEFAULT 'OPEN',
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    subject VARCHAR(100),
    "actionPlan" TEXT,
    "baselinePercentage" DOUBLE PRECISION,
    "targetPercentage" DOUBLE PRECISION,
    "currentPercentage" DOUBLE PRECISION,
    "baselineAttendance" DOUBLE PRECISION,
    "followUpDate" TIMESTAMP,
    "resolvedAt" TIMESTAMP,
    "resolvedById" UUID REFERENCES users(id) ON DELETE SET NULL,
    "resolutionNotes" TEXT,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_interventions_status ON academic_interventions("schoolId", status);

-- Table: academic_intervention_notes
CREATE TABLE academic_intervention_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "interventionId" UUID NOT NULL REFERENCES academic_interventions(id) ON DELETE CASCADE,
    "authorId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    note TEXT NOT NULL,
    "progressMetric" DOUBLE PRECISION,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_ain_intervention ON academic_intervention_notes("interventionId");

-- Table: financial_year_archives
CREATE TABLE financial_year_archives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "schoolId" UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    "academicYear" VARCHAR(50) NOT NULL,
    "archivedById" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    "totalAssessed" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "totalCollected" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "totalPending" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "totalStudents" INT NOT NULL DEFAULT 0,
    "feeStructureCount" INT NOT NULL DEFAULT 0,
    "paymentCount" INT NOT NULL DEFAULT 0,
    "summarySnapshot" JSONB NOT NULL,
    notes TEXT,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_school_financial_archive UNIQUE ("schoolId", "academicYear")
);
CREATE INDEX idx_fya_school_year ON financial_year_archives("schoolId", "academicYear");

-- ============================================================================
-- SCHEMA DDL CREATION COMPLETE (39 Tables, Strictly Typed, 3NF Normalized)
-- ============================================================================

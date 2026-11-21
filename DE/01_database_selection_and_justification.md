# 01. Database Selection and Justification
## Subject: Data Engineering (DE) – Section A
### Project: ShikshaTrack (Smart Attendance & School Management System)

---

## 1. Executive Summary

Selecting an appropriate Database Management System (DBMS) is one of the most critical foundational decisions in software engineering. For **ShikshaTrack**, an enterprise-grade school management and smart attendance system tailored for rural and semi-urban educational institutions, the database must guarantee absolute data consistency, prevent proxy or duplicate attendance, uphold referential integrity across deeply interconnected academic entities, process multi-installment financial transactions, and generate complex statutory reports for district authorities (such as the **Mid-Day Meal (MDM)** headcount and the **Right to Education (RTE) Act 75% attendance threshold**).

After a systematic evaluation of relational (PostgreSQL) and document-oriented (MongoDB) paradigms against the application's functional and non-functional requirements, **PostgreSQL 18** was chosen as the primary database management system.

---

## 2. Problem Statement & System Context

Rural educational institutions in India face distinct systemic challenges:
1. **Paper-Based Register Inefficiencies:** Manual rolls waste 15–20 minutes per classroom daily and suffer from high rates of proxy marking, human tally errors, and physical loss or wear.
2. **Statutory Governance Requirements:** Government welfare programs, such as the national Mid-Day Meal (MDM) scheme, require daily, tamper-proof headcounts to allocate grain and monetary subsidies. Over-reporting results in financial corruption; under-reporting deprives children of nutrition.
3. **Low-Connectivity Environments:** Rural schools frequently suffer from intermittent or absent internet connectivity. The attendance system must operate locally via client-side caching (IndexedDB/PWA) and later perform batch synchronization against the centralized database without creating duplicate marks or race conditions.
4. **Unified School Administration:** Beyond attendance, the system manages teacher allocations, student leave requests, disciplinary incident tracking, timetable schedules, multi-subject examinations, and fee collections.

These operational constraints demand a database system with rigorous transaction guarantees, strong consistency, relational constraints, and rich analytical querying.

---

## 3. Nature of the Stored Data

The data managed by ShikshaTrack is inherently **highly structured**, **densely relational**, and **transactionally sensitive**. It can be classified into five distinct operational tiers:

```
┌────────────────────────────────────────────────────────────────────────┐
│                   ShikshaTrack Data Taxonomy                           │
├──────────────────────────┬─────────────────────────────────────────────┤
│ 1. Core Organizational   │ Schools, Users (Admins, Teachers, Parents), │
│    & Academic Registry   │ Classes, Sections, Teacher Allocations      │
├──────────────────────────┼─────────────────────────────────────────────┤
│ 2. High-Frequency        │ Daily Attendance Sessions, Individual Marks │
│    Transactional Logs    │ (QR / Manual / Offline), Sync Operations    │
├──────────────────────────┼─────────────────────────────────────────────┤
│ 3. Financial & Fee       │ Fee Structures, Student Fee Ledgers,        │
│    Accounting Ledgers    │ Installments, Payments, Payment Allocations │
├──────────────────────────┼─────────────────────────────────────────────┤
│ 4. Evaluation & Welfare  │ Examinations, Subjects, Student Marks,      │
│    Data                  │ Leaves, Discipline Incidents, Interventions │
├──────────────────────────┼─────────────────────────────────────────────┤
│ 5. Audit & Compliance    │ Audit Logs, Certificate Verification Logs,  │
│    Artifacts             │ System Notifications, Announcements         │
└──────────────────────────┴─────────────────────────────────────────────┘
```

### Key Data Characteristics:
- **Strict Schema Requirements:** A student cannot exist without belonging to a registered school and a valid class. An attendance record cannot exist without referencing both a valid attendance session and an enrolled student.
- **Relational Interdependence:** Over 80% of application queries involve multi-table traversals (e.g., retrieving a student's daily attendance alongside their class teacher, parent contact numbers, and fee clearance status).
- **Zero-Tolerance Financial Ledger:** Fee collection involves splitting lump-sum payments across multiple overdue installments (tuition, transport, examination). Every rupee must balance out across ledger entries without discrepancy.
- **Temporal Series:** Attendance sessions and marked records form a continuous, append-heavy chronological series requiring time-window rollups, truancy window scans, and historical aggregations.

---

## 4. Comprehensive Comparison: PostgreSQL vs MongoDB

| Architectural Dimension | PostgreSQL 18 (Selected) | MongoDB (Document Store) | Suitability Analysis for ShikshaTrack |
| :--- | :--- | :--- | :--- |
| **Data Model** | Relational tabular model (strict tables, columns, constraints, foreign keys). | Schema-optional, JSON-like document model (BSON collections). | **PostgreSQL Wins:** School entities have well-defined, static schemas with deep cross-entity relationships that map naturally to normalized relational tables. |
| **Transaction Model** | Full ACID (Atomicity, Consistency, Isolation, Durability) at table and multi-table levels. | Multi-document ACID transactions exist but carry performance overhead and distributed coordination complexity. | **PostgreSQL Wins:** Critical for fee payments where one receipt updates `fee_payments`, multiple `payment_allocations`, and `student_fees` simultaneously. |
| **Referential Integrity** | Native Declarative Foreign Keys with `ON DELETE CASCADE`, `RESTRICT`, and `SET NULL`. | Application-level manual enforcement. Dangling references must be handled in application code. | **PostgreSQL Wins:** Essential to prevent orphaned attendance records, dangling exam marks, or unallocated payments if an entity is modified or removed. |
| **Complex Joins & Aggregation** | Industry standard SQL with ANSI JOINs, CTEs (Common Table Expressions), Window Functions (`DENSE_RANK`, `LAG`), and Subqueries. | Aggregation Pipeline (`$lookup`, `$unwind`, `$group`). Complex multi-collection joins are verbose, harder to optimize, and memory-intensive. | **PostgreSQL Wins:** Crucial for district governance reporting (e.g., classes with < 75% attendance, daily Mid-Day Meal headcounts, student rank lists). |
| **Duplicate Prevention** | Declarative composite unique constraints (`UNIQUE(session_id, student_id)`, `UNIQUE(school_id, admission_number)`). | Unique compound indexes supported, but validation of cross-collection dependencies requires application middleware. | **PostgreSQL Wins:** Guarantees at the database engine level that no student is marked twice in the same session, even during concurrent or retried sync requests. |
| **Handling Semi-Structured Data** | Native, highly optimized `JSONB` data type with GIN indexing for flexible payloads. | Native BSON format. | **Tie:** PostgreSQL's `JSONB` gives ShikshaTrack the exact flexibility of MongoDB for audit trails, sync payloads, and dynamic certificate snapshots while retaining full relational rigor. |
| **Concurrency Control** | Multi-Version Concurrency Control (MVCC) with fine-grained row-level locking. | Document-level concurrency control with WiredTiger engine. | **PostgreSQL Wins:** High concurrent throughput for multiple teachers marking morning attendance simultaneously without table-level locking bottlenecks. |
| **Memory & Storage Footprint** | Compact, indexed tabular storage; low memory overhead on commodity hardware. | Significant memory footprint (WiredTiger cache, repeated field names in every document unless compressed). | **PostgreSQL Wins:** Rural servers, low-cost district cloud instances, or local school edge machines have constrained RAM; PostgreSQL runs exceptionally well on constrained resources. |

---

## 5. Architectural Justification for PostgreSQL

### 5.1. Strict ACID Guarantees for Financial and Academic Ledgers
In ShikshaTrack, fee collection is not a simple key-value write. When a parent pays ₹3,500 towards their child's fees:
1. A new `fee_payments` record must be inserted with a unique receipt number.
2. The payment must be allocated across specific outstanding `fee_installments` via `payment_allocations`.
3. The parent `student_fees` record must update its `paid_amount` and `balance_amount`.
4. An `audit_logs` entry must capture the transaction.

If the server crashes midway or network disconnects, PostgreSQL's `BEGIN ... COMMIT` transaction ensures **all-or-nothing atomicity**. In a document store without strict ACID guarantees, a partial write would result in an unaccounted financial discrepancy.

### 5.2. Database-Enforced Data Integrity via Constraints
Application code can contain bugs, race conditions, or unhandled exceptions. PostgreSQL enforces business rules directly at the storage layer:
- `@@unique([sessionId, studentId])`: Absolutely prevents duplicate attendance marks for a student in a single session.
- `@@unique([schoolId, admissionNumber])`: Enforces that student admission IDs are unique per school.
- `CHECK (marks_obtained >= 0 AND marks_obtained <= max_marks)`: Prevents out-of-range examination grades.
- `CHECK (start_time < end_time)`: Enforces valid timetable periods.
- `FOREIGN KEY (...) ON DELETE RESTRICT`: Prevents an administrator from accidentally deleting a class that contains actively enrolled students.

### 5.3. Complex Analytical Reporting for Government Compliance
State education departments require complex daily, weekly, and monthly statutory reporting. PostgreSQL's expressive SQL engine executes these aggregations directly inside the database kernel in milliseconds:
- **Mid-Day Meal (MDM) Allocation:** Requires filtering present students on a specific date, cross-referencing school enrollment, and multiplying by ration weights.
- **RTE 75% Attendance Alerts:** Requires calculating aggregate attendance percentages per student across rolling time windows and grouping with `HAVING percentage < 75.0`.
- **Examination Leaderboards:** Window functions like `DENSE_RANK() OVER (PARTITION BY subject ORDER BY marks DESC)` compute academic standings in a single scan without loading thousands of rows into Node.js application memory.

### 5.4. Conflict Resolution for Offline Synchronization
In rural zones, teachers record attendance offline on their mobile devices or laptops. When internet connectivity is restored, the client queues a batch of attendance marks to the backend.
- Using PostgreSQL's `ON CONFLICT (session_id, student_id) DO UPDATE ...` (or Prisma `upsert`), the database guarantees **idempotent writes**.
- If a sync request is retried five times due to a spotty 2G/3G cellular connection, PostgreSQL ensures the attendance record is updated cleanly rather than creating duplicate entries.

### 5.5. The "Best of Both Worlds": Relational Tables + JSONB
A common argument for MongoDB is document flexibility. However, PostgreSQL offers native, binary-encoded `JSONB` support. ShikshaTrack leverages `JSONB` for:
- `audit_logs.previous_value` and `audit_logs.new_value` (arbitrary entity state snapshots).
- `sync_operations.payload` and `sync_operations.conflict_data` (storing offline operation payloads).
- `issued_certificates.student_snapshot` and `certificate_data` (tamper-proof point-in-time academic snapshots).

Thus, ShikshaTrack achieves **100% of MongoDB's document flexibility** while retaining **100% of PostgreSQL's relational power and ACID guarantees**.

---

## 6. Conclusion

PostgreSQL 18 is the optimal database choice for ShikshaTrack. Its mature ACID transaction engine, declarative referential constraints, rich analytical querying capabilities, superior resource efficiency, and hybrid JSONB support directly satisfy the demanding operational, financial, and compliance requirements of an educational institution.

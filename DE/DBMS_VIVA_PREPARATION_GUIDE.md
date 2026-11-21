# DBMS Viva Video Recording & Preparation Guide
## Subject: Data Engineering (DE) Major Project – ShikshaTrack
### Time Limit: 10 Minutes Maximum | Screen Recording Required

---

## 1. Video Recording Setup & Structure Checklist

### Recording Rules:
- **Maximum Duration:** Strictly **under 10 minutes** (aim for **8 to 9 minutes**).
- **Visibility:** Screen must be shared and clearly visible throughout. Keep your webcam thumbnail in the corner if possible.
- **Demonstration Requirement:** Demonstrate **live code**, **Prisma schema**, **SQL console/queries**, and **running outputs**. Do **not** use presentation slides.
- **Tone:** Confident, precise, engineering-focused, and specific to **ShikshaTrack**.

### Recommended Time Allocation:
| Section | Question | Time Allocation | Screen to Show |
| :---: | :--- | :---: | :--- |
| **0** | Quick Introduction & Project Context | **0:30** | VS Code / GitHub Repository (`ShikshaTrack_Major_Project`) |
| **1** | Q1: Why did you choose this database? | **1:45** | `DE/01_database_selection_and_justification.md` + Live Query in Terminal |
| **2** | Q2: Schema & Data Model Walkthrough | **2:00** | `backend/prisma/schema.prisma` / ER Diagram in `DE/02_er_diagram_and_data_modelling.md` |
| **3** | Q3: Normal Forms & Deliberate Denormalization | **1:45** | `DE/03_database_normalization.md` + `feeService.js` code |
| **4** | Q4: Data Correctness, Constraints & Transactions | **2:00** | `backend/src/services/feeService.js` (`$transaction`) + Constraint Rejection in Terminal |
| **5** | Q5: Efficiency, Indexing & 100x Scaling | **1:30** | `DE/08_database_architecture_and_performance.md` + Index definitions |
| **—** | Brief Conclusion | **0:30** | Working Application or Final Summary |

---

## 2. Question-by-Question Spoken Script & Screen Demo

---

### Introduction (0:00 – 0:30)
> **What to Say:**
> *"Hello, my name is [Your Name]. This is my individual DBMS viva video submission for our Data Engineering Major Project: **ShikshaTrack**, an AI-powered smart attendance and school management system designed for rural schools. Over the next 9 minutes, I will answer all five viva questions while demonstrating our actual PostgreSQL database schema, backend integration, transaction logic, and live query execution."*
>
> **What to Show on Screen:**
> - VS Code open to the project root showing the `/backend` and `/DE` directories.

---

### Question 1: Why did you choose this database? (0:30 – 2:15)

#### Evaluation Criteria to Hit:
- Name database & type: **PostgreSQL 18** (Relational DBMS / Object-Relational).
- Nature of data: Highly structured, densely connected, financial/academic ledgers.
- Read/Write patterns & scale: Daily read-heavy dashboards; intense burst write pattern between **8:30 AM – 9:15 AM** during morning roll calls. Scale: ~250 students/school = 60,000 attendance records/year; across a 500-school rural district = 30 million rows/year.
- Strong consistency / Transactions: Mandatory for financial fee installments, zero-duplicate attendance marking, and statutory Mid-Day Meal ration headcounts.
- Rejected alternative: **MongoDB** (document store). Rejected because:
  1. Embedding attendance in student documents causes documents to grow without bound ($>16\text{MB}$ limit).
  2. Lack of native declarative foreign key cascades (`ON DELETE RESTRICT`/`CASCADE`).
  3. Multi-collection ACID transactions carry heavy overhead compared to PostgreSQL's native MVCC engine.
- Hybrid capability: PostgreSQL's native **`JSONB`** provides document flexibility for audit snapshots and offline sync payloads without sacrificing relational ACID rigor.

#### What to Show on Screen:
1. Open [`DE/01_database_selection_and_justification.md`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/DE/01_database_selection_and_justification.md) and highlight the comparison matrix.
2. Open terminal and run **Query 1** and **Query 4** from [`DE/06_project_queries_and_execution.sql`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/DE/06_project_queries_and_execution.sql):
   - **Frequent Operation 1:** QR Attendance check-in (`INSERT INTO attendance_records ... ON CONFLICT DO UPDATE`).
   - **Frequent Operation 2:** Class roster retrieval sorted by roll number.

> **Spoken Script for Q1:**
> *"For ShikshaTrack, we chose **PostgreSQL 18**, which is an enterprise-grade object-relational database management system. 
> Our data is inherently **highly structured and densely relational**. A school contains classes, classes contain students, and daily sessions record attendance. In addition, we manage multi-installment fee ledgers and examination scores.
> 
> Our workload has a distinct write-heavy burst pattern: every morning between 8:30 and 9:15 AM, hundreds of QR attendance scans arrive simultaneously. For a single school, this generates about 60,000 records annually, but at a district scale of 500 schools, that exceeds 30 million rows. Strong consistency is an absolute non-negotiable requirement. Under the Right to Education Act and Mid-Day Meal scheme, we cannot afford dirty reads, duplicate attendance marks, or financial discrepancies.
> 
> We explicitly evaluated and rejected **MongoDB**. In MongoDB, if you embed attendance records inside a student document, the document grows unbounded over an academic career, violating document size limits. If you reference them, multi-collection joins require memory-intensive `$lookup` pipelines without declarative foreign key cascades. Furthermore, PostgreSQL gives us the best of both worlds: strict relational tables for our core ledgers, and native binary **`JSONB`** for audit logs and offline sync conflict payloads."*

---

### Question 2: Walk us through your schema or data model (2:15 – 4:15)

#### Evaluation Criteria to Hit:
- Present ER diagram / tables (39 models).
- Explain entities, PKs, FKs, and relationships:
  - **Surrogate PKs:** `UUIDv4` across all tables (critical for offline mobile sync without key collisions).
  - **1:1 Relationships:** `users` $\leftrightarrow$ `parents` (via `parents.userId` UNIQUE); `student_leaves` $\leftrightarrow$ `student_leave_decisions`.
  - **1:N Relationships:** `schools` $\rightarrow$ `classes`; `classes` $\rightarrow$ `students` (`ON DELETE RESTRICT`); `attendance_sessions` $\rightarrow$ `attendance_records` (`ON DELETE CASCADE`).
  - **M:N Relationships resolved via Associative Junction Tables:**
    1. `users (Teachers)` $\leftrightarrow$ `classes` resolved via **`teacher_assignments`** (`UNIQUE(teacherId, classId)`).
    2. `parents` $\leftrightarrow$ `students` resolved via **`parent_students`** (`UNIQUE(parentId, studentId)`).
    3. `fee_payments` $\leftrightarrow$ `fee_installments` resolved via **`payment_allocations`** (splits lump-sum payments across overdue installments).
- Show cross-relationship query joining the main tables.

#### What to Show on Screen:
1. Open [`backend/prisma/schema.prisma`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/backend/prisma/schema.prisma) (lines 40 to 235) or [`DE/02_er_diagram_and_data_modelling.md`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/DE/02_er_diagram_and_data_modelling.md).
2. Show **Query 7** from `DE/06_project_queries_and_execution.sql` in terminal or editor, which performs an `INNER JOIN` across `attendance_records`, `students`, `attendance_sessions`, `classes`, and `users`.

> **Spoken Script for Q2:**
> *"Here is our data model in Prisma schema and PostgreSQL DDL. All primary keys use globally unique **UUIDv4** surrogate keys. This is critical for rural offline operations: a teacher's mobile device can create unique records offline without central network roundtrips.
> 
> Let's look at key cardinalities:
> - **One-to-One (1:1):** Every parent system user account in `users` links to exactly one profile in `parents` using a unique foreign key `parents.userId`. Similarly, each `student_leaves` application culminates in exactly one `student_leave_decisions` review.
> - **One-to-Many (1:N):** One `class` has many `students`, protected by `ON DELETE RESTRICT` so a class with active pupils cannot be dropped accidentally. One daily `attendance_session` has many `attendance_records`, protected by `ON DELETE CASCADE`.
> - **Many-to-Many (M:N):** We resolve M:N relationships using formal associative junction tables:
>   1. `teacher_assignments` links teachers and classes, with a boolean flag `isClassTeacher` and a compound unique constraint.
>   2. `parent_students` links parents and students, accommodating siblings and multiple emergency contacts.
>   3. `payment_allocations` links `fee_payments` with `fee_installments`, tracking how a single ₹3,500 receipt is divided across multiple overdue installments.
> 
> Here on screen, you can see **Query 7**, which joins four levels of this hierarchy—the attendance record, student, session, class, and the recording teacher—returning a consolidated classroom roll in 1.6 milliseconds."*

---

### Question 3: What normal form is your design in, and where did you deliberately break it? (4:15 – 6:00)

#### Evaluation Criteria to Hit:
- Highest normal form: **Third Normal Form (3NF) and Boyce-Codd Normal Form (BCNF)**.
- Functional dependencies of one table: e.g. `attendance_records` ($\{\text{sessionId}, \text{studentId}\} \rightarrow \text{id}, \text{status}, \text{method}, \text{markedAt}$) or `students` ($\{\text{schoolId}, \text{admissionNumber}\} \rightarrow \text{id}, \text{name}, \text{classId}, \dots$).
- Removal of partial & transitive dependencies:
  - *Partial dependency removed:* In unnormalized form with key $\{\text{sessionId}, \text{studentId}\}$, `sessionDate` depended only on `sessionId`. Decomposed into separate `attendance_sessions` and `attendance_records`.
  - *Transitive dependency removed:* In 2NF, `studentId` determined `classId`, which determined `schoolId` and `schoolName`. Extracted `classes` and `schools` into independent tables.
- **Deliberate Denormalization & How Correctness is Maintained:**
  - Table **`student_fees`** stores redundant fields: `paidAmount` and `balanceAmount` alongside `netAmount`.
  - *Why denormalized:* Real-time fee balance lookups are queried on every student profile, portal login, and report card. Recomputing `SUM(allocatedAmount)` across thousands of `payment_allocations` rows on every read creates excessive query overhead.
  - *How correctness is guaranteed:* We do **not** allow manual updates. Correctness is strictly maintained by backend application transactions in [`backend/src/services/feeService.js`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/backend/src/services/feeService.js). Whenever a payment is recorded or reversed, an interactive ACID `$transaction` atomically updates the installments, inserts the allocation, and recalculates `paidAmount` and `balanceAmount`.

#### What to Show on Screen:
1. Open [`DE/03_database_normalization.md`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/DE/03_database_normalization.md) and highlight the 1NF $\rightarrow$ 2NF $\rightarrow$ 3NF decomposition table.
2. Open [`backend/src/services/feeService.js`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/backend/src/services/feeService.js) (lines 485–510) showing the transaction updating `paidAmount` and `balanceAmount`.

> **Spoken Script for Q3:**
> *"Our database is formally normalized to **Third Normal Form (3NF)** and **Boyce-Codd Normal Form (BCNF)**.
> 
> Let's examine the functional dependencies of `attendance_records`. The composite determinant $\{\text{sessionId}, \text{studentId}\}$ uniquely determines `status`, `method`, and `markedAt`. In our unnormalized starting design, attributes like `studentName` and `sessionDate` were placed in the same row. This violated 2NF because `studentName` depended only on `studentId` (a partial dependency). We decomposed this into `students`, `attendance_sessions`, and `attendance_records`. We also removed transitive dependencies where `studentId` determined `classId`, which determined `schoolId`.
> 
> However, in one place we **deliberately denormalized**: inside the **`student_fees`** table. Here, we store redundant columns: `paidAmount` and `balanceAmount`. In strict 3NF, balance must be calculated dynamically via `netAmount - SUM(payment_allocations.allocatedAmount)`. But because fee balance checks occur continuously on student dashboards and report cards, calculating this aggregate on every read is computationally expensive.
> 
> To maintain strict correctness, we protect this denormalization inside a backend transaction in `feeService.js`. Every time a payment or reversal happens, the payment creation, installment allocation, and student fee recalculation execute inside a single atomic `prisma.$transaction`. If any step fails, the entire transaction rolls back, guaranteeing zero balance divergence."*

---

### Question 4: How does your database protect data correctness? (6:00 – 8:00)

#### Evaluation Criteria to Hit:
- Constraints used:
  - `NOT NULL` on essential fields.
  - `UNIQUE(sessionId, studentId)`: Storage-level guarantee that prevents double-marking attendance.
  - `UNIQUE(schoolId, admissionNumber)`: School-scoped admission numbers.
  - `CHECK ("amountPaid" > 0)` and `CHECK ("passMarks" <= "maxMarks")`.
  - Foreign keys with `ON DELETE RESTRICT` (classes with students) and `ON DELETE CASCADE` (sessions with records).
- Database vs. Application Enforcement:
  - Database enforces structural invariants, uniqueness, referential integrity, and value boundaries.
  - Application code enforces temporal rules (e.g., sessions can only be closed by the assigned teacher, leave quota limits).
- Transactions: Demonstrate [`backend/src/services/feeService.js`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/backend/src/services/feeService.js) `recordPayment` method using `prisma.$transaction(async (tx) => { ... })`.
- Concurrency & Isolation: PostgreSQL uses **Multi-Version Concurrency Control (MVCC)** with `READ COMMITTED` isolation. If two teachers or offline sync workers submit attendance for the same student simultaneously, PostgreSQL's composite unique index catches the conflict, and our atomic `upsert` (`ON CONFLICT DO UPDATE`) prevents double-marking and deadlocks.
- **Extra Credit Demo:** Show a constraint rejection in the console (trying to insert duplicate attendance or negative fee amount).

#### What to Show on Screen:
1. Open [`backend/src/services/feeService.js`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/backend/src/services/feeService.js) showing `prisma.$transaction`.
2. In terminal, run a test query that triggers a constraint violation:
   ```sql
   INSERT INTO attendance_records (id, "sessionId", "studentId", status)
   VALUES (gen_random_uuid(), 'f0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000001', 'PRESENT');
   ```
   Show PostgreSQL outputting:
   `ERROR: duplicate key value violates unique constraint "uq_session_student"`

> **Spoken Script for Q4:**
> *"Data correctness is guarded at the database storage engine level rather than relying solely on application code.
> 
> We implement:
> - **Composite Unique Constraints:** `UNIQUE(sessionId, studentId)` in `attendance_records`. Even under concurrent network requests, a student cannot be marked twice in the same session.
> - **Domain CHECK Constraints:** `CHECK ("amountPaid" > 0)` in `fee_payments` and `CHECK ("passMarks" <= "maxMarks")` in `exam_subjects`.
> - **Referential Cascades:** `ON DELETE RESTRICT` ensures an administrator cannot accidentally drop a class that contains active students.
> 
> To demonstrate atomicity, look at our `recordPayment` service on screen. Recording a payment requires four operations: creating the payment receipt, updating installment balances sequentially, inserting junction allocations, and updating the overall fee account. We wrap all four inside `prisma.$transaction(async (tx) => { ... })`. If the server crashes or network fails while allocating installment two, PostgreSQL automatically issues an internal `ROLLBACK`.
> 
> For concurrency, PostgreSQL uses **Multi-Version Concurrency Control (MVCC)**. When offline batch synchronization pushes attendance from multiple devices, our atomic `ON CONFLICT ("sessionId", "studentId") DO UPDATE` resolves concurrency cleanly without race conditions.
> 
> Watch as I attempt to manually insert a duplicate attendance mark for student Aarav Sharma in today's closed session. As you can see in the terminal, PostgreSQL immediately rejects it with: `ERROR: duplicate key value violates unique constraint 'uq_session_student'`. Data corruption is prevented at the engine level."*

---

### Question 5: How did you make your database usage efficient? (8:00 – 9:30)

#### Evaluation Criteria to Hit:
- Indexes created & queries supported:
  1. Composite B-Tree index on `attendance_sessions(classId, sessionDate)`: Supports daily roll retrieval.
  2. Composite index on `attendance_records(studentId, markedAt)`: Supports historical student attendance rate calculations.
  3. Unique B-Tree index on `students(qrToken)`: Enables instant $O(1)$ lookups during live camera scans.
- Index considered & decided against:
  - We decided **against** creating separate indexes on individual text columns like `attendance_records.remarks` or standalone `markedAt` because adding secondary indexes increases write latency and WAL buffer bloat during the high-concurrency morning 8:30 AM check-in rush.
- Optimization evidence: `EXPLAIN ANALYZE` shows composite index transforms $O(N)$ sequential scans into $O(\log N)$ index scans executing in **0.065 milliseconds**.
- What breaks if user base grew 100x (e.g. 50,000 students across hundreds of schools):
  1. `attendance_records` table bloats to over **15 million rows annually**, causing memory cache eviction and slow historical reporting.
  2. Connection saturation on PostgreSQL during 8:30 AM simultaneous check-in bursts.
- What would change to fix 100x scale:
  1. **Declarative Table Partitioning:** Partition `attendance_records` by Academic Year or Quarter (`PARTITION BY RANGE (marked_at)`), enabling instant partition pruning.
  2. **Connection Pooling:** Implement **PgBouncer** connection pooling to multiplex thousands of client connections into a controlled worker pool.
  3. **Read Replicas:** Route heavy statutory reports (Mid-Day Meal counts, RTE 75% alerts) to read replicas while writes go to primary compute.
  4. **Archival Engine:** Utilize our existing `financial_year_archives` model to freeze closed academic sessions into static JSONB snapshots.

#### What to Show on Screen:
1. Open [`DE/08_database_architecture_and_performance.md`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/DE/08_database_architecture_and_performance.md) and highlight Section 4 (`EXPLAIN ANALYZE`) and Section 5 (Partitioning & Scaling Strategy).

> **Spoken Script for Q5:**
> *"To maximize performance, we analyzed our execution paths using PostgreSQL's `EXPLAIN ANALYZE`.
> 
> We created targeted B-tree indexes:
> 1. A composite index on `attendance_sessions(classId, sessionDate)` which speeds up morning roll lookups.
> 2. A composite index on `attendance_records(studentId, markedAt)` which powers the cumulative attendance percentage calculation.
> 3. A unique index on `students(qrToken)` which allows our camera viewfinder to resolve student IDs in less than 2 milliseconds.
> 
> Crucially, we decided **against** indexing every single column, such as `remarks` or isolated timestamps. In a rural school, write throughput during the 8:30 AM rush is paramount; extraneous indexes degrade write performance and increase WAL file churn.
> 
> If our deployment grew **100 times**—scaling to 500 schools and millions of attendance records—the first thing that would break is the `attendance_records` table, causing cache eviction and slower sequential scans on historical queries. Second, hundreds of simultaneous teacher sessions would saturate database connection limits.
> 
> To handle 100x scale, our architectural roadmap introduces:
> 1. **Declarative Table Partitioning:** Partitioning `attendance_records` by range across academic years (`PARTITION BY RANGE (marked_at)`), allowing partition pruning to skip historical years.
> 2. **PgBouncer Connection Pooling:** Multiplexing thousands of teacher mobile apps into a stable pool of 50 backend PostgreSQL connections.
> 3. **Read Replicas:** Offloading heavy district-wide Mid-Day Meal aggregations and AI analytics to read replicas while keeping primary compute 100% responsive for attendance writes."*

---

### Conclusion (9:30 – 10:00)
> **What to Say:**
> *"In summary, ShikshaTrack demonstrates a complete, production-grade implementation of DBMS principles: a fully normalized 3NF/BCNF PostgreSQL schema, declarative constraints, ACID multi-table transactions via Prisma, robust offline conflict resolution, and sub-millisecond query performance. 
> All documentation, ER diagrams, DDL schemas, sample seed data, and 14 project queries are submitted in the `/DE` folder of our GitHub repository. Thank you!"*

---

## 3. Quick Reference Sheet (Keep Open Next to Your Screen)

```
┌────────────────────────────────────────────────────────────────────────┐
│               SHIKSHATRACK DBMS VIVA CHEAT SHEET                       │
├────────────────────────────────────────────────────────────────────────┤
│ Q1: Database       │ PostgreSQL 18 (Relational, ACID, MVCC, JSONB)     │
│     Why not Mongo? │ Unbounded array growth, lack of FK cascades,       │
│                    │ heavy multi-collection transaction overhead.      │
│ Q2: Cardinality    │ 1:1 (users ↔ parents), 1:N (classes → students),  │
│     M:N Junctions  │ teacher_assignments, parent_students,             │
│                    │ payment_allocations.                              │
│ Q3: Normal Form    │ 3NF & BCNF certified.                             │
│     Denormalized   │ student_fees (paidAmount, balanceAmount) for fast │
│                    │ reads; updated transactionally via $transaction.  │
│ Q4: Correctness    │ UNIQUE(sessionId, studentId), CHECK(amount > 0),  │
│     Transactions   │ prisma.$transaction in feeService.js.             │
│ Q5: Efficiency     │ Composite indexes (classId, sessionDate).         │
│     100x Growth    │ Table Partitioning (by year), PgBouncer, Replicas.│
└────────────────────────────────────────────────────────────────────────┘
```

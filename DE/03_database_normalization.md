# 03. Database Normalization (1NF, 2NF, 3NF & BCNF)
## Subject: Data Engineering (DE) – Section C
### Project: ShikshaTrack (Smart Attendance & School Management System)

---

## 1. Introduction & Theoretical Foundations

In relational database engineering, **normalization** is the formal mathematical process of decomposing complex, redundant table structures into smaller, well-structured relations. The primary objectives are:
1. **Eliminating Data Redundancy:** Storing each discrete data fact in exactly one place.
2. **Preventing Modification Anomalies:** Guaranteeing that insertions, updates, and deletions cannot corrupt database consistency.
3. **Preserving Functional Dependencies:** Ensuring that valid real-world relationships and constraints are enforced naturally by primary and foreign keys.
4. **Ensuring Lossless Decompositions:** Guaranteeing that the original dataset can be reconstructed via relational `JOIN` operations without generating spurious or phantom tuples.

This document demonstrates the formal step-by-step transformation of ShikshaTrack's operational data from an **Unnormalized Form (UNF)** flat spreadsheet model up to **Third Normal Form (3NF)** and **Boyce-Codd Normal Form (BCNF)**.

---

## 2. The Unnormalized Form (UNF) & Modification Anomalies

### 2.1. The Unnormalized School Attendance & Fee Ledger
Prior to computerized DBMS systems, rural schools recorded attendance, examinations, and fee collections in physical paper registers or unnormalized spreadsheets. Consider the unnormalized universal relation:

$$\text{UNF\_SCHOOL\_REGISTER}(\underline{\text{SchoolCode}}, \text{SchoolName}, \text{Address}, \text{TeacherEmail}, \text{TeacherName}, \text{ClassName}, \text{Section}, \text{AcademicYear}, \underline{\text{AdmissionNo}}, \text{StudentName}, \text{DOB}, \text{GuardianName}, \{\text{GuardianPhones}\}, \underline{\text{SessionDate}}, \text{AttendanceStatus}, \text{AttendanceMethod}, \text{FeeCategory}, \text{TotalFeeAmount}, \{\text{InstallmentNo, DueDate, InstAmount}\}, \text{PaidAmount}, \{\text{Subject, MaxMarks, MarksObtained}\})$$

*(Note: Curly braces $\{\dots\}$ represent repeating groups / multi-valued attributes).*

### 2.2. Critical Operational Anomalies in UNF

#### A. Insertion Anomaly (Cannot insert data without unrelated entities)
1. **Unassigned Teacher:** A newly appointed teacher cannot be registered into the system until they are assigned to an active class containing enrolled students with an attendance session.
2. **New Fee Structure:** The administration cannot establish a fee structure for the upcoming academic year until a student is billed and makes a payment.
3. **Empty Class:** A newly constructed classroom or grade section (e.g., "Class 9-B") cannot be created without enrolling at least one student.

#### B. Deletion Anomaly (Deleting one fact inadvertently destroys others)
1. **Student Dropout:** If the only student enrolled in a specialized class section withdraws from the school, deleting their record unintentionally deletes the class entity, its teacher assignment record, and the syllabus fee schedule.
2. **Purging Old Attendance:** If the school archives or purges attendance records from three years prior, all historical student profile details, guardian telephone numbers, and teacher associations present only on those rows are permanently destroyed.

#### C. Update / Modification Anomaly (Data inconsistency during partial updates)
1. **Teacher Particulars:** If Teacher "Ramesh Kumar" updates his mobile number or legal name, this update must be executed across tens of thousands of historical daily attendance rows. If the database crashes midway, "Ramesh Kumar" will exist with contradictory information across different historical sessions.
2. **Fee Rate Alteration:** If the institutional development fee is revised, every un-normalized student row must be individually edited, leading to catastrophic billing discrepancies if a row is missed.

---

## 3. Catalog of Functional Dependencies (FDs)

Let $\mathcal{U}$ represent the universal set of attributes. The real-world operational rules of ShikshaTrack establish the following set of non-trivial **Functional Dependencies ($F$)**:

```
┌────────────────────────────────────────────────────────────────────────┐
│                   Core Functional Dependencies (FDs)                   │
├───────┬────────────────────────────────────────────────────────────────┤
│ FD 1  │ SchoolCode → SchoolId, SchoolName, Address, ContactPhone       │
│ FD 2  │ UserEmail → UserId, UserName, PasswordHash, Role, SchoolId     │
│ FD 3  │ (SchoolId, ClassName, Section, AcademicYear) → ClassId         │
│ FD 4  │ (TeacherId, ClassId) → AssignmentId, IsClassTeacher, AssignedAt│
│ FD 5  │ (SchoolId, AdmissionNumber) → StudentId, StudentName, ClassId, │
│       │                               QRToken, Gender, DOB             │
│ FD 6  │ QRToken → StudentId, SchoolId, AdmissionNumber                 │
│ FD 7  │ (ClassId, SessionDate) → SessionId, TeacherId, SessionStatus   │
│ FD 8  │ (SessionId, StudentId) → RecordId, Status, Method, MarkedAt    │
│ FD 9  │ (SchoolId, AcademicYear, FeeCategory) → FeeStructureId, Total  │
│ FD 10 │ (StudentId, FeeStructureId) → StudentFeeId, NetAmount, Balance │
│ FD 11 │ (StudentFeeId, InstallmentNo) → InstallmentId, DueDate, Amount │
│ FD 12 │ ReceiptNumber → PaymentId, StudentFeeId, AmountPaid, Method    │
│ FD 13 │ (ExaminationId, Subject) → ExamSubjectId, MaxMarks, PassMarks  │
│ FD 14 │ (ExamSubjectId, StudentId) → MarkId, MarksObtained, Remarks    │
│ FD 15 │ LeaveId → StudentId, ClassId, StartDate, EndDate, Status       │
│ FD 16 │ (LeaveId) → DecisionId, ReviewerId, Action, DecidedAt          │
└───────┴────────────────────────────────────────────────────────────────┘
```

---

## 4. Step-by-Step Normalization Process

### 4.1. First Normal Form (1NF)
> **Definition:** A relation $R$ is in First Normal Form (1NF) if and only if all underlying attribute domains contain only **atomic (indivisible) values**, and there are **no repeating groups or arrays**.

#### Violations in UNF:
1. `GuardianPhones` contained multiple telephone numbers (e.g., `["9876543210", "9876543211"]`).
2. Repeating groups existed for `Installments` (`{InstallmentNo, DueDate, InstAmount}`) and `ExamMarks` (`{Subject, MaxMarks, MarksObtained}`).

#### 1NF Transformation:
- Multi-valued telephone numbers and arrays are decomposed into atomic, single-valued columns.
- Repeating installment and examination groups are separated into discrete row entries.
- A composite primary key is established to uniquely identify each atomic row:
  $$\text{PK} = \{\text{SchoolCode}, \text{ClassName}, \text{Section}, \text{AdmissionNo}, \text{SessionDate}, \text{FeeCategory}, \text{Subject}\}$$

While 1NF achieves value atomicity, it suffers from severe **partial key dependencies**, as non-prime attributes depend on only parts of the gigantic composite primary key.

---

### 4.2. Second Normal Form (2NF)
> **Definition:** A relation $R$ is in Second Normal Form (2NF) if and only if it is in **1NF** and **no non-prime attribute is partially dependent on any candidate key**. That is, every non-prime attribute must depend on the **whole candidate key**.

#### Analysis of Partial Dependencies in 1NF:
In our 1NF relation, the candidate key is composite: $\{\text{SessionId}, \text{StudentId}, \text{FeeStructureId}, \text{ExamSubjectId}\}$.
Notice the following partial dependencies:
- $\{\text{StudentId}\} \rightarrow \text{StudentName}, \text{DOB}, \text{Gender}$ (Depends only on `StudentId`, not on `SessionId` or `FeeStructureId`).
- $\{\text{SessionId}\} \rightarrow \text{SessionDate}, \text{SessionStatus}, \text{TeacherId}$ (Depends only on `SessionId`).
- $\{\text{FeeStructureId}\} \rightarrow \text{FeeCategory}, \text{TotalAmount}$ (Depends only on `FeeStructureId`).
- $\{\text{ExamSubjectId}\} \rightarrow \text{SubjectName}, \text{MaxMarks}, \text{PassMarks}$ (Depends only on `ExamSubjectId`).

#### 2NF Decomposition:
To eliminate partial dependencies, we decompose the relation so that attributes functionally dependent on partial keys are placed into their own relations where those partial keys become full primary keys:

1. **`STUDENTS_2NF`** ($\underline{\text{StudentId}}$, $\text{AdmissionNumber}$, $\text{Name}$, $\text{DOB}$, $\text{Gender}$, $\text{ClassId}$, $\text{SchoolId}$)
   - Key: `StudentId`
   - All student attributes depend entirely on `StudentId`.
2. **`ATTENDANCE_SESSIONS_2NF`** ($\underline{\text{SessionId}}$, $\text{ClassId}$, $\text{TeacherId}$, $\text{SessionDate}$, $\text{Status}$)
   - Key: `SessionId`
   - All session attributes depend entirely on `SessionId`.
3. **`ATTENDANCE_RECORDS_2NF`** ($\underline{\text{SessionId}}, \underline{\text{StudentId}}$, $\text{Status}$, $\text{Method}$, $\text{MarkedAt}$)
   - Key: $\{\text{SessionId}, \text{StudentId}\}$
   - Non-prime attributes (`Status`, `Method`, `MarkedAt`) depend on the **entire composite key**.
4. **`FEE_STRUCTURES_2NF`** ($\underline{\text{FeeStructureId}}$, $\text{SchoolId}$, $\text{ClassId}$, $\text{Category}$, $\text{TotalAmount}$)
5. **`EXAM_SUBJECTS_2NF`** ($\underline{\text{ExamSubjectId}}$, $\text{ExaminationId}$, $\text{Subject}$, $\text{MaxMarks}$, $\text{PassMarks}$)
6. **`EXAM_MARKS_2NF`** ($\underline{\text{ExamSubjectId}}, \underline{\text{StudentId}}$, $\text{MarksObtained}$, $\text{Remarks}$)

All partial dependencies are completely eliminated. The schema is now in **2NF**.

---

### 4.3. Third Normal Form (3NF)
> **Definition:** A relation $R$ is in Third Normal Form (3NF) if and only if it is in **2NF** and **no non-prime attribute is transitively dependent on the primary key**.
> Formally, for every non-trivial functional dependency $X \rightarrow Y$:
> 1. $X$ is a superkey of $R$, OR
> 2. $Y$ is a prime attribute (part of a candidate key).

#### Analysis of Transitive Dependencies in 2NF:
Even though partial dependencies were eliminated, transitive dependencies ($X \rightarrow Y$ and $Y \rightarrow Z$, where $X$ is the primary key and $Y$ is not a superkey) persist in 2NF tables:

1. **In `STUDENTS_2NF`:**
   $$\text{StudentId} \rightarrow \text{ClassId} \quad \text{and} \quad \text{ClassId} \rightarrow \text{ClassName}, \text{Section}, \text{AcademicYear}$$
   $$\text{ClassId} \rightarrow \text{SchoolId} \quad \text{and} \quad \text{SchoolId} \rightarrow \text{SchoolName}, \text{SchoolAddress}$$
   - `StudentId` transitively determines `ClassName` and `SchoolName` through `ClassId` and `SchoolId`.
2. **In `FEE_PAYMENTS_2NF`:**
   $$\text{PaymentId} \rightarrow \text{StudentFeeId} \quad \text{and} \quad \text{StudentFeeId} \rightarrow \text{FeeStructureId} \rightarrow \text{Category}, \text{TotalFeeAmount}$$
   - `PaymentId` transitively determines fee category and base tariff through `StudentFeeId`.
3. **In `EXAM_MARKS_2NF`:**
   $$\text{MarkId} \rightarrow \text{ExamSubjectId} \quad \text{and} \quad \text{ExamSubjectId} \rightarrow \text{ExaminationId} \rightarrow \text{ExamName}, \text{ExamType}$$
   - `MarkId` transitively determines examination name and academic year through `ExamSubjectId`.

#### 3NF Decomposition:
We eliminate transitive dependencies by extracting intermediate determinants ($Y$) into independent relation schemas where $Y$ becomes the primary key:

```
Decomposition of Transitive Chains:
──────────────────────────────────────────────────────────────────────────
[STUDENTS]      StudentId → ClassId (FK)
                    │
                    ▼
[CLASSES]       ClassId → SchoolId (FK), Name, Section, AcademicYear
                    │
                    ▼
[SCHOOLS]       SchoolId → Name, Code, Address, ContactPhone
──────────────────────────────────────────────────────────────────────────
[EXAM_MARKS]    MarkId → ExamSubjectId (FK), StudentId (FK), MarksObtained
                    │
                    ▼
[EXAM_SUBJECTS] ExamSubjectId → ExaminationId (FK), Subject, MaxMarks, PassMarks
                    │
                    ▼
[EXAMINATIONS]  ExaminationId → SchoolId (FK), Name, ExamType, AcademicYear
──────────────────────────────────────────────────────────────────────────
```

#### Final 3NF Relations Created:
1. **`schools`** ($\underline{\text{id}}$, $\text{name}$, $\text{code}$, $\text{address}$, $\text{contactEmail}$, $\text{contactPhone}$)
2. **`users`** ($\underline{\text{id}}$, $\text{name}$, $\text{email}$, $\text{passwordHash}$, $\text{role}$, $\text{schoolId}$)
3. **`classes`** ($\underline{\text{id}}$, $\text{name}$, $\text{section}$, $\text{academicYear}$, $\text{schoolId}$)
4. **`teacher_assignments`** ($\underline{\text{id}}$, $\text{teacherId}$, $\text{classId}$, $\text{isClassTeacher}$)
5. **`students`** ($\underline{\text{id}}$, $\text{name}$, $\text{admissionNumber}$, $\text{rollNumber}$, $\text{classId}$, $\text{schoolId}$, $\text{qrToken}$)
6. **`attendance_sessions`** ($\underline{\text{id}}$, $\text{classId}$, $\text{teacherId}$, $\text{sessionDate}$, $\text{status}$)
7. **`attendance_records`** ($\underline{\text{id}}$, $\text{sessionId}$, $\text{studentId}$, $\text{status}$, $\text{method}$, $\text{markedAt}$)
8. **`fee_structures`** ($\underline{\text{id}}$, $\text{schoolId}$, $\text{classId}$, $\text{name}$, $\text{academicYear}$, $\text{category}$, $\text{totalAmount}$)
9. **`student_fees`** ($\underline{\text{id}}$, $\text{studentId}$, $\text{feeStructureId}$, $\text{netAmount}$, $\text{paidAmount}$, $\text{balanceAmount}$)
10. **`fee_installments`** ($\underline{\text{id}}$, $\text{studentFeeId}$, $\text{installmentNumber}$, $\text{amount}$, $\text{dueDate}$, $\text{status}$)
11. **`fee_payments`** ($\underline{\text{id}}$, $\text{studentFeeId}$, $\text{studentId}$, $\text{receiptNumber}$, $\text{amountPaid}$, $\text{paymentMethod}$)
12. **`payment_allocations`** ($\underline{\text{id}}$, $\text{feePaymentId}$, $\text{feeInstallmentId}$, $\text{allocatedAmount}$)
13. **`examinations`** ($\underline{\text{id}}$, $\text{schoolId}$, $\text{name}$, $\text{examType}$, $\text{academicYear}$, $\text{startDate}$)
14. **`exam_subjects`** ($\underline{\text{id}}$, $\text{examinationId}$, $\text{subject}$, $\text{maxMarks}$, $\text{passMarks}$)
15. **`exam_marks`** ($\underline{\text{id}}$, $\text{examSubjectId}$, $\text{studentId}$, $\text{marksObtained}$)

Every non-prime attribute in these tables depends directly, fully, and non-transitively on its primary key. Thus, **the schema satisfies Third Normal Form (3NF)**.

---

## 5. Boyce-Codd Normal Form (BCNF) Analysis

> **Definition:** A relation $R$ is in Boyce-Codd Normal Form (BCNF) if and only if for every non-trivial functional dependency $X \rightarrow Y$, **$X$ is a superkey** of $R$.
> BCNF is a stricter version of 3NF that eliminates anomalies when a table has multiple overlapping candidate keys.

### Evaluating Candidate Keys in ShikshaTrack:
Let us inspect the relations that possess multiple candidate keys:

#### 1. Entity `users`:
- Candidate Keys: $K_1 = \{\text{id}\}$, $K_2 = \{\text{email}\}$.
- Functional Dependencies:
  - $\text{id} \rightarrow \text{name}, \text{email}, \text{passwordHash}, \text{role}, \text{schoolId}$ (Here, `id` is a superkey).
  - $\text{email} \rightarrow \text{id}, \text{name}, \text{passwordHash}, \text{role}, \text{schoolId}$ (Here, `email` is a superkey).
- **Result:** In all FDs, the determinant is a superkey. **Satisfies BCNF.**

#### 2. Entity `classes`:
- Candidate Keys: $K_1 = \{\text{id}\}$, $K_2 = \{\text{schoolId}, \text{name}, \text{section}, \text{academicYear}\}$.
- Functional Dependencies:
  - $\text{id} \rightarrow \text{schoolId}, \text{name}, \text{section}, \text{academicYear}$ (`id` is a superkey).
  - $\{\text{schoolId}, \text{name}, \text{section}, \text{academicYear}\} \rightarrow \text{id}$ (Composite set is a superkey).
- **Result:** Every determinant is a superkey. **Satisfies BCNF.**

#### 3. Entity `attendance_records`:
- Candidate Keys: $K_1 = \{\text{id}\}$, $K_2 = \{\text{sessionId}, \text{studentId}\}$.
- Functional Dependencies:
  - $\text{id} \rightarrow \text{sessionId}, \text{studentId}, \text{status}, \text{method}, \text{markedAt}$ (`id` is a superkey).
  - $\{\text{sessionId}, \text{studentId}\} \rightarrow \text{id}, \text{status}, \text{method}, \text{markedAt}$ (Composite set is a superkey via `UNIQUE` constraint).
- **Result:** Every determinant is a superkey. **Satisfies BCNF.**

#### 4. Entity `students`:
- Candidate Keys: $K_1 = \{\text{id}\}$, $K_2 = \{\text{schoolId}, \text{admissionNumber}\}$, $K_3 = \{\text{qrToken}\}$.
- Functional Dependencies:
  - $\text{id} \rightarrow \text{schoolId}, \text{admissionNumber}, \text{name}, \text{qrToken}, \dots$ (`id` is superkey).
  - $\{\text{schoolId}, \text{admissionNumber}\} \rightarrow \text{id}, \text{name}, \text{qrToken}, \dots$ (Composite key is superkey).
  - $\text{qrToken} \rightarrow \text{id}, \text{schoolId}, \text{admissionNumber}, \text{name}, \dots$ (`qrToken` is superkey).
- **Result:** Every determinant is a superkey. **Satisfies BCNF.**

### Conclusion of BCNF Test:
Because every non-trivial functional dependency $X \rightarrow Y$ across all 39 entities has a determinant $X$ that is a superkey, **the entire ShikshaTrack database schema satisfies BCNF**.

---

## 6. Mathematical Guarantees: Lossless Join & Dependency Preservation

### 6.1. Lossless Join Property Verification
A decomposition of relation $R$ into $R_1$ and $R_2$ is **lossless** with respect to functional dependency set $F$ if and only if the common attributes contain a candidate key for at least one of the decomposed relations:

$$(R_1 \cap R_2) \rightarrow R_1 \quad \text{OR} \quad (R_1 \cap R_2) \rightarrow R_2$$

#### Proof Example: Decomposition of Student & Class:
- $R = \text{STUDENT\_CLASS}(\text{studentId}, \text{name}, \text{admissionNo}, \text{classId}, \text{className}, \text{section})$
- Decomposed into:
  - $R_1 = \text{STUDENTS}(\underline{\text{studentId}}, \text{name}, \text{admissionNo}, \text{classId})$
  - $R_2 = \text{CLASSES}(\underline{\text{classId}}, \text{className}, \text{section})$
- Intersection: $R_1 \cap R_2 = \{\text{classId}\}$.
- Functional Dependency: $\{\text{classId}\} \rightarrow \{\text{className}, \text{section}\} = R_2$.
- Since $R_1 \cap R_2 \rightarrow R_2$, the decomposition is **guaranteed to be strictly lossless**. A relational natural join $R_1 \bowtie R_2$ reconstructs the exact original tuple set with zero spurious rows.

### 6.2. Dependency Preservation Verification
A decomposition is **dependency-preserving** if the union of functional dependencies enforceable in the individual decomposed relations is equivalent to the original functional dependency set $F$:

$$\left( \bigcup_{i=1}^{n} F_{R_i} \right)^+ = F^+$$

In our schema:
- Every functional dependency $FD_1$ through $FD_{16}$ is enforced directly within a single relation through a primary key, unique constraint, or foreign key constraint.
- No functional dependency spans across decomposed tables without being enforced by a local primary key.
- Hence, **dependency preservation is 100% satisfied**.

---

## 7. Summary Comparison Matrix: UNF to 3NF/BCNF

| Normal Form | Condition Met | Anomalies Eliminated | ShikshaTrack Status |
| :--- | :--- | :--- | :---: |
| **UNF** | Raw un-normalized universal spreadsheet. | None (suffers from severe insert, update, and delete anomalies). | Replaced |
| **1NF** | Atomic values; no repeating groups; candidate key defined. | Eliminates non-atomic storage and parsing bugs. | Passed |
| **2NF** | In 1NF + zero partial dependencies on composite keys. | Eliminates student/session duplication across mark rows. | Passed |
| **3NF** | In 2NF + zero transitive dependencies ($X \rightarrow Y \rightarrow Z$). | Eliminates class/school duplication in student records. | Passed |
| **BCNF** | Every determinant is a superkey. | Eliminates overlapping candidate key anomalies. | **Fully Certified** |

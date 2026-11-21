# 07. Database and Application Integration Evidence
## Subject: Data Engineering (DE) – Section F
### Project: ShikshaTrack (Smart Attendance & School Management System)

---

## 1. System Integration Architecture

The **ShikshaTrack** software architecture integrates an Express.js MVC monolith with a PostgreSQL 18 relational database engine using **Prisma ORM (v6.19.3)** as the primary data access layer.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        ShikshaTrack Application Stack                  │
└────────────────────────────────────────────────────────────────────────┘
                                 │
                   HTTP / REST API (/api/v1)
                                 │
                                 ▼
┌────────────────────────────────────────────────────────────────────────┐
│                     Express.js Controller Layer                        │
│  - Parameter validation, authorization middleware, route dispatching   │
└────────────────────────────────────────────────────────────────────────┘
                                 │
                        Internal Service Call
                                 │
                                 ▼
┌────────────────────────────────────────────────────────────────────────┐
│                      Business Logic Service Layer                      │
│  - attendanceService.js, feeService.js, examService.js, syncService.js │
└────────────────────────────────────────────────────────────────────────┘
                                 │
                    Prisma Client Query Engine
                                 │
                                 ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   PostgreSQL 18 Database Engine                        │
│  - Connection pooling, ACID transactions ($transaction), B-tree indexes │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Backend-Database Communication & Connection Pooling

### 2.1. Prisma Client Singleton & Dynamic Datasource Resolution
To prevent connection exhaustion under high concurrency (e.g., hundreds of teachers simultaneously submitting morning roll calls), the backend establishes a thread-safe singleton connection pool in [`backend/src/config/db.js`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/backend/src/config/db.js):

```javascript
// File: backend/src/config/db.js
import dotenv from 'dotenv';
dotenv.config();
import { PrismaClient } from '@prisma/client';

let prisma;

const getDatasourceUrl = () => {
  if (process.env.NODE_ENV === 'test' && (process.env.LOCAL_DATABASE_URL || process.env.TEST_DATABASE_URL)) {
    return process.env.LOCAL_DATABASE_URL || process.env.TEST_DATABASE_URL;
  }
  return process.env.DATABASE_URL;
};

const resolvedUrl = getDatasourceUrl();
const clientOptions = resolvedUrl ? { datasources: { db: { url: resolvedUrl } } } : {};

if (process.env.NODE_ENV === 'production') {
  prisma = new PrismaClient(clientOptions);
} else {
  // Prevent multiple client instances during developer nodemon hot-reloads
  if (!global.__prismaClient) {
    global.__prismaClient = new PrismaClient({
      ...clientOptions,
      log: ['error', 'warn'],
    });
  }
  prisma = global.__prismaClient;
}

export default prisma;
```

### 2.2. SQL Injection Prevention via Parameterized Queries
All interactions with PostgreSQL—whether using Prisma models or raw queries (`prisma.$queryRaw`)—utilize **prepared statements and parameterized bindings**. User input is never concatenated directly into SQL text, rendering SQL injection attacks impossible.

---

## 3. End-to-End Traces of CRUD Operations

### 3.1. Create (INSERT): Cryptographic QR Code Attendance Scan
- **API Endpoint:** `POST /api/v1/attendance/sessions/:id/scan`
- **Route Controller:** `attendanceController.scanQrCode`
- **Service Logic:** [`backend/src/services/attendanceService.js`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/backend/src/services/attendanceService.js)

```javascript
// Excerpt from backend/src/services/attendanceService.js
export const scanQrCode = async ({ sessionId, qrToken, schoolId, teacherId, status = 'PRESENT' }) => {
  // 1. Verify session is OPEN and belongs to teacher's school
  const session = await prisma.attendanceSession.findFirst({
    where: { id: sessionId, class: { schoolId } },
    include: { class: true },
  });
  if (!session) throw new Error('Attendance session not found.');
  if (session.status !== 'OPEN') throw new Error('Session is closed.');

  // 2. Resolve cryptographic QR token to student
  const student = await prisma.student.findUnique({
    where: { qrToken },
  });
  if (!student || student.schoolId !== schoolId || student.classId !== session.classId) {
    throw new Error('Invalid QR Code or student does not belong to this class.');
  }

  // 3. Upsert attendance record (Atomic INSERT with ON CONFLICT)
  const record = await prisma.attendanceRecord.upsert({
    where: {
      sessionId_studentId: {
        sessionId,
        studentId: student.id,
      },
    },
    update: {
      status,
      method: 'QR',
      markedAt: new Date(),
      remarks: 'Scanned via camera viewfinder',
    },
    create: {
      sessionId,
      studentId: student.id,
      status,
      method: 'QR',
      markedAt: new Date(),
      remarks: 'Scanned via camera viewfinder',
    },
  });

  return { student, record };
};
```
**Database Reflection:** Executes an `INSERT ... ON CONFLICT ("sessionId", "studentId") DO UPDATE` into the `attendance_records` table, guaranteeing that rapid or duplicate scans update the existing row rather than generating duplicate entries.

---

### 3.2. Read (SELECT): Relational Join Query for Classroom Sessions
- **API Endpoint:** `GET /api/v1/attendance/sessions/:id`
- **Service Logic:** [`backend/src/services/attendanceService.js`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/backend/src/services/attendanceService.js)

```javascript
// Excerpt from backend/src/services/attendanceService.js
export const getSessionDetails = async (sessionId, schoolId) => {
  const session = await prisma.attendanceSession.findFirst({
    where: { id: sessionId, class: { schoolId } },
    include: {
      class: {
        include: {
          students: {
            where: { active: true },
            orderBy: [{ rollNumber: 'asc' }, { name: 'asc' }],
          },
        },
      },
      teacher: { select: { id: true, name: true, email: true } },
      attendanceRecords: {
        include: {
          student: { select: { id: true, name: true, rollNumber: true, admissionNumber: true } },
        },
      },
    },
  });
  return session;
};
```
**Database Reflection:** Generates an optimized multi-table SQL query joining `attendance_sessions`, `classes`, `students`, `users`, and `attendance_records` in a single roundtrip.

---

### 3.3. Update (UPDATE): Administrative Correction with Audit Logging
- **API Endpoint:** `PATCH /api/v1/attendance/records/:id`
- **Service Logic:** [`backend/src/services/attendanceService.js`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/backend/src/services/attendanceService.js)

```javascript
// Excerpt from backend/src/services/attendanceService.js
export const correctAttendanceRecord = async ({ recordId, status, remarks, reason, actorId, schoolId }) => {
  const existingRecord = await prisma.attendanceRecord.findUnique({
    where: { id: recordId },
    include: { session: { include: { class: true } } },
  });
  if (!existingRecord) throw new Error('Record not found.');

  // Update attendance record status
  const updatedRecord = await prisma.attendanceRecord.update({
    where: { id: recordId },
    data: {
      status,
      remarks: remarks || existingRecord.remarks,
    },
  });

  // Log administrative audit snapshot
  await logAudit({
    actorId,
    action: 'ATTENDANCE_CORRECTED',
    entityType: 'AttendanceRecord',
    entityId: recordId,
    previousValue: JSON.stringify({ status: existingRecord.status, remarks: existingRecord.remarks }),
    newValue: JSON.stringify({ status, remarks: updatedRecord.remarks }),
    reason: reason || 'Administrative correction',
  });

  return updatedRecord;
};
```
**Database Reflection:** Updates the target row in `attendance_records` and immediately inserts an audit record in `audit_logs` capturing the previous and new states.

---

### 3.4. Delete (DELETE): Removing Timetable Scheduling Conflicts
- **API Endpoint:** `DELETE /api/v1/timetable/entries/:id`
- **Service Logic:** Calls `prisma.timetableEntry.delete({ where: { id } })`.
- **Database Reflection:** Executes `DELETE FROM timetable_entries WHERE id = $1`, enforcing that related entities remain unharmed due to referential key integrity.

---

## 4. Multi-Table ACID Transactions (`$transaction`)

In financial accounting, recording a fee payment requires modifying multiple tables simultaneously. In [`backend/src/services/feeService.js`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/backend/src/services/feeService.js), ShikshaTrack executes an **interactive ACID transaction** via `prisma.$transaction(async (tx) => { ... })`:

```javascript
// Excerpt from backend/src/services/feeService.js
export const recordPayment = async ({
  schoolId,
  studentFeeId,
  amountPaid,
  paymentMethod = 'CASH',
  transactionReference = null,
  remarks = null,
  paymentDate = new Date(),
  recordedById = null,
}) => {
  // [Validation logic omitted for brevity]

  const paymentResult = await prisma.$transaction(async (tx) => {
    // Step 1: Insert Payment Receipt in fee_payments
    const payment = await tx.feePayment.create({
      data: {
        schoolId,
        studentFeeId,
        studentId: fee.studentId,
        receiptNumber,
        amountPaid: paymentAmount,
        paymentMethod,
        transactionReference,
        remarks,
        paymentDate: pDate,
        recordedById,
      },
    });

    // Step 2: Allocate amount across unpaid fee_installments sequentially
    let unallocated = paymentAmount;
    for (const inst of fee.installments) {
      if (unallocated <= 0) break;
      if (inst.balanceAmount <= 0) continue;

      const allocation = Math.min(unallocated, inst.balanceAmount);
      const newInstPaid = Math.round((inst.paidAmount + allocation) * 100) / 100;
      const newInstBal = Math.round((inst.balanceAmount - allocation) * 100) / 100;

      // Update individual fee installment balance and status
      await tx.feeInstallment.update({
        where: { id: inst.id },
        data: {
          paidAmount: newInstPaid,
          balanceAmount: newInstBal,
          status: newInstBal <= 0 ? 'PAID' : 'PARTIAL',
          paidAt: newInstBal <= 0 ? pDate : inst.paidAt,
        },
      });

      // Insert junction record in payment_allocations
      await tx.paymentAllocation.create({
        data: {
          feePaymentId: payment.id,
          feeInstallmentId: inst.id,
          allocatedAmount: allocation,
        },
      });

      unallocated = Math.round((unallocated - allocation) * 100) / 100;
    }

    // Step 3: Update overarching student_fees balance
    const updatedPaid = Math.round((fee.paidAmount + paymentAmount) * 100) / 100;
    const updatedBal = Math.round((fee.netAmount - updatedPaid) * 100) / 100;

    await tx.studentFee.update({
      where: { id: fee.id },
      data: {
        paidAmount: updatedPaid,
        balanceAmount: updatedBal,
        status: updatedBal <= 0 ? 'PAID' : 'PARTIAL',
      },
    });

    return payment;
  });

  return paymentResult;
};
```

### Transaction Integrity Guarantee:
If the server loses power or a network drop occurs during Step 2, PostgreSQL automatically issues an internal `ROLLBACK`. No partial installment update is persisted, and no phantom payment receipt is created.

---

## 5. Offline Synchronization & Idempotent Conflict Resolution

In rural zones without reliable cellular connectivity, teachers mark attendance in a Progressive Web App (PWA) storing records in client-side IndexedDB (`ShikshaTrackOfflineDB`).

When connectivity is restored, the batch is uploaded to `POST /api/v1/sync/batch`. In [`backend/src/services/syncService.js`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/backend/src/services/syncService.js):

1. **Client Operation Idempotency:** Each offline mark carries a client-generated UUID `operationId`. The backend checks the `sync_operations` table. If the `operationId` is already marked `SYNCED`, the backend safely returns the existing success status without duplicate execution.
2. **Conflict Resolution:** If a record was modified concurrently on the cloud while the teacher was offline, the operation enters `CONFLICT` status, storing divergent versions in `sync_operations.conflictData` for administrative review.
3. **Database Upsert:** Valid records execute `prisma.attendanceRecord.upsert(...)` using the composite unique key `@@unique([sessionId, studentId])`, ensuring that offline marks overwrite stale records cleanly.

---

## 6. Integration Test Suite Evidence

The integration between Express.js and PostgreSQL is continuously verified by **22 automated integration test suites** located in [`backend/tests/`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/backend/tests/):

```
backend/tests/
├── attendance.test.js          # Verifies session creation, QR scanning & upsert
├── attendanceAnalytics.test.js # Verifies aggregations, pass rates & percentages
├── fees.test.js                # Verifies $transaction multi-installment allocations
├── exams.test.js               # Verifies subject mark entry & grade computations
├── sync.test.js                # Verifies offline queue sync and conflict resolution
├── auth.test.js                # Verifies bcrypt hashing & role verification
├── leaves.test.js              # Verifies leave decision cascade
└── documents.test.js           # Verifies student document versioning & checksums
```

All integration suites test actual database schemas and verify that operations initiated through HTTP REST endpoints correctly mutate and persist records in PostgreSQL.

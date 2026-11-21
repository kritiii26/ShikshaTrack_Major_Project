# Data Engineering (DE) Integrated Project Submission
## Project: ShikshaTrack – AI-Powered Smart Attendance & School Management System

---

### Project Metadata
- **Project Title:** ShikshaTrack (AI-Powered Smart Attendance and School Management System for Rural Schools)
- **Subject:** Data Engineering (DE) / Database Management Systems (DBMS)
- **Database Engine:** PostgreSQL 18 (Relational DBMS)
- **Backend Architecture:** Node.js (v20+ / v25), Express.js (REST API v1), Prisma ORM (v6.19.3)
- **Frontend Architecture:** React 18, Vite, Tailwind CSS, Progressive Web App (PWA) with Offline IndexedDB Sync
- **Repository Folder:** `/DE`

---

## 1. Executive Summary & Compliance Overview

This folder contains the complete, rigorous, and exhaustive Data Engineering documentation, database schema definitions, sample seed datasets, analytical SQL query executions, and backend integration evidence for **ShikshaTrack**.

The database architecture has been designed from the ground up to address critical challenges in rural school administration: eliminating paper attendance registers, preventing proxy attendance via cryptographic QR codes, ensuring **100% offline resilience** with guaranteed transactional synchronization, calculating accurate statutory reports (such as **Mid-Day Meal (MDM)** ration quotas and the **Right to Education (RTE) 75% attendance threshold**), and managing complete fee, examination, and welfare operations.

Every requirement outlined in the **DE Integrated Project – Expectations and Submission Guidelines** has been fully designed, implemented, tested, and compiled herein.

---

## 2. Directory Structure & Deliverables Mapping

| Guideline Requirement | Corresponding Deliverable File | Description |
| :--- | :--- | :--- |
| **Section A:** Database Selection & Justification | [`01_database_selection_and_justification.md`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/DE/01_database_selection_and_justification.md) | Exhaustive evaluation of PostgreSQL vs MongoDB, nature of school data, ACID requirements, relational integrity, and schema justification. |
| **Section B:** ER Diagram & Data Modelling | [`02_er_diagram_and_data_modelling.md`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/DE/02_er_diagram_and_data_modelling.md) | Complete entity-attribute catalog, primary/foreign key mappings, 1:1, 1:N, M:N relationship mappings, and Mermaid visual ER diagrams. |
| **Section C:** Database Normalization | [`03_database_normalization.md`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/DE/03_database_normalization.md) | Formal normalization proofs up to 3NF/BCNF, functional dependencies ($FDs$), elimination of insert/update/delete anomalies, and losslessness proofs. |
| **Section D:** Database Implementation (DDL) | [`04_database_schema.sql`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/DE/04_database_schema.sql) | Standalone, production-grade executable PostgreSQL SQL DDL script creating all enums, tables, keys, constraints, and indexes. |
| **Section D:** Sample Records (DML) | [`05_sample_records.sql`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/DE/05_sample_records.sql) | Realistic Indian rural school SQL DML seed dataset across all entities (schools, users, classes, students, sessions, fees, exams, leaves, audit logs). |
| **Section E:** Project Queries & Execution (SQL) | [`06_project_queries_and_execution.sql`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/DE/06_project_queries_and_execution.sql) | Executable SQL script featuring 14 project-specific business queries covering CRUD, Aggregates, GROUP BY/HAVING, JOINs, Subqueries, CTEs, and Window Functions. |
| **Section E:** Query Explanations & Execution Outputs | [`06_project_queries_and_execution.md`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/DE/06_project_queries_and_execution.md) | In-depth companion document providing business rationale, relational algebra concepts, and verbatim PostgreSQL formatted execution outputs. |
| **Section F:** Database-Backend Integration | [`07_database_backend_integration.md`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/DE/07_database_backend_integration.md) | Evidence of application integration: Prisma ORM connection pooling, CRUD traces from Route -> Controller -> Service -> SQL, ACID transactions, and offline sync. |
| **Section G:** Data Integrity & Performance | [`08_database_architecture_and_performance.md`](file:///Users/faridabaddiegmail.com/Downloads/major/ShikshaTrack_Major_Project/DE/08_database_architecture_and_performance.md) | Constraints, deduplication, missing data handling, B-Tree/Composite indexing, `EXPLAIN ANALYZE` query plans, table partitioning, and archival strategy. |

---

## 3. Compliance Matrix

| Requirement from Submission Guidelines | Status | Implementation Evidence |
| :--- | :---: | :--- |
| **1. Database Selection (PostgreSQL or MongoDB)** | **COMPLIANT** | PostgreSQL 18 selected and rigorously justified over MongoDB in `01_database_selection_and_justification.md`. |
| **2. Justify database choice based on requirements** | **COMPLIANT** | Detailed 8-point justification covering ACID compliance, financial ledgers, relational integrity, and government reporting. |
| **3. Identify nature of stored data** | **COMPLIANT** | Classified data into relational core, financial ledgers, audit trails, and hybrid JSONB payloads. |
| **4. Entities, attributes, PKs, FKs, and relationships** | **COMPLIANT** | 39 distinct models defined, with all PKs, FKs, and cardinalities specified in `02_er_diagram_and_data_modelling.md`. |
| **5. Represent 1:1, 1:N, and M:N relationships** | **COMPLIANT** | 1:1 (`User`-`Parent`), 1:N (`Class`-`Student`), M:N (`TeacherAssignment`, `ParentStudent`, `PaymentAllocation`) implemented. |
| **6. ER Diagram representing proposed database structure** | **COMPLIANT** | Full Mermaid ER diagrams (Master + 4 Sub-domain diagrams) included in `02_er_diagram_and_data_modelling.md`. |
| **7. Identify data redundancy & anomalies** | **COMPLIANT** | Documented insertion, update, and deletion anomalies on unnormalized school registers in `03_database_normalization.md`. |
| **8. Demonstrate normalization up to 3NF** | **COMPLIANT** | Step-by-step transformations from UNF $\rightarrow$ 1NF $\rightarrow$ 2NF $\rightarrow$ 3NF with functional dependencies and BCNF analysis. |
| **9. Database implementation with tables & constraints** | **COMPLIANT** | Executable DDL script in `04_database_schema.sql` with enums, checks, foreign keys with CASCADE/RESTRICT, and unique constraints. |
| **10. Populate database with sample data** | **COMPLIANT** | Comprehensive SQL DML script in `05_sample_records.sql` with realistic Indian rural school records. |
| **11. Minimum 10 project-specific queries/operations** | **COMPLIANT** | **14 advanced queries** implemented in `06_project_queries_and_execution.sql` and documented with real outputs in `06_project_queries_and_execution.md`. |
| **12. Cover CRUD, Aggregates, GROUP BY, HAVING, JOINs, Subqueries** | **COMPLIANT** | All mandatory query patterns covered plus CTEs, Window Functions (`DENSE_RANK`, `LAG`), and Multi-Table aggregations. |
| **13. Database and backend application integration** | **COMPLIANT** | Documented in `07_database_backend_integration.md` with Prisma ORM mappings, transaction blocks, and test suite logs. |
| **14. Constraints, indexing, data integrity, and scaling** | **COMPLIANT** | Documented in `08_database_architecture_and_performance.md` with composite indexing, `EXPLAIN ANALYZE`, and partitioning designs. |

---

## 4. How to Execute the SQL Scripts

The SQL scripts in this folder are completely self-contained and can be executed directly in any PostgreSQL instance (version 14, 15, 16, 17, or 18):

```bash
# 1. Connect to PostgreSQL and create the database
createdb -U postgres shikshatrack_de

# 2. Execute the Database Schema DDL (creates all enums, tables, keys, and indexes)
psql -U postgres -d shikshatrack_de -f DE/04_database_schema.sql

# 3. Populate the Database with Sample Seed Records (DML)
psql -U postgres -d shikshatrack_de -f DE/05_sample_records.sql

# 4. Execute the 14 Project-Specific Business Queries
psql -U postgres -d shikshatrack_de -f DE/06_project_queries_and_execution.sql
```

All queries output formatted tables directly into the terminal, matching the documented outputs in `06_project_queries_and_execution.md`.

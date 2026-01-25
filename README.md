# <div align="center">**Evaluation of Oracle Virtual Private Database (VPD) Against Complex Access Control Policies**</div>

<p align="center">
  <img src="https://img.shields.io/badge/Query%20Language-SQL-blue?style=flat&logo=oracle&logoColor=white" />
  <img src="https://img.shields.io/badge/Database-Oracle-red?style=flat&logo=oracle&logoColor=white" />
  <img src="https://img.shields.io/badge/Security-VPD%20(Row--Level%20Access%20Control)-orange?style=flat" />
  <img src="https://img.shields.io/badge/Benchmark-TPC--H-green?style=flat" />
</p>

## **1. System Overview**

This project evaluates the effectiveness and performance of **Oracle Virtual Private Database (VPD)** in enforcing **fine-grained, row-level access control policies** under complex query workloads.

Oracle VPD dynamically appends security predicates to SQL queries in `where` clause at runtime, ensuring that users can access only authorized rows without modifying application logic.

---
## **2. Loading TPC-H DB**
*Location: `src/loader.py*
- Generates 1 GB TPC-H data using DuckDB's dbgen
- Exports generated tables to Parquet files
- Creates TPC-H tables in Oracle with correct PK/FK constraints
- Loads tables into Oracle in foreign-key-safe order
- Uses batch inserts to ensure efficient loading
---

## **3. Test User Creation**
*Location: `src/UserCreation.sql*
- Creates a role TPCH_END_USERS with SELECT privileges on all TPC-H tables and ability to create views.
- Creates a test user TPCH_USER with login privileges and assigns the TPCH_END_USERS role.
- Creates a USER_ROLE_MAP table linking session users to their logical roles; application context TPCH_CTX is set at logon via trigger TPCH_LOGON_TRG.
- Logon triggers automatically set role (TPCH_CTX) context for each session to enforce row-level VPD access.

---

## **4. Test RLS policies**
*Location: `src/Policies.sql*
- Each policy is implemented as a PL/SQL function returning a WHERE clause that constrains visible rows for a table based on the session context.
- Policy functions dynamically inspect SYS_CONTEXT('TPCH_CTX','ROLE') to enforce restrictions specifically for TPCH_END_USERS while leaving other roles unrestricted.
- Policies are registered using DBMS_RLS.ADD_POLICY with CONTEXT_SENSITIVE type, enabling predicate caching when SYS_CONTEXT remains same.
---

## 5. Analysis Methodology

The analysis phase quantifies the computational cost of row-level security on a standardized TPC-H decision-support workload and `executed_plans` dir contains images of actual plans and overheads for TPC-H queries for the following analysis cases.

### Baseline Measurement 
To establish a performance ceiling, all 20 **TPC-H benchmark queries** are executed on the Oracle instance under the following conditions:
* **Indexing:** Only Primary Key (PK) indexes are enabled.
* **Security:** No **Virtual Private Database (VPD)** policies are applied.
* **Metrics:** Data is captured for **Buffer Gets**, **Physical Reads** and **Execution Latency**.

### Execution Plan & Runtime Inspection
During query execution, the delta between theoretical and actual execution behavior is analyzed using:
* **Optimizer Estimates (`EXPLAIN PLAN`):** To capture the Cost-Based Optimizer's (CBO) predicted execution paths and cardinality.
* **Runtime Statistics:** Utilizing `DBMS_XPLAN.DISPLAY_CURSOR` with the `ALLSTATS LAST` hint to extract real-time row counts, operator-level costs, and memory usage.

### Incremental Policy Evaluation
* VPD overhead is isolated by enabling security policies sequentially.
* Simple `COUNT(*)` operations are executed on protected tables to measure the latency introduced by row-level security filter in isolation.

### Complex Workload Impact
The TPC-H queries are executed with active VPD policies to observe latency overhead. Key focus areas include:
* **Join Reordering:** Whether the added predicate reorder join.
* **Predicate Pushdown:** Evaluation of whether the security filter is successfully pushed into subqueries or view definitions.
* **Cardinality Misestimates:** Identifying if security predicates lead to suboptimal plan choices due to inaccurate row-count predictions.

### Optimization
This final phase evaluates RLS with indexing:
* **Indexing Strategy:** Composite and simple indexes are applied specifically to columns referenced in VPD predicates.
* **Policy in isolation:** Each Oracle RLS policy is enabled sequentially and overhead is evaluated.
* **Multiple policies:** Multiple compatible policies are enabled simultaneouly and overhead is evaluated.
  

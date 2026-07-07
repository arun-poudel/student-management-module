# Business Central Database Backup — Full Course
### From SQL Server fundamentals → BC on-prem vs cloud → Azure infrastructure → hands-on SSMS for HRMS/banking data

Context for this course: you're at Agile Solutions, working on HRMS for bank clients (NIMB, Prabhu Bank) on BC252. This is exactly the kind of environment where backup discipline matters most — you're holding employee financial/HR data for regulated institutions. Treat this as production-adjacent from day one.

---

## Part 1 — How SQL Server Actually Stores Data

Before backup makes sense, you need the storage model in your head. BC doesn't invent its own storage — it sits entirely on top of SQL Server.

### 1.1 Physical files

Every SQL Server database is (at minimum) two files on disk:

| File | Extension | Purpose |
|---|---|---|
| Primary data file | `.mdf` | Holds actual table/index data |
| Secondary data file(s) | `.ndf` | Optional, used to spread data across disks |
| Transaction log file | `.ldf` | Records every change before it's committed (write-ahead logging) |

**Key concept — Write-Ahead Logging (WAL):** SQL Server never writes a change directly to the `.mdf` first. It writes the change to the `.ldf` transaction log, confirms it's durable, *then* eventually flushes it to the data file during a checkpoint. This is why the transaction log is the single most important file for backup/recovery — it's the source of truth for "what happened and when."

### 1.2 Pages and extents

- Data is stored in **8 KB pages** — the smallest unit SQL Server reads/writes.
- 8 contiguous pages = 1 **extent** (64 KB).
- Every BC table maps to one or more of these pages under the hood. When you create Table 50801 in AL, SQL Server creates a real physical table and allocates pages for it — same as any other SQL table.

### 1.3 How BC organizes tables inside SQL Server

This is the part that trips up most new BC developers coming from a pure-code background:

- One **BC database** = one SQL Server database (e.g., `NIMB-HRMS-Prod`).
- Inside it, **every company** you see in BC (Cronus, or "NIMB HQ", "Prabhu Bank Branch A") is **not a separate database** — it's a naming prefix on the same physical tables.
- A BC table is materialized in SQL as something like:
  ```
  [CompanyName$Table Caption]
  ```
  e.g. `NIMB HQ$Employee`, `NIMB HQ$Student Enrollment`
- System tables (not company-specific) don't have that prefix — e.g. `User`, `Object Metadata`, `Company`.

You can verify this yourself right now in SSMS:
```sql
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME LIKE '%Employee%'
ORDER BY TABLE_NAME;
```

This matters for backup because **you cannot back up "just one company."** A SQL backup is always the whole database — all companies, all tables, all objects, together. If NIMB and Prabhu Bank ever sat in the same BC database (they usually won't for a bank client — more likely separate databases per client for isolation/compliance), a restore would restore both.

### 1.4 Recovery models — this decides your backup strategy

Every database has one of three **recovery models**, set at the database level:

| Model | What it means | Transaction log behavior |
|---|---|---|
| **Simple** | Log is truncated automatically after each checkpoint | You lose point-in-time recovery. Can only restore to the last full/differential backup. |
| **Full** | Log keeps *everything* since the last log backup | You can restore to any point in time (e.g., "restore to 2:47 PM right before the bad import"). Required for production. |
| **Bulk-logged** | Like Full, but minimally logs certain bulk operations | Rarely used for BC |

**For a bank's HRMS production database, this should always be Full recovery model.** Simple recovery model means if the server dies at 3 PM, you lose everything since last night's backup — that's a real financial/HR data loss for a regulated institution. Check it with:
```sql
SELECT name, recovery_model_desc FROM sys.databases;
```

---

## Part 2 — The Three Backup Types (and how they fit together)

### 2.1 Full backup
A complete copy of every allocated page in the database at the moment the backup runs.
```sql
BACKUP DATABASE [NIMB-HRMS-Prod] 
TO DISK = 'D:\SQLBackups\NIMB-HRMS-Prod_Full.bak'
WITH INIT, COMPRESSION, CHECKSUM;
```
- `INIT` overwrites the existing backup file (omit to append)
- `COMPRESSION` shrinks the backup file significantly (recommended, minor CPU cost)
- `CHECKSUM` verifies page integrity while writing — catches corruption early

### 2.2 Differential backup
Everything that's **changed since the last full backup** (not since the last differential — always measured against the full).
```sql
BACKUP DATABASE [NIMB-HRMS-Prod] 
TO DISK = 'D:\SQLBackups\NIMB-HRMS-Prod_Diff.bak'
WITH DIFFERENTIAL, COMPRESSION, CHECKSUM;
```
Smaller and faster than a full backup. Good middle ground for daily backups between weekly fulls.

### 2.3 Transaction log backup
Everything recorded in the log since the last log backup. **Only possible in Full recovery model.**
```sql
BACKUP LOG [NIMB-HRMS-Prod] 
TO DISK = 'D:\SQLBackups\NIMB-HRMS-Prod_Log.trn'
WITH COMPRESSION, CHECKSUM;
```
This is what gives you point-in-time recovery — restore full → diff → logs in sequence, up to the exact minute before a problem occurred.

### 2.4 A realistic bank-grade schedule

| Backup type | Frequency | Retention |
|---|---|---|
| Full | Weekly (e.g., Sunday night) | 4–8 weeks on-site, longer in cold storage |
| Differential | Daily | 1–2 weeks |
| Transaction log | Every 15–30 minutes | 3–7 days |

This gives an **RPO (Recovery Point Objective)** of ~15–30 minutes — meaning worst case you lose 15–30 minutes of data, not a full day. For HRMS holding salary/employee records this is a reasonable industry target; core banking systems often push tighter (down to seconds) using Always On Availability Groups.

---

## Part 3 — How Real Businesses Actually Do This (Not Just the T-SQL)

The `BACKUP DATABASE` command is 5% of the real process. The other 95%:

1. **Automation** — Nobody runs `BACKUP DATABASE` by hand. It's automated via:
   - **SQL Server Agent Jobs** (on-prem, most common) — scheduled jobs that run backup scripts on a timer
   - **Maintenance Plans** (SSMS's GUI wizard for building backup/cleanup jobs without writing T-SQL)
   - **Azure Backup / Azure SQL automated backups** (cloud)

2. **Off-server storage** — backups are never left only on the same disk as the live database. If that disk or server dies, you lose the database *and* its backups simultaneously. Real setups copy backups to:
   - A separate network share / NAS
   - Cloud blob storage (Azure Blob, with geo-redundancy)
   - Tape/offline storage for long-term compliance retention (banks often require 5–7 years of financial record retention)

3. **Verification — the step most junior teams skip.** A backup file existing means nothing until you've proven it restores.
   ```sql
   RESTORE VERIFYONLY FROM DISK = 'D:\SQLBackups\NIMB-HRMS-Prod_Full.bak';
   ```
   Better: **actually restore it** to a test/DR server periodically (monthly, quarterly) and validate the data. Untested backups are a leading cause of real disaster-recovery failures — the backup existed but was corrupted, incomplete, or from the wrong recovery model configuration.

4. **Monitoring & alerting** — failed backup jobs need to page someone, not silently fail for two weeks.

5. **Encryption** — for banking data specifically:
   - **TDE (Transparent Data Encryption)** encrypts the `.mdf`/`.ldf` and backup files at rest, so a stolen backup file is useless without the certificate/key.
   - Backup files should also be encrypted in transit when copied off-site.
   ```sql
   BACKUP DATABASE [NIMB-HRMS-Prod] 
   TO DISK = 'D:\SQLBackups\NIMB-HRMS-Prod_Full.bak'
   WITH ENCRYPTION (ALGORITHM = AES_256, 
   SERVER CERTIFICATE = MyBackupCert), COMPRESSION;
   ```

6. **Access control & audit trail** — who can trigger a restore, who can read backup files, and logging every restore/backup action. For bank-regulated data this is often a compliance requirement (Nepal Rastra Bank IT guidelines, similar to how other central banks mandate data governance for financial institutions), not just good practice.

7. **RTO vs RPO** — two numbers every backup strategy is designed around:
   - **RPO (Recovery Point Objective):** how much data can we afford to lose? (drives backup *frequency*)
   - **RTO (Recovery Time Objective):** how fast must we be back online? (drives whether you need hot standby/AG, or a restore-from-backup is acceptable)

---

## Part 4 — On-Prem vs Cloud: How This Differs for Business Central

### 4.1 On-Prem Business Central (what you're working with on BC252)

You have full SQL Server access — this is your world right now.

- **Full control, full responsibility.** You (or the infra team at Agile Solutions / the bank's IT) own the entire backup pipeline described in Part 3.
- **Typical stack:** SQL Server (Standard or Enterprise edition) running on a Windows Server, either physical hardware in the bank's data center, or a VM (on-prem hypervisor or Azure — see Part 5).
- **High availability options for banks specifically:**
  - **Always On Availability Groups (AG)** — a synchronized replica of the database on a second server. If the primary dies, failover happens in seconds with near-zero data loss. This is common for core banking but often overkill for HRMS unless the bank mandates it uniformly.
  - **Log shipping** — a simpler, cheaper alternative: transaction log backups are automatically restored to a standby server every few minutes. Higher RTO than AG, but much simpler to run.
- **BC-specific note:** the **Business Central Server (NST — NAV Service Tier)** is a separate service from SQL Server. Backing up the database backs up your data, but you separately need to back up:
  - The BC Server instance configuration
  - Any custom AL extensions/apps deployed (`.app` files) — ideally these live in source control (like your `feature/student-management-arun` branch) rather than relying on server backup alone
  - License files, if on-prem licensing is used

### 4.2 Business Central Cloud (SaaS)

This is the "no SSMS at all" world:
- Microsoft manages the underlying SQL Server entirely. You **cannot** connect via SSMS to a BC Online production environment.
- Microsoft takes **automatic daily backups**, retained for a rolling window, without any admin action.
- Restore is done through the **Business Central Admin Center**, not T-SQL — you pick "restore environment to a point in time" and Microsoft handles it (there's also a "Copy" function to spin up a sandbox from a point-in-time snapshot for testing).
- You lose granular control (no custom log-backup intervals, no direct restore of a single table) but gain zero operational overhead.

### 4.3 Why this matters for your HRMS/bank project specifically

Banks in Nepal (and generally) are often conservative about where employee/financial data physically lives, which is exactly why NIMB and Prabhu Bank are very likely running **on-prem or private-cloud BC**, not BC SaaS — data residency and regulatory control are usually non-negotiable for a regulated financial institution. That's consistent with what you're already doing: connecting to a local BC252 server via SSMS. This course's on-prem section is the one that applies directly to your daily work.

---

## Part 5 — Azure Infrastructure in This Picture

Even "on-prem" BC today is frequently **on-prem architecture, hosted on Azure infrastructure** — i.e., the bank's servers are Azure VMs instead of physical boxes in a server room, while everything else (SQL Server, NST, SSMS access) works identically to true on-prem. Here's how Azure typically slots in:

### 5.1 Azure VM hosting SQL Server ("IaaS" model)
- The bank/Agile Solutions provisions an **Azure Virtual Machine** running Windows Server + SQL Server, exactly like a physical server would.
- You still manage backups yourself (Agent Jobs, maintenance plans) — Azure doesn't do this automatically for you here, it's just the hardware layer.
- Benefit over physical: easier to resize, snapshot, and geographically place, and Azure handles the physical hardware failure risk.

### 5.2 Azure SQL Managed Instance ("PaaS" model — a middle ground)
- A managed SQL Server that's *almost* fully compatible with on-prem SQL Server (BC supports this), but Microsoft handles patching, and **automated backups are built-in** — full/diff/log backups happen automatically with configurable retention (7–35 days point-in-time restore, longer with long-term retention policies).
- You still get SSMS access to connect and query, but you don't manage the backup schedule manually — it's a hybrid of on-prem control and cloud convenience.

### 5.3 Azure Backup service
- A separate Azure service that can back up **Azure VMs as a whole** (including a VM running SQL Server) or specifically integrate with **SQL Server VM backup** for app-consistent, transaction-log-aware backups.
- Backups land in an **Azure Recovery Services Vault**, stored in Azure Blob Storage under the hood.

### 5.4 Storage redundancy options (this is the "where do backups physically live" question)
When backups land in Azure Blob Storage, you choose a redundancy tier:

| Tier | What it protects against | Typical use |
|---|---|---|
| **LRS** (Locally Redundant) | Disk failure within one datacenter | Minimum acceptable for any real backup |
| **ZRS** (Zone Redundant) | One datacenter/availability zone going down | Common baseline for production |
| **GRS** (Geo-Redundant) | An entire Azure *region* going down (e.g., disaster) | Recommended for regulated financial data — a copy exists in a paired region hundreds of km away |
| **RA-GRS** | Same as GRS, plus you can *read* from the secondary region directly | Used when you need read access during a regional outage |

For bank HRMS data, **GRS at minimum** is the reasonable default — a single-datacenter failure should never be able to destroy both the live database and its backup.

### 5.5 Azure Site Recovery (ASR)
For full disaster recovery (not just data — the whole running server), ASR continuously replicates an entire VM to a secondary Azure region, so if the primary region fails, you can fail over the whole BC server stack (NST + SQL) with minutes of RTO, not just restore a database file.

### 5.6 Putting it together — a realistic bank HRMS architecture on Azure

```
[On-prem or bank datacenter]  <-- private network / VPN -->  [Azure Region: Central India / configured region]
                                                                |
                                                    Azure VM: SQL Server + BC NST
                                                                |
                                            SQL Agent Job: Full/Diff/Log backups
                                                                |
                                              Azure Blob Storage (GRS) — backup vault
                                                                |
                                          Paired Azure region (geo-replica, disaster recovery)
```

---

## Part 6 — Hands-On: What to Actually Do in SSMS

Since you already have SSMS on your device connected to BC252, here's the practical path.

### 6.1 Which database should you practice on?

**Do not practice backup/restore on the live NIMB or Prabhu Bank HRMS databases directly**, even in a dev environment, until you're confident — a botched `RESTORE` can overwrite a working database. Your safest learning path:

1. **Your own `StudentAssignmentManagementSystem` or the newer student-enrollment BC252 project** — these are yours, low stakes, and you already understand the schema (Enum 50800, Tables 50801–50804) so you'll actually notice if something looks wrong after a restore.
2. Once comfortable, move to a **copy of the HRMS dev/test database** (never the client's real one) — ask your team lead for a sandbox/dev environment specifically, this is standard practice and a very reasonable thing to request as your assigned learning task.
3. Only after that, observe (don't independently perform) a real backup/restore on an actual bank environment, ideally shadowing a senior dev or DBA the first few times.

### 6.2 Practical exercise sequence

```sql
-- 1. Check current recovery model
SELECT name, recovery_model_desc, log_reuse_wait_desc 
FROM sys.databases WHERE name = 'YourTestDB';

-- 2. Take a full backup
BACKUP DATABASE [YourTestDB] 
TO DISK = 'C:\BCBackups\YourTestDB_Full.bak' 
WITH INIT, COMPRESSION, CHECKSUM, STATS = 10;

-- 3. Make some changes in BC (add a student record, post something)

-- 4. Take a differential backup
BACKUP DATABASE [YourTestDB] 
TO DISK = 'C:\BCBackups\YourTestDB_Diff.bak' 
WITH DIFFERENTIAL, COMPRESSION, CHECKSUM;

-- 5. Verify both backups are valid
RESTORE VERIFYONLY FROM DISK = 'C:\BCBackups\YourTestDB_Full.bak';
RESTORE VERIFYONLY FROM DISK = 'C:\BCBackups\YourTestDB_Diff.bak';

-- 6. Practice a full restore-to-new-name (safe — doesn't touch original)
RESTORE DATABASE [YourTestDB_Restored] 
FROM DISK = 'C:\BCBackups\YourTestDB_Full.bak'
WITH MOVE 'YourTestDB' TO 'C:\SQLData\YourTestDB_Restored.mdf',
     MOVE 'YourTestDB_log' TO 'C:\SQLData\YourTestDB_Restored_log.ldf',
     REPLACE;

-- Then restore the differential on top:
RESTORE DATABASE [YourTestDB_Restored] 
FROM DISK = 'C:\BCBackups\YourTestDB_Diff.bak'
WITH RECOVERY;
```

Then in BC: point a new BC server instance at `YourTestDB_Restored` and confirm your test data is there. This full loop — backup, verify, restore, confirm in BC — is the exact skill your team wants you to build.

### 6.3 Setting up automation (the next step after manual practice)
In SSMS: **SQL Server Agent → Jobs → New Job** → add a step running your `BACKUP DATABASE` script → **Schedules** tab to set it to run nightly/every 15 minutes for logs. This is the GUI equivalent of what enterprise backup schedules actually run on.

---

## Summary — What to Take Into Your HRMS Task

1. BC data = ordinary SQL Server tables, company-prefixed, nothing magic.
2. Full recovery model + Full/Diff/Log backup cadence is the standard for anything holding real bank/HR data.
3. A backup is worthless until it's been restored and verified at least once.
4. On-prem gives you full control and full responsibility; BC cloud hands backup entirely to Microsoft; Azure IaaS/PaaS sits in between.
5. For regulated bank data, care about: recovery model, encryption (TDE), geo-redundant storage (GRS), retention policy, and access control — not just "does a `.bak` file exist somewhere."
6. Practice on your own databases first, then a sandbox copy of HRMS, before touching anything live.

If you want, I can also put together a shorter one-page checklist version of this you could actually present to your team as "here's my understanding of the backup process" — useful if this task is meant to end in you demonstrating it.
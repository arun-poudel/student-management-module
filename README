# Student Enrollment Management (Business Central AL)

A small learning module built in AL for Microsoft Dynamics 365 Business Central. It implements the standard BC **journal → post → permanent ledger** pattern using a simple student/course enrollment scenario.

**Object ID range:** 50800–50900
**Environment:** Local BC252 server
**Branch:** `feature/student-management-arun`

---

## What it does

- Maintain a list of **Students** and **Courses**.
- Enter enrollments on an editable **Enrollment Journal**.
- Click **Post** to move valid lines into a permanent, read-only **Posted Enrollment Entries** table, stamped with who posted and when.
- Look up a student's posting history directly from the journal via **Show Posted Entries**.

---

## Object list

| Type     | ID    | Name                          | Purpose                                    |
|----------|-------|-------------------------------|---------------------------------------------|
| Enum     | 50800 | `student status`              | Active / InActive / Graduate                |
| Page     | 50800 | `Student card`                | Card view for a single student              |
| Page     | 50801 | `Student List`                | List of all students                        |
| Page     | 50802 | `Course List`                 | Editable list of all courses                |
| Table    | 50801 | `Student`                     | Master student records                      |
| Table    | 50802 | `Course`                      | Master course records                       |
| Table    | 50803 | `Enrollment Journal Line`     | Editable working table                      |
| Table    | 50804 | `Posted Enrollment Entry`     | Permanent, read-only posted records         |
| Page     | 50803 | `Enrollment Journal`          | Where enrollments are entered and posted    |
| Page     | 50804 | `Posted Enrollment Entries`   | Read-only view of posted history            |
| Codeunit | 50800 | `Enrollment Post`             | Posting logic                               |

> Note: object IDs are per object type in AL, so a Table and a Codeunit can share the same number (e.g. `50800`) without conflicting.

---

## Data model

**Student (50801)** — `No.` (PK), `Name`, `Email`, `Phone No.`, `Enrollment Date`, `Status` (enum), `Blocked`

**Course (50802)** — `Code` (PK), `Description`, `CreditHour`, `Fee Amount`, `Instructor Name`

**Enrollment Journal Line (50803)** — `Entry No.` (PK), `Student No.` (→ Student), `Student Name`, `Course Code` (→ Course), `Course Description`, `Enrollment Date`, `Fee Amount`

**Posted Enrollment Entry (50804)** — same business fields as the journal line, plus `Posting Date` and `User ID`

---

## Core concepts this module demonstrates

- **`TableRelation`** — gives `Student No.` and `Course Code` a lookup, and rejects values that don't exist in the source table.
- **`Get()` vs `SetRange()`/`SetFilter()`** — `Get` reads one record by primary key (used to auto-fill Name/Fee on `OnValidate`); `SetFilter` + `FindSet` selects a set of records to loop over (used when posting).
- **Auto-fill via `OnValidate`** — selecting a Student No. or Course Code copies related fields (Name, Description, Fee) onto the journal line automatically.
- **Blocked-student enforcement** — `TestField(Blocked, false)` stops a blocked student from being enrolled.
- **The posting pattern** — copy validated data from an editable table into a permanent table, stamp `Posting Date` (`WorkDate()`) and `User ID` (`UserId()`), then `DeleteAll()` the source lines.
- **Two-layer read-only enforcement** — `Posted Enrollment Entry` is locked down both at the **page** level (`Editable`, `InsertAllowed`, `ModifyAllowed`, `DeleteAllowed` all `false`) and at the **table** level (`OnModify`/`OnDelete` triggers that `Error()` out), so it stays protected even from other pages, reports, or API calls — not just this one page.

---

## Actions on the Enrollment Journal

| Action | Behavior |
|---|---|
| **Post** | Confirms with the user, then runs `Codeunit 50800 "Enrollment Post"` against all journal lines with a Student No. |
| **Show Posted Entries** | Opens Posted Enrollment Entries pre-filtered to the student on the *currently selected* journal line — useful for checking a student's history mid-entry, before posting. |

---

## Posting logic, step by step

1. Filter `Enrollment Journal Line` where `Student No. <> ''`.
2. If `FindSet()` finds nothing → `Error('There is nothing to post.')` and stop immediately.
3. Work out the next `Posted Enrollment Entry` number (`FindLast()` + 1, or `1` if the table is empty).
4. Loop the filtered lines with `repeat...until Next() = 0`; for each one, `Init()` a new posted entry, copy the fields across, stamp `Posting Date`/`User ID`, and `Insert()`.
5. After the loop, `DeleteAll()` on the same filtered set clears the journal.
6. `Message()` the number of lines posted.

---

## Lessons learned / bugs fixed while building this

These are worth keeping in mind for future BC modules:

- **`Error()` vs `Message()`** — `Message()` does not stop execution; only `Error()` does. Using `Message()` for the "nothing to post" check let a blank record fall through and get posted anyway.
- **`repeat...until` always runs at least once** — it doesn't check a condition up front like `while` does. If `FindSet()` failed, the loop body still executes once on an unpositioned record unless you `Error()` out beforehand.
- **Don't `Copy(Rec)` into your posting loop variable** — it can silently inherit filters from the caller. Declare a fresh `Record` variable and filter it explicitly so posting always operates on the *entire* table, not whatever view happened to be active.
- **A filter set before `FindSet()` stays active afterward** — no need to `SetFilter` a second time before `DeleteAll()`; the loop doesn't clear it.
- **`SetRange` on a blank value is still a valid filter** — if `Show Posted Entries` is clicked with no journal line selected, `Rec."Student No."` is blank, and the filter becomes "show entries where Student No. is blank," which correctly returns nothing. This needs an explicit guard (error out, or fall back to showing all posted entries) rather than being treated as a bug.
- **Read-only must be enforced at two layers** — page properties alone only protect that one page. Table-level `OnModify`/`OnDelete` triggers are what actually guarantee a posted record can never change, regardless of entry point.

---

## Manual test checklist

- [ ] Create 3 students and 3 courses.
- [ ] On the journal, selecting a Student No. auto-fills Student Name.
- [ ] Selecting a Course Code auto-fills Course Description and Fee Amount.
- [ ] Setting a student's `Blocked = true` and trying to enroll them throws an error.
- [ ] Posting with an empty journal shows "There is nothing to post" and creates **no** record.
- [ ] Entering 2–3 valid lines and clicking Post moves them to Posted Enrollment Entries and clears the journal.
- [ ] Posted entries show the correct `Posting Date` and `User ID`.
- [ ] Editing or deleting a posted entry is blocked, both from the page and from `Edit List`.
- [ ] `Show Posted Entries` on a selected line shows only that student's history.
- [ ] `Show Posted Entries` with no line selected behaves as intended (error or full list — confirm which was chosen).

---

## Submission notes

- **Get vs SetRange:** `Get` reads a single record by its known primary key (e.g. auto-filling a student's name). `SetRange`/`SetFilter` narrow down a *set* of records you don't have individual keys for, so you can loop over all of them — used when posting every eligible journal line at once.
- **Why the posted table is read-only:** once a record is posted, it becomes the official, auditable history of what happened, stamped with who did it and when. Allowing edits afterward would make that stamp meaningless and destroy the audit trail — so both the page and the table itself refuse any modification or deletion.

---

**Author:** Arun Poudel (Nest) — Agile Solutions Pvt. Ltd.
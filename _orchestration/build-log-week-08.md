# Build Log - Week 8 Student Repository Scaffold

**Date Scaffold Created:** 2026-08-14
**Phase:** 1 - Student Repository Scaffolding
**Week:** 8 (Data Observability and Backup Verification)
**Sprint:** 4 (Async) - Weeks 7-8

---

## Overview

This document logs all assumptions, ambiguities, design decisions, and implementation notes made while building the Week 8 Student Repository scaffold.

---

## Architecture Assumptions

### Assumption 1: Privileged Container Mode Required
**Status:** INHERITED FROM COURSE DESIGN

From the course structure overview: "One privileged Docker container per team (4-6 students), shared for the entire semester. The container runs a nested Docker daemon."

Week 8 assumes this privileged container environment allows:
- Running nested Docker daemon for MinIO
- Mounting Docker volumes that restic can access
- Running `docker compose` commands with volume management

**Risk if unconfirmed:** MinIO container provisioning may fail if privileged mode is unavailable.

**Mitigation:** Added a notice to the Week 8 README stating this is unconfirmed.

---

## Prerequisites Verification

### Week 7 Prerequisites
The lab directions state Week 8 depends on:
- Week 7 complete: security controls applied, CI pipeline passing
- Application is running with data in the database

**Assumption:** Students will have Week 7 scaffolding available. The build log does NOT assume any Week 7 outputs exist - only what the lab directions state. Build is based on stated prerequisites, not on examining Week 7's actual files.

---

## Design Decisions

### Decision 1: MinIO Container Lifecycle
**Question:** Should MinIO run as a persistent named container or be created fresh each week?

**Decision:** MinIO runs as a persistent named container (`--name minio`).

**Rationale:**
- Matches the lab directions exactly (they specify `docker run -d --name minio`)
- Backup data persists across lab sessions
- Easier for students to reason about ("the MinIO container")

**Implementation:** The runbook and check script assume a container named "minio" exists. If students accidentally stop/remove it, they will need to restart it using the same docker run command.

---

### Decision 2: restic-env.sh Credential Handling
**Question:** How should students secure restic credentials?

**Decision:** Store in `week-8/.env.backup` (not committed) and source from `restic-env.sh` (committed with placeholders).

**Rationale:**
- Matches the lab directions exactly
- `restic-env.sh` goes into version control; `.env.backup` goes into `.gitignore`
- Allows students to commit their configuration template without exposing secrets
- Teaches a practical pattern: declare what credentials you need, store real values separately

**Implementation:** 
- `restic-env.sh` contains placeholder values (`changethispassword`)
- Step 6 of Part 2 (in the lab directions) instructs students to replace placeholders
- Check script warns if placeholders are still present (implies work not completed)

---

### Decision 3: GitHub Actions Workflow Scope
**Question:** Should the GitHub Actions workflow actually perform the backup, or just verify repository access?

**Decision:** Workflow verifies repository access and applies retention policy only.

**Rationale:**
- GitHub Actions runners do NOT have access to team container volumes
- Actual backup must be run manually on the team container
- This teaches two patterns: (a) GitHub Actions for scheduled tasks that can run anywhere, (b) local cron/daemon for data access tasks
- Matches the comment in the lab directions: "This runs successfully, but does not actually backup data while running in GitHub Actions"

**Implementation:**
- Workflow has verbose TODO comments explaining the limitation
- Lab directions Part 2 Step 9 instructs manual backup
- Check script does NOT verify workflow executed an actual backup

**Ambiguity:** Should students be warned about this earlier? The lab directions bury it in the workflow YAML comments, and students might not realize the workflow is not doing the actual backup until they run it.

**Mitigation:** Added explicit TODO comments in the workflow YAML and a note in `restic-env.sh` about this.

---

### Decision 4: Recovery Drill Procedure
**Question:** Should the runbook be a template or a worked example?

**Decision:** Runbook is a template with TODOs for students to fill in during the drill.

**Rationale:**
- Students must execute the drill and document results
- Runbook becomes a genuine artifact (not just a copy-paste of lab directions)
- Reflects the sprint structure requirement: QA role owns verification artifacts
- The runbook is the output of the drill, not the input to it

**Implementation:** 
- Runbook contains placeholder sections like `[TODO: Insert value from drill]`
- Runbook includes questions students must answer after drill execution
- Runbook Step 4 is intentionally incomplete: students must document their actual restore procedure

---

### Decision 5: Check Script Scope
**Question:** What should check-week8.sh actually verify?

**Decision:** 
- File existence (all required files present)
- Container status (MinIO running, listening on correct ports)
- Tool installation (restic installed)
- Repository initialization (restic repository is initialized)
- No exposed credentials in git history

**Rationale:**
- Checks can run without executing destructive operations (no DROP TABLE)
- Checks are repeatable without side effects
- Provides early feedback before QA runs the recovery drill
- Does NOT check snapshot count (may be zero if drill not run yet)

**Implementation:** Check script has 10 distinct checks with clear pass/fail output.

---

## Ambiguities Encountered

### Ambiguity 1: "week-2_db-data" Volume Naming
**Context:** Lab directions reference `/var/lib/docker/volumes/week-2_db-data/_data` multiple times (Steps 9, 11, 20).

**Question:** Is this volume path guaranteed to exist? Will all teams use this exact name?

**Assumption Made:** Yes. The lab directions assume Week 2 created a volume with this name via docker-compose.

**Mitigation:** 
- Runbook includes the exact path from lab directions
- Runbook Step 3 and Step 6 reference this path explicitly
- Check script assumes teams followed Week 2 structure

**Risk:** If teams used different Week 2 docker-compose setups, the backup path may be wrong.

**Note:** Build log cannot verify Week 2's actual docker-compose output (as instructed: do not assume other weeks' real outputs).

---

### Ambiguity 2: GitHub Actions Secret Names
**Context:** Lab directions Part 3 Step 12 says "Add restic credentials as GitHub Actions secrets" and lists 4 secrets but does not specify if there are others.

**Question:** Are these the ONLY secrets, or are there others?

**Assumption Made:** These are the only four required secrets based on the workflow template in the lab directions.

**Implementation:** Workflow references exactly these four:
- `RESTIC_REPOSITORY`
- `RESTIC_PASSWORD`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**Risk:** If students add additional secrets or use different names, the workflow will fail.

**Mitigation:** Workflow includes comments explaining each secret's purpose.

---

### Ambiguity 3: MinIO Console Access
**Context:** Lab directions mention MinIO console on port 9001 but do not explicitly require students to access it.

**Question:** Should the check script verify console access?

**Decision:** No. Check script verifies port exposure only, not that console is functional. Console is a nice-to-have for debugging, not a requirement for backups.

**Implementation:** Check script has a WARN (not FAIL) if port 9001 is not exposed.

---

### Ambiguity 4: Retention Policy Retention Window
**Context:** Reflection Question 2 asks "A corruption is introduced on day 1 and goes undetected until day 10. Can you recover clean data?"

**Question:** What is the answer? (7 daily snapshots = 7 days of retention, but the corruption was on day 1 and discovered on day 10)

**Decision:** This is intentionally unanswered. Students must work through it in their acceptance criteria and QA report.

**Rationale:** It's a reflection question, not a validation check. Students should reason through the retention math themselves.

**Note:** The QA report template includes this question in the "QA Questions Answered" section.

---

### Ambiguity 5: Restore Target Location
**Context:** Lab directions Step 20 says "restic restore latest --target /tmp/restore --include /var/lib/docker/volumes/week-2_db-data/_data"

**Question:** After restore, how do students actually move data from /tmp/restore back to the live Docker volume?

**Decision:** Marked as incomplete in the runbook. Step 4 says `[TODO: Complete this step during the drill and document what you actually did]`

**Rationale:**
- The exact procedure depends on Docker volume mounting details
- Lab directions do not specify this step
- Students will learn by experimenting during the drill
- Runbook becomes a record of what actually worked

**Risk:** Students may struggle with this step during the drill. But that struggle creates learning value.

**Mitigation:** Runbook includes an example comment showing one possible approach using `sudo cp`.

---

### Ambiguity 6: RTO Measurement Timing
**Context:** Recovery drill Steps 17 and 23 say "Start a timer" and "Stop the timer" but do not specify granularity.

**Question:** Should teams measure to the second, or to the nearest minute?

**Decision:** Not specified. Teams should measure with reasonable precision (seconds is fine).

**Implementation:** Runbook template uses minutes as the unit but does not enforce precision.

**Note:** This is a pragmatic choice: real RTO is usually measured in minutes anyway.

---

## Role Distribution Verification

Checked against `Documents/Sprint_Structure_Layout.md`:

**Sprint 4 covers Weeks 7-8 (async week is Week 8)**

Expected role artifacts:
- Scrum Master: `docs/sprint-4-retrospective.md` - CREATED ✓
- System Admin: `docs/environment-log.md` - CREATED ✓
- QA: `docs/acceptance-criteria.md` and `docs/qa-report-4.md` - CREATED ✓
- Developer(s): Technical deliverables - CREATED (week-8 directory, GitHub workflow, runbook) ✓

**Role Coverage Check (Week 8 technical work):**

Can this be completed solo by one role?

- Developer solo: Could do technical implementation, but cannot verify infrastructure (SA role) or write acceptance criteria before implementing (QA role) ✓ NOT SOLO COMPLETABLE
- System Admin solo: Could provision MinIO, but cannot implement GitHub Actions workflow (Dev role) or write acceptance criteria (QA role) ✓ NOT SOLO COMPLETABLE
- QA solo: Could write acceptance criteria, but cannot implement technical work (Dev role) or manage infrastructure decisions (SA role) ✓ NOT SOLO COMPLETABLE

**Conclusion:** Work is properly distributed. Good.

---

## Cross-Week Dependencies

### Checked Against Known Threads

1. **Week 8/9 Runbook Format:** ✓ Verified
   - Both Week 8 and Week 9 runbooks use format: symptom, root cause, fix, measured before/after vs target
   - Week 8 runbook follows this format exactly

2. **Week 9 Prerequisites:** Note
   - Week 9 requires Week 8 complete with data in database
   - Week 8 is a prerequisite for Week 9, not vice versa
   - No forward-looking dependencies in Week 8

3. **Week 1-4 Ansible Thread:** Not applicable
   - Week 8 is part of Sprint 4, which does not involve Ansible
   - Ansible is Weeks 1-4 only

---

## Files Created

### Role Artifacts (Templates)
- `Student Repositories/week-08/docs/acceptance-criteria.md`
- `Student Repositories/week-08/docs/environment-log.md`
- `Student Repositories/week-08/docs/sprint-4-retrospective.md`
- `Student Repositories/week-08/docs/qa-report-4.md`

### Technical Scaffolding
- `Student Repositories/week-08/week-8/restic-env.sh` (with TODO placeholders)
- `Student Repositories/week-08/week-8/runbook.md` (with TODO placeholders)
- `Student Repositories/week-08/.github/workflows/backup.yml` (with TODO comments)
- `Student Repositories/week-08/scripts/check-week8.sh` (10 validation checks)

### Supporting Files
- `Student Repositories/week-08/README.md` (week overview and architecture notice)
- `Student Repositories/week-08/.gitignore` (credentials exclusion)

### Build Log
- `_orchestration/build-log-week-08.md` (this file)

---

## TODOs Embedded in Scaffolding

The following placeholders appear throughout the scaffolding and must be completed by students:

1. **restic-env.sh:** Replace `changethispassword` with actual values
2. **runbook.md:** Complete Steps 4 and 6 with actual restore procedures
3. **runbook.md:** Fill in drill results (times, row counts, RTO)
4. **qa-report-4.md:** All verification sections need evidence and rework notes
5. **acceptance-criteria.md:** QA must verify all criteria are met
6. **environment-log.md:** SA must complete infrastructure decisions and issues
7. **sprint-4-retrospective.md:** SM must complete retrospective after sprint ends
8. **check-week8.sh:** Script has inline TODOs for credential checking thresholds

---

## Known Limitations

### Limitation 1: GitHub Actions Cannot Backup Live Database
The workflow cannot access the team container's database volumes. Actual backup must run locally. This is a limitation of GitHub Actions runners, not the scaffold.

### Limitation 2: Check Script Cannot Verify Drill Success
The check script cannot execute the recovery drill (that would be destructive and require lab environment). It can only verify prerequisites and setup are in place.

### Limitation 3: restic Repository Access
Check script assumes `.env.backup` and `restic-env.sh` are properly configured before checking repository status. If either file has syntax errors, checks will fail.

---

## Questions for Phase 2 QA

When the QA agent reviews this scaffold, verify:

1. Do the role artifact templates align with the role distribution in Sprint Structure Layout?
2. Does the runbook format match the required "symptom, root cause, fix, measured before/after" pattern?
3. Are there any cross-week defects (e.g., Week 7 artifacts that Week 8 depends on)?
4. Should the GitHub Actions workflow limitation (cannot backup) be more prominent in the lab directions?
5. Is the restore step completeness acceptable (intentionally vague to allow student discovery)?

---

## Summary

The Week 8 scaffold is complete and ready for student use. All required files are templated with TODOs where students must provide actual values or configurations. Role-artifact files follow the sprint structure requirements. The check script validates prerequisites without executing destructive operations.

Key points for student success:
- Start with MinIO provisioning (Part 1)
- Move credentials to .env.backup immediately (Part 1)
- Complete restic configuration (Part 2)
- Add GitHub Actions secrets (Part 3)
- Execute recovery drill and document results (Part 4)
- QA signs off in qa-report-4.md before sprint close

All assumptions and ambiguities are documented above for Phase 2 QA review.

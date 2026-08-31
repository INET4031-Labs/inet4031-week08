# QA Report: Sprint 4 Week 8

**Owned by:** QA

This report documents the results of validation testing at the end of the async week. It includes check script results, acceptance criteria verification, and any rework required before marking deliverables complete.

This file is completed after MinIO is provisioned, restic backups are configured with a retention policy, the scheduled GitHub Actions workflow is committed, and the recovery drill has been run end to end with a measured RTO.

---

## Validation Check Results

### Check 1: MinIO Is Running

**Test:** Run `docker ps --filter name=minio --format "{{.Status}}"`

**Expected:** `Up X minutes`

**Actual Result:**
```
TODO: Paste the actual output
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** If not running, was it started with the exact credentials in `week-8/.env.backup`?

---

### Check 2: At Least One restic Snapshot Exists

**Test:** Run `source week-8/restic-env.sh && restic snapshots`

**Expected:** At least one snapshot row

**Actual Result:**
```
TODO: Paste the actual output
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** `restic-env.sh` alone isn't enough -- `AWS_SECRET_ACCESS_KEY` there references `${MINIO_ROOT_PASSWORD}`, which only exists after also sourcing `week-8/.env.backup` first.

---

### Check 3: Recovery Drill Succeeded

**Test:** Compare the row count recorded before the drill (Step 15) to the row count after recovery (Step 22)

**Expected:** Post-restore count matches pre-drill count

**Actual Result:**
```
TODO: Pre-drill count: ___
TODO: Post-restore count: ___
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** If the count came back as `0` instead of matching, the restored data was likely never copied from `/tmp/restore` back into the live Docker volume (Step 20a) before restarting the stack -- Flask's own `CREATE TABLE IF NOT EXISTS` will silently recreate an empty table on startup, which looks like a successful recovery but isn't.

---

### Check 4: Check Script Passes

**Test:** Run `chmod +x ./scripts/check-week8.sh` then `./scripts/check-week8.sh`

**Expected:** All checks pass with exit code 0

**Actual Result:**
```
TODO: Paste the full output of the check script
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** This script cannot verify the recovery drill itself (Check 3) -- that's confirmed manually and recorded in the Google Doc and runbook.

---

## Acceptance Criteria Verification

Review the criteria below for each part of this week's deliverables. For each criterion, record whether it was met:

### Part 1: Provision MinIO

TODO: [ ] `week-8/.env.backup` created with `MINIO_ROOT_USER`/`MINIO_ROOT_PASSWORD`, added to `.gitignore`
TODO: [ ] MinIO container started and running persistently, ports 9000/9001 exposed
TODO: [ ] `backups` bucket created (via a single combined `docker run` session -- two separate `docker run --rm` calls will not share an `mc` alias between them)

### Part 2: Configure restic Backups

TODO: [ ] `week-8/restic-env.sh` created with `RESTIC_REPOSITORY`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `RESTIC_PASSWORD`
TODO: [ ] restic repository initialized (`restic init`)
TODO: [ ] At least one test backup taken with `sudo -E restic backup /var/lib/docker/volumes/week-2_db-data/_data ...` (`sudo -E` is required -- the volume path is root-owned, and `-E` preserves the credentials `restic-env.sh` exported)
TODO: [ ] Retention policy applied (`restic forget --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 3`)

### Part 3: Automated Backups via GitHub Actions

TODO: [ ] `.github/workflows/backup.yml` committed with a daily cron trigger and `workflow_dispatch`
TODO: [ ] `RESTIC_REPOSITORY`, `RESTIC_PASSWORD`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` stored as GitHub Actions secrets
TODO: [ ] Workflow manually triggered; screenshot captured of the run **failing** at `restic snapshots` with a connection-refused error -- this is the expected, correct result. `RESTIC_REPOSITORY` points at `http://localhost:9000`, which only resolves to your team's own machine locally; a GitHub-hosted runner has no path to reach it. A green checkmark here would actually indicate something is misconfigured, not the reverse.

### Part 4: Recovery Drill

TODO: [ ] Week 2 Compose stack running before starting the drill (`docker compose -f week-2/docker-compose.yml up -d`)
TODO: [ ] Pre-drill row count recorded (Step 15)
TODO: [ ] Fresh pre-drill backup taken with `sudo -E` (Step 16)
TODO: [ ] `incidents` table dropped; `curl http://localhost:8080/incidents` (not `8081` -- that's the separate Kubernetes-deployed app, untouched by anything in this week) confirmed an error response (Steps 17-18)
TODO: [ ] `flask`, `nginx`, **and `db`** all stopped before restoring (Step 19 + 20a -- `db` must be stopped too, since its live data files can't be safely replaced while Postgres has them open)
TODO: [ ] Backup restored to `/tmp/restore` (Step 20), then explicitly copied back into the live Docker volume (Step 20a) -- restoring to the staging path alone does not update the live volume
TODO: [ ] Stack restarted; post-restore row count matches pre-drill count (Steps 21-22)
TODO: [ ] RTO measured and recorded, compared against the 15-minute target (Step 23)

---

## Deliverables Verification

### Required Files

TODO: [ ] `week-8/restic-env.sh` committed (credentials placeholdered or omitted, not real secrets)
TODO: [ ] `.github/workflows/backup.yml` committed
TODO: [ ] `week-8/runbook.md` committed using the required format (Symptom, Root Cause, Fix, Measured Before/After)
TODO: [ ] `scripts/check-week8.sh` present and runs clean

### GitHub Repository

TODO: [ ] All changes pushed to the main branch
TODO: [ ] No real MinIO/restic credentials appear anywhere in git history

### Google Doc

TODO: [ ] Screenshot of `restic snapshots` showing at least one snapshot is attached
TODO: [ ] Screenshot of the application error after `DROP TABLE` is attached
TODO: [ ] Screenshot of the application returning the correct row count after restore is attached
TODO: [ ] Screenshot of the backup workflow failing at `restic snapshots` (connection refused) is attached, with the reachability discussion answered
TODO: [ ] Screenshot of `./scripts/check-week8.sh` passing is attached
TODO: [ ] Recovery drill results recorded: start time, end time, measured RTO, row count before and after
TODO: [ ] Discussion answers recorded for Parts 1-4 (backup target failure domain, retention policy risk, RPO, RTO vs. target)
TODO: [ ] Week 8 storage check recorded, compared to Week 7 baseline

---

## Rework Required

If any validation checks or acceptance criteria failed, document the rework needed:

**Issues Found:**
```
TODO: List any failures here
```

**Rework Plan:**
```
TODO: For each failure, describe the steps to fix it and who will do the work
```

**Re-validation Date:** TODO: When will rework be complete?

---

## Sign-Off

**QA Name:** ______________________
**Date Signed:** ______________________
**Overall Status:** TODO: [ ] All Criteria Met [ ] Rework Required

**Notes:** Any final observations about the sprint's technical quality and team coordination.

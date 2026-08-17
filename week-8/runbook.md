# Runbook: Database Data Loss Recovery

## Overview

This runbook documents the procedure for recovering PostgreSQL database data from a restic backup. It is based on a real recovery drill performed during Sprint 4 Week 8 and reflects the actual steps your team executed successfully.

---

## Incident Definition

**Incident:** Database data loss recovery

**Severity:** Critical (application returns errors or empty results)

---

## Symptom

Application returns errors when querying the incidents table, or the row count drops to zero. For example:

```
curl http://localhost:8080/incidents
```

Returns: HTTP 500 or error message indicating the table does not exist.

---

## Root Cause

The incidents table or its data directory has been deleted. Confirmed by:

```bash
docker compose -f week-2/docker-compose.yml exec db \
  psql -U appuser -d statustracker -c "SELECT COUNT(*) FROM incidents;"
```

This query returns: `ERROR: relation "incidents" does not exist`

---

## Fix (Recovery Steps)

Follow these steps to restore data from the most recent backup:

### Step 1: Stop Application Components

Prevent any writes from interfering with the restore process:

```bash
docker compose -f week-2/docker-compose.yml stop flask nginx
```

### Step 2: Identify the Most Recent Clean Snapshot

List available backups:

```bash
source week-8/restic-env.sh
restic snapshots
```

Look for a snapshot with the tag `pre-drill` or `postgres` and note its ID (the hash in the first column).

### Step 3: Restore to a Temporary Location

Extract the backup to a temporary directory:

```bash
source week-8/restic-env.sh
restic restore <snapshot-id> --target /tmp/restore --include /var/lib/docker/volumes/week-2_db-data/_data
```

Replace `<snapshot-id>` with the actual snapshot ID from Step 2.

### Step 4: Replace the Database Data

[TODO: Complete this step during the drill and document what you actually did]

The restore will place data at `/tmp/restore/var/lib/docker/volumes/week-2_db-data/_data`. You must move this into the actual Docker volume:

```bash
# TODO: Document the actual command(s) your team ran to restore the data volume
# Example:
#   sudo cp -r /tmp/restore/var/lib/docker/volumes/week-2_db-data/_data/* \
#     /var/lib/docker/volumes/week-2_db-data/_data/
```

### Step 5: Restart the Application

Bring the application back online:

```bash
docker compose -f week-2/docker-compose.yml up -d
```

Wait for the containers to start (approximately 10-15 seconds).

### Step 6: Verify Data Integrity

Confirm the incidents table is restored and contains the expected data:

```bash
docker compose -f week-2/docker-compose.yml exec db \
  psql -U appuser -d statustracker -c "SELECT COUNT(*) FROM incidents;"
```

The row count should match the pre-incident count (see "Measured Before/After" section below).

---

## Measured Before/After vs. Stated Target

### Baseline (Drill Preparation)

**Pre-drill row count:** [TODO: Insert value from drill - run: SELECT COUNT(*) FROM incidents;]

**Pre-drill snapshot command:**
```bash
source week-8/restic-env.sh
restic backup /var/lib/docker/volumes/week-2_db-data/_data --tag postgres --tag pre-drill
```

### Simulated Failure

**Failure method:** `DROP TABLE incidents;`

**Verification that failure succeeded:** Application returned error when accessing `/incidents` endpoint

### Recovery Execution

**Recovery start time:** [TODO: HH:MM UTC]

**Recovery end time:** [TODO: HH:MM UTC]

**Actual Recovery Time Objective (RTO):** [TODO: Calculated as end time minus start time, in minutes]

### Post-Recovery Verification

**Post-restore row count:** [TODO: Insert value - should match pre-drill count]

**Match verification:** [TODO: Pre-drill and post-restore row counts are equal? YES / NO]

### Performance vs. Target

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| RTO (Recovery Time Objective) | 15 minutes | [TODO: minutes] | [PASS/FAIL] |
| Data Integrity | 100% row match | [TODO: %] | [PASS/FAIL] |
| Application Availability | Restored within RTO | [TODO: YES/NO] | [PASS/FAIL] |

---

## What This Drill Tells Us

[TODO: Answer these questions based on your drill results:]

1. **Did the recovery procedure work as documented, or did we need to adjust steps?**
   Answer: 

2. **What took the longest during recovery? Was it stopping services, restoring data, or restarting?**
   Answer: 

3. **If we had a real failure 1 minute after the daily backup ran at 02:00 UTC, how much data would we lose?**
   Answer: 

4. **Is our retention policy (7 daily, 4 weekly, 3 monthly snapshots) sufficient to recover from an undetected 10-day-old corruption?**
   Answer: 

---

## Prevention and Monitoring

### Backup Verification

The GitHub Actions workflow runs daily at 02:00 UTC. Verify that backups are being taken:

```bash
source week-8/restic-env.sh
restic snapshots
```

You should see a daily snapshot. If you do not see a recent snapshot, check the GitHub Actions workflow logs for errors.

### When to Use This Runbook

Use this runbook immediately if:

- Application returns "relation does not exist" errors
- Row count in incidents table unexpectedly drops to zero
- Database query responses show unexpected errors
- The application log shows PostgreSQL connection errors or schema issues

Do NOT wait. Start with Step 1.

---

## Post-Incident Review

After executing this runbook in a real incident:

1. Determine the root cause (accidental DROP, disk failure, misconfiguration, etc.)
2. Document the root cause in a post-incident review
3. Propose changes to prevent recurrence (backups to separate storage, monitoring, alerts, etc.)
4. Update this runbook with any adjustments learned from the incident

---

## Contacts and Escalation

[TODO: Fill in contact information for your team]

- **System Admin (backup owner):** [Name] [Contact]
- **Database Owner:** [Name] [Contact]
- **Scrum Master:** [Name] [Contact]

If restic restore fails or you encounter errors not covered in this runbook, contact your System Admin immediately.

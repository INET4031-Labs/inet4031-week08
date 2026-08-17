# Sprint 4 Acceptance Criteria

**Written by:** QA before development begins

**Purpose:** Define what "done" means for this sprint beyond what the check script validates.

## Overview

This document defines the acceptance criteria for Sprint 4 (Weeks 7-8). Week 8 focuses on backup infrastructure, automated backup execution, and recovery verification. These criteria were established before implementation and will guide verification at sprint close.

## Week 8 Acceptance Criteria

### MinIO Provisioning

- MinIO container runs persistently in the team environment
- MinIO is accessible on port 9000 (S3 API) and port 9001 (console)
- A backup bucket named `backups` exists and is readable by restic
- MinIO root credentials are generated securely and stored in `.gitignore`d files only
- No hardcoded MinIO credentials appear in version-controlled files

### restic Configuration

- restic is installed on the team container
- restic repository is initialized pointing to the local MinIO S3 endpoint
- restic environment file (`restic-env.sh`) is committed with placeholders for sensitive values
- Test backup of PostgreSQL data volume succeeds without errors
- At least one snapshot exists in the restic repository

### Retention Policy

- A retention policy is defined using `restic forget --prune` with specified parameters
- Policy is documented in the runbook
- Policy keeps 7 daily, 4 weekly, and 3 monthly snapshots

### Automated Backups via GitHub Actions

- `.github/workflows/backup.yml` is committed and syntactically valid
- Workflow is scheduled to run daily at 02:00 UTC using cron syntax
- All restic credentials are added to GitHub Actions Secrets (not stored in code)
- Workflow can be triggered manually via `workflow_dispatch`
- Manual workflow trigger succeeds without errors

### Recovery Drill

- Pre-drill row count in incidents table is recorded
- Table is dropped to simulate data loss
- Application returns appropriate errors when table is missing
- Backup is restored to a temporary location
- Application is restarted and verifies data integrity
- Post-restore row count matches pre-drill row count
- Actual RTO (Recovery Time Objective) is measured and recorded
- Measured RTO does not exceed 15 minutes

### Runbook

- Recovery runbook is committed in the required format
- Runbook includes: symptom, root cause, fix steps, measured before/after values
- Runbook reflects the actual drill results, not theoretical procedures
- Runbook is clear enough for a team member unfamiliar with the work to follow

### Verification and Integration

- `./scripts/check-week8.sh` exists and passes without errors
- Check script validates MinIO status
- Check script validates restic snapshots exist
- Check script validates runbook contains required fields
- All commits have meaningful messages that explain the "why"

## Acceptance Conditions for Sprint Close

For Week 8 to be considered complete:

1. All five validation checks pass
2. All required files are committed to the repository
3. Recovery drill is documented with before/after measurements
4. QA has run the check script and signed off in `docs/qa-report-4.md`
5. No hardcoded credentials appear in any version-controlled files

## Questions for Team Review

Before marking complete, answer the following in `docs/qa-report-4.md`:

- Did MinIO provision without issues? What docker commands were used?
- Did the backup succeed on the first attempt, or were there troubleshooting steps?
- Did the recovery drill follow the expected procedure, or were adjustments needed?
- Does the actual measured RTO match the team's expectations?
- Are there any infrastructure decisions (MinIO placement, backup retention, etc.) that should be reconsidered?

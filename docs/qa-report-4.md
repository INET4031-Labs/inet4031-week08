# QA Report - Sprint 4

**Written by:** QA after validation checks are run

**Purpose:** Document what passed verification, what required rework, and what remains incomplete.

---

## Sprint 4 Validation Summary

**Sprint:** 4 (Weeks 7-8)
**QA Lead:** [Enter your name]
**Report Date:** [YYYY-MM-DD]
**Check Script Last Run:** [YYYY-MM-DD HH:MM UTC]

---

## Acceptance Criteria Verification

### MinIO Provisioning - PASS / FAIL / INCOMPLETE

- [ ] MinIO container runs persistently
- [ ] MinIO is accessible on ports 9000 and 9001
- [ ] Backup bucket named `backups` exists
- [ ] MinIO credentials are not in version control

**Evidence:** [TODO: Describe what you checked and the output]

**Rework Needed (if any):** [TODO: What must be fixed before this is truly done?]

### restic Configuration - PASS / FAIL / INCOMPLETE

- [ ] restic is installed on the team container
- [ ] restic repository is initialized
- [ ] `restic-env.sh` is committed without real credentials
- [ ] At least one snapshot exists

**Evidence:** [TODO: Output from 'restic snapshots' command]

**Rework Needed (if any):** [TODO: What troubleshooting was required?]

### Retention Policy - PASS / FAIL / INCOMPLETE

- [ ] Retention policy is defined (7 daily, 4 weekly, 3 monthly)
- [ ] Policy is documented in the runbook
- [ ] `restic forget --prune` has been executed at least once

**Evidence:** [TODO: Show the retention policy from the runbook]

**Rework Needed (if any):** [TODO: Was the policy correctly applied?]

### GitHub Actions Backup Workflow - PASS / FAIL / INCOMPLETE

- [ ] `.github/workflows/backup.yml` is committed and valid YAML
- [ ] Workflow is scheduled for 02:00 UTC daily
- [ ] All credentials are stored in GitHub Actions Secrets
- [ ] Manual workflow trigger succeeds

**Evidence:** [TODO: Screenshot of successful workflow run from GitHub Actions]

**Rework Needed (if any):** [TODO: Did the workflow require troubleshooting?]

### Recovery Drill - PASS / FAIL / INCOMPLETE

- [ ] Pre-drill row count recorded
- [ ] Table dropped and verified missing
- [ ] Backup restored without errors
- [ ] Post-restore row count matches pre-drill
- [ ] Measured RTO recorded (should not exceed 15 minutes)

**Evidence:** 

[TODO: Record the drill results:]
- Pre-drill row count: ___________
- Post-restore row count: ___________
- Measured RTO: ___________ minutes
- Expected RTO target: 15 minutes

**Rework Needed (if any):** [TODO: Did the recovery require adjustments to the procedure?]

### Runbook - PASS / FAIL / INCOMPLETE

- [ ] `week-8/runbook.md` is committed
- [ ] Runbook includes: symptom, root cause, fix, measured before/after
- [ ] Runbook reflects actual drill results
- [ ] Steps are clear and reproducible

**Evidence:** [TODO: Does the runbook contain all required sections?]

**Rework Needed (if any):** [TODO: Was the runbook unclear or incomplete?]

### Check Script - PASS / FAIL / INCOMPLETE

```bash
./scripts/check-week8.sh
```

**Output:**

[TODO: Paste the full output of the check script here]

**Result:** [TODO: Did the script pass or fail?]

**Rework Needed (if any):** [TODO: What errors did the script report?]

---

## File Inventory

[TODO: Verify all required files exist and are committed. Check the current state of the repo.]

- [ ] `week-8/restic-env.sh` exists
- [ ] `week-8/runbook.md` exists
- [ ] `.github/workflows/backup.yml` exists
- [ ] `scripts/check-week8.sh` exists
- [ ] `.gitignore` includes `week-8/.env.backup`
- [ ] No real credentials appear in any committed files

**Inventory Issues:** [TODO: Note any missing files or credential leaks]

---

## Screenshots Collected

[TODO: Verify all required screenshots were captured. Copy filenames here.]

The lab directions require these screenshots:

- [ ] Screenshot 1: `restic snapshots` showing at least one snapshot
- [ ] Screenshot 2: Application error after DROP TABLE
- [ ] Screenshot 3: Application returning correct row count after restore
- [ ] Screenshot 4: Backup workflow success in GitHub Actions
- [ ] Screenshot 5: `./scripts/check-week8.sh` passing

**Screenshot Issues:** [TODO: Note any screenshots that are missing or unclear]

---

## Pre-Existing Issues from Week 7

[TODO: Did any Week 7 deliverables need rework or attention during Week 8? Note them here.]

- Issue: [If any]
- Impact on Week 8: [How did this affect the backup work?]
- Resolution: [Was it fixed, or is it still pending?]

---

## Overall Verdict

**Week 8 Sign-Off:** [TODO: Choose one]

- [ ] **PASS** - All acceptance criteria met, check script passes, ready for Sprint 5
- [ ] **PASS WITH MINOR REWORK** - One or two small issues need fixing; will retest after fix
- [ ] **FAIL** - Significant rework required before Week 8 is complete

**Summary for the team:** [TODO: Write a brief summary of what is blocking a "PASS" verdict, if applicable]

---

## QA Questions Answered

Before closing out QA, answer these questions in your own words:

1. **MinIO Design Decision:** The backup target (MinIO) runs in the same team container as your application. What class of failure would destroy both your application data AND your backups simultaneously?

   [TODO: Your answer]

2. **Recovery Confidence:** How confident is the team that the documented recovery procedure will work in a real emergency? What gaps exist between the drill and a real failure?

   [TODO: Your answer]

3. **Retention Policy Risk:** If data corruption went undetected for 10 days, could your retention policy recover clean data?

   [TODO: Your answer]

4. **Backup Schedule RPO:** The backup workflow runs at 02:00 UTC daily. If a failure occurs at 23:00 UTC, how much data (in time) is at risk?

   [TODO: Your answer]

---

## Sign-Off

QA Lead: _________________________ Date: __________

Scrum Master (verifies rework completed): _________________________ Date: __________

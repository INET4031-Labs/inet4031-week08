# Environment Log - Sprint 4

**Maintained by:** System Admin

**Purpose:** Track infrastructure decisions, environment state, and resource usage across the sprint.

## Sprint 4 Environment Entry

**Sprint:** 4 (Weeks 7-8)
**System Admin:** [Enter your name]
**Date Snapshot Taken:** [YYYY-MM-DD]

### Environment Baseline (from Week 7)

[Copy and paste the Week 7 environment snapshot here, or reference it from Week 7's environment log]

### Week 8 Changes

#### Docker Resources

Before Week 8 work begins, record:

- Total disk space available: `TODO: Run 'df -h' and record`
- Docker system storage:
  ```
  TODO: Run 'docker system df' and record output
  ```

After MinIO provisioning, before backup pipeline:

- New volumes created for MinIO:
  ```
  TODO: List MinIO-related docker volumes
  ```
- Disk space consumed by MinIO data:
  ```
  TODO: After first backup, run 'du -sh /var/lib/docker/volumes/minio-data/_data'
  ```

After backup pipeline is complete:

- Total disk space remaining: `TODO: Run 'df -h' and record`
- Docker system storage after restic backups:
  ```
  TODO: Run 'docker system df' and record output
  ```

#### Infrastructure Decisions Made This Sprint

1. **MinIO Provisioning Placement**
   - Decision: [TODO: Where is MinIO running? Same container as application? On the host?]
   - Rationale: [TODO: Why did we choose this placement?]
   - Impact: [TODO: How does this placement affect recovery scenarios?]

2. **restic Repository Backend**
   - Decision: [TODO: Using MinIO S3-compatible endpoint at which address?]
   - Rationale: [TODO: Why this backend over alternatives?]
   - Impact: [TODO: How does this decision affect backup reliability?]

3. **Backup Retention Policy**
   - Decision: [TODO: Keep 7 daily, 4 weekly, 3 monthly snapshots]
   - Rationale: [TODO: How long could data corruption go undetected with this policy?]
   - Impact: [TODO: What is the maximum data loss window if this policy fails?]

4. **Backup Schedule**
   - Decision: [TODO: Backups run at 02:00 UTC daily via GitHub Actions]
   - Rationale: [TODO: Why 02:00 UTC? What is our RPO based on this schedule?]
   - Impact: [TODO: If a failure occurs at 01:59 UTC, how much data is at risk?]

#### Issues Encountered and Resolutions

[TODO: For each infrastructure issue that required System Admin investigation, document:]
- Issue: [What went wrong?]
- Investigation: [How did you diagnose it?]
- Resolution: [How did you fix it? What commands did you run?]
- Prevention: [What will you do differently next sprint to avoid this?]

#### Verification Checkpoints

Before closing this sprint, System Admin must verify:

- [ ] MinIO container is running and accessible
- [ ] restic repository is initialized and contains at least one snapshot
- [ ] GitHub Actions workflow ran at least once successfully
- [ ] No disk space issues detected (df shows healthy free space)
- [ ] Recovery drill was attempted and documented
- [ ] All infrastructure decisions are logged above

### Notes for Next Sprint

[TODO: What should the next System Admin know about the current state of the backup infrastructure?]

Example topics:
- Is the MinIO data volume getting large? Will it need pruning?
- Did any of the backup/restore procedures take longer than expected?
- Are there any credentials or configuration changes that need attention?
- Is there any infrastructure that should be monitored or changed?

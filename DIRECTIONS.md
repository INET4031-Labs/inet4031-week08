## Week 8: Data Observability and Backup Verification

**Sprint 4 Async | Due before Sprint 4 Review**

### Overview

In this lab, your team builds an automated backup pipeline for your PostgreSQL database, verifies that backups actually work under a simulated failure, and measures your recovery time against a defined target. You will provision a MinIO container as an S3-compatible backup destination, automate backups with restic using a GitHub Actions scheduled workflow, apply a retention policy, and simulate real data loss with a recovery drill. After completing this lab, you will have a working backup pipeline with a verified recovery procedure and a runbook documenting both.

### Learning Objectives

- Provision MinIO as an S3-compatible backup target using a Docker container
- Configure restic for PostgreSQL data volume backups to an S3-compatible backend
- Implement a retention policy using `restic forget --prune`
- Automate backups using a GitHub Actions scheduled workflow with cron syntax
- Execute a recovery drill and measure actual RTO against a stated target

### Prerequisites

- Week 7 complete: security controls applied, CI pipeline passing
- Application is running with data in the database

---

### Part 1: Provision MinIO

> **Background:** MinIO is an open-source, S3-compatible object storage server. Running it as a Docker container gives you an S3 endpoint without cloud credentials. restic works identically whether the target is AWS S3 or a local MinIO instance.

**Step 1.** Create the directory for this week's files.

```bash
mkdir -p week-8
```

**Step 2.** Generate a MinIO password and save it to a credentials file.

```bash
export MINIO_ROOT_PASSWORD="$(openssl rand -base64 24)"
echo "MINIO_ROOT_USER=backup" >> week-8/.env.backup
echo "MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}" >> week-8/.env.backup
```

Add `week-8/.env.backup` to `.gitignore`.

**Step 3.** Start MinIO.

```bash
docker run -d --name minio \
  -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=backup \
  -e MINIO_ROOT_PASSWORD="${MINIO_ROOT_PASSWORD}" \
  -v minio-data:/data \
  minio/minio server /data --console-address ":9001"
```

**Step 4.** Verify MinIO is running.

```bash
docker ps --filter name=minio
```

Expected: MinIO container with `Up` status.

**Step 5.** Create a backup bucket.

```bash
docker run --rm --network host minio/mc:latest alias set local http://localhost:9000 backup "${MINIO_ROOT_PASSWORD}"
docker run --rm --network host minio/mc:latest mb local/backups
```

**Discussion (add to Google Doc):** MinIO provides an S3-compatible API. If you later wanted to move backups to AWS S3, what would change in your restic configuration? What would NOT change?

---

### Part 2: Configure restic Backups

**Step 6.** Install restic.

```bash
apt-get install -y restic
```

**Step 7.** Create `week-8/restic-env.sh`. Source this file before running any restic commands.

```bash
export RESTIC_REPOSITORY="s3:http://localhost:9000/backups"
export AWS_ACCESS_KEY_ID=backup
export AWS_SECRET_ACCESS_KEY="${MINIO_ROOT_PASSWORD}"
export RESTIC_PASSWORD="changethispassword"
```

Replace `changethispassword` with a strong password your team generates and records somewhere safe. If this value is lost, your backups cannot be decrypted.

**Step 8.** Initialize the restic repository.

```bash
source week-8/restic-env.sh
restic init
```

Expected: `created restic repository <id> at s3:http://localhost:9000/backups`

**Step 9.** Take a test backup.

```bash
source week-8/restic-env.sh
restic backup /var/lib/docker/volumes/week-2_db-data/_data --tag postgres --tag manual
```

**Step 10.** Verify the backup exists.

```bash
source week-8/restic-env.sh
restic snapshots
```

Expected: a table showing one snapshot with timestamp, tags, and path.

**Step 11.** Apply a retention policy.

```bash
source week-8/restic-env.sh
restic forget --prune \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 3
```

**Discussion (add to Google Doc):** The retention policy keeps 7 daily, 4 weekly, and 3 monthly snapshots. If a corruption went undetected for 10 days, could you recover clean data?

---

### Part 3: Automated Backups via GitHub Actions

**Step 12.** Add restic credentials as GitHub Actions secrets (Settings > Secrets > Actions):

- `RESTIC_REPOSITORY`
- `RESTIC_PASSWORD`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**Step 13.** Create `.github/workflows/backup.yml`.

```yaml
name: Scheduled Database Backup

on:
  schedule:
    - cron: '0 2 * * *'
  workflow_dispatch:

jobs:
  backup:
    runs-on: ubuntu-latest

    steps:
      - name: Install restic
        run: sudo apt-get install -y restic

      - name: Verify repository and prune old snapshots
        env:
          RESTIC_REPOSITORY: ${{ secrets.RESTIC_REPOSITORY }}
          RESTIC_PASSWORD: ${{ secrets.RESTIC_PASSWORD }}
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          restic snapshots
          restic forget --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 3
```

**Step 14.** Trigger the backup workflow manually from the Actions tab.

---

### Part 4: Recovery Drill

**Step 15.** Record the row count before the drill.

```bash
docker compose -f week-2/docker-compose.yml exec db \
  psql -U appuser -d statustracker -c "SELECT COUNT(*) FROM incidents;"
```

Record in Google Doc under "Week 8 Recovery Drill."

**Step 16.** Take a fresh pre-drill backup.

```bash
source week-8/restic-env.sh
restic backup /var/lib/docker/volumes/week-2_db-data/_data --tag postgres --tag pre-drill
```

**Step 17.** Start a timer. Drop the incidents table.

```bash
docker compose -f week-2/docker-compose.yml exec db \
  psql -U appuser -d statustracker -c "DROP TABLE incidents;"
```

**Step 18.** Verify the data is gone.

```bash
curl http://localhost:8080/incidents
```

Expected: an error response.

**Step 19.** Stop application components to avoid writes during restore.

```bash
docker compose -f week-2/docker-compose.yml stop flask nginx
```

**Step 20.** Restore the backup.

```bash
source week-8/restic-env.sh
restic restore latest --target /tmp/restore --include /var/lib/docker/volumes/week-2_db-data/_data
```

**Step 21.** Restart the application.

```bash
docker compose -f week-2/docker-compose.yml up -d
```

**Step 22.** Verify the data is restored.

```bash
docker compose -f week-2/docker-compose.yml exec db \
  psql -U appuser -d statustracker -c "SELECT COUNT(*) FROM incidents;"
```

Row count should match the pre-drill value.

**Step 23.** Stop the timer. Record elapsed time as your measured RTO.

---

### Runbook: Write and Commit

Create `week-8/runbook.md`. Use this exact format. Both Week 8 and Week 9 use structurally identical runbooks.

```markdown
**Incident:** Database data loss recovery

**Symptom:** Application returns errors or empty results for incident queries. Row count in incidents table drops to zero or table is missing.

**Root Cause:** Table or data directory deleted. Confirmed by: SELECT COUNT(*) FROM incidents returns error "relation does not exist."

**Fix:**
1. Stop application containers to prevent writes: docker compose stop flask nginx
2. Identify the most recent clean snapshot: restic snapshots
3. Restore data directory: restic restore <snapshot-id> --target /tmp/restore
4. Copy restored data to the Docker volume path
5. Restart the application: docker compose up -d
6. Verify row count matches pre-incident count

**Measured Before/After vs. Stated Target:**
- Row count before incident: [your value]
- Row count after restore: [your value]
- RTO target: 15 minutes
- Actual RTO: [your measured time]
```

Commit:

```bash
git add week-8/
git commit -m "feat: add MinIO backup pipeline, restic config, and recovery runbook"
git push origin main
```

---

### Storage Check

```bash
df -h
docker system df
```

The MinIO data volume and restic repository both consume disk. Record and compare to your Week 7 baseline in your Google Doc under "Week 8 Storage Check."

---

### Validation Checks

#### Validation Check: MinIO Is Running

```bash
docker ps --filter name=minio --format "{{.Status}}"
```

Expected: `Up X minutes`

#### Validation Check: At Least One restic Snapshot Exists

```bash
source week-8/restic-env.sh && restic snapshots
```

Expected: at least one snapshot row.

#### Validation Check: Recovery Drill Succeeded

Row count before the drill matches row count after recovery. Both documented in Google Doc and runbook.

#### Validation Check: Check Script Passes

```bash
./scripts/check-week8.sh
```

---

### Deliverables

- `week-8/restic-env.sh` committed (credentials placeholdered or omitted)
- `.github/workflows/backup.yml` committed
- `week-8/runbook.md` committed using the required format
- Google Doc updated with recovery drill results (start time, end time, measured RTO, row count before and after)
- `./scripts/check-week8.sh` runs clean

**Screenshot requirements:**

- **Screenshot 1:** `restic snapshots` showing at least one snapshot
- **Screenshot 2:** Application returning error after DROP TABLE
- **Screenshot 3:** Application returning correct row count after restore
- **Screenshot 4:** Backup workflow success in GitHub Actions
- **Screenshot 5:** `./scripts/check-week8.sh` passing

---

### Reflection Questions (Answer in Google Doc)

1. You measured an actual RTO during the recovery drill. How did your measured RTO compare to the 15-minute target? If it was over, which step took longest and what would you change?
2. Your retention policy keeps 7 daily, 4 weekly, and 3 monthly snapshots. A corruption is introduced on day 1 and goes undetected until day 10. Can you recover clean data? What would you change to guarantee recovery from a corruption that old?
3. restic encrypts backups by default. You stored the encryption password as a GitHub Actions secret. What are the risks of this approach, and what would a production team do differently?
4. The backup workflow runs at 02:00 UTC daily. What is your RPO based on this schedule? If the database is updated every 10 minutes, how much data is at risk in the worst case?
5. (Extend) Your backup target (MinIO) runs inside the same team container as your application. What class of failure would destroy both your application data AND your backups simultaneously? How would you redesign the backup target placement to survive that failure?

---

---


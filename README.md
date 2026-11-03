# Week 8: Data Observability and Backup Verification

**Sprint 4| Due before Sprint 4 Review**

## Overview

In this lab, your team builds an automated backup pipeline for your PostgreSQL database, verifies that backups actually work under a simulated failure, and measures your recovery time against a defined target. You will deploy MinIO into your k3d cluster as an S3-compatible backup destination, back up your cluster's database with restic, automate backups using a GitHub Actions scheduled workflow, apply a retention policy, and simulate real data loss with a recovery drill. After completing this lab, you will have a working backup pipeline with a verified recovery procedure and a runbook documenting both.

## Learning Objectives

- Deploy MinIO into Kubernetes as an S3-compatible backup target
- Configure restic to back up a PostgreSQL database dump to an S3-compatible backend
- Implement a retention policy using `restic forget --prune`
- Automate backups using a GitHub Actions scheduled workflow with cron syntax
- Execute a recovery drill and measure actual RTO against a stated target

## Prerequisites

- Week 7 complete: security controls applied, CI pipeline passing
- Application is running in your k3d cluster with data in the database
- `restic` installed on your team's VM (check with `restic version`)
- Your team's MinIO port (9300 plus your team number, e.g. 9303 for Team 3). See the Team Port Assignments table in the Wiki.

## Pulling This Week's Starter Content Into Your Team Repo

This repo (`inet4031-week08`) is instructor-provided starter/reference content for
Week 8, not something you clone standalone. Pull the pieces you need into your
team's single repo:

```bash
git clone https://github.com/INET4031-Labs/inet4031-week08.git temp-week08
rm -rf temp-week08/.git
mkdir -p week-8
mv temp-week08/week-8/. week-8/
cp -r temp-week08/docs/. docs/
cp temp-week08/scripts/check-week8.sh scripts/
rm -rf temp-week08
```

**`week-8/minio.yaml` and `.github/workflows/backup.yml` are not shipped as files in
this repo.** You write them yourself, following the wiki step by step -- they are part
of the actual exercise for this lab.

## Deliverables Checklist

Before submitting, ensure you have:

- [ ] `week-8/minio.yaml` committed
- [ ] `week-8/restic-env.sh` committed (with your MinIO port, and no passwords in it)
- [ ] `.github/workflows/backup.yml` committed
- [ ] `week-8/runbook.md` committed using the required format
- [ ] All changes merged into `main` through a pull request
- [ ] Google Doc updated with recovery drill results
- [ ] `./scripts/check-week8.sh` runs clean
- [ ] All screenshots captured as specified

## Role Distribution

This week's work is distributed across all four roles. No single role can complete it alone.

- **Scrum Master:** Sprint process, issue tracking, completion summary
- **System Admin:** Environment health, MinIO deployment in the cluster, backup target placement
- **QA:** Validation check script authoring, recovery drill verification, sign-off before submission
- **Developer(s):** restic configuration, database backup and restore commands, GitHub Actions workflow, runbook authoring

## File Structure

```
week-8/
├── .env.backup (MinIO and restic passwords - DO NOT COMMIT)
├── minio.yaml (MinIO PersistentVolumeClaim, Deployment, and Service - written by you in this lab)
├── restic-env.sh (restic configuration - reads passwords from .env.backup, safe to commit)
└── runbook.md (recovery procedure and measured results)

.github/workflows/
└── backup.yml (scheduled backup workflow - written by you in this lab, not shipped)

scripts/
└── check-week8.sh (validation check script)

docs/
├── sprint-4-retrospective.md (what went well, what didn't)
└── qa-report-4.md (validation results and rework needed)
```

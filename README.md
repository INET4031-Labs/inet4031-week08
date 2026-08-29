# Week 8: Data Observability and Backup Verification

**Sprint 4 Async | Due before Sprint 4 Review**

## Architecture Assumption

This week, like all weeks from Week 3 onward, assumes your team container runs in `--privileged` mode. This has not been confirmed by the professor. If privileged mode is unavailable, some steps in this lab may fail or behave unexpectedly.

## Overview

In this lab, your team builds an automated backup pipeline for your PostgreSQL database, verifies that backups actually work under a simulated failure, and measures your recovery time against a defined target. You will provision a MinIO container as an S3-compatible backup destination, automate backups with restic using a GitHub Actions scheduled workflow, apply a retention policy, and simulate real data loss with a recovery drill. After completing this lab, you will have a working backup pipeline with a verified recovery procedure and a runbook documenting both.

## Learning Objectives

- Provision MinIO as an S3-compatible backup target using a Docker container
- Configure restic for PostgreSQL data volume backups to an S3-compatible backend
- Implement a retention policy using `restic forget --prune`
- Automate backups using a GitHub Actions scheduled workflow with cron syntax
- Execute a recovery drill and measure actual RTO against a stated target

## Prerequisites

- Week 7 complete: security controls applied, CI pipeline passing
- Application is running with data in the database

## Pulling This Week's Starter Content Into Your Team Repo

This repo (`inet4031-week08`) is instructor-provided starter/reference content for
Week 8, not something you clone standalone. Pull the pieces you need into your
team's single repo:

```bash
git remote add week8 https://github.com/INET4031-Labs/inet4031-week08.git
git fetch week8
git checkout week8/main -- week-8 scripts docs
git remote remove week8
```

**`.github/workflows/backup.yml` is not shipped as a file in this repo.** You write it
yourself, following the wiki step by step -- it is the actual exercise for this lab.

Do this before you start editing `week-8/` locally, or your local changes will be
silently overwritten by the checkout.

## Deliverables Checklist

Before submitting, ensure you have:

- [ ] `week-8/restic-env.sh` committed (credentials placeholdered or omitted)
- [ ] `.github/workflows/backup.yml` committed
- [ ] `week-8/runbook.md` committed using the required format
- [ ] Google Doc updated with recovery drill results
- [ ] `./scripts/check-week8.sh` runs clean
- [ ] All screenshots captured as specified

## Role Distribution

This week's work is distributed across all four roles. No single role can complete it alone.

- **Scrum Master:** Sprint process, issue tracking, completion summary
- **System Admin:** Environment health, Docker/MinIO configuration decisions, backup target placement
- **QA:** Acceptance criteria definition, validation check script authoring, recovery drill verification
- **Developer(s):** restic configuration, GitHub Actions workflow, runbook authoring

## File Structure

```
week-08/
├── .env.backup (credentials - DO NOT COMMIT)
├── restic-env.sh (restic configuration template - commit without real secrets)
└── runbook.md (recovery procedure and measured results)

.github/workflows/
└── backup.yml (scheduled backup workflow)

scripts/
└── check-week8.sh (validation check script)

docs/
├── week-08-acceptance-criteria.md (what "done" means for this sprint)
├── week-08-environment-log.md (infrastructure decisions and state)
├── sprint-4-retrospective.md (what went well, what didn't)
└── qa-report-4.md (validation results and rework needed)
```

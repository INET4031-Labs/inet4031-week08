#!/bin/bash
# Week 8 Validation Check Script
#
# This script verifies that all Week 8 deliverables are in place and functional.
# Run this script before submitting Week 8 for review:
#
#   ./scripts/check-week8.sh
#
# Expected output: PASS for all checks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0

# Helper function to print results
pass_check() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED++))
}

fail_check() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED++))
}

warn_check() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo "=========================================="
echo "Week 8 Validation Check"
echo "=========================================="
echo ""

# Check 1: restic-env.sh exists
echo "Check 1: restic-env.sh exists"
if [ -f "$REPO_ROOT/week-8/restic-env.sh" ]; then
    pass_check "week-8/restic-env.sh found"
else
    fail_check "week-8/restic-env.sh not found"
fi
echo ""

# Check 2: restic-env.sh does not contain real credentials
echo "Check 2: restic-env.sh does not contain real credentials"
# TODO: This check looks for placeholder values. Update to match your actual credentials
# if you find this check is too strict.
if grep -q "changethispassword" "$REPO_ROOT/week-8/restic-env.sh"; then
    warn_check "restic-env.sh still contains 'changethispassword' placeholder"
    pass_check "Placeholder found (credentials not exposed)"
else
    warn_check "restic-env.sh may contain real credentials - verify manually before committing"
fi
echo ""

# Check 3: .env.backup is in .gitignore
echo "Check 3: .env.backup is in .gitignore"
if [ -f "$REPO_ROOT/.gitignore" ]; then
    if grep -q ".env.backup" "$REPO_ROOT/.gitignore"; then
        pass_check ".env.backup is in .gitignore"
    else
        fail_check ".env.backup is not in .gitignore - add it before committing!"
    fi
else
    warn_check ".gitignore does not exist - create it and add .env.backup"
fi
echo ""

# Check 4: GitHub Actions workflow exists
echo "Check 4: GitHub Actions backup workflow exists"
if [ -f "$REPO_ROOT/.github/workflows/backup.yml" ]; then
    pass_check ".github/workflows/backup.yml found"

    # Verify YAML syntax (basic check)
    if grep -q "Scheduled Database Backup" "$REPO_ROOT/.github/workflows/backup.yml"; then
        pass_check "Workflow name 'Scheduled Database Backup' found"
    else
        fail_check "Workflow name not found"
    fi

    # Check for cron schedule
    if grep -q "cron:" "$REPO_ROOT/.github/workflows/backup.yml"; then
        pass_check "Cron schedule found in workflow"
    else
        fail_check "Cron schedule not found - workflow will not run on schedule"
    fi
else
    fail_check ".github/workflows/backup.yml not found"
fi
echo ""

# Check 5: Runbook exists and contains required sections
#
# PATCHED BY QA SOLVE PASS (see _orchestration/solve-log-week-08.md): the original version
# of this check declared `local sections=(...)` and `local all_found=true` outside of any
# function body. `local` is only valid inside a function in bash; used at top level, it
# either errors outright or (depending on shell) silently fails to scope the variable, and
# combined with `set -e` at the top of this script, the check-5 block could abort the
# entire script before Checks 6-10 ever ran. Rewritten below as a plain loop with no
# `local` keyword, which is valid at top-level script scope.
echo "Check 5: Runbook exists with required sections"
if [ -f "$REPO_ROOT/week-8/runbook.md" ]; then
    pass_check "week-8/runbook.md found"

    for section in "Symptom" "Root Cause" "Fix" "Measured Before/After"; do
        if grep -iq "$section" "$REPO_ROOT/week-8/runbook.md"; then
            pass_check "  - Section '$section' found in runbook"
        else
            fail_check "  - Section '$section' NOT found in runbook"
        fi
    done
else
    fail_check "week-8/runbook.md not found"
fi
echo ""

# Check 6: MinIO container is running
echo "Check 6: MinIO container status"
if command -v docker &> /dev/null; then
    if docker ps --filter name=minio --quiet | grep -q . ; then
        pass_check "MinIO container is running"

        # Check if MinIO is listening on ports
        if docker ps --filter name=minio --format "{{.Ports}}" | grep -q "9000"; then
            pass_check "  - MinIO S3 API port 9000 is exposed"
        else
            fail_check "  - MinIO S3 API port 9000 is not exposed"
        fi

        if docker ps --filter name=minio --format "{{.Ports}}" | grep -q "9001"; then
            pass_check "  - MinIO console port 9001 is exposed"
        else
            warn_check "  - MinIO console port 9001 may not be exposed"
        fi
    else
        fail_check "MinIO container is not running - start it with: docker run -d --name minio ..."
    fi
else
    warn_check "Docker not available - cannot check MinIO status"
fi
echo ""

# Check 7: restic is installed
echo "Check 7: restic installation"
if command -v restic &> /dev/null; then
    pass_check "restic is installed"
    restic version 2>&1 | head -1 | sed 's/^/  - /'
else
    fail_check "restic is not installed - install with: apt-get install -y restic"
fi
echo ""

# Check 8: restic repository is initialized (check if .env.backup exists)
echo "Check 8: restic repository status"
if [ -f "$REPO_ROOT/week-8/.env.backup" ]; then
    pass_check "week-8/.env.backup exists (restic credentials)"

    # Try to source the env file and check snapshots
    if command -v restic &> /dev/null; then
        # TODO: This check requires .env.backup to be properly populated
        # If this fails, you may need to manually source restic-env.sh
        if source "$REPO_ROOT/week-8/.env.backup" 2>/dev/null && \
           source "$REPO_ROOT/week-8/restic-env.sh" 2>/dev/null && \
           restic snapshots &>/dev/null 2>&1; then
            pass_check "restic repository is initialized and accessible"
        else
            warn_check "Could not verify restic repository - you may need to run 'restic init' first"
        fi
    fi
else
    fail_check "week-8/.env.backup not found - run the MinIO setup steps from Week 8 Part 1"
fi
echo ""

# Check 9: At least one restic snapshot exists
echo "Check 9: restic snapshots"
if [ -f "$REPO_ROOT/week-8/.env.backup" ] && command -v restic &> /dev/null; then
    (
        source "$REPO_ROOT/week-8/.env.backup" 2>/dev/null || true
        source "$REPO_ROOT/week-8/restic-env.sh" 2>/dev/null || true

        # TODO: This check requires the restic repository to be accessible
        snapshot_count=$(restic snapshots 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")

        if [ "$snapshot_count" -gt 0 ]; then
            pass_check "At least one restic snapshot exists"
            echo "  - Run 'restic snapshots' to see all backups"
        else
            fail_check "No restic snapshots found - run: restic backup /var/lib/docker/volumes/week-2_db-data/_data"
        fi
    )
else
    warn_check "Cannot check snapshots - restic not available or .env.backup missing"
fi
echo ""

# Check 10: Verify no commits contain credentials
echo "Check 10: Checking for exposed credentials in git history"
if command -v git &> /dev/null; then
    # TODO: This check looks for common credential patterns
    # Adjust the patterns if needed for your team's setup
    if git log --all -p | grep -i "RESTIC_PASSWORD.*changethis" &>/dev/null; then
        pass_check "No exposed RESTIC_PASSWORD in git history (contains placeholders only)"
    elif git log --all -p | grep -E "(RESTIC_PASSWORD|AWS_SECRET_ACCESS_KEY|MINIO_ROOT_PASSWORD)" | \
         grep -v "changethispassword" | grep -v "TODO" &>/dev/null; then
        fail_check "Potential credentials found in git history - review and rotate if needed"
    else
        pass_check "No obvious credentials in git history"
    fi
else
    warn_check "git not available - cannot check git history"
fi
echo ""

# Summary
echo "=========================================="
echo "Summary"
echo "=========================================="
echo -e "Passed: ${GREEN}${PASSED}${NC}"
echo -e "Failed: ${RED}${FAILED}${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    echo "Week 8 is ready for QA review and submission."
    exit 0
else
    echo -e "${RED}$FAILED check(s) failed. Please address the failures above.${NC}"
    exit 1
fi

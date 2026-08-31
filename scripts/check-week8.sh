#!/bin/bash

# Week 8 Validation Script
# This script runs all acceptance checks for Week 8 deliverables
# Run from the repository root: ./scripts/check-week8.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( dirname "$SCRIPT_DIR" )"

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track pass/fail status
PASS_COUNT=0
FAIL_COUNT=0

# Helper function to print results
check_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

check_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo "========================================="
echo "Week 8 Validation Checks"
echo "========================================="
echo ""

# =========================================
# Check 1: Required Files Exist
# =========================================
echo "Check 1: Required Files Exist"
echo "-----------------------------------"

if [ -f "$REPO_ROOT/week-8/restic-env.sh" ]; then
    check_pass "week-8/restic-env.sh exists"
else
    check_fail "week-8/restic-env.sh not found"
fi

if [ -f "$REPO_ROOT/week-8/runbook.md" ]; then
    check_pass "week-8/runbook.md exists"
else
    check_fail "week-8/runbook.md not found"
fi

if [ -f "$REPO_ROOT/.github/workflows/backup.yml" ]; then
    check_pass ".github/workflows/backup.yml exists"
else
    check_fail ".github/workflows/backup.yml not found"
fi

# =========================================
# Check 2: Credentials Not Committed
# =========================================
echo ""
echo "Check 2: Credentials Not Committed"
echo "----------------------------------------"

if [ -f "$REPO_ROOT/.gitignore" ] && grep -q "\.env\.backup" "$REPO_ROOT/.gitignore"; then
    check_pass "week-8/.env.backup is in .gitignore"
else
    check_fail "week-8/.env.backup is not in .gitignore"
fi

if [ -f "$REPO_ROOT/week-8/restic-env.sh" ] && grep -q "changethispassword" "$REPO_ROOT/week-8/restic-env.sh"; then
    check_pass "week-8/restic-env.sh still uses the placeholder RESTIC_PASSWORD (not a real committed secret)"
else
    check_warn "week-8/restic-env.sh does not contain the placeholder password - verify manually that no real secret was committed"
fi

# =========================================
# Check 3: GitHub Actions Backup Workflow
# =========================================
echo ""
echo "Check 3: GitHub Actions Backup Workflow"
echo "---------------------------------------------"

if [ -f "$REPO_ROOT/.github/workflows/backup.yml" ]; then
    if grep -q "cron:" "$REPO_ROOT/.github/workflows/backup.yml"; then
        check_pass "backup.yml has a cron trigger"
    else
        check_fail "backup.yml is missing a cron trigger"
    fi

    if grep -q "restic" "$REPO_ROOT/.github/workflows/backup.yml"; then
        check_pass "backup.yml references restic"
    else
        check_fail "backup.yml does not reference restic"
    fi
else
    check_warn "Skipping backup.yml content checks - file not found"
fi

# =========================================
# Check 4: Runbook Contains Required Sections
# =========================================
echo ""
echo "Check 4: Runbook Contains Required Sections"
echo "---------------------------------------------------"

if [ -f "$REPO_ROOT/week-8/runbook.md" ]; then
    for section in "Symptom" "Root Cause" "Fix" "Measured Before/After"; do
        if grep -iq "$section" "$REPO_ROOT/week-8/runbook.md"; then
            check_pass "Runbook contains section: $section"
        else
            check_fail "Runbook is missing section: $section"
        fi
    done
else
    check_warn "Skipping runbook content checks - file not found"
fi

# =========================================
# Check 5: MinIO Container Is Running
# =========================================
echo ""
echo "Check 5: MinIO Container Is Running"
echo "-----------------------------------------"

if command -v docker &> /dev/null; then
    if docker ps --filter name=minio --quiet | grep -q .; then
        check_pass "MinIO container is running"

        if docker ps --filter name=minio --format "{{.Ports}}" | grep -q "9000"; then
            check_pass "MinIO S3 API port 9000 is exposed"
        else
            check_fail "MinIO S3 API port 9000 is not exposed"
        fi
    else
        check_fail "MinIO container is not running"
    fi
else
    check_fail "docker is not available"
fi

# =========================================
# Check 6: restic Is Installed
# =========================================
echo ""
echo "Check 6: restic Is Installed"
echo "------------------------------"

if command -v restic &> /dev/null; then
    check_pass "restic is installed ($(restic version 2>&1 | head -1))"
else
    check_fail "restic is not installed"
fi

# =========================================
# Check 7: At Least One restic Snapshot Exists
# =========================================
echo ""
echo "Check 7: At Least One restic Snapshot Exists"
echo "----------------------------------------------------"

if [ -f "$REPO_ROOT/week-8/.env.backup" ] && [ -f "$REPO_ROOT/week-8/restic-env.sh" ] && command -v restic &> /dev/null; then
    SNAPSHOT_COUNT=$(
        source "$REPO_ROOT/week-8/.env.backup" 2>/dev/null
        source "$REPO_ROOT/week-8/restic-env.sh" 2>/dev/null
        restic snapshots 2>/dev/null | grep -c "^[0-9a-f]" || echo "0"
    )

    if [ "$SNAPSHOT_COUNT" -gt 0 ] 2>/dev/null; then
        check_pass "At least one restic snapshot exists ($SNAPSHOT_COUNT found)"
    else
        check_fail "No restic snapshots found"
    fi
else
    check_warn "Skipping snapshot check - week-8/.env.backup, week-8/restic-env.sh, or restic itself is missing"
fi

# =========================================
# Summary
# =========================================
echo ""
echo "========================================="
echo "Validation Summary"
echo "========================================="
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"
echo ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "${GREEN}Status: ALL CHECKS PASSED${NC}"
    exit 0
else
    echo -e "${RED}Status: SOME CHECKS FAILED - Review errors above${NC}"
    exit 1
fi

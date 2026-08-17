#!/bin/bash
# restic Environment Configuration
#
# Source this file before running any restic commands:
#   source week-8/restic-env.sh
#
# NOTE: In production, use a secret management system (Vault, AWS Secrets Manager, etc.)
#       instead of environment variables. This approach is for lab use only.

# TODO: Replace with your MinIO S3 endpoint
# This should point to the MinIO instance running in your team container
export RESTIC_REPOSITORY="s3:http://localhost:9000/backups"

# TODO: Replace with your MinIO root user (typically "backup")
export AWS_ACCESS_KEY_ID="backup"

# TODO: Generate a strong random password and replace this placeholder
# Use: openssl rand -base64 24
# Then store it securely and reference it here or in a .gitignore'd file
export AWS_SECRET_ACCESS_KEY="changethispassword"

# TODO: Generate a strong restic encryption password and replace this placeholder
# Use: openssl rand -base64 24
# This password encrypts the repository itself. If lost, backups cannot be decrypted.
# Store this password somewhere secure (password manager, team notes, etc.)
export RESTIC_PASSWORD="changethispassword"

# Optional: Set verbosity for debugging
# Uncomment to see detailed output from restic commands
# export RESTIC_VERBOSE=true

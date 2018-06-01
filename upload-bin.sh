#!/usr/bin/env bash
set -e
set -x

function log() {
    ts=$(date '+%Y-%m-%dT%H:%M:%SZ')
    printf '%s [upload-bin] %s\n' "$ts" "$1"
}

function error() {
    log "$1"
    exit 1
}

log "Running upload-bin"

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    error "Unable to perform deploy: missing AWS credentials!"
fi

log "Installing awscli"
pip install awscli --upgrade --user
export PATH=$HOME/.local/bin:$PATH
aws --version
log "awscli installed"

log "Uploading to bucket: ${S3_BUCKET_NAME}"
aws s3 mv a.out "s3://${S3_BUCKET_NAME}/commit-${CIRCLE_SHA1}-a.out"
log "Upload completed"

#!/usr/bin/env bash
set -e

function log() {
    ts=$(date '+%Y-%m-%dT%H:%M:%SZ')
    printf '%s ************** [%s] %s\n' "$ts" "$1" "$2"
}

function error() {
    log "$1" "$2"
    log "." "SCRIPT COMPLETED WITH ERRORS"
    exit 1
}

log "." "SCRIPT STARTED"


####### CHECK REQUIRED ENV VARS #######
log "check" "Check aws env vars"
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_DEFAULT_REGION" ]; then
    error "Missing AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY or AWS_DEFAULT_REGION"
fi
log "check" "Check S3 bucket env var"
if [ -z "$S3_BUCKET_NAME" ]; then
    error "Missing S3_BUCKET_NAME"
fi
log "check" "Check CirclCI env vars"
if [ -z "$CIRCLE_BRANCH" ] || [ -z "$CIRCLE_SHA1" ]; then
    error "Missing CIRCLE_BRANCH or CIRCLE_SHA1"
fi


####### GENERAL #######
log "general" "Run apt-update"
apt-get update
log "general" "Install build-essential"
apt-get install -y build-essential
log "general" "Print gcc version"
gcc --version
log "general" "Install curl"
apt-get install -y curl
log "general" "Install git"
apt-get install -y git-core
log "general" "Print git version"
git --version


####### RUST #######
log "rust" "Install rust"
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
log "rust" "Print rustc and cargo versions"
rustc --version
cargo --version


####### ROCKSDB #######
log "rocksdb" "Install packages for rocksdb"
apt-get install -y libgflags-dev
apt-get install -y libsnappy-dev
apt-get install -y zlib1g-dev
apt-get install -y libbz2-dev
apt-get install -y liblz4-dev
apt-get install -y libzstd-dev

log "rocksdb" "Build from source"
git clone https://github.com/facebook/rocksdb.git
cd rocksdb/
make all
cd ..


####### BRIDGE #######
log "bridge" "Install solc"
apt-get install -y software-properties-common
add-apt-repository -y ppa:ethereum/ethereum
apt-get update
apt-get install -y solc
log "bridge" "Install libudev-dev"
apt-get install -y libudev-dev
log "bridge" "Install libssl-dev"
apt-get install -y libssl-dev
log "bridge" "Install pkg-config"
apt-get install -y pkg-config
log "bridge" "Compile binary"
cd poa-bridge-master
#RUST_BACKTRACE=1 make
make
log "bridge" "Print bridge version"
target/release/bridge --version
cd ..


####### AWS #######
log "aws" "Install python"
apt-get install -y python2.7 python-pip

log "aws" "Install awscli"
pip install awscli --upgrade --user
export PATH=$HOME/.local/bin:$PATH
log "aws" "Print aws version"
aws --version

log "Upload to S3 bucket ${S3_BUCKET_NAME}"
aws s3 mv poa-bridge-master/target/release/bridge "s3://${S3_BUCKET_NAME}/bridge-branch_${CIRCLE_BRANCH}-commit_${CIRCLE_SHA1}"

log "." "SCRIPT COMPLETED SUCCESSFULLY"

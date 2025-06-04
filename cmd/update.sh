#!/bin/bash
set -eo pipefail

# Constants
SCRIPT_DIR=$(cd "$(dirname "$0")" || exit; pwd)
MD5_URL="https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/md5sum.txt"
MD5_FILE="/tmp/wanxiang-lts-zh-hans.gram.md5sum.txt"
GRAM_URL="https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram"
GRAM_FILE="$SCRIPT_DIR/../wanxiang-lts-zh-hans.gram"

# Log function with colored output
log() {
  local level=$1
  shift
  local message="$*"
  
  case "$level" in
    "info")
      echo -e "\033[0;32m[INFO]\033[0m $message"
      ;;
    "warn")
      echo -e "\033[0;33m[WARN]\033[0m $message"
      ;;
    "error")
      echo -e "\033[0;31m[ERROR]\033[0m $message"
      ;;
    *)
      echo "$message"
      ;;
  esac
}

# Download file function
download_file() {
  local url=$1
  local output_file=$2
  local description=$3
  
  log "info" "Downloading $description..."
  if ! curl -s -f -L -o "$output_file" "$url"; then
    log "error" "Failed to download $description"
    return 1
  fi
  return 0
}

# Get MD5 checksum of a file
get_md5() {
  local file=$1
  
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS uses md5 instead of md5sum
    md5 -q "$file"
  else
    # Linux and others use md5sum
    md5sum "$file" | cut -d ' ' -f 1
  fi
}

# Extract expected MD5 from MD5 file
get_expected_md5() {
  local md5_file=$1
  
  # Extract only the hash part from first line
  head -1 "$md5_file" | awk '{print $1}'
}

# Check if grammar file needs to be updated
check_grammar_update() {
  if ! download_file "$MD5_URL" "$MD5_FILE" "MD5 checksum"; then
    log "error" "Unable to download MD5 file, assuming update needed"
    return 0
  fi
  
  if [ ! -f "$GRAM_FILE" ]; then
    log "info" "Grammar file not found locally"
    return 0
  fi
  
  log "info" "Checking MD5 checksums..."
  
  local expected_md5
  local actual_md5
  
  expected_md5=$(get_expected_md5 "$MD5_FILE")
  actual_md5=$(get_md5 "$GRAM_FILE")
  
  log "info" "Expected MD5: $expected_md5"
  log "info" "Actual MD5:   $actual_md5"
  
  if [ "$expected_md5" = "$actual_md5" ]; then
    log "info" "MD5 checksums match. No update needed."
    return 1
  else
    log "info" "MD5 checksums do not match. Update needed."
    return 0
  fi
}

# Update grammar file
update_grammar() {
  if ! download_file "$GRAM_URL" "$GRAM_FILE" "grammar file"; then
    log "error" "Failed to download grammar file"
    return 1
  fi
  log "info" "Grammar file updated successfully"
  return 0
}

# Check for upstream git changes
check_git_updates() {
  log "info" "Checking for upstream updates..."
  
  git fetch upstream
  local upstream_changes
  upstream_changes=$(git rev-list --count HEAD..upstream/main)
  
  if [ "$upstream_changes" -gt 0 ]; then
    log "info" "Found $upstream_changes new commit(s)"
    return 0
  else
    log "info" "No upstream changes. Already up-to-date."
    return 1
  fi
}

# Update git repo by rebasing from upstream
update_git_repo() {
  log "info" "Rebasing with upstream..."
  git rebase --autostash upstream/main
  log "info" "Rebase complete"
}

# Main execution
main() {
  cd "$SCRIPT_DIR" || exit 1
  
  # Check and update grammar file if needed
  if check_grammar_update; then
    update_grammar
  fi
  
  # Check and update git repo if needed
  if check_git_updates; then
    update_git_repo
  fi
  
  log "info" "Update process completed successfully"
}

# Run the main function
main

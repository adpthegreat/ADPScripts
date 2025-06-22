#!/bin/bash

# Git Repositories Updater Script
# Updates all git repositories in the current directory or specified directory

set -e  # Exit on any error

# Default directory is current directory
TARGET_DIR="${1:-.}"
# Store the original directory
ORIGINAL_DIR=$(pwd)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if directory exists
if [ ! -d "$TARGET_DIR" ]; then
    print_error "Directory '$TARGET_DIR' does not exist!"
    exit 1
fi

print_status "Searching for Git repositories in: $(realpath "$TARGET_DIR")"
echo

# Counter for repositories
total_repos=0
updated_repos=0
uptodate_repos=0
failed_repos=0

# Find all directories containing .git folder
while IFS= read -r -d '' git_dir; do
    repo_dir=$(realpath "$(dirname "$git_dir")")
    repo_name=$(basename "$repo_dir")
    
    total_repos=$((total_repos + 1))
    
    echo "================================================"
    print_status "Processing repository: $repo_name"
    print_status "Location: $repo_dir"
    
    # Change to the repository directory using absolute path
    if ! cd "$repo_dir"; then
        print_error "Failed to change to directory: $repo_dir"
        failed_repos=$((failed_repos + 1))
        continue
    fi
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not a valid git repository: $repo_dir"
        failed_repos=$((failed_repos + 1))
        continue
    fi
    
    # Check if there's a remote configured
    if ! git remote | grep -q .; then
        print_warning "No remote configured for $repo_name - skipping"
        continue
    fi
    
    # Get current branch
    current_branch=$(git branch --show-current)
    if [ -z "$current_branch" ]; then
        print_warning "Detached HEAD state in $repo_name - skipping"
        continue
    fi
    
    print_status "Current branch: $current_branch"
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        print_warning "Uncommitted changes detected in $repo_name"
        print_warning "Stashing changes before pull..."
        git stash push -m "Auto-stash before pull on $(date)"
        stashed=true
    else
        stashed=false
    fi
    
    # Fetch and pull
    print_status "Fetching updates..."
    if git fetch origin; then
        print_status "Pulling changes..."
        pull_output=$(git pull origin "$current_branch" 2>&1)
        pull_exit_code=$?
        
        if [ $pull_exit_code -eq 0 ]; then
            # Check if there were actual changes
            if echo "$pull_output" | grep -q "Already up to date\|Already up-to-date"; then
                print_status "Repository $repo_name is already up to date"
                uptodate_repos=$((uptodate_repos + 1))
            else
                print_success "Successfully updated $repo_name"
                updated_repos=$((updated_repos + 1))
                echo "$pull_output"
            fi
            
            # Restore stashed changes if any
            if [ "$stashed" = true ]; then
                print_status "Restoring stashed changes..."
                if git stash pop; then
                    print_success "Stashed changes restored"
                else
                    print_warning "Could not restore stashed changes - they remain in stash"
                fi
            fi
        else
            print_error "Failed to pull changes for $repo_name"
            echo "$pull_output"
            failed_repos=$((failed_repos + 1))
        fi
    else
        print_error "Failed to fetch updates for $repo_name"
        failed_repos=$((failed_repos + 1))
    fi
    
    echo
    
    # Return to original directory before processing next repo
    cd "$ORIGINAL_DIR"
    
done < <(find "$TARGET_DIR" -name ".git" -type d -print0)

# Summary
echo "================================================"
echo "UPDATE SUMMARY"
echo "================================================"
print_status "Total repositories found: $total_repos"
print_success "Successfully updated: $updated_repos"
print_status "Already up to date: $uptodate_repos"
if [ $failed_repos -gt 0 ]; then
    print_error "Failed to update: $failed_repos"
fi

if [ $total_repos -eq 0 ]; then
    print_warning "No Git repositories found in $TARGET_DIR"
    exit 1
fi

print_status "Update process completed!"
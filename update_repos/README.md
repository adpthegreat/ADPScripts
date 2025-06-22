# Git Repositories Updater Script

A bash script that automatically finds and updates all Git repositories in a directory using `git pull`. Perfect for keeping multiple project repositories up to date with a single command.

## Features

- 🔍 **Automatic Discovery**: Finds all Git repositories in the specified directory
- 🛡️ **Safe Updates**: Stashes uncommitted changes before pulling and restores them afterward
- 🎨 **Colored Output**: Easy-to-read status messages with color-coded feedback
- 📊 **Detailed Reporting**: Shows summary of successful and failed updates
- 🌿 **Branch Aware**: Only pulls from the current branch of each repository
- ⚡ **Error Handling**: Continues processing other repos if one fails
- 🔗 **Remote Validation**: Skips repositories without configured remotes

## Prerequisites

- **Git** installed and configured
- **Bash shell** (available in Windows Ubuntu/WSL, Linux, macOS)
- **Execute permissions** on the script file

## Installation

1. **Download the script** and save it as `update-repos.sh`:

```bash
# Option 1: Create the file and copy the script content
nano update-repos.sh
# Paste the script content and save (Ctrl+X, Y, Enter)

# Option 2: Download directly if you have the file
curl -O https://your-script-location/update-repos.sh
```

2. **Make the script executable**:

```bash
chmod +x update-repos.sh
```

## Usage

### Basic Usage

Update all Git repositories in the current directory:

```bash
./update-repos.sh
```

### Specify Directory

Update all Git repositories in a specific directory:

```bash
./update-repos.sh /path/to/your/repositories
```

### Examples

```bash
# Update repos in current directory
./update-repos.sh

# Update repos in your projects folder
./update-repos.sh ~/projects

# Update repos in a specific path
./update-repos.sh /home/user/development

# Windows WSL example
./update-repos.sh /mnt/c/Users/YourName/Documents/GitHub
```

## What the Script Does

For each Git repository found, the script will:

1. **Validate** that it's a proper Git repository
2. **Check** for configured remotes (skips if none found)
3. **Identify** the current branch
4. **Stash** any uncommitted changes temporarily
5. **Fetch** updates from the remote repository
6. **Pull** changes to the current branch
7. **Restore** any stashed changes
8. **Report** the status of the operation

## Output Example

```
[INFO] Searching for Git repositories in: /home/user/projects

================================================
[INFO] Processing repository: my-website
[INFO] Location: /home/user/projects/my-website
[INFO] Current branch: main
[INFO] Fetching updates...
[INFO] Pulling changes...
[SUCCESS] Successfully updated my-website

================================================
[INFO] Processing repository: api-server
[INFO] Location: /home/user/projects/api-server
[INFO] Current branch: develop
[WARNING] Uncommitted changes detected in api-server
[WARNING] Stashing changes before pull...
[INFO] Fetching updates...
[INFO] Pulling changes...
[INFO] Restoring stashed changes...
[SUCCESS] Stashed changes restored
[SUCCESS] Successfully updated api-server

================================================
UPDATE SUMMARY
================================================
[INFO] Total repositories found: 2
[SUCCESS] Successfully updated: 2
[INFO] Update process completed!
```

## Safety Features

### Uncommitted Changes
The script automatically detects uncommitted changes and:
- Stashes them before pulling
- Restores them after successful pull
- Keeps them in the stash if restoration fails

### Error Handling
- Continues with other repositories if one fails
- Provides clear error messages
- Never loses your work

### Validation Checks
- Verifies each directory is a valid Git repository
- Checks for configured remotes
- Handles detached HEAD states gracefully

## Common Issues & Solutions

### Permission Denied
```bash
# Make sure the script is executable
chmod +x update-repos.sh
```

### No Repositories Found
```bash
# Check if you're in the right directory
ls -la
# Look for directories containing .git folders
find . -name ".git" -type d
```

### Authentication Issues
Make sure your Git credentials are configured:
```bash
# Check current configuration
git config --list

# Set up credentials if needed
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Windows WSL Path Issues
Use proper WSL paths:
```bash
# Windows C: drive
./update-repos.sh /mnt/c/Users/YourName/Documents/Projects

# WSL home directory
./update-repos.sh ~/projects
```

## Customization

You can modify the script to:
- Change color schemes by editing the color variables
- Add different Git operations (fetch only, specific branches, etc.)
- Customize the output format
- Add email notifications or logging

## Troubleshooting

### Script Won't Run
1. Check if bash is available: `which bash`
2. Ensure execute permissions: `ls -la update-repos.sh`
3. Try running with bash directly: `bash update-repos.sh`

### Git Authentication
If you encounter authentication issues:
1. Use SSH keys for seamless authentication
2. Configure Git credential helper
3. Check if your personal access tokens are valid

### Performance
For many repositories, you might want to:
- Run in the background: `./update-repos.sh > update.log 2>&1 &`
- Process only specific repositories by organizing them in separate directories

## Contributing

Feel free to modify and enhance the script for your specific needs. Common improvements include:
- Parallel processing for faster updates
- Configuration file support
- Integration with CI/CD pipelines
- Support for different Git hosting providers

## License

This script is provided as-is for educational and practical use. Feel free to modify and distribute according to your needs.
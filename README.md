# Git Archiver Script
Shell script on MacOS to create a complete archive of a git repository with all submodules.

# Features
- [x] Write log file for debug
- [x] Initialize submodules before running
- [x] Archive main repository and all submodules and nested submodules
- [x] Export to zip file `release.zip`
- [x] Not include all files and folders from your `.gitignore`
- [x] Open root folder after running

# Usage

- Place the script in your root project directory
- Run the command `sh git_archiver.sh` or `sh git_archiver.sh true` to initialize submodules
- Get your archive as a `release.zip` file in the root directory


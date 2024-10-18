#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Color codes
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

# Log file path
LOG_FILE="archive.log"

# # Enable the line below to write output/error to the log file.
exec > "$LOG_FILE" 2>&1

echo "Starting the archive process at $(date)"

# [UPDATE_SUBMODULE] is used to update submodule or not. Default is "false".
UPDATE_SUBMODULE=$1

if [ -z "$UPDATE_SUBMODULE" ]; then
    UPDATE_SUBMODULE="false"
fi

if [[ "${UPDATE_SUBMODULE}" == "true" ]]; then
    # Ensure all submodules are updated recursively
    echo "Updating submodules recursively..."
    git submodule update --init --recursive

    echo "Updated submodules successfully."
fi

# Create a temporary directory for the archive
TEMP_DIR=$(mktemp -d)
echo "Created temporary directory: $TEMP_DIR"

# Archive the main repository
echo "Archiving main repository..."
git archive HEAD | tar -x -C "$TEMP_DIR"
echo "Main repository archived successfully."

# Archive submodules and their nested submodules
echo "Archiving submodules and nested submodules..."
git submodule foreach '
  echo "Archiving submodule: $sm_path"

  # Create the submodule directory structure inside the temporary folder
  mkdir -p '"$TEMP_DIR"'/$sm_path

  # Archive the submodule into the appropriate folder in the temporary directory
  (cd $toplevel/$sm_path && git archive HEAD) | tar -x -C '"$TEMP_DIR"'/$sm_path

  # Check if this submodule has nested submodules and archive them as well
  if [ -f "$toplevel/$sm_path/.gitmodules" ]; then
    echo "Found nested submodules in $sm_path, archiving them..."

    SUBMODULE='"$TEMP_DIR"'/$sm_path

    # (cd "$toplevel/$sm_path" && git submodule update --init --recursive)
    (cd "$toplevel/$sm_path" && git submodule foreach "
      echo \"Archiving nested submodule: \$sm_path\";
      mkdir -p "$SUBMODULE"/\$sm_path;
      (cd \$toplevel/\$sm_path && git archive HEAD) | tar -x -C "$SUBMODULE"/\$sm_path;
    ")
  fi
'

# Zip the entire content of the temporary directory
echo "Creating release.zip in the current directory..."
cd "$TEMP_DIR" || exit 1
zip -r "$OLDPWD/release.zip" . 2>/dev/null  # Suppress permission warnings
echo "Zip archive created: release.zip."
open $OLDPWD

# Clean up
echo "Cleaning up temporary files..."
cd ..
rm -rf "$TEMP_DIR"

echo "${GREEN}✅ Archive release.zip created successfully.${RESET}"
echo "${GREEN}Archive process completed at $(date)${RESET}"

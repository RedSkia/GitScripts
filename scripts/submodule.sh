#!/bin/bash

# The path or url of the .git module
readonly GIT_MODULE="location/to/submodule.git"

# The destination path for the .git module; (Leave blank to use the script's directory as the default location)
readonly GIT_MODULE_DEST=""

# Override existing module; (0 = false, 1 = true)
readonly OVERRIDE=0

readonly SCRIPT_DIR="${GIT_MODULE_DEST:-$(dirname "$(realpath "${BASH_SOURCE[0]}")")}"
readonly MODULE_NAME=$(basename "$GIT_MODULE" .git)
readonly MODULE_PATH="${SCRIPT_DIR}/${MODULE_NAME}"

if (grep -q "$MODULE_PATH" .gitmodules || [ -d "$MODULE_PATH"]) && [ "$OVERRIDE" -ne 1 ]; then
    echo "Submodule already exists or override is missing"
    exit 0
fi

if [ -d "$MODULE_PATH" ]; then
    echo "Removing submodule: $MODULE_NAME"
    git submodule deinit -f "$MODULE_PATH"
    git rm -f "$MODULE_PATH"
    rm -rf "$MODULE_PATH"
fi

echo "Adding submodule: $MODULE_NAME"
git submodule add "$GIT_MODULE" "$MODULE_PATH"
git submodule update --init --recursive
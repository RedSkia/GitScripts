#!/bin/bash

# The URL of the Git module to add
readonly GIT_MODULE="https://github.com/RedSkia/Template.git"

# The destination path for the Git module. Leave blank to use the script's directory as the default location.
readonly GIT_MODULE_DEST=""

# Option specifying the action to take:
# 1 = Install the submodule
# 2 = Update the submodule
# 3 = Remove the submodule
readonly OPTION=3

# Override flag to control whether existing submodules should be replaced:
# 0 = Do not override, 1 = Override existing submodules
readonly OVERRIDE=1

# Determine the script's directory or use GIT_MODULE_DEST if provided
readonly SCRIPT_DIR="${GIT_MODULE_DEST:-$(dirname "$(realpath "${BASH_SOURCE[0]}")")}"

# Extract the submodule's name from the Git module URL (without the .git extension)
readonly MODULE_NAME=$(basename "$GIT_MODULE" .git)

# Define the path where the submodule will be located within the script directory
readonly MODULE_PATH="${SCRIPT_DIR}/${MODULE_NAME}"

# Function to check if the submodule exists:
# Returns true if the submodule path is found in .gitmodules, the directory exists, or it is found in .git/modules
submodule_exists() {
    grep -q "$MODULE_PATH" .gitmodules || [ -d "$MODULE_PATH" ] || [ -d ".git/modules/$MODULE_NAME" ]
}

# Function to clear (remove) a submodule:
# This function removes all traces of the submodule from .gitmodules, .git/config, the file system, and .git/modules
clear_submodule() {
    echo "Clearing submodule: $MODULE_NAME"
    
    # Deinitialize and remove the submodule
    git submodule deinit -f "$MODULE_PATH"
    git rm -f "$MODULE_PATH"
    rm -rf "$MODULE_PATH"
    
    # Remove the submodule entry from .gitmodules if it exists
    sed -i "/$MODULE_PATH/d" .gitmodules
    
    # Remove submodule reference from .git/config
    git config -f .git/config --remove-section "submodule.$MODULE_PATH" 2>/dev/null
    
    # Remove the submodule's Git directory in .git/modules if it exists
    if [ -d ".git/modules/$MODULE_NAME" ]; then
        echo "Removing submodule directory from .git/modules: $MODULE_NAME"
        rm -rf ".git/modules/$MODULE_NAME"
    fi
}

case "$OPTION" in
    1)  
    # Install
        if submodule_exists; then
            if [ "$OVERRIDE" -eq 1 ]; then
                clear_submodule
            else
                echo "Submodule already exists in .gitmodules, directory, or .git/modules. To override, set OVERRIDE to 1."
                exit 0
            fi
        fi

        echo "Installing submodule: $MODULE_NAME"
        git submodule add --force "$GIT_MODULE" "$MODULE_NAME"
        git submodule update --init --recursive
        ;;

    2)  
    # Update
        if submodule_exists; then
            echo "Updating submodule: $MODULE_NAME"
            git submodule update --remote --merge
        else
            echo "Submodule not found in .gitmodules, directory, or .git/modules. Please install it first."
            exit 1
        fi
        ;;

    3)  
    # Remove
        if submodule_exists; then
            clear_submodule
        else
            echo "Submodule not found in .gitmodules, directory, or .git/modules. Nothing to clear."
            exit 1
        fi
        ;;

    *)
        echo "Invalid OPTION value. Use 1 for install, 2 for update, or 3 for remove."
        exit 1
        ;;
esac

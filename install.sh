#!/bin/bash

set -e

INSTALL_DIR="$HOME/.store"
SCRIPT_NAME="store.sh"
SOURCE_FILE="./store.sh"
TARGET_FILE="$INSTALL_DIR/$SCRIPT_NAME"

# Detect user's login shell
USER_SHELL=$(basename "$SHELL")

if [[ "$USER_SHELL" == "zsh" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "$USER_SHELL" == "bash" ]]; then
    SHELL_RC="$HOME/.bashrc"
else
    echo "Detected shell: $USER_SHELL"
    echo "Defaulting to .bashrc"
    SHELL_RC="$HOME/.bashrc"
fi

echo "Installing store..."

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Copy script
if [ -f "$SOURCE_FILE" ]; then
    cp "$SOURCE_FILE" "$TARGET_FILE"
    echo "✓ Copied $SOURCE_FILE to $TARGET_FILE"
else
    echo "Error: $SOURCE_FILE not found in current directory."
    exit 1
fi

# Add to RC file
if [ -f "$SHELL_RC" ]; then
    # Check if already sourced
    if grep -q "source.*$TARGET_FILE" "$SHELL_RC"; then
        echo "✓ Already installed in $SHELL_RC"
    else
        echo "" >> "$SHELL_RC"
        echo "# Store CLI" >> "$SHELL_RC"
        echo "source \"$TARGET_FILE\"" >> "$SHELL_RC"
        echo "✓ Added source command to $SHELL_RC"
    fi
    
    echo ""
    echo "Installation complete!"
    echo "Please restart your terminal or run:"
    echo "  source $SHELL_RC"
else
    echo "Warning: Could not find shell configuration file at $SHELL_RC"
    echo "Please manually add the following line to your shell config:"
    echo "  source \"$TARGET_FILE\""
fi

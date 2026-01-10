# For production
STORE_FILE="${STORE_DB_PATH:-$HOME/.store_db}"

# For testing, you can export STORE_DB_PATH="store_db_test.txt"
# export STORE_DB_PATH="store_db_test.txt"

# STORE: Store a key-value pair, with value being a string, directory, or file path
# Usage: store <key> <value>
# Example: store greet "hello world"
# Example: store home ~
# Example: store file <filepath>
function store() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: store <key> <value>"
        return 1
    fi

    mkdir -p "$(dirname "$STORE_FILE")"

    local key="$1"
    shift
    local value="$*"
    
    # Resolve absolute path if value is a directory or file
    if [[ -d "$value" ]]; then
        value="$(cd "$value" && pwd)"
    elif [[ -f "$value" ]]; then
        # For files, resolve the directory path then append the filename
        local dir
        dir="$(dirname "$value")"
        local filename
        filename="$(basename "$value")"
        value="$(cd "$dir" && pwd)/$filename"
    fi

    # Remove existing key if it exists to prevent duplicates
    if [[ -f "$STORE_FILE" ]]; then
        awk -F: -v k="$key" '$1 != k' "$STORE_FILE" > "${STORE_FILE}.tmp"
        mv "${STORE_FILE}.tmp" "$STORE_FILE"
    fi

    # Append new key:value
    echo "${key}:${value}" >> "$STORE_FILE"
    echo "Stored '$key' -> '$value'"
}

# STORED: Lists all keys and values
# Usage: stored
function stored() {
    column -s ":" -t "$STORE_FILE" 2>/dev/null || echo "Store is empty."
}

# RESTORE: Restore a value by key, list available keys if no arguments, run command with value if command is provided
# Usage: restore <key> [command]
# Example: restore greet -> "hello world"
# Example: restore greet echo -> echo "hello world"
function restore() {
    local target_key="$1"

    # Handle no arguments: Show keys
    if [[ -z "$target_key" ]]; then
        echo "Usage: restore <key> [command]"
        echo "Available keys:"
        [[ -f "$STORE_FILE" ]] && cut -d':' -f1 "$STORE_FILE"
        return
    fi

    shift
    local command=("$@")

    # Search for the exact key
    local entry
    entry=$(awk -F: -v k="$target_key" '$1 == k {print $0; exit}' "$STORE_FILE")

    if [[ -z "$entry" ]]; then
        echo "Key '$target_key' not found."
        return
    fi

    # Extract value safely
    local value="${entry#*:}"

    # If command provided, execute it with value
    if [[ ${#command[@]} -gt 0 ]]; then
        # print command with value
        echo "${command[@]} $value"
        # execute command with value
        "${command[@]}" "$value"
        return
    fi

    # Default action based on type
    if [[ -d "$value" ]]; then
        # change directory
        cd "$value" || return
    else
        # print string
        echo "$value"
    fi
}

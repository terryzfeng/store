# For production
STORE_FILE="${STORE_DB_PATH:-$HOME/.store_db}"

# For local shell testing, you can export a custom STORE_DB_PATH
# export STORE_DB_PATH="./local_store_db.txt"

function _key_regex() {
    [[ $1 =~ ^[a-zA-Z0-9_-]+$ ]] && return 0
    return 1
}

function _value_regex() {
    [[ "$1" != *$'\n'* ]] && return 0
    return 1
}

# STORE: Store a key-value pair, with value being a string, directory, or file path.
# Usage: store <key> <value>
function store() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Usage: store <key> <value>"
        echo ""
        echo "Store a key-value pair, with value being a string, directory, or file path."
        echo ""
        echo "Examples:"
        echo "  store greet \"hello world\""
        echo "  store docs ~/Documents"
        echo "  store readme ./README.md"
        return 0
    fi

    if [[ $# -lt 2 ]]; then
        echo "Usage: store <key> <value>"
        return 1
    fi
    
    local key="$1"
    shift
    local value="$*"
    
    # Validate key
    if [[ -z "$key" ]]; then
        echo "Invalid key: key cannot be empty"
        return 1
    fi
    
    if ! _key_regex "$key"; then
        echo "Invalid key: only letters, numbers, '-', and '_' are allowed"
        return 1
    fi
    
    # Validate value
    if ! _value_regex "$value"; then
        echo "Invalid value: newlines are not allowed"
        return 1
    fi
    
    mkdir -p "$(dirname "$STORE_FILE")"

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

# UNSTORE: Remove a stored key.
# Usage: unstore <key>
function unstore() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Usage: unstore <key>"
        echo ""
        echo "Remove a stored key."
        echo ""
        echo "Examples:"
        echo "  unstore greet"
        return 0
    fi

    if [[ $# -lt 1 ]]; then
        echo "Usage: unstore <key>"
        return 1
    fi

    local key="$1"
    
    if [[ -f "$STORE_FILE" ]]; then
        # Check if key exists first to give feedback
        if grep -q "^${key}:" "$STORE_FILE"; then
            awk -F: -v k="$key" '$1 != k' "$STORE_FILE" > "${STORE_FILE}.tmp"
            mv "${STORE_FILE}.tmp" "$STORE_FILE"
            echo "Removed '$key'"
        else
            echo "Key '$key' not found."
        fi
    else
        echo "Store is empty."
    fi
}

# STORED: Lists all keys and values.
# Usage: stored
function stored() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Usage: stored"
        echo ""
        echo "Lists all keys and values."
        echo ""
        echo "Examples:"
        echo "  stored"
        return 0
    fi

    if [[ ! -f "$STORE_FILE" ]]; then
        echo "Store is empty."
        return
    fi

    sed "s/:/$(printf '\t')/" "$STORE_FILE" | column -s "$(printf '\t')" -t
}

# RESTORE: Restore a value by key. Print the value by default.
# If a command is provided, run `command value`.
# If command contains {}, replace all instances of {} with the value
# Usage: restore <key> [command]
function restore() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Usage: restore <key> [command]"
        echo ""
        echo "Restore a value by key. Print the value by default."
        echo "If a command is provided, run `command value`."
        echo "If command contains {}, replace all instances of {} with the value."
        echo ""
        echo "Examples:"
        echo "  restore greet -> \"hello world\""
        echo "  restore docs cd -> cd ~/Documents"
        echo "  restore readme vim -> vim README.md"
        echo "  restore greet echo \"Greeting: {}\" -> Greeting: hello world"
        return 0
    fi

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

    # If command is provided, securely evaluate it with the value
    if [[ ${#command[@]} -gt 0 ]]; then
        local new_command=()
        local has_template=false

        for arg in "${command[@]}"; do
            if [[ "$arg" == *"{}"* ]]; then
                new_command+=("${arg//\{\}/$value}")
                has_template=true
            else
                new_command+=("$arg")
            fi
        done

        # If no template was found, append the value at the end
        if [[ "$has_template" == false ]]; then
            new_command+=("$value")
        fi

        # Echo the executed command explicitly for transparency
        echo "+ ${new_command[*]}" >&2
        
        # Execute securely keeping arg boundaries intact
        "${new_command[@]}"
        return
    fi

    # Default action based on type
    echo "$value"
}

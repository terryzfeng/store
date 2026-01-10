#!/bin/bash

# Configuration
TEST_DB="test_store_db.txt"
export STORE_DB_PATH="$TEST_DB"
SCRIPT="./store.sh"

# Setup
rm -f "$TEST_DB"
source "$SCRIPT"

# Helpers
function assert_eq() {
    local expected="$1"
    local actual="$2"
    local msg="$3"
    if [[ "$actual" == "$expected" ]]; then
        echo "✅  PASS: $msg"
    else
        echo "❌  FAIL: $msg"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        return 1
    fi
}

function assert_contains() {
    local haystack="$1"
    local needle="$2"
    local msg="$3"
    if [[ "$haystack" == *"$needle"* ]]; then
        echo "✅  PASS: $msg"
    else
        echo "❌  FAIL: $msg"
        echo "  String '$needle' not found in output"
        return 1
    fi
}

echo "--- Running Tests ---"

# Test 1: Basic Store and Restore
echo "Test 1: Basic Store/Restore"
store greet "hello world"
val=$(restore greet)
assert_eq "hello world" "$val" "Stored value 'hello world' retrieved correctly"

# Test 2: Overwrite
echo "Test 2: Overwrite"
store greet "hi there"
val=$(restore greet)
assert_eq "hi there" "$val" "Value overwritten correctly"

# Test 3: Command Execution (Simple)
echo "Test 3: Command Execution (Simple)"
out=$(restore greet echo)
assert_contains "$out" "hi there" "Command executed and printed value"

# Test 4: Command Execution (Multi-word)
echo "Test 4: Command Execution (Multi-word)"
out=$(restore greet printf "Value:%s\n")
assert_contains "$out" "Value:hi there" "Multi-word command executed correctly"

# Test 5: Stored list
echo "Test 5: Stored list"
out=$(stored)
assert_contains "$out" "greet" "stored command lists key"

# Cleanup
rm -f "$TEST_DB"
echo "--- Tests Complete ---"

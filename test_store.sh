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

function assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local msg="$3"
    if [[ "$haystack" != *"$needle"* ]]; then
        echo "✅  PASS: $msg"
    else
        echo "❌  FAIL: $msg"
        echo "  String '$needle' WAS found in output"
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
# This is expected to fail with the current code if arguments aren't handled right
echo "Test 4: Command Execution (Multi-word)"
# We'll use printf to format it, expecting the value to be the second arg
out=$(restore greet printf "Value:%s\n")
assert_contains "$out" "Value:hi there" "Multi-word command executed correctly"

# Test 5: Stored list
echo "Test 5: Stored list"
out=$(stored)
assert_contains "$out" "greet" "stored command lists key"

# Test 6: Unstore
echo "Test 6: Unstore"
unstore greet
out=$(stored)
assert_not_contains "$out" "greet" "Key 'greet' removed from stored list"
val=$(restore greet)
assert_contains "$val" "not found" "Restoring removed key says not found"

# Test 7: Sanitization
echo "Test 7: Sanitization"
store "hi:hi" "colon_val"
val=$(restore hihi)
assert_eq "colon_val" "$val" "Key with colon sanitized correctly"
store " my key " "space_val"
val=$(restore mykey)
assert_eq "space_val" "$val" "Key with spaces sanitized correctly"

# Test 8: Column Display (Colons in value)
echo "Test 8: Column Display (Colons in value)"
store my_url "https://google.com"
out=$(stored)
assert_contains "$out" "https://google.com" "URL preserved in stored output"

# Cleanup
rm -f "$TEST_DB"
echo "--- Tests Complete ---"

#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

check_output() {
    local actual_output="$1"
    local expected_output="$2"
    
    # Compare the actual output with the expected output
    if [[ "$actual_output" == "$expected_output" ]]; then
        echo -e "${GREEN}Passed${NC}"
    else
        echo -e "${RED}Failed!${NC}"
        echo "Expected:"
        echo "$expected_output"
        echo "Actual:"
        echo "$actual_output"
    fi
}

# Sample command for testing: a dummy 'echo' command
dummy_command() {
    echo "$@"
}

# Test variables
test_file="testfile.txt"
error_file="nonexistentfile.txt"

# Clean up test files (if they exist)
rm -f "$test_file"

# Test 1: Executing with a valid file
echo -e "line1
line2
line3" > "$test_file"
echo "Test 1: Executing with valid file and dummy_command"
# Expect to see "line1", "line2", "line3"
actual_output="$(exec_on_lines dummy_command "$test_file")"
expected_output="""line1
line2
line3"""
check_output "$actual_output" "$expected_output"


# Test 2: Non-existent file
echo "Test 2: Executing with non-existent file"
# Expect to see "Error: File not found..."
actual_output="$(exec_on_lines dummy_command "$error_file")"
expected_output="""Error: File not found at 'nonexistentfile.txt'"""
check_output "$actual_output" "$expected_output"


# Test 3: Empty file
echo "Test 3: Executing with an empty file"
> "$test_file"  # Create an empty file
# Expect no output
actual_output="$(exec_on_lines dummy_command "$test_file")"
expected_output=""
check_output "$actual_output" "$expected_output"


# Test 4: Using additional parameters
echo -e "line1
line2" > "$test_file"
echo "Test 4: Executing with additional parameters"
# Expect to see "-flag line1", "-flag line2"
actual_output="$(exec_on_lines dummy_command -flag "$test_file")"
expected_output="""-flag line1
-flag line2"""
check_output "$actual_output" "$expected_output"

# Test 5: Handling arguments count
echo "Test 5: Executing with additional arguments only"
# Expect to see "argA argB line1", "argA argB line2"
actual_output="$(exec_on_lines dummy_command argA argB "$test_file")"
expected_output="""argA argB line1
argA argB line2"""
check_output "$actual_output" "$expected_output"


# Test 6: No variable substitution from file
echo "Test 6: No variable substitution from file"
echo "\$(seq 1 5)" > "$test_file"
actual_output="$(exec_on_lines echo "$test_file")"
expected_output="""\$(seq 1 5)"""
check_output "$actual_output" "$expected_output"

# Clean up test files
rm -f "$test_file"
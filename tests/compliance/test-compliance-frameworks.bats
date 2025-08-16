#!/usr/bin/env bats

setup() {
    export TEST_REPOS_DIR="/tmp/git-security-audit-test-repos"
    export SCRIPT_PATH="$BATS_TEST_DIRNAME/../../src/git-security-audit.sh"
    ./tests/fixtures/create-test-repositories.sh medium
}

teardown() {
    rm -rf "$TEST_REPOS_DIR"
}

@test "should detect PCI violations" {
    cd "$TEST_REPOS_DIR/medium-repo"
    
    run "$SCRIPT_PATH" --compliance pci --output json
    [ "$status" -eq 0 ]
    
    # Should find credit card numbers
    [[ "$output" =~ "pci" ]] || [[ "$output" =~ "credit" ]]
}

@test "should detect HIPAA violations" {
    cd "$TEST_REPOS_DIR/medium-repo"
    
    run "$SCRIPT_PATH" --compliance hipaa --output json
    [ "$status" -eq 0 ]
    
    # Should find SSN or medical data
    [[ "$output" =~ "hipaa" ]] || [[ "$output" =~ "ssn" ]]
}

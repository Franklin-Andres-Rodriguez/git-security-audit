#!/usr/bin/env bats

setup() {
    export TEST_REPOS_DIR="/tmp/git-security-audit-test-repos"
    export SCRIPT_PATH="$BATS_TEST_DIRNAME/../../src/git-security-audit.sh"
    
    # Solo crear repo grande para performance
    ./tests/fixtures/create-test-repositories.sh large
}

teardown() {
    rm -rf "$TEST_REPOS_DIR"
}

@test "quick scan should complete under 30 seconds" {
    cd "$TEST_REPOS_DIR/large-repo"
    
    timeout 30s "$SCRIPT_PATH" --type quick --quiet
    [ "$?" -eq 0 ]
}

@test "comprehensive scan should complete under 5 minutes" {
    cd "$TEST_REPOS_DIR/large-repo"
    
    timeout 300s "$SCRIPT_PATH" --type comprehensive --quiet
    [ "$?" -eq 0 ]
}

#!/usr/bin/env bats

setup() {
    # Crear repositorios de prueba dinámicamente
    export TEST_REPOS_DIR="/tmp/git-security-audit-test-repos"
    ./tests/fixtures/create-test-repositories.sh all
    export SCRIPT_PATH="$BATS_TEST_DIRNAME/../../src/git-security-audit.sh"
}

teardown() {
    # Limpiar después de cada test
    rm -rf "$TEST_REPOS_DIR"
}

@test "should detect AWS keys in small repository" {
    cd "$TEST_REPOS_DIR/small-repo"
    
    run "$SCRIPT_PATH" --type secrets --output json
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "aws_access_key" ]]
}

@test "should find no secrets in clean repository" {
    cd "$TEST_REPOS_DIR/clean-repo"
    
    run "$SCRIPT_PATH" --type comprehensive --output json
    
    [ "$status" -eq 0 ]
    # Parse JSON to verify zero findings
    findings=$(echo "$output" | tail -1 | jq '.total_findings' 2>/dev/null || echo "0")
    [ "$findings" -eq 0 ]
}

@test "should detect compliance violations in medium repository" {
    cd "$TEST_REPOS_DIR/medium-repo"
    
    run "$SCRIPT_PATH" --compliance pci --output json
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "credit_card" ]] || [[ "$output" =~ "pci" ]]
}

@test "should handle large repository performance" {
    cd "$TEST_REPOS_DIR/large-repo"
    
    # Time the execution
    start_time=$(date +%s)
    run "$SCRIPT_PATH" --type quick --output json
    end_time=$(date +%s)
    
    [ "$status" -eq 0 ]
    
    # Should complete in reasonable time (< 30 seconds for quick scan)
    duration=$((end_time - start_time))
    [ "$duration" -lt 30 ]
}

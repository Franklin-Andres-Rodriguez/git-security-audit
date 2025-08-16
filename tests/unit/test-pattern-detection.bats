#!/usr/bin/env bats

setup() {
    export SCRIPT_PATH="$BATS_TEST_DIRNAME/../../src/git-security-audit.sh"
}

@test "should show help message" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Git Security Audit Framework" ]]
}

@test "should show version" {
    run "$SCRIPT_PATH" --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "2.0.0" ]]
}

@test "should list builtin patterns" {
    run "$SCRIPT_PATH" --list-patterns
    [ "$status" -eq 0 ]
    [[ "$output" =~ "aws_access_key" ]]
    [[ "$output" =~ "github_token" ]]
    [[ "$output" =~ "jwt_token" ]]
}

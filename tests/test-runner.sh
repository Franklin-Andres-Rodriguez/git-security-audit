#!/bin/bash

# Modern Test Runner for Git Security Audit Framework
# Purpose: Execute comprehensive test suites with proper reporting
# Author: Git Security Audit Framework
# Usage: ./test-runner.sh [test-type] [options]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Test configuration
TEST_DIR="$(dirname "$0")"
PROJECT_ROOT="$(dirname "$TEST_DIR")"
SCRIPT_PATH="$PROJECT_ROOT/src/git-security-audit.sh"
REPORTS_DIR="$TEST_DIR/reports"
COVERAGE_DIR="$TEST_DIR/coverage"

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

log_header() {
    echo -e "${BOLD}${PURPLE}🧪 $1${NC}"
    echo -e "${PURPLE}$(printf '=%.0s' {1..50})${NC}"
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    command -v bats >/dev/null 2>&1 || missing_deps+=("bats-core")
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        echo ""
        echo "Install with:"
        echo "  # Ubuntu/Debian:"
        echo "  sudo apt-get install bats jq"
        echo ""
        echo "  # macOS:"
        echo "  brew install bats-core jq"
        exit 1
    fi
}

# Setup test environment
setup_test_environment() {
    log_info "Setting up test environment..."
    
    # Ensure script is executable
    chmod +x "$SCRIPT_PATH"
    
    # Create reports directories
    mkdir -p "$REPORTS_DIR" "$COVERAGE_DIR"
    
    # Verify script basic functionality
    if ! "$SCRIPT_PATH" --version >/dev/null 2>&1; then
        log_error "Script fails basic functionality test"
        exit 1
    fi
    
    log_success "Test environment ready"
}

# Run specific test suite
run_test_suite() {
    local test_type="$1"
    local test_files=()
    local suite_name=""
    
    case "$test_type" in
        "unit")
            test_files=("$TEST_DIR/unit/"*.bats)
            suite_name="Unit Tests"
            ;;
        "integration")
            test_files=("$TEST_DIR/integration/"*.bats)
            suite_name="Integration Tests"
            ;;
        "performance")
            test_files=("$TEST_DIR/performance/"*.bats)
            suite_name="Performance Tests"
            ;;
        "compliance")
            test_files=("$TEST_DIR/compliance/"*.bats)
            suite_name="Compliance Tests"
            ;;
        "pattern-detection")
            test_files=("$TEST_DIR/pattern-detection/"*.bats)
            suite_name="Pattern Detection Tests"
            ;;
        "quick")
            test_files=("$TEST_DIR/unit/"*.bats)
            suite_name="Quick Test Suite"
            ;;
        "all")
            test_files=("$TEST_DIR"/**/*.bats)
            suite_name="Complete Test Suite"
            ;;
        *)
            log_error "Unknown test type: $test_type"
            echo "Available types: unit, integration, performance, compliance, pattern-detection, quick, all"
            exit 1
            ;;
    esac
    
    if [[ ${#test_files[@]} -eq 0 ]]; then
        log_warning "No test files found for: $test_type"
        return 0
    fi
    
    log_header "$suite_name"
    
    local start_time=$(date +%s)
    local exit_code=0
    
    # Run BATS with proper reporting
    if bats --formatter tap "${test_files[@]}" > "$REPORTS_DIR/${test_type}-results.tap" 2>&1; then
        log_success "$suite_name completed successfully"
    else
        exit_code=$?
        log_error "$suite_name failed"
        
        # Show failed test details
        echo ""
        echo "Failed test details:"
        tail -20 "$REPORTS_DIR/${test_type}-results.tap"
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "Duration: ${duration}s"
    echo ""
    
    return $exit_code
}

# Generate test report
generate_report() {
    local overall_status="$1"
    
    log_header "Test Report Summary"
    
    echo "Timestamp: $(date)"
    echo "Project: Git Security Audit Framework"
    echo "Script Version: $("$SCRIPT_PATH" --version 2>/dev/null || echo "unknown")"
    echo ""
    
    if [[ -d "$REPORTS_DIR" ]]; then
        echo "Test Results:"
        for report in "$REPORTS_DIR"/*.tap; do
            if [[ -f "$report" ]]; then
                local test_name=$(basename "$report" .tap)
                local passed=$(grep -c "^ok" "$report" 2>/dev/null || echo "0")
                local failed=$(grep -c "^not ok" "$report" 2>/dev/null || echo "0")
                local total=$((passed + failed))
                
                if [[ $total -gt 0 ]]; then
                    printf "  %-20s: %2d/%2d passed" "$test_name" "$passed" "$total"
                    [[ $failed -gt 0 ]] && echo -e " ${RED}($failed failed)${NC}" || echo -e " ${GREEN}✓${NC}"
                fi
            fi
        done
    fi
    
    echo ""
    echo "Reports available in: $REPORTS_DIR"
    
    if [[ $overall_status -eq 0 ]]; then
        log_success "All tests passed! 🎉"
    else
        log_error "Some tests failed. Check reports for details."
    fi
}

# Main execution
main() {
    local test_type="${1:-quick}"
    local verbose=false
    
    # Parse additional arguments
    shift || true
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                verbose=true
                shift
                ;;
            --help)
                echo "Usage: $0 [test-type] [options]"
                echo ""
                echo "Test Types:"
                echo "  unit           - Unit tests for individual functions"
                echo "  integration    - Integration tests with test repositories"
                echo "  performance    - Performance and scalability tests"
                echo "  compliance     - Compliance framework tests"
                echo "  pattern-detection - Secret pattern detection tests"
                echo "  quick          - Fast subset of tests (default)"
                echo "  all            - Complete test suite"
                echo ""
                echo "Options:"
                echo "  -v, --verbose  - Verbose output"
                echo "  --help         - Show this help"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    echo -e "${BOLD}${BLUE}Git Security Audit Framework - Test Runner${NC}"
    echo -e "${BLUE}=============================================${NC}"
    echo ""
    
    check_dependencies
    setup_test_environment
    
    local overall_exit_code=0
    
    if [[ "$test_type" == "all" ]]; then
        # Run all test suites
        for suite in unit integration performance compliance; do
            if ! run_test_suite "$suite"; then
                overall_exit_code=1
            fi
        done
    else
        # Run specific test suite
        if ! run_test_suite "$test_type"; then
            overall_exit_code=1
        fi
    fi
    
    generate_report $overall_exit_code
    
    exit $overall_exit_code
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

#!/bin/bash

# Git Security Audit Framework - Generalized
# Purpose: Comprehensive security scanning and secret detection across projects
# Author: DevSecOps Framework v2.0
# Usage: ./git-security-audit.sh [options]

set -euo pipefail

# Script metadata
SCRIPT_NAME="Git Security Audit Framework"
VERSION="2.0.0"
CREATED_DATE=$(date +%Y-%m-%d)

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Default configuration
AUDIT_DIR="security-audit/scan-$(date +%Y%m%d-%H%M%S)"
SCAN_TYPE="comprehensive"
OUTPUT_FORMAT="text"
TARGET_SECRET=""
CUSTOM_PATTERNS_FILE=""
BRANCH_SCOPE="all"
DEPTH_LIMIT=""
EXCLUDE_PATTERNS="node_modules|\.git|build|dist|vendor"
ENABLE_ENTROPY_ANALYSIS=false
COMPLIANCE_MODE=""
VERBOSITY="normal"

# Predefined secret patterns with descriptions
declare -A SECRET_PATTERNS=(
    # API Keys and Tokens
    ["generic_api_keys"]="[A-Za-z0-9_-]{20,50}"
    ["aws_access_key"]="AKIA[0-9A-Z]{16}"
    ["aws_secret_key"]="[A-Za-z0-9/+=]{40}"
    ["github_token"]="ghp_[A-Za-z0-9]{36}"
    ["github_oauth"]="gho_[A-Za-z0-9]{36}"
    ["gitlab_token"]="glpat-[A-Za-z0-9_-]{20}"
    ["azure_storage"]="DefaultEndpointsProtocol=https;AccountName=[^;]+;AccountKey=[A-Za-z0-9+/=]+=="
    ["google_api"]="AIza[0-9A-Za-z_-]{35}"
    ["slack_token"]="xox[baprs]-[0-9]+-[0-9A-Za-z]+"
    ["discord_bot"]="[MN][A-Za-z\d]{23}\.[\w-]{6}\.[\w-]{27}"
    
    # JWT and Authentication
    ["jwt_token"]="eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+"
    ["bearer_token"]="Bearer [A-Za-z0-9_-]+"
    ["basic_auth"]="Basic [A-Za-z0-9+/=]+"
    
    # Database and Services
    ["mysql_connection"]="mysql://[^:]+:[^@]+@[^/]+/[^?]+"
    ["postgres_connection"]="postgres://[^:]+:[^@]+@[^/]+/[^?]+"
    ["mongodb_connection"]="mongodb://[^:]+:[^@]+@[^/]+/[^?]+"
    ["redis_url"]="redis://[^:]*:[^@]*@[^:]+:[0-9]+/[0-9]+"
    
    # Cloud and Infrastructure
    ["docker_auth"]="[\"']auths[\"']:\s*{[^}]*[\"']auth[\"']:\s*[\"'][A-Za-z0-9+/=]+[\"']"
    ["ssh_private_key"]="-----BEGIN [A-Z ]+PRIVATE KEY-----"
    ["pgp_private_key"]="-----BEGIN PGP PRIVATE KEY BLOCK-----"
    ["ssl_private_key"]="-----BEGIN PRIVATE KEY-----"
    
    # High entropy strings (potential secrets)
    ["high_entropy"]="[A-Za-z0-9+/]{32,}"
    
    # Common password patterns
    ["password_assignment"]="password[\"'\\s]*[:=][\"'\\s]*[^\"'\\s]+"
    ["secret_assignment"]="secret[\"'\\s]*[:=][\"'\\s]*[^\"'\\s]+"
    ["key_assignment"]="(?:api_?key|access_?key)[\"'\\s]*[:=][\"'\\s]*[^\"'\\s]+"
)

# Sensitive file patterns
SENSITIVE_FILE_PATTERNS=(
    "*.env*"
    "*.pem"
    "*.key"
    "*.p12"
    "*.pfx" 
    "*secret*"
    "*password*"
    "*credential*"
    "*config*"
    "id_rsa*"
    "id_dsa*"
    "id_ecdsa*"
    "id_ed25519*"
    "*.ppk"
    "*.keystore"
    "*.jks"
    "*.crt"
    "*.cer"
    "*.der"
    "shadow"
    "passwd"
    ".htpasswd"
    ".netrc"
    "terraform.tfstate*"
    "vault.yml"
    "secrets.yml"
    "docker-compose.override.yml"
)

# Compliance frameworks
declare -A COMPLIANCE_PATTERNS=(
    ["pci"]="credit_?card|cvv|pan|[0-9]{4}[-\\s]?[0-9]{4}[-\\s]?[0-9]{4}[-\\s]?[0-9]{4}"
    ["hipaa"]="ssn|social.security|patient|medical|hipaa|phi"
    ["gdpr"]="gdpr|personal.data|data.subject|consent|privacy.policy"
    ["sox"]="financial|sox|sarbanes|audit.trail|material.weakness"
    ["iso27001"]="information.security|risk.assessment|security.incident|vulnerability"
)

show_usage() {
    cat << EOF
${BOLD}${BLUE}$SCRIPT_NAME v$VERSION${NC}

${BOLD}USAGE:${NC}
    $(basename "$0") [OPTIONS]

${BOLD}OPTIONS:${NC}
    ${YELLOW}Basic Scanning:${NC}
    -s, --secret VALUE          Search for specific secret value
    -p, --patterns FILE         Load custom patterns from file
    -t, --type TYPE            Scan type: quick|comprehensive|secrets|files|compliance
    -o, --output FORMAT        Output format: text|json|csv|html
    
    ${YELLOW}Scope Control:${NC}
    -b, --branches SCOPE       Branch scope: all|current|main|pattern
    -d, --depth NUMBER         Limit git history depth
    -e, --exclude PATTERNS     Exclude file patterns (comma-separated)
    
    ${YELLOW}Advanced Options:${NC}
    --entropy                  Enable entropy analysis for unknown secrets
    --compliance MODE          Run compliance checks: pci|hipaa|gdpr|sox|iso27001
    -v, --verbose              Increase verbosity
    --quiet                    Suppress non-critical output
    
    ${YELLOW}Help & Information:${NC}
    -h, --help                 Show this help message
    --list-patterns            List all built-in secret patterns
    --version                  Show version information

${BOLD}EXAMPLES:${NC}
    ${GREEN}# Quick security scan${NC}
    $(basename "$0") --type quick
    
    ${GREEN}# Search for specific API key${NC}
    $(basename "$0") --secret "your-api-key-here"
    
    ${GREEN}# Comprehensive scan with entropy analysis${NC}
    $(basename "$0") --type comprehensive --entropy
    
    ${GREEN}# PCI compliance check${NC}
    $(basename "$0") --compliance pci --output json
    
    ${GREEN}# Scan only main branches${NC}
    $(basename "$0") --branches main --type secrets

${BOLD}SCAN TYPES:${NC}
    ${CYAN}quick${NC}        - Fast scan for common secrets and sensitive files
    ${CYAN}comprehensive${NC} - Full repository analysis with all patterns
    ${CYAN}secrets${NC}      - Focus only on secret detection
    ${CYAN}files${NC}        - Analyze sensitive file patterns
    ${CYAN}compliance${NC}   - Run compliance-specific checks

EOF
}

show_patterns() {
    echo -e "${BOLD}${BLUE}Built-in Secret Patterns:${NC}\n"
    
    for pattern_name in "${!SECRET_PATTERNS[@]}"; do
        pattern="${SECRET_PATTERNS[$pattern_name]}"
        echo -e "${YELLOW}$pattern_name${NC}: ${CYAN}$pattern${NC}"
    done
    
    echo -e "\n${BOLD}${BLUE}Sensitive File Patterns:${NC}\n"
    printf '%s\n' "${SENSITIVE_FILE_PATTERNS[@]}" | sort
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--secret)
                TARGET_SECRET="$2"
                shift 2
                ;;
            -p|--patterns)
                CUSTOM_PATTERNS_FILE="$2"
                shift 2
                ;;
            -t|--type)
                SCAN_TYPE="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            -b|--branches)
                BRANCH_SCOPE="$2"
                shift 2
                ;;
            -d|--depth)
                DEPTH_LIMIT="$2"
                shift 2
                ;;
            -e|--exclude)
                EXCLUDE_PATTERNS="$2"
                shift 2
                ;;
            --entropy)
                ENABLE_ENTROPY_ANALYSIS=true
                shift
                ;;
            --compliance)
                COMPLIANCE_MODE="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSITY="verbose"
                shift
                ;;
            --quiet)
                VERBOSITY="quiet"
                shift
                ;;
            --list-patterns)
                show_patterns
                exit 0
                ;;
            --version)
                echo "$SCRIPT_NAME v$VERSION"
                exit 0
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo -e "${RED}Error: Unknown option $1${NC}" >&2
                show_usage
                exit 1
                ;;
        esac
    done
}

# Logging functions
log_info() {
    [[ $VERBOSITY != "quiet" ]] && echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    [[ $VERBOSITY != "quiet" ]] && echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

log_verbose() {
    [[ $VERBOSITY == "verbose" ]] && echo -e "${CYAN}🔍 $1${NC}"
}

# Initialize audit environment
initialize_audit() {
    log_info "Initializing security audit environment..."
    
    # Create audit directory structure
    mkdir -p "$AUDIT_DIR"/{findings,reports,metrics,raw-data}
    
    # Create audit metadata
    cat > "$AUDIT_DIR/audit-metadata.json" << EOF
{
    "audit_id": "$(uuidgen 2>/dev/null || date +%s)",
    "script_version": "$VERSION",
    "scan_type": "$SCAN_TYPE",
    "target_secret": "$([[ -n "$TARGET_SECRET" ]] && echo "***REDACTED***" || echo "none")",
    "timestamp": "$(date -Iseconds)",
    "repository_path": "$(pwd)",
    "git_repository": "$(git remote get-url origin 2>/dev/null || echo "local")",
    "git_branch": "$(git branch --show-current 2>/dev/null || echo "unknown")",
    "git_commit": "$(git rev-parse HEAD 2>/dev/null || echo "unknown")",
    "scan_parameters": {
        "branch_scope": "$BRANCH_SCOPE",
        "depth_limit": "$DEPTH_LIMIT",
        "exclude_patterns": "$EXCLUDE_PATTERNS",
        "entropy_analysis": $ENABLE_ENTROPY_ANALYSIS,
        "compliance_mode": "$COMPLIANCE_MODE",
        "verbosity": "$VERBOSITY"
    }
}
EOF

    log_success "Audit environment initialized: $AUDIT_DIR"
}

# Repository analysis functions
analyze_repository_metrics() {
    log_info "Analyzing repository structure and metrics..."
    scan_common_patterns
    display_result

    local metrics_file="$AUDIT_DIR/metrics/repository-metrics.json"
    
    # Collect repository metrics with timeouts and limits
    local total_commits=$(timeout 15s git rev-list --all --count 2>/dev/null || echo "0")
    local total_branches=$(timeout 5s git branch -a 2>/dev/null | wc -l || echo "0")
    local repo_size=$(timeout 10s du -sh .git 2>/dev/null | cut -f1 || echo "unknown")
    local objects_info="metrics_disabled_for_performance"
    local total_files=$(timeout 20s find . -maxdepth 3 -type f | grep -Ev "$EXCLUDE_PATTERNS" | wc -l 2>/dev/null || echo "0")
    
    # Create metrics JSON
    cat > "$metrics_file" << METRICS_EOF
{
    "repository_metrics": {
        "total_commits": $total_commits,
        "total_branches": $total_branches,
        "repository_size": "$repo_size",
        "total_files": $total_files,
        "objects_info": "$objects_info",
        "scan_scope": {
            "branch_scope": "$BRANCH_SCOPE",
            "depth_limit": "$DEPTH_LIMIT",
            "excluded_patterns": "$EXCLUDE_PATTERNS"
        }
    }
}
METRICS_EOF

    log_verbose "Repository metrics: $total_commits commits, $total_branches branches, $total_files files"
    log_success "Repository metrics analysis completed"
}

scan_secret_patterns() {
    log_info "Scanning for secret patterns..."
    
    local findings_dir="$AUDIT_DIR/findings"
    local total_findings=0
    
    # Load custom patterns if provided
    if [[ -n "$CUSTOM_PATTERNS_FILE" && -f "$CUSTOM_PATTERNS_FILE" ]]; then
        log_info "Loading custom patterns from $CUSTOM_PATTERNS_FILE"
        source "$CUSTOM_PATTERNS_FILE"
    fi
    
    # Scan each pattern
    for pattern_name in "${!SECRET_PATTERNS[@]}"; do
        local pattern="${SECRET_PATTERNS[$pattern_name]}"
        local findings_file="$findings_dir/${pattern_name}-findings.txt"
        
        log_verbose "Scanning pattern: $pattern_name"
        
        # Build git log command with appropriate scope
        local git_cmd="git log --all -p"
        [[ -n "$DEPTH_LIMIT" ]] && git_cmd+=" --max-count=$DEPTH_LIMIT"
        
        # Search for pattern in git history
        if $git_cmd | grep -E "$pattern" > "$findings_file" 2>/dev/null; then
            local count=$(wc -l < "$findings_file")
            total_findings=$((total_findings + count))
            log_warning "Found $count potential secrets for pattern: $pattern_name"
        else
            rm -f "$findings_file"
        fi
    done
    
    # Specific secret search if provided
    if [[ -n "$TARGET_SECRET" ]]; then
        log_info "Searching for specific secret value..."
        local secret_findings="$findings_dir/target-secret-findings.txt"
        
        # Search in git history
        git log --all -p -S "$TARGET_SECRET" > "$secret_findings" 2>/dev/null || true
        
        if [[ -s "$secret_findings" ]]; then
            local count=$(grep -c "^commit" "$secret_findings" || echo "0")
            log_error "Target secret found in $count commits!"
            total_findings=$((total_findings + count))
        else
            rm -f "$secret_findings"
            log_success "Target secret not found in git history"
        fi
    fi
    
    echo "$total_findings" > "$AUDIT_DIR/metrics/total-secret-findings.txt"
}

# Sensitive file analysis
analyze_sensitive_files() {
    log_info "Analyzing sensitive file patterns..."
    
    local files_dir="$AUDIT_DIR/findings"
    local sensitive_files="$files_dir/sensitive-files-history.txt"
    
    # Find sensitive files in git history
    {
        for pattern in "${SENSITIVE_FILE_PATTERNS[@]}"; do
            git log --all --name-only | grep -i "$pattern" 2>/dev/null || true
        done
    } | sort | uniq > "$sensitive_files"
    
    local count=$(wc -l < "$sensitive_files" 2>/dev/null || echo "0")
    if [[ $count -gt 0 ]]; then
        log_warning "Found $count sensitive files in git history"
        
        # Analyze current presence
        local current_sensitive="$files_dir/current-sensitive-files.txt"
        > "$current_sensitive"
        
        while read -r file; do
            if [[ -f "$file" ]]; then
                echo "$file" >> "$current_sensitive"
            fi
        done < "$sensitive_files"
        
        local current_count=$(wc -l < "$current_sensitive" 2>/dev/null || echo "0")
        [[ $current_count -gt 0 ]] && log_warning "$current_count sensitive files exist in current working directory"
    else
        log_success "No sensitive files found in git history"
        rm -f "$sensitive_files"
    fi
}

# Entropy analysis for unknown secrets
perform_entropy_analysis() {
    [[ $ENABLE_ENTROPY_ANALYSIS != true ]] && return 0
    
    log_info "Performing entropy analysis for potential unknown secrets..."
    
    local entropy_findings="$AUDIT_DIR/findings/high-entropy-strings.txt"
    
    # Extract strings with high entropy (simplified approach)
    git log --all -p | grep -oE '[A-Za-z0-9+/=]{24,}' | while read -r string; do
        # Simple entropy check (character diversity)
        local unique_chars=$(echo "$string" | fold -w1 | sort | uniq | wc -l)
        local string_length=${#string}
        local entropy_ratio=$((unique_chars * 100 / string_length))
        
        # If entropy ratio > 60%, consider it high entropy
        if [[ $entropy_ratio -gt 60 && $string_length -gt 20 ]]; then
            echo "$string (entropy: ${entropy_ratio}%)" >> "$entropy_findings"
        fi
    done 2>/dev/null || true
    
    if [[ -f "$entropy_findings" ]]; then
        local count=$(wc -l < "$entropy_findings")
        [[ $count -gt 0 ]] && log_warning "Found $count high-entropy strings (potential secrets)"
    fi
}

# Compliance-specific checks
run_compliance_checks() {
    [[ -z "$COMPLIANCE_MODE" ]] && return 0
    
    log_info "Running compliance checks for: $COMPLIANCE_MODE"
    
    local compliance_findings="$AUDIT_DIR/findings/compliance-${COMPLIANCE_MODE}.txt"
    
    if [[ -n "${COMPLIANCE_PATTERNS[$COMPLIANCE_MODE]}" ]]; then
        local pattern="${COMPLIANCE_PATTERNS[$COMPLIANCE_MODE]}"
        
        git log --all -p | grep -iE "$pattern" > "$compliance_findings" 2>/dev/null || true
        
        if [[ -s "$compliance_findings" ]]; then
            local count=$(wc -l < "$compliance_findings")
            log_warning "Found $count potential $COMPLIANCE_MODE compliance issues"
        else
            log_success "No $COMPLIANCE_MODE compliance issues detected"
            rm -f "$compliance_findings"
        fi
    else
        log_error "Unknown compliance mode: $COMPLIANCE_MODE"
    fi
}

# Risk assessment
assess_security_risks() {
    log_info "Assessing security risks..."
    
    local risk_file="$AUDIT_DIR/reports/risk-assessment.txt"
    
    {
        echo "SECURITY RISK ASSESSMENT"
        echo "========================"
        echo "Generated: $(date)"
        echo ""
        
        # Repository exposure risk
        echo "Repository Exposure Risk:"
        if git remote -v 2>/dev/null | grep -qE "(github\.com|gitlab\.com|bitbucket\.org)"; then
            echo "❌ HIGH RISK: Repository hosted on public platform"
            git remote -v
        else
            echo "⚠️ MEDIUM RISK: Repository hosting unclear or private"
        fi
        echo ""
        
        # Secret findings summary
        local total_findings=$(cat "$AUDIT_DIR/metrics/total-secret-findings.txt" 2>/dev/null || echo "0")
        echo "Secret Detection Summary:"
        echo "Total potential secrets found: $total_findings"
        
        if [[ $total_findings -gt 0 ]]; then
            echo "❌ CRITICAL: Secrets detected in repository history"
        else
            echo "✅ GOOD: No obvious secrets detected"
        fi
        echo ""
        
        # File risk assessment
        local sensitive_files=$(wc -l < "$AUDIT_DIR/findings/sensitive-files-history.txt" 2>/dev/null || echo "0")
        echo "Sensitive Files:"
        echo "Sensitive files in history: $sensitive_files"
        
        if [[ $sensitive_files -gt 0 ]]; then
            echo "⚠️ WARNING: Sensitive files detected in history"
        else
            echo "✅ GOOD: No sensitive files detected"
        fi
        
    } > "$risk_file"
    
    log_success "Risk assessment completed"
}

# Generate comprehensive report
generate_report() {
    log_info "Generating security audit report..."
    
    local report_file="$AUDIT_DIR/reports/security-audit-report.txt"
    local json_report="$AUDIT_DIR/reports/security-audit-report.json"
    
    # Text report
    {
        echo -e "${BOLD}SECURITY AUDIT REPORT${NC}"
        echo "=================================================="
        echo "Audit ID: $(grep audit_id "$AUDIT_DIR/audit-metadata.json" | cut -d'"' -f4)"
        echo "Generated: $(date)"
        echo "Repository: $(git remote get-url origin 2>/dev/null || pwd)"
        echo "Branch: $(git branch --show-current 2>/dev/null || echo "unknown")"
        echo ""
        
        echo -e "${BOLD}SCAN CONFIGURATION${NC}"
        echo "Scan Type: $SCAN_TYPE"
        echo "Branch Scope: $BRANCH_SCOPE"
        echo "Entropy Analysis: $ENABLE_ENTROPY_ANALYSIS"
        echo "Compliance Mode: ${COMPLIANCE_MODE:-"none"}"
        echo ""
        
        echo -e "${BOLD}FINDINGS SUMMARY${NC}"
        local total_findings=$(cat "$AUDIT_DIR/metrics/total-secret-findings.txt" 2>/dev/null || echo "0")
        echo "Total Secret Findings: $total_findings"
        
        # List all finding files
        if ls "$AUDIT_DIR/findings/"*-findings.txt >/dev/null 2>&1; then
            echo ""
            echo "Detailed Findings:"
            for finding_file in "$AUDIT_DIR/findings/"*-findings.txt; do
                local filename=$(basename "$finding_file")
                local count=$(wc -l < "$finding_file")
                echo "  ${filename%%-findings.txt}: $count issues"
            done
        fi
        
        echo ""
        echo -e "${BOLD}RECOMMENDATIONS${NC}"
        if [[ $total_findings -gt 0 ]]; then
            echo "❌ IMMEDIATE ACTION REQUIRED:"
            echo "1. Review all identified secrets and revoke/rotate compromised credentials"
            echo "2. Implement git history rewriting to remove secrets permanently"
            echo "3. Add pre-commit hooks to prevent future secret commits"
            echo "4. Implement secret scanning in CI/CD pipeline"
        else
            echo "✅ SECURITY STATUS: GOOD"
            echo "1. Consider implementing preventive controls (pre-commit hooks)"
            echo "2. Schedule regular security audits"
            echo "3. Implement secret management solution"
        fi
        
        echo ""
        echo "Detailed audit data available in: $AUDIT_DIR"
        
    } > "$report_file"
    
    # JSON report for automation
    {
        echo "{"
        echo "  \"audit_metadata\": $(cat "$AUDIT_DIR/audit-metadata.json"),"
        echo "  \"repository_metrics\": $(cat "$AUDIT_DIR/metrics/repository-metrics.json" 2>/dev/null || echo "{}"),"
        echo "  \"total_findings\": $(cat "$AUDIT_DIR/metrics/total-secret-findings.txt" 2>/dev/null || echo "0"),"
        echo "  \"findings_files\": ["
        
        local first=true
        if ls "$AUDIT_DIR/findings/"*-findings.txt >/dev/null 2>&1; then
            for finding_file in "$AUDIT_DIR/findings/"*-findings.txt; do
                [[ $first == true ]] && first=false || echo ","
                local filename=$(basename "$finding_file")
                local count=$(wc -l < "$finding_file")
                echo -n "    {\"type\": \"${filename%%-findings.txt}\", \"count\": $count, \"file\": \"$finding_file\"}"
            done
        fi
        
        echo ""
        echo "  ]"
        echo "}"
    } > "$json_report"
    
    log_success "Reports generated: $report_file"
}

# Display results
display_results() {
    local total_findings=$(cat "$AUDIT_DIR/metrics/total-secret-findings.txt" 2>/dev/null || echo "0")
    
    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}                    SECURITY AUDIT COMPLETE                     ${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [[ $total_findings -gt 0 ]]; then
        echo -e "${RED}🚨 SECURITY ALERT: $total_findings potential secrets found!${NC}"
        echo ""
        echo -e "${YELLOW}📋 IMMEDIATE ACTIONS REQUIRED:${NC}"
        echo "1. Review findings in: $AUDIT_DIR/findings/"
        echo "2. Revoke and rotate any confirmed secrets"
        echo "3. Clean git history using git-filter-repo or BFG"
        echo "4. Implement preventive controls"
    else
        echo -e "${GREEN}✅ SECURITY STATUS: No obvious secrets detected${NC}"
        echo ""
        echo -e "${BLUE}📋 RECOMMENDED NEXT STEPS:${NC}"
        echo "1. Implement pre-commit secret scanning"
        echo "2. Add CI/CD security gates"
        echo "3. Schedule regular security audits"
    fi
    
    echo ""
    echo -e "${CYAN}📊 Detailed Results:${NC}"
    echo "   Audit Directory: $AUDIT_DIR"
    echo "   Text Report: $AUDIT_DIR/reports/security-audit-report.txt"
    echo "   JSON Report: $AUDIT_DIR/reports/security-audit-report.json"
    echo ""
}

# Main execution flow
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_error "Not a git repository. Please run this script from within a git repository."
        exit 1
    fi
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Display header
    echo -e "${BOLD}${PURPLE}$SCRIPT_NAME v$VERSION${NC}"
    echo -e "${BOLD}${PURPLE}Security audit for: $(pwd)${NC}"
    echo ""
    
    # Initialize audit environment
    initialize_audit
    
    # Run appropriate scan type
    case $SCAN_TYPE in
        "quick")
            log_info "Running quick security scan..."
            analyze_repository_metrics
            scan_secret_patterns
            analyze_sensitive_files
            ;;
        "comprehensive")
            log_info "Running comprehensive security audit..."
            analyze_repository_metrics
            scan_secret_patterns
            analyze_sensitive_files
            perform_entropy_analysis
            run_compliance_checks
            assess_security_risks
            ;;
        "secrets")
            log_info "Running focused secret detection..."
            scan_secret_patterns
            perform_entropy_analysis
            ;;
        "files")
            log_info "Running sensitive file analysis..."
            analyze_sensitive_files
            ;;
        "compliance")
            log_info "Running compliance checks..."
            run_compliance_checks
            ;;
        *)
            log_error "Invalid scan type: $SCAN_TYPE"
            exit 1
            ;;
    esac
    
    # Generate reports
    generate_report
    
    # Display results
    display_results
}

# Execute main function with all arguments
main "$@"

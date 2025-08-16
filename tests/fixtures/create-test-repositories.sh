#!/bin/bash

# Modern Test Repository Generator for Security Tool Testing
# Purpose: Create isolated test repositories with known secrets for validation
# Author: Git Security Audit Framework
# Usage: ./create-test-repositories.sh [test-type]

set -euo pipefail

FIXTURES_DIR="$(dirname "$0")"
TEST_REPOS_DIR="/tmp/git-security-audit-test-repos"
SCRIPT_DIR="$(dirname "$(dirname "$FIXTURES_DIR")")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Clean up any existing test repositories
cleanup_test_repos() {
    if [[ -d "$TEST_REPOS_DIR" ]]; then
        rm -rf "$TEST_REPOS_DIR"
        log_info "Cleaned up existing test repositories"
    fi
}

# Create base test repository structure
create_base_test_repo() {
    local repo_name="$1"
    local repo_path="$TEST_REPOS_DIR/$repo_name"
    
    mkdir -p "$repo_path"
    cd "$repo_path"
    
    # Initialize git repository
    git init --initial-branch=main
    git config user.name "Test User"
    git config user.email "test@git-security-audit.com"
    
    echo "$repo_path"
}

# Create small repository with basic secrets
create_small_test_repo() {
    log_info "Creating small test repository with basic secrets..."
    
    local repo_path=$(create_base_test_repo "small-repo")
    cd "$repo_path"
    
    # AWS secrets
    cat > aws-config.txt << 'EOF'
# AWS Configuration
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
region = us-west-2
EOF
    
    # GitHub token
    echo "GITHUB_TOKEN=ghp_1234567890abcdef1234567890abcdef123456" > .env
    
    # Database connection
    cat > database.yml << 'EOF'
production:
  adapter: postgresql
  host: db.example.com
  username: myuser
  password: mypassword123
  database: production_db
EOF
    
    # JWT token example
    echo "JWT_SECRET=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c" > jwt-config.js
    
    # Commit secrets
    git add .
    git commit -m "Initial commit with test secrets"
    
    # Additional commits for history testing
    echo "# Updated README" > README.md
    git add README.md
    git commit -m "Add README"
    
    echo "version=2.0.0" >> version.txt
    git add version.txt
    git commit -m "Update version"
    
    log_success "Small test repository created at: $repo_path"
    echo "$repo_path"
}

# Create medium repository with compliance violations
create_medium_test_repo() {
    log_info "Creating medium test repository with compliance violations..."
    
    local repo_path=$(create_base_test_repo "medium-repo")
    cd "$repo_path"
    
    # PCI DSS violations
    cat > payment-processing.py << 'EOF'
# Payment Processing Module
credit_card_number = "4532-1234-5678-9012"
cvv = "123"
expiry_date = "12/25"

def process_payment(pan, cvv, expiry):
    # Store PAN in logs (PCI violation)
    print(f"Processing payment for card: {pan}")
    return True
EOF
    
    # HIPAA violations
    cat > patient-data.sql << 'EOF'
-- Patient medical records
INSERT INTO patients (ssn, name, medical_condition) VALUES 
('123-45-6789', 'John Doe', 'Diabetes Type 2'),
('987-65-4321', 'Jane Smith', 'Hypertension');
EOF
    
    # High entropy strings (potential secrets)
    cat > config.json << 'EOF'
{
  "api_key": "sk_test_FAKE_STRIPE_KEY_FOR_TESTING_NOT_REAL",
  "encryption_key": "AES256:FAKE_ENCRYPTION_KEY_FOR_TESTING_NOT_REAL",
  "webhook_secret": "whsec_FAKE_WEBHOOK_SECRET_FOR_TESTING_NOT_REAL",
  "private_key": "-----BEGIN RSA PRIVATE KEY-----\nFAKE_PRIVATE_KEY_FOR_TESTING_NOT_REAL..."
}
EOF
    
    # Multiple commits for comprehensive history
    git add payment-processing.py
    git commit -m "Add payment processing module"
    
    git add patient-data.sql
    git commit -m "Add patient database schema"
    
    git add config.json
    git commit -m "Add application configuration"
    
    # Create branches for branch testing
    git checkout -b feature/new-payment-method
    echo "stripe_secret_key=sk_live_1234567890abcdef" > stripe-config.txt
    git add stripe-config.txt
    git commit -m "Add Stripe integration"
    
    git checkout -b hotfix/security-patch
    echo "# Security patch applied" >> SECURITY.md
    git add SECURITY.md
    git commit -m "Apply security patch"
    
    git checkout main
    
    log_success "Medium test repository created at: $repo_path"
    echo "$repo_path"
}

# Create large repository for performance testing
create_large_test_repo() {
    log_info "Creating large test repository for performance testing..."
    
    local repo_path=$(create_base_test_repo "large-repo")
    cd "$repo_path"
    
    # Create many files with scattered secrets
    for i in {1..50}; do
        mkdir -p "module_$i"
        
        # Some modules have secrets, others don't
        if (( i % 7 == 0 )); then
            echo "API_KEY_$i=secret_key_$(openssl rand -hex 16)" > "module_$i/config.env"
        fi
        
        if (( i % 11 == 0 )); then
            echo "password_$i=admin123" > "module_$i/database.conf"
        fi
        
        # Normal files
        echo "# Module $i documentation" > "module_$i/README.md"
        echo "export MODULE_$i=true" > "module_$i/init.sh"
        
        git add "module_$i/"
        git commit -m "Add module $i"
    done
    
    # Add some historical secret commits that were "fixed"
    echo "old_api_key=REMOVED_FOR_SECURITY" > legacy-config.txt
    git add legacy-config.txt
    git commit -m "Remove API key from legacy config"
    
    log_success "Large test repository created at: $repo_path"
    echo "$repo_path"
}

# Create repository with no secrets (clean baseline)
create_clean_test_repo() {
    log_info "Creating clean test repository (no secrets)..."
    
    local repo_path=$(create_base_test_repo "clean-repo")
    cd "$repo_path"
    
    # Only clean files
    cat > README.md << 'EOF'
# Clean Test Repository

This repository contains no secrets and should pass all security scans.

## Features
- No hardcoded credentials
- No sensitive data
- Clean git history
EOF
    
    cat > src/main.py << 'EOF'
#!/usr/bin/env python3
"""
Clean application with no secrets.
"""

import os
from typing import Dict, Any

def load_config() -> Dict[str, Any]:
    """Load configuration from environment variables."""
    return {
        'debug': os.getenv('DEBUG', 'false').lower() == 'true',
        'port': int(os.getenv('PORT', '8080')),
        'host': os.getenv('HOST', '0.0.0.0')
    }

if __name__ == '__main__':
    config = load_config()
    print(f"Starting application on {config['host']}:{config['port']}")
EOF
    
    mkdir -p src tests docs
    echo "# Tests" > tests/README.md
    echo "# Documentation" > docs/README.md
    
    git add .
    git commit -m "Initial clean repository setup"
    
    git add src/main.py
    git commit -m "Add main application"
    
    log_success "Clean test repository created at: $repo_path"
    echo "$repo_path"
}

# Export test repository paths for use in other scripts
create_repository_manifest() {
    local manifest_file="$TEST_REPOS_DIR/repositories.json"
    
    cat > "$manifest_file" << EOF
{
  "test_repositories": {
    "small": "$TEST_REPOS_DIR/small-repo",
    "medium": "$TEST_REPOS_DIR/medium-repo", 
    "large": "$TEST_REPOS_DIR/large-repo",
    "clean": "$TEST_REPOS_DIR/clean-repo"
  },
  "created_at": "$(date -Iseconds)",
  "script_version": "2.0.0"
}
EOF
    
    log_success "Repository manifest created: $manifest_file"
}

# Main execution
main() {
    local test_type="${1:-all}"
    
    echo "🧪 Creating test repositories for Git Security Audit Framework"
    echo "============================================================="
    
    cleanup_test_repos
    mkdir -p "$TEST_REPOS_DIR"
    
    case "$test_type" in
        "small")
            create_small_test_repo
            ;;
        "medium")
            create_medium_test_repo
            ;;
        "large")
            create_large_test_repo
            ;;
        "clean")
            create_clean_test_repo
            ;;
        "all")
            create_small_test_repo
            create_medium_test_repo
            create_large_test_repo
            create_clean_test_repo
            create_repository_manifest
            ;;
        *)
            echo "Usage: $0 [small|medium|large|clean|all]"
            exit 1
            ;;
    esac
    
    echo ""
    echo "✅ Test repositories ready for testing!"
    echo "📂 Location: $TEST_REPOS_DIR"
    
    if [[ "$test_type" == "all" ]]; then
        echo ""
        echo "📋 Available test repositories:"
        echo "  • small-repo: Basic secrets (AWS, GitHub, DB)"
        echo "  • medium-repo: Compliance violations (PCI, HIPAA)"  
        echo "  • large-repo: Performance testing (50+ modules)"
        echo "  • clean-repo: No secrets (baseline validation)"
        echo ""
        echo "🧪 Run tests with:"
        echo "  cd $TEST_REPOS_DIR/small-repo && $SCRIPT_DIR/src/git-security-audit.sh --type comprehensive"
    fi
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# tests/fixtures/secure-test-data-generator.sh
#!/bin/bash

# Professional Test Data Generator for Security Tools
# Generates realistic but obviously fake secrets that won't trigger scanners
# Best practices for 2024-2025 GitHub security compliance

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔧 Generating GitHub-safe test data for security tool...${NC}"

# Create secure test data directory
mkdir -p tests/fixtures/data
cd tests/fixtures/data

# ==============================================================================
# STRIPE TEST KEYS - Obviously fake but realistic format
# ==============================================================================
generate_fake_stripe_keys() {
    echo -e "${GREEN}Generating Stripe-like test keys...${NC}"
    
    # Publishable keys (safe format)
    echo "pk_test_FAKE_PUBLISHABLE_KEY_FOR_TESTING_NOT_REAL" > stripe-publishable-test.key
    echo "pk_live_FAKE_PUBLISHABLE_KEY_FOR_TESTING_NOT_REAL" > stripe-publishable-live.key
    
    # Secret keys (obviously fake format) 
    echo "sk_test_FAKE_SECRET_KEY_FOR_TESTING_NOT_REAL_12345" > stripe-secret-test.key
    echo "sk_live_FAKE_SECRET_KEY_FOR_TESTING_NOT_REAL_67890" > stripe-secret-live.key
    
    # Webhook secrets
    echo "whsec_FAKE_WEBHOOK_SECRET_FOR_TESTING_NOT_REAL_ABCDEF" > stripe-webhook.secret
}

# ==============================================================================
# AWS CREDENTIALS - Obviously fake but correct format
# ==============================================================================
generate_fake_aws_credentials() {
    echo -e "${GREEN}Generating AWS-like test credentials...${NC}"
    
    # Access keys
    echo "AKIAFAKEFORTESTINGNOTREAL123" > aws-access-key.txt
    echo "AIDAFAKEFORTESTINGNOTREAL456" > aws-access-key-user.txt
    
    # Secret keys (obviously fake)
    echo "wJalrXUtnFEMI/K7MDENG/bPxRfiCYFAKEFORTESTING" > aws-secret-key.txt
    
    # Session tokens
    echo "AQoDYXdzEJr..FAKE_SESSION_TOKEN_FOR_TESTING_NOT_REAL" > aws-session-token.txt
}

# ==============================================================================
# GITHUB TOKENS - Obviously fake but correct format
# ==============================================================================
generate_fake_github_tokens() {
    echo -e "${GREEN}Generating GitHub-like test tokens...${NC}"
    
    # Personal access tokens
    echo "ghp_FAKE_PERSONAL_ACCESS_TOKEN_FOR_TESTING_NOT_REAL" > github-pat.token
    echo "gho_FAKE_OAUTH_TOKEN_FOR_TESTING_NOT_REAL_ABCDEF123" > github-oauth.token
    echo "ghu_FAKE_USER_TOKEN_FOR_TESTING_NOT_REAL_123456789" > github-user.token
    echo "ghs_FAKE_SERVER_TOKEN_FOR_TESTING_NOT_REAL_FEDCBA" > github-server.token
    echo "ghr_FAKE_REFRESH_TOKEN_FOR_TESTING_NOT_REAL_987654" > github-refresh.token
}

# ==============================================================================
# DATABASE CONNECTION STRINGS - Safe test format
# ==============================================================================
generate_fake_database_strings() {
    echo -e "${GREEN}Generating database connection test strings...${NC}"
    
    # MySQL
    echo "mysql://testuser:FAKE_PASSWORD_FOR_TESTING@fake-host.example.com:3306/testdb" > mysql-connection.txt
    
    # PostgreSQL
    echo "postgresql://testuser:FAKE_PASSWORD_FOR_TESTING@fake-host.example.com:5432/testdb" > postgres-connection.txt
    
    # MongoDB
    echo "mongodb://testuser:FAKE_PASSWORD_FOR_TESTING@fake-host.example.com:27017/testdb" > mongodb-connection.txt
    
    # Redis
    echo "redis://:FAKE_PASSWORD_FOR_TESTING@fake-host.example.com:6379/0" > redis-connection.txt
}

# ==============================================================================
# JWT TOKENS - Obviously fake but realistic structure
# ==============================================================================
generate_fake_jwt_tokens() {
    echo -e "${GREEN}Generating JWT-like test tokens...${NC}"
    
    # Standard JWT structure but with fake content
    echo "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJGQUtFX1VTRVJfRk9SX1RFU1RJTkciLCJuYW1lIjoiVGVzdCBVc2VyIiwiaWF0IjoxNTE2MjM5MDIyfQ.FAKE_SIGNATURE_FOR_TESTING_NOT_REAL_JWT_TOKEN" > jwt-token.txt
    
    # Refresh token
    echo "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.FAKE_REFRESH_TOKEN_PAYLOAD_FOR_TESTING.FAKE_REFRESH_SIGNATURE_NOT_REAL" > jwt-refresh.txt
}

# ==============================================================================
# API KEYS - Various services with obvious fake patterns
# ==============================================================================
generate_fake_api_keys() {
    echo -e "${GREEN}Generating API key test data...${NC}"
    
    # Google API
    echo "AIzaFAKE_GOOGLE_API_KEY_FOR_TESTING_NOT_REAL_123456" > google-api.key
    
    # OpenAI API
    echo "sk-FAKE_OPENAI_API_KEY_FOR_TESTING_NOT_REAL_1234567890ABCDEF" > openai-api.key
    
    # Slack tokens
    echo "xoxb-FAKE-SLACK-BOT-TOKEN-FOR-TESTING-NOT-REAL" > slack-bot.token
    echo "xoxp-FAKE-SLACK-USER-TOKEN-FOR-TESTING-NOT-REAL" > slack-user.token
    
    # Discord bot token
    echo "FAKE_DISCORD_BOT_TOKEN_FOR_TESTING_NOT_REAL.X-FAKE.FAKE_SIGNATURE" > discord-bot.token
    
    # Twilio
    echo "ACfake123456789012345678901234567890" > twilio-sid.txt
    echo "fake_auth_token_for_testing_not_real_12345678901234567890" > twilio-auth.token
}

# ==============================================================================
# SSL/TLS CERTIFICATES - Fake but realistic structure
# ==============================================================================
generate_fake_certificates() {
    echo -e "${GREEN}Generating certificate test data...${NC}"
    
    cat > fake-private-key.pem << 'EOF'
-----BEGIN PRIVATE KEY-----
FAKE_PRIVATE_KEY_CONTENT_FOR_TESTING_NOT_REAL
THIS_IS_NOT_A_REAL_PRIVATE_KEY_JUST_FOR_TESTING
ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789012345678901234567890
-----END PRIVATE KEY-----
EOF

    cat > fake-certificate.crt << 'EOF'
-----BEGIN CERTIFICATE-----
FAKE_CERTIFICATE_CONTENT_FOR_TESTING_NOT_REAL
THIS_IS_NOT_A_REAL_CERTIFICATE_JUST_FOR_TESTING  
ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789012345678901234567890
-----END CERTIFICATE-----
EOF

    cat > fake-ca-bundle.pem << 'EOF'
-----BEGIN CERTIFICATE-----
FAKE_CA_CERTIFICATE_FOR_TESTING_NOT_REAL
THIS_IS_NOT_A_REAL_CA_CERTIFICATE_JUST_FOR_TESTING
ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789012345678901234567890
-----END CERTIFICATE-----
EOF
}

# ==============================================================================
# SSH KEYS - Obviously fake format
# ==============================================================================
generate_fake_ssh_keys() {
    echo -e "${GREEN}Generating SSH key test data...${NC}"
    
    # ED25519 key (fake)
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5FAKE_SSH_KEY_FOR_TESTING_NOT_REAL test@example.com" > ssh-ed25519.pub
    
    # RSA key (fake)
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQFAKE_RSA_SSH_KEY_FOR_TESTING_NOT_REAL test@example.com" > ssh-rsa.pub
    
    # Private key placeholder
    cat > ssh-private-key << 'EOF'
-----BEGIN OPENSSH PRIVATE KEY-----
FAKE_OPENSSH_PRIVATE_KEY_FOR_TESTING_NOT_REAL
THIS_IS_NOT_A_REAL_SSH_PRIVATE_KEY_JUST_FOR_TESTING
ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789012345678901234567890
-----END OPENSSH PRIVATE KEY-----
EOF
}

# ==============================================================================
# DOCKER REGISTRY AUTH - Safe test format
# ==============================================================================
generate_fake_docker_auth() {
    echo -e "${GREEN}Generating Docker registry test auth...${NC}"
    
    cat > docker-config.json << 'EOF'
{
  "auths": {
    "registry.example.com": {
      "auth": "FAKE_DOCKER_AUTH_FOR_TESTING_NOT_REAL_BASE64_ENCODED"
    },
    "private-registry.example.com": {
      "auth": "FAKE_PRIVATE_REGISTRY_AUTH_FOR_TESTING_NOT_REAL"
    }
  }
}
EOF
}

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================
main() {
    echo -e "${BLUE}🚀 Starting secure test data generation...${NC}"
    
    generate_fake_stripe_keys
    generate_fake_aws_credentials  
    generate_fake_github_tokens
    generate_fake_database_strings
    generate_fake_jwt_tokens
    generate_fake_api_keys
    generate_fake_certificates
    generate_fake_ssh_keys
    generate_fake_docker_auth
    
    # Create summary file
    cat > README.md << 'EOF'
# Test Data for Security Tool

This directory contains **FAKE** test data designed to:

✅ Look realistic enough for testing secret detection
✅ Be obviously fake to avoid triggering GitHub secret scanning
✅ Follow 2024-2025 security best practices for test data

## ⚠️ IMPORTANT NOTES

- **ALL DATA IS FAKE** - None of these are real credentials
- **Safe for GitHub** - Won't trigger push protection
- **Testing Only** - Designed specifically for security tool validation
- **Regularly Updated** - Patterns updated to avoid false positives

## Usage

These files are used by our test suite to validate:
- Secret detection accuracy
- Pattern matching capabilities  
- False positive prevention
- Performance with realistic data

## Security

This test data follows GitHub 2024-2025 best practices:
- Obviously fake patterns that won't trigger secret scanning
- Realistic structure for proper testing
- Clear labeling to prevent confusion
- Safe for public repositories

EOF

    echo -e "${GREEN}✅ Secure test data generation completed!${NC}"
    echo -e "${YELLOW}📁 Generated files in: tests/fixtures/data/${NC}"
    echo -e "${BLUE}📋 Summary: $(ls -1 | wc -l) test files created${NC}"
    
    # List generated files
    echo -e "\n${BLUE}Generated test files:${NC}"
    ls -la | grep -v "^d" | awk '{print "  " $9}' | sort
}

# Execute main function
main "$@"

# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.0.x   | :white_check_mark: |
| < 2.0   | :x:                |

## Reporting a Vulnerability

**Please do not open public issues for security vulnerabilities.**

To report a security vulnerability in Git Security Audit Framework:

📧 **Email**: negusnet101@gmail.com  
📝 **Subject**: `SECURITY: [Brief Description]`

### Include in your report:
- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment  
- Suggested fix (if available)
- Your contact information

### Our Response Timeline:
- **< 24 hours**: Initial response confirming receipt
- **< 72 hours**: Vulnerability assessment and severity classification
- **< 7 days**: Fix development and testing
- **< 14 days**: Public disclosure after fix deployment

## Security Best Practices

When using this tool:
- ✅ Never commit scan results containing real secrets to version control
- ✅ Use `--quiet` mode in automated CI/CD environments  
- ✅ Regularly update to the latest version for security improvements
- ✅ Configure `.gitsecurityignore` for legitimate test secrets
- ✅ Use specific version tags in production deployments (not `latest`)
- ✅ Review scan results manually before automated remediation
- ✅ Implement proper secret rotation when secrets are detected

## Security Features

This tool includes several security considerations:
- **Local Processing**: All scanning happens locally, no data sent to external services
- **No Persistence**: Scan results stored only in local temporary directories  
- **Configurable Output**: Sensitive findings can be redacted in outputs
- **Minimal Dependencies**: Pure bash implementation reduces attack surface
- **Open Source**: Full transparency allows community security audits
- **Audit Trails**: Comprehensive logging for compliance requirements

## Responsible Disclosure

We are committed to working with security researchers and the community to verify and respond to legitimate security vulnerabilities. We appreciate your efforts to responsibly disclose your findings and will acknowledge your contribution in our security advisories.

### Hall of Fame
*Security researchers who have helped improve this project will be listed here with their permission.*

## Contact

For security-related questions or concerns:
- Security Email: negusnet101@gmail.com
- Response Time: Typically within 24 hours
- Encrypted Communication: GPG key available upon request

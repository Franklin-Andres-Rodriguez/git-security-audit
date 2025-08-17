# 🤝 Contributing to Git Security Audit Framework

We're thrilled that you're interested in contributing to Git Security Audit Framework! This project thrives on community collaboration, and we welcome contributions from developers of all experience levels.

## 🌟 Ways to Contribute

### 🐛 **Bug Reports**
Found a bug? Help us fix it! Good bug reports are incredibly valuable.

### 💡 **Feature Requests** 
Have an idea for a new feature? We'd love to hear about it.

### 📝 **Documentation**
Help improve our docs, examples, or tutorials.

### 🔧 **Code Contributions**
Fix bugs, implement features, or improve performance.

### 🧪 **Testing**
Help us test new features or write additional test cases.

### 🎨 **Design & UX**
Improve the CLI experience, error messages, or output formatting.

## 🚀 Getting Started

### Development Environment Setup

#### Prerequisites
- **Bash 4.0+** (macOS users may need to upgrade)
- **Git 2.25+** (for modern git features)
- **Optional but recommended:**
  - `jq` for JSON processing
  - `shellcheck` for script linting
  - `shfmt` for shell formatting
  - `bats-core` for testing

#### Quick Setup
```bash
# 1. Fork the repository on GitHub
# 2. Clone your fork
git clone https://github.com/Franklin-Andres-Rodriguez/git-security-audit.git
cd git-security-audit

# 3. Add upstream remote
git remote add upstream https://github.com/Franklin-Andres-Rodriguez/git-security-audit.git

# 4. Install development dependencies
./scripts/setup-dev.sh

# 5. Verify setup
./tests/test-runner.sh --quick
```

#### Using Dev Container (Recommended)
```bash
# If you use VS Code with Dev Containers extension
# Just reopen in container when prompted, or:
# Cmd/Ctrl + Shift + P -> "Dev Containers: Reopen in Container"

# Everything will be pre-configured!
```

### Development Workflow

#### 🔄 **Standard Contribution Flow**
```bash
# 1. Create feature branch
git checkout -b feature/amazing-improvement

# 2. Make your changes
# ... code, test, commit ...

# 3. Keep your branch updated
git fetch upstream
git rebase upstream/main

# 4. Run full test suite
./tests/test-runner.sh

# 5. Push and create PR
git push origin feature/amazing-improvement
```

#### 📏 **Code Standards**

**Shell Scripting Guidelines:**
- Use `set -euo pipefail` for safety
- 4-space indentation (no tabs)
- Functions use `snake_case`
- Variables use `UPPER_CASE` for constants, `lower_case` for locals
- Quote all variables: `"$variable"`
- Use `local` for function variables

**Example Function:**
```bash
scan_secret_patterns() {
    local findings_dir="$1"
    local pattern_name="$2"
    local pattern="${SECRET_PATTERNS[$pattern_name]}"
    
    # Process with error handling
    if ! git log --all -p | grep -E "$pattern" > "$findings_dir/${pattern_name}.txt"; then
        log_verbose "No matches found for pattern: $pattern_name"
        return 0
    fi
    
    log_info "Found matches for pattern: $pattern_name"
}
```

**Commit Message Format:**
We use [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or improving tests
- `chore`: Maintenance tasks

**Examples:**
```bash
git commit -m "feat(patterns): add support for Stripe API keys"
git commit -m "fix(entropy): handle edge case with empty strings"
git commit -m "docs(readme): update installation instructions"
```

## 🧪 Testing

### Running Tests

```bash
# Quick smoke tests (< 30 seconds)
./tests/test-runner.sh --quick

# Full test suite (< 5 minutes)
./tests/test-runner.sh

# Specific test category
./tests/test-runner.sh unit
./tests/test-runner.sh integration
./tests/test-runner.sh pattern-detection

# Performance tests (long-running)
./tests/test-runner.sh performance
```

### Writing Tests

We use [BATS](https://github.com/bats-core/bats-core) for testing:

```bash
# tests/unit/test-pattern-detection.bats

#!/usr/bin/env bats

setup() {
    # Setup test environment
    export TEST_DIR="$(mktemp -d)"
    export SCRIPT_PATH="$BATS_TEST_DIRNAME/../../src/git-security-audit.sh"
}

teardown() {
    # Clean up
    rm -rf "$TEST_DIR"
}

@test "should detect AWS access keys" {
    # Create test file with AWS key
    echo "AKIAIOSFODNN7EXAMPLE" > "$TEST_DIR/test-file.txt"
    
    # Initialize git repo
    cd "$TEST_DIR"
    git init
    git add test-file.txt
    git commit -m "Add test file"
    
    # Run scanner
    run "$SCRIPT_PATH" --type secrets --output json
    
    # Assertions
    [ "$status" -eq 0 ]
    [[ "$output" =~ "aws_access_key" ]]
}
```

### Test Coverage

We aim for:
- **Unit tests**: 90%+ coverage of individual functions
- **Integration tests**: Cover all major workflows
- **Pattern tests**: Verify all secret patterns work correctly
- **Compliance tests**: Ensure all compliance frameworks function

## 📚 Documentation

### Documentation Structure

```
docs/
├── installation.md          # Installation guide
├── usage-examples.md        # Real-world examples
├── configuration.md         # Advanced configuration
├── compliance-guide.md      # Compliance frameworks
├── troubleshooting.md      # Common issues
├── api-reference.md        # CLI reference
├── architecture.md         # Technical architecture
└── development.md          # Development guide
```

### Writing Good Documentation

- **Be specific**: Include exact commands and examples
- **Use real scenarios**: Show practical use cases
- **Include troubleshooting**: Anticipate common problems
- **Keep it updated**: Documentation should match current version
- **Test your examples**: Ensure all code examples actually work

## 🔍 Code Review Process

### What We Look For

✅ **Good PR Qualities:**
- Clear description of changes and motivation
- Comprehensive tests for new functionality
- Documentation updates for user-facing changes
- Follows existing code style and patterns
- Handles edge cases and error conditions
- Performance considerations for large repositories

❌ **Common Issues:**
- Missing tests for new functionality
- Breaking changes without migration guide
- Hard-coded values instead of configurable options
- Poor error handling or unclear error messages
- Performance regressions on large repositories

### PR Template Checklist

When you create a PR, our template will guide you through:

- [ ] Description explains what and why
- [ ] Tests added/updated for changes
- [ ] Documentation updated if needed
- [ ] Breaking changes clearly marked
- [ ] Performance impact considered
- [ ] Security implications reviewed

## 🎯 Contribution Ideas

### 🌟 **Beginner-Friendly**
- Add new secret patterns (GitHub tokens, API keys)
- Improve error messages and user experience
- Add examples for CI/CD integrations
- Fix typos or improve documentation
- Add shell completion enhancements

### 🚀 **Intermediate**
- Implement new output formats (XML, YAML)
- Add support for custom compliance frameworks
- Improve entropy analysis algorithms
- Add parallel processing for large repositories
- Create additional reporting templates

### 💪 **Advanced**
- Machine learning for false positive reduction
- Integration with secret management tools (HashiCorp Vault, etc.)
- Performance optimizations for enterprise repositories
- Advanced git history analysis features
- Plugin architecture for extensibility

### 🔥 **Current Priorities**
Check our [Project Board](https://github.com/Franklin-Andres-Rodriguez/git-security-audit/projects) for current priorities and roadmap items.

## 🏷️ Issue Labels

We use labels to organize and prioritize work:

### **Type Labels**
- `bug` - Something isn't working
- `enhancement` - New feature or improvement
- `documentation` - Documentation updates
- `question` - General questions

### **Priority Labels**
- `priority: critical` - Security vulnerabilities, data loss
- `priority: high` - Important features, significant bugs
- `priority: medium` - Standard improvements
- `priority: low` - Nice-to-have features

### **Effort Labels**
- `effort: small` - Less than 1 day of work
- `effort: medium` - 1-3 days of work
- `effort: large` - More than 3 days of work

### **Special Labels**
- `good first issue` - Great for newcomers
- `help wanted` - We need community help
- `breaking change` - Requires version bump
- `security` - Security-related changes

## 💬 Community & Communication

### 📞 **Where to Get Help**

- **GitHub Discussions**: [Discussions tab](https://github.com/Franklin-Andres-Rodriguez/git-security-audit/discussions)
- **Issues**: For bugs and feature requests
- **Email**: security@git-security-audit.com (for security issues)
- **Discord**: [Development Channel](https://discord.gg/gitsecurityaudit) (if available)

### 🤝 **Code of Conduct**

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). We're committed to providing a welcoming and inspiring community for all.

### 🌎 **Internationalization**

We welcome contributions to make the tool more accessible:
- Error message translations
- Documentation in other languages
- Locale-specific compliance frameworks

## 🎉 Recognition

### Contributors Hall of Fame

All contributors are recognized in:
- [README.md contributors section](README.md#contributors)
- [Annual contributor report](https://github.com/Franklin-Andres-Rodriguez/git-security-audit/releases)
- Special mentions in release notes

### Contribution Rewards

- **First-time contributors**: Welcome swag package (if budget allows)
- **Regular contributors**: Annual recognition and priority support
- **Major contributors**: Maintainer privileges and decision-making input

## 📋 Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):
- `MAJOR.MINOR.PATCH`
- Breaking changes increment MAJOR
- New features increment MINOR
- Bug fixes increment PATCH

### Release Schedule

- **Patch releases**: As needed for critical bugs
- **Minor releases**: Monthly feature releases
- **Major releases**: When breaking changes accumulate

## 🚨 Security Contributions

Since this is a security tool, we take security contributions seriously:

### Security-First Development
- All security patterns must be thoroughly tested
- False positives should be minimized
- Performance must not degrade significantly
- Error handling must not leak sensitive information

### Responsible Disclosure
If you find security vulnerabilities in the tool itself:
1. **DO NOT** create a public issue
2. Email security@git-security-audit.com
3. Include detailed reproduction steps
4. Allow time for fix before public disclosure

## 📝 License

By contributing to Git Security Audit Framework, you agree that your contributions will be licensed under the [MIT License](LICENSE).

---

## 🙏 Thank You!

Every contribution, no matter how small, makes this project better for everyone. Whether you're fixing a typo, adding a feature, or helping other users, you're helping to make the developer ecosystem more secure.

**Ready to contribute?** Start by reading our issues labeled [`good first issue`](https://github.com/Franklin-Andres-Rodriguez/git-security-audit/labels/good%20first%20issue)!

---

*This contributing guide was inspired by the best practices from successful open source projects and is continuously updated based on community feedback.*

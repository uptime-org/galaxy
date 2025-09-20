# CI Testing Framework

This directory contains Docker-based testing tools that provide identical testing capabilities locally and in CI/CD pipelines.

## Overview

**Philosophy:** All testing runs in Docker containers to ensure consistency between local development and CI environments. No need to install testing tools on your machine - just Docker.

## Testing Framework Components

### 1. **Flake8** - Python Code Linting
**What it does:** Checks Python code for style violations, syntax errors, and code complexity
**Why we use it:** Ensures consistent code style across the team and catches common Python mistakes

```bash
# Example issues it catches:
- Unused imports
- Lines too long (>127 characters)
- Missing whitespace
- Syntax errors
- Overly complex functions
```

### 2. **Black** - Python Code Formatting
**What it does:** Automatically formats Python code to a consistent style
**Why we use it:** Eliminates debates about code formatting, ensures uniform style

```bash
# What it fixes:
- Inconsistent indentation
- Quote style (single vs double)
- Line breaks and spacing
- Trailing commas
```

### 3. **isort** - Import Sorting
**What it does:** Organizes Python imports in a consistent order
**Why we use it:** Makes imports readable and reduces merge conflicts

```bash
# How it organizes:
1. Standard library imports
2. Third-party imports  
3. Local application imports
# All alphabetically sorted within each group
```

### 4. **Bandit** - Security Vulnerability Scanner
**What it does:** Scans Python code for common security vulnerabilities
**Why we use it:** Prevents security issues from reaching production

```bash
# Security issues it finds:
- Hard-coded passwords
- SQL injection vulnerabilities
- Use of insecure functions
- Weak cryptographic practices
- File permission issues
```

### 5. **Safety** - Dependency Vulnerability Scanner
**What it does:** Checks Python dependencies for known security vulnerabilities
**Why we use it:** Ensures our dependencies don't have known security flaws

```bash
# What it checks:
- PyPI packages against vulnerability databases
- Reports CVE numbers and severity
- Suggests version updates to fix issues
```

### 6. **pytest** - Python Testing Framework
**What it does:** Runs unit tests and generates test reports
**Why we use it:** Validates code functionality and prevents regressions

```bash
# Features:
- Simple test discovery
- Fixtures for test setup/teardown
- Parametrized testing
- JSON report generation for CI
```

### 7. **Helm Lint** - Kubernetes Manifest Validation
**What it does:** Validates Helm chart templates and values
**Why we use it:** Catches Kubernetes configuration errors before deployment

```bash
# What it validates:
- YAML syntax
- Kubernetes resource specifications
- Template rendering
- Required fields
- Naming conventions
```

### 8. **Helm Template Test** - Template Rendering Validation
**What it does:** Renders Helm templates with different environment values
**Why we use it:** Ensures templates work correctly across dev/stage/prod

```bash
# What it tests:
- Template rendering for each environment
- Value substitution correctness
- Generated manifest validity
- Environment-specific configurations
```

## File Structure

```
ci-test/
├── README.md              # This file
├── Dockerfile              # Container with all testing tools
├── analyze.sh              # Main test runner script
├── requirements.txt        # Python testing dependencies
├── .flake8                 # Flake8 configuration
├── .bandit                 # Bandit security scanner config
└── reports/                # Generated test reports (gitignored)
    ├── .gitkeep           # Keeps directory in git
    ├── flake8-report.json # Linting issues
    ├── black-report.txt   # Formatting issues
    ├── isort-report.txt   # Import sorting issues
    ├── bandit-report.json # Security vulnerabilities
    ├── safety-report.json # Dependency vulnerabilities
    ├── pytest-report.json# Test results (if tests exist)
    └── helm-templates/    # Rendered Helm templates for validation
```

## Usage

### Run All Tests (Default)
```bash
./run-ci.sh
# or
./dev test
```

### Run Specific Target
```bash
./run-ci.sh --target python    # Only Python tests
./run-ci.sh --target helm      # Only Helm tests
```

### Run Specific Test Types
```bash
./run-ci.sh --tests security   # Only security scans
./run-ci.sh --lint flake8      # Only flake8 linting
```

### Run Specific Combinations
```bash
./run-ci.sh --target python --lint flake8,black --tests security
```

## Configuration Files

### `.flake8` - Python Linting Config
```ini
[flake8]
max-line-length = 127    # Allow longer lines than default (79)
max-complexity = 10      # Maximum cyclomatic complexity
ignore = E203, W503      # Ignore specific error codes
exclude = ...            # Directories to skip
```

### `.bandit` - Security Scanner Config
```ini
[bandit]
exclude_dirs = ci-test,helm,.git  # Skip these directories
skips = B101                      # Skip specific security tests
```

## Reports Generated

All reports are saved to `ci-test/reports/` and uploaded as CI artifacts:

1. **flake8-report.json** - Linting issues with line numbers
2. **black-report.txt** - Code formatting differences
3. **isort-report.txt** - Import sorting issues
4. **bandit-report.json** - Security vulnerabilities found
5. **safety-report.json** - Dependency security issues
6. **helm-lint-report.txt** - Helm chart validation results
7. **helm-templates/** - Rendered templates for each environment

## Understanding Test Results

### ✅ **Success Indicators**
- No security vulnerabilities found
- All templates render correctly
- Code passes linting rules
- No dependency security issues

### ⚠️ **Warning Indicators**  
- Minor linting issues (long lines, unused imports)
- Formatting inconsistencies
- Non-critical security suggestions

### ❌ **Failure Indicators**
- High-severity security vulnerabilities
- Helm template rendering failures
- Syntax errors in code
- Critical dependency vulnerabilities

## Integration with CI/CD

This testing framework runs in GitHub Actions and uploads reports as artifacts. The same Docker container that runs locally runs in CI, ensuring identical results.

**Workflow:**
1. **Every Push:** Tests run automatically
2. **Pull Requests:** Tests must pass before merge
3. **Deploy:** Only tested code gets deployed
4. **Reports:** Available for download from GitHub Actions

## Adding New Tests

To add new testing tools:

1. **Add dependency** to `requirements.txt`
2. **Add test function** to `analyze.sh`
3. **Update Dockerfile** if system packages needed
4. **Update this README** with explanation

The framework is designed to be extensible while maintaining the Docker-based approach for consistency.
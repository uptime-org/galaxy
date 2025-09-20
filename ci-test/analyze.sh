#!/bin/bash
set -e

# Default values
TARGET=""
TESTS="all"
LINT_TYPES="all"
OUTPUT_DIR="/app/ci-test/reports"

# Create output directory and ensure it exists
mkdir -p "$OUTPUT_DIR"
# Create a placeholder file to ensure directory exists for CI artifacts
touch "$OUTPUT_DIR/.gitkeep"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --target)
            TARGET="$2"
            shift 2
            ;;
        --tests)
            TESTS="$2"
            shift 2
            ;;
        --lint)
            LINT_TYPES="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --target TARGET     Target to analyze (python|helm|all)"
            echo "  --tests TESTS       Tests to run (security|safety|unit|all)"
            echo "  --lint LINT_TYPES   Lint types (flake8|black|isort|all)"
            echo "  --help             Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --target python --lint flake8"
            echo "  $0 --target helm --tests all"
            echo "  $0 --target all --tests security --lint all"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "🚀 Starting analysis with:"
echo "  Target: ${TARGET:-all}"
echo "  Tests: ${TESTS}"
echo "  Lint: ${LINT_TYPES}"
echo ""

# Python linting functions
run_flake8() {
    if [[ "$LINT_TYPES" == "all" || "$LINT_TYPES" == *"flake8"* ]]; then
        echo "🔍 Running flake8 linting..."
        flake8 --config=.flake8 . --format=json --output-file="$OUTPUT_DIR/flake8-report.json" || true
        flake8 --config=.flake8 . || echo "❌ Flake8 found issues"
    fi
}

run_black() {
    if [[ "$LINT_TYPES" == "all" || "$LINT_TYPES" == *"black"* ]]; then
        echo "🎨 Running black formatting check..."
        black --check --diff . > "$OUTPUT_DIR/black-report.txt" 2>&1 || echo "❌ Black found formatting issues"
    fi
}

run_isort() {
    if [[ "$LINT_TYPES" == "all" || "$LINT_TYPES" == *"isort"* ]]; then
        echo "📦 Running isort import sorting check..."
        isort --check-only --diff . > "$OUTPUT_DIR/isort-report.txt" 2>&1 || echo "❌ Isort found import issues"
    fi
}

# Security testing functions
run_bandit() {
    if [[ "$TESTS" == "all" || "$TESTS" == *"security"* ]]; then
        echo "🔒 Running bandit security scan..."
        bandit -c .bandit -r . -f json -o "$OUTPUT_DIR/bandit-report.json" || true
        echo "📄 Security report saved to: $OUTPUT_DIR/bandit-report.json"
    fi
}

run_safety() {
    if [[ "$TESTS" == "all" || "$TESTS" == *"safety"* ]]; then
        echo "🛡️ Running safety dependency check..."
        safety check --json --output "$OUTPUT_DIR/safety-report.json" || true
        echo "📄 Safety report saved to: $OUTPUT_DIR/safety-report.json"
    fi
}

# Unit testing functions
run_pytest() {
    if [[ "$TESTS" == "all" || "$TESTS" == *"unit"* ]]; then
        echo "🧪 Running pytest..."
        if [ -d "tests" ]; then
            pytest tests/ --json-report --json-report-file="$OUTPUT_DIR/pytest-report.json" || true
        else
            echo "📝 No tests directory found, skipping pytest"
        fi
    fi
}

# Helm testing functions
run_helm_lint() {
    if [[ "$LINT_TYPES" == "all" || "$LINT_TYPES" == *"helm"* ]]; then
        echo "⎈ Running Helm lint..."
        helm lint helm/ > "$OUTPUT_DIR/helm-lint-report.txt" 2>&1 || echo "❌ Helm lint found issues"
    fi
}

run_helm_template_test() {
    if [[ "$TESTS" == "all" || "$TESTS" == *"helm"* ]]; then
        echo "⎈ Testing Helm templates..."
        for env in dev stage prod; do
            echo "  Testing $env environment..."
            helm template test helm/ \
                --values helm/env/$env.values.yaml \
                --set env="$env" \
                --set image.tag="test" \
                --output-dir "$OUTPUT_DIR/helm-templates/$env/" || echo "❌ Helm template test failed for $env"
        done
    fi
}

# Main execution logic
case "${TARGET:-all}" in
    "python")
        echo "🐍 Analyzing Python code..."
        run_flake8
        run_black
        run_isort
        run_bandit
        run_safety
        run_pytest
        ;;
    "helm")
        echo "⎈ Analyzing Helm charts..."
        run_helm_lint
        run_helm_template_test
        ;;
    "all"|"")
        echo "🔄 Running full analysis..."
        run_flake8
        run_black
        run_isort
        run_bandit
        run_safety
        run_pytest
        run_helm_lint
        run_helm_template_test
        ;;
    *)
        echo "❌ Unknown target: $TARGET"
        echo "Valid targets: python, helm, all"
        exit 1
        ;;
esac

echo ""
echo "✅ Analysis complete! Reports saved to: $OUTPUT_DIR"
echo ""
echo "📊 Generated reports:"
ls -la "$OUTPUT_DIR" 2>/dev/null || echo "No reports generated"

# Summary
echo ""
echo "🎯 Analysis Summary:"
if [ -f "$OUTPUT_DIR/flake8-report.json" ]; then
    FLAKE8_ISSUES=$(jq length "$OUTPUT_DIR/flake8-report.json" 2>/dev/null || echo "unknown")
    echo "  Flake8 issues: $FLAKE8_ISSUES"
fi

if [ -f "$OUTPUT_DIR/bandit-report.json" ]; then
    SECURITY_ISSUES=$(jq '.results | length' "$OUTPUT_DIR/bandit-report.json" 2>/dev/null || echo "unknown")
    echo "  Security issues: $SECURITY_ISSUES"
fi

echo "  Reports directory: $OUTPUT_DIR"
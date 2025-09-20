#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="bandy-ci"

# Build the CI image
echo "🐳 Building CI container..."
docker build -f ci-test/Dockerfile -t "$IMAGE_NAME" .

# Run with provided arguments or default to full analysis
if [ $# -eq 0 ]; then
    echo "🔄 Running full analysis (no arguments provided)..."
    docker run --rm -v "$SCRIPT_DIR/ci-test/reports:/app/ci-test/reports" "$IMAGE_NAME"
else
    echo "🚀 Running with custom parameters: $@"
    docker run --rm -v "$SCRIPT_DIR/ci-test/reports:/app/ci-test/reports" "$IMAGE_NAME" "$@"
fi

# Show results
if [ -d "$SCRIPT_DIR/ci-test/reports" ]; then
    echo ""
    echo "📊 Reports available in: $SCRIPT_DIR/ci-test/reports"
    ls -la "$SCRIPT_DIR/ci-test/reports"
fi
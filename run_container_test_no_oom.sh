#!/bin/bash

# 🚀 CONTAINER TEST RUN SCRIPT - NO OOM KILLER VERSION
# Runs chat.py --test with core isolation and OOM killer disabled

set -e  # Exit on any error

echo "🚀 Starting Container Mesh Test (No OOM Killer)..."
echo "================================"

# Configuration
CONTAINER_NAME="aimgr-test-$(date +%Y%m%d_%H%M%S)"
IMAGE_NAME="testc-minimal"
TEST_COMMAND="/home/aimgr/venv2/bin/python3 /home/aimgr/dev/avoli/agent2/chat.py --test"

# Resource limits
MEMORY_LIMIT="20g"

echo "📊 Configuration:"
echo "  Container: $CONTAINER_NAME"
echo "  Image: $IMAGE_NAME"
echo "  Memory Limit: $MEMORY_LIMIT"
echo "  OOM Killer: DISABLED"
echo "  Test Command: $TEST_COMMAND"
echo ""

# Pre-flight checks
echo "🔍 Pre-flight checks..."

# Check Docker is running (ALREADY RUNNING - no permission issues)
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Starting Docker..."
    systemctl start docker
    sleep 3
fi

# Check container image exists
if ! docker images | grep -q "$IMAGE_NAME"; then
    echo "❌ Container image '$IMAGE_NAME' not found."
    echo "   Run: docker build -t $IMAGE_NAME /tmp/container-mesh/"
    exit 1
fi

# Check test files exist
if [ ! -f "/home/aimgr/dev/avoli/agent2/chat.py" ]; then
    echo "❌ Test file 'chat.py' not found in current directory."
    exit 1
fi

if [ ! -d "/home/aimgr/venv2" ]; then
    echo "❌ Python virtual environment not found at /home/aimgr/venv2"
    exit 1
fi

echo "✅ All pre-flight checks passed."
echo ""

# Run the container test
echo "🧪 Running container test..."
echo "================================"

# Start timing
START_TIME=$(date +%s.%N)

# Execute container with resource isolation (OOM killer disabled)
docker run --rm \
  --name "$CONTAINER_NAME" \
  --user 1003 \
  --memory="$MEMORY_LIMIT" \
  --memory-swap="-1" \
  --oom-kill-disable \
  --network="none" \
  --tmpfs="/tmp" \
  -v /usr/bin:/usr/bin:ro \
  -v /usr/lib:/usr/lib:ro \
  -v /lib:/lib:ro \
  -v /lib64:/lib64:ro \
  -v /etc:/etc:ro \
  -v /home/aimgr/dev/avoli/agent2:/home/aimgr/dev/avoli/agent2:ro \
  -v /home/aimgr/venv2:/home/aimgr/venv2:ro \
  "$IMAGE_NAME" \
  $TEST_COMMAND

# Check exit code
EXIT_CODE=$?

# End timing
END_TIME=$(date +%s.%N)
DURATION=$(echo "$END_TIME - $START_TIME" | bc -l)

echo ""
echo "================================"
echo "📊 Test Results:"
echo "  Exit Code: $EXIT_CODE"
echo "  Duration: $DURATION seconds"
echo "  Container: $CONTAINER_NAME"

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Test completed successfully!"
else
    echo "❌ Test failed with exit code $EXIT_CODE"
fi

# Show system impact
echo ""
echo "📈 System Impact:"
echo "  Current Load: $(uptime | awk -F'load average:' '{print $2}')"
echo "  Memory Usage: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
echo "  Container Status: Removed (--rm flag)"

echo ""
echo "🎯 Container Test Complete!"

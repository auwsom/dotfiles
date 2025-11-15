#!/bin/bash

# 🚀 CONTAINER TEST RUN SCRIPT - IMPROVED OUTPUT CAPTURE
# Runs chat.py --test with core isolation, OOM killer disabled, and proper output capture

set -e  # Exit on any error

echo "🚀 Starting Container Mesh Test (Improved Output Capture)..."
echo "================================"

# Configuration
CONTAINER_NAME="aimgr-test-$(date +%Y%m%d_%H%M%S)"
IMAGE_NAME="testc-minimal"
TEST_COMMAND="/home/aimgr/venv2/bin/python3 /home/aimgr/dev/avoli/agent2/chat.py --test"
OUTPUT_LOG="/tmp/container_test_output_$(date +%Y%m%d_%H%M%S).log"

# Resource limits
MEMORY_LIMIT="20g"

echo "📊 Configuration:"
echo "  Container: $CONTAINER_NAME"
echo "  Image: $IMAGE_NAME"
echo "  Memory Limit: $MEMORY_LIMIT"
echo "  OOM Killer: DISABLED"
echo "  Output Log: $OUTPUT_LOG"
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

# Execute container with resource isolation (OOM killer disabled) and improved output capture
docker run \
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
  $TEST_COMMAND > "$OUTPUT_LOG" 2>&1

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
echo "  Output Log: $OUTPUT_LOG"

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
echo "  Container Status: Still running (for log access)"

# Show last 20 lines of output
echo ""
echo "📄 Test Output Summary:"
echo "================================"
if [ -s "$OUTPUT_LOG" ]; then
    tail -20 "$OUTPUT_LOG"
else
    echo "⚠️  Output log is empty"
fi

echo ""
echo "🎯 Container Test Complete!"
echo "📁 Full output saved to: $OUTPUT_LOG"
echo "🔍 Container still running. Access logs with: docker logs $CONTAINER_NAME"
echo "🗑️  Remove container when done: docker rm $CONTAINER_NAME"

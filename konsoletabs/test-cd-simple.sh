#!/bin/bash
# Simple test: can we change directories in konsole?

echo "Testing directory change in new konsole..."

# Create a test script that changes directory
cat > /tmp/test_cd.sh << 'EOF'
#!/bin/bash
echo "Starting in: $(pwd)"
cd /tmp
echo "Changed to: $(pwd)"
exec bash
EOF

chmod +x /tmp/test_cd.sh

# Start konsole with the test script
echo "Starting konsole with test script..."
konsole -e /tmp/test_cd.sh &

echo "Test window should show directory change to /tmp"
echo "Press Enter to clean up..."
read input

# Cleanup
rm -f /tmp/test_cd.sh

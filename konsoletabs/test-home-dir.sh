#!/bin/bash
# Test if we can make konsole start in /home/user

echo "Testing konsole directory change..."

# Test method 1: Create a script that changes directory
cat > /tmp/test_home.sh << 'EOF'
#!/bin/bash
echo "Should start in /home/user"
cd /home/user
pwd
echo "Current directory: $(pwd)"
exec bash
EOF

chmod +x /tmp/test_home.sh

echo "Starting konsole with directory change script..."
echo "Window should show /home/user directory"

# This should work since Fresh Layout works
konsole --profile "Regular User" -e /tmp/test_home.sh &

echo ""
echo "If the window shows /home/user, then we can fix restore."
echo "Press Enter to cleanup and close..."
read input

rm -f /tmp/test_home.sh

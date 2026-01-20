#!/bin/bash
# Test single window restore with directory

echo "Testing single window restore to /home..."

# Create simple script
cat > /tmp/test_single.sh << 'EOF'
#!/bin/bash
echo "Window should be in /home"
cd /home
pwd
exec bash
EOF

chmod +x /tmp/test_single.sh

# Start konsole
echo "Starting konsole..."
konsole --profile "Regular User" -e /tmp/test_single.sh &

echo "Window started. Check if it's in /home directory."
echo "Press Enter to cleanup..."
read input

rm -f /tmp/test_single.sh

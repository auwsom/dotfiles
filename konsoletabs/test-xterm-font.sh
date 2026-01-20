#!/bin/bash
# Quick xterm font size test

echo "Testing different xterm font sizes..."
echo "Choose a font size:"
echo "1) Size 12 (small)"
echo "2) Size 14 (current default)" 
echo "3) Size 16 (medium)"
echo "4) Size 18 (large)"
echo "5) Size 20 (very large)"
echo "6) Size 24 (huge)"

read -p "Enter choice (1-6): " choice

case $choice in
    1) SIZE=12 ;;
    2) SIZE=14 ;;
    3) SIZE=16 ;;
    4) SIZE=18 ;;
    5) SIZE=20 ;;
    6) SIZE=24 ;;
    *) SIZE=14 ;;
esac

echo "Opening xterm with font size $SIZE..."
xterm -fn "DejaVu Sans Mono-$SIZE" -fb "DejaVu Sans Mono Bold-$SIZE" &

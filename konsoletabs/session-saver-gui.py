#!/usr/bin/env python3
"""
Konsole Session Saver - GUI Version
Creates a desktop shortcut to save the current Konsole session
"""

import os
import subprocess
import json
from datetime import datetime
import sys

def create_desktop_shortcut():
    """Create a desktop shortcut for saving Konsole sessions"""
    
    desktop_dir = os.path.expanduser("~/Desktop")
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    shortcut_content = f"""[Desktop Entry]
Version=1.0
Type=Application
Name=Save Konsole Session
Comment=Save current Konsole session with tabs and directories
Icon=konsole
Exec={script_dir}/save-session-enhanced.sh
Terminal=false
Categories=System;Utility;
"""
    
    shortcut_path = os.path.join(desktop_dir, "save-konsole-session.desktop")
    
    try:
        with open(shortcut_path, 'w') as f:
            f.write(shortcut_content)
        
        # Make it executable
        os.chmod(shortcut_path, 0o755)
        
        print(f"✅ Created desktop shortcut: {shortcut_path}")
        print("🖱️  Double-click this shortcut when you have your full Konsole layout set up!")
        print("")
        print("📋 Instructions:")
        print("1. Set up your Konsole layout (8 tabs + 4 windows with 3 tabs each)")
        print("2. Make sure some tabs have 'su aimgr' running in different directories")
        print("3. Double-click the 'Save Konsole Session' shortcut on your desktop")
        print("4. Check the output to see what was captured")
        
        return True
    except Exception as e:
        print(f"❌ Error creating desktop shortcut: {e}")
        return False

def quick_save():
    """Quick save function that can be called manually"""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    save_script = os.path.join(script_dir, "save-session-enhanced.sh")
    
    try:
        result = subprocess.run([save_script], capture_output=True, text=True)
        print("🔄 Running enhanced session save...")
        print(result.stdout)
        if result.stderr:
            print("⚠️  Warnings/Errors:")
            print(result.stderr)
        return True
    except Exception as e:
        print(f"❌ Error running save script: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--quick":
        quick_save()
    else:
        create_desktop_shortcut()

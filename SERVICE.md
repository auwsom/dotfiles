# Service Management Documentation

## 🎯 SERVICE STATUS: MANUAL-ONLY OPERATION

### Current Status: ✅ OPTIMIZED FOR MANUAL START

All services are now configured for **manual start only** to prevent:
- **Automatic restart** causing high load (30+ load average)
- **Core allocation conflicts** with system/desktop cores (0-1)
- **Resource exhaustion** from uncontrolled service spawning
- **System instability** from competing services

## 📊 SERVICE CONFIGURATION

### Docker Services (Container Runtime)
```bash
# Current Status: ✅ ACTIVE but DISABLED from auto-start
systemctl status docker
  Loaded: disabled (preset: enabled)
  Active: active (running) - manually started
  Drop-In: /etc/systemd/system/docker.service.d/cpu-affinity.conf
```

**Configuration:**
- **Auto-start**: ❌ DISABLED (systemctl disable docker)
- **Manual start**: ✅ Available when needed
- **CPU Affinity**: ✅ Cores 6-19 (via systemd drop-in)
- **Purpose**: Container testing only (not service management)

### Problematic Services (Permanently Disabled)
The following services were causing system instability and have been **permanently disabled**:

| Service | Status | Problem | Solution |
|---------|--------|---------|----------|
| **supervisor** | ❌ DISABLED | Process manager causing 30+ load | Docker daemon stopped |
| **good_job** | ❌ DISABLED | Background job processor | Container removed |
| **puma** | ❌ DISABLED | Ruby web server | Container removed |
| **postgres** | ❌ DISABLED | Database service | Container removed |
| **memcached** | ❌ DISABLED | Caching service | Container removed |

## 🚀 AVAILABLE SERVICES (MANUAL START ONLY)

### 1. Agent2 Discord Bot Service
```bash
# Manual start only
cd /home/aimgr/dev/avoli/agent2
./goose2_service.sh

# Configuration:
- Environment: /home/aimgr/venv2
- Port: Discord bot (no HTTP port)
- Core usage: Will use AIMGR cores (4-19)
- Logging: Standard output to terminal
```

### 2. Agent2 HTTP Service
```bash
# Manual start only
cd /home/aimgr/dev/avoli/agent2
python3 chat_http_service.py

# Configuration:
- Environment: /home/aimgr/venv2
- Port: 7899 (HTTP interface)
- Core usage: Will use AIMGR cores (4-19)
- Purpose: HTTP API for agent2
- Logging: chat_http_service.log
```

### 3. Container Test Services
```bash
# Manual container test execution
cd /home/aimgr/dev/avoli/agent2

# Primary test (recommended)
./run_container_test_logged.sh

# Alternative with debug output
./run_container_test_capture.sh

# High memory test (20GB)
./run_container_test_no_oom.sh
```

### 4. Universal Service Manager
```bash
# Manual universal service
cd /home/aimgr/dev/avoli/agent2
python3 universal_service.py

# Configuration:
- Multi-service management
- Core usage: AIMGR cores (4-19)
- Purpose: Centralized service control
- Logging: universal_service.log
```

## 🔧 SERVICE MANAGEMENT COMMANDS

### Docker Management
```bash
# Start Docker manually (when needed)
systemctl start docker

# Stop Docker when done
systemctl stop docker

# Check Docker status
systemctl status docker

# Check Docker CPU affinity
systemctl show docker.service | grep CPUAffinity
```

### Service Process Management
```bash
# Check for any running services
ps aux | grep -E '(supervisor|good_job|puma)' | grep -v grep

# Kill any rogue processes
pkill -9 -f supervisor
pkill -9 -f good_job
pkill -9 -f puma

# Check system load
uptime

# Check core usage
ps -eo pid,psr,comm | awk '{print $2}' | sort | uniq -c
```

### Agent2 Service Management
```bash
# Start Agent2 Discord bot manually
cd /home/aimgr/dev/avoli/agent2 && ./goose2_service.sh

# Start Agent2 HTTP service manually
cd /home/aimgr/dev/avoli/agent2 && python3 chat_http_service.py

# Check if services are running
ps aux | grep -E '(goose2|chat_http)' | grep -v grep

# Check service logs
tail -f goose2_service.log
tail -f chat_http_service.log
```

## 📋 SERVICE CONFIGURATION FILES

### Systemd Configuration (Docker)
```bash
# Docker CPU affinity configuration
/etc/systemd/system/docker.service.d/cpu-affinity.conf
[Service]
CPUAffinity=6-19
```

### Service Scripts Location
All service scripts are located in: `/home/aimgr/dev/avoli/agent2/`

| Script | Purpose | Auto-start | Manual Use |
|--------|---------|------------|------------|
| `goose2_service.sh` | Discord bot | ❌ | ✅ Recommended |
| `chat_http_service.py` | HTTP API | ❌ | ✅ Available |
| `universal_service.py` | Multi-service | ❌ | ✅ Available |
| `restart_agent2_server.sh` | Health monitoring | ❌ | ✅ For debugging |

## ⚠️ IMPORTANT WARNINGS

### 1. No Automatic Service Restart
```bash
# WARNING: Do NOT enable any services for auto-start
# This will cause system instability and high load average

# NEVER do this:
systemctl enable docker  # ❌ BAD - causes auto-start
systemctl enable any-other-service  # ❌ BAD
```

### 2. Core Allocation Protection
```bash
# System cores 0-1 are PROTECTED for desktop/system
# Services will automatically use AIMGR cores 4-19
# Do NOT manually assign services to system cores
```

### 3. Resource Management
```bash
# Monitor system load when running services
# If load exceeds 10, stop services immediately
uptime  # Check load average
```

## 🚨 EMERGENCY PROCEDURES

### If Services Cause High Load
```bash
# 1. Check load average
uptime

# 2. Stop all services
systemctl stop docker
pkill -9 -f goose2
pkill -9 -f chat_http
pkill -9 -f universal_service

# 3. Verify services stopped
ps aux | grep -E '(goose2|chat_http|universal)' | grep -v grep

# 4. Check system stability
uptime
```

### If System Becomes Unresponsive
```bash
# Use virsh reset for complete system recovery
timeout 10 sudo virsh reset 3

# After reboot, verify no auto-start services
systemctl status docker | grep disabled
ps aux | grep -E '(supervisor|good_job|puma)' | grep -v grep
```

## 📈 PERFORMANCE MONITORING

### Recommended Monitoring Commands
```bash
# Monitor system load
watch -n 5 'uptime'

# Monitor core usage
watch -n 5 'ps -eo pid,psr,comm | awk '\''{print $2}'\'' | sort | uniq -c'

# Monitor Docker containers
watch -n 5 'docker ps'

# Monitor service processes
watch -n 5 'ps aux | grep -E '\''(goose2|chat_http|universal)'\'' | grep -v grep'
```

## 🏆 BEST PRACTICES

### 1. Service Usage Pattern
```bash
# ✅ RECOMMENDED: Manual start for specific tasks
./goose2_service.sh  # Start Discord bot when needed
./run_container_test_logged.sh  # Run tests when needed

# ❌ AVOID: Continuous service operation
# Do NOT leave services running unattended
```

### 2. Resource Management
```bash
# Start services one at a time
# Monitor system load after each service start
# Stop services immediately when not in use
```

### 3. System Protection
```bash
# Always verify cores 0-1 are protected
# Never enable auto-start for any service
# Use virsh reset if system becomes unstable
```

---

**Status**: ✅ CONFIGURED FOR MANUAL-ONLY OPERATION

**Key Principle**: Services are tools, not background processes. Start them when needed, stop them when done.

**System Impact**: Zero background load when no services running, full control when services are active.

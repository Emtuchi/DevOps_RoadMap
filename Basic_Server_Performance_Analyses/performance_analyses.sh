#!/bin/bash

# Get CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')

# Get Memory usage
TOTAL_MEM=$(free -m | awk '/Mem:/ {print $2}')
USED_MEM=$(free -m | awk '/Mem:/ {print $3}')
FREE_MEM=$(free -m | awk '/Mem:/ {print $4}')
MEM_PERCENT=$(awk "BEGIN {printf \"%.2f\", ($USED_MEM/$TOTAL_MEM)*100}")

# Get Disk usage
DISK_USAGE=$(df -h --total | grep 'total' | awk '{print $3}')
DISK_FREE=$(df -h --total | grep 'total' | awk '{print $4}')
DISK_PERCENT=$(df -h --total | grep 'total' | awk '{print $5}')

# Get top 5 CPU-consuming processes
TOP_CPU_PROCESSES=$(ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6)

# Get top 5 memory-consuming processes
TOP_MEM_PROCESSES=$(ps -eo pid,comm,%mem --sort=-%mem | head -n 6)

# Get OS Version
OS_VERSION=$(cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d '=' -f2 | tr -d '"')

# Get system uptime
UPTIME=$(uptime -p)

# Get load average
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}')

# Get logged in users
LOGGED_USERS=$(who | wc -l)

# Get failed login attempts (Only for systems using auth.log)
FAILED_LOGINS=$(grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l)

# Print system stats
echo "===== Server Performance Stats ====="
echo "CPU Usage: $CPU_USAGE%"
echo "Memory Usage: $USED_MEM MB / $TOTAL_MEM MB ($MEM_PERCENT%)"
echo "Disk Usage: $DISK_USAGE used / $DISK_FREE free ($DISK_PERCENT)"
echo "\n--- Top 5 CPU-Consuming Processes ---"
echo "$TOP_CPU_PROCESSES"
echo "\n--- Top 5 Memory-Consuming Processes ---"
echo "$TOP_MEM_PROCESSES"
echo "\n===== Additional System Information ====="
echo "OS Version: $OS_VERSION"
echo "Uptime: $UPTIME"
echo "Load Average: $LOAD_AVG"
echo "Logged-in Users: $LOGGED_USERS"
echo "Failed Login Attempts: $FAILED_LOGINS"

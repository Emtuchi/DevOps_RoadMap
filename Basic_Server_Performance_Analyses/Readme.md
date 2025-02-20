# A script that analyses basic server performance

### how to use

#### give it execute permissions

```
chmod +x performance_analyses.sh
```

#### run it with

```
./performance_analyses.sh
```

## WHAT IS SERVER PERFORMANCE:

Server performance is a measurement of how well the server is performing. It is the process of overseeing system resources such as CPU usage, memory consumption, storage capacity, I/O performance, network uptime, and more. Server performance monitoring helps identify performance-related issues of a server, such as response time, resource utilization, and application downtime. The key factors affecting server performance are utilization of server CPU and memory resources.

## Here are the core statistics we aim to track:

1. Total CPU Usage
2. Total Memory Usage (Free vs. Used, including percentage)
3. Total Disk Usage (Free vs. Used, including percentage)
4. Top 5 Processes by CPU Usage
5. Top 5 Processes by Memory Usage

## CODE EXPLANATION:

```bash
#!/bin/bash
```

• This tells the system to use the Bash shell to execute the script.

### Get CPU usage

```bash
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
```

#### top -bn1:

- Runs top(You'll see a live-updating table of processes, sorted by CPU usage by default.) in batch mode(-b), This will output the system stats once(cos it does live updating continuously if u don’t do this) and exit., for 1 iteration (-n1).

#### grep "Cpu(s)":

- Extracts the line containing CPU usage details.

#### awk '{print $2 + $4}':

- awk treats whitespace as a separator which it uses to create columns and assigns each column a variable($1, $2, $3 etc), so if "me you" is passed, $1 is me and $2 is you, $1 is always whats on the left of the first split,so "me you us", and "us" will be $3

- {print $2 + $3} means print the results(+) of the 2nd($2) and 3rd($3) columns after they have been added:
  > $2 represents the user CPU usage.

> $4 represents the system CPU usage.

> We sum them to get the total CPU usage.

### Get Memory usage

```bash
TOTAL_MEM=$(free -m | awk '/Mem:/ {print $2}')
USED_MEM=$(free -m | awk '/Mem:/ {print $3}')
FREE_MEM=$(free -m | awk '/Mem:/ {print $4}')
MEM_PERCENT=$(awk "BEGIN {printf \"%.2f\", ($USED_MEM/$TOTAL_MEM)*100}")
```

#### free -m:

- Displays memory usage in MB.

#### awk '/Mem:/ {print $2}':

- Extracts total memory.

#### awk '/Mem:/ {print $3}':

- Extracts used memory.

#### awk '/Mem:/ {print $4}':

- Extracts free memory.

> Note:
>
> #### Pattern Matching:
>
> In awk, anything inside /.../ is treated as a regular expression.
>
> /Mem:/ → Matches any line containing "Mem:".
>
> Without slashes, awk would treat "Mem:" as a variable (which will lead to syntax error or no result), if u want Mem to be treated as a variable for searching, use grep instead.

#### awk "BEGIN {printf &#92;"%.2f&#92;", ($USED_MEM/$TOTAL_MEM)\*100}":

- Calculates percentage of memory used, formatted to 2 decimal places.

  #### awk:

  - This runs the awk command.

  #### "BEGIN { ... }"

  - Normally, awk reads data line by line from a file or standard input.

  - Here, we are just performing a mathematical calculation (($USED_MEM/$TOTAL_MEM)\*100), so we don't need to process any input.

  - BEGIN tells awk to skip waiting for input and execute the code right away. Without BEGIN, awk would expect input and might hang or behave unexpectedly.

  #### printf &#92;"%.2f&#92;", ($USED_MEM/$TOTAL_MEM)\*100

  - printf → A formatted print function (similar to C’s printf).

  - &#92;"%.2f&#92;" → Format specifier:

  - "%.2f" → Print floating-point number with 2 decimal places.
  - ($USED_MEM/$TOTAL_MEM)\*100 → Calculation:

  - $USED_MEM → Used memory (variable set earlier in the script).

  - $TOTAL_MEM → Total memory.

  - ($USED_MEM/$TOTAL_MEM)\*100 → Converts fraction to percentage.

> Note:
>
> - When writing a command inside a shell script, double quotes (") are used to enclose strings.
>
> - Since awk uses double quotes ("%.2f") to specify format strings, we need to escape them using &#92;" so that the shell doesn't interpret them incorrectly.
>
> - Without escaping, the shell would interpret the " inside awk as the end of the string, causing a syntax error.
>
> - By using &#92;", we tell the shell, "This is part of the awk command, not the script's string."
> - Alternatively, Instead of escaping quotes, you can use single quotes ' to enclose the awk command

(html special characters like &#92; were used in this readme, look it up)

### Get Disk usage

```bash
DISK_USAGE=$(df -h --total | grep 'total' | awk '{print $3}')
DISK_FREE=$(df -h --total | grep 'total' | awk '{print $4}')
DISK_PERCENT=$(df -h --total | grep 'total' | awk '{print $5}')
```

#### df -h --total:

- df -h → Shows disk usage in human-readable format (e.g., GB/MB or Unicode text).

- --total → Adds a row with the total disk usage.

#### grep 'total'

- Filters only the total row.

#### awk '{print $3}'

- Extracts used disk space.

#### awk '{print $4}'

- Extracts free disk space.

#### awk '{print $5}'

- Extracts disk usage percentage.

### Get top 5 CPU-consuming processes

```bash
TOP_CPU_PROCESSES=$(ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6)
```

#### ps -eo pid,comm,%cpu:

- ps -eo → Lists processes with specific columns.

- pid → Process ID.

- comm → Command name.

- %cpu → CPU usage percentage.

#### --sort=-%cpu

- Sorts by CPU usage in descending order.

#### head -n 6

- Gets the top 5 processes plus the header.

### Get top 5 memory-consuming processes

```bash
TOP_MEM_PROCESSES=$(ps -eo pid,comm,%mem --sort=-%mem | head -n 6)
```

- Similar to CPU processes, but instead of %cpu, we use %mem (memory usage).

### Get OS Version

```bash
OS_VERSION=$(cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d '=' -f2 | tr -d '"')
```

#### cat /etc/os-release

- Displays OS details.

#### grep -w "PRETTY_NAME"

- Extracts the pretty name (full OS name).

#### cut -d '=' -f2

- Extracts the value after =.

#### tr -d '&#92;"'

- Removes quotes.

### Get system uptime

```bash
UPTIME=$(uptime -p)
```

#### uptime -p

- Shows uptime in a human-readable format (e.g., "up 5 hours, 30 minutes").

### Get load average

```bash
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}')
```

#### uptime

- Displays system uptime and load average.

#### awk -F'load average:' '{print $2}'

- Extracts the load average part.
- awk -F'delimiter' '{print $column_number}'
- The -F flag in awk sets the field separator (delimiter) for splitting input lines into columns.
- $2 represents the second column i.e what came after "load average", $1 is what came before, since it broke the linw into 2 parts

### Get logged in users

```bash
LOGGED_USERS=$(who | wc -l)
```

#### who

- Lists logged-in users.

#### wc -l

- Counts the number of logged-in users.

### Get failed login attempts (Only for systems using auth.log)

```bash
FAILED_LOGINS=$(grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l)
```

#### grep "Failed password" /var/log/auth.log

- Searches for failed login attempts.
- Works on Ubuntu/Debian (might need /var/log/secure for CentOS/RHEL).
- 2>/dev/null: Suppresses error if auth.log is missing.

#### wc -l

- Counts failed login attempts.

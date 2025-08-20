# Linux Day 3 - Practice Session Log

## Date: Tue Aug 19, 2025

---

## Section 1: Find Command - Part 3

### Finding Files by Name
```bash
# Find specific file by name
find . -name "error.txt"
# Output: ./Linux/Day_1/Commands/error.txt

# Find all .txt files
find . -name "*.txt"
# Output:
# ./Linux/Day_3/Commands/findme.txt
# ./Linux/Day_1/Commands/error.txt
# ./Linux/Day_1/Commands/input.txt
# ./Linux/Day_1/Commands/hello.txt
# ./Linux/Day_1/Commands/output.txt
# ./Linux/Day_2/commands/filea.txt
# ./Linux/Day_2/commands/date.txt
# ./Linux/Day_2/commands/diary.txt
# ./Linux/Day_2/commands/reversed.txt
# ./Linux/Day_2/commands/fileb.txt
# ./Linux/Day_2/commands/file1.txt
# ./Linux/Day_2/commands/file2.txt
# ./Linux/Day_2/commands/deleteme.txt
# ./Linux/Day_2/commands/unsorted.txt
# ./Linux/Day_2/Docs/Locate.txt

# Case-sensitive vs case-insensitive search
find . -name "*.TXT"     # Won't find lowercase .txt files
find . -iname "*.TXT"    # Will find both .txt and .TXT files (case-insensitive)
```

### Finding Files by Size
```bash
# Find files larger than 100KB
find / -type f -size +100k

# Find files smaller than 50KB in current directory
find . -type f -size -50k
# Output:
# ./day3.md
# ./findme.txt

# Count large files system-wide
sudo find / -type f -size +100k | wc -l
# Output: 29746

# Find files between 100KB and 5MB
sudo find / -type f -size +100k -size -5M | wc -l
# Output: 28499

# Find files either less than 100KB OR greater than 5MB
sudo find / -type f -size -100k -o -size +5M | wc -l
```

---

## Section 2: Find Command - Part 4

### Using Find with Exec
```bash
# Create directory for copying files
mkdir copy_here

# Count files matching criteria
find / -type f -size +100k -size -5M | wc -l

# Copy files matching criteria (with exec)
find / -type f -size +100k -size -5M -exec cp {} ~/home/imranshaikh/Training_plan/Linux/Day_3/Commands/copy_here \;

# Limit search depth for better performance
find / -maxdepth 3 -type f -size +100k -size -5M -exec cp {} ~/home/imranshaikh/Training_plan/Linux/Day_3/Commands/copy_here \;
```

---

## Section 3: Find Command - Part 5 (Needle in Haystack)

### Creating Test Environment
```bash
# Create large directory structure
mkdir haystack
mkdir haystack/folder{1..200}
touch haystack/folder{1..200}/file{1..100}

# Create needle.txt in random folder
touch haystack/folder$(shuf -i 1-200 -n 1)/needle.txt
```

### Finding and Moving the Needle
```bash
# Use locate command (faster but requires updatedb)
locate needle.txt
# Output: /home/imranshaikh/Training_plan/Linux/Day_3/Commands/haystack/folder195/needle.txt

# Use find command
find haystack/ -type f -name "needle.txt"
# Output: haystack/folder195/needle.txt

# Find and move the needle
find haystack/ -type f -name "needle.txt" -exec mv {} /home/imranshaikh/Downloads \;
```

**Find Command Summary:**
- Can execute sophisticated search tasks
- Search by `-name`, `-type`, `-size` and many more options (see man page)
- Use `-exec` option to execute commands on each result
- Always end `-exec` commands with `\;`

---

## Section 4: Viewing Files - Part 1

### Basic File Concatenation
```bash
# View multiple files
cat file1.txt file2.txt file3.txt file4.txt file5.txt
# Output:
# Hello
# there
# you
# Beautiful
# People

# Combine files into one
cat file1.txt file2.txt file3.txt file4.txt file5.txt > beautiful.txt
cat file[1-5].txt > beautiful.txt

# Append content to file
echo "abc" >> alpha.txt
echo "def" >> alpha.txt
echo "ghi" >> alpha.txt
```

### Reversing File Content
```bash
# Reverse lines vertically (tac = cat backwards)
tac alpha.txt
# Output:
# ghi
# def
# abc

# Reverse entire file content and save
cat file[1-5].txt | tac
# Output:
# People
# Beautiful
# you
# there
# Hello

cat file[1-5].txt | tac > reversed.txt

# Reverse characters horizontally
cat file[1-5].txt | rev
# Output:
# olleH
# ereht
# uoy
# lufituaeB
# elpoeP
```

---

## Section 5: Viewing Files - Part 2

### Paging and Partial Content
```bash
# Page through large files
less /etc/cups/cups-browsed.conf
cat /etc/cups/cups-browsed.conf | less

# View first few lines
cat file[1-5].txt | head
cat file[1-5].txt | head -n 5

# Count lines in head output
find | head -n 5
head -n 20 /etc/cups/cups-browsed.conf | wc -l

# View last few lines
cat file[1-5].txt | tail -n 2
tail -n 20 /etc/cups/cups-browsed.conf | wc -l

# Extract middle content (combine head and tail)
head -n 20 /etc/cups/cups-browsed.conf | tail -n 2

# Export results
find | tail -n 1
find | tail -n 3 > ~/Desktop/export.txt
```

**File Viewing Summary:**
- Join files together using `cat` command
- Reverse file vertically using `tac` command
- Reverse files horizontally using `rev` command
- Use `less` to page through large amounts of output
- Use `head` and `tail` commands to extract specific portions

---

## Section 6: Sorting Data - Part 1

### Basic Sorting
```bash
# Sort alphabetically (a-z)
sort words.txt > sorted.txt

# Sort in reverse (z-a)
sort words.txt | tac
sort -r words.txt
sort -r words.txt | less

# Numerical sorting
sort numbers.txt | less          # Sorts by 1st digit (lexicographic)
sort -n numbers.txt | less       # Sorts by actual number value
sort -nr numbers.txt | less      # Numerical reverse sort

# Unique sorting (removes duplicates)
sort numbers0-9.txt | less
sort -u numbers0-9.txt | less
# Output:
# 0
# 1
# 2
# 3
# 4
# 5
# 6
# 7
# 8
# 9

# Unique reverse sort
sort -ur numbers0-9.txt
# Output:
# 9
# 8
# 7
# 6
# 5
# 4
# 3
# 2
# 1
# 0
```

**Basic Sorting Summary:**
- Sort data using the `sort` command
- Sort command defaults to "smallest first" (a-z, 0-9 etc)
- Reverse sorting using `-r` option
- Sort numerically using `-n` option
- Get unique results using `-u` option

---

## Section 7: Sorting Data - Part 2 (Column-based Sorting)

### Advanced Sorting with Columns
```bash
# Basic directory listing
ls -l /etc/ | head -n 20

# Sort by file size (5th column, numerically)
ls -l /etc/ | head -n 20 | sort -k 5n
# Output shows files sorted by size (smallest first)

# Sort by file size in reverse
ls -l /etc/ | head -n 20 | sort -k 5nr

# Sort human-readable sizes
ls -l /etc/ | head -n 20 | sort -k 5hr

# Sort by month (6th column)
ls -l /etc/ | head -n 20 | sort -k 6M
ls -l /etc/ | head -n 20 | sort -k 6Mr    # Reverse month order

# Sort by link count (2nd column)
ls -l /etc/ | head -n 20 | sort -k 2n
ls -l /etc/ | head -n 20 | sort -k 2nr
```

**Column Sorting Summary:**
- Sort tabular data using the `-k` option
- Need to give the `-k` option a KEYDEF
- `3nr` means sort using column 3, with `-n` and `-r` options
- Use `-h` option for human-readable data, not `-n`
- Use `-M` option for month data
- Order of options in KEYDEF doesn't matter

---

## Section 8: File Archiving and Compression - Part 1

### TAR Archives
```bash
# Create tar file of 3 files
tar -cvf ourarchive.tar file[1-3].txt

# List tar files
ls -l | grep .tar

# Check contents of tar file
tar -tf ourarchive.tar

# Extract tar file
tar -xvf ourarchive.tar
```

---

## Section 9: File Archiving and Compression - Part 2

### Compression Methods
```bash
# GZIP compression (faster but less compression power)
gzip ourarchive.tar
file ourarchive.tar.gz    # Shows file size and type
gunzip ourarchive.tar.gz

# BZIP2 compression (smaller size than gzip but requires more computational time)
bzip2 ourarchive.tar
ls -l
file ourarchive.tar.bz2   # Shows file size and type
bunzip2 ourarchive.tar.bz2

# ZIP compression
zip ourthing.zip file1.txt file2.txt file3.txt
file ourthing.zip
unzip ourthing.zip
```

---

## Section 10: Project Tasks

### Task 1: Secret Directory
```bash
mkdir super_secret_stuff
echo "This is my secret content!" > super_secret_stuff/top_secret.txt
sudo updatedb
locate super_secret_stuff > secret_place.txt
```

### Task 2: Large File Analysis
```bash
# Part A & B: Find large files and sort by size
sudo find / -maxdepth 4 -type f -size +1M -exec ls -lh {} \; | sort -k 5 -h
```

---

## Section 11: Task Automation and Scheduling

### Shell Scripts
```bash
# Create automation script
nano our_script.sh
```

**Script 1: Magic Directory Creator**
```bash
#!/bin/bash
mkdir -p ~/Training_plan/Linux/Day_3/Commands/magic
cd ~/Training_plan/Linux/Day_3/Commands/magic
touch file{1..20}
ls -lh ~/Training_plan/Linux/Day_3/Commands/magic > ~/Training_plan/Linux/Day_3/Commands/magic/magic.log
```

**Script 2: Backup Script**
```bash
#!/bin/bash
tar -cvf backup.tar.gz ~/{Documents,Downloads,Desktop,Pictures,Videos} 2>/dev/null
```

### Cron Job Scheduling

**Cron Format:**
```
minute hour day month day_of_week
```

#### Task 1: Create Hungry Script
```bash
nano hungry.sh
```

```bash
#!/bin/bash
echo "I am hungry. Feed me data." >> /home/imranshaikh/Training_plan/Linux/Day_3/Commands/demands.txt
date >> /home/imranshaikh/Training_plan/Linux/Day_3/Commands/demands.log
```

**Test the script:**
```bash
cat demands.log
# Output: Tue Aug 19 04:46:23 PM IST 2025

cat demands.txt
# Output: I am hungry. Feed me data.
```

#### Task 2: Schedule with Cron
```bash
# Edit crontab
crontab -e

# Add this line to run every minute
* * * * * /home/imranshaikh/Training_plan/Linux/Day_3/Commands/hungry.sh
```

**Verify cron job execution:**
```bash
cat demands.log
# Output:
# Tue Aug 19 04:46:23 PM IST 2025
# Tuesday 19 August 2025 04:54:01 PM IST
# Tuesday 19 August 2025 04:55:01 PM IST
# Tuesday 19 August 2025 04:56:01 PM IST
# Tuesday 19 August 2025 04:57:01 PM IST
# Tuesday 19 August 2025 04:58:01 PM IST
# Tuesday 19 August 2025 04:59:01 PM IST
# Tuesday 19 August 2025 05:00:01 PM IST
# Tuesday 19 August 2025 05:01:01 PM IST
# Tuesday 19 August 2025 05:02:01 PM IST
# Tuesday 19 August 2025 05:03:01 PM IST
# Tuesday 19 August 2025 05:04:01 PM IST

cat demands.txt
# Output:
# I am hungry. Feed me data.
# I am hungry. Feed me data.
# I am hungry. Feed me data.
# I am hungry. Feed me data.
# I am hungry. Feed me data.
# I am hungry. Feed me data.
# I am hungry. Feed me data.
# I am hungry. Feed me data.
# I am hungry. Feed me data.
# I am hungry. Feed me data.
# I am hungry. Feed me data.
# I am hungry. Feed me data.
```

---

## Daily Practice Summary

### Commands Mastered Today:
1. **find** - Advanced file searching with multiple criteria
2. **cat/tac/rev** - File viewing and content manipulation
3. **head/tail/less** - Partial file viewing and paging
4. **sort** - Data sorting with column-based options
5. **tar/gzip/bzip2/zip** - File archiving and compression
6. **crontab** - Task scheduling and automation

### Key Learnings:
- Find command is extremely powerful for file system searches
- Compression methods have different speed vs. size trade-offs
- Column-based sorting requires understanding of KEYDEF format
- Cron jobs need full paths and proper permissions
- Shell scripts enable powerful automation workflows

**Difficulty Level**: Advanced
**Next Focus**: Text processing and regular expressions
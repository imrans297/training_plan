# Linux Day 2 - Hands-on Practice Log

## Date: Mon Aug 18, 2025

---

## Section 1: Piping Fundamentals

### Basic Piping with cut command
```bash
# Get current date
date
# Output: Mon Aug 18 11:13:32 AM IST 2025

# Using cut with input redirection
cut < date.txt --delimiter " " --fields 1
# Output: Mon

# Piping date to cut command
date | cut --delimiter " " --fields 1  # Mon
date | cut --delimiter " " --fields 2  # Aug  
date | cut --delimiter " " --fields 3  # 18

# Redirecting output to file
date | cut --delimiter " " --fields 3 > today.txt
cat today.txt  # 18

# Appending to file
date >> date.txt
cat date.txt
# Mon Aug 18 11:14:13 AM IST 2025
# Mon Aug 18 11:34:47 AM IST 2025
```

### Piping with tee command
```bash
# tee saves to file AND passes to next command
date | tee fulldate.txt | cut --delimiter=" " --field=1
# Output: Mon

cat fulldate.txt
# Mon Aug 18 11:44:44 AM IST 2025

# Combining tee with output redirection
date | tee fulldate.txt | cut --delimiter=" " --field=1 > today.txt
cat today.txt  # Mon
```

### Piping with xargs command
```bash
# xargs passes input as arguments
date | xargs echo
# Mon Aug 18 11:50:11 AM IST 2025

date | xargs echo "hello"
# hello Mon Aug 18 11:50:35 AM IST 2025

# This won't work (echo doesn't read from stdin)
date | cut --delimiter=" " --field=1 | echo

# This works (xargs converts stdin to arguments)
date | cut --delimiter=" " --field=1 | xargs echo
# Mon

# Practical example: delete files listed in a text file
echo -e "fulldate.txt\ntoday.txt" > deleteme.txt
cat deleteme.txt | xargs rm
```

### Assignment Solutions
```bash
# Task 1: List directories and save to files
ls -l /etc/ > file1.txt
ls -l /run/ > file2.txt

# Task 2: Combine, save unsorted copy, and create reversed sorted file
cat file1.txt file2.txt | tee unsorted.txt | sort -r > reversed.txt
```

---

## Section 2: Linux File System Navigation

### Basic Navigation Commands
```bash
# Current directory
pwd

# List files
ls
ls -F          # Show file types with indicators
ls -l          # Long format (detailed)
ls -lh         # Human readable sizes
ls -a          # Show hidden files

# Change directory
cd             # Go to home
cd /           # Go to root
cd ..          # Go up one level
cd .           # Stay in current directory
```

### Path Types
- **Absolute path**: Starts from root (/) - `/home/user/file.txt`
- **Relative path**: Starts from current directory - `./file.txt` or `../folder/`
- **Special directories**: `.` (current), `..` (parent)

### File Type Detection
```bash
# Check file type
file image-1.png
# Output: PNG image data, 963 x 363, 8-bit/color RGBA, non-interlaced
```

---

## Section 3: Wildcards and Pattern Matching

### Wildcard Characters
```bash
# * matches any characters
ls *           # All files
ls *.txt       # All .txt files

# ? matches single character
ls ?.txt       # Single character + .txt
ls file?.txt   # file + single char + .txt

# [] matches character ranges
ls file[0-9].txt      # file + digit + .txt
ls file[a-z].txt      # file + lowercase letter + .txt
ls file[A-Z].txt      # file + uppercase letter + .txt
ls file[0-9][A-Z][a-z].txt  # Complex pattern
```

---

## Section 4: Creating Files and Directories

### Basic Creation
```bash
# Create empty file
touch file1.txt

# Create file with content
echo "hello" > file1.txt

# Create directories
mkdir folder
mkdir ~/pictures/folder
mkdir -p abc/folder/one    # Create parent directories
```

### Bulk Creation with Brace Expansion
```bash
# Create multiple directories
mkdir {jan,feb,march,april,may,june,july,august,sept,nov,dec}_{2017..2022}

# Create multiple files
touch file{A..D}.txt
touch file{A,B,C,D}.txt

# Complex bulk creation
touch {jan,feb,march}_{2017..2022}/file{1..50}
```

---

## Section 5: Deleting Files and Directories

### File Deletion
```bash
# Delete single file
rm file1.txt

# Delete multiple files
rm file1.txt file2.txt file3.txt

# Delete with patterns
rm file*       # All files starting with 'file'
rm *.txt       # All .txt files
rm *[2,3]*     # Files containing 2 or 3
```

### Directory Deletion
```bash
# Delete empty directory
rmdir folder

# Delete directory and contents recursively
rm -r folder/

# Interactive deletion (asks for confirmation)
rm -ri folder/

# Example: rmdir fails on non-empty directories
mkdir -p delfolder/folder{1..3}
touch delfolder/folder{1,2}/file{1..10}
rmdir delfolder/*  # This will fail - directories not empty
```

---

## Section 6: Copying Files and Directories

### Basic Copying
```bash
# Copy file to new location
cp filea.txt /home/imranshaikh/Training_plan/Linux/Day_2/

# Copy and rename
cp filea.txt fileb.txt

# Copy multiple files to directory
cp filea.txt fileb.txt filec.txt destination/

# Copy all files from directory
cp destination/* .

# Copy directories recursively
cp -r source_folder/ destination_folder/
```

---

## Section 7: Moving and Renaming

### Move/Rename Operations
```bash
# Rename file
mv oldname.txt newname.txt

# Rename directory
mv oldfolder/ newfolder/

# Move files to directory
mv file* newfolder/

# Move all files from directory
mv newfolder/* .

# Move directory to different location
mv newfolder/ ~/Documents/
mv ~/Documents/newfolder/ ./jackpot
```

---

## Daily Practice Notes
- **Tab completion** is very useful for long paths
- Always use `ls -la` to see hidden files and permissions
- Use `man command` to get help for any command
- Practice with small test files before working on important data
- Remember: `rm` is permanent - no recycle bin in Linux!

---

## Today's Key Learnings
1. Piping allows chaining commands efficiently
2. `tee` is useful when you need both file output and pipeline continuation
3. `xargs` converts stdin to command arguments
4. Wildcards make bulk operations much easier
5. Always be careful with `rm` - especially `rm -r`

**Practice Time**: Approximately 2-3 hours
**Difficulty Level**: Intermediate
**Next Focus**: Advanced file permissions and text processing

---

## Quick Reference Commands
```bash
# Piping essentials
command1 | command2           # Basic pipe
command | tee file.txt        # Save and continue pipeline
command | xargs other_cmd     # Convert stdin to arguments

# Navigation
pwd                          # Current directory
ls -la                       # List all files with details
cd /path/to/directory        # Change directory

# File operations
touch filename               # Create empty file
mkdir -p path/to/dir        # Create directory tree
cp -r source/ dest/         # Copy recursively
mv source dest              # Move/rename
rm -r directory/            # Delete recursively

# Wildcards
*                           # Match any characters
?                           # Match single character
[0-9]                       # Match digit range
{a,b,c}                     # Brace expansion
```
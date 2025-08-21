# Linux Day 4 - Package Management & Virtual Machine Setup

## Date: Aug 20, 2025

---

## Section 1: Master Level 5 - Mastering Open Source Software

### Understanding GNU and Open Source
- **GNU Project**: Free software foundation providing core Linux utilities
- **Open Source Philosophy**: Source code freely available for modification and distribution
- **GPL License**: GNU General Public License ensuring software freedom
- **Community Development**: Collaborative software development model

---

## Section 2: Compiling Software from Source Code

### Source Code Compilation Process
```bash
# Typical compilation workflow
wget https://example.com/software-1.0.tar.gz
tar -xzf software-1.0.tar.gz
cd software-1.0/

# Configure, compile, and install
./configure
make
sudo make install

# Check dependencies
./configure --help
make clean          # Clean previous builds
```

### Build Tools Required
```bash
# Install build essentials
sudo apt update
sudo apt install build-essential
sudo apt install gcc g++ make cmake

# Development libraries
sudo apt install libssl-dev
sudo apt install zlib1g-dev
```

**Benefits of Source Compilation:**
- Latest features and bug fixes
- Custom configuration options
- Optimized for specific hardware
- Learning opportunity

**Drawbacks:**
- Time-consuming process
- Dependency management complexity
- No automatic updates
- Potential compilation errors

---

## Section 3: Package Management Systems

### Understanding Packages
- **Binary Packages**: Pre-compiled software ready for installation
- **Package Dependencies**: Required libraries and components
- **Package Repositories**: Centralized software distribution points
- **Package Managers**: Tools for installing, updating, and removing software

### APT (Advanced Package Tool)
```bash
# APT is the primary package manager for Debian/Ubuntu systems
# Handles dependencies automatically
# Maintains package database
# Provides security updates
```

---

## Section 4: The APT Cache

### APT Cache Operations
```bash
# Search for packages
apt-cache search docx
apt-cache search docx | grep text

# Show package information
apt-cache show docxtxt | less
apt-cache show firefox
apt-cache show vim

# Show package dependencies
apt-cache depends firefox
apt-cache rdepends firefox    # Reverse dependencies

# Search by description
apt-cache search "text editor"
apt-cache search "web browser"

# Package statistics
apt-cache stats
apt-cache pkgnames | wc -l    # Count available packages
```

### Cache Management
```bash
# Update package cache
sudo apt update

# Show package versions
apt-cache policy firefox
apt-cache policy vim

# Search installed packages
apt list --installed
apt list --installed | grep firefox
```

---

## Section 5: Updating Cache and Upgrading Software

### System Updates
```bash
# Update package cache (fetch latest package information)
sudo apt update

# Upgrade installed packages
sudo apt upgrade              # Safe upgrade (no removals)
sudo apt full-upgrade         # Complete upgrade (may remove packages)
sudo apt dist-upgrade         # Distribution upgrade

# Update and upgrade in one command
sudo apt update && sudo apt upgrade

# Check for upgradeable packages
apt list --upgradable
```

### Security Updates
```bash
# Install security updates only
sudo apt upgrade -s           # Simulate upgrade
sudo unattended-upgrade       # Automatic security updates

# Check update history
cat /var/log/apt/history.log
cat /var/log/apt/term.log
```

---

## Section 6: Installing New Software

### Package Installation
```bash
# Install single package
sudo apt install firefox
sudo apt install vim
sudo apt install git

# Install multiple packages
sudo apt install curl wget htop tree

# Install with specific version
sudo apt install firefox=85.0+build1-0ubuntu1

# Install from .deb file
sudo dpkg -i package.deb
sudo apt install -f           # Fix dependencies

# Install recommended packages
sudo apt install --install-recommends package-name
sudo apt install --no-install-recommends package-name
```

### Installation Options
```bash
# Simulate installation (dry run)
sudo apt install -s firefox

# Download package without installing
apt download firefox
sudo apt install --download-only firefox

# Reinstall package
sudo apt install --reinstall firefox

# Install from different repository
sudo apt install -t repository-name package-name
```

---

## Section 7: Downloading Source Code

### Source Package Management
```bash
# Enable source repositories in /etc/apt/sources.list
# Uncomment deb-src lines

# Update cache for source packages
sudo apt update

# Download source code
apt source firefox
apt source vim

# Download source with dependencies
sudo apt build-dep firefox
apt source --compile firefox

# Get source package information
apt-cache showsrc firefox
```

### Building from Source
```bash
# Install build dependencies
sudo apt build-dep package-name

# Download and build
apt source package-name
cd package-directory/
dpkg-buildpackage -us -uc

# Install built package
sudo dpkg -i ../package.deb
```

---

## Section 8: Uninstalling Software

### Package Removal Methods
```bash
# Remove package (keep configuration files)
sudo apt remove firefox

# Purge package (remove everything including config files)
sudo apt purge firefox
sudo apt remove --purge firefox

# Remove package and unused dependencies
sudo apt autoremove firefox
sudo apt autoremove --purge firefox

# Remove orphaned packages
sudo apt autoremove
sudo apt autoclean           # Remove old package files
sudo apt clean              # Remove all package files from cache
```

### Advanced Removal Operations
```bash
# List packages for removal
apt list --installed | grep firefox

# Remove multiple packages
sudo apt remove firefox thunderbird libreoffice

# Simulate removal
sudo apt remove -s firefox

# Force removal (dangerous)
sudo dpkg --remove --force-depends package-name
```

### Package Status Check
```bash
# Check package status
dpkg -l | grep firefox
dpkg -s firefox

# List files installed by package
dpkg -L firefox

# Find which package owns a file
dpkg -S /usr/bin/firefox
```

---

## Section 9: Master Level 6 - Advanced Package Management

### Repository Management
```bash
# Add new repository
sudo add-apt-repository ppa:repository-name
sudo add-apt-repository "deb http://repository-url distribution component"

# Remove repository
sudo add-apt-repository --remove ppa:repository-name

# List repositories
cat /etc/apt/sources.list
ls /etc/apt/sources.list.d/

# Repository keys
sudo apt-key list
sudo apt-key add keyfile
```

### Package Pinning and Preferences
```bash
# Create preferences file
sudo nano /etc/apt/preferences.d/package-name

# Example pinning configuration:
# Package: firefox
# Pin: version 85.0*
# Pin-Priority: 1001
```

---

## Section 8: Appendix - Setting up Linux Virtual Machine

### Installing VirtualBox
```bash
# Install VirtualBox on host system
# Download from https://www.virtualbox.org/

# Ubuntu/Debian host installation
sudo apt update
sudo apt install virtualbox
sudo apt install virtualbox-ext-pack

# Add user to vboxusers group
sudo usermod -aG vboxusers $USER

# Verify installation
vboxmanage --version
```

### Setting up Linux Virtual Machine

#### VM Creation Steps:
1. **Create New VM**
   - Name: Linux-Practice
   - Type: Linux
   - Version: Ubuntu (64-bit)
   - Memory: 2048 MB (minimum)
   - Hard disk: Create virtual hard disk (20 GB)

2. **VM Configuration**
   - Processor: 2 CPUs
   - Display: Video Memory 128 MB
   - Network: NAT or Bridged
   - Storage: Attach Ubuntu ISO

3. **Ubuntu Installation**
   - Boot from ISO
   - Choose installation language
   - Select installation type
   - Create user account
   - Complete installation

#### Post-Installation Setup:
```bash
# Update system
sudo apt update && sudo apt upgrade

# Install Guest Additions
sudo apt install build-essential dkms linux-headers-$(uname -r)
# Insert Guest Additions CD from VirtualBox menu
sudo mount /dev/cdrom /mnt
sudo /mnt/VBoxLinuxAdditions.run

# Enable shared folders
sudo usermod -aG vboxsf $USER

# Install essential tools
sudo apt install curl wget git vim htop tree
```

### Installation Troubleshooting

#### Common Issues and Solutions:

**1. Virtualization Not Enabled**
```bash
# Check if virtualization is enabled
grep -E "(vmx|svm)" /proc/cpuinfo

# Enable in BIOS/UEFI:
# - Intel: Enable VT-x
# - AMD: Enable AMD-V
```

**2. Insufficient Resources**
```bash
# Check system resources
free -h                    # Memory
df -h                      # Disk space
nproc                      # CPU cores

# Recommended minimums:
# RAM: 2 GB for VM + 2 GB for host
# Disk: 20 GB for VM
# CPU: 2 cores minimum
```

**3. Boot Issues**
```bash
# Check boot order in VM settings
# Ensure ISO is properly attached
# Verify ISO integrity:
sha256sum ubuntu.iso
```

**4. Network Connectivity**
```bash
# Test network in VM
ping google.com
ip addr show

# Network troubleshooting:
# - Try different network modes (NAT, Bridged, Host-only)
# - Check firewall settings
# - Restart network service
sudo systemctl restart networking
```

**5. Guest Additions Issues**
```bash
# Reinstall Guest Additions
sudo apt remove virtualbox-guest-*
sudo apt autoremove
# Reinsert Guest Additions CD and reinstall

# Manual installation
sudo mount /dev/cdrom /mnt
sudo /mnt/VBoxLinuxAdditions.run --nox11
```

**6. Performance Issues**
```bash
# Optimize VM performance
# - Increase RAM allocation
# - Enable hardware acceleration
# - Disable visual effects in guest OS
# - Use SSD for VM storage

# Check VM resource usage
top
htop
iotop
```

---

## Daily Practice Summary

### Commands Mastered Today:
1. **apt-cache** - Package search and information
2. **apt update/upgrade** - System maintenance
3. **apt install/remove** - Package management
4. **apt source** - Source code management
5. **dpkg** - Low-level package operations
6. **VirtualBox** - Virtualization setup

### Key Concepts Learned:
- Open source software ecosystem
- Package dependency management
- Source code compilation process
- Virtual machine configuration
- System maintenance workflows

### Practical Skills Developed:
- Software installation from multiple sources
- System update and maintenance
- Troubleshooting installation issues
- Virtual environment setup
- Repository management

**Practice Time**: 3-4 hours
**Difficulty Level**: Intermediate to Advanced
**Next Focus**: System monitoring and process management

---

## Quick Reference Commands
```bash
# Package Management
apt-cache search keyword         # Search packages
apt-cache show package          # Package information
sudo apt update                 # Update package cache
sudo apt upgrade                # Upgrade packages
sudo apt install package        # Install package
sudo apt remove package         # Remove package
sudo apt purge package          # Remove package + config
sudo apt autoremove            # Remove unused packages

# Source Management
apt source package              # Download source
sudo apt build-dep package     # Install build dependencies

# System Information
dpkg -l                        # List installed packages
dpkg -S file                   # Find package owning file
apt list --installed           # List installed packages
apt list --upgradable          # List upgradable packages
```
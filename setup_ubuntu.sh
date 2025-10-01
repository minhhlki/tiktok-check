#!/bin/bash

###############################################################################
# TikTok Statistics Analyzer - Ubuntu VPS Auto Setup Script
# GitHub: https://github.com/minhhlki/tiktok-check
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Banner
echo "============================================================================="
echo "        TikTok Statistics Analyzer - Ubuntu VPS Setup Script"
echo "============================================================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    print_warning "Please don't run as root. Run as normal user with sudo privileges."
    exit 1
fi

# Step 1: Update system
print_step "Updating system packages..."
sudo apt update -qq
sudo apt upgrade -y -qq
print_success "System updated"

# Step 2: Install basic tools
print_step "Installing basic tools (git, curl, vim)..."
sudo apt install -y git curl vim wget software-properties-common > /dev/null 2>&1
print_success "Basic tools installed"

# Step 3: Check Python version
print_step "Checking Python version..."
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
REQUIRED_VERSION="3.8"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" = "$REQUIRED_VERSION" ]; then 
    print_success "Python $PYTHON_VERSION is installed (>= 3.8)"
else
    print_warning "Python version is too old. Installing Python 3.11..."
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt update -qq
    sudo apt install -y python3.11 python3.11-venv python3.11-dev
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
    print_success "Python 3.11 installed"
fi

# Step 4: Install pip
print_step "Installing pip..."
sudo apt install -y python3-pip > /dev/null 2>&1
python3 -m pip install --upgrade pip --quiet
print_success "pip installed"

# Step 5: Install system dependencies for Playwright
print_step "Installing Playwright system dependencies..."
sudo apt install -y \
    libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 \
    libcups2 libdrm2 libdbus-1-3 libxkbcommon0 \
    libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
    libgbm1 libpango-1.0-0 libcairo2 libasound2 \
    libatspi2.0-0 libxshmfence1 > /dev/null 2>&1
print_success "System dependencies installed"

# Step 6: Clone repository
print_step "Checking for tiktok-check directory..."
if [ -d "$HOME/tiktok-check" ]; then
    print_warning "Directory already exists. Pulling latest changes..."
    cd $HOME/tiktok-check
    git pull
else
    print_step "Cloning repository from GitHub..."
    cd $HOME
    git clone https://github.com/minhhlki/tiktok-check.git
    cd tiktok-check
    print_success "Repository cloned"
fi

# Step 7: Create virtual environment
print_step "Creating Python virtual environment..."
if [ -d "venv" ]; then
    print_warning "Virtual environment already exists"
else
    python3 -m venv venv
    print_success "Virtual environment created"
fi

# Step 8: Activate venv and install packages
print_step "Installing Python packages..."
source venv/bin/activate
pip install --upgrade pip --quiet
pip install playwright --quiet
print_success "Playwright installed"

# Step 9: Install browsers
print_step "Installing Chromium browser (this may take a few minutes)..."
playwright install chromium > /dev/null 2>&1
playwright install-deps chromium > /dev/null 2>&1
print_success "Chromium browser installed"

# Step 10: Test installation
print_step "Testing installation..."
if python -c "from playwright.sync_api import sync_playwright" 2>/dev/null; then
    print_success "Playwright is working correctly"
else
    print_error "Playwright test failed"
    exit 1
fi

# Step 11: Create helper scripts
print_step "Creating helper scripts..."

# Run script
cat > run_tiktok.sh << 'EOF'
#!/bin/bash
cd ~/tiktok-check
source venv/bin/activate

if [ -z "$1" ]; then
    echo "Usage: ./run_tiktok.sh <tiktok_url> [options]"
    echo "Example: ./run_tiktok.sh https://www.tiktok.com/@username --save-json"
    exit 1
fi

python tiktok_counter.py "$@"
EOF

chmod +x run_tiktok.sh
print_success "Created run_tiktok.sh"

# Improved version script
cat > run_tiktok_improved.sh << 'EOF'
#!/bin/bash
cd ~/tiktok-check
source venv/bin/activate

if [ -z "$1" ]; then
    echo "Usage: ./run_tiktok_improved.sh <tiktok_url> [options]"
    echo "Example: ./run_tiktok_improved.sh https://www.tiktok.com/@username --save"
    exit 1
fi

python tiktok_counter_improved.py "$@"
EOF

chmod +x run_tiktok_improved.sh
print_success "Created run_tiktok_improved.sh"

# Step 12: Setup firewall (optional)
print_step "Do you want to setup UFW firewall? (y/n)"
read -r setup_firewall
if [ "$setup_firewall" = "y" ]; then
    sudo ufw allow ssh
    sudo ufw --force enable
    print_success "Firewall configured (SSH allowed)"
fi

# Step 13: Create swap if needed (for low RAM VPS)
TOTAL_RAM=$(free -m | awk 'NR==2{print $2}')
if [ "$TOTAL_RAM" -lt 2048 ]; then
    print_warning "Detected low RAM ($TOTAL_RAM MB). Creating 2GB swap file..."
    if [ ! -f /swapfile ]; then
        sudo fallocate -l 2G /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile > /dev/null 2>&1
        sudo swapon /swapfile
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null
        print_success "Swap file created (2GB)"
    else
        print_warning "Swap file already exists"
    fi
fi

# Final instructions
echo ""
echo "============================================================================="
echo -e "${GREEN}✅ INSTALLATION COMPLETED SUCCESSFULLY!${NC}"
echo "============================================================================="
echo ""
echo "📍 Project location: ~/tiktok-check"
echo ""
echo "🚀 Quick start:"
echo ""
echo "   # Activate virtual environment:"
echo "   cd ~/tiktok-check && source venv/bin/activate"
echo ""
echo "   # Run tool (regular version):"
echo "   python tiktok_counter.py https://www.tiktok.com/@username --save-json"
echo ""
echo "   # Run tool (improved version - more accurate):"
echo "   python tiktok_counter_improved.py https://www.tiktok.com/@username --save"
echo ""
echo "   # Or use helper scripts:"
echo "   ./run_tiktok.sh https://www.tiktok.com/@username --save-json --save-csv"
echo "   ./run_tiktok_improved.sh https://www.tiktok.com/@username --save"
echo ""
echo "📚 Documentation:"
echo "   - README.md - Full documentation"
echo "   - HUONG_DAN.txt - Vietnamese quick guide"
echo "   - SETUP_VPS_UBUNTU.md - Detailed VPS setup guide"
echo "   - FIX_VIEW_ACCURACY.md - View accuracy explanation"
echo ""
echo "⚠️  Important notes:"
echo "   - Always activate venv before running: source venv/bin/activate"
echo "   - Use improved version for better accuracy"
echo "   - Don't run too frequently to avoid being blocked by TikTok"
echo ""
echo "🎉 Happy analyzing!"
echo "============================================================================="


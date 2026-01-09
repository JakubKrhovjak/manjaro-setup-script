#!/bin/bash

set -e

echo "=================================="
echo "Dev Tools Installation for Manjaro"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

# Update system
print_info "Updating system packages..."
sudo pacman -Syu --noconfirm

# Install base dependencies
print_info "Installing base dependencies..."
sudo pacman -S --needed --noconfirm base-devel curl wget zip unzip

# Install Git
print_info "Installing Git..."
sudo pacman -S --needed --noconfirm git
print_status "Git installed: $(git --version)"

# Install Docker
print_info "Installing Docker..."
sudo pacman -S --needed --noconfirm docker docker-compose
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
print_status "Docker installed: $(docker --version)"
print_info "You may need to log out and back in for Docker group permissions to take effect"

# Install Go
print_info "Installing Go..."
sudo pacman -S --needed --noconfirm go
print_status "Go installed: $(go version)"

# Install Terraform
print_info "Installing Terraform..."
sudo pacman -S --needed --noconfirm terraform
print_status "Terraform installed: $(terraform --version | head -n1)"

# Install SDKMAN
print_info "Installing SDKMAN..."
if [ ! -d "$HOME/.sdkman" ]; then
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    print_status "SDKMAN installed"
else
    print_status "SDKMAN already installed"
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# Install Java 21 via SDKMAN
print_info "Installing Java 21 via SDKMAN..."
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21.0.1-tem || true
sdk default java 21.0.1-tem
print_status "Java installed: $(java -version 2>&1 | head -n1)"

# Install Maven via SDKMAN
print_info "Installing Maven via SDKMAN..."
sdk install maven || true
print_status "Maven installed: $(mvn --version | head -n1)"

# Install NVM
print_info "Installing NVM..."
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    print_status "NVM installed"
else
    print_status "NVM already installed"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# Install Node.js 21 via NVM
print_info "Installing Node.js 21 via NVM..."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 21
nvm use 21
nvm alias default 21
print_status "Node.js installed: $(node --version)"
print_status "npm installed: $(npm --version)"

# Install Kind (Kubernetes in Docker)
print_info "Installing Kind..."
if ! command -v kind &> /dev/null; then
    KIND_VERSION="v0.20.0"
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    print_status "Kind installed: $(kind --version)"
else
    print_status "Kind already installed: $(kind --version)"
fi

# Install kubectl (for working with Kind clusters)
print_info "Installing kubectl..."
sudo pacman -S --needed --noconfirm kubectl
print_status "kubectl installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"

# Install Google Cloud SDK
print_info "Installing Google Cloud SDK..."
if ! command -v gcloud &> /dev/null; then
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
    tar -xf google-cloud-cli-linux-x86_64.tar.gz
    ./google-cloud-sdk/install.sh --quiet --usage-reporting=false --path-update=true --command-completion=true
    rm google-cloud-cli-linux-x86_64.tar.gz
    source "$HOME/.bashrc" 2>/dev/null || true
    print_status "Google Cloud SDK installed: $(gcloud --version | head -n1)"
else
    print_status "Google Cloud SDK already installed: $(gcloud --version | head -n1)"
fi

# Install GKE gcloud auth plugin
print_info "Installing GKE gcloud auth plugin..."
gcloud components install gke-gcloud-auth-plugin --quiet
print_status "GKE auth plugin installed"

# Install yay (AUR helper) if not present
print_info "Checking for yay (AUR helper)..."
if ! command -v yay &> /dev/null; then
    print_info "Installing yay..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    print_status "yay installed"
else
    print_status "yay already installed"
fi

# Install JetBrains Toolbox
print_info "Installing JetBrains Toolbox..."
if ! command -v jetbrains-toolbox &> /dev/null; then
    yay -S --needed --noconfirm jetbrains-toolbox
    print_status "JetBrains Toolbox installed"
    print_info "Launch Toolbox from your applications menu to install IntelliJ IDEA, GoLand, or other JetBrains IDEs"
else
    print_status "JetBrains Toolbox already installed"
fi

echo ""
echo "=================================="
print_status "Installation Complete!"
echo "=================================="
echo ""
echo "Installed tools:"
echo "  - Git: $(git --version)"
echo "  - Docker: $(docker --version)"
echo "  - Go: $(go version)"
echo "  - Terraform: $(terraform --version | head -n1)"
echo "  - SDKMAN: Installed at ~/.sdkman"
echo "  - Java: $(source ~/.sdkman/bin/sdkman-init.sh && java -version 2>&1 | head -n1)"
echo "  - Maven: $(source ~/.sdkman/bin/sdkman-init.sh && mvn --version | head -n1)"
echo "  - NVM: Installed at ~/.nvm"
echo "  - Node.js: $(source ~/.nvm/nvm.sh && node --version)"
echo "  - npm: $(source ~/.nvm/nvm.sh && npm --version)"
echo "  - Kind: $(kind --version)"
echo "  - kubectl: $(kubectl version --client --short 2>/dev/null || echo 'installed')"
echo "  - Google Cloud SDK: $(gcloud --version | head -n1)"
echo "  - GKE auth plugin: installed"
echo "  - yay: AUR helper"
echo "  - JetBrains Toolbox: installed"
echo ""
print_info "IMPORTANT: Please run the following command or restart your terminal:"
echo "  source ~/.bashrc"
echo ""
print_info "If you use zsh, also run:"
echo "  source ~/.zshrc"
echo ""
print_info "For Docker permissions to take effect, log out and back in."
echo ""
print_info "To install IntelliJ IDEA or GoLand:"
echo "  1. Launch JetBrains Toolbox from your applications menu"
echo "  2. Sign in with your JetBrains account"
echo "  3. Install IntelliJ IDEA Ultimate and/or GoLand from the Toolbox"
# Dev Tools Installation Script for Manjaro

Automated installation script for setting up a development environment on Manjaro Linux.

## Overview

This script automatically installs and configures a complete set of development tools for working with various technologies including Java, Node.js, Go, Docker, Kubernetes, and cloud tools.

## Installed Tools

### Core Tools
- **Git** - version control system
- **Base Development Tools** - `base-devel`, curl, wget, zip, unzip

### Containerization
- **Docker** - platform for containerizing applications
- **Docker Compose** - tool for defining multi-container Docker applications

### Programming Languages & Runtimes
- **Go** - programming language
- **Java 21** - installed via SDKMAN (Temurin distribution)
- **Node.js 21** - installed via NVM

### Build Tools & Package Managers
- **Maven** - build tool for Java projects (via SDKMAN)
- **npm** - package manager for Node.js (part of Node.js)
- **SDKMAN** - SDK manager for Java ecosystem
- **NVM** - Node Version Manager

### Infrastructure as Code
- **Terraform** - tool for managing infrastructure as code

### Kubernetes
- **kubectl** - CLI for working with Kubernetes clusters
- **Kind** - Kubernetes in Docker (local Kubernetes clusters)

### Cloud Tools
- **Google Cloud SDK (gcloud)** - CLI for Google Cloud Platform
- **GKE gcloud auth plugin** - plugin for kubectl authentication with GKE clusters

## Requirements

- Manjaro Linux or Arch-based distribution
- Sudo privileges
- Internet connection

## Installation

1. Download the script:
```bash
git clone <repository-url>
cd setup-script
```

2. Set execution permissions:
```bash
chmod +x setup-script.sh
```

3. Run the script:
```bash
./setup-script.sh
```

## Post-Installation

### Restart Shell
To load all environment changes, run:
```bash
source ~/.bashrc
```

If you use zsh:
```bash
source ~/.zshrc
```

Or restart your terminal.

### Docker Permissions
To activate Docker permissions, log out and log back in to your system.

### Verify Installation
Check versions of installed tools:
```bash
git --version
docker --version
go version
terraform --version
java -version
mvn --version
node --version
npm --version
kubectl version --client
kind --version
gcloud --version
```

## Configuring SDKMAN and NVM

### SDKMAN
SDKMAN is installed in `~/.sdkman/`. To manage Java versions:
```bash
sdk list java          # List available Java versions
sdk install java <version>
sdk use java <version>
sdk default java <version>
```

### NVM
NVM is installed in `~/.nvm/`. To manage Node.js versions:
```bash
nvm list               # List installed versions
nvm install <version>  # Install another version
nvm use <version>      # Use specific version
nvm alias default <version>
```

## Google Cloud SDK

After installation, you need to initialize:
```bash
gcloud init
```

To login to GCP:
```bash
gcloud auth login
```

To configure kubectl with GKE:
```bash
gcloud container clusters get-credentials <cluster-name> --region=<region>
```

## Notes

- The script checks if tools are already installed and skips their installation
- All tools are installed with the latest stable versions
- The script uses `set -e`, which means it stops at the first error
- Docker requires sudo privileges for service management
- The user is automatically added to the Docker group

## Uninstallation

To uninstall individual tools:

```bash
# SDKMAN
rm -rf ~/.sdkman

# NVM
rm -rf ~/.nvm

# Google Cloud SDK
rm -rf ~/google-cloud-sdk

# Other tools via pacman
sudo pacman -R git docker docker-compose go terraform kubectl
```

## Support

If you encounter problems:
1. Check that you have an up-to-date Manjaro Linux
2. Verify internet connection
3. Check sudo privileges
4. Look at the script output for error details

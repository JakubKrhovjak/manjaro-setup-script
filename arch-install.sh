#!/bin/bash

# Minimal Arch Linux Installation Script
# Run from Arch ISO live environment
# Usage: bash arch-install.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${CYAN}[>]${NC} $1"; }
ok()      { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
die()     { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# ── Sanity checks ──────────────────────────────────────────────────────────────
[ "$(id -u)" -eq 0 ] || die "Run as root (from Arch ISO)"
ping -c1 archlinux.org &>/dev/null || die "No internet connection"

# ── Config ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}══════════════════════════════════════${NC}"
echo -e "${CYAN}   Minimal Arch Linux Installer       ${NC}"
echo -e "${CYAN}══════════════════════════════════════${NC}"
echo ""

# List available disks
lsblk -d -o NAME,SIZE,TYPE | grep disk
echo ""

read -rp "Target disk (e.g. sda, nvme0n1): " DISK
DISK="/dev/${DISK}"
[ -b "$DISK" ] || die "Disk $DISK not found"

read -rp "Hostname: " HOSTNAME
read -rp "Username: " USERNAME
read -rsp "User password: " USER_PASS; echo
read -rsp "Root password: " ROOT_PASS; echo
read -rp "Timezone [Europe/Prague]: " TIMEZONE
TIMEZONE="${TIMEZONE:-Europe/Prague}"

read -rp "Locale [en_US.UTF-8]: " LOCALE
LOCALE="${LOCALE:-en_US.UTF-8}"
read -rp "Console keymap (e.g. cz, cz-qwerty) [cz]: " KEYMAP
KEYMAP="${KEYMAP:-cz}"


read -rp "Data disk to mount at /data (e.g. sdb, leave blank to skip): " DATA_DISK
if [ -n "$DATA_DISK" ]; then
    DATA_DISK="/dev/${DATA_DISK}"
    [ -b "$DATA_DISK" ] || die "Data disk $DATA_DISK not found"
fi

# Detect UEFI
if [ -d /sys/firmware/efi ]; then
    BOOT_MODE="uefi"
    info "Boot mode: UEFI"
else
    BOOT_MODE="bios"
    info "Boot mode: BIOS/Legacy"
fi

warn "This will ERASE all data on $DISK. Continue? (yes/no)"
read -r CONFIRM
[ "$CONFIRM" = "yes" ] || die "Aborted."

# ── Partitioning ───────────────────────────────────────────────────────────────
info "Partitioning $DISK..."

if [ "$BOOT_MODE" = "uefi" ]; then
    parted -s "$DISK" \
        mklabel gpt \
        mkpart ESP fat32 1MiB 513MiB \
        set 1 esp on \
        mkpart root ext4 513MiB 100%

    # Partition naming: nvme uses p1/p2, sda uses 1/2
    if [[ "$DISK" == *"nvme"* ]]; then
        EFI_PART="${DISK}p1"
        ROOT_PART="${DISK}p2"
    else
        EFI_PART="${DISK}1"
        ROOT_PART="${DISK}2"
    fi

    info "Formatting EFI partition..."
    mkfs.fat -F32 "$EFI_PART"
else
    parted -s "$DISK" \
        mklabel msdos \
        mkpart primary ext4 1MiB 100% \
        set 1 boot on

    if [[ "$DISK" == *"nvme"* ]]; then
        ROOT_PART="${DISK}p1"
    else
        ROOT_PART="${DISK}1"
    fi
fi

info "Formatting root partition..."
mkfs.ext4 -F "$ROOT_PART"

# ── Mounting ───────────────────────────────────────────────────────────────────
info "Mounting partitions..."
mount "$ROOT_PART" /mnt

if [ "$BOOT_MODE" = "uefi" ]; then
    mkdir -p /mnt/boot/efi
    mount "$EFI_PART" /mnt/boot/efi
fi

if [ -n "$DATA_DISK" ]; then
    info "Mounting data disk $DATA_DISK at /data..."
    mkdir -p /mnt/data
    mount "$DATA_DISK" /mnt/data
fi

# ── Base install ───────────────────────────────────────────────────────────────
info "Installing base system (this may take a while)..."
pacstrap -K /mnt \
    base \
    linux \
    linux-firmware \
    base-devel \
    networkmanager \
    networkmanager-wifi \
    iwd \
    iw \
    wireless_tools \
    wpa_supplicant \
    sudo \
    git \
    flatpak \
    vim \
    man-db \
    man-pages \
    \
    terminus-font \
    \
    noto-fonts \
    noto-fonts-extra \
    noto-fonts-emoji \
    noto-fonts-cjk \
    \
    ttf-dejavu \
    ttf-liberation \
    ttf-freefont \
    gnu-free-fonts \
    ttf-linux-libertine \
    ttf-carlito \
    ttf-croscore \
    \
    ttf-hack \
    ttf-fira-code \
    ttf-cascadia-code \
    ttf-jetbrains-mono \
    ttf-inconsolata \
    adobe-source-code-pro-fonts \
    \
    ttf-ubuntu-font-family \
    cantarell-fonts \
    adobe-source-sans-fonts \
    adobe-source-serif-fonts \
    \
    plasma-meta \
    kde-applications-meta \
    sddm \
    xdg-user-dirs \
    mesa \
    libva-mesa-driver \
    vulkan-icd-loader \
    \
    firefox \
    chromium \
    \
    vlc \
    mpv \
    \
    ark \
    p7zip \
    unrar \
    \
    cups \
    system-config-printer \
    \
    bluez \
    bluez-utils \
    bluedevil \
    \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    wireplumber \
    pavucontrol \
    \
    spectacle \
    gwenview \
    okular \
    kate \
    \
    filelight \
    kcalc \
    \
    wget \
    curl \
    htop \
    zip \
    unzip \
    openssh \
    usbutils \
    ntfs-3g \
    exfatprogs \
    \
    zsh \
    zsh-syntax-highlighting \
    zsh-autosuggestions \
    zsh-completions \
    starship \
    \
    \
    hunspell \
    hunspell-cs \
    hunspell-en_us \
    \
    libreoffice-fresh \
    libreoffice-fresh-cs

# ── AMD GPU drivers ─────────────────────────────────────────────────────────────
info "Installing AMD GPU drivers..."
pacstrap -K /mnt \
    xf86-video-amdgpu \
    vulkan-radeon \
    libva-mesa-driver \
    mesa-vdpau \
    radeontop
ok "AMD drivers installed (amdgpu, Vulkan, VA-API, VDPAU)"

# ── fstab ──────────────────────────────────────────────────────────────────────
info "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# ── Chroot configuration ───────────────────────────────────────────────────────
info "Configuring system inside chroot..."

arch-chroot /mnt /bin/bash <<CHROOT
set -e

# Timezone
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc

# Locale — English primary, Czech secondary (both generated, system uses English)
{
    echo "en_US.UTF-8 UTF-8"
    echo "cs_CZ.UTF-8 UTF-8"
} >> /etc/locale.gen
locale-gen
cat > /etc/locale.conf <<EOF
LANG=en_US.UTF-8
LANGUAGE=en_US:cs_CZ
EOF

# Console keymap and font (Terminus looks great at hi-res too)
cat > /etc/vconsole.conf <<EOF
KEYMAP=${KEYMAP}
FONT=ter-132b
EOF

# Hostname
echo "${HOSTNAME}" > /etc/hostname
cat >> /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

# Root password
echo "root:${ROOT_PASS}" | chpasswd

# Create user with zsh as default shell
useradd -m -G wheel -s /usr/bin/zsh "${USERNAME}"
echo "${USERNAME}:${USER_PASS}" | chpasswd

# Setup zsh config
cat > /home/${USERNAME}/.zshrc <<'ZSHRC'
# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

# Autocompletion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Starship prompt
eval "$(starship init zsh)"

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
alias k=kubectl
alias ..='cd ..'
alias ...='cd ../..'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)" 2>/dev/null || true
ZSHRC

chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.zshrc

# Starship config — nice colorful preset
mkdir -p /home/${USERNAME}/.config
cat > /home/${USERNAME}/.config/starship.toml <<'STARSHIP'
format = """
[╭─](bold green)$os$username$hostname$directory$git_branch$git_status$python$nodejs$java$golang
[╰─](bold green)$character"""

[os]
disabled = false
style = "bold blue"

[username]
style_user = "bold yellow"
show_always = true

[hostname]
ssh_only = false
style = "bold cyan"

[directory]
style = "bold cyan"
truncation_length = 4

[git_branch]
style = "bold purple"

[git_status]
style = "bold red"

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
STARSHIP

chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.config

# Set wallpaper (Next — same as Manjaro default, from breeze package)
mkdir -p /home/${USERNAME}/.config
cat > /home/${USERNAME}/.config/plasma-org.kde.plasma.desktop-appletsrc <<'WALLPAPER'
[Containments][1][Wallpaper][org.kde.image][General]
Image=/usr/share/wallpapers/Next/
WALLPAPER
chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.config/plasma-org.kde.plasma.desktop-appletsrc

# Sudo for wheel group
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Pacman tuning — color, parallel downloads, multilib
sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf
sed -i '/^#\[multilib\]/{N;s/#\[multilib\]\n#Include/\[multilib\]\nInclude/}' /etc/pacman.conf
pacman -Sy --noconfirm

# Install yay (AUR helper)
cd /tmp
git clone https://aur.archlinux.org/yay.git
chown -R ${USERNAME}:${USERNAME} /tmp/yay
cd /tmp/yay
sudo -u ${USERNAME} makepkg -si --noconfirm
cd /

# Flatpak — enable Flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Enable services
systemctl enable NetworkManager
systemctl enable iwd
systemctl enable sddm
systemctl enable bluetooth
systemctl enable cups

# Bootloader
CHROOT

# ── Bootloader ─────────────────────────────────────────────────────────────────
if [ "$BOOT_MODE" = "uefi" ]; then
    info "Installing systemd-boot (UEFI)..."
    arch-chroot /mnt bootctl install

    ROOT_UUID=$(blkid -s UUID -o value "$ROOT_PART")

    # Loader config
    cat > /mnt/boot/efi/loader/loader.conf <<EOF
default arch.conf
timeout 3
console-mode max
editor no
EOF

    # Boot entry
    mkdir -p /mnt/boot/efi/loader/entries
    cat > /mnt/boot/efi/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=${ROOT_UUID} rw quiet
EOF

    # Copy kernel + initramfs to EFI partition
    cp /mnt/boot/vmlinuz-linux /mnt/boot/efi/
    cp /mnt/boot/initramfs-linux.img /mnt/boot/efi/
    cp /mnt/boot/initramfs-linux-fallback.img /mnt/boot/efi/

else
    info "Installing GRUB (BIOS)..."
    arch-chroot /mnt pacman -S --needed --noconfirm grub
    arch-chroot /mnt grub-install --target=i386-pc "$DISK"
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
fi

# ── Copy dev setup script to new system ───────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/setup-script.sh" ]; then
    info "Copying setup-script.sh to /home/${USERNAME}/ on new system..."
    cp "$SCRIPT_DIR/setup-script.sh" "/mnt/home/${USERNAME}/setup-script.sh"
    arch-chroot /mnt chown "${USERNAME}:${USERNAME}" "/home/${USERNAME}/setup-script.sh"
    arch-chroot /mnt chmod +x "/home/${USERNAME}/setup-script.sh"
    ok "Dev setup script ready at ~/setup-script.sh — run it after first boot"
else
    warn "setup-script.sh not found next to arch-install.sh, skipping copy"
fi

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}══════════════════════════════════════${NC}"
ok "Installation complete!"
echo -e "${GREEN}══════════════════════════════════════${NC}"
echo ""
echo "  Disk:     $DISK"
echo "  Hostname: $HOSTNAME"
echo "  User:     $USERNAME"
echo "  Boot:     $BOOT_MODE"
echo "  GPU:      AMD (amdgpu, Vulkan, VA-API, VDPAU)"
echo "  Locale:   $LOCALE (+ cs_CZ.UTF-8 for paper/time/measurement)"
echo "  Keymap:   $KEYMAP"
echo "  Fonts:    terminus (TTY), noto (full unicode+CJK+emoji), dejavu, liberation,"
echo "            hack, fira-code, cascadia-code, jetbrains-mono, inconsolata,"
echo "            ubuntu, cantarell, source-sans/serif/code, freefont, libertine"
echo ""
warn "Unmount and reboot:"
echo "  umount -R /mnt && reboot"
echo ""
warn "After first login, run the dev tools setup:"
echo "  bash ~/setup-script.sh"

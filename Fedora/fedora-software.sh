#!/usr/bin/env bash

# ---------------------------------------------------------------------------------
# Purpose - Script to get stuff done in a fedora installation
# Author  - @darchap
# ---------------------------------------------------------------------------------

#VSCODE
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf install -y code

#BRAVE
sudo dnf install dnf-plugins-core
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install -y brave-browser

#GIT
sudo dnf install -y git

#STACER
sudo dnf install -y stacer

#FLATSEAL
flatpak install -y flatseal

#QEMU AND VIRT-MANAGER
sudo dnf group install --with-optional virtualization
sudo systemctl start libvirtd
sudo systemctl enable libvirtd

#YADM
git clone https://github.com/TheLocehiliosan/yadm.git ~/.yadm-project
if [ ! -d "$HOME/bin" ]; then
    mkdir -p "$HOME/bin"
fi
ln -s ~/.yadm-project/yadm ~/bin/yadm

#ZSH
sudo dnf install -y zsh
sudo chsh -s "$(which zsh)" "$USER"

#STARSHIP
curl -sS https://starship.rs/install.sh | sh

#NERD FONTS
git clone https://github.com/ryanoasis/nerd-fonts.git
sudo ./nerd-fonts/install.sh -S Meslo

#UFW
sudo dnf install -y ufw
#Disable firewalld
sudo systemctl disable --now firewalld.service
#Configure ufw
sudo ufw default deny incoming
sudo ufw limit in 22/tcp comment "rate-limit SSH"
sudo ufw allow 80/tcp comment 'accept HTTP connections'
sudo ufw allow 443/tcp comment 'accept HTTPS connections'
sudo ufw allow 1714:1764/udp comment 'accept kde-connect'
sudo ufw allow 1714:1764/tcp comment 'accept kde-connect'
sudo ufw default allow outgoing
sudo ufw enable

#FAIL2BAN
sudo dnf install -y fail2ban

echo "[DEFAULT]
ignoreip = 127.0.0.1/8 ::1
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true" | sudo tee /etc/fail2ban/jail.local

echo "[wordpress]
enabled = true
filter = wordpress
logpath = /var/log/auth.log
maxretry = 3
port = http,https
bantime = 300" | sudo tee /etc/fail2ban/jail.d/wordpress.conf

sudo systemctl enable fail2ban
sudo systemctl start fail2ban

#SPOTIFY
flatpak install -y spotify

#SPICETIFY
curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.sh | sh
source ~/.zshrc
spicetify config prefs_path "$HOME"/.var/app/com.spotify.Client/config/spotify/prefs
curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.sh | sh

sudo chmod a+wr /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify
sudo chmod a+wr -R /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/Apps

git clone https://github.com/spicetify/spicetify-themes.git
cp -r spicetify-themes/* ~/.config/spicetify/Themes
rm -rf spicetify-themes

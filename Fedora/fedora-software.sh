#!/usr/bin/env bash

# ---------------------------------------------------------------------------------
# Purpose - Script to get stuff done in a fedora installation
# Author  - @darchap
# ---------------------------------------------------------------------------------

#VSCODIUM
sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscodium.repo
sudo dnf install -y codium

#BRAVE
sudo dnf install dnf-plugins-core
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install -y brave-browser

#STACER
sudo dnf install -y stacer

#QEMU AND VIRT-MANAGER
#sudo dnf install -y qemu-kvm libvirt virt-install bridge-utils virt-manager
#sudo dnf install -y libvirt-devel virt-top libguestfs-tools guestfs-tools
#sudo systemctl start libvirtd
#sudo systemctl enable libvirtd

#YADM
git clone https://github.com/TheLocehiliosan/yadm.git ~/.yadm-project
if [ ! -d "$HOME/bin" ]; then
    mkdir -p "$HOME/bin"
fi
ln -s ~/.yadm-project/yadm ~/bin/yadm

#GIT
sudo dnf install -y git

#ZSH
sudo dnf install -y zsh
sudo chsh -s "$(which zsh)" "$USER"

#starship
curl -sS https://starship.rs/install.sh | sh

#nerd fonts
git clone https://github.com/ryanoasis/nerd-fonts.git
sudo ./nerd-fonts/install.sh -S Meslo

#UFW
sudo dnf install -y ufw
#Disable firewalld
sudo systemctl disable --now firewalld.service
#Configure ufw
sudo ufw default deny incoming
sudo ufw limit in 22/tcp comment "rate-limit SSH"
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
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
sudo dnf install lpf-spotify-client
sudo usermod -a -G pkg-build "$USER"
#exec su - $USER
#lpf update

curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.sh | sh
curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.sh | sh
#sudo chmod a+wr /usr/share/spotify-client/
#sudo chmod a+wr -R /usr/share/spotify-client/Apps/
git clone https://github.com/spicetify/spicetify-themes.git
cp -r spicetify-themes/* ~/.config/spicetify/Themes
rm -rf spicetify-themes

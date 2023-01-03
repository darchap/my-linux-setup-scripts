#!/usr/bin/env bash

# ---------------------------------------------------------------------------------
# Purpose - Script to get stuff done in a fedora installation
# Author  - @darchap
# ---------------------------------------------------------------------------------

#FIX DUALBOOT TIME WIN AND LINUX
#sudo timedatectl set-local-rtc 1 --adjust-system-clock

#FIX TOUCHPAD AFTER SLEEP
#echo '#!/bin/sh
#if [ "$1" == "post" ]; then
#rmmod rmi_smbus
#modprobe rmi_smbus
#fi' | sudo tee /usr/lib/systemd/system-sleep/touchpad-fix.sh
sudo grubby --update-kernel=ALL --args="psmouse.synaptics_intertouch=0"

#THINKFAN
sudo dnf install -y thinkfan

echo 'options thinkpad_acpi fan_control=1' | sudo tee /etc/modprobe.d/thinkpad_acpi.conf

echo "sensors:
  # GPU
  #- tpacpi: /proc/acpi/ibm/thermal
  #  indices: [1]
  # CPU
  - hwmon: /sys/class/hwmon
    name: coretemp
    indices: [1]
  # Chassis
  #- hwmon: /sys/class/hwmon
  #  name: thinkpad
  #  indices: [1]
  # MB
  #- hwmon: /sys/class/hwmon
  #  name: acpitz
  #  indices: [1]

fans:
  - tpacpi: /proc/acpi/ibm/fan

levels:
  - [0, 0, 60]
  - [1, 58, 64]
  - [2, 62, 72]
  - [3, 68, 78]
  - [4, 74, 82]
  - [5, 76, 86]
# - [6, 78, 84]
  - [7, 82, 90]
  - [level full-speed, 84, 32767]



#  - [0, 0, 37]
#  - [1, 35, 42]
#  - [2, 40, 45]
#  - [3, 43, 47]
#  - [4, 45, 52]
#  - [5, 50, 57]
#  - [6, 55, 72]
#  - [7, 70, 82]
#  - [level full-speed, 77, 32767]" | sudo tee /etc/thinkfan.conf

sudo mkdir -p /etc/systemd/system/thinkfan.service.d
echo "[Unit]
StartLimitIntervalSec=30
StartLimitBurst=3

[Service]
Restart=on-failure
RestartSec=3" | sudo tee /etc/systemd/system/thinkfan.service.d/10-restart-on-failure.conf
sudo systemctl daemon-reload

#sudo modprobe -rv thinkpad_acpi
#sudo modprobe -v thinkpad_acpi
sudo systemctl enable thinkfan
sudo systemctl start thinkfan

#GRUB
git clone https://github.com/AdisonCavani/distro-grub-themes.git
sudo mkdir -p /boot/grub2/themes
sudo cp -r distro-grub-themes/customize/lenovo/ /boot/grub2/themes
rm -rf distro-grub-themes

if grep -q GRUB_TERMINAL_OUTPUT= /etc/default/grub; then
  sudo sed -e '/GRUB_TERMINAL_OUTPUT=^*/ s/^#*/#/g' -i /etc/default/grub
fi

if ! grep -q GRUB_TIMEOUT= /etc/default/grub; then
  echo 'GRUB_TIMEOUT=10' | sudo tee -a /etc/default/grub
else
  sudo sed -i '/GRUB_TIMEOUT=/c\GRUB_TIMEOUT=10' /etc/default/grub
fi

if ! grep -q GRUB_GFXMODE= /etc/default/grub; then
  echo 'GRUB_GFXMODE="1920x1080"' | sudo tee -a /etc/default/grub
else
  sudo sed -i '/GRUB_GFXMODE=/c\GRUB_GFXMODE="1920x1080"' /etc/default/grub
fi

if ! grep -q GRUB_THEME= /etc/default/grub; then
  echo 'GRUB_THEME="/boot/grub2/themes/lenovo/theme.txt"' | sudo tee -a /etc/default/grub
else
  sudo sed -i '/GRUB_THEME=/c\GRUB_THEME="/boot/grub2/themes/lenovo/theme.txt"' /etc/default/grub
fi

sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

#THEMING
sudo dnf install -y kvantum
git clone https://github.com/vinceliuice/Layan-kde.git
Layan-kde/install.sh
rm -rf Layan-kde

#AUTO-CPUFREQ
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
sudo auto-cpufreq/auto-cpufreq-installer
rm -rf auto-cpufreq

#!/bin/bash

# ---------------------------------------------------------------------------------
# Purpose - Script to get stuff done in a fedora installation
# Author  - @darchap
# ---------------------------------------------------------------------------------

#DNF CONFIG
if [ -z $(grep fastestmirror= /etc/dnf/dnf.conf) ]; then
    echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
else
    sudo sed -i '/fastestmirror=/c\fastestmirror=True' /etc/dnf/dnf.conf
fi

if [ -z $(grep max_parallel_downloads= /etc/dnf/dnf.conf) ]; then
    echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
else
    sudo sed -i '/max_parallel_downloads=/c\max_parallel_downloads=10' /etc/dnf/dnf.conf
fi

if [ -z $(grep defaultyes= /etc/dnf/dnf.conf) ]; then
    echo "defaultyes=True" | sudo tee -a /etc/dnf/dnf.conf
else
    sudo sed -i '/defaultyes=/c\defaultyes=True' /etc/dnf/dnf.conf
fi

if [ -z $(grep keepcache= /etc/dnf/dnf.conf) ]; then
    echo "keepcache=True" | sudo tee -a /etc/dnf/dnf.conf
else
    sudo sed -i '/keepcache=/c\keepcache=True' /etc/dnf/dnf.conf
fi

if [ -z $(grep deltarpm= /etc/dnf/dnf.conf) ]; then
    echo "deltarpm=True" | sudo tee -a /etc/dnf/dnf.conf
else
    sudo sed -i '/deltarpm=/c\deltarpm=True' /etc/dnf/dnf.conf
fi

#REMOVE DNFDRAGORA
sudo dnf remove -y dnfdragora

###
# Disable the Modular Repos
# Given the added load at updates, and the issues to keep modules updated, in check and listed from the awful cli for it - remove entirely.
###
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-modular.repo
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-modular.repo
# Testing Repos should be disabled anyways
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-testing-modular.repo
# Rpmfusion makes this obsolete
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-cisco-openh264.repo
# Disable Machine Counting for all repos
sudo sed -i 's/countme=1/countme=0/g' /etc/yum.repos.d/*

#RPM FUSION REPOS
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

#ADD FLATHUB REPO
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#DEBLOAT KDE
sudo dnf remove -y akregator kamoso mediawriter elisa-player kmag kgpg qt5-qdbusviewer kcharselect kcolorchooser dragon kmines kmahjongg kpat kruler kmousetool kmouth kolourpaint konversation krdc kfind kaddressbook kmail kontact korganizer ktnef kf5-akonadi-*

#ADDITIONAL CODECS
sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install -y lame\* --exclude=lame-devel
sudo dnf group upgrade -y --with-optional Multimedia

#UPDATE
# Clean all dnf temporary files
sudo dnf clean all
# Force update the whole system to the latest and greatest
sudo dnf upgrade --best --allowerasing --refresh -y
# And also remove any packages without a source backing them
sudo dnf distro-sync -y

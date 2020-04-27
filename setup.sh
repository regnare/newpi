#!/bin/bash

NEWHOST="farside"
NEWDOMAIN="lan"
NEWUSER="ben"

NEWLOCALE="en_US.UTF-8"
NEWLAYOUT="us"
NEWTIMEZONE="US/Eastern"
AVAHI_CONFIG="/etc/avahi/avahi-daemon.conf"

# Setup new user. I do it here first in case I decided
# to run this script with "&& sudo reboot", that way
# I don't have to wait until the end to setup the password.
echo "Adding new user $NEWUSER"
sudo useradd -m -G users,sudo,adm "$NEWUSER"
echo "Please set the password now."
sudo passwd "$NEWUSER"

# Update timezone
sudo timedatectl set-timezone "$NEWTIMEZONE"

# configure avahi-daemon to use new hostname for mDNS
sudo sed -i.bak "s/.*host-name=.*/host-name=$NEWHOST/g" "$AVAHI_CONFIG"
sudo sed -i "s/.*domain-name=.*/domain-name=$NEWDOMAIN/g" "$AVAHI_CONFIG"
sudo sed -i "s/.*disable-publishing=.*/publish-domain=no/g" "$AVAHI_CONFIG"

# disable bluetooth and wifi
echo "dtoverlay=pi3-disable-wifi" | sudo tee -a /boot/config.txt
echo "dtoverlay=pi3-disable-bt" | sudo tee -a /boot/config.txt
sudo systemctl disable hciuart
sudo systemctl disable wpa_supplicant

# disable ipv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee /etc/sysctl.d/custom.conf

# install updates and my common packages.
sudo apt update && sudo apt -y upgrade
sudo apt -y install tmux vim zsh stow git uptimed nftables unattended-upgrades toilet
sudo apt -y purge iptables

# setup motd with a banner of the hostname.
toilet -f mono9 -F gay "$NEWHOST" | sudo tee /etc/motd

# Update user shell as zsh
sudo usermod -s $(which zsh) "$NEWUSER"

# configure the locale settings
sudo raspi-config nonint do_hostname "$NEWHOST"
sudo raspi-config nonint do_configure_keyboard "$NEWLAYOUT"
sudo raspi-config nonint do_wifi_country "$NEWLAYOUT"
sudo raspi-config nonint do_change_locale "$NEWLOCALE"

echo "Time to 'reboot'."

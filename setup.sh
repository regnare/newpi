#!/bin/bash

NEWHOST="newhostname"
NEWDOMAIN="lan"
NEWUSER="ben"

NEWLOCALE="en_US.UTF-8"
NEWLAYOUT="us"
NEWTIMEZONE="US/Eastern"

echo "Adding new user $NEWUSER"
sudo useradd -m -G users,sudo,adm "$NEWUSER"
echo "Please set the password now."
sudo passwd "$NEWUSER"

sudo timedatectl set-timezone "$NEWTIMEZONE"

sudo sed -i.bak "s/#host-name=foo/host-name=$NEWHOST/g" /etc/avahi/avahi-daemon.conf
sudo sed -i "s/#domain-name=local/domain-name=$NEWDOMAIN/g" /etc/avahi/avahi-daemon.conf

# disable bluetooth and wifi
echo "dtoverlay=pi3-disable-wifi" | sudo tee -a /boot/config.txt
echo "dtoverlay=pi3-disable-bt" | sudo tee -a /boot/config.txt
sudo systemctl disable hciuart
sudo systemctl disable wpa_supplicant

# disable ipv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee /etc/sysctl.d/custom.conf

echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | sudo debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | sudo debconf-set-selections

sudo apt update && sudo apt -y upgrade
sudo apt -y install tmux vim zsh stow git uptimed iptables-persistent

sudo usermod -s $(which zsh) "$NEWUSER"

sudo raspi-config nonint do_hostname "$NEWHOST"
sudo raspi-config nonint do_configure_keyboard "$NEWLAYOUT"
sudo raspi-config nonint do_wifi_country "$NEWLAYOUT"
sudo raspi-config nonint do_change_locale "$NEWLOCALE"

echo "Time to 'reboot'."

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

sudo raspi-config nonint do_hostname "$NEWHOST"
sudo raspi-config nonint do_change_locale "$NEWLOCALE"
sudo raspi-config nonint do_configure_keyboard "$NEWLAYOUT"
sudo raspi-config nonint do_wifi_country "$NEWLAYOUT"

sudo timedatectl set-timezone "$NEWTIMEZONE"

sudo sed -i "s/#host-name=foo/domain-name=$NEWHOST/g" /etc/avahi/avahi-daemon.conf
sudo sed -i "s/#domain-name=local/domain-name=$NEWDOMAIN/g" /etc/avahi/avahi-daemon.conf

sudo apt update && sudo apt -y upgrade
sudo apt -y install tmux vim zsh stow git 

sudo usermod -s $(which zsh) "$NEWUSER"

echo "Time to 'reboot'."

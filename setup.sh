#!/bin/bash

NEWHOST="newhostname"
NEWDOMAIN="lan"

NEWLOCALE="en_US.UTF-8"
NEWLAYOUT="us"
NEWTIMEZONE="US/Eastern"

sudo raspi-config nonint do_hostname "$NEWHOST"
sudo raspi-config nonint do_change_locale "$NEWLOCALE"
sudo raspi-config nonint do_configure_keyboard "$NEWLAYOUT"
echo "$NEWTIMEZONE" | sudo tee /etc/timezone
sudo dpkg-reconfigure -f noninteractive tzdata

sudo sed -i 's/#host-name=foo/domain-name=$NEWHOST/g' /etc/avahi/avahi-daemon.conf
sudo sed -i 's/#domain-name=local/domain-name=$NEWDOMAIN/g' /etc/avahi/avahi-daemon.conf

sudo apt update && sudo apt -y upgrade
sudo apt -y install tmux vim zsh stow git 

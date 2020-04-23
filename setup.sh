#!/bin/bash

NEWHOST="newhostname"

NEWLOCALE="en_US.UTF-8"
NEWLAYOUT="us"
NEWTIMEZONE="US/Eastern"

sudo raspi-config nonint do_hostname "$NEWHOST"
sudo raspi-config nonint do_change_locale "$NEWLOCALE"
sudo raspi-config nonint do_configure_keyboard "$NEWLAYOUT"
sudo echo "$NEWTIMEZONE" > /etc/timezone
sudo dpkg-reconfigure -f noninteractive tzdata

sudo apt update && sudo apt -y upgrade
sudo apt -y install tmux vim zsh stow git 

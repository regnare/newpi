#!/bin/bash

NEWDOMAIN="lan"
NEWLOCALE="en_US.UTF-8"
NEWLAYOUT="us"
NEWTIMEZONE="US/Eastern"
AVAHI_CONFIG="/etc/avahi/avahi-daemon.conf"
UNATTEND_POLICY="/etc/apt/apt.conf.d/50unattended-upgrades"
AUTO_UPGRADES="/etc/apt/apt.conf.d/20auto-upgrades"
WIFI_CONFIG="/etc/wpa_supplicant/wpa_supplicant.conf"
SSH_KEY_FILE="regnare.pub"
WIFI="false"
SSID=""
WIFI_PASSPHRASE=""

function usage() {
  echo "Usage: $0"
  echo "  -h: [string] The new hostname"
  echo "  -u: [string] The new username"
  echo "  -w: To enable wifi adapter"
  exit 1
}

function main() {
  while getopts ":u:h:w" args; do
    case "${args}" in
      u) NEWUSER="${OPTARG}";;
      h) NEWHOST="${OPTARG}";;
      w) WIFI="true";;
      *) usage;;
    esac
  done

  if [[ -z $NEWUSER || -z $NEWHOST ]]; then usage; fi
  if $WIFI; then
    read -p "SSID: " SSID
    read -s -p "Passphrase:" WIFI_PASSPHRASE
  fi

  echo "========================================"
  echo "You've selected the following options:"
  echo "User: $NEWUSER (default password is: changeme)"
  echo "Hostname: $NEWHOST"
  echo "WiFi Enabled: $WIFI"
  if $WIFI; then
    echo "SSID: $SSID"
    echo "Passphrase: $WIFI_PASSPHRASE"
  fi
  echo "========================================"

  read -p "Continue with setup? (y/N)" choice
  case "$choice" in
    y|Y) echo "Ok, here we go..."; configure;;
    *)   echo "Setup aborted."; exit 2;;
  esac
}

function configure() { 
  # Setup new user.
  echo "Adding new user $NEWUSER"
  sudo useradd -m -G users,sudo,adm "$NEWUSER"
  # set default password
  echo "$NEWUSER:changeme" | sudo chpasswd
  # force the password to expired, requiring that it's changed on next login.
  sudo passwd -e "$NEWUSER"
  
  # Setup pub ssh key
  sudo mkdir -p /home/"$NEWUSER"/.ssh
  sudo cp "$SSH_KEY_FILE" /home/"$NEWUSER"/.ssh/authorized_keys
  sudo chown "$NEWUSER":"$NEWUSER" /home/"$NEWUSER"/.ssh/authorized_keys
  sudo chmod 600 /home/"$NEWUSER"/.ssh/authorized_keys

  # Update timezone
  sudo timedatectl set-timezone "$NEWTIMEZONE"

  # configure avahi-daemon to use new hostname for mDNS
  sudo sed -i.bak "s/.*host-name=.*/host-name=$NEWHOST/g" "$AVAHI_CONFIG"
  sudo sed -i "s/.*domain-name=.*/domain-name=$NEWDOMAIN/g" "$AVAHI_CONFIG"
  sudo sed -i "s/.*disable-publishing=.*/publish-domain=no/g" "$AVAHI_CONFIG"
  
  # disable bluetooth and wifi
  if $WIFI; then
    echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" | sudo tee "$WIFI_CONFIG"
    echo "update_config=1" | sudo tee -a "$WIFI_CONFIG"
    echo "country=$NEWLAYOUT" | sudo tee -a "$WIFI_CONFIG"
    wpa_passphrase "$SSID" "$WIFI_PASSPHRASE" | sed '/\s*#/d' | sudo tee -a "$WIFI_CONFIG"
  else
    echo "dtoverlay=pi3-disable-wifi" | sudo tee -a /boot/config.txt
    echo "dtoverlay=pi3-disable-bt" | sudo tee -a /boot/config.txt
    sudo systemctl disable hciuart
    sudo systemctl disable wpa_supplicant
  fi

  # disable ipv6
  echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee /etc/sysctl.d/no-ipv6.conf

  # install updates and my common packages.
  sudo apt update && sudo apt -y upgrade
  sudo apt -y install tmux vim zsh stow git uptimed ufw unattended-upgrades toilet xclip

# setup unattended upgrades
# unindented on purpose for heredoc formatting.
sudo tee "$UNATTEND_POLICY" <<'EOF'
Unattended-Upgrade::Origins-Pattern {
  "origin=Raspbian,codename=${distro_codename},label=Raspbian";
  "origin=Raspberry Pi Foundation,codename=${distro_codename},label=Raspberry Pi Foundation";
};
Unattended-Upgrade::Package-Blacklist {
};
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-WithUsers "false";
EOF

sudo tee "$AUTO_UPGRADES" <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

  # setup motd with a banner of the hostname.
  toilet -f mono9 -F gay "$NEWHOST" | sudo tee /etc/motd

  # Update user shell as zsh
  sudo usermod -s $(which zsh) "$NEWUSER"
  
  # Configure UFW
  sudo sed -i.bak "s/.*IPV6=.*/IPV6=no/g" /etc/default/ufw
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow ssh
  sudo ufw show added
  sudo ufw enable

  # configure the locale settings
  sudo raspi-config nonint do_hostname "$NEWHOST"
  sudo raspi-config nonint do_configure_keyboard "$NEWLAYOUT"
  sudo raspi-config nonint do_wifi_country "$NEWLAYOUT"
  sudo raspi-config nonint do_change_locale "$NEWLOCALE"

  # Set vim as default editor
  sudo update-alternatives --set editor /usr/bin/vim.basic

  echo "Time to 'reboot'."
}

main "$@"

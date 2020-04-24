#!/bin/bash

sudo ln -f $(pwd)/nftables.conf /etc/nftables.conf
sudo systemctl enable nftables.service
sudo systemctl start nftables.service
sudo nft list ruleset

#!/bin/bash
# 1. Install prerequisites
sudo apt-get update
sudo apt-get install -y debian-keyring debian-archive-keyring bash-completion curl gpg

# 2. Add XanMod GPG Key and Repository
curl -s https://dl.xanmod.org/archive.key | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-release.list

# 3. Install the specific 6.18 XanMod headers
sudo apt-get update
sudo apt-get install -y linux-headers-6.18.18-x64v2-xanmod1
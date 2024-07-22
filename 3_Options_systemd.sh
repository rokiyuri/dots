#!/bin/bash

mkdir /etc/pcman.d/hooks

touch /etc/pacman.d/hooks/50-bootbackup.hook

chmod a+rx /.snapshots

chown :roki /.snapshots

git clone https://aur.archlinux.org/yay.git

cd yay.git

makepkg -sic

yay -S zramd

systemctl enable --now zramd.service
#/etc/default/zramd


#Install the ifplugd package and start/enable the netctl-ifplugd@interface.service systemd unit. 
#Start/enable netctl-auto@interface.service systemd unit. netctl profiles will be started/stopped automatically as you move from the range of one network into the range of another network (roaming).
#Profiles must use Security=wpa-configsection or Security=wpa to work with netctl-auto

printf "\e[1;32mDone! Move to the next Script.\e[0m"


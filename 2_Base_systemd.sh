#!/bin/bash

ln -sf /usr/share/zoneinfo/America/Paramaribo /etc/localtime
hwclock --systohc
sed -i 's/^#\(en_US.UTF-8 UTF-8\)//g' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=us" >> /etc/vconsole.conf
echo "Phoenix" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 Phoenix.localdomain Phoenix" >> /etc/hosts
echo root:password | chpasswd

#pacman -S networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools reflector base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh reflector acpi acpi_call tlp virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq iptables-nft ipset firewalld acpid ntfs-3g terminus-font --noconfirm

pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack pipewire-audio wireplumber dialog reflector avahi gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups bash-completion acpi acpi_call tlp virt-manager qemu-desktop libvirt iptables-nft ipset edk2-ovmf bridge-utils dnsmasq ipset firewalld acpid terminus-font ttf-jetbrains-mono ttf-iosevka-nerd ttf-dejavu blueman qtile bitwarden dunst feh zsh zsh-autosuggestions sh-syntax-highlighting zsh-completions playerctl brightnessctl fileroller nemo nemo-fileroller nemo-image-converter nemo-preview nemo-python nemo-share obsidian kitty kitty-shell-integration kitty-terminfo maim openconnect pavucontrol ifplugd #--noconfirm

sed -i 's/HOOKS=(base\ udev\ autodetect\ modconf\ block\ filesystems\ keyboard\ fsck)/HOOKS="base\ udev\ autodetect\ modconf\ block\ encrypt\ filesystems\ keyboard\ fsck"/' /etc/mkinitcpio.conf
sed -i 's/MODULES=()/MODULES="btrfs"/' /etc/mkinitcpio.conf

mkinitcpio -p linux-lts

#systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable tlp # You can comment this command out if you didn't install tlp, see above
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid

bootctl --path=/boot install

### cd /boot/loader
### change the loader.conf
#timeout 5
#console-mode max
#default arch

### cd /entries
### make the file arch.conf
#title	Arch
#linux	/vmlinuz-linux-lts
#initrd	/intel-ucode
#initrd	/initramfs-linux-lts.img
#options cryptdevice=UUID=2bef5000-8f23-4a1d-8018-92cc534dedf0:root root=UUID=56beddbc-41c8-47b9-9fec-4f77bd8ba868 rootflags=subvol=@ rw


###options cryptdevice=UUID=(van de /dev/nvme0n1p5):root root=UUID=(UUID van de mapper cryptroot)
###info te halen met blkid /dev/nvme0n1p5) & blkd /dev/mapper/cryptroot

###onderstaand is wanneer geen encrypted device
#options root="LABEL=arch" rw (dit is zonder encryption)

### nu de fallback config
#cp /boot/loader/entries/arch.conf /boot/loader/entries/arch-fallback.conf
#initrd /initramfs-linux-lts-fallback.img

# useradd -m -G additional_groups -s login_shell username
useradd -m -G wheel libvirt roki
echo roki:password | chpasswd
usermod -aG wheel libvirt roki

#echo "roki ALL=(ALL) ALL" >> /etc/sudoers.d/roki

printf "\e[1;32mDone! Unmount with: umount -R /mnt .\e[0m"


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

sed -i 's/HOOKS=(base\ udev\ autodetect\ modconf\ block\ filesystems\ keyboard\ fsck)/HOOKS="base\ udev\ autodetect\ modconf\ block\ encrypt\ filesystems\ keyboard\ fsck\ resume"/' /etc/mkinitcpio.conf
sed -i 's/MODULES=()/MODULES="btrfs"/' /etc/mkinitcpio.conf

#Note: If you don’t use a swap file, leave out the resume hook

mkinitcpio -p linux
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

### 
########linux-lts Kernel
### 
### For the linux-lts kernel: change the loader.conf in /boot/loader/loader.conf to set it as default
echo "timeout 5" >> /boot/loader/loader.conf
echo "console-mode max" >> /boot/loader/loader.conf
echo "default archlts" >> /boot/loader/loader.conf

### cmake the file arch.conf in /boot/loader/entries/arch.conf
echo "title	Archlts" >> /boot/loader/entries/archlts.conf
echo "linux	/vmlinuz-linux-lts" >> /boot/loader/entries/archlts.conf
echo "initrd	/intel-ucode" >> /boot/loader/entries/archlts.conf
echo "initrd	/initramfs-linux-lts.img" >> /boot/loader/entries/archlts.conf
echo "options cryptdevice=" >> /boot/loader/entries/archlts.conf
blkid -s UUID -o value /dev/nvme0n1p5 >> /boot/loader/entries/archlts.conf
echo ":cryptroot:allow-discards root=" >> /boot/loader/entries/archlts.conf
echo blkid -s UUID -o value /dev/mapper/cryptroot >> /boot/loader/entries/archlts.conf
echo " rootflags=subvol=@ rw resume=/dev/mapper/cryptroot resume_offset=" >> /boot/loader/entries/archlts.conf
btrfs inspect-internal map-swapfile -r swap_file >> /boot/loader/entries/archlts.conf


### 
########linux-Kernel
### 
### cmake the file arch.conf in /boot/loader/entries/arch.conf
echo "title	Arch" >> /boot/loader/entries/arch.conf
echo "linux	/vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd	/intel-ucode" >> /boot/loader/entries/arch.conf
echo "initrd	/initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options cryptdevice=" >> /boot/loader/entries/arch.conf
blkid -s UUID -o value /dev/nvme0n1p5 >> /boot/loader/entries/arch.conf
echo ":cryptroot:allow-discards root=" >> /boot/loader/entries/arch.conf
echo blkid -s UUID -o value /dev/mapper/cryptroot >> /boot/loader/entries/arch.conf
echo " rootflags=subvol=@ rw resume=/dev/mapper/cryptroot resume_offset=" >> /boot/loader/entries/arch.conf
btrfs inspect-internal map-swapfile -r swap_file >> /boot/loader/entries/arch.conf


####onderstaand is de volledige commando
#options cryptdevice=UUID=2bef5000-8f23-4a1d-8018-92cc534dedf0:cryptroot:allow-discards root=UUID=56beddbc-41c8-47b9-9fec-4f77bd8ba868 rootflags=subvol=@ rw resume=/dev/mapper/cryptroot resume_offset=<YOUR-OFFSET>

###Andere optie met swapfile
#options cryptdevice=UUID=<UUID-OF-ROOT-PARTITION>:luks:allow-discards root=/dev/mapper/luks rootflags=subvol=@ rd.luks.options=discard rw resume=/dev/mapper/luks resume_offset=<YOUR-OFFSET>
### For Btrfs, nstead, use the btrfs-inspect-internal
## btrfs inspect-internal map-swapfile -r swap_file
##resume_offset=198122980
###options cryptdevice=UUID=(van de /dev/nvme0n1p5):cryptroot root=UUID=(UUID van de mapper cryptroot)
###onderstaand is wanneer geen encrypted device
#options root="LABEL=arch" rw (dit is zonder encryption)

### nu de fallback config
#cp /boot/loader/entries/arch.conf /boot/loader/entries/arch-fallback.conf
#initrd /initramfs-linux-lts-fallback.img
#echo "title	arch" >> /boot/loader/entries/arch-fallback.conf
#echo "linux	/vmlinuz-linux-lts" >> /boot/loader/entries/arch-fallback.conf
#echo "initrd	/intel-ucode" >> /boot/loader/entries/arch-fallback.conf
#echo "initrd	/initramfs-linux-lts-fallback.img" >> /boot/loader/entries/arch-fallback.conf
#echo "options cryptdevice=" >> /boot/loader/entries/arch-fallback.conf
#blkid -s UUID -o value /dev/nvme0n1p5 >> /boot/loader/entries/arch-fallback.conf
#echo ":cryptroot:allow-discards root=" >> /boot/loader/entries/arch-fallback.conf
#echo blkid -s UUID -o value /dev/mapper/cryptroot >> /boot/loader/entries/arch-fallback.conf
#echo " rootflags=subvol=@ rw resume=/dev/mapper/cryptroot resume_offset=" >> /boot/loader/entries/arch-fallback.conf
#btrfs inspect-internal map-swapfile -r swap_file >> /boot/loader/entries/arch-fallback.conf


# useradd -m -G additional_groups -s login_shell username
useradd -m -G wheel libvirt roki
echo roki:password | chpasswd
usermod -aG wheel libvirt roki

#echo "roki ALL=(ALL) ALL" >> /etc/sudoers.d/roki

printf "\e[1;32mDone! Modify the bootloader files and then Unmount with: umount -R /mnt .\e[0m"


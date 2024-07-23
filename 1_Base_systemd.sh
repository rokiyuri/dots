1. Setup the wifi

iwctl

2. Set the correct time

timedatectl set-ntp true
pacman -S --noconfirm archlinux-keyring

3. check the binaries for UEFI

ls /sys/firmware/efi/efivars


4. Partition the disk (create a boot partition)

cfdisk
create a /boot partition with /fat32 filesystem
mkfs.fat -F32 /dev/nvme0n1p4

4. Format the partitions ( create an encrypted root partition)

cryptsetup --verbose --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random --pbkdf pbkdf2 --type luks2 luksFormat /dev/nvme0n1p5

cryptsetup --allow-discards --persistent luksOpen /dev/nvme0n1p5 cryptroot

mkfs.btrfs /dev/mapper/cryptroot


5. Mount the partitions

mount /dev/mapper/cryptroot /mnt
#mount -o compress=zstd,noatime,discard,ssd,defaults /dev/mapper/cryptroot /mnt
#mount -o noatime,compress=zstd,ssd,space_cache=v2

#Als we de archinstall script gebruiken is je mount point:  /mnt/archinstall
# voorbeeld is uitgewerkt in paragraaf 7

6. Create Subvolumes:

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@swap
umount /mnt

7. Mount the subvolumes:

# voorbeeld:
# mount -o compress=lzo,noatime,space_cache=v2,discard=async,ssd,defaults,subvol=@ /dev/mapper/cryptroot /mnt/archinstall


mount -o compress=zstd,noatime,space_cache=v2,discard=async,ssd,subvol=@ /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{home,boot,.snapshots,var/log,btrfs}
mount -o compress=zstd,noatime,space_cache=v2,discard=async,ssd,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o compress=zstd,noatime,space_cache=v2,discard=async,ssd,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
mount -o compress=zstd,noatime,space_cache=v2,discard=async,ssd,subvol=@var_log /dev/mapper/cryptroot /mnt/var/log
mount -o noatime,nodiratime,compress=zstd,space_cache=v2,ssd,subvolid=5 /dev/mapper/cryptroot  /mnt/btrfs
mount /dev/nvme0n1p4 /mnt/boot

8. Swapfile
#codyhou
#cd /mnt/swap
#chattr +C /mnt/swap
#dd if=/dev/zero of=./swapfile bs=1M count=4096 status=progress
#chmod 0600 ./swapfile
# mkswap -U clear ./swapfile
# swapon ./swapfile
#sync


cd /mnt/btrfs/@swap
truncate -s 0 ./swapfile
chattr +C ./swapfile
btrfs property set ./swapfile compression none
dd if=/dev/zero of=./swapfile bs=1M count=8192 status=progress
# btrfs filesystem mkswapfile --size 2G swapfile
chmod 600 ./swapfile
mkswap ./swapfile
swapon ./swapfile
# swapon swapfile
cd -
sync




#nerdstuff
# cd /mnt/btrfs/@swap
# btrfs subvolume create /mnt/@swap
# btrfs filesystem mkswapfile --size 8g --uuid clear /swap/swapfile
# swapon /swap/swapfile
#/etc/fstab
#/swap/swapfile none swap defaults 0 0
#/swap/swapfile        none        swap        defaults      0 0


#Manual
# btrfs subvolume create /swap
#Tip: Consider creating the subvolume directly below the top-level subvolume, e.g. @swap. Then, make sure the subvolume is mounted to /swap (or any other accessible location).
# btrfs filesystem mkswapfile --size 4g --uuid clear /swap/swapfile
# swapon /swap/swapfile
#/etc/fstab
#/swap/swapfile none swap defaults 0 0

9. Install the base packages into /mnt or run the archinstall script

#For archinstall script choose the pre-mounted partition setup
pacman -Syy

pacstrap /mnt base base-devel linux-lts linux-lts-headers linux linux-headers git linux-firmware nano btrfs-progs efibootmgr bootctl netctl openssh intel-ucode wpa_supplicant git xdg-user-dirs xdg-utils gvfs ntfs-3g mtools dosfstools --noconfirm 
#(or amd-ucode))


10. Generate the fstab
genfstab -U /mnt >> /mnt/etc/fstab


11. Copy the windows bootlaoder into the new EFI partition & arch-root into new install

arch-chroot /mnt
mkdir /mnt/win10
mount /dev/nvme0n1p1 /mnt/win10
cp -r /mnt/win10/EFI/Microsoft /boot/EFI


#cryptsetup luksUUID /dev/YOUR_ROOT_PARTITION
#cryptsetup luksUUID /dev/nvme0n1p5
#cryptsetup --allow-discards --persistent luksOpen /dev/nvme0n1p5 cryptroot

12. Continue with Script 2_Base_systemtd.sh


Download the git repository with git clone https://gitlab.com/rokiyuri/2_Base_systemd.sh

10. cd arch-basic
11. chmod +x 2_Base_systemd.sh
12. run with ./2_Base_systemd.sh

printf "\e[1;32mDone! Move to the next Script.\e[0m"





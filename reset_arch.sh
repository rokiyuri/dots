https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Removing_everything_but_essential_packages

git clone https://github.com/rokiyuri/dots.git

1. Mark all installed packages as dependencies

sudo pacman -D --asdeps $(pacman -Qqe)

2. Mark a certain set out of previous set as explicitly installed

sudo pacman -D --asexplicit base linux linux-lts linux-firmware git nano vim intel-ucode

3. Switch to root user

su -

4a. Remove everything (dependencies and optional dependencies)

pacman -Qttdq | pacman -Rns -

#4b. Remove only dependencies (but keep optional dependencies)

#pacman -Qtdq | pacman -Rns -

5. Make preperations to reinstall the base system, reinstall the base install script. Start from where we define the root password (e.g: echo root:password | chpasswd) also comment out the roki user and the permissions

6. Chaneg the permissions for the file before excecuting

chmod +x the_script+file.sh

7. Excecute the file

run ./the_script+file.Switch

8. reboot



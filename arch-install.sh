#!/bin/bash

timezone() {
    ln -sf /usr/share/zoneinfo/Europe/Oslo /etc/localtime
    hwclock --systohc
}

setlocale() {
    sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
}

setkeymap() {
    echo "KEYMAP=us" > /etc/vconsole.conf
}

sethost() {
    echo "Set name of the host:"
    read hostname

    echo $hostname > /etc/hostname
    echo "127.0.0.1 localhost" >> /etc/hosts
    echo "::1 localhost" >> /etc/hosts
}

setup-intel-ucode() {
    pacman -S intel-ucode
}

setup-wifi() {
    echo "Do you want to setup wifi? (y/n)"
    read wifi

    if [ $wifi == "y" ]; then
        echo "Enter wifi interface (e.g. wlp2s0):"
        read wifi_interface
        echo "Enter wifi ssid:"
        read wifi_ssid
        echo "Enter wifi password:"
        read wifi_password

        systemctl start iwd
        iwctl station $wifi_interface connect $wifi_ssid --passphrase $wifi_password
        ping -c 3 google.com
    fi

}

setup-bootloader() {
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    # check if intel or amd
    echo "Is this an Intel or AMD system? (i/a)"
    read cpu
    if [ $cpu == "i" ]; then
        setup-intel-ucode
    fi
    grub-mkconfig -o /boot/grub/grub.cfg
}

gen-fstab(){
    genfstab -U /mnt >> /mnt/etc/fstab
}

install-base() {
    pacstrap /mnt base base-devel linux linux-firmware btrfs-progs efibootmgr grub os-prober vim git
}

setup-disk-with-btrfs-and-encryption() {
    # Read disk
    echo "Enter disk to install Arch Linux on (e.g. /dev/sda):"
    read disk

    # Partitioning
    ## EFI
    parted ${disk} mklabel gpt
    parted ${disk} mkpart primary fat32 1MiB 513MiB
    parted ${disk} set 1 esp on
    ## Swap
    parted ${disk} mkpart primary linux-swap 513MiB 4.5GiB
    ## Root
    parted ${disk} mkpart primary ext4 4.5GiB 100%

    # Format
    mkfs.fat -F32 ${disk}1
    mkswap ${disk}2
    swapon ${disk}2
    mkfs.ext4 ${disk}3

    # Encrypt
    modprobe dm-crypt
    modprobe dm-mod
    cryptsetup luksFormat -v -s 512 -h sha512 ${disk}3
    cryptsetup open ${disk}3 cryptroot
    mkfs.btrfs /dev/mapper/cryptroot

    # Mount
    mkdir /mnt
    mkdir /mnt/boot
    mount -t btrfs /dev/mapper/cryptroot /mnt
    btrfs su cr /mnt/@
    btrfs su cr /mnt/@home
    btrfs su cr /mnt/@var
    btrfs su cr /mnt/@snapshots
    umount /mnt
    mount -o noatime,compress=lzo,space_cache,subvol=@ /dev/mapper/cryptroot /mnt
    mkdir -p /mnt/{boot,home,var,.snapshots}
    mount -o noatime,compress=lzo,space_cache,subvol=@home /dev/mapper/cryptroot /mnt/home
    mount -o noatime,compress=lzo,space_cache,subvol=@var /dev/mapper/cryptroot /mnt/var
    mount -o noatime,compress=lzo,space_cache,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
    mount ${disk}1 /mnt/boot
}

install-after-chroot() {
    pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si

    # Install packages
    paru -S --needed - < .config/packages.txt

    # Enable services
    systemctl enable NetworkManager
    systemctl enable sshd
    systemctl enable cronie
    systemctl enable fstrim.timer
}

installation() {
    loadkeys us
    timedatectl set-ntp true

    setup-wifi
    setup-disk-with-btrfs-and-encryption
    install-base
    gen-fstab

    # Chroot
    arch-chroot /mnt

    # Change passwd
    echo "Enter root password:"
    passwd

    # Locale and keymap
    setlocale
    setkeymap

    # Host
    sethost

    # Timezone
    timezone

    # Update grub cmdline with cryptdevice
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice='${disk}3':cryptroot"/' /etc/default/grub

    # Update mkinitcpio
    sed -i 's/^HOOKS.*/HOOKS=(base udev autodetect keyboard keymap modconf block encrypt btrfs filesystems fsck)/' /etc/mkinitcpio.conf
    mkinitcpio -p linux

    # Setup bootloader
    setup-bootloader

    # Install after chroot
    install-after-chroot

    # Exit chroot
    exit

    # Unmount
    umount -R /mnt

    # Reboot
    reboot
}

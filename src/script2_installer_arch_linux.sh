#!/bin/bash
#
# script2_instaler_arch_linux.sh
#
#       scrip de instalacao do SO ARCH linux
#       Autor: Jeremias Pereira da silva
#       Data:16/01/2020
#       Versao: 0.1
#       Licensa: MIT                                                            
#
#
# Este segundo script seta as configuracoes de localizacao configuracoes basicas da rede  hostname instalacao do bootloader 
#
#
#############################################################################################################################################################

SET_HOSTAME=""
echo "install package"

# instala ferramentas de rede, bootloader(grub)
pacman -S mtools net-tools network-manager-applet networkmanager grub

#set time zone
ln -sf /usr/zoneinfo/Brazil/East /etc/localtime

#generate clock
hwclock --systohc

#localization
locale-gen

#language LANG=en_US.UTF-8
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

#set your hostname
echo -e "\033[32;1m Qual sera o nome da maquina na rede (hostname)\
	default=arch_linux\033[m"
read SET_HOSTNAME

#Network configuration

if [ -z "$SET_HOSTNAME" ]
	then
		echo "$SET_HOSTNAME" >> /etc/hostname
		echo "127.0.0.1 localhost\
                        ::1 localhost\
                        127.0.1.1 "$SET_HOSTNAME".localdomain "$SET_HOSTNAME"" >> /etc/hosts
	else
		echo "arch_linux" >> /etc/hostname
		echo "127.0.0.1 localhost\
			::1 localhost\
			127.0.1.1 arch_linux.localdomain arch_linux" >> /etc/hosts
fi
#create initramfs mkinitcpio
mkinitcpio -P

#set the root password 
passwd

#install bootloader em modo legacy (MBR)
grub-install --target=i386-pc  /dev/sda

#generate file grub
if [ -r /boot/grub/locale/en.mo ]
	then
	cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
else
	mkdir /boot/grub/locale
	touch /boot/grub/locale/en.mo
	cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
fi

#gera o arquivo de configuracao do grub
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager





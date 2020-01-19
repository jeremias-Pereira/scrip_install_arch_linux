#!/bin/bash
#
# script_instaler_arch_linux.sh
#
#	scrip de instalacao do SO ARCH linux
#	Autor: Jeremias Pereira da silva
#	Data:16/01/2020
#	Versao: 0.1
# 	Licensa: MIT								
#
#
# Este primeiro script faz a preparacao do disco e instala o pacote base
# E necessario executar o em siguida o script2_install_arch_linux.sh para finalizar a instalacao
#
#
#
#############################################################################################################################################################

COUNT_PARTITION=0
DISK=""
PART_HOME=""
PART_RAIZ=""
echo -e "\033[32;1m Bem Vindo ao Instalador do Arch linux\033[m"
echo 
echo -e "\033[32;1m Discos indentificados no sistema\033[m"
#exibe os discos disponiveis no sistema para a instalacao
fdisk -l |egrep "^Disk"|cut -d" " -f2|egrep ".{4}/[sh]"|sed "s/://g"
echo -e "\033[31;1m Sao necessarios no minimo 2 particoes \033[m"
echo -e "\033[31;1m Por padrao a primeira particao sera usada pra alocar o bootloader\033[m"
echo -e "\033[31;1m E recomendado cria a primeira particao com no minimo 512MB\033[m"
echo -e "\033[32;1m Qual disco voce quer usar para instalar seu novo SO Arch\033[m"
read DISK
#atribui o diretorio barra boot como a primeira particao do disco
PART_BOOT="${DISK}1"

#verificando se o disco informado para a instalacao existe
TEST=`fdisk -l |grep "$DISK"`
if [  -n "$TEST" ]
	then
		cfdisk "$DISK"
		
		#atribui a variavel a quandidade de particoes criadas no disco selecionado
		COUNT_PARTITION=$(fdisk -l |egrep "^${DISK}[1-9]"|wc -l)
		clear

		#atribui o sistema de arquivos do tipo vfat a particao que sera utilizada para instalar o bootloader mais adiante
		mkfs.vfat -F32 "$PART_BOOT"
		
		#verficacao se foram criadas mais que duas particoes 
		if [ $COUNT_PARTITION -gt 2 ];
			then
				for i in $(seq $COUNT_PARTITION);do
					if [ $i -ge 2 ] && [ $i -le $COUNT_PARTITION ];
						then 
						       	mkfs.ext4 "${DISK}${i}" 
					fi
				done
				clear
		else
			PART_RAIZ="${DISK}2"
			mkfs.ext4 "$PART_RAIZ"
		fi
else
	echo -e"\033[31;1m Disco Nao encontrado\033[m"
	exit 0
fi

if [ -z "$PART_RAIZ" ]
	then
		fdisk -l |grep "${DISK}[2-9]"|sort|cut -c1-10,40-48
		echo -e "\033[32;m Qual particao sera a RAIZ(/)\033[m"
		read PART_RAIZ
		echo -e "\033[32;m Qual sera aparticao Home (/home)\033[m"
		fdisk -l |grep "${DISK}[2-9]"|sort|cut -c1-10,40-48
		read PART_HOME
		clear
		
	fi
mount "$PART_RAIZ" /mnt
mkdir -p /mnt/boot
mount "$PART_BOOT" /mnt/boot
if [ $COUNT_PARTITION -gt 2 -a $COUNT_PARTITION -le 3 ]
	then
		mkdir -p /mnt/home
		mount "$PART_HOME" /mnt/home
fi
#instala os  pacotes base do sistema
pacstrap /mnt base linux linux-firmware

#gerando o arquivo fstab
genfstab -U /mnt >> /mnt/etc/fstab

#copiando o segundo script de instalacao para o novo sistema
cp ./script2_installer_arch_linux.sh /mnt
arch-chroot /mnt


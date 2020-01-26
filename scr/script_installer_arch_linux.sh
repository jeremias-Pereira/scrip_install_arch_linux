#!/bin/bash
#
# script_instaler_arch_linux.sh
#
#	scrip de instalacao do S.O ARCH linux
#	Autor: Jeremias Pereira da silva
#	Data:16/01/2020
#	Versao: 0.2
# 	Licensa: MIT								
#
#
# Este primeiro script faz a preparacao do disco e instala o pacote base
# E necessario executar em siguida o script2_install_arch_linux.sh para finalizar a instalacao
#
#
#
#############################################################################################################################################################

COUNT_PARTITION=0
DISK=""
PART_RAIZ=""
PART_USR=""
PART_HOME=""
PART_VAR=""
PART_OPT=""
PART_TMP=""

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
TEST=`fdisk -l |grep "${DISK}"`
if [  -n "${TEST}" ]
	then
		clear
		echo -e "\033[33;1m Obs: atribua a flag \033[31;1m Bootable \033[33;1m A primeira particao do disco ao entrar no particionador\033[m"
		sleep 3 

		cfdisk "${DISK}"
		clear

		PART_BOOT="${DISK}1"

		#atribui a variavel a quandidade de particoes criadas no disco selecionado
		COUNT_PARTITION=$(fdisk -l |egrep "^${DISK}[1-9]"|wc -l)
		clear

		#atribui o sistema de arquivos do tipo vfat a particao que sera utilizada para instalar o bootloader mais adiante
		mkfs.vfat -F32 "${PART_BOOT}"
		
		#verficacao se foram criadas mais que duas particoes 
		if [ ${COUNT_PARTITION} -gt 2 ];
			then
				for i in $(seq ${COUNT_PARTITION});do
					if [ $i -ge 2 ] && [ $i -le ${COUNT_PARTITION} ];
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
	echo -e "\033[31;1m Disco Nao encontrado\033[m"
	exit 0
fi

if [ -z "${PART_RAIZ}" ]
	then
		for i in $(seq ${COUNT_PARTITION}) ;
			do
				if [ $i -gt 1 ] 
				then

        			echo -e "\033[32;1m Qual o ponto de montagem da particao \n\n\033[31;1m${DISK}${i}\033[m"
				echo -e "\033[32;1m Pontos de montagem posiveis que podem ser montados fora do /(raiz)\033[33;1m\
					\n / \
					\n /root\
					\n /usr\
					\n /home\
					\n /var\
					\n /opt\
					\n /tmp\033[m"
        			read DISK_PART
				clear
				case "${DISK_PART}" in
					    '/') PART_RAIZ=${DISK}${i};;
				        '/root') PART_ROOT=${DISK}${i};;
				         '/usr') PART_USR=${DISK}${i};;
				        '/home') PART_HOME=${DISK}${i};;
				         '/var') PART_VAR=${DISK}${i};;
				         '/opt') PART_OPT=${DISK}${i};;
				         '/tmp') PART_TMP=${DISK}${i};;
				            "" )
				                 continue ;;

				        *) echo -e "\033[31;1m Ponto de montagem nao existe ou nao pode ser montada fora da particao\n\n\n\033[m"
				                exit 0;;
				esac
			fi
		done
	fi

mount "${PART_RAIZ}" /mnt
mkdir -p /mnt/boot
mount "${PART_BOOT}" /mnt/boot

if [ -z "${PART_HOME}" ]
then
	mkdir -p /mnt/home
	mount "${PART_HOME}" /mnt/home
fi
if [ -z "${PART_ROOT}" ]
then
	mkdir -p /mnt/root
	mount "${PART_ROOT}" /mnt/root
fi
if [ -z "${PART_USR}" ]
then
	mkdir -p /mnt/usr
	mount "${PART_USR}" /mnt/usr
fi
if [ -z "${PART_VAR}" ]
then
	mkdir -p /mnt/var
	mount "${PART_VAR}" /mnt/var
fi
if [ -z "${PART_OPT}" ]
then
	mkdir -p /mnt/opt
	mount "${PART_OPT}" /mnt/opt
fi
if [ -z "${PART_TMP}" ]
then
	mkdir -p /mnt/tmp
	mount "${PART_TMP}" /mnt/tmp
fi

pacstrap /mnt base linux linux-firmware

#gerando o arquivo fstab
genfstab -U /mnt >> /mnt/etc/fstab

#copiando o segundo script de instalacao para o novo sistema
cp ./script2_installer_arch_linux.sh /mnt
arch-chroot /mnt


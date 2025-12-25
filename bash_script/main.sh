	#!/usr/bin/env bash

	# esse script é um script SIMPLES de instalação para o meu sistema! ^^

	# declara variaveis para evitar erros
	home_disk=""
	home_fs=""
	system_disk=""
	system_fs=""
	root_fs=""
	
	set -euo pipefail # define a seguranca do script

	source ./functions.sh # importa as functions
	
	# verifica se o usuario e root/sudo
	if [[ $EUID -ne 0 ]]; then
    	echo "Este script precisa ser executado como root."
    	exit 1
	fi

	# alguns lembretes
	echo "--------------AVISOS-----------------"
	echo "comente o packages.nix na flake para uma instalação limpa!"
	echo "caso ja possua uma home sera necessario montar manualmente!"
	echo "NUNCA USE A MESMA UNIDADE PARA O SISTEMA E HOME!!!"
	echo "-------------------------------------"
	
	# interacao inicial
	while true; do
		echo "FileSystems: [ ext4, xfs, btrfs, f2fs, zfs, tmpfs ]"
		# passa parametros para dentro de funcoes, evitando repeticoes no codigo
		system_fs=$(ask_choice "qual o filesystem para o sistema? " ext4 xfs btrfs f2fs zfs tmpfs)
		system_disk=$(unidade "diga a unidade no qual o sistema vai ser instalado (/dev/sdX) ") 

		case $system_fs in
			tmpfs)
				echo "FileSystems: [ ext4, xfs, btrfs, f2fs ]"
				root_fs=$(ask_choice "no tmpfs e necessario definir um FileSystem comum para o persist " ext4 xfs btrfs f2fs )
				;;
			btrfs|zfs)
				resp_ephemeral=$(ask_choice "voce deseja ativar o root efemero?: " s n sim nao)
				;;
			f2fs|ext4|xfs)
				;;
		esac
		resp=$(ask_choice "Tem certeza? (s/n) " s n sim nao)

		case $resp in 
			s|sim)
				break;;
			n|nao)
				;;
		esac
	done
	
	clear

	resp2=$(ask_choice "deseja criar uma home? (s/n) " s n sim nao)

	case $resp2 in
		s|sim)
			echo "FileSystems: [ ext4, xfs, btrfs, f2fs, zfs, tmpfs ]"
			home_fs=$(ask_choice "Digite o filesystem da home " ext4 xfs btrfs f2fs zfs tmpfs)
			
			if [[ "$home_fs" != "tmpfs" ]]; then
  				home_disk=$(unidade "qual a unidade que a home vai ser instalada? (/dev/sdX) ")
			fi
			;;
		n|nao)
			;;
	esac

	clear

	while true; do
		echo "-------ALTERACOES-------" 
		echo "DISCO DA HOME: $home_disk"
		echo "FS DA HOME: $home_fs"
		echo "DISCO DO SISTEMA: $system_disk"
		echo "FS DO SISTEMA: $system_fs"
		echo "------------------------"

		read -p "deseja continuar, abortar ou mudar algo? (continue/abort/change) " resp3

		case "${resp3,,}" in
			abort)
				echo "operacao encerrada pelo usuario"; exit 130;;
			continue)
				break;;
			change)
				change; continue;; # chama a funcao 'change' e retorna ao loop apos sua execucao
			*)
				echo "opcao invalida";;
		esac
	done

	clear
	
	source ./filesystems.sh # importa o script final para instalar o sistema

	exit 0
	#!/usr/bin/env bash

	# esse script é um script SIMPLES de instalação para o meu sistema! ^^

	# declara variaveis para evitar erros
	home_disk=""
	home_fs=""
	system_disk=""
	system_fs=""
	root_fs=""
	resp_ephemeral=""
	resp2=""
	resp3=""

	RED="\e[91m" # prefiro o vermelho mais claro!
	GREEN="\e[32m"
	YELLOW="\e[33m"
	BLUE="\e[34m"
	RESET="\e[0m"

	# esse sera um arquivo imutavel
	file="/mnt/nix/git/general-configs/filesystems/definition.nix"
	
	set -euo pipefail # define a seguranca do script

	source ./functions.sh # importa as functions
	
	# verifica se o usuario e root/sudo
	if [[ $EUID -ne 0 ]]; then
    	error "Este script precisa ser executado como root."
    	exit 1
	fi

	# alguns lembretes
	warn " --------------AVISOS-----------------"
	info " comente o packages.nix na flake para uma instalação limpa!"
	info " caso ja possua uma home sera necessario montar manualmente!"
	info " NUNCA USE A MESMA UNIDADE PARA O SISTEMA E HOME!!!"
	info " lembre-se de colocar sua senha em /mnt/nix/ antes de instalar!"
	warn " -------------------------------------"
	
	# interacao inicial
	warn "F2FS ESTA MARCADO GERALMENTE E INSTAVEL, USAR ELE SERA POR SUA CONTA E RISCO!"
	info "FileSystems: [ ext4, xfs, btrfs, f2fs, zfs, tmpfs ]"
	# passa parametros para dentro de funcoes, evitando repeticoes no codigo
	system_fs=$(ask_choice "qual o filesystem para o sistema? " ext4 xfs btrfs f2fs zfs tmpfs)
	system_disk=$(unidade "diga a unidade no qual o sistema vai ser instalado (/dev/sdX) " system) 

	case $system_fs in
		tmpfs)
			info "FileSystems: [ ext4, xfs, btrfs, f2fs ]"
			root_fs=$(ask_choice "no tmpfs e necessario definir um FileSystem comum para o persist " ext4 xfs btrfs f2fs )
			;;
		btrfs|zfs)
			resp_ephemeral=$(ask_choice "voce deseja ativar o root efemero?: (s/n) " s n sim nao);;
	esac
	
	clear

	resp2=$(ask_choice "deseja criar uma home? (s/n) " s n sim nao)

	case $resp2 in
		s|sim)
			info "FileSystems: [ ext4, xfs, btrfs, f2fs, zfs, tmpfs ]"
			home_fs=$(ask_choice "Digite o filesystem da home " ext4 xfs btrfs f2fs zfs tmpfs)
			
			if [[ "$home_fs" != "tmpfs" ]]; then
  				home_disk=$(unidade "qual a unidade que a home vai ser instalada? (/dev/sdX1) " home)
			fi
			;;
	esac

	clear

	warn " -------ALTERACOES-------" 
	info " DISCO DA HOME:    $home_disk"
	info " FS DA HOME:       $home_fs"
	info " DISCO DO SISTEMA: $system_disk"
	info " FS DO SISTEMA:    $system_fs"
	warn " ------------------------"

	resp3=$(ask_choice "deseja continuar ou abortar? (continue/abort) " continue abort)

	case "${resp3,,}" in
		abort)
			success "operacao encerrada pelo usuario"; exit 130;;
	esac

	clear
	
	source ./filesystems.sh # importa o script final para instalar o sistema

	exit 0
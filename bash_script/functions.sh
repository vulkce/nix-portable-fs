	unidade() {
		local prompt="$1"	
		local dev

		while true; do
			read -p "$prompt" dev

			if lsblk "$dev" &>/dev/null; then
				break
			else
				echo "A unidade $dev nao foi encontrada, mude isso" >&2
				continue
			fi
		done

		echo "$dev"; return 0
	}

	ask_choice() {
		local prompt="$1"
		shift
		local options=("$@")
		local resp
		while true; do
			read -p "$prompt" resp
			resp="${resp,,}"
			for opt in "${options[@]}"; do
				[[ "$resp" == "$opt" ]] && { echo "$resp"; return 0; }
			done
			echo "Opção inválida, tente novamente." >&2
		done
	}

	boot() {
		# reconstroi o disco com gpt
		wipefs -a $system_disk
		parted $system_disk mklabel gpt
		
		# cria particao de 1GB para boot
		parted -a optimal $system_disk mkpart primary 0% 1GB
		
		# formata a particao de boot para fat32
		mkfs.fat -F 32 -n BOOT ${system_disk}1
		
		# flags de para particao boot
		parted $system_disk set 1 esp on
		parted $system_disk set 1 boot on

		# cria a  segunda particao usando o restante do disco
		parted -a optimal $system_disk mkpart primary 1GB 100%

		return 0
	}

	makeHome() {
		if [[ -n "$home_fs" ]]; then

			if [[ "$home_fs" != "tmpfs" ]]; then
  				wipefs -a $home_disk
				parted $home_disk mklabel gpt
			fi
			
			# muda nas configuracoes para o fs da home escolhido
			sed -i "19c\  fsHome = \"$home_fs\";" /mnt/git/general-configs/filesystems/definition.nix

			case $home_fs in
				ext4|xfs|btrfs)
					mkfs.$home_fs -L home -f $home_disk # cria a home com as opcoes escolhidas
					mount -o noatime /dev/disk/by-label/home /mnt/home # monta a home
					;;
				f2fs)
					mkfs.$home_fs -l home -f $home_disk # cria a home com as opcoes escolhidas
					mount -o noatime /dev/disk/by-label/home /mnt/home # monta a home
					;;
				zfs)
					zpool create -f -o ashift=12 home $home_disk # cria um pool
					zfs create -o mountpoint=legacy home/user # cria um dataset
					mount -t zfs home/user /mnt/home # monta o dataset
					sed -i '11c\    zfsH = true;' /mnt/git/general-configs/filesystems/definition.nix
					;;
				tmpfs)
					mkdir -p /mnt/nix/safe/home
					sed -i '12c\    tmpfsH = true;' /mnt/git/general-configs/filesystems/definition.nix
					;;
				*) 
					echo "ocorreu um erro ao tentar encontrar o filesystem $home_fs em $home_disk" 
					exit 2
					;;
			esac
		fi
	}
	
	install() {
		# clona as configs
		git clone https://github.com/vulkce/ephemeral-dotfiles-nix.git /mnt/git/
		
		case $system_fs in
			btrfs|zfs)
				sed -i "9c\     fsBackend = \"$system_fs\";" /mnt/git/general-configs/filesystems/definition.nix

				if [[ "$resp_ephemeral" == "s" || "$resp_ephemeral" == "sim" ]]; then
    				sed -i "187c\   ./ephemeral/$system_fs.nix;" /mnt/git/general-configs/filesystems/definition.nix
				fi
				;;
			f2fs|ext4|xfs)
				sed -i '9c\     fsBackend = "common";' /mnt/git/general-configs/filesystems/definition.nix
				sed -i "18c\     fsRoot = \"$root_fs\";" /mnt/git/general-configs/filesystems/definition.nix
				;;
			tmpfs)
				sed -i "9c\     fsBackend = \"$system_fs\";" /mnt/git/general-configs/filesystems/definition.nix
				sed -i "18c\     fsRoot = \"$root_fs\";" /mnt/git/general-configs/filesystems/definition.nix
				sed -i '13c\    tmpfs = true;' /mnt/git/general-configs/filesystems/definition.nix
				;;
			*)
				echo "ocorreu um erro ao encontrar o FileSystem de ${system_disk}, nenhuma acao destrutiva foi realizada"
				
				exit 2
				;;
		esac

		makeHome

		# monta o boot
		mount /dev/disk/by-label/BOOT /mnt/boot

		# instala o sistema
		echo "agora voce pode instalar o sistema!"
		echo "nixos-install --flake /mnt/git#flake"

		return 0
	}

    change() {
		while true; do
			resp4=$(ask_choice "o que voce deseja alterar? (home_disk, home_fs, system_disk, system_fs) " home_disk home_fs system_disk system_fs)
			echo "FileSystems disponiveis: [ ext4, xfs, btrfs, f2fs, zfs, tmpfs ]"
			case $resp4 in
				home_disk)
					home_disk=$(unidade "escolha a nova unidade para home (/dev/sdX)")
					break
					;;
				home_fs)
					home_fs=$(ask_choice "escolha o novo FileSystem para a home " ext4 xfs btrfs f2fs zfs tmpfs)
					break
					;;
				system_disk)
					system_disk=$(unidade "escolha a nova unidade para o sistema (/dev/sdX) ")
					break
					;;
				system_fs)
					system_fs=$(ask_choice "escolha o novo FileSystem para o sistema: " ext4 xfs btrfs f2fs zfs tmpfs)
					break
					;;
			esac
		done

		return 0
    }
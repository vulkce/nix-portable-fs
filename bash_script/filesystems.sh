    case $system_fs in
        btrfs)
            boot # constroi o boot

            mkfs.btrfs -L nixos -f ${system_disk}2
            sync

            # Montar e criar subvolumes
            mount ${system_disk}2 /mnt

            btrfs subvolume create /mnt/root
            btrfs subvolume create /mnt/nix
            btrfs subvolume create /mnt/safe

            # Criar snapshot vazia
            btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

            umount /mnt

            # Montar a raiz
            mount -o subvol=root,noatime ${system_disk}2 /mnt

            # cria os diretórios no liveCD 
            mkdir -p /mnt/{nix,safe,boot,home,nix/git}

            # Montar outros subvolumes do sistema
            mount -o subvol=nix,noatime ${system_disk}2 /mnt/nix
            mount -o subvol=safe,compress=lz4,noatime ${system_disk}2 /mnt/safe

            install # executa a instalacao
            ;;
        zfs)
            boot # constroi o boot

            zpool create -f -o ashift=12 nixos ${system_disk}2 # ashift=12 é bom para SSDs 
            sync 

            zfs create -o mountpoint=legacy nixos/system # cria um dataset

            zfs set acltype=posixacl nixos/system # define as permissões do ZFS como POSIX

            # cria sub-datasets
            zfs create -p -o mountpoint=legacy nixos/system/root
            zfs create -p -o mountpoint=legacy nixos/system/nix
            zfs create -p -o mountpoint=legacy nixos/system/safe

            zfs set compression=lz4 nixos/system # compressão

            # monta os datasets
            mount -t zfs nixos/system/root /mnt
            mkdir -p /mnt/{nix,safe,boot,home,nix/git}
            mount -t zfs nixos/system/nix /mnt/nix
            mount -t zfs nixos/system/safe /mnt/safe

            zfs snapshot nixos/system/root@blank # cria uma snapshot vazia do root
            
            install # executa a instalacao
            ;;		
        tmpfs)
            boot # constroi o boot

            case $root_fs in
                btrfs|ext4|xfs)
                    mkfs.$root_fs -L nixos -f ${system_disk}2
                    sync
                    ;;
                f2fs)
                    mkfs.$root_fs -l nixos -f ${system_disk}2
                    sync
                    ;;
            esac

            mount ${system_disk}2 /mnt

            mkdir -p /mnt/{nix/safe/system,boot,home,nix/git}

            install # executa a instalacao
            ;;
        ext4|xfs)
            boot # constroi o boot

            mkfs.$system_fs -L nixos -f ${system_disk}2 # formata a particao do sistema
            sync

            mount ${system_disk}2 /mnt

            mkdir -p /mnt/{nix,boot,home,nix/git}
            
            install # executa a instalacao
            ;;
        f2fs)
            boot # constroi o boot

            mkfs.f2fs -l nixos -f ${system_disk}2 # formata a particao do sistema
            sync

            mount ${system_disk}2 /mnt

            mkdir -p /mnt/{nix,boot,home,nix/git}
            
            install # executa a instalacao
            ;;
        *)
            echo "ocorreu um erro ao encontrar o FileSystem de ${system_disk}, nenhuma acao destrutiva foi realizada"
            
            exit 2
            ;;
    esac
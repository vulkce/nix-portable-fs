#!/usr/bin/env bash

# esse script é um script SIMPLES de instalação para o meu sistema! ^^
resp="n"

echo "--------------LEMBRETES--------------"
echo "lembre-se de ter uma home criada em XFS antes de executar isso!"
echo "rode como root para funcionar!"
echo "comente o packages.nix das flakes para uma instalação limpa!"
echo "-------------------------------------"

while [ $resp = "n" ]; do
  echo "digite '1' para BTRFS e '2' para ZFS"
  read fstype
  echo "diga a unidade no qual o sistema vai ser instalado (/dev/sdX)"
  read unidade 
  echo "unidade digitada: $unidade"
  echo "isso está correto? (s/n)"
  read resp
  echo "-------------------"
done

if [ "$fstype" = "1" ]; then

  # -------- BTRFS --------
  mkfs.btrfs -L nixos $unidade

  # Montar e criar subvolumes
  mount /dev/disk/by-label/nixos /mnt

  btrfs subvolume create /mnt/root
  btrfs subvolume create /mnt/nix
  btrfs subvolume create /mnt/persist

  # Criar snapshot vazia
  btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

  umount /mnt

  # Montar a raiz
  mount -o subvol=root,compress=zstd,noatime /dev/disk/by-label/nixos /mnt

  # Criar diretórios
  mkdir -p /mnt/{nix,persist,boot,home}

  # Montar outros subvolumes do sistema
  mount -o subvol=nix,compress=zstd,noatime /dev/disk/by-label/nixos /mnt/nix
  mount -o subvol=persist,compress=zstd,noatime /dev/disk/by-label/nixos /mnt/persist

  # Montar boot
  mount /dev/disk/by-label/BOOT /mnt/boot

  # Montar home
  mount -o noatime /dev/disk/by-label/home /mnt/home # é necessário ter uma home já

  # muda nas configurações para btrfs
  sed -i '5c\   ./filesystems/btrfs.nix # importa o filesystem' /mnt/persist/general-configs/system.nix

  git clone https://github.com/vulkce/ephemeral-dotfiles-nix.git /mnt/persist/

else

  # -------- ZFS --------
  # estou usando atualmente

  zpool create -f -o ashift=12 nixos $unidade # ashift=12 é bom para SSDs

  zfs create nixos/system # cria um dataset

  # cria sub-datasets
  zfs create -p -o mountpoint=legacy nixos/system/root 
  zfs create -p -o mountpoint=legacy nixos/system/nix
  zfs create -p -o mountpoint=legacy nixos/system/persist

  zfs set compression=lz4 nixos/system # compressão, opcional

  # prepara para instalação
  mount -t zfs nixos/system/root /mnt

  mkdir -p /mnt/{nix,persist,boot,home} # cria os diretórios

  # monta os datasets
  mount -t zfs nixos/system/nix /mnt/nix
  mount -t zfs nixos/system/persist /mnt/persist
  mount /dev/disk/by-label/BOOT /mnt/boot
  
  mount -o noatime /dev/disk/by-label/home /mnt/home # é necessário ter uma home já

  zfs snapshot nixos/system/root@blank # cria uma snapshot vazia do root

  zfs set acltype=posixacl nixos/system # define as permissões do ZFS como POSIX

  # muda nas configurações para zfs
  sed -i '5c\   ./filesystems/zfs.nix # importa o filesystem' /mnt/persist/general-configs/system.nix

  git clone https://github.com/vulkce/ephemeral-dotfiles-nix.git /mnt/persist/

fi

exit 0

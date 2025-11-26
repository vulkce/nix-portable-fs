```bash

# esse script é um script de instalação para o meu sistema! ^^

mkfs.btrfs -L nixos /dev/sdX

# Montar e criar subvolumes
mount /dev/disk/by-label/nixos /mnt

btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/var_log

# Criar snapshot vazia
btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

umount /mnt

# Montar a raiz
mount -o subvol=root,compress=zstd,noatime /dev/disk/by-label/nixos /mnt

# Criar diretórios
mkdir -p /mnt/{nix,persist,var/log,boot,home}

# Montar outros subvolumes do sistema
mount -o subvol=nix,compress=zstd,noatime /dev/disk/by-label/nixos /mnt/nix
mount -o subvol=persist,compress=zstd,noatime /dev/disk/by-label/nixos /mnt/persist
mount -o subvol=var_log,compress=zstd,noatime /dev/disk/by-label/nixos /mnt/var/log

# Montar boot
mount /dev/disk/by-label/BOOT /mnt/boot

# Montar home
mount -o noatime /dev/disk/by-label/home /mnt/home

git clone https://github.com/vulkce/ephemeral-dotfiles-nix.git /mnt/persist/
```

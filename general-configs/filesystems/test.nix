{ config, lib, pkgs, ... }:

let
  # seleciona o FS
  fsBackend = "zfs";  # btrfs | zfs | tmpfs | common

  zfsH   = false;
  tmpfsH = false;
  tmpfs  = false;

  # filesystems
  fsRoot = if fsBackend == "tmpfs" then "ext4" else "xfs";  # FIX: não pode ser vazio
  fsHome = "xfs";

  commonOpts = [ "noatime" ];

  # Devices
  homeDevice =
    if zfsH then "home/user"
    else if tmpfsH then "none"
    else "/dev/disk/by-label/home";

  rootDevice = "/dev/disk/by-label/nixos";

  # Base comum
  baseFileSystems = {
    "/" = {
      neededForBoot = true;
    };
  };

  # Backends
  backends = {
    btrfs = {
      "/" = {
        device  = rootDevice;
        fsType  = "btrfs";
        options = commonOpts ++ [ "subvol=root" ];
      };

      "/nix" = {
        device  = rootDevice;
        fsType  = "btrfs";
        options = commonOpts ++ [ "subvol=nix" ];
      };

      "/safe" = {
        device  = rootDevice;
        fsType  = "btrfs";
        neededForBoot = true;
        options = commonOpts ++ [ "subvol=safe" "compress=lz4" ];  # FIX: uma lista só
      };
    };

    zfs = {
      "/" = {
        device  = "nixos/system/root";
        fsType  = "zfs";
        options = commonOpts;
      };

      "/nix" = {
        device  = "nixos/system/nix";
        fsType  = "zfs";
        options = commonOpts;
      };

      "/safe" = {
        device  = "nixos/system/safe";
        fsType  = "zfs";
        neededForBoot = true;
        options = commonOpts;  # FIX: removido compress=lz4
      };
    };

    tmpfs = {
      "/" = {
        device  = "none";
        fsType  = "tmpfs";
        options = [ "size=4G" "mode=755" ];
      };

      "/nix" = {
        device  = rootDevice;
        fsType  = fsRoot;
        options = commonOpts;
      };
    };

    common = {
      "/" = {
        device  = rootDevice;
        fsType  = fsRoot;
        options = commonOpts;
      };
    };
  };

  fileSystemsConfig = lib.recursiveUpdate baseFileSystems backends.${fsBackend};

in
{
  fileSystems = fileSystemsConfig;

  # FIX: Configuração correta de persistence
  environment.persistence = lib.mkIf tmpfs {
    "/nix/safe/system" = {
      enable = true;
      hideMounts = true;
      directories = [
        "/etc/nixos"
        "/var/lib/flatpak"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
      ];
      files = [ "/etc/machine-id" ];
    };
  } // lib.mkIf tmpfsH {
    "/nix/safe/home" = {
      enable = true;
      hideMounts = true;
      users.vulkce = {
        directories = [
          ".cache/nix"
          ".ssh"
          "Documents"
          "Projects"
        ];
        files = [ ".gitconfig" ];
      };
    };
  };
}
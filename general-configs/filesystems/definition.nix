{ config, lib, pkgs, ... }:

let
  # =========================
  # seleciona o FS
  # =========================
  
  # btrfs | zfs | tmpfs | common
  fsBackend = "";

  zfsH   = false;
  tmpfsH = false;
  tmpfs  = false;

  # =========================
  # filesystems
  # =========================
  fsRoot = "";
  fsHome = "";

  commonOpts = [ "noatime" "nodiratime" ];

  # =========================
  # Devices - MEOW
  # =========================
  homeDevice =
    if zfsH then "home/user"
    else if tmpfsH then "none"
    else "/dev/disk/by-label/home";

  rootDevice = "/dev/disk/by-label/nixos";

  # =========================
  # Base comum (merge)
  # =========================
  baseFileSystems = {
    "/" = {
      neededForBoot = true;
    };
  };

  # =========================
  # Persistence
  # =========================
  tmpfsConfig =
    if tmpfs then {
      persistence."/nix/safe/system" = {
        enable = true;
        hideMounts = true;

        directories = [
          "/etc/nixos"
          "/var/lib/flatpak"
          "/var/lib/nixos"
          "/var/lib/nixos-containers"
          "/var/lib/systemd/coredump"
          "/var/lib/bluetooth"
          "/etc/NetworkManager/system-connections"
        ];

        files = [
          "/etc/machine-id"
        ];
      };
    }

    else if tmpfsH then {
      persistence."/nix/safe/home" = {
        enable = true;
        hideMounts = true;

        users.vulkce = {
          directories = [
            ".cache/nix"
            ".local/share/nix"
            ".ssh"
            "Desktop"
            "Documents"
            "Music"
            "Pictures"
            "Projects"
            "Public"
            "Templates"
            "Videos"
            ".config"
            ".local/share/flatpak"
            ".local/share/PrismLauncher"
            ".var"
            "passwords"
          ];

          files = [
            ".env"
            ".gitconfig"
          ];
        };
      };
    }

    else {};

  # =========================
  # Backends - MEOW!
  # =========================
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

      "/safe/system" = {
        device  = rootDevice;
        fsType  = "btrfs";
        neededForBoot = true;
        options = commonOpts ++ [ "subvol=safe" ] [ "compress=lz4" ];
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

      "/safe/system" = {
        device  = "nixos/system/safe";
        fsType  = "zfs";
        neededForBoot = true;
        options = commonOpts ++ [ "compress=lz4" ];
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

  # =========================
  # merge final!
  # =========================
  fileSystemsConfig =
    lib.recursiveUpdate baseFileSystems backends.${fsBackend};

in
{
  fileSystems = fileSystemsConfig;
  environment = tmpfsConfig;

  imports = [
  
  ];

  # =========================
  # Specialisations
  # =========================
  specialisation = {
    Home = {
      inheritParentConfig = true;

      configuration = {
        system.nixos.tags = [ "Home" ];

        fileSystems."/home" = {
          device  = homeDevice;
          fsType  = fsHome;
          options = [ "mode=0755" ] ++ commonOpts;
        };
      };
    };

    TempHome = {
      inheritParentConfig = true;

      configuration = {
        system.nixos.tags = [ "TempHome" ];

        fileSystems."/home" = {
          device  = "none";
          fsType  = "tmpfs";
          options = [ "size=8G" "mode=0755" ];
        };

        systemd.tmpfiles.settings."10-home-vulkce" = {
          "/home/vulkce".d = {
            mode  = "0755";
            user  = "vulkce";
            group = "users";
          };
        };
      };
    };
  };
}
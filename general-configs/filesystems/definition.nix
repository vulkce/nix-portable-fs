{ config, lib, pkgs, ... }:

let
  # =========================
  #     seleciona o FS
  # =========================
  
  # btrfs | zfs | tmpfs | common
  fsBackend = "";

  zfsH   = false;
  tmpfsH = false;
  tmpfs  = false;

  # =========================
  #       filesystems
  # =========================
  fsRoot = "";
  fsHome = "";

  # =========================
  #     Devices - MEOW
  # =========================
  homeDevice =
    if zfsH then "home/user"
    else if tmpfsH then "none"
    else "/dev/disk/by-label/home";

  rootDevice = "/dev/disk/by-label/nixos";

  # =========================
  #   Base comum (merge)
  # =========================
  baseFileSystems = {
    "/" = {
      neededForBoot = true;
    };
  };

  # =========================
  #     Backends - MEOW!
  # =========================
  backends = {
    btrfs = {
      "/" = {
        device  = rootDevice;
        fsType  = "btrfs";
        options = [ "noatime" "subvol=root" ];
      };

      "/nix" = {
        device  = rootDevice;
        fsType  = "btrfs";
        options = [ "noatime" "subvol=nix" ];
      };

      "/safe" = {
        device  = rootDevice;
        fsType  = "btrfs";
        neededForBoot = true;
        options = [ "noatime" "subvol=safe" "compress=lz4" ];
      };
    };

    zfs = {
      "/" = {
        device  = "nixos/system/root";
        fsType  = "zfs";
      };

      "/nix" = {
        device  = "nixos/system/nix";
        fsType  = "zfs";
      };

      "/safe" = {
        device  = "nixos/system/safe";
        fsType  = "zfs";
        neededForBoot = true;
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
        options = [ "noatime" ];
      };
    };

    common = {
      "/" = {
        device  = rootDevice;
        fsType  = fsRoot;
        options = [ "noatime" ];
      };
    };
  };

  # =========================
  #       merge final!
  # =========================
  fileSystemsConfig =
    lib.recursiveUpdate baseFileSystems backends.${fsBackend};

in
{
  fileSystems = fileSystemsConfig;

  # complementos opcionais
  imports = [
  
  ];

  # =========================
  #       Persistence
  # =========================
  environment.persistence = lib.mkIf tmpfs {
    "/nix/safe/system" = {
      enable = true;
      hideMounts = true;

      directories = [
        "/git"
        "/etc/nixos"
        "/var/lib/flatpak"
        "/var/lib/nixos"
        "/var/lib/nixos-containers"
        "/var/lib/systemd/coredump"
        "/var/lib/bluetooth"
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
          "Desktop"
          "Pictures"
          "Projects"
          "Videos"
          ".config"
          ".local/share"
          ".var"
          ".nix-defexpr"
          ".pki"
        ];
        files = [ 
          ".gitconfig" 
          ".env"
          ".gtkrc-2.0"
          ];
      };
    };
  };

  # =========================
  #     Specialisations
  # =========================
  specialisation = {
    Home = {
      inheritParentConfig = true;

      configuration = {
        system.nixos.tags = [ "Home" ];

        fileSystems."/home" = {
          device  = homeDevice;
          fsType  = fsHome;
          options = [ "noatime" "nofail" "x-systemd.device-timeout=5" ];
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

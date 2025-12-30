{ config, lib, pkgs, ... }:

# =========================
#        ARQUIVO
#        IMUTAVEL
# =========================

let  
  # btrfs | zfs | tmpfs | common
  fsBackend = "";

  # non-common
  zfsH   = false; # zfs na home
  tmpfsH = false; # tmpfs na home

  # common
  fsRoot = ""; # fs do root
  fsHome = ""; # fs da Home

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
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

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
        options = [ "noatime" "subvol=safe" ];
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
        options = [ "defaults" "size=25%" "mode=755" ];
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
        options = [ "noatime" "subvol=safe" ];
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

  # complementos
  imports = [
  
  
  ];

  # filesystems
  boot = {
    supportedFilesystems = [ 
      "zfs" 
      "ext4" 
      "xfs" 
      "ntfs" 
      "btrfs"
      "f2fs"
    ];
    # protege o zfs
    zfs.removeLinuxDRM = true;
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
          options = [ "mode=0755" "noatime" "nofail" "x-systemd.device-timeout=5" ];
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
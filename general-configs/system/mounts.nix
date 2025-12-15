{ config, lib, pkgs, ... }: {

# -------- SYSTEM --------

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "zfs";
  #  options = [ "subvol=root" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "zfs";
  #  options = [ "subvol=nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "zfs";
  #  options = [ "subvol=persist" "compress=zstd" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "zfs";
  #  options = [ "subvol=var_log" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

# -------- TempHome --------

  specialisation = {
    Home = {
      inheritParentConfig = true;
      configuration = {
        system.nixos.tags = [ "Home" ];
        # home separada
        fileSystems."/home" = {
          device = "/dev/disk/by-label/home";
          fsType = "xfs";
          options = [ "noatime" "nofail" "x-systemd.device-timeout=5" ];
        };
      };
    };
    TempHome = {
      inheritParentConfig = true;
      configuration = {
        system.nixos.tags = [ "TempHome" ];
        # home interna
        fileSystems."/home" = {
          device = "none"; 
          fsType = "tmpfs"; # filesystem temporário na ram
          options = [ "size=8G" "mode=777" ]; # options para o tmpfs
        };
        # usa systemd para criar uma home
        systemd.tmpfiles.settings."10-home-vulkce" = {
          "/home/vulkce".d = {
            mode = "0755";
            user = "vulkce";
            group = "users";
          };
        };
      };
    };
  };

# -------- PERSIST --------

  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/lib/nixos"
      "/var/lib/nixos-containers"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/general-configs"
      "/home-manager"
      "/.git" 
    ];
    files = [
      "/etc/machine-id"
      "/flake.nix"
      "/flake.lock"
      "/subvolume.nix"
      "/bash.sh"
    ];
  };

# -------- PERSONAL --------

  fileSystems."/home/vulkce/Documents/etc1" = {
    device = "/dev/disk/by-uuid/2896792c-503e-4e52-bbd6-05fc5ae67675";
    fsType = "btrfs";
    options = [ "users" "exec" "nofail" ];
  };

  fileSystems."/home/vulkce/Documents/HD1" = {
    device = "/dev/disk/by-uuid/2a01b06c-f29d-4375-9c18-f5d3733df8e7";
    fsType = "btrfs";
    options = [ "users" "exec" "nofail" ];
  };

  fileSystems."/home/vulkce/Documents/HD2" = {
    device = "/dev/disk/by-uuid/1b8e11e0-d2f3-4d74-833a-1a1aca422b89";
    fsType = "btrfs";
    options = [ "users" "exec" "nofail" ];
  };

  fileSystems."/home/vulkce/Documents/etc2" = {
    device = "/dev/disk/by-uuid/d47d9f1f-c57e-41b9-95cd-48f75d0500c8";
    fsType = "btrfs";
    options = [ "users" "exec" "nofail" ];
  };
  
}
